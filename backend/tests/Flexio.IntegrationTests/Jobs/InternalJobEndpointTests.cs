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
    public async Task Valid_secret_without_jobs_db_returns_service_unavailable_for_seed()
    {
        using var client = _factory.CreateClient();
        using var request = new HttpRequestMessage(HttpMethod.Post, "/internal/jobs/seed-foods");
        request.Headers.Add(Flexio.Api.Endpoints.InternalJobEndpoints.SecretHeaderName, "testing-only-job-secret-32b");

        using var response = await client.SendAsync(request);
        Assert.Equal(HttpStatusCode.ServiceUnavailable, response.StatusCode);
    }

    [Fact]
    public async Task Valid_secret_accepts_off_import_when_jobs_db_missing_returns_unavailable()
    {
        using var client = _factory.CreateClient();
        using var request = new HttpRequestMessage(HttpMethod.Post, "/internal/jobs/import-off");
        request.Headers.Add(Flexio.Api.Endpoints.InternalJobEndpoints.SecretHeaderName, "testing-only-job-secret-32b");

        using var response = await client.SendAsync(request);
        Assert.Equal(HttpStatusCode.ServiceUnavailable, response.StatusCode);
    }
}
