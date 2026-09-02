namespace Flexio.Infrastructure.Jobs;

public sealed class FoodCatalogOptions
{
    public const string SectionName = "FoodCatalog";

    /// <summary>A kurátorolt katalógus JSON elérési útja (relatív a futtatható fájlhoz).</summary>
    public string CatalogPath { get; init; } = "assets/food_catalog_hu.json";
}
