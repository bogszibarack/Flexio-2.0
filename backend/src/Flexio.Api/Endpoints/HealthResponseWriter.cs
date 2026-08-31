using System.Text.Json;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace Flexio.Api.Endpoints;

/// <summary>
/// A health válasz törzse. Csak a saját próbáink nevét, állapotát és leírását
/// adja ki - konfigurációs értéket, kulcsot vagy kapcsolati adatot soha.
/// </summary>
internal static class HealthResponseWriter
{
    private static readonly JsonSerializerOptions SerializerOptions = new(JsonSerializerDefaults.Web);

    internal static Task WriteAsync(HttpContext httpContext, HealthReport report)
    {
        var payload = new HealthResponse(
            report.Status.ToString(),
            Math.Round(report.TotalDuration.TotalMilliseconds, 1),
            report.Entries
                .Select(entry => new HealthCheckResponse(
                    entry.Key,
                    entry.Value.Status.ToString(),
                    entry.Value.Description))
                .ToArray());

        return httpContext.Response.WriteAsJsonAsync(
            payload,
            SerializerOptions,
            contentType: "application/json; charset=utf-8",
            httpContext.RequestAborted);
    }

    private sealed record HealthResponse(
        string Status,
        double DurationMs,
        IReadOnlyList<HealthCheckResponse> Checks);

    private sealed record HealthCheckResponse(
        string Name,
        string Status,
        string? Description);
}
