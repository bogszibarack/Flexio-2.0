using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Flexio.Infrastructure.Jobs;

public sealed class InternalJobsOptions
{
    public const string SectionName = "InternalJobs";

    /// <summary>
    /// A Render cron és az admin hívások közös titka. Header:
    /// <c>X-Flexio-Job-Secret</c>. Üresen a belső végpontok 401-et adnak.
    /// </summary>
    public string SharedSecret { get; init; } = string.Empty;

    public bool IsConfigured => SharedSecret.Length >= 16;
}

internal static class JobsServiceCollectionExtensions
{
    internal static IServiceCollection AddInternalJobs(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddOptions<InternalJobsOptions>()
            .Bind(configuration.GetSection(InternalJobsOptions.SectionName))
            .Validate(
                options => string.IsNullOrEmpty(options.SharedSecret) || options.SharedSecret.Length >= 16,
                "Az InternalJobs:SharedSecret legalább 16 karakter, vagy üres (ekkor a job végpontok zárva maradnak).")
            .ValidateOnStart();

        return services;
    }
}
