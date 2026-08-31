using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;

namespace Flexio.Api.Endpoints;

/// <summary>
/// Felhasználó-alapú kvóta a coach végpontra. Egy példány memóriájában él; ha
/// több replica lesz, Redis/Upstash jön. A partition kulcs a JWT <c>sub</c>
/// claim, így ugyanaz a telefon IP-váltás után se kap új kvótát.
/// </summary>
internal static class CoachRateLimiting
{
    internal const string PolicyName = "coach";
    private const string SubjectClaim = "sub";

    internal const int PermitLimit = 40;
    internal static readonly TimeSpan Window = TimeSpan.FromHours(1);

    internal static IServiceCollection AddCoachRateLimiting(this IServiceCollection services)
    {
        services.AddRateLimiter(options =>
        {
            options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
            options.OnRejected = async (context, cancellationToken) =>
            {
                context.HttpContext.Response.ContentType = "application/problem+json";
                await context.HttpContext.Response.WriteAsJsonAsync(
                    new
                    {
                        type = "https://flexio.app/problems/RateLimited",
                        title = "Túl sok kérés",
                        status = StatusCodes.Status429TooManyRequests,
                        detail = "Túl sok coach kérés. Próbáld újra később.",
                        errorCode = "RateLimited",
                        traceId = context.HttpContext.TraceIdentifier,
                    },
                    cancellationToken);
            };

            options.AddPolicy(PolicyName, httpContext =>
            {
                var subject = httpContext.User.FindFirst(SubjectClaim)?.Value
                    ?? httpContext.Connection.RemoteIpAddress?.ToString()
                    ?? "anonymous";

                return RateLimitPartition.GetFixedWindowLimiter(
                    subject,
                    _ => new FixedWindowRateLimiterOptions
                    {
                        PermitLimit = PermitLimit,
                        Window = Window,
                        QueueLimit = 0,
                        AutoReplenishment = true,
                    });
            });
        });

        return services;
    }
}
