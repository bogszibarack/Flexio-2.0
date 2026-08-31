namespace Flexio.Domain.Common;

/// <summary>
/// A hívó azonosított, de a művelet nem engedélyezett. Csak akkor használható,
/// ha az erőforrás létezése eleve nem titok; idegen erőforrás olvasásánál
/// <see cref="NotFoundException"/> a helyes válasz.
/// </summary>
public sealed class ForbiddenException : FlexioException
{
    public ForbiddenException(string message)
        : base(ErrorCode.Forbidden, message)
    {
    }
}
