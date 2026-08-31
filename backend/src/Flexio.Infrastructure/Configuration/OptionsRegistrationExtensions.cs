using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Flexio.Infrastructure.Configuration;

public static class OptionsRegistrationExtensions
{
    /// <summary>
    /// Beállítás-kötés DataAnnotations validációval és <c>ValidateOnStart</c>-tal:
    /// a hibás konfiguráció induláskor derül ki, nem az első kérés közben.
    /// </summary>
    public static IServiceCollection AddValidatedOptions<TOptions>(
        this IServiceCollection services,
        IConfiguration configuration,
        string sectionName)
        where TOptions : class
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);
        ArgumentException.ThrowIfNullOrWhiteSpace(sectionName);

        services.AddOptions<TOptions>()
            .Bind(configuration.GetSection(sectionName))
            .ValidateDataAnnotations()
            .ValidateOnStart();

        return services;
    }
}
