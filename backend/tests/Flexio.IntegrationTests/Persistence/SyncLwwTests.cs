using Flexio.Application.Abstractions;
using Flexio.Application.Sync;
using Flexio.Domain.Identity;
using Flexio.Infrastructure.Persistence;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Flexio.IntegrationTests.Persistence;

[Collection(PostgresCollection.Name)]
public sealed class SyncLwwTests
{
    private readonly PostgresFixture _fixture;

    public SyncLwwTests(PostgresFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task Newer_client_write_wins_over_older_server_row()
    {
        var userId = UserId.From(Guid.NewGuid());
        var entryId = Guid.NewGuid();
        var older = DateTimeOffset.Parse("2026-08-01T10:00:00Z");
        var newer = DateTimeOffset.Parse("2026-08-01T12:00:00Z");

        await using var root = BuildServices();
        await using var scope = root.CreateAsyncScope();
        var unitOfWork = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
        var diary = scope.ServiceProvider.GetRequiredService<IDiaryRepository>();

        await using (var write = await unitOfWork.BeginWriteAsync(userId, CancellationToken.None))
        {
            await diary.UpsertBatchAsync(
                userId,
                [CreateEntry(entryId, userId, "Régi", older)],
                CancellationToken.None);
            await write.CommitAsync(CancellationToken.None);
        }

        await using (var write = await unitOfWork.BeginWriteAsync(userId, CancellationToken.None))
        {
            var accepted = await diary.UpsertBatchAsync(
                userId,
                [CreateEntry(entryId, userId, "Újabb", newer)],
                CancellationToken.None);
            Assert.Equal(1, accepted);
            await write.CommitAsync(CancellationToken.None);
        }

        await using (var read = await unitOfWork.BeginReadAsync(userId, CancellationToken.None))
        {
            var rows = await diary.ListChangedSinceAsync(userId, null, CancellationToken.None);
            Assert.Single(rows);
            Assert.Equal("Újabb", rows[0].FoodName);
            Assert.Equal(newer, rows[0].UpdatedAt);
            await read.CommitAsync(CancellationToken.None);
        }
    }

    [Fact]
    public async Task Older_client_write_is_ignored_by_lww()
    {
        var userId = UserId.From(Guid.NewGuid());
        var entryId = Guid.NewGuid();
        var newer = DateTimeOffset.Parse("2026-08-01T12:00:00Z");
        var older = DateTimeOffset.Parse("2026-08-01T10:00:00Z");

        await using var root = BuildServices();
        await using var scope = root.CreateAsyncScope();
        var unitOfWork = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
        var diary = scope.ServiceProvider.GetRequiredService<IDiaryRepository>();

        await using (var write = await unitOfWork.BeginWriteAsync(userId, CancellationToken.None))
        {
            await diary.UpsertBatchAsync(
                userId,
                [CreateEntry(entryId, userId, "Győztes", newer)],
                CancellationToken.None);
            await write.CommitAsync(CancellationToken.None);
        }

        await using (var write = await unitOfWork.BeginWriteAsync(userId, CancellationToken.None))
        {
            var accepted = await diary.UpsertBatchAsync(
                userId,
                [CreateEntry(entryId, userId, "Későn jött", older)],
                CancellationToken.None);
            Assert.Equal(0, accepted);
            await write.CommitAsync(CancellationToken.None);
        }

        await using (var read = await unitOfWork.BeginReadAsync(userId, CancellationToken.None))
        {
            var rows = await diary.ListChangedSinceAsync(userId, null, CancellationToken.None);
            Assert.Equal("Győztes", Assert.Single(rows).FoodName);
            await read.CommitAsync(CancellationToken.None);
        }
    }

    private ServiceProvider BuildServices()
    {
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Postgres:ApiConnectionString"] = _fixture.ApiConnectionString,
                ["Postgres:JobsConnectionString"] = _fixture.JobsConnectionString,
                ["Postgres:StartupProbeAttempts"] = "0",
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

    private static DiaryEntryDto CreateEntry(
        Guid id,
        UserId userId,
        string foodName,
        DateTimeOffset updatedAt) =>
        new()
        {
            Id = id,
            UserId = userId.Value,
            LoggedAt = updatedAt,
            LocalDate = DateOnly.FromDateTime(updatedAt.UtcDateTime),
            MealType = "Ebéd",
            FoodName = foodName,
            AmountG = 100,
            Kcal = 200,
            Protein = 10,
            Fat = 5,
            Carbs = 20,
            UpdatedAt = updatedAt,
        };
}
