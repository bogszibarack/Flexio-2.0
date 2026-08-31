using System.ComponentModel.DataAnnotations;

namespace Flexio.Infrastructure.Coach;

/// <summary>
/// A Gemini szöveggenerálás beállításai. A kulcs hiánya nem indulási hiba:
/// ilyenkor a coach a kliens által küldött tartalék mondatot adja vissza,
/// tehát a szolgáltatás működik, csak gyengébb szöveggel.
/// </summary>
public sealed class GeminiOptions
{
    public const string SectionName = "Gemini";

    /// <summary>Környezeti változóból jön (<c>Gemini__ApiKey</c>), sosem appsettingsből.</summary>
    public string ApiKey { get; init; } = string.Empty;

    [Required]
    public string Model { get; init; } = "gemini-2.0-flash";

    [Range(1, 60)]
    public int TimeoutSeconds { get; init; } = 12;

    [Required]
    [Url]
    public string BaseUrl { get; init; } = "https://generativelanguage.googleapis.com/";

    public bool IsConfigured => !string.IsNullOrWhiteSpace(ApiKey);
}
