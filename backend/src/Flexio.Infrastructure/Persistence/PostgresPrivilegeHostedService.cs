using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Flexio.Infrastructure.Persistence;

/// <summary>
/// Az API csak akkor fogad forgalmat, ha az adatbázis-jogosultság ellenőrzése
/// sikeres. A readiness probe ugyanezt a guardot hívja; a HostedService
/// fail-fast: rossz role mellett a StartAsync kivételt dob, és a host nem indul.
/// </summary>
internal sealed class PostgresPrivilegeHostedService : IHostedService
{
    private readonly PostgresPrivilegeGuard _guard;
    private readonly ILogger<PostgresPrivilegeHostedService> _logger;

    public PostgresPrivilegeHostedService(
        PostgresPrivilegeGuard guard,
        ILogger<PostgresPrivilegeHostedService> logger)
    {
        _guard = guard;
        _logger = logger;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        try
        {
            await _guard.EnsureSafeAsync(cancellationToken).ConfigureAwait(false);
        }
        catch (Exception exception)
        {
            _logger.LogCritical(exception, "Az adatbázis-jogosultság ellenőrzése megállította az indulást.");
            throw;
        }
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
