using System.Net;
using System.Net.Http.Json;

namespace Flexio.IntegrationTests.Jobs;

[Collection(FlexioApiCollection.Name)]
public sealed class InternalJobEndpointTests
{
    private readonly FlexioApiFactory _factory;

    public InternalJobEndpointTests(FlexioApiFactory factory)
    {
        _factory = factory;
    }

    [Fact]
    public async Task Missing_secret_is_rejected()
    {
        using var client = _factory.CreateClient();
        using var response = await client.PostAsync("/internal/jobs/seed-foods", null);
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Valid_secret_accepts_seed_job()
    {
        using var client = _factory.CreateClient();
        using var request = new HttpRequestMessage(HttpMethod.Post, "/internal/jobs/seed-foods");
        request.Headers.Add(Flexio.Api.Endpoints.InternalJobEndpoints.SecretHeaderName, "testing-only-job-secret-32b");

        using var response = await client.SendAsync(request);
        Assert.Equal(HttpStatusCode.Accepted, response.StatusCode);

        var body = await response.Content.ReadFromJsonAsync<JobAccepted>();
        Assert.NotNull(body);
        Assert.Equal("accepted", body.Status);
    }

    private sealed record JobAccepted(string Status, string Detail);
}
