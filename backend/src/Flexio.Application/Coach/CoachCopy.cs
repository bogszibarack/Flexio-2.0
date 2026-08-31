namespace Flexio.Application.Coach;

/// <summary>
/// A coach válasz: rövid magyar szöveg. A számokat a kliens számolja, a szerver
/// csak a nyelvet adja.
/// </summary>
public sealed record CoachCopy(string Prose, string Pros, string Cons)
{
    public static CoachCopy Empty { get; } = new(string.Empty, string.Empty, string.Empty);

    public bool HasProse => !string.IsNullOrWhiteSpace(Prose);
}
