using Flexio.Infrastructure.Jobs;
using Flexio.Infrastructure.Persistence;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

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
            .GetRequiredService<Microsoft.Extensions.Options.IOptions<InternalJobsOptions>>()
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

    private static IResult ImportOffAsync(
        HttpContext httpContext,
        OpenFoodFactsImportCoordinator coordinator)
    {
        var jobsDataSource = httpContext.RequestServices
            .GetKeyedService<NpgsqlDataSource>(PostgresDataSourceKeys.Jobs);
        if (jobsDataSource is null)
        {
            return Results.Problem(
                title: "Szolgáltatás nem elérhető",
                detail: "A Postgres__JobsConnectionString nincs beállítva.",
                statusCode: StatusCodes.Status503ServiceUnavailable);
        }

        if (coordinator.IsRunning)
        {
            return Results.Conflict(new JobHttpResponse(
                "running",
                "Az OFF import már fut."));
        }

        if (!coordinator.TryStart())
        {
            return Results.Conflict(new JobHttpResponse(
                "running",
                "Az OFF import már fut."));
        }

        return Results.Accepted(
            "/internal/jobs/import-off",
            new JobHttpResponse(
                "accepted",
                "Az OFF import elindult a háttérben."));
    }

    private static async Task<IResult> SeedFoodsAsync(
        HttpContext httpContext,
        CancellationToken cancellationToken)
    {
        var jobsDataSource = httpContext.RequestServices
            .GetKeyedService<NpgsqlDataSource>(PostgresDataSourceKeys.Jobs);
        if (jobsDataSource is null)
        {
            return Results.Problem(
                title: "Szolgáltatás nem elérhető",
                detail: "A Postgres__JobsConnectionString nincs beállítva.",
                statusCode: StatusCodes.Status503ServiceUnavailable);
        }

        var seeder = httpContext.RequestServices.GetRequiredService<IFoodCatalogSeeder>();
        var result = await seeder.SeedAsync(cancellationToken).ConfigureAwait(false);
        return Results.Ok(new SeedJobHttpResponse(
            "completed",
            $"{result.Processed} tétel betöltve vagy frissítve.",
            result.Processed,
            result.Errors));
    }

    private static bool SecretEquals(string provided, string expected)
    {
        var left = System.Text.Encoding.UTF8.GetBytes(provided);
        var right = System.Text.Encoding.UTF8.GetBytes(expected);
        if (left.Length != right.Length)
        {
            System.Security.Cryptography.CryptographicOperations.FixedTimeEquals(right, right);
            return false;
        }

        return System.Security.Cryptography.CryptographicOperations.FixedTimeEquals(left, right);
    }

    private sealed record JobHttpResponse(string Status, string Detail);

    private sealed record SeedJobHttpResponse(
        string Status,
        string Detail,
        int Processed,
        int Errors);
}
