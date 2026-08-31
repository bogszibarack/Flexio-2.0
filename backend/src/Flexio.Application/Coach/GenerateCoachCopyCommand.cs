using System.Text.Json;

namespace Flexio.Application.Coach;

/// <summary>
/// A kliens rövid, anonim pillanatképe. Nincs név, e-mail, étellista.
/// </summary>
public sealed record CoachSnapshot(string Kind, JsonElement Facts);

/// <summary>
/// A coach szöveg generálásának bemenete. A fallback a kliens helyi szabály-
/// szövege: ha a modell nem elérhető vagy hibás JSON-t ad, ezt kapja vissza.
/// </summary>
public sealed record GenerateCoachCopyCommand(
    CoachSnapshot Snapshot,
    CoachCopy Fallback);
