namespace Flexio.Domain.Common;

/// <summary>
/// Gépi feldolgozásra szánt, stabil hibakód. A kliens erre ágazhat el; a
/// szöveges üzenet változhat, a kód nem.
/// </summary>
public enum ErrorCode
{
    Unknown = 0,
    ValidationFailed = 1,
    Unauthorized = 2,
    Forbidden = 3,
    NotFound = 4,
    Conflict = 5,
    RateLimited = 6,
    ExternalServiceFailed = 7,
}
