using Dapper;
using Flexio.Application.Sync;
using Flexio.Domain.Common;
using Flexio.Domain.Identity;

namespace Flexio.Infrastructure.Persistence.Repositories;

internal sealed class WorkoutRepository : IWorkoutRepository
{
    private readonly DbSession _session;

    public WorkoutRepository(DbSession session)
    {
        _session = session;
    }

    public async Task<int> UpsertBatchAsync(
        UserId userId,
        IReadOnlyList<WorkoutSessionDto> sessions,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(sessions);
        foreach (var session in sessions)
        {
            if (session.UserId != userId.Value)
            {
                throw new ForbiddenException("Az edzés nem a bejelentkezett felhasználóhoz tartozik.");
            }
        }

        var accepted = 0;
        foreach (var session in sessions)
        {
            accepted += await _session.RequireConnection().ExecuteAsync(
                _session.Command(
                    """
                    insert into public.workout_sessions (
                      id, user_id, title, kind, scheduled_at, completed_at,
                      duration_minutes, calories, difficulty, payload, updated_at, deleted_at)
                    values (
                      @Id, @UserId, @Title, @Kind, @ScheduledAt, @CompletedAt,
                      @DurationMinutes, @Calories, @Difficulty, cast(@PayloadJson as jsonb), @UpdatedAt, @DeletedAt)
                    on conflict (id) do update set
                      title = excluded.title,
                      kind = excluded.kind,
                      scheduled_at = excluded.scheduled_at,
                      completed_at = excluded.completed_at,
                      duration_minutes = excluded.duration_minutes,
                      calories = excluded.calories,
                      difficulty = excluded.difficulty,
                      payload = excluded.payload,
                      updated_at = excluded.updated_at,
                      deleted_at = excluded.deleted_at
                    where public.workout_sessions.user_id = excluded.user_id
                      and public.workout_sessions.updated_at < excluded.updated_at
                    """,
                    session,
                    cancellationToken));
        }

        return accepted;
    }

    public async Task<IReadOnlyList<WorkoutSessionDto>> ListChangedSinceAsync(
        UserId userId,
        DateTimeOffset? since,
        CancellationToken cancellationToken)
    {
        var rows = await _session.RequireConnection().QueryAsync<WorkoutSessionDto>(
            _session.Command(
                """
                select
                  id as Id,
                  user_id as UserId,
                  title as Title,
                  kind as Kind,
                  scheduled_at as ScheduledAt,
                  completed_at as CompletedAt,
                  duration_minutes as DurationMinutes,
                  calories as Calories,
                  difficulty as Difficulty,
                  payload::text as PayloadJson,
                  updated_at as UpdatedAt,
                  deleted_at as DeletedAt
                from public.workout_sessions
                where user_id = @UserId
                  and (@Since is null or updated_at > @Since)
                order by updated_at asc
                """,
                new { UserId = userId.Value, Since = since },
                cancellationToken));

        return rows.AsList();
    }
}
