using Dapper;
using Flexio.Application.Sync;
using Flexio.Domain.Common;
using Flexio.Domain.Identity;

namespace Flexio.Infrastructure.Persistence.Repositories;

internal sealed class ProfileRepository : IProfileRepository
{
    private readonly DbSession _session;

    public ProfileRepository(DbSession session)
    {
        _session = session;
    }

    public async Task UpsertAsync(UserId userId, ProfileDto profile, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(profile);
        if (profile.UserId != userId.Value)
        {
            throw new ForbiddenException("A profil nem a bejelentkezett felhasználóhoz tartozik.");
        }

        await _session.RequireConnection().ExecuteAsync(
            _session.Command(
                """
                insert into public.profiles (
                  user_id, first_name, gender, birth_date, height_cm, weight_kg,
                  activity_level, goal, updated_at)
                values (
                  @UserId, @FirstName, @Gender, @BirthDate, @HeightCm, @WeightKg,
                  @ActivityLevel, @Goal, @UpdatedAt)
                on conflict (user_id) do update set
                  first_name = excluded.first_name,
                  gender = excluded.gender,
                  birth_date = excluded.birth_date,
                  height_cm = excluded.height_cm,
                  weight_kg = excluded.weight_kg,
                  activity_level = excluded.activity_level,
                  goal = excluded.goal,
                  updated_at = excluded.updated_at
                where public.profiles.updated_at < excluded.updated_at
                """,
                profile,
                cancellationToken));
    }

    public async Task UpsertGoalsAsync(UserId userId, GoalsDto goals, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(goals);
        if (goals.UserId != userId.Value)
        {
            throw new ForbiddenException("A célok nem a bejelentkezett felhasználóhoz tartoznak.");
        }

        await _session.RequireConnection().ExecuteAsync(
            _session.Command(
                """
                insert into public.goals (
                  user_id, calorie_goal, protein_goal, fat_goal, carbs_goal,
                  water_goal_ml, is_manual, updated_at)
                values (
                  @UserId, @CalorieGoal, @ProteinGoal, @FatGoal, @CarbsGoal,
                  @WaterGoalMl, @IsManual, now())
                on conflict (user_id) do update set
                  calorie_goal = excluded.calorie_goal,
                  protein_goal = excluded.protein_goal,
                  fat_goal = excluded.fat_goal,
                  carbs_goal = excluded.carbs_goal,
                  water_goal_ml = excluded.water_goal_ml,
                  is_manual = excluded.is_manual,
                  updated_at = now()
                """,
                goals,
                cancellationToken));
    }

    public async Task<ProfileDto?> GetProfileAsync(UserId userId, CancellationToken cancellationToken)
    {
        return await _session.RequireConnection().QuerySingleOrDefaultAsync<ProfileDto>(
            _session.Command(
                """
                select
                  user_id as UserId,
                  first_name as FirstName,
                  gender as Gender,
                  birth_date as BirthDate,
                  height_cm as HeightCm,
                  weight_kg as WeightKg,
                  activity_level as ActivityLevel,
                  goal as Goal,
                  updated_at as UpdatedAt
                from public.profiles
                where user_id = @UserId
                """,
                new { UserId = userId.Value },
                cancellationToken));
    }

    public async Task<GoalsDto?> GetGoalsAsync(UserId userId, CancellationToken cancellationToken)
    {
        return await _session.RequireConnection().QuerySingleOrDefaultAsync<GoalsDto>(
            _session.Command(
                """
                select
                  user_id as UserId,
                  calorie_goal as CalorieGoal,
                  protein_goal as ProteinGoal,
                  fat_goal as FatGoal,
                  carbs_goal as CarbsGoal,
                  water_goal_ml as WaterGoalMl,
                  is_manual as IsManual
                from public.goals
                where user_id = @UserId
                """,
                new { UserId = userId.Value },
                cancellationToken));
    }
}
