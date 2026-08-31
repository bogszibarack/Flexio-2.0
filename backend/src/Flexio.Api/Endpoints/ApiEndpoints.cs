namespace Flexio.Api.Endpoints;

internal static class ApiEndpoints
{
    /// <summary>
    /// A verziózott felület egyetlen gyökere. Minden modul ehhez a csoporthoz
    /// csatlakozik, így a hitelesítési és korlátozási szabályok egy helyen
    /// dőlnek el, nem endpointonként.
    /// </summary>
    internal static WebApplication MapApiEndpoints(this WebApplication app)
    {
        ArgumentNullException.ThrowIfNull(app);

        var api = app.MapGroup("/api/v1").RequireAuthorization();

        api.MapIdentityEndpoints();
        api.MapCoachEndpoints();
        api.MapSyncEndpoints();
        api.MapFoodEndpoints();

        return app;
    }
}
