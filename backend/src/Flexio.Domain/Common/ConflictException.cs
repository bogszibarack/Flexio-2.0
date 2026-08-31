namespace Flexio.Domain.Common;

/// <summary>
/// Ütköző állapot: a kérés önmagában érvényes, de a jelenlegi állapottal nem
/// egyeztethető össze. Nem ide tartozik a szinkron last-write-wins elutasítás:
/// az nem hiba, hanem a válasz "conflicts" listájának eleme.
/// </summary>
public sealed class ConflictException : FlexioException
{
    public ConflictException(string message)
        : base(ErrorCode.Conflict, message)
    {
    }
}
