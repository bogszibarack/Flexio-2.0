using Flexio.Application.Abstractions;
using Flexio.Infrastructure.Configuration;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;

namespace Flexio.Api.Authentication;

internal static class AuthenticationServiceCollectionExtensions
{
    internal static IServiceCollection AddFlexioAuthentication(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddValidatedOptions<SupabaseAuthOptions>(configuration, SupabaseAuthOptions.SectionName);

        services.AddHttpContextAccessor();
        services.AddScoped<ICurrentUserAccessor, HttpContextCurrentUserAccessor>();

        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer();
        services.ConfigureOptions<SupabaseJwtBearerConfiguration>();

        services.AddAuthorizationBuilder()
            // Biztonságos alapállapot: aminek nincs saját szabálya, az
            // hitelesítést kér. A nyilvános kivételeket (health, séma) explicit
            // AllowAnonymous jelöli, így egy új endpoint nem lesz véletlenül nyílt.
            .SetFallbackPolicy(new AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser()
                .Build());

        return services;
    }
}
