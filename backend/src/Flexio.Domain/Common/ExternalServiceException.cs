namespace Flexio.Domain.Common;

/// <summary>
/// Külső szolgáltatás (Gemini, Open Food Facts, Supabase Admin API) hibája.
/// A szolgáltatás nevét naplózzuk, de a kliens felé nem részletezzük.
/// </summary>
public sealed class ExternalServiceException : FlexioException
{
    public ExternalServiceException(string serviceName, string message, Exception? innerException = null)
        : base(ErrorCode.ExternalServiceFailed, message, innerException)
    {
        ServiceName = serviceName;
    }

    public string ServiceName { get; }
}
