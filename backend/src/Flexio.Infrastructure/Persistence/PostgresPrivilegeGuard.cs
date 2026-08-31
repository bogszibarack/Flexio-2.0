using System.Data;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Npgsql;

namespace Flexio.Infrastructure.Persistence;

/// <summary>
/// Induláskori és readiness ellenőrzés: él-e a kapcsolat, és a
/// <c>flexio_api</c> szerepkör nem kerülheti meg az RLS-t. Ha a role
/// <c>rolbypassrls</c> lenne, a policy-k csendben semmit sem védenének - ez a
/// legrosszabb, ami történhet, ezért az API ilyenkor nem indul el.
/// </summary>
internal sealed class PostgresPrivilegeGuard : IHealthCheck
{
    private readonly NpgsqlDataSource _dataSource;
    private readonly PostgresOptions _options;
    private readonly ILogger<PostgresPrivilegeGuard> _logger;

    public PostgresPrivilegeGuard(
        [FromKeyedServices(PostgresDataSourceKeys.Api)] NpgsqlDataSource dataSource,
        IOptions<PostgresOptions> options,
        ILogger<PostgresPrivilegeGuard> logger)
    {
        _dataSource = dataSource;
        _options = options.Value;
        _logger = logger;
    }

    public async Task EnsureSafeAsync(CancellationToken cancellationToken)
    {
        if (IsProbeDisabled)
        {
            _logger.LogWarning(
                "Az adatbázis induláskori jogosultság-ellenőrzése ki van kapcsolva (StartupProbeAttempts=0).");
            return;
        }

        Exception? lastFailure = null;

        for (var attempt = 1; attempt <= _options.StartupProbeAttempts; attempt++)
        {
            cancellationToken.ThrowIfCancellationRequested();

            try
            {
                await VerifyPrivilegesAsync(cancellationToken).ConfigureAwait(false);
                return;
            }
            catch (Exception exception) when (exception is NpgsqlException or TimeoutException)
            {
                lastFailure = exception;
                _logger.LogWarning(
                    exception,
                    "Adatbázis-ellenőrzés sikertelen ({Attempt}/{MaxAttempts}).",
                    attempt,
                    _options.StartupProbeAttempts);

                if (attempt < _options.StartupProbeAttempts)
                {
                    await Task
                        .Delay(_options.StartupProbeDelayMilliseconds, cancellationToken)
                        .ConfigureAwait(false);
                }
            }
        }

        throw new InvalidOperationException(
            "A Flexio API nem indult el: az adatbázis-jogosultság ellenőrzése " +
            $"{_options.StartupProbeAttempts} próbálkozás után sem sikerült.",
            lastFailure);
    }

    public async Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        if (IsProbeDisabled)
        {
            return HealthCheckResult.Healthy(
                "Postgres ellenőrzés ki van kapcsolva (teszt / helyi indítás).");
        }

        try
        {
            await VerifyPrivilegesAsync(cancellationToken).ConfigureAwait(false);
            return HealthCheckResult.Healthy("Postgres elérhető, az API role nem kerülheti meg az RLS-t.");
        }
        catch (Exception exception) when (exception is NpgsqlException or InvalidOperationException or TimeoutException)
        {
            return HealthCheckResult.Unhealthy(
                "Postgres nem elérhető, vagy az API role jogosultsága nem biztonságos.",
                exception);
        }
    }

    private bool IsProbeDisabled => _options.StartupProbeAttempts <= 0;

    private async Task VerifyPrivilegesAsync(CancellationToken cancellationToken)
    {
        await using var connection = await _dataSource
            .OpenConnectionAsync(cancellationToken)
            .ConfigureAwait(false);

        await using var command = new NpgsqlCommand(
            """
            select
              current_user as role_name,
              coalesce((select rolbypassrls from pg_roles where rolname = current_user), false) as bypasses_rls,
              to_regprocedure('public.flexio_current_user_id()') is not null as has_user_seam
            """,
            connection);

        await using var reader = await command
            .ExecuteReaderAsync(CommandBehavior.SingleRow, cancellationToken)
            .ConfigureAwait(false);

        if (!await reader.ReadAsync(cancellationToken).ConfigureAwait(false))
        {
            throw new InvalidOperationException("Az adatbázis-jogosultság lekérdezése üres választ adott.");
        }

        var roleName = reader.GetString(0);
        var bypassesRls = reader.GetBoolean(1);
        var hasUserSeam = reader.GetBoolean(2);

        if (bypassesRls)
        {
            throw new InvalidOperationException(
                $"A '{roleName}' role rendelkezik a rolbypassrls jogosultsággal. " +
                "Az API role soha nem kerülheti meg az RLS-t; a deploy megállt.");
        }

        if (!hasUserSeam)
        {
            throw new InvalidOperationException(
                "Hiányzik a public.flexio_current_user_id() függvény. " +
                "Futtasd a 20260830190000_api_role migrációt az adatbázison.");
        }

        _logger.LogInformation(
            "Adatbázis-jogosultság rendben: role={Role}, rolbypassrls=false, flexio_current_user_id=ok.",
            roleName);
    }
}
