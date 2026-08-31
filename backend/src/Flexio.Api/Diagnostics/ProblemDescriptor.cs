using System.Collections.ObjectModel;
using Flexio.Domain.Common;

namespace Flexio.Api.Diagnostics;

/// <summary>
/// Kivétel -> HTTP válasz leképezés egyetlen, tiszta függvényben. Azért külön
/// típus, hogy a szabály tesztelhető legyen HTTP-kérés indítása nélkül.
/// </summary>
internal sealed record ProblemDescriptor(
    int StatusCode,
    ErrorCode ErrorCode,
    string Title,
    string Detail,
    IReadOnlyDictionary<string, string[]> Failures)
{
    private static readonly IReadOnlyDictionary<string, string[]> NoFailures =
        new ReadOnlyDictionary<string, string[]>(new Dictionary<string, string[]>(StringComparer.Ordinal));

    /// <summary>Váratlan hiba: teljes naplózást kap, és a részletei nem mennek ki.</summary>
    public bool IsUnexpected => StatusCode >= StatusCodes.Status500InternalServerError;

    public static ProblemDescriptor For(Exception exception)
    {
        ArgumentNullException.ThrowIfNull(exception);

        return exception switch
        {
            ValidationException validation => new ProblemDescriptor(
                StatusCodes.Status400BadRequest,
                ErrorCode.ValidationFailed,
                "Érvénytelen kérés",
                validation.Message,
                validation.Failures),

            UnauthorizedException => new ProblemDescriptor(
                StatusCodes.Status401Unauthorized,
                ErrorCode.Unauthorized,
                "Hitelesítés szükséges",
                "A kérés hitelesítés nélkül nem teljesíthető.",
                NoFailures),

            ForbiddenException forbidden => new ProblemDescriptor(
                StatusCodes.Status403Forbidden,
                ErrorCode.Forbidden,
                "Tiltott művelet",
                forbidden.Message,
                NoFailures),

            // A törzs szándékosan nem tartalmaz azonosítót: a nem létező és a
            // más felhasználóhoz tartozó erőforrás válasza megkülönböztethetetlen.
            NotFoundException notFound => new ProblemDescriptor(
                StatusCodes.Status404NotFound,
                ErrorCode.NotFound,
                "Nem található",
                notFound.Message,
                NoFailures),

            ConflictException conflict => new ProblemDescriptor(
                StatusCodes.Status409Conflict,
                ErrorCode.Conflict,
                "Ütköző állapot",
                conflict.Message,
                NoFailures),

            RateLimitedException rateLimited => new ProblemDescriptor(
                StatusCodes.Status429TooManyRequests,
                ErrorCode.RateLimited,
                "Túl sok kérés",
                rateLimited.Message,
                NoFailures),

            // A külső szolgáltatás saját hibaüzenete csak a naplóba megy.
            ExternalServiceException => new ProblemDescriptor(
                StatusCodes.Status502BadGateway,
                ErrorCode.ExternalServiceFailed,
                "Külső szolgáltatás nem elérhető",
                "Egy külső szolgáltatás most nem válaszol. Próbáld újra később.",
                NoFailures),

            _ => new ProblemDescriptor(
                StatusCodes.Status500InternalServerError,
                ErrorCode.Unknown,
                "Váratlan hiba",
                "Váratlan hiba történt. A hibát naplóztuk.",
                NoFailures),
        };
    }
}
