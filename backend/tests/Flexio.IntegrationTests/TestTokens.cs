using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;

namespace Flexio.IntegrationTests;

/// <summary>
/// Teszt-tokenek előállítása. Ugyanazt az utat járja, mint a Supabase: RS256
/// aláírás, "sub" claim, "authenticated" audience.
/// </summary>
internal static class TestTokens
{
    internal static string ForUser(FlexioApiFactory factory, Guid userId) =>
        Create(factory, claims: new Dictionary<string, object> { ["sub"] = userId.ToString() });

    internal static string WithoutSubject(FlexioApiFactory factory) =>
        Create(factory, claims: new Dictionary<string, object> { ["role"] = "authenticated" });

    internal static string Expired(FlexioApiFactory factory, Guid userId)
    {
        var expiredAt = DateTime.UtcNow.AddMinutes(-5);

        return Create(
            factory,
            claims: new Dictionary<string, object> { ["sub"] = userId.ToString() },
            notBefore: expiredAt.AddMinutes(-5),
            expires: expiredAt);
    }

    internal static string FromForeignIssuer(FlexioApiFactory factory, Guid userId) =>
        Create(
            factory,
            claims: new Dictionary<string, object> { ["sub"] = userId.ToString() },
            issuer: "https://tamado.example.com/auth/v1");

    internal static string WithForeignAudience(FlexioApiFactory factory, Guid userId) =>
        Create(
            factory,
            claims: new Dictionary<string, object> { ["sub"] = userId.ToString() },
            audience: "mas-alkalmazas");

    private static string Create(
        FlexioApiFactory factory,
        Dictionary<string, object> claims,
        string? issuer = null,
        string? audience = null,
        DateTime? notBefore = null,
        DateTime? expires = null)
    {
        var descriptor = new SecurityTokenDescriptor
        {
            Issuer = issuer ?? FlexioApiFactory.Issuer,
            Audience = audience ?? FlexioApiFactory.Audience,
            Claims = claims,
            NotBefore = notBefore ?? DateTime.UtcNow.AddMinutes(-1),
            Expires = expires ?? DateTime.UtcNow.AddMinutes(5),
            SigningCredentials = new SigningCredentials(factory.SigningKey, SecurityAlgorithms.RsaSha256),
        };

        return new JsonWebTokenHandler().CreateToken(descriptor);
    }
}
