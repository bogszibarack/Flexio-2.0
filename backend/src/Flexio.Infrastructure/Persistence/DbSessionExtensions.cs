using System.Data;
using System.Data.Common;
using Dapper;
using Flexio.Infrastructure.Persistence;
using Npgsql;

namespace Flexio.Infrastructure.Persistence;

/// <summary>
/// A repository-k közös belépési pontja a nyitott tranzakcióhoz. Ha nincs
/// scope, azonnal hibázik - így egy elfelejtett UnitOfWork nem csendben
/// üres eredményt ad.
/// </summary>
internal static class DbSessionExtensions
{
    internal static NpgsqlConnection RequireConnection(this DbSession session) => session.Connection;

    internal static NpgsqlTransaction RequireTransaction(this DbSession session) => session.Transaction;

    internal static CommandDefinition Command(
        this DbSession session,
        string sql,
        object? parameters = null,
        CancellationToken cancellationToken = default) =>
        new(
            sql,
            parameters,
            transaction: session.Transaction,
            cancellationToken: cancellationToken);
}
