using Flexio.Application.Abstractions;

namespace Flexio.Api.Endpoints;

internal static class IdentityEndpoints
{
    internal static RouteGroupBuilder MapIdentityEndpoints(this RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        // A kliens ezzel tudja ellenőrizni, hogy a szerver ugyanazt a
        // felhasználót ismeri fel a tokenből, mint amit ő feltételez.
        group.MapGet("/me", GetCurrentUser)
            .WithName("GetCurrentUser")
            .WithSummary("A tokenből felismert felhasználó azonosítója.");

        return group;
    }

    private static IResult GetCurrentUser(ICurrentUserAccessor currentUserAccessor)
    {
        var userId = currentUserAccessor.RequireUserId();

        return Results.Ok(new CurrentUserResponse(userId.Value));
    }

    private sealed record CurrentUserResponse(Guid UserId);
}
