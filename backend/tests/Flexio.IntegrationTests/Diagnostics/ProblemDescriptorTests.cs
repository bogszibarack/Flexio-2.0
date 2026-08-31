using Flexio.Api.Diagnostics;
using Flexio.Domain.Common;
using Microsoft.AspNetCore.Http;

namespace Flexio.IntegrationTests.Diagnostics;

/// <summary>
/// A kivétel -> HTTP leképezés szabályai. Az Api szerelvény belső típusát
/// teszteli közvetlenül, mert a szabály HTTP-kérés nélkül is ellenőrizhető.
/// </summary>
public sealed class ProblemDescriptorTests
{
    [Fact]
    public void Validation_failure_maps_to_400_and_keeps_the_field_errors()
    {
        var failures = new Dictionary<string, string[]>(StringComparer.Ordinal)
        {
            ["quality"] = ["Az érték 1 és 5 között lehet."],
        };

        var descriptor = ProblemDescriptor.For(new ValidationException("Érvénytelen kérés.", failures));

        Assert.Equal(StatusCodes.Status400BadRequest, descriptor.StatusCode);
        Assert.Equal(ErrorCode.ValidationFailed, descriptor.ErrorCode);
        Assert.Single(descriptor.Failures);
        Assert.False(descriptor.IsUnexpected);
    }

    [Fact]
    public void Not_found_detail_stays_free_of_resource_identifiers()
    {
        // Aranyérték: ha valaki később azonosítót ír az üzenetbe, ez a teszt bukik.
        // Az idegen és a nem létező erőforrás válasza csak így marad azonos.
        var descriptor = ProblemDescriptor.For(new NotFoundException("naplóbejegyzés"));

        Assert.Equal(StatusCodes.Status404NotFound, descriptor.StatusCode);
        Assert.Equal("A kért erőforrás nem található: naplóbejegyzés.", descriptor.Detail);
    }

    [Fact]
    public void External_service_failure_hides_the_provider_message()
    {
        var descriptor = ProblemDescriptor.For(
            new ExternalServiceException("Gemini", "quota exceeded for project 12345"));

        Assert.Equal(StatusCodes.Status502BadGateway, descriptor.StatusCode);
        Assert.DoesNotContain("quota", descriptor.Detail, StringComparison.OrdinalIgnoreCase);
        Assert.DoesNotContain("12345", descriptor.Detail, StringComparison.Ordinal);
    }

    [Fact]
    public void Unexpected_exception_maps_to_500_without_leaking_internals()
    {
        var descriptor = ProblemDescriptor.For(
            new InvalidOperationException("Npgsql connection string is invalid"));

        Assert.Equal(StatusCodes.Status500InternalServerError, descriptor.StatusCode);
        Assert.Equal(ErrorCode.Unknown, descriptor.ErrorCode);
        Assert.DoesNotContain("Npgsql", descriptor.Detail, StringComparison.Ordinal);
        Assert.True(descriptor.IsUnexpected);
    }

    [Theory]
    [InlineData(typeof(UnauthorizedException), StatusCodes.Status401Unauthorized)]
    [InlineData(typeof(ForbiddenException), StatusCodes.Status403Forbidden)]
    [InlineData(typeof(ConflictException), StatusCodes.Status409Conflict)]
    public void Authorization_and_conflict_failures_map_to_their_status_codes(
        Type exceptionType,
        int expectedStatusCode)
    {
        var exception = (Exception)Activator.CreateInstance(exceptionType, "teszt")!;

        var descriptor = ProblemDescriptor.For(exception);

        Assert.Equal(expectedStatusCode, descriptor.StatusCode);
        Assert.False(descriptor.IsUnexpected);
    }
}
