using Dapper;
using Flexio.Application.Abstractions;
using Flexio.Infrastructure.Configuration;
using Flexio.Infrastructure.Jobs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Options;
using Npgsql;

namespace Flexio.Infrastructure.Persistence;

internal static class PersistenceServiceCollectionExtensions
{
    internal static IServiceCollection AddPersistence(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        SqlMapper.AddTypeHandler(new DateOnlyTypeHandler());
        SqlMapper.AddTypeHandler(new DateTimeOffsetTypeHandler());
        SqlMapper.AddTypeHandler(new NullableDateTimeOffsetTypeHandler());

        services.AddValidatedOptions<PostgresOptions>(configuration, PostgresOptions.SectionName);

        services.AddSingleton(CreateApiDataSource);
        services.AddKeyedSingleton<NpgsqlDataSource>(
            PostgresDataSourceKeys.Api,
            (serviceProvider, _) => serviceProvider.GetRequiredService<NpgsqlDataSource>());

        // A Jobs kapcsolat opcionális: ha nincs connection string, a keyed
        // szolgáltatás nincs regisztrálva. Az import endpoint
        // GetKeyedService-szel kérdezi le, és egyértelmű hibát ad, ha hiányzik.
        var jobsConnectionString = configuration
            .GetSection(PostgresOptions.SectionName)
            .GetValue<string>(nameof(PostgresOptions.JobsConnectionString));

        if (!string.IsNullOrWhiteSpace(jobsConnectionString))
        {
            services.AddKeyedSingleton<NpgsqlDataSource>(
                PostgresDataSourceKeys.Jobs,
                (serviceProvider, _) =>
                {
                    var options = serviceProvider.GetRequiredService<IOptions<PostgresOptions>>().Value;
                    return BuildDataSource(
                        options.JobsConnectionString!,
                        options.CommandTimeoutSeconds);
                });

            services.AddHttpClient(
                "OpenFoodFacts",
                client => client.Timeout = TimeSpan.FromMinutes(45));

            services.TryAddScoped<IFoodCatalogSeeder, FoodCatalogSeeder>();
            services.TryAddScoped<IOpenFoodFactsImporter, OpenFoodFactsImporter>();
        }

        services.TryAddScoped<DbSession>();
        services.TryAddScoped<IUnitOfWork, NpgsqlUnitOfWork>();
        services.TryAddScoped<Flexio.Application.Sync.IDiaryRepository, Repositories.DiaryRepository>();
        services.TryAddScoped<Flexio.Application.Sync.IProfileRepository, Repositories.ProfileRepository>();
        services.TryAddScoped<Flexio.Application.Sync.IWorkoutRepository, Repositories.WorkoutRepository>();
        services.TryAddScoped<Flexio.Application.Sync.ISleepRepository, Repositories.SleepRepository>();
        services.TryAddScoped<Flexio.Application.Foods.IFoodCatalogRepository, Repositories.FoodCatalogRepository>();

        services.AddSingleton<PostgresPrivilegeGuard>();
        services.AddHostedService<PostgresPrivilegeHostedService>();
        services.AddHealthChecks()
            .AddCheck<PostgresPrivilegeGuard>("postgres", tags: ["ready"]);

        return services;
    }

    private static NpgsqlDataSource CreateApiDataSource(IServiceProvider serviceProvider)
    {
        var options = serviceProvider.GetRequiredService<IOptions<PostgresOptions>>().Value;
        return BuildDataSource(options.ApiConnectionString, options.CommandTimeoutSeconds);
    }

    private static NpgsqlDataSource BuildDataSource(string connectionString, int commandTimeoutSeconds)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(connectionString);

        var builder = new NpgsqlDataSourceBuilder(connectionString);
        builder.ConnectionStringBuilder.CommandTimeout = commandTimeoutSeconds;
        builder.ConnectionStringBuilder.ApplicationName = "flexio-api";
        // A connection poolban ne maradjon beállított app.current_user_id: minden
        // scope saját tranzakcióban állítja be, és a scope végén a kapcsolat
        // visszaáll. A ResetOnClose a pool biztonsági hálója.
        builder.ConnectionStringBuilder.NoResetOnClose = false;
        return builder.Build();
    }
}
