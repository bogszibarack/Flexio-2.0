using Flexio.Application.Coach;
using Flexio.Domain.Identity;
using Flexio.Infrastructure.Persistence;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Npgsql;

namespace Flexio.Infrastructure.Coach;

/// <summary>
/// Coach hívás napló. Élő Postgres mellett a coach_usage táblába ír; ha az
/// induláskori DB-próba ki van kapcsolva (teszt), csak naplóz - a usage soha
/// nem dönthet a felhasználói válaszról.
/// </summary>
internal sealed class CoachUsageRecorder : ICoachUsageRecorder
{
    private readonly NpgsqlDataSource _dataSource;
    private readonly PostgresOptions _options;
    private readonly ILogger<CoachUsageRecorder> _logger;

    public CoachUsageRecorder(
        [FromKeyedServices(PostgresDataSourceKeys.Api)] NpgsqlDataSource dataSource,
        IOptions<PostgresOptions> options,
        ILogger<CoachUsageRecorder> logger)
    {
        _dataSource = dataSource;
        _options = options.Value;
        _logger = logger;
    }

    public async Task RecordAsync(
        UserId userId,
        string kind,
        string? model,
        CoachUsageStatus status,
        int latencyMilliseconds,
        CancellationToken cancellationToken)
    {
        if (!userId.IsPresent)
        {
            return;
        }

        if (_options.StartupProbeAttempts <= 0)
        {
            _logger.LogInformation(
                "coach_usage user={UserId} kind={Kind} status={Status} latencyMs={Latency}",
                userId.Value,
                kind,
                status,
                latencyMilliseconds);
            return;
        }

        await using var connection = await _dataSource
            .OpenConnectionAsync(cancellationToken)
            .ConfigureAwait(false);
        await using var transaction = await connection
            .BeginTransactionAsync(cancellationToken)
            .ConfigureAwait(false);

        await using (var context = new NpgsqlCommand(
            "select set_config('app.current_user_id', @userId, true)",
            connection,
            transaction))
        {
            context.Parameters.AddWithValue("userId", userId.Value.ToString());
            await context.ExecuteNonQueryAsync(cancellationToken).ConfigureAwait(false);
        }

        await using (var insert = new NpgsqlCommand(
            """
            insert into public.coach_usage (user_id, kind, model, status, latency_ms)
            values (@userId, @kind, @model, @status, @latencyMs)
            """,
            connection,
            transaction))
        {
            insert.Parameters.AddWithValue("userId", userId.Value);
            insert.Parameters.AddWithValue("kind", kind);
            insert.Parameters.AddWithValue("model", (object?)model ?? DBNull.Value);
            insert.Parameters.AddWithValue("status", status.ToString());
            insert.Parameters.AddWithValue("latencyMs", latencyMilliseconds);
            await insert.ExecuteNonQueryAsync(cancellationToken).ConfigureAwait(false);
        }

        await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);
    }
}
