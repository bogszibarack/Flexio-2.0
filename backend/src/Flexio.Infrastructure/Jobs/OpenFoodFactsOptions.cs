namespace Flexio.Infrastructure.Jobs;

public sealed class OpenFoodFactsOptions
{
    public const string SectionName = "OpenFoodFacts";

    public string DumpUrl { get; init; } =
        "https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv.gz";

    public int BatchSize { get; init; } = 500;

    /// <summary>0 = nincs limit (teljes dump).</summary>
    public int MaxRows { get; init; }

    public string UserAgent { get; init; } = "Flexio/1.0 (kapcsolat: hello@flexio.app)";
}
