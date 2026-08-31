using Testcontainers.PostgreSql;

namespace Flexio.IntegrationTests.Persistence;

/// <summary>
/// Egy közös Postgres példány az RLS tesztekhez. A konténer indítása drága,
/// ezért a collection fixture egyszer hozza létre, és minden teszt ugyanazt
/// használja - a tesztek saját felhasználói azonosítókkal dolgoznak, így nem
/// lépnek egymás lábára.
/// </summary>
public sealed class PostgresFixture : IAsyncLifetime
{
    private const string ApiPassword = "flexio_api_test";
    private const string JobsPassword = "flexio_jobs_test";

    private readonly PostgreSqlContainer _container = new PostgreSqlBuilder("postgres:16-alpine")
        .WithDatabase("flexio")
        .WithUsername("postgres")
        .WithPassword("postgres")
        .Build();

    public string ApiConnectionString { get; private set; } = string.Empty;

    public string JobsConnectionString { get; private set; } = string.Empty;

    public string SuperuserConnectionString => _container.GetConnectionString();

    public async Task InitializeAsync()
    {
        await _container.StartAsync();

        var fixtureSql = await File.ReadAllTextAsync(
            Path.Combine(AppContext.BaseDirectory, "Persistence", "Fixtures", "rls_fixture.sql"));

        await using (var connection = new Npgsql.NpgsqlConnection(SuperuserConnectionString))
        {
            await connection.OpenAsync();
            await using var command = new Npgsql.NpgsqlCommand(fixtureSql, connection);
            await command.ExecuteNonQueryAsync();
        }

        ApiConnectionString = BuildRoleConnectionString("flexio_api", ApiPassword);
        JobsConnectionString = BuildRoleConnectionString("flexio_jobs", JobsPassword);
    }

    public Task DisposeAsync() => _container.DisposeAsync().AsTask();

    private string BuildRoleConnectionString(string username, string password)
    {
        var builder = new Npgsql.NpgsqlConnectionStringBuilder(SuperuserConnectionString)
        {
            Username = username,
            Password = password,
        };
        return builder.ConnectionString;
    }
}
