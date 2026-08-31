using System.Diagnostics;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace Flexio.Api.Diagnostics;

/// <summary>
/// A hibák egyetlen kimeneti pontja: minden válasz RFC 9457 ProblemDetails.
/// A várt (<see cref="Flexio.Domain.Common.FlexioException"/>) és a váratlan
/// hibák másképp naplózódnak, de a kliens sosem kap stack trace-t vagy belső
/// részletet.
/// </summary>
internal sealed class GlobalExceptionHandler : IExceptionHandler
{
    private const string ProblemTypeBaseUri = "https://flexio.app/problems/";

    private readonly IProblemDetailsService _problemDetailsService;
    private readonly ILogger<GlobalExceptionHandler> _logger;

    public GlobalExceptionHandler(
        IProblemDetailsService problemDetailsService,
        ILogger<GlobalExceptionHandler> logger)
    {
        _problemDetailsService = problemDetailsService;
        _logger = logger;
    }

    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        // Ha a kliens szakította meg a kérést, nincs kinek válaszolni, és a
        // megszakítás nem hiba: ne szennyezzük vele a hibanaplót.
        if (httpContext.RequestAborted.IsCancellationRequested)
        {
            _logger.LogDebug("A kérést a kliens megszakította: {Path}", httpContext.Request.Path);
            return true;
        }

        var descriptor = ProblemDescriptor.For(exception);
        Log(descriptor, exception, httpContext);

        httpContext.Response.StatusCode = descriptor.StatusCode;

        var problemDetails = new ProblemDetails
        {
            Status = descriptor.StatusCode,
            Title = descriptor.Title,
            Detail = descriptor.Detail,
            Type = ProblemTypeBaseUri + descriptor.ErrorCode,
            Instance = httpContext.Request.Path,
        };

        problemDetails.Extensions["errorCode"] = descriptor.ErrorCode.ToString();
        problemDetails.Extensions["traceId"] = Activity.Current?.TraceId.ToString() ?? httpContext.TraceIdentifier;

        if (descriptor.Failures.Count > 0)
        {
            problemDetails.Extensions["errors"] = descriptor.Failures;
        }

        return await _problemDetailsService.TryWriteAsync(new ProblemDetailsContext
        {
            HttpContext = httpContext,
            Exception = exception,
            ProblemDetails = problemDetails,
        });
    }

    private void Log(ProblemDescriptor descriptor, Exception exception, HttpContext httpContext)
    {
        if (descriptor.IsUnexpected)
        {
            _logger.LogError(
                exception,
                "Váratlan hiba a {Method} {Path} kérésben.",
                httpContext.Request.Method,
                httpContext.Request.Path);
            return;
        }

        // A várt hibák nem hibaszintűek: a naplóban a kód és az útvonal elég,
        // a stack trace csak zajt adna.
        _logger.LogWarning(
            "Kezelt hiba ({ErrorCode}, HTTP {StatusCode}) a {Method} {Path} kérésben: {Reason}",
            descriptor.ErrorCode,
            descriptor.StatusCode,
            httpContext.Request.Method,
            httpContext.Request.Path,
            exception.Message);
    }
}
