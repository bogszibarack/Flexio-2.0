namespace Flexio.Infrastructure.Jobs;

public sealed record JobRunResult(
    int Processed,
    int Errors,
    int RowsSeen = 0,
    int ElapsedSeconds = 0);
