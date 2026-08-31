using Flexio.Api.Authentication;
using Flexio.Api.Diagnostics;
using Flexio.Api.Endpoints;
using System.Text.Json;

namespace Flexio.Api;

internal static class ApiServiceCollectionExtensions
{
    /// <summary>
    /// A HTTP határ regisztrációi: hitelesítés, hibakimenet, séma. Üzleti
    /// logika itt nem lehet.
    /// </summary>
    internal static IServiceCollection AddApiLayer(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        services.AddProblemDetails(options => options.CustomizeProblemDetails = ProblemDetailsCustomizer.Customize);
        services.AddExceptionHandler<GlobalExceptionHandler>();
        services.AddOpenApi();
        services.AddFlexioAuthentication(configuration);
        services.AddCoachRateLimiting();

        // A Flutter / Supabase szerződés snake_case. A PropertyNameCaseInsensitive
        // a camelCase teszteket is elfogadja.
        services.ConfigureHttpJsonOptions(options =>
        {
            options.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower;
            options.SerializerOptions.PropertyNameCaseInsensitive = true;
            options.SerializerOptions.DictionaryKeyPolicy = JsonNamingPolicy.SnakeCaseLower;
        });

        return services;
    }
}
