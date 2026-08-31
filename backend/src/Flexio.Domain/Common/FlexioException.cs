namespace Flexio.Domain.Common;

/// <summary>
/// Minden szándékosan dobott, üzleti jelentéssel bíró hiba közös bázisa.
/// Ami nem ebből származik, az váratlan hiba: 500-as választ és teljes
/// naplóbejegyzést kap.
/// </summary>
public abstract class FlexioException : Exception
{
    protected FlexioException(ErrorCode errorCode, string message, Exception? innerException = null)
        : base(message, innerException)
    {
        ErrorCode = errorCode;
    }

    public ErrorCode ErrorCode { get; }
}
