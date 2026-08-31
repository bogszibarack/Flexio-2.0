using System.Security.Cryptography;
using System.Text;
using Flexio.Infrastructure.Jobs;
using Microsoft.Extensions.Options;

namespace Flexio.Api.Endpoints;

/// <summary>
/// Belső job végpontok. Nem JWT, hanem shared secret: a Render cron hívja.
/// A felhasználói API-tól szándékosan külön csoport.
/// </summary>
internal static class InternalJobEndpoints
{
    internal const string SecretHeaderName = "X-Flexio-Job-Secret";

    internal static WebApplication MapInternalJobEndpoints(this WebApplication app)
    {
        ArgumentNullException.ThrowIfNull(app);

        var jobs = app.MapGroup("/internal/jobs")
            .AllowAnonymous()
            .AddEndpointFilter(RequireJobSecretAsync);

        jobs.MapPost("/import-off", ImportOffAsync)
            .WithName("ImportOpenFoodFacts")
            .WithSummary("Open Food Facts dump import (cron).")
            .DisableAntiforgery();

        jobs.MapPost("/seed-foods", SeedFoodsAsync)
            .WithName("SeedFoods")
            .WithSummary("Kurátorolt magyar katalógus seed (cron).")
            .DisableAntiforgery();

        return app;
    }

    private static async ValueTask<object?> RequireJobSecretAsync(
        EndpointFilterInvocationContext context,
        EndpointFilterDelegate next)
    {
        var options = context.HttpContext.RequestServices
            .GetRequiredService<IOptions<InternalJobsOptions>>()
            .Value;

        if (!options.IsConfigured
            || !context.HttpContext.Request.Headers.TryGetValue(SecretHeaderName, out var provided)
            || !SecretEquals(provided.ToString(), options.SharedSecret))
        {
            return Results.Problem(
                title: "Tiltott művelet",
                detail: "Érvénytelen vagy hiányzó job titok.",
                statusCode: StatusCodes.Status401Unauthorized);
        }

        return await next(context).ConfigureAwait(false);
    }

    private static IResult ImportOffAsync()
    {
        // A teljes OFF stream-import a következő iterációban költözik át a
        // Node workerből. A végpont és a secret-kapu már a szerződés része.
        return Results.Accepted(
            "/internal/jobs/import-off",
            new
            {
                status = "accepted",
                detail = "Az OFF import ütemezve; a worker implementáció következik.",
            });
    }

    private static IResult SeedFoodsAsync()
    {
        return Results.Accepted(
            "/internal/jobs/seed-foods",
            new
            {
                status = "accepted",
                detail = "A katalógus seed ütemezve; a worker implementáció következik.",
            });
    }

    private static bool SecretEquals(string provided, string expected)
    {
        var left = Encoding.UTF8.GetBytes(provided);
        var right = Encoding.UTF8.GetBytes(expected);
        if (left.Length != right.Length)
        {
            CryptographicOperations.FixedTimeEquals(right, right);
            return false;
        }

        return CryptographicOperations.FixedTimeEquals(left, right);
    }
}
