using Flexio.Application.Abstractions;
using Flexio.Domain.Identity;
using Flexio.Infrastructure.Persistence;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace Flexio.IntegrationTests.Persistence;

/// <summary>
/// A UnitOfWork + RLS szerződés: a felhasználó csak a saját sorait látja, és
/// kontextus nélkül egyáltalán semmit. A tesztek a valódi Postgres policy-ket
/// járják be, nem mockot.
/// </summary>
[Collection(PostgresCollection.Name)]
public sealed class RowLevelSecurityTests
{
    private readonly PostgresFixture _fixture;

    public RowLevelSecurityTests(PostgresFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task User_only_sees_own_diary_rows()
    {
        var alice = UserId.From(Guid.NewGuid());
        var bob = UserId.From(Guid.NewGuid());
        var aliceEntryId = Guid.NewGuid();
        var bobEntryId = Guid.NewGuid();

        await using var root = BuildServices();
        await using var scope = root.CreateAsyncScope();
        var unitOfWork = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
        var session = scope.ServiceProvider.GetRequiredService<DbSession>();

        await using (var writeScope = await unitOfWork.BeginWriteAsync(alice, CancellationToken.None))
        {
            await InsertDiaryEntryAsync(session, aliceEntryId, alice, "Alice saláta");
            await writeScope.CommitAsync(CancellationToken.None);
        }

        await using (var writeScope = await unitOfWork.BeginWriteAsync(bob, CancellationToken.None))
        {
            await InsertDiaryEntryAsync(session, bobEntryId, bob, "Bob pizza");
            await writeScope.CommitAsync(CancellationToken.None);
        }

        await using (var readScope = await unitOfWork.BeginReadAsync(alice, CancellationToken.None))
        {
            var names = await ListFoodNamesAsync(session);
            Assert.Equal(["Alice saláta"], names);
            await readScope.CommitAsync(CancellationToken.None);
        }

        await using (var readScope = await unitOfWork.BeginReadAsync(bob, CancellationToken.None))
        {
            var names = await ListFoodNamesAsync(session);
            Assert.Equal(["Bob pizza"], names);
            await readScope.CommitAsync(CancellationToken.None);
        }
    }

    [Fact]
    public async Task User_cannot_update_another_users_row()
    {
        var alice = UserId.From(Guid.NewGuid());
        var bob = UserId.From(Guid.NewGuid());
        var aliceEntryId = Guid.NewGuid();

        await using var root = BuildServices();
        await using var scope = root.CreateAsyncScope();
        var unitOfWork = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
        var session = scope.ServiceProvider.GetRequiredService<DbSession>();

        await using (var writeScope = await unitOfWork.BeginWriteAsync(alice, CancellationToken.None))
        {
            await InsertDiaryEntryAsync(session, aliceEntryId, alice, "Alice saláta");
            await writeScope.CommitAsync(CancellationToken.None);
        }

        await using (var writeScope = await unitOfWork.BeginWriteAsync(bob, CancellationToken.None))
        {
            var affected = await UpdateFoodNameAsync(session, aliceEntryId, "Bob átírta");
            Assert.Equal(0, affected);
            await writeScope.CommitAsync(CancellationToken.None);
        }

        await using (var readScope = await unitOfWork.BeginReadAsync(alice, CancellationToken.None))
        {
            var names = await ListFoodNamesAsync(session);
            Assert.Equal(["Alice saláta"], names);
            await readScope.CommitAsync(CancellationToken.None);
        }
    }

    [Fact]
    public async Task Query_without_unit_of_work_scope_is_rejected()
    {
        await using var root = BuildServices();
        await using var scope = root.CreateAsyncScope();
        var session = scope.ServiceProvider.GetRequiredService<DbSession>();

        var exception = Assert.Throws<InvalidOperationException>(() => _ = session.Connection);
        Assert.Contains("IUnitOfWork", exception.Message, StringComparison.Ordinal);
    }

    [Fact]
    public async Task Read_only_transaction_rejects_writes()
    {
        var alice = UserId.From(Guid.NewGuid());

        await using var root = BuildServices();
        await using var scope = root.CreateAsyncScope();
        var unitOfWork = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
        var session = scope.ServiceProvider.GetRequiredService<DbSession>();

        await using var readScope = await unitOfWork.BeginReadAsync(alice, CancellationToken.None);
        var exception = await Assert.ThrowsAsync<PostgresException>(async () =>
            await InsertDiaryEntryAsync(session, Guid.NewGuid(), alice, "Nem szabad"));
        Assert.Equal("25006", exception.SqlState);
    }

    [Fact]
    public async Task Privilege_guard_accepts_api_role_without_bypassrls()
    {
        await using var root = BuildServices(startupProbeAttempts: 1);
        var guard = root.GetRequiredService<PostgresPrivilegeGuard>();

        await guard.EnsureSafeAsync(CancellationToken.None);
    }

    [Fact]
    public async Task Jobs_role_can_write_catalog_but_not_diary()
    {
        await using var jobsConnection = new NpgsqlConnection(_fixture.JobsConnectionString);
        await jobsConnection.OpenAsync();

        await using (var insertFood = new NpgsqlCommand(
            """
            insert into public.foods (id, source, name, owner_id, kcal, protein, fat, carbs)
            values (@id, 'curated', 'Teszt alma', null, 52, 0.3, 0.2, 14)
            """,
            jobsConnection))
        {
            insertFood.Parameters.AddWithValue("id", Guid.NewGuid());
            var foodRows = await insertFood.ExecuteNonQueryAsync();
            Assert.Equal(1, foodRows);
        }

        await using var insertDiary = new NpgsqlCommand(
            """
            insert into public.diary_entries (id, user_id, food_name)
            values (@id, @userId, 'Jobs nem írhat naplót')
            """,
            jobsConnection);
        insertDiary.Parameters.AddWithValue("id", Guid.NewGuid());
        insertDiary.Parameters.AddWithValue("userId", Guid.NewGuid());

        var exception = await Assert.ThrowsAsync<PostgresException>(
            () => insertDiary.ExecuteNonQueryAsync());
        Assert.Equal("42501", exception.SqlState);
    }

    private ServiceProvider BuildServices(int startupProbeAttempts = 0)
    {
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Postgres:ApiConnectionString"] = _fixture.ApiConnectionString,
                ["Postgres:JobsConnectionString"] = _fixture.JobsConnectionString,
                ["Postgres:StartupProbeAttempts"] = startupProbeAttempts.ToString(),
                ["Postgres:CommandTimeoutSeconds"] = "15",
            })
            .Build();

        var services = new ServiceCollection();
        services.AddLogging(builder => builder.AddDebug());
        services.AddPersistence(configuration);
        return services.BuildServiceProvider(new ServiceProviderOptions
        {
            ValidateScopes = true,
            ValidateOnBuild = true,
        });
    }

    private static async Task InsertDiaryEntryAsync(
        DbSession session,
        Guid entryId,
        UserId userId,
        string foodName)
    {
        await using var command = new NpgsqlCommand(
            """
            insert into public.diary_entries (id, user_id, food_name)
            values (@id, @userId, @foodName)
            """,
            session.Connection,
            session.Transaction);
        command.Parameters.AddWithValue("id", entryId);
        command.Parameters.AddWithValue("userId", userId.Value);
        command.Parameters.AddWithValue("foodName", foodName);
        await command.ExecuteNonQueryAsync();
    }

    private static async Task<int> UpdateFoodNameAsync(DbSession session, Guid entryId, string foodName)
    {
        await using var command = new NpgsqlCommand(
            """
            update public.diary_entries
            set food_name = @foodName
            where id = @id
            """,
            session.Connection,
            session.Transaction);
        command.Parameters.AddWithValue("id", entryId);
        command.Parameters.AddWithValue("foodName", foodName);
        return await command.ExecuteNonQueryAsync();
    }

    private static async Task<IReadOnlyList<string>> ListFoodNamesAsync(DbSession session)
    {
        await using var command = new NpgsqlCommand(
            "select food_name from public.diary_entries order by food_name",
            session.Connection,
            session.Transaction);
        await using var reader = await command.ExecuteReaderAsync();

        var names = new List<string>();
        while (await reader.ReadAsync())
        {
            names.Add(reader.GetString(0));
        }

        return names;
    }
}
