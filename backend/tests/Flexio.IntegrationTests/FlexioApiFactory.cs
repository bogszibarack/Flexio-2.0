using System.Security.Cryptography;
using Flexio.Api.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;

namespace Flexio.IntegrationTests;

/// <summary>
/// Az alkalmazás tesztpéldánya. A környezet szándékosan nem Development, hogy a
/// tesztek az éles pipeline-t járják be. A tokenaláíró kulcs helyben generált:
/// a teszt nem hív ki a hálózatra a Supabase JWKS végpontjára.
/// </summary>
public sealed class FlexioApiFactory : WebApplicationFactory<Program>
{
    public const string ProjectUrl = "https://teszt.supabase.co";
    public const string Issuer = ProjectUrl + "/auth/v1";
    public const string Audience = "authenticated";

    private readonly RSA _signingRsa = RSA.Create(2048);

    public FlexioApiFactory()
    {
        SigningKey = new RsaSecurityKey(_signingRsa) { KeyId = "teszt-kulcs" };
    }

    /// <summary>Ezzel a kulccsal írja alá a teszt a tokeneket.</summary>
    public RsaSecurityKey SigningKey { get; }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.UseEnvironment("Testing");
        builder.UseSetting("SupabaseAuth:ProjectUrl", ProjectUrl);
        // A auth/health teszteknek nincs szüksége élő Postgresre. A connection
        // string csak a Options validációnak kell; a probe ki van kapcsolva.
        builder.UseSetting(
            "Postgres:ApiConnectionString",
            "Host=127.0.0.1;Port=1;Database=flexio_unused;Username=flexio_api;Password=unused");
        builder.UseSetting("Postgres:StartupProbeAttempts", "0");
        builder.UseSetting("InternalJobs:SharedSecret", "testing-only-job-secret-32b");

        builder.ConfigureTestServices(services =>
        {
            // A JWKS letöltése helyett egy statikus konfiguráció adja a
            // nyilvános kulcsot, így a validáció teljes útja tesztelt, de
            // hálózat nélkül.
            services.Configure<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme, options =>
            {
                var configuration = new OpenIdConnectConfiguration { Issuer = Issuer };
                configuration.SigningKeys.Add(SigningKey);

                options.ConfigurationManager =
                    new StaticConfigurationManager<OpenIdConnectConfiguration>(configuration);
            });
        });
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);

        if (disposing)
        {
            _signingRsa.Dispose();
        }
    }
}
