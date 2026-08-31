using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;

namespace Flexio.IntegrationTests.Diagnostics;

/// <summary>
/// A hibaburkolat egységessége: a kliensnek egyetlen hibaformátumot kell
/// ismernie, akkor is, ha a hiba nem kivételből, hanem a middleware-ből jön.
/// </summary>
[Collection(FlexioApiCollection.Name)]
public sealed class ProblemDetailsResponseTests
{
    private readonly FlexioApiFactory _factory;

    public ProblemDetailsResponseTests(FlexioApiFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Unmatched_route_returns_a_problem_details_body()
    {
        using var client = CreateAuthenticatedClient();

        using var response = await client.GetAsync("/api/v1/nincs-ilyen-utvonal");
        var body = await response.Content.ReadAsStringAsync();

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
        Assert.Equal("application/problem+json", response.Content.Headers.ContentType?.MediaType);

        using var document = JsonDocument.Parse(body);
        var root = document.RootElement;

        Assert.Equal("NotFound", root.GetProperty("errorCode").GetString());
        Assert.Equal(404, root.GetProperty("status").GetInt32());
        Assert.False(string.IsNullOrWhiteSpace(root.GetProperty("traceId").GetString()));
    }

    [Fact]
    public async Task Unknown_paths_stay_invisible_to_unauthenticated_callers()
    {
        // Szándékos: hitelesítés nélkül nem derül ki, hogy egy útvonal létezik-e.
        // Ugyanaz az elv, mint az azonosítóknál - az ismeretlen és a védett
        // útvonal válasza megegyezik.
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync("/api/v1/nincs-ilyen-utvonal");
        var body = await response.Content.ReadAsStringAsync();

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);

        using var document = JsonDocument.Parse(body);
        Assert.Equal("Unauthorized", document.RootElement.GetProperty("errorCode").GetString());
    }

    [Fact]
    public async Task Health_probes_answer_only_to_get()
    {
        using var client = CreateAuthenticatedClient();

        using var request = new HttpRequestMessage(HttpMethod.Post, "/health/live");
        using var response = await client.SendAsync(request);
        var body = await response.Content.ReadAsStringAsync();

        Assert.Equal(HttpStatusCode.MethodNotAllowed, response.StatusCode);

        using var document = JsonDocument.Parse(body);
        Assert.True(document.RootElement.TryGetProperty("errorCode", out _));
    }

    private HttpClient CreateAuthenticatedClient()
    {
        var client = _factory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(
            "Bearer",
            TestTokens.ForUser(_factory, Guid.NewGuid()));

        return client;
    }
}
