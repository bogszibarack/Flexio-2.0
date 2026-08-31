using Flexio.Domain.Identity;

namespace Flexio.Application.Abstractions;

/// <summary>
/// Adatbázis-tranzakció a felhasználó kontextusában.
///
/// Minden művelet - az olvasás is - tranzakcióban fut. Nem kényelmi döntés: a
/// felhasználói kontextus tranzakció-lokális, tranzakció nélkül a beállítás a
/// statement végén eldobódik, és a következő lekérdezés kontextus nélkül,
/// csendben üres eredménnyel futna le.
/// </summary>
public interface IUnitOfWork
{
    Task<IUnitOfWorkScope> BeginWriteAsync(UserId userId, CancellationToken cancellationToken);

    /// <summary>
    /// Csak olvasó tranzakció. Az adatbázis is elutasítja benne az írást, így egy
    /// véletlen mellékhatás nem a kódellenőrzésen, hanem a szerveren bukik el.
    /// </summary>
    Task<IUnitOfWorkScope> BeginReadAsync(UserId userId, CancellationToken cancellationToken);
}

/// <summary>
/// Nyitott tranzakció. Commit nélküli elhagyása visszaállítást jelent, ezért egy
/// félbehagyott kérés nem hagy részleges írást.
/// </summary>
public interface IUnitOfWorkScope : IAsyncDisposable
{
    Task CommitAsync(CancellationToken cancellationToken);
}
