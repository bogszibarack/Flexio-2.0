using Flexio.Domain.Identity;

namespace Flexio.Application.Sync;

public sealed class DiaryEntryDto
{
    public Guid Id { get; init; }
    public Guid UserId { get; init; }
    public DateTimeOffset LoggedAt { get; init; }
    public DateOnly LocalDate { get; init; }
    public string MealType { get; init; } = string.Empty;
    public Guid? FoodId { get; init; }
    public string FoodName { get; init; } = string.Empty;
    public string? FoodImage { get; init; }
    public decimal AmountG { get; init; }
    public string? ServingLabel { get; init; }
    public decimal Kcal { get; init; }
    public decimal Protein { get; init; }
    public decimal Fat { get; init; }
    public decimal Carbs { get; init; }
    public decimal? Sugar { get; init; }
    public decimal? SaturatedFat { get; init; }
    public decimal? Salt { get; init; }
    public decimal? Fiber { get; init; }
    public DateTimeOffset UpdatedAt { get; init; }
    public DateTimeOffset? DeletedAt { get; init; }
}

public sealed class ProfileDto
{
    public Guid UserId { get; init; }
    public string? FirstName { get; init; }
    public string? Gender { get; init; }
    public DateOnly? BirthDate { get; init; }
    public decimal? HeightCm { get; init; }
    public decimal? WeightKg { get; init; }
    public string ActivityLevel { get; init; } = "moderate";
    public string? Goal { get; init; }
    public string? AvatarUrl { get; init; }
    public DateTimeOffset? AvatarUpdatedAt { get; init; }
    public DateTimeOffset UpdatedAt { get; init; }
}

public sealed class GoalsDto
{
    public Guid UserId { get; init; }
    public decimal? CalorieGoal { get; init; }
    public decimal? ProteinGoal { get; init; }
    public decimal? FatGoal { get; init; }
    public decimal? CarbsGoal { get; init; }
    public int? WaterGoalMl { get; init; }
    public bool IsManual { get; init; }
}

public sealed class WorkoutSessionDto
{
    public Guid Id { get; init; }
    public Guid UserId { get; init; }
    public string Title { get; init; } = string.Empty;
    public string Kind { get; init; } = "completed";
    public DateTimeOffset? ScheduledAt { get; init; }
    public DateTimeOffset? CompletedAt { get; init; }
    public int? DurationMinutes { get; init; }
    public decimal? Calories { get; init; }
    public string? Difficulty { get; init; }

    /// <summary>
    /// A kliens JSON objektumként küldi (<c>payload</c>). A Dapper szövegként
    /// olvassa vissza. A konverter mindkét formát elfogadja.
    /// </summary>
    [System.Text.Json.Serialization.JsonPropertyName("payload")]
    [System.Text.Json.Serialization.JsonConverter(typeof(JsonElementOrStringConverter))]
    public string PayloadJson { get; init; } = "{}";

    public DateTimeOffset UpdatedAt { get; init; }
    public DateTimeOffset? DeletedAt { get; init; }
}

/// <summary>
/// A workout <c>payload</c> mező objektumként vagy stringként is érkezhet.
/// </summary>
public sealed class JsonElementOrStringConverter : System.Text.Json.Serialization.JsonConverter<string>
{
    public override string Read(
        ref System.Text.Json.Utf8JsonReader reader,
        Type typeToConvert,
        System.Text.Json.JsonSerializerOptions options)
    {
        using var document = System.Text.Json.JsonDocument.ParseValue(ref reader);
        return document.RootElement.ValueKind == System.Text.Json.JsonValueKind.String
            ? document.RootElement.GetString() ?? "{}"
            : document.RootElement.GetRawText();
    }

    public override void Write(
        System.Text.Json.Utf8JsonWriter writer,
        string value,
        System.Text.Json.JsonSerializerOptions options)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            writer.WriteStartObject();
            writer.WriteEndObject();
            return;
        }

        using var document = System.Text.Json.JsonDocument.Parse(value);
        document.RootElement.WriteTo(writer);
    }
}

public sealed class SleepEntryDto
{
    public Guid Id { get; init; }
    public Guid UserId { get; init; }
    public DateTimeOffset Bedtime { get; init; }
    public DateTimeOffset WakeTime { get; init; }
    public int? Quality { get; init; }
    public string? Note { get; init; }
    public DateTimeOffset UpdatedAt { get; init; }
    public DateTimeOffset? DeletedAt { get; init; }
}

public interface IDiaryRepository
{
    Task<int> UpsertBatchAsync(UserId userId, IReadOnlyList<DiaryEntryDto> entries, CancellationToken cancellationToken);
    Task<IReadOnlyList<DiaryEntryDto>> ListChangedSinceAsync(UserId userId, DateTimeOffset? since, CancellationToken cancellationToken);
}

public interface IProfileRepository
{
    Task UpsertAsync(UserId userId, ProfileDto profile, CancellationToken cancellationToken);
    Task UpsertGoalsAsync(UserId userId, GoalsDto goals, CancellationToken cancellationToken);
    Task<ProfileDto?> GetProfileAsync(UserId userId, CancellationToken cancellationToken);
    Task<GoalsDto?> GetGoalsAsync(UserId userId, CancellationToken cancellationToken);
}

public interface IWorkoutRepository
{
    Task<int> UpsertBatchAsync(UserId userId, IReadOnlyList<WorkoutSessionDto> sessions, CancellationToken cancellationToken);
    Task<IReadOnlyList<WorkoutSessionDto>> ListChangedSinceAsync(UserId userId, DateTimeOffset? since, CancellationToken cancellationToken);
}

public interface ISleepRepository
{
    Task<int> UpsertBatchAsync(UserId userId, IReadOnlyList<SleepEntryDto> entries, CancellationToken cancellationToken);
    Task<IReadOnlyList<SleepEntryDto>> ListChangedSinceAsync(UserId userId, DateTimeOffset? since, CancellationToken cancellationToken);
}
