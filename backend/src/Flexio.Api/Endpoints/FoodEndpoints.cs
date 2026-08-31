using Flexio.Application.Foods;
using Flexio.Domain.Common;

namespace Flexio.Api.Endpoints;

internal static class FoodEndpoints
{
    internal static RouteGroupBuilder MapFoodEndpoints(this RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        var foods = group.MapGroup("/foods");

        foods.MapGet("/search", SearchAsync)
            .WithName("SearchFoods")
            .WithSummary("Rétegzett ételkeresés a Postgres RPC-n keresztül.");

        foods.MapGet("/barcode/{code}", ByBarcodeAsync)
            .WithName("FoodByBarcode")
            .WithSummary("Étel feloldása vonalkód alapján.");

        foods.MapPost("/search-miss", LogMissAsync)
            .WithName("LogSearchMiss")
            .WithSummary("Találat nélküli keresés naplózása.")
            .DisableAntiforgery();

        return group;
    }

    private static async Task<IResult> SearchAsync(
        string q,
        SearchFoodsHandler handler,
        CancellationToken cancellationToken,
        int limit = 30)
    {
        var results = await handler.SearchAsync(q, limit, cancellationToken).ConfigureAwait(false);
        return TypedResults.Ok(results);
    }

    private static async Task<IResult> ByBarcodeAsync(
        string code,
        SearchFoodsHandler handler,
        CancellationToken cancellationToken)
    {
        var food = await handler.ByBarcodeAsync(code, cancellationToken).ConfigureAwait(false);
        if (food is null)
        {
            throw new NotFoundException("étel");
        }

        return TypedResults.Ok(food);
    }

    private static async Task<IResult> LogMissAsync(
        SearchMissRequest body,
        SearchFoodsHandler handler,
        CancellationToken cancellationToken)
    {
        await handler.LogMissAsync(body.Query, body.ResultCount, cancellationToken).ConfigureAwait(false);
        return TypedResults.NoContent();
    }

    private sealed record SearchMissRequest(string Query, int ResultCount);
}
