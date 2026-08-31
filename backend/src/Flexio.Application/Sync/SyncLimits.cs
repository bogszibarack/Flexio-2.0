namespace Flexio.Application.Sync;

/// <summary>
/// Egy szinkron-köteg felső határa. A telefon ma korlát nélkül küld; a szerver
/// védi magát, hogy egy elszabadult kliens ne írhasson több ezer sort egy
/// tranzakcióban.
/// </summary>
public static class SyncLimits
{
    public const int MaxBatchSize = 500;
}
