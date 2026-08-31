namespace Flexio.Domain.Common;

/// <summary>
/// Túl sok kérés ugyanattól a felhasználótól. A válasz soha nem árul el, hogy
/// a kvóta felhasználóhoz vagy IP-hez kötött - csak azt, hogy várni kell.
/// </summary>
public sealed class RateLimitedException : FlexioException
{
    public RateLimitedException(string message = "Túl sok kérés. Próbáld újra később.")
        : base(ErrorCode.RateLimited, message)
    {
    }
}
