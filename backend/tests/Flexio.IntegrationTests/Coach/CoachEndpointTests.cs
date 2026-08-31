using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;

namespace Flexio.IntegrationTests.Coach;

[Collection(FlexioApiCollection.Name)]
public sealed class CoachEndpointTests
{
    private readonly FlexioApiFactory _factory;

    public CoachEndpointTests(FlexioApiFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Authenticated_coach_request_returns_fallback_without_gemini_key()
    {
        using var client = CreateClient(Guid.NewGuid());
        using var response = await client.PostAsJsonAsync("/api/v1/coach", new
        {
            snapshot = new { kind = "sleep", headline = "Aludj többet" },
            fallback = new
            {
                prose = "Aludj 30 perccel többet.",
                pros = "",
                cons = "",
            },
        });

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var payload = await response.Content.ReadFromJsonAsync<CoachPayload>();
        Assert.NotNull(payload);
        Assert.Equal("Aludj 30 perccel többet.", payload.Prose);
    }

    [Fact]
    public async Task Missing_token_is_rejected()
    {
        using var client = _factory.CreateClient();
        using var response = await client.PostAsJsonAsync("/api/v1/coach", new
        {
            snapshot = new { kind = "workout" },
            fallback = new { prose = "x", pros = "", cons = "" },
        });

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Invalid_kind_returns_validation_problem()
    {
        using var client = CreateClient(Guid.NewGuid());
        using var response = await client.PostAsJsonAsync("/api/v1/coach", new
        {
            snapshot = new { kind = "chatbot" },
            fallback = new { prose = "helyi", pros = "", cons = "" },
        });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var body = await response.Content.ReadAsStringAsync();
        using var document = JsonDocument.Parse(body);
        Assert.Equal("ValidationFailed", document.RootElement.GetProperty("errorCode").GetString());
    }

    [Fact]
    public async Task Oversized_body_is_rejected()
    {
        using var client = CreateClient(Guid.NewGuid());
        var huge = new string('x', 9_000);
        var json =
            "{\"snapshot\":{\"kind\":\"sleep\",\"note\":\"" + huge +
            "\"},\"fallback\":{\"prose\":\"helyi\",\"pros\":\"\",\"cons\":\"\"}}";
        using var content = new StringContent(json, Encoding.UTF8, "application/json");

        using var response = await client.PostAsync("/api/v1/coach", content);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    private HttpClient CreateClient(Guid userId)
    {
        var client = _factory.CreateClient();
        client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", TestTokens.ForUser(_factory, userId));
        return client;
    }

    private sealed record CoachPayload(string Prose, string Pros, string Cons);
}
