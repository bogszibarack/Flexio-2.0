namespace Flexio.Domain.Common;

/// <summary>
/// Hiányzó vagy érvénytelen hitelesítés.
/// </summary>
public sealed class UnauthorizedException : FlexioException
{
    public UnauthorizedException(string message)
        : base(ErrorCode.Unauthorized, message)
    {
    }
}
