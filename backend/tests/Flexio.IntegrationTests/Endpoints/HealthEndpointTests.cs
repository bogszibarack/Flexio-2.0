using System.Net;
using System.Net.Http.Json;

namespace Flexio.IntegrationTests.Endpoints;

[Collection(FlexioApiCollection.Name)]
public sealed class HealthEndpointTests
{
    private readonly FlexioApiFactory _factory;

    public HealthEndpointTests(FlexioApiFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Liveness_reports_healthy_and_runs_no_external_checks()
    {
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync("/health/live");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var payload = await response.Content.ReadFromJsonAsync<HealthPayload>();
        Assert.NotNull(payload);
        Assert.Equal("Healthy", payload.Status);
        Assert.Empty(payload.Checks);
    }

    [Fact]
    public async Task Readiness_is_degraded_without_a_gemini_key_but_still_serves_traffic()
    {
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync("/health/ready");

        // Kulcs nélkül a coach tartalék szöveggel válaszol, ezért a példányt nem
        // szabad kivonni a forgalomból: degraded, de 200-as.
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var payload = await response.Content.ReadFromJsonAsync<HealthPayload>();
        Assert.NotNull(payload);
        Assert.Equal("Degraded", payload.Status);
        Assert.Contains(payload.Checks, check => check.Name == "gemini");
    }

    [Fact]
    public async Task Readiness_never_echoes_configuration_values()
    {
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync("/health/ready");
        var body = await response.Content.ReadAsStringAsync();

        Assert.DoesNotContain("ApiKey", body, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("generativelanguage", body, StringComparison.OrdinalIgnoreCase);
    }

    private sealed record HealthPayload(string Status, double DurationMs, HealthCheckPayload[] Checks);

    private sealed record HealthCheckPayload(string Name, string Status, string? Description);
}
