namespace Flexio.Domain.Common;

/// <summary>
/// Nem elérhető erőforrás. Szándékosan nem tartalmaz azonosítót: a nem létező
/// és a más felhasználóhoz tartozó erőforrás válaszának azonosnak kell lennie,
/// különben az azonosító létezése kiszivárog (ID enumeration).
/// </summary>
public sealed class NotFoundException : FlexioException
{
    public NotFoundException(string resourceName)
        : base(ErrorCode.NotFound, $"A kért erőforrás nem található: {resourceName}.")
    {
        ResourceName = resourceName;
    }

    /// <summary>Az erőforrás típusa (például "naplóbejegyzés"), nem a példány azonosítója.</summary>
    public string ResourceName { get; }
}
