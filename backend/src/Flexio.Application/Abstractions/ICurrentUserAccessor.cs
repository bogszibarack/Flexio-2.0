using Flexio.Domain.Identity;

namespace Flexio.Application.Abstractions;

/// <summary>
/// A kérést indító felhasználó azonosítója. Az Application réteg csak ezt a
/// portot ismeri: nem tud tokenről, claimről vagy HTTP-fejlécről, így a
/// hitelesítési technológia cseréje nem érinti az üzleti logikát.
/// </summary>
public interface ICurrentUserAccessor
{
    /// <summary>
    /// A hitelesített felhasználó azonosítója.
    /// </summary>
    /// <exception cref="Flexio.Domain.Common.UnauthorizedException">
    /// Ha a kérés nem tartalmaz érvényes azonosítót. Szándékosan kivétel és nem
    /// null: a hívó így nem tud véletlenül felhasználó nélkül lekérdezni.
    /// </exception>
    UserId RequireUserId();

    bool TryGetUserId(out UserId userId);
}
