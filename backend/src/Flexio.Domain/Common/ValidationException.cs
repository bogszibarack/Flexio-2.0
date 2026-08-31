using System.Collections.ObjectModel;

namespace Flexio.Domain.Common;

/// <summary>
/// Érvénytelen bemenet. A kérés széléről (DTO-validáció) és a domain
/// invariánsokból is jöhet.
/// </summary>
public sealed class ValidationException : FlexioException
{
    private static readonly IReadOnlyDictionary<string, string[]> Empty =
        new ReadOnlyDictionary<string, string[]>(new Dictionary<string, string[]>(StringComparer.Ordinal));

    public ValidationException(string message)
        : base(ErrorCode.ValidationFailed, message)
    {
        Failures = Empty;
    }

    public ValidationException(string message, IDictionary<string, string[]> failures)
        : base(ErrorCode.ValidationFailed, message)
    {
        ArgumentNullException.ThrowIfNull(failures);
        Failures = new ReadOnlyDictionary<string, string[]>(
            new Dictionary<string, string[]>(failures, StringComparer.Ordinal));
    }

    /// <summary>Mezőnév -> hibaüzenetek, a ProblemDetails "errors" kiterjesztésébe kerül.</summary>
    public IReadOnlyDictionary<string, string[]> Failures { get; }
}
