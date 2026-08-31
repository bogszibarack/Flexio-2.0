using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;

namespace Flexio.Api.Authentication;

/// <summary>
/// A Supabase nem OIDC szolgáltató: nincs discovery dokumentuma, csak JWKS-e.
/// Ez a retriever a JWKS-t olvassa, és a keretrendszer által elvárt
/// konfigurációs objektumba csomagolja, hogy a <c>ConfigurationManager</c>
/// gyorsítótárazása és kulcsrotációja változatlanul működjön.
/// </summary>
internal sealed class SupabaseJwksRetriever : IConfigurationRetriever<OpenIdConnectConfiguration>
{
    private readonly string _issuer;

    public SupabaseJwksRetriever(string issuer)
    {
        _issuer = issuer;
    }

    public async Task<OpenIdConnectConfiguration> GetConfigurationAsync(
        string address,
        IDocumentRetriever retriever,
        CancellationToken cancel)
    {
        ArgumentNullException.ThrowIfNull(retriever);

        var document = await retriever.GetDocumentAsync(address, cancel).ConfigureAwait(false);
        var keySet = new JsonWebKeySet(document);

        // Az issuer nem a JWKS-ből jön (nincs benne), hanem a beállításból.
        var configuration = new OpenIdConnectConfiguration
        {
            Issuer = _issuer,
            JsonWebKeySet = keySet,
        };

        foreach (var signingKey in keySet.GetSigningKeys())
        {
            configuration.SigningKeys.Add(signingKey);
        }

        if (configuration.SigningKeys.Count == 0)
        {
            throw new InvalidOperationException(
                $"A JWKS válasz nem tartalmazott használható aláíró kulcsot: {address}");
        }

        return configuration;
    }
}
