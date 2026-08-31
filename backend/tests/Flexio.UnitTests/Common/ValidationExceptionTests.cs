using Flexio.Domain.Common;

namespace Flexio.UnitTests.Common;

public sealed class ValidationExceptionTests
{
    [Fact]
    public void Failures_default_to_an_empty_collection()
    {
        var exception = new ValidationException("Érvénytelen kérés.");

        Assert.Empty(exception.Failures);
        Assert.Equal(ErrorCode.ValidationFailed, exception.ErrorCode);
    }

    [Fact]
    public void Failures_are_copied_so_the_caller_cannot_mutate_them_afterwards()
    {
        var failures = new Dictionary<string, string[]>(StringComparer.Ordinal)
        {
            ["bedtime"] = ["A lefekvés ideje kötelező."],
        };

        var exception = new ValidationException("Érvénytelen kérés.", failures);
        failures["wakeTime"] = ["Utólag hozzáadott hiba."];

        Assert.Single(exception.Failures);
        Assert.True(exception.Failures.ContainsKey("bedtime"));
    }

    [Fact]
    public void Null_failures_are_rejected_instead_of_silently_ignored()
    {
        Assert.Throws<ArgumentNullException>(() => new ValidationException("Érvénytelen kérés.", null!));
    }
}
