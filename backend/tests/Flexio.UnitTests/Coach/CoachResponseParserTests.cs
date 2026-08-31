using Flexio.Application.Coach;

namespace Flexio.UnitTests.Coach;

public sealed class CoachResponseParserTests
{
    [Fact]
    public void Parse_reads_json_embedded_in_prose()
    {
        var fallback = new CoachCopy("helyi", "helyi előny", "helyi hátrány");
        var result = CoachResponseParser.Parse(
            """
            Itt a válasz:
            {"prose":"Emeld 5%-kal.","pros":"Jól aludtál.","cons":"Az RPE magas."}
            """,
            fallback);

        Assert.Equal("Emeld 5%-kal.", result.Prose);
        Assert.Equal("Jól aludtál.", result.Pros);
        Assert.Equal("Az RPE magas.", result.Cons);
    }

    [Fact]
    public void Parse_falls_back_when_json_is_missing()
    {
        var fallback = new CoachCopy("helyi", "", "");
        var result = CoachResponseParser.Parse("nincs json", fallback);
        Assert.Equal(fallback, result);
    }

    [Fact]
    public void Parse_keeps_fallback_prose_when_model_prose_is_empty()
    {
        var fallback = new CoachCopy("helyi szöveg", "a", "b");
        var result = CoachResponseParser.Parse(
            """{"prose":"  ","pros":"x","cons":"y"}""",
            fallback);

        Assert.Equal("helyi szöveg", result.Prose);
        Assert.Equal("x", result.Pros);
        Assert.Equal("y", result.Cons);
    }
}
