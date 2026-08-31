using System.ComponentModel.DataAnnotations;

namespace Flexio.Infrastructure.Persistence;

/// <summary>
/// Az adatbázis-kapcsolatok beállításai. Két kapcsolat van, mert két
/// jogosultsági szint van: a kérés-útvonal RLS alatt fut, a kötegelt
/// katalógusírás nem nyúlhat felhasználói adathoz.
/// </summary>
public sealed class PostgresOptions
{
    public const string SectionName = "Postgres";

    /// <summary>
    /// A kérés-útvonal kapcsolata, a <c>flexio_api</c> role-lal. Ez a role nem
    /// kerüli meg az RLS-t; ezt az induláskori ellenőrzés kikényszeríti.
    /// </summary>
    [Required]
    public string ApiConnectionString { get; init; } = string.Empty;

    /// <summary>
    /// A kötegelt munkák kapcsolata, a <c>flexio_jobs</c> role-lal. Csak akkor
    /// kell, ha az importot vagy a seedet is ez a példány futtatja.
    /// </summary>
    public string? JobsConnectionString { get; init; }

    [Range(1, 300)]
    public int CommandTimeoutSeconds { get; init; } = 30;

    /// <summary>
    /// Az induláskori jogosultság-ellenőrzés próbálkozásai. Egy rövid
    /// adatbázis-kimaradás ne buktassa a deployt, de ellenőrzés nélkül nem
    /// indulunk el. A <c>0</c> szándékosan kikapcsolja az ellenőrzést: csak
    /// tesztekben és olyan helyi indításkor, ahol nincs Postgres.
    /// </summary>
    [Range(0, 20)]
    public int StartupProbeAttempts { get; init; } = 5;

    [Range(100, 10_000)]
    public int StartupProbeDelayMilliseconds { get; init; } = 1_000;
}
