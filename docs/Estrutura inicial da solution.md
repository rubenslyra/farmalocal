# 1. Estrutura inicial da solution

```text
FarmaLocal.sln

src/
  FarmaLocal.Domain/
  FarmaLocal.Application/
  FarmaLocal.Infrastructure/
  FarmaLocal.Api/

tests/
  FarmaLocal.UnitTests/
  FarmaLocal.IntegrationTests/

database/
  postgresql/
    migrations/
```

---

# 2. Comandos iniciais

```bash
dotnet new sln -n FarmaLocal

dotnet new classlib -n FarmaLocal.Domain -o src/FarmaLocal.Domain
dotnet new classlib -n FarmaLocal.Application -o src/FarmaLocal.Application
dotnet new classlib -n FarmaLocal.Infrastructure -o src/FarmaLocal.Infrastructure
dotnet new webapi -n FarmaLocal.Api -o src/FarmaLocal.Api

dotnet new xunit -n FarmaLocal.UnitTests -o tests/FarmaLocal.UnitTests
dotnet new xunit -n FarmaLocal.IntegrationTests -o tests/FarmaLocal.IntegrationTests

dotnet sln FarmaLocal.sln add src/FarmaLocal.Domain/FarmaLocal.Domain.csproj
dotnet sln FarmaLocal.sln add src/FarmaLocal.Application/FarmaLocal.Application.csproj
dotnet sln FarmaLocal.sln add src/FarmaLocal.Infrastructure/FarmaLocal.Infrastructure.csproj
dotnet sln FarmaLocal.sln add src/FarmaLocal.Api/FarmaLocal.Api.csproj
dotnet sln FarmaLocal.sln add tests/FarmaLocal.UnitTests/FarmaLocal.UnitTests.csproj
dotnet sln FarmaLocal.sln add tests/FarmaLocal.IntegrationTests/FarmaLocal.IntegrationTests.csproj

dotnet add src/FarmaLocal.Application/FarmaLocal.Application.csproj reference src/FarmaLocal.Domain/FarmaLocal.Domain.csproj
dotnet add src/FarmaLocal.Infrastructure/FarmaLocal.Infrastructure.csproj reference src/FarmaLocal.Application/FarmaLocal.Application.csproj
dotnet add src/FarmaLocal.Infrastructure/FarmaLocal.Infrastructure.csproj reference src/FarmaLocal.Domain/FarmaLocal.Domain.csproj
dotnet add src/FarmaLocal.Api/FarmaLocal.Api.csproj reference src/FarmaLocal.Application/FarmaLocal.Application.csproj
dotnet add src/FarmaLocal.Api/FarmaLocal.Api.csproj reference src/FarmaLocal.Infrastructure/FarmaLocal.Infrastructure.csproj
```

Pacotes:

```bash
dotnet add src/FarmaLocal.Infrastructure/FarmaLocal.Infrastructure.csproj package Dapper
dotnet add src/FarmaLocal.Infrastructure/FarmaLocal.Infrastructure.csproj package Npgsql

dotnet add src/FarmaLocal.Api/FarmaLocal.Api.csproj package Swashbuckle.AspNetCore
```

---

# 3. Estrutura de pastas por projeto

## `FarmaLocal.Domain`

```text
Entities/
Enums/
Exceptions/
```

## `FarmaLocal.Application`

```text
Abstractions/
  Data/
  Repositories/
DTOs/
Commands/
Services/
```

## `FarmaLocal.Infrastructure`

```text
Persistence/
  Dapper/
  Queries/
  Repositories/
DependencyInjection/
```

## `FarmaLocal.Api`

```text
Controllers/
Middlewares/
Extensions/
```

---

# 4. Código base do domínio

## `Produto.cs`

```csharp
namespace FarmaLocal.Domain.Entities;

public class Produto
{
    public long Id { get; set; }
    public long CategoriaId { get; set; }
    public long FabricanteId { get; set; }
    public string CodigoInterno { get; set; } = string.Empty;
    public string? NomeComercial { get; set; }
    public string NomeReduzido { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    public string TipoProduto { get; set; } = string.Empty;
    public bool Ativo { get; set; } = true;
    public DateTime DataCriacao { get; set; }
    public DateTime? DataAtualizacao { get; set; }
}
```

## `DomainException.cs`

```csharp
namespace FarmaLocal.Domain.Exceptions;

public sealed class DomainException : Exception
{
    public DomainException(string message) : base(message)
    {
    }
}
```

---

# 5. Contratos da aplicação

## `IDbConnectionFactory.cs`

```csharp
using System.Data;

namespace FarmaLocal.Application.Abstractions.Data;

public interface IDbConnectionFactory
{
    IDbConnection CreateConnection();
}
```

## `IUnitOfWork.cs`

```csharp
using System.Data;

namespace FarmaLocal.Application.Abstractions.Data;

public interface IUnitOfWork : IAsyncDisposable
{
    IDbConnection Connection { get; }
    IDbTransaction? Transaction { get; }

    Task BeginAsync(CancellationToken cancellationToken = default);
    Task CommitAsync(CancellationToken cancellationToken = default);
    Task RollbackAsync(CancellationToken cancellationToken = default);
}
```

## `IProdutoRepository.cs`

```csharp
using FarmaLocal.Application.DTOs.Produto;
using FarmaLocal.Domain.Entities;

namespace FarmaLocal.Application.Abstractions.Repositories;

public interface IProdutoRepository
{
    Task<long> InserirAsync(Produto produto, CancellationToken cancellationToken);
    Task<Produto?> ObterPorIdAsync(long id, CancellationToken cancellationToken);
    Task<IReadOnlyList<ProdutoListItemDto>> BuscarAsync(string? termo, CancellationToken cancellationToken);
}
```

---

# 6. DTOs e command

## `ProdutoListItemDto.cs`

```csharp
namespace FarmaLocal.Application.DTOs.Produto;

public sealed class ProdutoListItemDto
{
    public long Id { get; init; }
    public string CodigoInterno { get; init; } = string.Empty;
    public string NomeExibicao { get; init; } = string.Empty;
    public string TipoProduto { get; init; } = string.Empty;
    public bool Ativo { get; init; }
}
```

## `CadastrarProdutoCommand.cs`

```csharp
namespace FarmaLocal.Application.Commands.Produto;

public sealed class CadastrarProdutoCommand
{
    public long CategoriaId { get; init; }
    public long FabricanteId { get; init; }
    public string CodigoInterno { get; init; } = string.Empty;
    public string? NomeComercial { get; init; }
    public string NomeReduzido { get; init; } = string.Empty;
    public string? Descricao { get; init; }
    public string TipoProduto { get; init; } = string.Empty;
}
```

---

# 7. Serviço de aplicação

## `ProdutoAppService.cs`

```csharp
using FarmaLocal.Application.Abstractions.Repositories;
using FarmaLocal.Application.Commands.Produto;
using FarmaLocal.Application.DTOs.Produto;
using FarmaLocal.Domain.Entities;
using FarmaLocal.Domain.Exceptions;

namespace FarmaLocal.Application.Services;

public sealed class ProdutoAppService
{
    private readonly IProdutoRepository _produtoRepository;

    public ProdutoAppService(IProdutoRepository produtoRepository)
    {
        _produtoRepository = produtoRepository;
    }

    public async Task<long> CadastrarAsync(CadastrarProdutoCommand command, CancellationToken cancellationToken)
    {
        if (command.CategoriaId <= 0)
            throw new DomainException("Categoria inválida.");

        if (command.FabricanteId <= 0)
            throw new DomainException("Fabricante inválido.");

        if (string.IsNullOrWhiteSpace(command.CodigoInterno))
            throw new DomainException("Código interno é obrigatório.");

        if (string.IsNullOrWhiteSpace(command.NomeReduzido))
            throw new DomainException("Nome reduzido é obrigatório.");

        if (string.IsNullOrWhiteSpace(command.TipoProduto))
            throw new DomainException("Tipo de produto é obrigatório.");

        var produto = new Produto
        {
            CategoriaId = command.CategoriaId,
            FabricanteId = command.FabricanteId,
            CodigoInterno = command.CodigoInterno.Trim(),
            NomeComercial = string.IsNullOrWhiteSpace(command.NomeComercial) ? null : command.NomeComercial.Trim(),
            NomeReduzido = command.NomeReduzido.Trim(),
            Descricao = string.IsNullOrWhiteSpace(command.Descricao) ? null : command.Descricao.Trim(),
            TipoProduto = command.TipoProduto.Trim().ToUpperInvariant(),
            Ativo = true
        };

        return await _produtoRepository.InserirAsync(produto, cancellationToken);
    }

    public Task<Produto?> ObterPorIdAsync(long id, CancellationToken cancellationToken)
        => _produtoRepository.ObterPorIdAsync(id, cancellationToken);

    public Task<IReadOnlyList<ProdutoListItemDto>> BuscarAsync(string? termo, CancellationToken cancellationToken)
        => _produtoRepository.BuscarAsync(termo, cancellationToken);
}
```

---

# 8. Infraestrutura Dapper

## `NpgsqlConnectionFactory.cs`

```csharp
using System.Data;
using FarmaLocal.Application.Abstractions.Data;
using Npgsql;

namespace FarmaLocal.Infrastructure.Persistence.Dapper;

public sealed class NpgsqlConnectionFactory : IDbConnectionFactory
{
    private readonly string _connectionString;

    public NpgsqlConnectionFactory(string connectionString)
    {
        _connectionString = connectionString;
    }

    public IDbConnection CreateConnection() => new NpgsqlConnection(_connectionString);
}
```

## `UnitOfWork.cs`

```csharp
using System.Data;
using FarmaLocal.Application.Abstractions.Data;

namespace FarmaLocal.Infrastructure.Persistence.Dapper;

public sealed class UnitOfWork : IUnitOfWork
{
    private readonly IDbConnectionFactory _connectionFactory;
    private IDbConnection? _connection;
    private IDbTransaction? _transaction;

    public UnitOfWork(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public IDbConnection Connection
        => _connection ?? throw new InvalidOperationException("Conexão não iniciada.");

    public IDbTransaction? Transaction => _transaction;

    public async Task BeginAsync(CancellationToken cancellationToken = default)
    {
        if (_connection is not null)
            return;

        _connection = _connectionFactory.CreateConnection();

        if (_connection.State != ConnectionState.Open)
        {
            if (_connection is DbConnection dbConnection)
                await dbConnection.OpenAsync(cancellationToken);
            else
                _connection.Open();
        }

        _transaction = _connection.BeginTransaction();
    }

    public Task CommitAsync(CancellationToken cancellationToken = default)
    {
        _transaction?.Commit();
        DisposeInternal();
        return Task.CompletedTask;
    }

    public Task RollbackAsync(CancellationToken cancellationToken = default)
    {
        _transaction?.Rollback();
        DisposeInternal();
        return Task.CompletedTask;
    }

    public ValueTask DisposeAsync()
    {
        DisposeInternal();
        return ValueTask.CompletedTask;
    }

    private void DisposeInternal()
    {
        _transaction?.Dispose();
        _connection?.Dispose();
        _transaction = null;
        _connection = null;
    }
}
```

## `ProdutoSql.cs`

```csharp
namespace FarmaLocal.Infrastructure.Persistence.Queries;

public static class ProdutoSql
{
    public const string Inserir = """
        insert into farmalocal.produto
        (
            categoria_id,
            fabricante_id,
            codigo_interno,
            nome_comercial,
            nome_reduzido,
            descricao,
            tipo_produto,
            ativo
        )
        values
        (
            @CategoriaId,
            @FabricanteId,
            @CodigoInterno,
            @NomeComercial,
            @NomeReduzido,
            @Descricao,
            @TipoProduto,
            @Ativo
        )
        returning id;
        """;

    public const string ObterPorId = """
        select
            id,
            categoria_id as CategoriaId,
            fabricante_id as FabricanteId,
            codigo_interno as CodigoInterno,
            nome_comercial as NomeComercial,
            nome_reduzido as NomeReduzido,
            descricao as Descricao,
            tipo_produto as TipoProduto,
            ativo,
            data_criacao as DataCriacao,
            data_atualizacao as DataAtualizacao
        from farmalocal.produto
        where id = @Id;
        """;

    public const string Buscar = """
        select
            id,
            codigo_interno as CodigoInterno,
            coalesce(nome_comercial, nome_reduzido) as NomeExibicao,
            tipo_produto as TipoProduto,
            ativo
        from farmalocal.produto
        where
            (@Termo is null)
            or nome_comercial ilike @TermoFiltro
            or nome_reduzido ilike @TermoFiltro
            or codigo_interno ilike @TermoFiltro
        order by nome_reduzido;
        """;
}
```

## `ProdutoRepository.cs`

```csharp
using Dapper;
using FarmaLocal.Application.Abstractions.Data;
using FarmaLocal.Application.Abstractions.Repositories;
using FarmaLocal.Application.DTOs.Produto;
using FarmaLocal.Domain.Entities;
using FarmaLocal.Infrastructure.Persistence.Queries;
using System.Data;

namespace FarmaLocal.Infrastructure.Persistence.Repositories;

public sealed class ProdutoRepository : IProdutoRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public ProdutoRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<long> InserirAsync(Produto produto, CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        return await connection.ExecuteScalarAsync<long>(
            new CommandDefinition(
                ProdutoSql.Inserir,
                new
                {
                    produto.CategoriaId,
                    produto.FabricanteId,
                    produto.CodigoInterno,
                    produto.NomeComercial,
                    produto.NomeReduzido,
                    produto.Descricao,
                    produto.TipoProduto,
                    produto.Ativo
                },
                cancellationToken: cancellationToken));
    }

    public async Task<Produto?> ObterPorIdAsync(long id, CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        return await connection.QuerySingleOrDefaultAsync<Produto>(
            new CommandDefinition(
                ProdutoSql.ObterPorId,
                new { Id = id },
                cancellationToken: cancellationToken));
    }

    public async Task<IReadOnlyList<ProdutoListItemDto>> BuscarAsync(string? termo, CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        var items = await connection.QueryAsync<ProdutoListItemDto>(
            new CommandDefinition(
                ProdutoSql.Buscar,
                new
                {
                    Termo = string.IsNullOrWhiteSpace(termo) ? null : termo.Trim(),
                    TermoFiltro = string.IsNullOrWhiteSpace(termo) ? null : $"%{termo.Trim()}%"
                },
                cancellationToken: cancellationToken));

        return items.ToList();
    }
}
```

---

# 9. Registro de dependências

## `InfrastructureServiceCollectionExtensions.cs`

```csharp
using FarmaLocal.Application.Abstractions.Data;
using FarmaLocal.Application.Abstractions.Repositories;
using FarmaLocal.Infrastructure.Persistence.Dapper;
using FarmaLocal.Infrastructure.Persistence.Repositories;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace FarmaLocal.Infrastructure.DependencyInjection;

public static class InfrastructureServiceCollectionExtensions
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' não configurada.");

        services.AddSingleton<IDbConnectionFactory>(_ => new NpgsqlConnectionFactory(connectionString));

        services.AddScoped<IUnitOfWork, UnitOfWork>();
        services.AddScoped<IProdutoRepository, ProdutoRepository>();

        return services;
    }
}
```

## `ApplicationServiceCollectionExtensions.cs`

```csharp
using FarmaLocal.Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace FarmaLocal.Application;

public static class ApplicationServiceCollectionExtensions
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<ProdutoAppService>();
        return services;
    }
}
```

---

# 10. Middleware global de exceção

## `ExceptionHandlingMiddleware.cs`

```csharp
using FarmaLocal.Domain.Exceptions;
using System.Net;
using System.Text.Json;

namespace FarmaLocal.Api.Middlewares;

public sealed class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;

    public ExceptionHandlingMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task Invoke(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (DomainException ex)
        {
            context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            context.Response.ContentType = "application/json";

            var payload = JsonSerializer.Serialize(new
            {
                error = ex.Message
            });

            await context.Response.WriteAsync(payload);
        }
        catch (Exception)
        {
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            context.Response.ContentType = "application/json";

            var payload = JsonSerializer.Serialize(new
            {
                error = "Erro interno do servidor."
            });

            await context.Response.WriteAsync(payload);
        }
    }
}
```

---

# 11. Controller inicial

## `ProdutosController.cs`

```csharp
using FarmaLocal.Application.Commands.Produto;
using FarmaLocal.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace FarmaLocal.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class ProdutosController : ControllerBase
{
    private readonly ProdutoAppService _produtoAppService;

    public ProdutosController(ProdutoAppService produtoAppService)
    {
        _produtoAppService = produtoAppService;
    }

    [HttpPost]
    public async Task<IActionResult> Post(
        [FromBody] CadastrarProdutoCommand command,
        CancellationToken cancellationToken)
    {
        var id = await _produtoAppService.CadastrarAsync(command, cancellationToken);

        return CreatedAtAction(nameof(GetById), new { id }, new { id });
    }

    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetById(long id, CancellationToken cancellationToken)
    {
        var produto = await _produtoAppService.ObterPorIdAsync(id, cancellationToken);

        if (produto is null)
            return NotFound();

        return Ok(produto);
    }

    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] string? termo, CancellationToken cancellationToken)
    {
        var items = await _produtoAppService.BuscarAsync(termo, cancellationToken);
        return Ok(items);
    }
}
```

---

# 12. `Program.cs`

```csharp
using FarmaLocal.Api.Middlewares;
using FarmaLocal.Application;
using FarmaLocal.Infrastructure.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

var app = builder.Build();

app.UseMiddleware<ExceptionHandlingMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.MapControllers();

app.Run();
```

---

# 13. `appsettings.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=farmalocal;Username=postgres;Password=postgres"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
```

---

# 14. Teste rápido do endpoint

### `POST /api/produtos`

```json
{
  "categoriaId": 1,
  "fabricanteId": 1,
  "codigoInterno": "MED-0001",
  "nomeComercial": "Paracetamol Genérico",
  "nomeReduzido": "Paracetamol 750mg",
  "descricao": "Caixa com 20 comprimidos",
  "tipoProduto": "MEDICAMENTO"
}
```

### `GET /api/produtos?termo=para`

Retorna lista filtrada.

