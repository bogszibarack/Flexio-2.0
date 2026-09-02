# syntax=docker/dockerfile:1

# A build kontextus a backend/ mappa (render.yaml: dockerContext: backend).
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY global.json Directory.Build.props Directory.Packages.props ./
COPY src/Flexio.Domain/Flexio.Domain.csproj src/Flexio.Domain/
COPY src/Flexio.Application/Flexio.Application.csproj src/Flexio.Application/
COPY src/Flexio.Infrastructure/Flexio.Infrastructure.csproj src/Flexio.Infrastructure/
COPY src/Flexio.Api/Flexio.Api.csproj src/Flexio.Api/
RUN dotnet restore src/Flexio.Api/Flexio.Api.csproj

COPY src/ src/
COPY assets/food_catalog_hu.json assets/
RUN dotnet publish src/Flexio.Api/Flexio.Api.csproj \
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
