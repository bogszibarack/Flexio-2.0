using Flexio.Domain.Identity;

namespace Flexio.UnitTests.Identity;

public sealed class UserIdTests
{
    [Fact]
    public void From_rejects_the_empty_guid()
    {
        var exception = Assert.Throws<ArgumentException>(() => UserId.From(Guid.Empty));

        Assert.Equal("value", exception.ParamName);
    }

    [Fact]
    public void Default_value_is_not_usable_for_queries()
    {
        Assert.False(default(UserId).IsPresent);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData("nem-guid")]
    [InlineData("00000000-0000-0000-0000-000000000000")]
    public void TryParse_rejects_invalid_input(string? raw)
    {
        Assert.False(UserId.TryParse(raw, out var userId));
        Assert.False(userId.IsPresent);
    }

    [Fact]
    public void TryParse_accepts_a_valid_guid()
    {
        var expected = Guid.NewGuid();

        Assert.True(UserId.TryParse(expected.ToString(), out var userId));

        Assert.Equal(expected, userId.Value);
        Assert.True(userId.IsPresent);
    }

    [Fact]
    public void Equality_compares_by_value()
    {
        var value = Guid.NewGuid();

        Assert.Equal(UserId.From(value), UserId.From(value));
        Assert.NotEqual(UserId.From(value), UserId.From(Guid.NewGuid()));
    }
}
