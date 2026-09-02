# syntax=docker/dockerfile:1

# A build kontextus a repo gyökere (render.yaml: dockerContext: .).
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY backend/global.json backend/Directory.Build.props backend/Directory.Packages.props ./backend/
COPY backend/src/Flexio.Domain/Flexio.Domain.csproj backend/src/Flexio.Domain/
COPY backend/src/Flexio.Application/Flexio.Application.csproj backend/src/Flexio.Application/
COPY backend/src/Flexio.Infrastructure/Flexio.Infrastructure.csproj backend/src/Flexio.Infrastructure/
COPY backend/src/Flexio.Api/Flexio.Api.csproj backend/src/Flexio.Api/
RUN dotnet restore backend/src/Flexio.Api/Flexio.Api.csproj

COPY backend/src/ backend/src/
COPY assets/food_catalog_hu.json assets/
RUN dotnet publish backend/src/Flexio.Api/Flexio.Api.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish \
    -p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

ENV ASPNETCORE_HTTP_PORTS=8080 \
    DOTNET_EnableDiagnostics=0

COPY --from=build /app/publish ./
COPY --from=build /src/assets/food_catalog_hu.json ./assets/

USER $APP_UID

ENTRYPOINT ["dotnet", "Flexio.Api.dll"]
