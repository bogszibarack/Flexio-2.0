using System.Globalization;
using System.IO.Compression;
using System.Net;
using System.Text;
using Dapper;
using Flexio.Infrastructure.Persistence;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Npgsql;

namespace Flexio.Infrastructure.Jobs;

public interface IOpenFoodFactsImporter
{
    Task<JobRunResult> ImportAsync(CancellationToken cancellationToken);
}

internal sealed class OpenFoodFactsImporter : IOpenFoodFactsImporter
{
    private static readonly Dictionary<string, string> NumericFields = new(StringComparer.Ordinal)
    {
        ["kcal"] = "energy-kcal_100g",
        ["protein"] = "proteins_100g",
        ["fat"] = "fat_100g",
        ["carbs"] = "carbohydrates_100g",
        ["sugar"] = "sugars_100g",
        ["saturated_fat"] = "saturated-fat_100g",
        ["salt"] = "salt_100g",
        ["fiber"] = "fiber_100g",
    };

    private readonly NpgsqlDataSource _jobsDataSource;
    private readonly OpenFoodFactsOptions _options;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<OpenFoodFactsImporter> _logger;

    public OpenFoodFactsImporter(
        [FromKeyedServices(PostgresDataSourceKeys.Jobs)] NpgsqlDataSource jobsDataSource,
        IOptions<OpenFoodFactsOptions> options,
        IHttpClientFactory httpClientFactory,
        ILogger<OpenFoodFactsImporter> logger)
    {
        _jobsDataSource = jobsDataSource;
        _options = options.Value;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task<JobRunResult> ImportAsync(CancellationToken cancellationToken)
    {
        var startedAt = DateTimeOffset.UtcNow;
        await using var connection = await _jobsDataSource
            .OpenConnectionAsync(cancellationToken)
            .ConfigureAwait(false);

        await using var responseStream = await OpenDumpStreamAsync(cancellationToken).ConfigureAwait(false);
        await using var gzip = new GZipStream(responseStream, CompressionMode.Decompress);
        using var reader = new StreamReader(gzip, Encoding.UTF8);

        string? headerLine = await reader.ReadLineAsync(cancellationToken).ConfigureAwait(false);
        if (string.IsNullOrEmpty(headerLine))
        {
            throw new InvalidOperationException("Az OFF dump fejléc sora üres.");
        }

        var header = headerLine.Split('\t');
        var rowsSeen = 0;
        var imported = 0;
        var batch = new List<OffFoodRecord>(_options.BatchSize);

        _logger.LogInformation("OFF import indul, batch méret: {BatchSize}.", _options.BatchSize);

        while (true)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var line = await reader.ReadLineAsync(cancellationToken).ConfigureAwait(false);
            if (line is null)
            {
                break;
            }

            rowsSeen += 1;
            var cells = line.Split('\t');
            if (cells.Length < header.Length / 2)
            {
                continue;
            }

            var row = new Dictionary<string, string>(StringComparer.Ordinal);
            for (var i = 0; i < header.Length; i++)
            {
                row[header[i]] = i < cells.Length ? cells[i] : string.Empty;
            }

            if (!IsHungarian(row))
            {
                continue;
            }

            var record = BuildRecord(row);
            if (record is null)
            {
                continue;
            }

            batch.Add(record);

            if (batch.Count >= _options.BatchSize)
            {
                imported += await FlushBatchAsync(connection, batch, cancellationToken).ConfigureAwait(false);
                batch.Clear();
                _logger.LogInformation(
                    "OFF import: {Imported} magyar termék mentve ({RowsSeen} sor beolvasva).",
                    imported,
                    rowsSeen);
            }

            if (_options.MaxRows > 0 && rowsSeen >= _options.MaxRows)
            {
                break;
            }
        }

        imported += await FlushBatchAsync(connection, batch, cancellationToken).ConfigureAwait(false);

        var elapsed = (int)(DateTimeOffset.UtcNow - startedAt).TotalSeconds;
        _logger.LogInformation(
            "OFF import kész: {Imported} termék, {RowsSeen} sor, {ElapsedSeconds} mp.",
            imported,
            rowsSeen,
            elapsed);

        return new JobRunResult(imported, 0, rowsSeen, elapsed);
    }

    private async Task<Stream> OpenDumpStreamAsync(CancellationToken cancellationToken)
    {
        var client = _httpClientFactory.CreateClient("OpenFoodFacts");
        var request = new HttpRequestMessage(HttpMethod.Get, _options.DumpUrl);
        request.Headers.TryAddWithoutValidation("User-Agent", _options.UserAgent);

        var response = await client
            .SendAsync(request, HttpCompletionOption.ResponseHeadersRead, cancellationToken)
            .ConfigureAwait(false);

        if (response.StatusCode is HttpStatusCode.MovedPermanently
            or HttpStatusCode.Found
            or HttpStatusCode.SeeOther
            or HttpStatusCode.TemporaryRedirect
            or HttpStatusCode.PermanentRedirect)
        {
            var location = response.Headers.Location;
            response.Dispose();
            if (location is null)
            {
                throw new InvalidOperationException("Az OFF dump átirányítása hely nélkül érkezett.");
            }

            var redirectRequest = new HttpRequestMessage(HttpMethod.Get, location);
            redirectRequest.Headers.TryAddWithoutValidation("User-Agent", _options.UserAgent);
            response = await client
                .SendAsync(redirectRequest, HttpCompletionOption.ResponseHeadersRead, cancellationToken)
                .ConfigureAwait(false);
        }

        if (!response.IsSuccessStatusCode)
        {
            throw new InvalidOperationException(
                $"Az OFF dump letöltése {(int)response.StatusCode} kóddal elutasítva.");
        }

        return await response.Content.ReadAsStreamAsync(cancellationToken).ConfigureAwait(false);
    }

    private static bool IsHungarian(IReadOnlyDictionary<string, string> row)
    {
        var countries = row.GetValueOrDefault("countries_tags", string.Empty).ToLowerInvariant();
        if (countries.Contains("hungary", StringComparison.Ordinal)
            || countries.Contains("magyarorszag", StringComparison.Ordinal))
        {
            return true;
        }

        return !string.IsNullOrWhiteSpace(row.GetValueOrDefault("product_name_hu"));
    }

    private static OffFoodRecord? BuildRecord(IReadOnlyDictionary<string, string> row)
    {
        var barcode = new string((row.GetValueOrDefault("code") ?? string.Empty)
            .Where(char.IsDigit)
            .ToArray());
        if (barcode.Length is < 8 or > 14)
        {
            return null;
        }

        var name = PickName(row);
        if (name is null)
        {
            return null;
        }

        var values = new Dictionary<string, double?>(StringComparer.Ordinal);
        foreach (var (key, column) in NumericFields)
        {
            values[key] = ToNumber(row.GetValueOrDefault(column));
        }

        if ((values["kcal"] ?? 0) <= 0
            && (values["protein"] ?? 0) <= 0
            && (values["fat"] ?? 0) <= 0
            && (values["carbs"] ?? 0) <= 0)
        {
            return null;
        }

        var servingRaw = row.GetValueOrDefault("serving_size") ?? string.Empty;
        var servingDigits = new string(servingRaw.Where(c => char.IsDigit(c) || c is ',' or '.').ToArray());
        var servingGrams = ToNumber(servingDigits);

        return new OffFoodRecord(
            barcode,
            name,
            TrimOrNull(row.GetValueOrDefault("brands"), 120),
            TrimOrNull(row.GetValueOrDefault("quantity"), 60),
            TrimOrNull(row.GetValueOrDefault("image_small_url")),
            values["kcal"] ?? 0,
            values["protein"] ?? 0,
            values["fat"] ?? 0,
            values["carbs"] ?? 0,
            values["sugar"],
            values["saturated_fat"],
            values["salt"],
            values["fiber"],
            QualityScore(values),
            servingGrams is > 0 and < 2000 ? servingGrams : null);
    }

    private static string? PickName(IReadOnlyDictionary<string, string> row)
    {
        var candidates = new[]
        {
            row.GetValueOrDefault("product_name_hu"),
            row.GetValueOrDefault("product_name"),
            string.Join(
                ' ',
                new[] { row.GetValueOrDefault("brands"), row.GetValueOrDefault("quantity") }
                    .Where(static value => !string.IsNullOrWhiteSpace(value))),
        };

        foreach (var candidate in candidates)
        {
            var value = (candidate ?? string.Empty).Trim();
            if (value.Length >= 2)
            {
                return value.Length <= 200 ? value : value[..200];
            }
        }

        return null;
    }

    private static double QualityScore(IReadOnlyDictionary<string, double?> values)
    {
        var score = 0.3;
        if ((values["kcal"] ?? 0) > 0)
        {
            score += 0.25;
        }

        if ((values["protein"] ?? 0) + (values["fat"] ?? 0) + (values["carbs"] ?? 0) > 0)
        {
            score += 0.25;
        }

        if (values["fiber"] is not null || values["salt"] is not null)
        {
            score += 0.2;
        }

        return Math.Min(score, 1.0);
    }

    private static double? ToNumber(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        var normalized = value.Replace(',', '.');
        return double.TryParse(normalized, NumberStyles.Float, CultureInfo.InvariantCulture, out var parsed)
            ? parsed
            : null;
    }

    private static string? TrimOrNull(string? value, int maxLength = int.MaxValue)
    {
        var trimmed = (value ?? string.Empty).Trim();
        if (trimmed.Length == 0)
        {
            return null;
        }

        return trimmed.Length <= maxLength ? trimmed : trimmed[..maxLength];
    }

    private static async Task<int> FlushBatchAsync(
        NpgsqlConnection connection,
        IReadOnlyList<OffFoodRecord> batch,
        CancellationToken cancellationToken)
    {
        if (batch.Count == 0)
        {
            return 0;
        }

        const string columns = """
            source, external_id, barcode, name, brand, quantity, lang,
            kcal, protein, fat, carbs, sugar, saturated_fat, salt, fiber,
            image_url, quality_score
            """;

        var values = new List<object?>();
        var tuples = new List<string>();

        for (var index = 0; index < batch.Count; index++)
        {
            var record = batch[index];
            var offset = index * 17;
            values.AddRange(
            [
                "off",
                record.Barcode,
                record.Barcode,
                record.Name,
                record.Brand,
                record.Quantity,
                "hu",
                record.Kcal,
                record.Protein,
                record.Fat,
                record.Carbs,
                record.Sugar,
                record.SaturatedFat,
                record.Salt,
                record.Fiber,
                record.ImageUrl,
                record.QualityScore,
            ]);

            tuples.Add(
                $"({string.Join(", ", Enumerable.Range(1, 17).Select(i => $"@${offset + i}"))})");
        }

        var sql = $"""
            insert into public.foods ({columns})
            values {string.Join(", ", tuples)}
            on conflict (barcode) do update set
              name = excluded.name,
              brand = coalesce(excluded.brand, public.foods.brand),
              quantity = coalesce(excluded.quantity, public.foods.quantity),
              kcal = excluded.kcal,
              protein = excluded.protein,
              fat = excluded.fat,
              carbs = excluded.carbs,
              sugar = coalesce(excluded.sugar, public.foods.sugar),
              saturated_fat = coalesce(excluded.saturated_fat, public.foods.saturated_fat),
              salt = coalesce(excluded.salt, public.foods.salt),
              fiber = coalesce(excluded.fiber, public.foods.fiber),
              image_url = coalesce(excluded.image_url, public.foods.image_url),
              quality_score = greatest(public.foods.quality_score, excluded.quality_score)
            """;

        await connection.ExecuteAsync(new CommandDefinition(sql, values, cancellationToken: cancellationToken))
            .ConfigureAwait(false);

        var withServing = batch.Where(static record => record.ServingGrams is not null).ToList();
        if (withServing.Count > 0)
        {
            var servingValues = new List<object?>();
            var servingTuples = new List<string>();

            for (var index = 0; index < withServing.Count; index++)
            {
                var record = withServing[index];
                var offset = index * 3;
                servingValues.Add(record.Barcode);
                servingValues.Add($"1 adag ({record.ServingGrams:0.#} g)");
                servingValues.Add(record.ServingGrams);
                servingTuples.Add(
                    $"(${offset + 1}, ${offset + 2}, ${offset + 3})");
            }

            var servingSql = $"""
                insert into public.food_servings (food_id, label, grams)
                select f.id, v.label, v.grams::numeric
                from (values {string.Join(", ", servingTuples)}) as v(barcode, label, grams)
                join public.foods f on f.barcode = v.barcode
                on conflict (food_id, label) do nothing
                """;

            await connection.ExecuteAsync(
                    new CommandDefinition(servingSql, servingValues, cancellationToken: cancellationToken))
                .ConfigureAwait(false);
        }

        return batch.Count;
    }

    private sealed record OffFoodRecord(
        string Barcode,
        string Name,
        string? Brand,
        string? Quantity,
        string? ImageUrl,
        double Kcal,
        double Protein,
        double Fat,
        double Carbs,
        double? Sugar,
        double? SaturatedFat,
        double? Salt,
        double? Fiber,
        double QualityScore,
        double? ServingGrams);
}
