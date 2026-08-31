using Microsoft.AspNetCore.Diagnostics.HealthChecks;

namespace Flexio.Api.Endpoints;

internal static class HealthEndpoints
{
    /// <summary>A readiness próbákat ezzel a címkével jelöli minden modul.</summary>
    internal const string ReadinessTag = "ready";

    internal static WebApplication MapHealthEndpoints(this WebApplication app)
    {
        ArgumentNullException.ThrowIfNull(app);

        // Liveness: csak a folyamat életét jelzi. A platform ez alapján indít
        // újra, ezért szándékosan nem futtat egyetlen külső próbát sem - egy
        // adatbázis-kimaradás nem indokol konténer-újraindítást.
        app.MapHealthChecks("/health/live", new HealthCheckOptions
        {
            Predicate = _ => false,
            ResponseWriter = HealthResponseWriter.WriteAsync,
        })
            .WithMetadata(new HttpMethodMetadata([HttpMethods.Get]))
            .AllowAnonymous();

        // Readiness: a külső függőségek is beleszámítanak, a forgalomból való
        // ki- és bevezetés ezen dől el.
        app.MapHealthChecks("/health/ready", new HealthCheckOptions
        {
            Predicate = registration => registration.Tags.Contains(ReadinessTag),
            ResponseWriter = HealthResponseWriter.WriteAsync,
        })
            .WithMetadata(new HttpMethodMetadata([HttpMethods.Get]))
            .AllowAnonymous();

        return app;
    }
}
