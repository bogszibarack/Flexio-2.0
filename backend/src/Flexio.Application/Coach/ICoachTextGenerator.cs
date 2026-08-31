namespace Flexio.Application.Coach;

/// <summary>
/// Szöveggeneráló port. Az Application nem tud a Gemini-ről; az Infrastructure
/// adja a konkrét klienset, és a tartalék szöveget, ha nincs kulcs.
/// </summary>
public interface ICoachTextGenerator
{
    Task<CoachCopy> GenerateAsync(
        GenerateCoachCopyCommand command,
        CancellationToken cancellationToken);
}
