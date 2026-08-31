using Flexio.Domain.Identity;

namespace Flexio.Application.Coach;

public enum CoachUsageStatus
{
    Success = 1,
    Fallback = 2,
    Error = 3,
}

/// <summary>
/// Coach hívás napló. Csak azonosító, típus, modell, státusz, késleltetés -
/// soha nem a pillanatkép szövege.
/// </summary>
public interface ICoachUsageRecorder
{
    Task RecordAsync(
        UserId userId,
        string kind,
        string? model,
        CoachUsageStatus status,
        int latencyMilliseconds,
        CancellationToken cancellationToken);
}
