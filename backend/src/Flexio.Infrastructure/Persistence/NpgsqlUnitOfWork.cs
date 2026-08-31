using System.Data;
using Flexio.Application.Abstractions;
using Flexio.Domain.Identity;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace Flexio.Infrastructure.Persistence;

/// <summary>
/// Tranzakció-kezelő a kérés-útvonalhoz. Minden scope-ban:
/// <list type="number">
///   <item>új kapcsolat a <c>flexio_api</c> poolból,</item>
///   <item>explicit tranzakció (olvasásnál is),</item>
///   <item>tranzakció-lokális <c>app.current_user_id</c> beállítás,</item>
///   <item>a <see cref="DbSession"/> feltöltése, hogy a repository-k ne
///   kaphassanak "kontextus nélküli" kapcsolatot.</item>
/// </list>
/// </summary>
internal sealed class NpgsqlUnitOfWork : IUnitOfWork
{
    private readonly NpgsqlDataSource _dataSource;
    private readonly DbSession _session;
    private readonly ILogger<NpgsqlUnitOfWork> _logger;

    public NpgsqlUnitOfWork(
        [FromKeyedServices(PostgresDataSourceKeys.Api)] NpgsqlDataSource dataSource,
        DbSession session,
        ILogger<NpgsqlUnitOfWork> logger)
    {
        _dataSource = dataSource;
        _session = session;
        _logger = logger;
    }

    public Task<IUnitOfWorkScope> BeginWriteAsync(UserId userId, CancellationToken cancellationToken)
        => BeginAsync(userId, readOnly: false, cancellationToken);

    public Task<IUnitOfWorkScope> BeginReadAsync(UserId userId, CancellationToken cancellationToken)
        => BeginAsync(userId, readOnly: true, cancellationToken);

    private async Task<IUnitOfWorkScope> BeginAsync(
        UserId userId,
        bool readOnly,
        CancellationToken cancellationToken)
    {
        if (!userId.IsPresent)
        {
            throw new ArgumentException(
                "A felhasználói kontextus nélkül nem nyitható adatbázis-tranzakció.",
                nameof(userId));
        }

        if (_session.IsActive)
        {
            throw new InvalidOperationException(
                "Egy kérésben egyszerre csak egy adatbázis-tranzakció lehet nyitva.");
        }

        var connection = await _dataSource.OpenConnectionAsync(cancellationToken).ConfigureAwait(false);
        NpgsqlTransaction? transaction = null;

        try
        {
            // Az olvasó tranzakciót a szerver is elutasítja írásra. Így egy
            // véletlenül mellékhatásos repository-metódus nem a code review-n,
            // hanem a Postgres-en bukik el.
            transaction = await connection
                .BeginTransactionAsync(
                    readOnly ? IsolationLevel.RepeatableRead : IsolationLevel.ReadCommitted,
                    cancellationToken)
                .ConfigureAwait(false);

            if (readOnly)
            {
                await using var readOnlyCommand = new NpgsqlCommand(
                    "set transaction read only",
                    connection,
                    transaction);
                await readOnlyCommand.ExecuteNonQueryAsync(cancellationToken).ConfigureAwait(false);
            }

            await ApplyUserContextAsync(connection, transaction, userId, cancellationToken)
                .ConfigureAwait(false);

            _session.Attach(connection, transaction, userId);

            return new NpgsqlUnitOfWorkScope(_session, connection, transaction, _logger);
        }
        catch
        {
            if (transaction is not null)
            {
                await transaction.DisposeAsync().ConfigureAwait(false);
            }

            await connection.DisposeAsync().ConfigureAwait(false);
            throw;
        }
    }

    /// <summary>
    /// A <c>true</c> harmadik argumentum a beállítást a tranzakció végére
    /// korlátozza. Statement-szintű (false) beállítás a következő utasítás előtt
    /// eldobódna, és a lekérdezés kontextus nélkül, csendben üres eredménnyel
    /// futna le - ez a legveszélyesebb hiba, amit el lehet követni ebben a
    /// rétegben.
    /// </summary>
    private static async Task ApplyUserContextAsync(
        NpgsqlConnection connection,
        NpgsqlTransaction transaction,
        UserId userId,
        CancellationToken cancellationToken)
    {
        await using var command = new NpgsqlCommand(
            "select set_config('app.current_user_id', @userId, true)",
            connection,
            transaction);
        command.Parameters.AddWithValue("userId", userId.Value.ToString());
        await command.ExecuteNonQueryAsync(cancellationToken).ConfigureAwait(false);
    }
}
