using Flexio.Application.Abstractions;
using Flexio.Domain.Common;
using Microsoft.Extensions.Logging;

namespace Flexio.Application.Sync;

/// <summary>
/// Egy szinkron kör: előbb a kliens piszkos sorai (LWW upsert), aztán a
/// watermark óta változott sorok. Egy tranzakcióban fut, hogy a pull ne
/// lásson félig beírt push-t.
/// </summary>
public sealed class SyncHandler
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICurrentUserAccessor _currentUser;
    private readonly IDiaryRepository _diary;
    private readonly IProfileRepository _profiles;
    private readonly IWorkoutRepository _workouts;
    private readonly ISleepRepository _sleep;
    private readonly ILogger<SyncHandler> _logger;

    public SyncHandler(
        IUnitOfWork unitOfWork,
        ICurrentUserAccessor currentUser,
        IDiaryRepository diary,
        IProfileRepository profiles,
        IWorkoutRepository workouts,
        ISleepRepository sleep,
        ILogger<SyncHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _currentUser = currentUser;
        _diary = diary;
        _profiles = profiles;
        _workouts = workouts;
        _sleep = sleep;
        _logger = logger;
    }

    public async Task<SyncPullResult> HandleAsync(SyncRequest request, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        ValidateBatchSizes(request);

        var userId = _currentUser.RequireUserId();
        await using var scope = await _unitOfWork
            .BeginWriteAsync(userId, cancellationToken)
            .ConfigureAwait(false);

        var push = new SyncPushResult(
            DiaryAccepted: request.Diary.Count == 0
                ? 0
                : await _diary.UpsertBatchAsync(userId, request.Diary, cancellationToken).ConfigureAwait(false),
            WorkoutsAccepted: request.Workouts.Count == 0
                ? 0
                : await _workouts.UpsertBatchAsync(userId, request.Workouts, cancellationToken).ConfigureAwait(false),
            SleepAccepted: request.Sleep.Count == 0
                ? 0
                : await _sleep.UpsertBatchAsync(userId, request.Sleep, cancellationToken).ConfigureAwait(false),
            ProfileAccepted: false,
            GoalsAccepted: false);

        var profileAccepted = false;
        var goalsAccepted = false;

        if (request.Profile is not null)
        {
            await _profiles.UpsertAsync(userId, request.Profile, cancellationToken).ConfigureAwait(false);
            profileAccepted = true;
        }

        if (request.Goals is not null)
        {
            await _profiles.UpsertGoalsAsync(userId, request.Goals, cancellationToken).ConfigureAwait(false);
            goalsAccepted = true;
        }

        push = push with { ProfileAccepted = profileAccepted, GoalsAccepted = goalsAccepted };

        var diary = await _diary
            .ListChangedSinceAsync(userId, request.Since.Diary, cancellationToken)
            .ConfigureAwait(false);
        var workouts = await _workouts
            .ListChangedSinceAsync(userId, request.Since.Workouts, cancellationToken)
            .ConfigureAwait(false);
        var sleep = await _sleep
            .ListChangedSinceAsync(userId, request.Since.Sleep, cancellationToken)
            .ConfigureAwait(false);
        var profile = await _profiles.GetProfileAsync(userId, cancellationToken).ConfigureAwait(false);
        var goals = await _profiles.GetGoalsAsync(userId, cancellationToken).ConfigureAwait(false);

        await scope.CommitAsync(cancellationToken).ConfigureAwait(false);

        _logger.LogInformation(
            "Sync kész: diary+{Diary} workout+{Workout} sleep+{Sleep} profile={Profile} goals={Goals}",
            push.DiaryAccepted,
            push.WorkoutsAccepted,
            push.SleepAccepted,
            push.ProfileAccepted,
            push.GoalsAccepted);

        return new SyncPullResult(push, diary, workouts, sleep, profile, goals);
    }

    private static void ValidateBatchSizes(SyncRequest request)
    {
        var failures = new Dictionary<string, string[]>(StringComparer.Ordinal);

        if (request.Diary.Count > SyncLimits.MaxBatchSize)
        {
            failures["diary"] = [$"Legfeljebb {SyncLimits.MaxBatchSize} naplóbejegyzés küldhető egy körben."];
        }

        if (request.Workouts.Count > SyncLimits.MaxBatchSize)
        {
            failures["workouts"] = [$"Legfeljebb {SyncLimits.MaxBatchSize} edzés küldhető egy körben."];
        }

        if (request.Sleep.Count > SyncLimits.MaxBatchSize)
        {
            failures["sleep"] = [$"Legfeljebb {SyncLimits.MaxBatchSize} alvásbejegyzés küldhető egy körben."];
        }

        if (failures.Count > 0)
        {
            throw new ValidationException("A szinkron köteg túl nagy.", failures);
        }
    }
}

public sealed record SyncSince(
    DateTimeOffset? Diary,
    DateTimeOffset? Workouts,
    DateTimeOffset? Sleep);

public sealed record SyncRequest(
    IReadOnlyList<DiaryEntryDto> Diary,
    IReadOnlyList<WorkoutSessionDto> Workouts,
    IReadOnlyList<SleepEntryDto> Sleep,
    ProfileDto? Profile,
    GoalsDto? Goals,
    SyncSince Since);

public sealed record SyncPushResult(
    int DiaryAccepted,
    int WorkoutsAccepted,
    int SleepAccepted,
    bool ProfileAccepted,
    bool GoalsAccepted);

public sealed record SyncPullResult(
    SyncPushResult Push,
    IReadOnlyList<DiaryEntryDto> Diary,
    IReadOnlyList<WorkoutSessionDto> Workouts,
    IReadOnlyList<SleepEntryDto> Sleep,
    ProfileDto? Profile,
    GoalsDto? Goals);
