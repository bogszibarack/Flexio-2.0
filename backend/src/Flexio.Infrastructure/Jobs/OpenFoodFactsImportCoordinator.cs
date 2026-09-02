using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Flexio.Infrastructure.Jobs;

/// <summary>
/// A hosszú OFF import háttérben fut, hogy a cron HTTP hívás ne timeoutoljon.
/// </summary>
public sealed class OpenFoodFactsImportCoordinator
{
    private int _running;
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<OpenFoodFactsImportCoordinator> _logger;

    public OpenFoodFactsImportCoordinator(
        IServiceScopeFactory scopeFactory,
        ILogger<OpenFoodFactsImportCoordinator> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    public bool IsRunning => Volatile.Read(ref _running) == 1;

    public bool TryStart()
    {
        if (Interlocked.CompareExchange(ref _running, 1, 0) != 0)
        {
            return false;
        }

        _ = Task.Run(RunImportAsync);
        return true;
    }

    private async Task RunImportAsync()
    {
        try
        {
            await using var scope = _scopeFactory.CreateAsyncScope();
            var importer = scope.ServiceProvider.GetRequiredService<IOpenFoodFactsImporter>();
            await importer.ImportAsync(CancellationToken.None).ConfigureAwait(false);
        }
        catch (Exception exception)
        {
            _logger.LogError(exception, "OFF import hiba a háttérben.");
        }
        finally
        {
            Interlocked.Exchange(ref _running, 0);
        }
    }
}
