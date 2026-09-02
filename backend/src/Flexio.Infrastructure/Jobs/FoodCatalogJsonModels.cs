using System.Text.Json.Serialization;

namespace Flexio.Infrastructure.Jobs;

internal sealed class FoodCatalogDocument
{
    [JsonPropertyName("foods")]
    public List<CatalogFoodJson> Foods { get; init; } = [];
}

internal sealed class CatalogFoodJson
{
    [JsonPropertyName("id")]
    public string Id { get; init; } = string.Empty;

    [JsonPropertyName("name")]
    public string Name { get; init; } = string.Empty;

    [JsonPropertyName("category")]
    public string? Category { get; init; }

    [JsonPropertyName("aliases")]
    public List<string>? Aliases { get; init; }

    [JsonPropertyName("kcal")]
    public double Kcal { get; init; }

    [JsonPropertyName("protein")]
    public double Protein { get; init; }

    [JsonPropertyName("fat")]
    public double Fat { get; init; }

    [JsonPropertyName("carbs")]
    public double Carbs { get; init; }

    [JsonPropertyName("sugar")]
    public double? Sugar { get; init; }

    [JsonPropertyName("saturatedFat")]
    public double? SaturatedFat { get; init; }

    [JsonPropertyName("salt")]
    public double? Salt { get; init; }

    [JsonPropertyName("fiber")]
    public double? Fiber { get; init; }

    [JsonPropertyName("servings")]
    public List<CatalogServingJson>? Servings { get; init; }
}

internal sealed class CatalogServingJson
{
    [JsonPropertyName("label")]
    public string Label { get; init; } = string.Empty;

    [JsonPropertyName("grams")]
    public double Grams { get; init; }
}
