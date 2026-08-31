# syntax=docker/dockerfile:1

# A build és a futtatás külön szakasz: a végleges képbe nem kerül SDK, forráskód
# és NuGet gyorsítótár.
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Először csak a projekt- és beállításfájlok másolódnak, hogy a restore layer
# addig cache-elt maradjon, amíg a függőségek nem változnak.
COPY global.json Directory.Build.props Directory.Packages.props ./
COPY src/Flexio.Domain/Flexio.Domain.csproj src/Flexio.Domain/
COPY src/Flexio.Application/Flexio.Application.csproj src/Flexio.Application/
COPY src/Flexio.Infrastructure/Flexio.Infrastructure.csproj src/Flexio.Infrastructure/
COPY src/Flexio.Api/Flexio.Api.csproj src/Flexio.Api/
RUN dotnet restore src/Flexio.Api/Flexio.Api.csproj

COPY src/ src/
RUN dotnet publish src/Flexio.Api/Flexio.Api.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish \
    -p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# A tényleges portot a Render a PORT változóban adja meg; ezt a Program.cs
# fordítja le Kestrel URL-re. Ez csak a helyi és a fallback eset.
ENV ASPNETCORE_HTTP_PORTS=8080 \
    DOTNET_EnableDiagnostics=0

COPY --from=build /app/publish ./

# A .NET alapképek nem root felhasználót is szállítanak: ez az azonosítója.
USER $APP_UID

ENTRYPOINT ["dotnet", "Flexio.Api.dll"]
