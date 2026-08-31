using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Flexio.IntegrationTests.Authentication;

/// <summary>
/// A hitelesítés kapuja. Minden eset a tokenen dől el: a kliens sosem küld
/// felhasználó-azonosítót a kérés törzsében.
/// </summary>
[Collection(FlexioApiCollection.Name)]
public sealed class AuthenticationTests
{
    private readonly FlexioApiFactory _factory;

    public AuthenticationTests(FlexioApiFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Valid_token_identifies_the_user_from_the_sub_claim()
    {
        var expectedUserId = Guid.NewGuid();
        using var client = CreateClient(TestTokens.ForUser(_factory, expectedUserId));

        using var response = await client.GetAsync("/api/v1/me");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var payload = await response.Content.ReadFromJsonAsync<CurrentUserPayload>();
        Assert.NotNull(payload);
        Assert.Equal(expectedUserId, payload.UserId);
    }

    [Fact]
    public async Task Missing_token_is_rejected_with_a_problem_details_body()
    {
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync("/api/v1/me");
        var body = await response.Content.ReadAsStringAsync();

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);

        using var document = JsonDocument.Parse(body);
        Assert.Equal("Unauthorized", document.RootElement.GetProperty("errorCode").GetString());
    }

    [Fact]
    public async Task Expired_token_is_rejected()
    {
        using var client = CreateClient(TestTokens.Expired(_factory, Guid.NewGuid()));

        using var response = await client.GetAsync("/api/v1/me");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Token_from_a_foreign_issuer_is_rejected_even_with_a_valid_signature()
    {
        using var client = CreateClient(TestTokens.FromForeignIssuer(_factory, Guid.NewGuid()));

        using var response = await client.GetAsync("/api/v1/me");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Token_for_another_audience_is_rejected()
    {
        using var client = CreateClient(TestTokens.WithForeignAudience(_factory, Guid.NewGuid()));

        using var response = await client.GetAsync("/api/v1/me");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Token_without_a_subject_claim_cannot_reach_user_data()
    {
        // Az aláírás érvényes, tehát a hitelesítés átmegy, de felhasználó nélkül
        // egyetlen lekérdezés sem indulhat el.
        using var client = CreateClient(TestTokens.WithoutSubject(_factory));

        using var response = await client.GetAsync("/api/v1/me");
        var body = await response.Content.ReadAsStringAsync();

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);

        using var document = JsonDocument.Parse(body);
        Assert.Equal("Unauthorized", document.RootElement.GetProperty("errorCode").GetString());
    }

    [Fact]
    public async Task Health_endpoints_stay_public_despite_the_secure_default()
    {
        using var client = _factory.CreateClient();

        using var response = await client.GetAsync("/health/live");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    private HttpClient CreateClient(string accessToken)
    {
        var client = _factory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

        return client;
    }

    private sealed record CurrentUserPayload(
        [property: JsonPropertyName("user_id")] Guid UserId);
}
