using Flexio.Application.Coach;
using Flexio.Infrastructure.Configuration;
using Flexio.Infrastructure.Persistence;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Http.Resilience;
using Microsoft.Extensions.Options;

namespace Flexio.Infrastructure.Coach;

/// <summary>
/// A coach modul önmagát regisztrálja: beállítás, kliens és a saját
/// readiness-próbája egy helyen. Így egy modul hozzáadása vagy elhagyása egy
/// hívás, nem szétszórt sorok a composition rootban.
/// </summary>
internal static class CoachServiceCollectionExtensions
{
    internal static IServiceCollection AddCoachTextGeneration(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddValidatedOptions<GeminiOptions>(configuration, GeminiOptions.SectionName);

        services.AddHttpClient<ICoachTextGenerator, GeminiCoachTextGenerator>((serviceProvider, client) =>
            {
                var options = serviceProvider.GetRequiredService<IOptionsMonitor<GeminiOptions>>().CurrentValue;
                client.BaseAddress = new Uri(options.BaseUrl, UriKind.Absolute);
                client.Timeout = TimeSpan.FromSeconds(options.TimeoutSeconds);
            })
            .AddStandardResilienceHandler(resilience =>
            {
                resilience.TotalRequestTimeout.Timeout = TimeSpan.FromSeconds(20);
                resilience.AttemptTimeout.Timeout = TimeSpan.FromSeconds(12);
                resilience.Retry.MaxRetryAttempts = 2;
                resilience.CircuitBreaker.SamplingDuration = TimeSpan.FromSeconds(30);
            });

        services.AddSingleton<ICoachUsageRecorder, CoachUsageRecorder>();

        services.AddHealthChecks()
            .AddCheck<GeminiConfigurationHealthCheck>("gemini", tags: ["ready"]);

        return services;
    }
}
