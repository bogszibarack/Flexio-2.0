namespace Flexio.IntegrationTests;

/// <summary>
/// Egyetlen megosztott alkalmazás-példány az egész tesztszerelvényre.
/// A <see cref="FlexioApiFactory"/> statikus diagnosztikai figyelővel csatolja
/// el a belépési pontot, ezért több párhuzamosan induló példány versenyhelyzetbe
/// kerül ("The entry point exited without ever building an IHost"). Az API
/// állapotmentes, így a megosztás nem gyengíti a teszteket, csak gyorsítja.
/// </summary>
[CollectionDefinition(Name)]
public sealed class FlexioApiCollection : ICollectionFixture<FlexioApiFactory>
{
    public const string Name = "flexio-api";
}
