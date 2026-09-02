using System.Text.Json;
using Dapper;
using Flexio.Infrastructure.Persistence;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Npgsql;

namespace Flexio.Infrastructure.Jobs;

public interface IFoodCatalogSeeder
{
    Task<JobRunResult> SeedAsync(CancellationToken cancellationToken);
}

internal sealed class FoodCatalogSeeder : IFoodCatalogSeeder
{
    private const string UpsertFoodSql = """
        insert into public.foods (
          source, external_id, name, category, lang, kcal, protein, fat, carbs,
          sugar, saturated_fat, salt, fiber, quality_score, verified
        ) values ('curated', @ExternalId, @Name, @Category, 'hu', @Kcal, @Protein, @Fat, @Carbs,
          @Sugar, @SaturatedFat, @Salt, @Fiber, 1.0, true)
        on conflict (source, external_id) where external_id is not null do update set
          name = excluded.name,
          category = excluded.category,
          kcal = excluded.kcal,
          protein = excluded.protein,
          fat = excluded.fat,
          carbs = excluded.carbs,
          sugar = excluded.sugar,
          saturated_fat = excluded.saturated_fat,
          salt = excluded.salt,
          fiber = excluded.fiber,
          quality_score = 1.0,
          verified = true
        returning id
        """;

    private const string InsertAliasSql = """
        insert into public.food_aliases (food_id, alias)
        values (@FoodId, @Alias)
        on conflict (food_id, normalized) do nothing
        """;

    private const string UpsertServingSql = """
        insert into public.food_servings (food_id, label, grams, sort_order)
        values (@FoodId, @Label, @Grams, @SortOrder)
        on conflict (food_id, label) do update set
          grams = excluded.grams,
          sort_order = excluded.sort_order
        """;

    private readonly NpgsqlDataSource _jobsDataSource;
    private readonly FoodCatalogOptions _options;
    private readonly ILogger<FoodCatalogSeeder> _logger;

    public FoodCatalogSeeder(
        [FromKeyedServices(PostgresDataSourceKeys.Jobs)] NpgsqlDataSource jobsDataSource,
        IOptions<FoodCatalogOptions> options,
        ILogger<FoodCatalogSeeder> logger)
    {
        _jobsDataSource = jobsDataSource;
        _options = options.Value;
        _logger = logger;
    }

    public async Task<JobRunResult> SeedAsync(CancellationToken cancellationToken)
    {
        var catalogPath = ResolveCatalogPath(_options.CatalogPath);
        if (!File.Exists(catalogPath))
        {
            throw new FileNotFoundException(
                $"A katalógus nem található: {catalogPath}. Futtasd: node server/scripts/build_catalog.mjs");
        }

        await using var stream = File.OpenRead(catalogPath);
        var document = await JsonSerializer
            .DeserializeAsync<FoodCatalogDocument>(stream, cancellationToken: cancellationToken)
            .ConfigureAwait(false);

        var foods = document?.Foods ?? [];
        if (foods.Count == 0)
        {
            throw new InvalidOperationException("A katalógus üres.");
        }

        await using var connection = await _jobsDataSource
            .OpenConnectionAsync(cancellationToken)
            .ConfigureAwait(false);

        var processed = 0;
        var errors = 0;

        _logger.LogInformation("Katalógus seed indul: {Count} tétel.", foods.Count);

        foreach (var food in foods)
        {
            cancellationToken.ThrowIfCancellationRequested();

            await using var transaction = await connection
                .BeginTransactionAsync(cancellationToken)
                .ConfigureAwait(false);

            try
            {
                var foodId = await connection.ExecuteScalarAsync<Guid>(
                    UpsertFoodSql,
                    new
                    {
                        ExternalId = food.Id,
                        food.Name,
                        food.Category,
                        food.Kcal,
                        food.Protein,
                        food.Fat,
                        food.Carbs,
                        food.Sugar,
                        SaturatedFat = food.SaturatedFat,
                        food.Salt,
                        food.Fiber,
                    },
                    transaction).ConfigureAwait(false);

                foreach (var alias in food.Aliases ?? [])
                {
                    await connection.ExecuteAsync(
                        InsertAliasSql,
                        new { FoodId = foodId, Alias = alias },
                        transaction).ConfigureAwait(false);
                }

                var order = 0;
                foreach (var serving in food.Servings ?? [])
                {
                    await connection.ExecuteAsync(
                        UpsertServingSql,
                        new
                        {
                            FoodId = foodId,
                            serving.Label,
                            serving.Grams,
                            SortOrder = order,
                        },
                        transaction).ConfigureAwait(false);
                    order += 1;
                }

                await transaction.CommitAsync(cancellationToken).ConfigureAwait(false);
                processed += 1;
            }
            catch (Exception exception) when (exception is not OperationCanceledException)
            {
                await transaction.RollbackAsync(cancellationToken).ConfigureAwait(false);
                errors += 1;
                _logger.LogError(exception, "Seed hiba a(z) {FoodId} tételnél.", food.Id);
            }
        }

        _logger.LogInformation(
            "Katalógus seed kész: {Processed} feldolgozva, {Errors} hiba.",
            processed,
            errors);

        return new JobRunResult(processed, errors);
    }

    internal static string ResolveCatalogPath(string configuredPath)
    {
        if (Path.IsPathRooted(configuredPath))
        {
            return configuredPath;
        }

        return Path.Combine(AppContext.BaseDirectory, configuredPath);
    }
}
