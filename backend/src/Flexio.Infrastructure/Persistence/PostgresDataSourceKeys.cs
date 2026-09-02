namespace Flexio.Infrastructure.Persistence;

/// <summary>
/// A két adatforrás megnevezése a DI-ben. Nevesített kulcs és nem két típus,
/// hogy a kérés-útvonal ne tudja véletlenül a kötegelt kapcsolatot kérni.
/// </summary>
public static class PostgresDataSourceKeys
{
    /// <summary>A kérés-útvonal (flexio_api, RLS alatt).</summary>
    public const string Api = "postgres:api";

    /// <summary>A kötegelt munkák (flexio_jobs, csak katalógus).</summary>
    public const string Jobs = "postgres:jobs";
}
