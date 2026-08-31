using System.Text.Json;

namespace Flexio.Application.Coach;

/// <summary>
/// A modell válaszának JSON-kinyerése. Tiszta függvény, infrastruktúra nélkül,
/// ezért a unit tesztek a Gemini kliens nélkül is lefedik.
/// </summary>
public static class CoachResponseParser
{
    public static CoachCopy Parse(string? text, CoachCopy fallback)
    {
        ArgumentNullException.ThrowIfNull(fallback);

        var raw = (text ?? string.Empty).Trim();
        var start = raw.IndexOf('{');
        var end = raw.LastIndexOf('}');
        if (start < 0 || end <= start)
        {
            return fallback;
        }

        try
        {
            using var document = JsonDocument.Parse(raw[start..(end + 1)]);
            var root = document.RootElement;
            var prose = ReadField(root, "prose") ?? fallback.Prose;
            if (string.IsNullOrWhiteSpace(prose))
            {
                prose = fallback.Prose;
            }

            return new CoachCopy(
                prose.Trim(),
                (ReadField(root, "pros") ?? fallback.Pros).Trim(),
                (ReadField(root, "cons") ?? fallback.Cons).Trim());
        }
        catch (JsonException)
        {
            return fallback;
        }
    }

    private static string? ReadField(JsonElement root, string name) =>
        root.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.String
            ? value.GetString()
            : null;
}
