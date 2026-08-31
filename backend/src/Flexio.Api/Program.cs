using System.Globalization;
using Flexio.Api;
using Flexio.Api.Endpoints;
using Flexio.Application;
using Flexio.Infrastructure;
using Serilog;
using Serilog.Formatting.Compact;

// Bootstrap logger: a konfiguráció beolvasása előtt keletkező indulási hibák se
// veszhessenek el nyom nélkül.
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console(new CompactJsonFormatter())
    .CreateBootstrapLogger();

try
{
    var builder = WebApplication.CreateBuilder(args);

    ConfigurePlatformPort(builder);

    builder.Services.AddSerilog((services, loggerConfiguration) =>
    {
        loggerConfiguration
            .ReadFrom.Configuration(builder.Configuration)
            .ReadFrom.Services(services)
            .Enrich.FromLogContext();

        // Fejlesztés közben olvasható szöveg, éles környezetben struktúrált
        // JSON, hogy a naplógyűjtő értelmezni tudja.
        if (builder.Environment.IsDevelopment())
        {
            loggerConfiguration.WriteTo.Console();
        }
        else
        {
            loggerConfiguration.WriteTo.Console(new CompactJsonFormatter());
        }
    });

    // A composition root: ez az egyetlen hely, ahol a rétegek találkoznak.
    builder.Services
        .AddApplicationLayer()
        .AddInfrastructureLayer(builder.Configuration)
        .AddApiLayer(builder.Configuration);

    var app = builder.Build();

    app.UseApiPipeline();
    app.MapHealthEndpoints();
    app.MapApiEndpoints();
    app.MapInternalJobEndpoints();

    await app.RunAsync();
    return 0;
}
catch (Exception exception) when (!IsHostControlSignal(exception))
{
    Log.Fatal(exception, "A Flexio API nem indult el.");
    return 1;
}
finally
{
    await Log.CloseAndFlushAsync();
}

/// <summary>
/// Az integrációs tesztek gazdája és az EF tooling szándékos kivétellel állítja
/// le a hostot, miután felépítette. Ezt nem szabad indulási hibaként elnyelni,
/// különben a tesztek nem tudják példányosítani az alkalmazást.
/// </summary>
static bool IsHostControlSignal(Exception exception) =>
    exception is HostAbortedException || exception.GetType().Name == "StopTheHostException";

/// <summary>
/// A Render (és több PaaS) a PORT környezeti változóban adja meg a hallgatandó
/// portot, az ASP.NET Core viszont csak az ASPNETCORE_* változókat olvassa.
/// Ezért itt fordítjuk le, és hibás értéknél azonnal megállunk, hogy ne egy
/// néma "nem érhető el" hibaként jelentkezzen éles környezetben.
/// </summary>
static void ConfigurePlatformPort(WebApplicationBuilder builder)
{
    var rawPort = Environment.GetEnvironmentVariable("PORT");
    if (string.IsNullOrWhiteSpace(rawPort))
    {
        return;
    }

    if (!int.TryParse(rawPort, CultureInfo.InvariantCulture, out var port) || port is < 1 or > 65535)
    {
        throw new InvalidOperationException(
            $"A PORT környezeti változó értéke nem érvényes portszám: '{rawPort}'.");
    }

    builder.WebHost.UseUrls($"http://0.0.0.0:{port}");
}

/// <summary>
/// A felső szintű utasításokból generált belépési pont alapból internal, az
/// integrációs tesztek gazdájának (WebApplicationFactory) viszont publikus típus
/// kell. A generált deklaráció szándékosan partial, ezért itt csak kiegészítjük.
/// </summary>
public partial class Program;
