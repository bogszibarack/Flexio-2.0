using System.Text.Json;
using System.Text.Json.Serialization;
using Flexio.Application.Sync;

namespace Flexio.Api.Endpoints;

internal static class SyncEndpoints
{
    private static readonly JsonSerializerOptions SerializerOptions = new(JsonSerializerDefaults.Web)
    {
        PropertyNameCaseInsensitive = true,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
    };

    internal static RouteGroupBuilder MapSyncEndpoints(this RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapPost("/sync", SyncAsync)
            .WithName("SyncUserData")
            .WithSummary("Piszkos sorok feltöltése és a watermark óta változott sorok lekérése.")
            .DisableAntiforgery();

        return group;
    }

    private static async Task<IResult> SyncAsync(
        SyncHttpRequest body,
        SyncHandler handler,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(body);

        var request = body.ToApplication();
        var result = await handler.HandleAsync(request, cancellationToken).ConfigureAwait(false);
        return TypedResults.Ok(SyncHttpResponse.From(result));
    }

    private sealed record SyncHttpRequest(
        [property: JsonPropertyName("diary")] List<DiaryEntryDto>? Diary,
        [property: JsonPropertyName("workouts")] List<WorkoutSessionDto>? Workouts,
        [property: JsonPropertyName("sleep")] List<SleepEntryDto>? Sleep,
        [property: JsonPropertyName("profile")] ProfileDto? Profile,
        [property: JsonPropertyName("goals")] GoalsDto? Goals,
        [property: JsonPropertyName("since")] SyncSinceHttp? Since)
    {
        internal SyncRequest ToApplication() => new(
            Diary ?? [],
            Workouts ?? [],
            Sleep ?? [],
            Profile,
            Goals,
            new SyncSince(Since?.Diary, Since?.Workouts, Since?.Sleep));
    }

    private sealed record SyncSinceHttp(
        [property: JsonPropertyName("diary")] DateTimeOffset? Diary,
        [property: JsonPropertyName("workouts")] DateTimeOffset? Workouts,
        [property: JsonPropertyName("sleep")] DateTimeOffset? Sleep);

    private sealed record SyncHttpResponse(
        [property: JsonPropertyName("push")] SyncPushHttp Push,
        [property: JsonPropertyName("diary")] IReadOnlyList<DiaryEntryDto> Diary,
        [property: JsonPropertyName("workouts")] IReadOnlyList<WorkoutSessionDto> Workouts,
        [property: JsonPropertyName("sleep")] IReadOnlyList<SleepEntryDto> Sleep,
        [property: JsonPropertyName("profile")] ProfileDto? Profile,
        [property: JsonPropertyName("goals")] GoalsDto? Goals)
    {
        internal static SyncHttpResponse From(SyncPullResult result) => new(
            new SyncPushHttp(
                result.Push.DiaryAccepted,
                result.Push.WorkoutsAccepted,
                result.Push.SleepAccepted,
                result.Push.ProfileAccepted,
                result.Push.GoalsAccepted),
            result.Diary,
            result.Workouts,
            result.Sleep,
            result.Profile,
            result.Goals);
    }

    private sealed record SyncPushHttp(
        [property: JsonPropertyName("diaryAccepted")] int DiaryAccepted,
        [property: JsonPropertyName("workoutsAccepted")] int WorkoutsAccepted,
        [property: JsonPropertyName("sleepAccepted")] int SleepAccepted,
        [property: JsonPropertyName("profileAccepted")] bool ProfileAccepted,
        [property: JsonPropertyName("goalsAccepted")] bool GoalsAccepted);
}
