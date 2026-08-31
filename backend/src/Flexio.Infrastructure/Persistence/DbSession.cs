using Flexio.Domain.Identity;
using Npgsql;

namespace Flexio.Infrastructure.Persistence;

/// <summary>
/// A kérés aktuális adatbázis-kapcsolata és tranzakciója. A repositoryk ezen
/// keresztül dolgoznak, saját kapcsolatot nem nyithatnak: így nincs olyan
/// lekérdezés, ami a felhasználói kontextus beállítása nélkül fut le.
/// </summary>
internal sealed class DbSession
{
    private NpgsqlConnection? _connection;
    private NpgsqlTransaction? _transaction;

    internal UserId UserId { get; private set; }

    internal bool IsActive => _transaction is not null;

    internal NpgsqlConnection Connection =>
        _connection ?? throw MissingScope();

    internal NpgsqlTransaction Transaction =>
        _transaction ?? throw MissingScope();

    internal void Attach(NpgsqlConnection connection, NpgsqlTransaction transaction, UserId userId)
    {
        if (IsActive)
        {
            throw new InvalidOperationException(
                "Egy kérésben egyszerre csak egy adatbázis-tranzakció lehet nyitva.");
        }

        _connection = connection;
        _transaction = transaction;
        UserId = userId;
    }

    internal void Detach()
    {
        _connection = null;
        _transaction = null;
        UserId = default;
    }

    /// <summary>
    /// Szándékosan kivétel és nem néma tartalék-kapcsolat: a hiba a fejlesztés
    /// során derüljön ki, ne éles környezetben, üres találati listaként.
    /// </summary>
    private static InvalidOperationException MissingScope() => new(
        "Nincs nyitott adatbázis-tranzakció. Minden lekérdezésnek - az olvasásnak is - " +
        "IUnitOfWork scope-ban kell futnia, különben a felhasználói kontextus nincs beállítva.");
}
