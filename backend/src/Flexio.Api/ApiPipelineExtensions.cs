using Serilog;
using Serilog.Events;

namespace Flexio.Api;

internal static class ApiPipelineExtensions
{
    internal static WebApplication UseApiPipeline(this WebApplication app)
    {
        ArgumentNullException.ThrowIfNull(app);

        // A hibakezelő a lánc elején áll, hogy minden későbbi middleware
        // kivétele is ProblemDetails válaszként érjen ki.
        app.UseExceptionHandler();

        // A kivétel nélkül keletkező hibaválaszokat (nem talált útvonal,
        // hitelesítési elutasítás) is ProblemDetails törzsre cseréli.
        app.UseStatusCodePages();

        app.UseSerilogRequestLogging(options =>
        {
            options.MessageTemplate = "{RequestMethod} {RequestPath} -> {StatusCode} ({Elapsed:0.0} ms)";
            options.GetLevel = ResolveRequestLogLevel;
        });

        app.UseAuthentication();
        app.UseAuthorization();
        // A rate limit a hitelesítés után áll: a kvóta kulcsa a JWT sub claim.
        app.UseRateLimiter();

        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi().AllowAnonymous();
        }

        return app;
    }

    /// <summary>
    /// A health-próbák sűrűn futnak, Information szinten elárasztanák a naplót,
    /// ezért csak Verbose szintre kerülnek. A hibás kérések viszont mindig
    /// láthatók maradnak.
    /// </summary>
    private static LogEventLevel ResolveRequestLogLevel(
        HttpContext httpContext,
        double elapsedMilliseconds,
        Exception? exception)
    {
        if (exception is not null || httpContext.Response.StatusCode >= StatusCodes.Status500InternalServerError)
        {
            return LogEventLevel.Error;
        }

        if (httpContext.Request.Path.StartsWithSegments("/health"))
        {
            return LogEventLevel.Verbose;
        }

        return LogEventLevel.Information;
    }
}
