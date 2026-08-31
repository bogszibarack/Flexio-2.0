using Dapper;
using Flexio.Application.Foods;
using Flexio.Domain.Identity;

namespace Flexio.Infrastructure.Persistence.Repositories;

/// <summary>
/// A meglévő Postgres RPC-ket hívja. A keresési rangsor és a normalizálás a
/// adatbázisban él; a C# csak a felhasználói kontextust és a HTTP határt adja.
/// </summary>
internal sealed class FoodCatalogRepository : IFoodCatalogRepository
{
    private readonly DbSession _session;

    public FoodCatalogRepository(DbSession session)
    {
        _session = session;
    }

    public async Task<IReadOnlyList<FoodDto>> SearchAsync(
        UserId userId,
        string query,
        int limit,
        CancellationToken cancellationToken)
    {
        var rows = await _session.RequireConnection().QueryAsync<FoodDto>(
            _session.Command(
                """
                select
                  id as Id,
                  source as Source,
                  barcode as Barcode,
                  name as Name,
                  brand as Brand,
                  category as Category,
                  kcal as Kcal,
                  protein as Protein,
                  fat as Fat,
                  carbs as Carbs,
                  sugar as Sugar,
                  saturated_fat as SaturatedFat,
                  salt as Salt,
                  fiber as Fiber,
                  image_url as ImageUrl,
                  popularity as Popularity,
                  quality_score as QualityScore,
                  owner_id as OwnerId,
                  score as Score,
                  match_kind as MatchKind
                from public.search_foods(@Query, @Limit)
                """,
                new { Query = query, Limit = limit },
                cancellationToken));

        return rows.AsList();
    }

    public async Task<FoodDto?> FindByBarcodeAsync(
        UserId userId,
        string barcode,
        CancellationToken cancellationToken)
    {
        return await _session.RequireConnection().QuerySingleOrDefaultAsync<FoodDto>(
            _session.Command(
                """
                select
                  id as Id,
                  source as Source,
                  barcode as Barcode,
                  name as Name,
                  brand as Brand,
                  category as Category,
                  kcal as Kcal,
                  protein as Protein,
                  fat as Fat,
                  carbs as Carbs,
                  sugar as Sugar,
                  saturated_fat as SaturatedFat,
                  salt as Salt,
                  fiber as Fiber,
                  image_url as ImageUrl,
                  popularity as Popularity,
                  quality_score as QualityScore,
                  owner_id as OwnerId
                from public.food_by_barcode(@Barcode)
                """,
                new { Barcode = barcode },
                cancellationToken));
    }

    public Task LogSearchMissAsync(
        UserId userId,
        string query,
        int resultCount,
        CancellationToken cancellationToken) =>
        _session.RequireConnection().ExecuteAsync(
            _session.Command(
                "select public.log_search_miss(@Query, @ResultCount)",
                new { Query = query, ResultCount = resultCount },
                cancellationToken));

    public Task IncrementPopularityAsync(
        UserId userId,
        Guid foodId,
        CancellationToken cancellationToken) =>
        _session.RequireConnection().ExecuteAsync(
            _session.Command(
                "select public.increment_food_popularity(@FoodId)",
                new { FoodId = foodId },
                cancellationToken));
}
