using System.ComponentModel.DataAnnotations;

namespace Flexio.Api.Authentication;

/// <summary>
/// A Supabase Auth mint token-kibocsátó beállításai. A saját API kizárólag
/// validál: nincs jelszókezelés, nincs token-kiadás, nincs refresh.
/// </summary>
public sealed class SupabaseAuthOptions
{
    public const string SectionName = "SupabaseAuth";

    /// <summary>A projekt URL-je, például <c>https://abcdefgh.supabase.co</c>.</summary>
    [Required]
    [Url]
    public string ProjectUrl { get; init; } = string.Empty;

    /// <summary>A Supabase minden bejelentkezett tokenbe ezt az audience-t írja.</summary>
    [Required]
    public string Audience { get; init; } = "authenticated";

    /// <summary>
    /// A régi, szimmetrikus (HS256) aláírás titka. Csak addig kell, amíg a
    /// projekt át nem áll aszimmetrikus kulcsra; ha üres, csak a JWKS-ből
    /// származó kulcsok érvényesek.
    /// </summary>
    public string? LegacyJwtSecret { get; init; }

    /// <summary>Óraeltérés-tolerancia. Kis érték, mert a token élettartama rövid.</summary>
    [Range(0, 300)]
    public int ClockSkewSeconds { get; init; } = 30;

    public string Issuer => $"{ProjectUrl.TrimEnd('/')}/auth/v1";

    /// <summary>
    /// A Supabase nem OIDC szolgáltató: discovery dokumentuma nincs, csak
    /// JWKS-e, ezért erre az útvonalra kell közvetlenül csatlakozni.
    /// </summary>
    public string JwksUri => $"{Issuer}/.well-known/jwks.json";
}
