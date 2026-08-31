using Flexio.Application.Coach;
using Flexio.Application.Foods;
using Flexio.Application.Sync;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace Flexio.Application;

public static class ApplicationServiceCollectionExtensions
{
    /// <summary>
    /// Az Application réteg regisztrációi. A réteg nem tud semmit az
    /// adatbázisról vagy a HTTP-ről: a portjait (repository, szöveggenerálás)
    /// az Infrastructure elégíti ki, a összekötés a composition rootban történik.
    /// </summary>
    public static IServiceCollection AddApplicationLayer(this IServiceCollection services)
    {
        ArgumentNullException.ThrowIfNull(services);

        // Az idő is függőség: teszteléshez FakeTimeProvider cserélhető alá.
        services.TryAddSingleton(TimeProvider.System);
        services.TryAddScoped<GenerateCoachCopyHandler>();
        services.TryAddScoped<SyncHandler>();
        services.TryAddScoped<SearchFoodsHandler>();

        return services;
    }
}
