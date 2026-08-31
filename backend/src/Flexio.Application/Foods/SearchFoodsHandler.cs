using Flexio.Application.Abstractions;
using Flexio.Domain.Common;

namespace Flexio.Application.Foods;

public sealed class SearchFoodsHandler
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICurrentUserAccessor _currentUser;
    private readonly IFoodCatalogRepository _foods;

    public SearchFoodsHandler(
        IUnitOfWork unitOfWork,
        ICurrentUserAccessor currentUser,
        IFoodCatalogRepository foods)
    {
        _unitOfWork = unitOfWork;
        _currentUser = currentUser;
        _foods = foods;
    }

    public async Task<IReadOnlyList<FoodDto>> SearchAsync(
        string query,
        int limit,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(query))
        {
            return [];
        }

        if (limit is < 1 or > 100)
        {
            throw new ValidationException(
                "Érvénytelen keresési limit.",
                new Dictionary<string, string[]>
                {
                    ["limit"] = ["A limit 1 és 100 között lehet."],
                });
        }

        var userId = _currentUser.RequireUserId();
        await using var scope = await _unitOfWork
            .BeginReadAsync(userId, cancellationToken)
            .ConfigureAwait(false);

        var results = await _foods
            .SearchAsync(userId, query.Trim(), limit, cancellationToken)
            .ConfigureAwait(false);

        await scope.CommitAsync(cancellationToken).ConfigureAwait(false);
        return results;
    }

    public async Task<FoodDto?> ByBarcodeAsync(string barcode, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(barcode))
        {
            throw new ValidationException(
                "Érvénytelen vonalkód.",
                new Dictionary<string, string[]>
                {
                    ["barcode"] = ["A vonalkód megadása kötelező."],
                });
        }

        var userId = _currentUser.RequireUserId();
        await using var scope = await _unitOfWork
            .BeginReadAsync(userId, cancellationToken)
            .ConfigureAwait(false);

        var food = await _foods
            .FindByBarcodeAsync(userId, barcode.Trim(), cancellationToken)
            .ConfigureAwait(false);

        await scope.CommitAsync(cancellationToken).ConfigureAwait(false);
        return food;
    }

    public async Task LogMissAsync(string query, int resultCount, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(query))
        {
            return;
        }

        var userId = _currentUser.RequireUserId();
        await using var scope = await _unitOfWork
            .BeginWriteAsync(userId, cancellationToken)
            .ConfigureAwait(false);

        await _foods
            .LogSearchMissAsync(userId, query.Trim(), resultCount, cancellationToken)
            .ConfigureAwait(false);

        await scope.CommitAsync(cancellationToken).ConfigureAwait(false);
    }
}
