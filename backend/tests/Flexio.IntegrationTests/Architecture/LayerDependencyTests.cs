using NetArchTest.Rules;

namespace Flexio.IntegrationTests.Architecture;

/// <summary>
/// Rétegfüggőségi szabályok: a Domain és az Application soha nem hivatkozhat
/// infrastruktúrára. Ha ezt egy PR megsérti, a build elbukik, mielőtt a hiba
/// az éles kódba kerülne.
/// </summary>
public sealed class LayerDependencyTests
{
    [Fact]
    public void Domain_does_not_depend_on_outer_layers()
    {
        var result = Types.InAssembly(typeof(Flexio.Domain.Identity.UserId).Assembly)
            .ShouldNot()
            .HaveDependencyOnAny(
                "Flexio.Application",
                "Flexio.Infrastructure",
                "Flexio.Api",
                "Microsoft.AspNetCore",
                "Npgsql",
                "Dapper")
            .GetResult();

        Assert.True(result.IsSuccessful, FormatFailures(result));
    }

    [Fact]
    public void Application_does_not_depend_on_infrastructure_or_api()
    {
        var result = Types.InAssembly(typeof(Flexio.Application.Abstractions.IUnitOfWork).Assembly)
            .ShouldNot()
            .HaveDependencyOnAny(
                "Flexio.Infrastructure",
                "Flexio.Api",
                "Microsoft.AspNetCore",
                "Npgsql",
                "Dapper")
            .GetResult();

        Assert.True(result.IsSuccessful, FormatFailures(result));
    }

    private static string FormatFailures(TestResult result)
    {
        if (result.FailingTypeNames is null || result.FailingTypeNames.Count == 0)
        {
            return "Ismeretlen architektúra-szabálysértés.";
        }

        return "Rétegsértés: " + string.Join(", ", result.FailingTypeNames);
    }
}
