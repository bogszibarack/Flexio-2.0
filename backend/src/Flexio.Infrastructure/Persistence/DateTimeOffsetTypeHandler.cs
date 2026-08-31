using System.Data;
using Dapper;

namespace Flexio.Infrastructure.Persistence;

/// <summary>
/// Npgsql néha <see cref="DateTime"/>-ként adja a timestamptz-t. A DTO-k
/// <see cref="DateTimeOffset"/>-et várnak; ez a handler a két forma között fordít.
/// </summary>
internal sealed class DateTimeOffsetTypeHandler : SqlMapper.TypeHandler<DateTimeOffset>
{
    public override void SetValue(IDbDataParameter parameter, DateTimeOffset value)
    {
        parameter.Value = value.UtcDateTime;
        parameter.DbType = DbType.DateTime;
    }

    public override DateTimeOffset Parse(object value) => value switch
    {
        DateTimeOffset offset => offset,
        DateTime dateTime when dateTime.Kind == DateTimeKind.Unspecified
            => new DateTimeOffset(DateTime.SpecifyKind(dateTime, DateTimeKind.Utc)),
        DateTime dateTime => new DateTimeOffset(dateTime),
        _ => DateTimeOffset.Parse(Convert.ToString(value)!),
    };
}

internal sealed class NullableDateTimeOffsetTypeHandler : SqlMapper.TypeHandler<DateTimeOffset?>
{
    public override void SetValue(IDbDataParameter parameter, DateTimeOffset? value)
    {
        parameter.Value = value?.UtcDateTime ?? (object)DBNull.Value;
        parameter.DbType = DbType.DateTime;
    }

    public override DateTimeOffset? Parse(object value)
    {
        if (value is null or DBNull)
        {
            return null;
        }

        return value switch
        {
            DateTimeOffset offset => offset,
            DateTime dateTime when dateTime.Kind == DateTimeKind.Unspecified
                => new DateTimeOffset(DateTime.SpecifyKind(dateTime, DateTimeKind.Utc)),
            DateTime dateTime => new DateTimeOffset(dateTime),
            _ => DateTimeOffset.Parse(Convert.ToString(value)!),
        };
    }
}
