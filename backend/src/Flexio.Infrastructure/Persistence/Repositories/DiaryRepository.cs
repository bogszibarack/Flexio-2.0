using Dapper;
using Flexio.Application.Sync;
using Flexio.Domain.Common;
using Flexio.Domain.Identity;

namespace Flexio.Infrastructure.Persistence.Repositories;

internal sealed class DiaryRepository : IDiaryRepository
{
    private readonly DbSession _session;

    public DiaryRepository(DbSession session)
    {
        _session = session;
    }

    public async Task<int> UpsertBatchAsync(
        UserId userId,
        IReadOnlyList<DiaryEntryDto> entries,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(entries);
        EnsureOwnRows(userId, entries);

        var accepted = 0;
        foreach (var entry in entries)
        {
            accepted += await _session.RequireConnection().ExecuteAsync(
                _session.Command(
                    """
                    insert into public.diary_entries (
                      id, user_id, logged_at, local_date, meal_type, food_id, food_name, food_image,
                      amount_g, serving_label, kcal, protein, fat, carbs, sugar, saturated_fat, salt, fiber,
                      updated_at, deleted_at)
                    values (
                      @Id, @UserId, @LoggedAt, @LocalDate, @MealType, @FoodId, @FoodName, @FoodImage,
                      @AmountG, @ServingLabel, @Kcal, @Protein, @Fat, @Carbs, @Sugar, @SaturatedFat, @Salt, @Fiber,
                      @UpdatedAt, @DeletedAt)
                    on conflict (id) do update set
                      logged_at = excluded.logged_at,
                      local_date = excluded.local_date,
                      meal_type = excluded.meal_type,
                      food_id = excluded.food_id,
                      food_name = excluded.food_name,
                      food_image = excluded.food_image,
                      amount_g = excluded.amount_g,
                      serving_label = excluded.serving_label,
                      kcal = excluded.kcal,
                      protein = excluded.protein,
                      fat = excluded.fat,
                      carbs = excluded.carbs,
                      sugar = excluded.sugar,
                      saturated_fat = excluded.saturated_fat,
                      salt = excluded.salt,
                      fiber = excluded.fiber,
                      updated_at = excluded.updated_at,
                      deleted_at = excluded.deleted_at
                    where public.diary_entries.user_id = excluded.user_id
                      and public.diary_entries.updated_at < excluded.updated_at
                    """,
                    entry,
                    cancellationToken));
        }

        return accepted;
    }

    public async Task<IReadOnlyList<DiaryEntryDto>> ListChangedSinceAsync(
        UserId userId,
        DateTimeOffset? since,
        CancellationToken cancellationToken)
    {
        var rows = await _session.RequireConnection().QueryAsync<DiaryEntryDto>(
            _session.Command(
                """
                select
                  id as Id,
                  user_id as UserId,
                  logged_at as LoggedAt,
                  local_date as LocalDate,
                  meal_type as MealType,
                  food_id as FoodId,
                  food_name as FoodName,
                  food_image as FoodImage,
                  amount_g as AmountG,
                  serving_label as ServingLabel,
                  kcal as Kcal,
                  protein as Protein,
                  fat as Fat,
                  carbs as Carbs,
                  sugar as Sugar,
                  saturated_fat as SaturatedFat,
                  salt as Salt,
                  fiber as Fiber,
                  updated_at as UpdatedAt,
                  deleted_at as DeletedAt
                from public.diary_entries
                where user_id = @UserId
                  and (@Since is null or updated_at > @Since)
                order by updated_at asc
                """,
                new { UserId = userId.Value, Since = since },
                cancellationToken));

        return rows.AsList();
    }

    private static void EnsureOwnRows(UserId userId, IReadOnlyList<DiaryEntryDto> entries)
    {
        foreach (var entry in entries)
        {
            if (entry.UserId != userId.Value)
            {
                throw new ForbiddenException("A naplóbejegyzés nem a bejelentkezett felhasználóhoz tartozik.");
            }
        }
    }
}
