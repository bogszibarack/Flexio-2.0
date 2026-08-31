using Flexio.Domain.Identity;

namespace Flexio.Application.Foods;

public sealed class FoodDto
{
    public Guid Id { get; init; }
    public string Source { get; init; } = string.Empty;
    public string? Barcode { get; init; }
    public string Name { get; init; } = string.Empty;
    public string? Brand { get; init; }
    public string? Category { get; init; }
    public decimal Kcal { get; init; }
    public decimal Protein { get; init; }
    public decimal Fat { get; init; }
    public decimal Carbs { get; init; }
    public decimal? Sugar { get; init; }
    public decimal? SaturatedFat { get; init; }
    public decimal? Salt { get; init; }
    public decimal? Fiber { get; init; }
    public string? ImageUrl { get; init; }
    public int Popularity { get; init; }
    public decimal QualityScore { get; init; }
    public Guid? OwnerId { get; init; }
    public double? Score { get; init; }
    public string? MatchKind { get; init; }
}

public interface IFoodCatalogRepository
{
    Task<IReadOnlyList<FoodDto>> SearchAsync(UserId userId, string query, int limit, CancellationToken cancellationToken);
    Task<FoodDto?> FindByBarcodeAsync(UserId userId, string barcode, CancellationToken cancellationToken);
    Task LogSearchMissAsync(UserId userId, string query, int resultCount, CancellationToken cancellationToken);
    Task IncrementPopularityAsync(UserId userId, Guid foodId, CancellationToken cancellationToken);
}
