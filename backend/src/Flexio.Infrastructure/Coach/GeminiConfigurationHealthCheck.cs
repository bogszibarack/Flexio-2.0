using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;

namespace Flexio.Infrastructure.Coach;

/// <summary>
/// A readiness próba Gemini-ága. Kulcs nélkül a szolgáltatás kiszolgálja a
/// kéréseket, csak tartalék szöveggel, ezért ez <c>Degraded</c> és nem
/// <c>Unhealthy</c> - különben a platform hibásan vonná ki a példányt.
/// A kulcs értéke sosem kerül a válaszba.
/// </summary>
internal sealed class GeminiConfigurationHealthCheck : IHealthCheck
{
    private readonly IOptionsMonitor<GeminiOptions> _options;

    public GeminiConfigurationHealthCheck(IOptionsMonitor<GeminiOptions> options)
    {
        _options = options;
    }

    public Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        var current = _options.CurrentValue;

        var result = current.IsConfigured
            ? HealthCheckResult.Healthy($"Gemini elérhető, modell: {current.Model}.")
            : HealthCheckResult.Degraded("Nincs Gemini kulcs, a coach tartalék szöveggel válaszol.");

        return Task.FromResult(result);
    }
}
