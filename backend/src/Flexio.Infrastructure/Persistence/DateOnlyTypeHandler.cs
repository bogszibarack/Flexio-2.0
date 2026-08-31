using System.Data;
using Dapper;

namespace Flexio.Infrastructure.Persistence;

/// <summary>
/// A Dapper alapból nem ismeri a <see cref="DateOnly"/> típust. Egyszer, a
/// perzisztencia regisztrációjakor kötjük be.
/// </summary>
internal sealed class DateOnlyTypeHandler : SqlMapper.TypeHandler<DateOnly>
{
    public override void SetValue(IDbDataParameter parameter, DateOnly value)
    {
        parameter.DbType = DbType.Date;
        parameter.Value = value.ToDateTime(TimeOnly.MinValue);
    }

    public override DateOnly Parse(object value) => value switch
    {
        DateOnly dateOnly => dateOnly,
        DateTime dateTime => DateOnly.FromDateTime(dateTime),
        DateTimeOffset dateTimeOffset => DateOnly.FromDateTime(dateTimeOffset.UtcDateTime),
        _ => DateOnly.FromDateTime(Convert.ToDateTime(value)),
    };
}
