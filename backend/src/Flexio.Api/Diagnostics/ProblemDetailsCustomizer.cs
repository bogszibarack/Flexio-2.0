using System.Diagnostics;
using Flexio.Domain.Common;

namespace Flexio.Api.Diagnostics;

/// <summary>
/// Nem minden hibaválasz kivételből származik: az útvonal-hibák (404, 405) és a
/// hitelesítési válaszok (401, 403) a middleware-ekből jönnek, üres törzzsel.
/// Ez a kiegészítés gondoskodik róla, hogy a kliens minden hibát ugyanabban a
/// burkolatban lásson, ezért nem kell két hibafeldolgozót írnia.
/// </summary>
internal static class ProblemDetailsCustomizer
{
    internal static void Customize(ProblemDetailsContext context)
    {
        var problemDetails = context.ProblemDetails;

        // TryAdd: ha a kivételkezelő már kitöltötte, nem írjuk felül.
        problemDetails.Extensions.TryAdd(
            "traceId",
            Activity.Current?.TraceId.ToString() ?? context.HttpContext.TraceIdentifier);

        problemDetails.Extensions.TryAdd(
            "errorCode",
            ResolveErrorCode(problemDetails.Status).ToString());

        problemDetails.Instance ??= context.HttpContext.Request.Path;
    }

    private static ErrorCode ResolveErrorCode(int? statusCode) => statusCode switch
    {
        StatusCodes.Status400BadRequest => ErrorCode.ValidationFailed,
        StatusCodes.Status401Unauthorized => ErrorCode.Unauthorized,
        StatusCodes.Status403Forbidden => ErrorCode.Forbidden,
        StatusCodes.Status404NotFound => ErrorCode.NotFound,
        StatusCodes.Status409Conflict => ErrorCode.Conflict,
        StatusCodes.Status429TooManyRequests => ErrorCode.RateLimited,
        StatusCodes.Status502BadGateway => ErrorCode.ExternalServiceFailed,
        StatusCodes.Status503ServiceUnavailable => ErrorCode.ExternalServiceFailed,
        _ => ErrorCode.Unknown,
    };
}
