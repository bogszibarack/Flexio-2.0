using Flexio.Infrastructure.Coach;
using Flexio.Infrastructure.Jobs;
using Flexio.Infrastructure.Persistence;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Flexio.Infrastructure;

public static class InfrastructureServiceCollectionExtensions
{
    /// <summary>
    /// Az Infrastructure réteg modulonként regisztrálja magát. Ez az egyetlen
    /// hely, ahol az Application interfészeihez konkrét implementáció kötődik,
    /// ezért egy technológiacsere (más adatbázis-kliens, más modell) itt ér véget.
    /// </summary>
    public static IServiceCollection AddInfrastructureLayer(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        ArgumentNullException.ThrowIfNull(services);
        ArgumentNullException.ThrowIfNull(configuration);

        services.AddPersistence(configuration);
        services.AddCoachTextGeneration(configuration);
        services.AddInternalJobs(configuration);

        return services;
    }
}
