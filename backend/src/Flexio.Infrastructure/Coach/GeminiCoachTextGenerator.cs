using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Flexio.Application.Coach;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Flexio.Infrastructure.Coach;

/// <summary>
/// Gemini-alapú szöveggeneráló. Kulcs hiányában vagy hiba esetén a kliens
/// tartalék szövegét adja vissza - a coach soha nem 502-vel válaszol a
/// felhasználónak, mert a helyi szabályszöveg mindig érvényes.
/// </summary>
internal sealed class GeminiCoachTextGenerator : ICoachTextGenerator
{
    private static readonly JsonSerializerOptions SerializerOptions = new(JsonSerializerDefaults.Web);

    private readonly HttpClient _httpClient;
    private readonly IOptionsMonitor<GeminiOptions> _options;
    private readonly ILogger<GeminiCoachTextGenerator> _logger;

    public GeminiCoachTextGenerator(
        HttpClient httpClient,
        IOptionsMonitor<GeminiOptions> options,
        ILogger<GeminiCoachTextGenerator> logger)
    {
        _httpClient = httpClient;
        _options = options;
        _logger = logger;
    }

    public async Task<CoachCopy> GenerateAsync(
        GenerateCoachCopyCommand command,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(command);

        var options = _options.CurrentValue;
        if (!options.IsConfigured)
        {
            return command.Fallback;
        }

        using var request = BuildRequest(command, options);
        using var response = await _httpClient
            .SendAsync(request, cancellationToken)
            .ConfigureAwait(false);

        if (!response.IsSuccessStatusCode)
        {
            _logger.LogWarning(
                "A Gemini HTTP {StatusCode} választ adott a coach kérésre.",
                (int)response.StatusCode);
            return command.Fallback;
        }

        await using var stream = await response.Content
            .ReadAsStreamAsync(cancellationToken)
            .ConfigureAwait(false);

        using var document = await JsonDocument
            .ParseAsync(stream, cancellationToken: cancellationToken)
            .ConfigureAwait(false);

        var text = ExtractModelText(document.RootElement);
        return CoachResponseParser.Parse(text, command.Fallback);
    }

    private static HttpRequestMessage BuildRequest(
        GenerateCoachCopyCommand command,
        GeminiOptions options)
    {
        var path =
            $"v1beta/models/{Uri.EscapeDataString(options.Model)}:generateContent" +
            $"?key={Uri.EscapeDataString(options.ApiKey)}";

        var payload = new
        {
            contents = new[]
            {
                new
                {
                    parts = new[]
                    {
                        new { text = BuildPrompt(command) },
                    },
                },
            },
            generationConfig = new
            {
                temperature = 0.6,
                maxOutputTokens = 256,
                responseMimeType = "application/json",
            },
        };

        return new HttpRequestMessage(HttpMethod.Post, path)
        {
            Content = JsonContent.Create(payload, options: SerializerOptions),
        };
    }

    private static string BuildPrompt(GenerateCoachCopyCommand command)
    {
        var kind = command.Snapshot.Kind;
        var facts = command.Snapshot.Facts.ValueKind == JsonValueKind.Undefined
            ? "{}"
            : command.Snapshot.Facts.GetRawText();
        var fallback = JsonSerializer.Serialize(new
        {
            prose = command.Fallback.Prose,
            pros = command.Fallback.Pros,
            cons = command.Fallback.Cons,
        }, SerializerOptions);

        var builder = new StringBuilder();
        builder.AppendLine("Te a Flexio magyar edzőtársa vagy. Rövid, barátságos, konkrét.");
        builder.AppendLine("TILOS: orvosi diagnózis, betegség, étrend-kiegészítő, kitalált kg/kcal szám.");
        builder.AppendLine("A számokat NE változtasd. A tények adottak. Csak szöveget írsz.");
        builder.Append("Típus: ").AppendLine(kind);
        builder.AppendLine("Tények:");
        builder.AppendLine(facts);
        builder.Append("Helyi javaslat, ha nincs jobb ötleted: ").AppendLine(fallback);
        builder.AppendLine(
            "Válaszolj CSAK JSON-nel: {\"prose\":\"1-2 mondat\",\"pros\":\"egy mondat vagy üres\",\"cons\":\"egy mondat vagy üres\"}");
        builder.AppendLine(
            kind == "workout"
                ? "A prose a választott százalékra vonatkozik. A pros/cons 1-1 mondat."
                : "A prose egy rövid magyar összefoglaló. A pros és cons legyen üres, kivéve ha tényleg kell.");
        return builder.ToString();
    }

    private static string? ExtractModelText(JsonElement root)
    {
        if (!root.TryGetProperty("candidates", out var candidates)
            || candidates.ValueKind != JsonValueKind.Array
            || candidates.GetArrayLength() == 0)
        {
            return null;
        }

        var first = candidates[0];
        if (!first.TryGetProperty("content", out var content)
            || !content.TryGetProperty("parts", out var parts)
            || parts.ValueKind != JsonValueKind.Array)
        {
            return null;
        }

        var text = new StringBuilder();
        foreach (var part in parts.EnumerateArray())
        {
            if (part.TryGetProperty("text", out var fragment)
                && fragment.ValueKind == JsonValueKind.String)
            {
                text.AppendLine(fragment.GetString());
            }
        }

        return text.ToString();
    }
}
