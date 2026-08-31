namespace Flexio.Domain.Identity;

/// <summary>
/// A felhasználó azonosítója. Szándékosan nem <see cref="string"/> és nem nyers
/// <see cref="Guid"/>: így a repository-metódusokban nem cserélhető össze más
/// azonosítóval, és a fordító kényszeríti ki, hogy minden felhasználói
/// lekérdezés kapjon felhasználót.
/// </summary>
public readonly record struct UserId
{
    private UserId(Guid value)
    {
        Value = value;
    }

    public Guid Value { get; }

    /// <summary>
    /// A <c>default(UserId)</c> érték üres Guid-ot tartalmaz, ami sosem
    /// azonosít felhasználót. A perzisztencia-réteg ezt ellenőrzi, mielőtt
    /// beállítja az adatbázis-kontextust.
    /// </summary>
    public bool IsPresent => Value != Guid.Empty;

    public static UserId From(Guid value)
    {
        if (value == Guid.Empty)
        {
            throw new ArgumentException("A felhasználó azonosítója nem lehet üres.", nameof(value));
        }

        return new UserId(value);
    }

    public static bool TryParse(string? raw, out UserId userId)
    {
        if (Guid.TryParse(raw, out var parsed) && parsed != Guid.Empty)
        {
            userId = new UserId(parsed);
            return true;
        }

        userId = default;
        return false;
    }

    public override string ToString() => Value.ToString();
}
