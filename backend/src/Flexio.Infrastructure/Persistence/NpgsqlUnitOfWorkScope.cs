using Flexio.Application.Abstractions;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace Flexio.Infrastructure.Persistence;

/// <summary>
/// Egy nyitott tranzakció élettartama. Commit nélküli elhagyás visszaállítás:
/// egy félbehagyott kérés nem hagy maga után részleges írást.
/// </summary>
internal sealed class NpgsqlUnitOfWorkScope : IUnitOfWorkScope
{
    private readonly DbSession _session;
    private readonly NpgsqlConnection _connection;
    private readonly NpgsqlTransaction _transaction;
    private readonly ILogger _logger;

    private bool _committed;
    private bool _disposed;

    internal NpgsqlUnitOfWorkScope(
        DbSession session,
        NpgsqlConnection connection,
        NpgsqlTransaction transaction,
        ILogger logger)
    {
        _session = session;
        _connection = connection;
        _transaction = transaction;
        _logger = logger;
    }

    public async Task CommitAsync(CancellationToken cancellationToken)
    {
        ObjectDisposedException.ThrowIf(_disposed, this);

        if (_committed)
        {
            throw new InvalidOperationException("Ez a tranzakció már véglegesítve lett.");
        }

        await _transaction.CommitAsync(cancellationToken).ConfigureAwait(false);
        _committed = true;
    }

    public async ValueTask DisposeAsync()
    {
        if (_disposed)
        {
            return;
        }

        _disposed = true;

        // A leválasztás azelőtt történik, hogy a rollback elhasalhatna: a kérés
        // további részében inkább "nincs tranzakció" hibát akarunk látni, mint
        // egy már halott kapcsolaton futó, csendben hibás lekérdezést.
        _session.Detach();

        if (!_committed)
        {
            await RollbackAsync().ConfigureAwait(false);
        }

        await _transaction.DisposeAsync().ConfigureAwait(false);
        await _connection.DisposeAsync().ConfigureAwait(false);
    }

    /// <summary>
    /// A visszaállítás nem kaphat lemondási jelzést: pont az a dolga, hogy egy
    /// megszakított kérés után is lezárja a tranzakciót. Ha a kapcsolat közben
    /// elszakadt, a szerver amúgy is visszaállít, ezért itt a naplózás elég.
    /// </summary>
    private async Task RollbackAsync()
    {
        try
        {
            await _transaction.RollbackAsync(CancellationToken.None).ConfigureAwait(false);
        }
        catch (Exception exception) when (exception is NpgsqlException or InvalidOperationException)
        {
            _logger.LogWarning(
                exception,
                "A tranzakció visszaállítása nem sikerült; a szerver oldalon a kapcsolat bontása zárja le.");
        }
    }
}
