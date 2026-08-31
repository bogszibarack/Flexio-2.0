using System.Text.Json;
using System.Text.Json.Serialization;
using Flexio.Application.Coach;

namespace Flexio.Api.Endpoints;

internal static class CoachEndpoints
{
    /// <summary>
    /// A kérés törzsének felső határa. A Node coach 8 KiB-ot engedett; ennél
    /// nagyobb pillanatkép már gyanús (ételista, napló), és a Geminihez se
    /// szabadna eljutnia.
    /// </summary>
    internal const int MaxRequestBytes = 8_192;

    private static readonly JsonSerializerOptions SerializerOptions = new(JsonSerializerDefaults.Web);

    internal static RouteGroupBuilder MapCoachEndpoints(this RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapPost("/coach", GenerateCoachCopyAsync)
            .WithName("GenerateCoachCopy")
            .WithSummary("Magyar coach szöveg rövid, anonim pillanatképből.")
            .RequireRateLimiting(CoachRateLimiting.PolicyName)
            .DisableAntiforgery();

        return group;
    }

    private static async Task<IResult> GenerateCoachCopyAsync(
        HttpRequest httpRequest,
        GenerateCoachCopyHandler handler,
        CancellationToken cancellationToken)
    {
        if (httpRequest.ContentLength is > MaxRequestBytes)
        {
            return TypedResults.Problem(
                title: "Érvénytelen kérés",
                detail: "A coach kérés törzse túl nagy.",
                statusCode: StatusCodes.Status400BadRequest);
        }

        CoachHttpRequest? body;
        try
        {
            body = await JsonSerializer
                .DeserializeAsync<CoachHttpRequest>(httpRequest.Body, SerializerOptions, cancellationToken)
                .ConfigureAwait(false);
        }
        catch (JsonException)
        {
            return TypedResults.Problem(
                title: "Érvénytelen kérés",
                detail: "A coach kérés törzse nem érvényes JSON.",
                statusCode: StatusCodes.Status400BadRequest);
        }

        if (body is null)
        {
            return TypedResults.Problem(
                title: "Érvénytelen kérés",
                detail: "A coach kérés törzse üres.",
                statusCode: StatusCodes.Status400BadRequest);
        }

        var command = ToCommand(body);
        var copy = await handler.HandleAsync(command, cancellationToken).ConfigureAwait(false);
        return TypedResults.Ok(new CoachHttpResponse(copy.Prose, copy.Pros, copy.Cons));
    }

    private static GenerateCoachCopyCommand ToCommand(CoachHttpRequest body)
    {
        var snapshot = body.Snapshot;
        var kind = string.Empty;
        if (snapshot.ValueKind == JsonValueKind.Object
            && snapshot.TryGetProperty("kind", out var kindElement)
            && kindElement.ValueKind == JsonValueKind.String)
        {
            kind = kindElement.GetString() ?? string.Empty;
        }

        var fallback = body.Fallback ?? new CoachFallbackDto(null, null, null);
        return new GenerateCoachCopyCommand(
            new CoachSnapshot(
                kind,
                snapshot.ValueKind == JsonValueKind.Undefined ? default : snapshot),
            new CoachCopy(
                fallback.Prose?.Trim() ?? string.Empty,
                fallback.Pros?.Trim() ?? string.Empty,
                fallback.Cons?.Trim() ?? string.Empty));
    }

    private sealed record CoachHttpRequest(
        [property: JsonPropertyName("snapshot")] JsonElement Snapshot,
        [property: JsonPropertyName("fallback")] CoachFallbackDto? Fallback);

    private sealed record CoachFallbackDto(
        [property: JsonPropertyName("prose")] string? Prose,
        [property: JsonPropertyName("pros")] string? Pros,
        [property: JsonPropertyName("cons")] string? Cons);

    private sealed record CoachHttpResponse(
        [property: JsonPropertyName("prose")] string Prose,
        [property: JsonPropertyName("pros")] string Pros,
        [property: JsonPropertyName("cons")] string Cons);
}
