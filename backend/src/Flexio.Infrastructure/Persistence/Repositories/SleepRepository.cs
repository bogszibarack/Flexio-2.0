using Dapper;
using Flexio.Application.Sync;
using Flexio.Domain.Common;
using Flexio.Domain.Identity;

namespace Flexio.Infrastructure.Persistence.Repositories;

internal sealed class SleepRepository : ISleepRepository
{
    private readonly DbSession _session;

    public SleepRepository(DbSession session)
    {
        _session = session;
    }

    public async Task<int> UpsertBatchAsync(
        UserId userId,
        IReadOnlyList<SleepEntryDto> entries,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(entries);
        foreach (var entry in entries)
        {
            if (entry.UserId != userId.Value)
            {
                throw new ForbiddenException("Az alvásbejegyzés nem a bejelentkezett felhasználóhoz tartozik.");
            }
        }

        var accepted = 0;
        foreach (var entry in entries)
        {
            accepted += await _session.RequireConnection().ExecuteAsync(
                _session.Command(
                    """
                    insert into public.sleep_entries (
                      id, user_id, bedtime, wake_time, quality, note, updated_at, deleted_at)
                    values (
                      @Id, @UserId, @Bedtime, @WakeTime, @Quality, @Note, @UpdatedAt, @DeletedAt)
                    on conflict (id) do update set
                      bedtime = excluded.bedtime,
                      wake_time = excluded.wake_time,
                      quality = excluded.quality,
                      note = excluded.note,
                      updated_at = excluded.updated_at,
                      deleted_at = excluded.deleted_at
                    where public.sleep_entries.user_id = excluded.user_id
                      and public.sleep_entries.updated_at < excluded.updated_at
                    """,
                    entry,
                    cancellationToken));
        }

        return accepted;
    }

    public async Task<IReadOnlyList<SleepEntryDto>> ListChangedSinceAsync(
        UserId userId,
        DateTimeOffset? since,
        CancellationToken cancellationToken)
    {
        var rows = await _session.RequireConnection().QueryAsync<SleepEntryDto>(
            _session.Command(
                """
                select
                  id as Id,
                  user_id as UserId,
                  bedtime as Bedtime,
                  wake_time as WakeTime,
                  quality as Quality,
                  note as Note,
                  updated_at as UpdatedAt,
                  deleted_at as DeletedAt
                from public.sleep_entries
                where user_id = @UserId
                  and (@Since is null or updated_at > @Since)
                order by updated_at asc
                """,
                new { UserId = userId.Value, Since = since },
                cancellationToken));

        return rows.AsList();
    }
}
