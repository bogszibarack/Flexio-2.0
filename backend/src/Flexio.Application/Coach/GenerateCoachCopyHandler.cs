using System.Diagnostics;
using Flexio.Application.Abstractions;
using Flexio.Domain.Common;
using Microsoft.Extensions.Logging;

namespace Flexio.Application.Coach;

/// <summary>
/// A coach use case: validál, generáltat, naplóz. A rate limit az API rétegben
/// él (HTTP-közeli), mert a kvóta a kéréshez, nem a domainhez tartozik.
/// </summary>
public sealed class GenerateCoachCopyHandler
{
    private static readonly HashSet<string> AllowedKinds = new(StringComparer.Ordinal)
    {
        "workout",
        "nutrition",
        "sleep",
    };

    private readonly ICoachTextGenerator _textGenerator;
    private readonly ICoachUsageRecorder _usageRecorder;
    private readonly ICurrentUserAccessor _currentUser;
    private readonly ILogger<GenerateCoachCopyHandler> _logger;

    public GenerateCoachCopyHandler(
        ICoachTextGenerator textGenerator,
        ICoachUsageRecorder usageRecorder,
        ICurrentUserAccessor currentUser,
        ILogger<GenerateCoachCopyHandler> logger)
    {
        _textGenerator = textGenerator;
        _usageRecorder = usageRecorder;
        _currentUser = currentUser;
        _logger = logger;
    }

    public async Task<CoachCopy> HandleAsync(
        GenerateCoachCopyCommand command,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);
        Validate(command);

        var userId = _currentUser.RequireUserId();
        var stopwatch = Stopwatch.StartNew();
        CoachUsageStatus status;
        CoachCopy result;

        try
        {
            result = await _textGenerator
                .GenerateAsync(command, cancellationToken)
                .ConfigureAwait(false);

            status = IsSameAsFallback(result, command.Fallback)
                ? CoachUsageStatus.Fallback
                : CoachUsageStatus.Success;
        }
        catch (Exception exception) when (exception is not OperationCanceledException)
        {
            _logger.LogWarning(
                exception,
                "A coach szöveggenerálás meghiúsult; a kliens tartalék szövegét adjuk vissza.");
            result = command.Fallback;
            status = CoachUsageStatus.Error;
        }

        stopwatch.Stop();

        try
        {
            await _usageRecorder
                .RecordAsync(
                    userId,
                    command.Snapshot.Kind,
                    model: null,
                    status,
                    (int)stopwatch.ElapsedMilliseconds,
                    cancellationToken)
                .ConfigureAwait(false);
        }
        catch (Exception exception) when (exception is not OperationCanceledException)
        {
            // A napló soha nem dönthet a felhasználói válaszról.
            _logger.LogWarning(exception, "A coach usage napló írása meghiúsult.");
        }

        return result;
    }

    private static void Validate(GenerateCoachCopyCommand command)
    {
        var failures = new Dictionary<string, string[]>(StringComparer.Ordinal);

        if (string.IsNullOrWhiteSpace(command.Snapshot.Kind))
        {
            failures["snapshot.kind"] = ["A coach típus megadása kötelező."];
        }
        else if (!AllowedKinds.Contains(command.Snapshot.Kind))
        {
            failures["snapshot.kind"] =
            [
                "A coach típus csak workout, nutrition vagy sleep lehet.",
            ];
        }

        if (string.IsNullOrWhiteSpace(command.Fallback.Prose))
        {
            failures["fallback.prose"] =
            [
                "A helyi tartalék szöveg (fallback.prose) kötelező.",
            ];
        }

        if (failures.Count > 0)
        {
            throw new ValidationException("Érvénytelen coach kérés.", failures);
        }
    }

    private static bool IsSameAsFallback(CoachCopy result, CoachCopy fallback) =>
        string.Equals(result.Prose, fallback.Prose, StringComparison.Ordinal)
        && string.Equals(result.Pros, fallback.Pros, StringComparison.Ordinal)
        && string.Equals(result.Cons, fallback.Cons, StringComparison.Ordinal);
}
