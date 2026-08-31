using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;

namespace Flexio.Api.Authentication;

/// <summary>
/// A JwtBearer séma beállítása a Supabase kibocsátóhoz. Külön osztály és nem
/// lambda, hogy a beállítás DI-ből kapja a <see cref="SupabaseAuthOptions"/>-t,
/// és a tesztek felül tudják írni a kulcsforrást.
/// </summary>
internal sealed class SupabaseJwtBearerConfiguration : IConfigureNamedOptions<JwtBearerOptions>
{
    private readonly SupabaseAuthOptions _authOptions;

    public SupabaseJwtBearerConfiguration(IOptions<SupabaseAuthOptions> authOptions)
    {
        _authOptions = authOptions.Value;
    }

    public void Configure(JwtBearerOptions options) => Configure(Options.DefaultName, options);

    public void Configure(string? name, JwtBearerOptions options)
    {
        ArgumentNullException.ThrowIfNull(options);

        if (name is not JwtBearerDefaults.AuthenticationScheme)
        {
            return;
        }

        // A kulcsokat közvetlenül a JWKS végpontról töltjük. A ConfigurationManager
        // gyorsítótáraz és időnként újratölt, így a kulcsrotáció újraindítás
        // nélkül végigfut.
        options.ConfigurationManager = new ConfigurationManager<OpenIdConnectConfiguration>(
            _authOptions.JwksUri,
            new SupabaseJwksRetriever(_authOptions.Issuer),
            new HttpDocumentRetriever { RequireHttps = true });

        // A claim nevek maradjanak azok, amiket a kibocsátó küldött: a "sub"-ból
        // ne legyen néma átnevezéssel NameIdentifier.
        options.MapInboundClaims = false;

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = _authOptions.Issuer,
            ValidateAudience = true,
            ValidAudience = _authOptions.Audience,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ClockSkew = TimeSpan.FromSeconds(_authOptions.ClockSkewSeconds),
            NameClaimType = "sub",
            IssuerSigningKeys = BuildLegacySigningKeys(_authOptions.LegacyJwtSecret),
        };
    }

    /// <summary>
    /// A régi HS256 titok, ha a projekt még nem állt át aszimmetrikus kulcsra.
    /// A JWKS-ből jövő kulcsokat a keretrendszer ehhez a listához fűzi.
    /// </summary>
    private static IEnumerable<SecurityKey>? BuildLegacySigningKeys(string? legacyJwtSecret)
    {
        if (string.IsNullOrWhiteSpace(legacyJwtSecret))
        {
            return null;
        }

        return [new SymmetricSecurityKey(Encoding.UTF8.GetBytes(legacyJwtSecret))];
    }
}
