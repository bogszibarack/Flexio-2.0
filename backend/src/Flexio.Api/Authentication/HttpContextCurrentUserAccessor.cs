using System.Security.Claims;
using Flexio.Application.Abstractions;
using Flexio.Domain.Common;
using Flexio.Domain.Identity;

namespace Flexio.Api.Authentication;

/// <summary>
/// A HTTP-token és az Application réteg közötti adapter. Ez az egyetlen hely,
/// ahol claim nevek szerepelnek; ha a kibocsátó cserélődik, csak ez a fájl
/// változik.
/// </summary>
internal sealed class HttpContextCurrentUserAccessor : ICurrentUserAccessor
{
    /// <summary>A Supabase a felhasználó uuid-ját a "sub" claimbe írja.</summary>
    private const string SubjectClaimType = "sub";

    private readonly IHttpContextAccessor _httpContextAccessor;

    public HttpContextCurrentUserAccessor(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public UserId RequireUserId()
    {
        if (!TryGetUserId(out var userId))
        {
            throw new UnauthorizedException("A kérés nem tartalmaz érvényes felhasználói azonosítót.");
        }

        return userId;
    }

    public bool TryGetUserId(out UserId userId)
    {
        var principal = _httpContextAccessor.HttpContext?.User;

        // A "sub" az elsődleges; a NameIdentifier csak akkor jön szóba, ha a
        // claim-leképezés valahol mégis bekapcsolódik.
        var subject = principal?.FindFirst(SubjectClaimType)?.Value
            ?? principal?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        return UserId.TryParse(subject, out userId);
    }
}
