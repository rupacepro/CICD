# Use the official ASP.NET Core runtime as a base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

# Use the SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the project file and restore dependencies
COPY ["CICD/CICD.csproj", "./"]  # Correct path to .csproj

# Restore the dependencies
RUN dotnet restore "CICD.csproj"

# Copy the entire project into the container
COPY ["CICD/", "CICD/"]  # Copying all project files from the inner CICD folder

# Build the project
WORKDIR "/src/CICD"
RUN dotnet build "CICD.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "CICD.csproj" -c Release -o /app/publish

# Final stage, copy the published app and set the entry point
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CICD.dll"]  # Adjust the name if necessary
