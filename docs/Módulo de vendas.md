# 1. Objetivo do módulo de estoque

Esse módulo precisa resolver 4 coisas:

* registrar entrada de lote
* consultar lotes por filial e apresentação
* localizar lote disponível por FEFO
* registrar movimento de estoque

A regra central é:

**para itens com controle por lote, a saída deve priorizar o lote com menor validade válida disponível.**

---

# 2. Estrutura de arquivos

## `FarmaLocal.Domain`

```text
Entities/
  LoteEstoque.cs
  MovimentoEstoque.cs
```

## `FarmaLocal.Application`

```text
Abstractions/Repositories/
  IEstoqueRepository.cs

Commands/Estoque/
  RegistrarEntradaLoteCommand.cs

DTOs/Estoque/
  LoteEstoqueDto.cs
  LoteDisponivelDto.cs

Services/
  EstoqueAppService.cs
```

## `FarmaLocal.Infrastructure`

```text
Persistence/Queries/
  EstoqueSql.cs

Persistence/Repositories/
  EstoqueRepository.cs
```

## `FarmaLocal.Api`

```text
Controllers/
  EstoqueController.cs
```

---

# 3. Entidades de domínio

## `LoteEstoque.cs`

```csharp
namespace FarmaLocal.Domain.Entities;

public sealed class LoteEstoque
{
    public long Id { get; set; }
    public long FilialId { get; set; }
    public long ApresentacaoId { get; set; }
    public long? FornecedorId { get; set; }
    public string NumeroLote { get; set; } = string.Empty;
    public DateOnly? DataFabricacao { get; set; }
    public DateOnly? DataValidade { get; set; }
    public decimal QuantidadeAtual { get; set; }
    public decimal QuantidadeReservada { get; set; }
    public decimal? CustoUnitario { get; set; }
    public bool Ativo { get; set; }
    public DateTime DataCriacao { get; set; }
    public DateTime? DataAtualizacao { get; set; }
}
```

## `MovimentoEstoque.cs`

```csharp
namespace FarmaLocal.Domain.Entities;

public sealed class MovimentoEstoque
{
    public long Id { get; set; }
    public long LoteId { get; set; }
    public string TipoMovimento { get; set; } = string.Empty;
    public decimal Quantidade { get; set; }
    public string? DocumentoReferencia { get; set; }
    public string Origem { get; set; } = string.Empty;
    public string? Observacoes { get; set; }
    public long? UsuarioId { get; set; }
    public DateTime DataMovimento { get; set; }
}
```

---

# 4. DTOs

## `LoteEstoqueDto.cs`

```csharp
namespace FarmaLocal.Application.DTOs.Estoque;

public sealed class LoteEstoqueDto
{
    public long Id { get; init; }
    public long FilialId { get; init; }
    public long ApresentacaoId { get; init; }
    public string NumeroLote { get; init; } = string.Empty;
    public DateOnly? DataFabricacao { get; init; }
    public DateOnly? DataValidade { get; init; }
    public decimal QuantidadeAtual { get; init; }
    public decimal QuantidadeReservada { get; init; }
    public decimal QuantidadeDisponivel { get; init; }
    public decimal? CustoUnitario { get; init; }
    public bool Ativo { get; init; }
}
```

## `LoteDisponivelDto.cs`

```csharp
namespace FarmaLocal.Application.DTOs.Estoque;

public sealed class LoteDisponivelDto
{
    public long Id { get; init; }
    public long FilialId { get; init; }
    public long ApresentacaoId { get; init; }
    public string NumeroLote { get; init; } = string.Empty;
    public DateOnly? DataValidade { get; init; }
    public decimal QuantidadeDisponivel { get; init; }
}
```

---

# 5. Command de entrada de lote

## `RegistrarEntradaLoteCommand.cs`

```csharp
namespace FarmaLocal.Application.Commands.Estoque;

public sealed class RegistrarEntradaLoteCommand
{
    public long FilialId { get; init; }
    public long ApresentacaoId { get; init; }
    public long? FornecedorId { get; init; }
    public string NumeroLote { get; init; } = string.Empty;
    public DateOnly? DataFabricacao { get; init; }
    public DateOnly? DataValidade { get; init; }
    public decimal Quantidade { get; init; }
    public decimal? CustoUnitario { get; init; }
    public long? UsuarioId { get; init; }
    public string? DocumentoReferencia { get; init; }
    public string? Observacoes { get; init; }
}
```

---

# 6. Contrato do repositório

## `IEstoqueRepository.cs`

```csharp
using FarmaLocal.Application.DTOs.Estoque;

namespace FarmaLocal.Application.Abstractions.Repositories;

public interface IEstoqueRepository
{
    Task<long> InserirLoteAsync(
        long filialId,
        long apresentacaoId,
        long? fornecedorId,
        string numeroLote,
        DateOnly? dataFabricacao,
        DateOnly? dataValidade,
        decimal quantidadeAtual,
        decimal? custoUnitario,
        CancellationToken cancellationToken);

    Task RegistrarMovimentoAsync(
        long loteId,
        string tipoMovimento,
        decimal quantidade,
        string origem,
        string? documentoReferencia,
        string? observacoes,
        long? usuarioId,
        CancellationToken cancellationToken);

    Task<IReadOnlyList<LoteEstoqueDto>> ListarLotesAsync(
        long filialId,
        long? apresentacaoId,
        CancellationToken cancellationToken);

    Task<LoteDisponivelDto?> ObterLoteFefoDisponivelAsync(
        long filialId,
        long apresentacaoId,
        decimal quantidadeDesejada,
        CancellationToken cancellationToken);

    Task BaixarEstoqueAsync(
        long loteId,
        decimal quantidade,
        CancellationToken cancellationToken);
}
```

---

# 7. Serviço de aplicação

## `EstoqueAppService.cs`

```csharp
using FarmaLocal.Application.Abstractions.Data;
using FarmaLocal.Application.Abstractions.Repositories;
using FarmaLocal.Application.Commands.Estoque;
using FarmaLocal.Application.DTOs.Estoque;
using FarmaLocal.Domain.Exceptions;

namespace FarmaLocal.Application.Services;

public sealed class EstoqueAppService
{
    private readonly IEstoqueRepository _estoqueRepository;
    private readonly IUnitOfWork _unitOfWork;

    public EstoqueAppService(
        IEstoqueRepository estoqueRepository,
        IUnitOfWork unitOfWork)
    {
        _estoqueRepository = estoqueRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<long> RegistrarEntradaAsync(
        RegistrarEntradaLoteCommand command,
        CancellationToken cancellationToken)
    {
        if (command.FilialId <= 0)
            throw new DomainException("Filial inválida.");

        if (command.ApresentacaoId <= 0)
            throw new DomainException("Apresentação inválida.");

        if (string.IsNullOrWhiteSpace(command.NumeroLote))
            throw new DomainException("Número do lote é obrigatório.");

        if (command.Quantidade <= 0)
            throw new DomainException("Quantidade deve ser maior que zero.");

        if (command.CustoUnitario.HasValue && command.CustoUnitario.Value < 0)
            throw new DomainException("Custo unitário inválido.");

        if (command.DataFabricacao.HasValue && command.DataValidade.HasValue &&
            command.DataValidade.Value < command.DataFabricacao.Value)
            throw new DomainException("Data de validade não pode ser menor que a data de fabricação.");

        await _unitOfWork.BeginAsync(cancellationToken);

        try
        {
            var loteId = await _estoqueRepository.InserirLoteAsync(
                command.FilialId,
                command.ApresentacaoId,
                command.FornecedorId,
                command.NumeroLote.Trim(),
                command.DataFabricacao,
                command.DataValidade,
                command.Quantidade,
                command.CustoUnitario,
                cancellationToken);

            await _estoqueRepository.RegistrarMovimentoAsync(
                loteId,
                "ENTRADA",
                command.Quantidade,
                "COMPRA",
                command.DocumentoReferencia,
                command.Observacoes,
                command.UsuarioId,
                cancellationToken);

            await _unitOfWork.CommitAsync(cancellationToken);

            return loteId;
        }
        catch
        {
            await _unitOfWork.RollbackAsync(cancellationToken);
            throw;
        }
    }

    public Task<IReadOnlyList<LoteEstoqueDto>> ListarLotesAsync(
        long filialId,
        long? apresentacaoId,
        CancellationToken cancellationToken)
    {
        if (filialId <= 0)
            throw new DomainException("Filial inválida.");

        return _estoqueRepository.ListarLotesAsync(filialId, apresentacaoId, cancellationToken);
    }

    public Task<LoteDisponivelDto?> ObterLoteFefoDisponivelAsync(
        long filialId,
        long apresentacaoId,
        decimal quantidadeDesejada,
        CancellationToken cancellationToken)
    {
        if (filialId <= 0)
            throw new DomainException("Filial inválida.");

        if (apresentacaoId <= 0)
            throw new DomainException("Apresentação inválida.");

        if (quantidadeDesejada <= 0)
            throw new DomainException("Quantidade desejada deve ser maior que zero.");

        return _estoqueRepository.ObterLoteFefoDisponivelAsync(
            filialId,
            apresentacaoId,
            quantidadeDesejada,
            cancellationToken);
    }
}
```

---

# 8. SQL do estoque

## `EstoqueSql.cs`

```csharp
namespace FarmaLocal.Infrastructure.Persistence.Queries;

public static class EstoqueSql
{
    public const string InserirLote = """
        insert into farmalocal.lote_estoque
        (
            filial_id,
            apresentacao_id,
            fornecedor_id,
            numero_lote,
            data_fabricacao,
            data_validade,
            quantidade_atual,
            quantidade_reservada,
            custo_unitario,
            ativo
        )
        values
        (
            @FilialId,
            @ApresentacaoId,
            @FornecedorId,
            @NumeroLote,
            @DataFabricacao,
            @DataValidade,
            @QuantidadeAtual,
            0,
            @CustoUnitario,
            true
        )
        returning id;
        """;

    public const string InserirMovimento = """
        insert into farmalocal.movimento_estoque
        (
            lote_id,
            tipo_movimento,
            quantidade,
            documento_referencia,
            origem,
            observacoes,
            usuario_id,
            data_movimento
        )
        values
        (
            @LoteId,
            @TipoMovimento,
            @Quantidade,
            @DocumentoReferencia,
            @Origem,
            @Observacoes,
            @UsuarioId,
            now()
        );
        """;

    public const string ListarLotes = """
        select
            le.id,
            le.filial_id as FilialId,
            le.apresentacao_id as ApresentacaoId,
            le.numero_lote as NumeroLote,
            le.data_fabricacao as DataFabricacao,
            le.data_validade as DataValidade,
            le.quantidade_atual as QuantidadeAtual,
            le.quantidade_reservada as QuantidadeReservada,
            (le.quantidade_atual - le.quantidade_reservada) as QuantidadeDisponivel,
            le.custo_unitario as CustoUnitario,
            le.ativo as Ativo
        from farmalocal.lote_estoque le
        where
            le.filial_id = @FilialId
            and (@ApresentacaoId is null or le.apresentacao_id = @ApresentacaoId)
            and le.ativo = true
        order by
            le.data_validade nulls last,
            le.numero_lote;
        """;

    public const string ObterLoteFefoDisponivel = """
        select
            le.id,
            le.filial_id as FilialId,
            le.apresentacao_id as ApresentacaoId,
            le.numero_lote as NumeroLote,
            le.data_validade as DataValidade,
            (le.quantidade_atual - le.quantidade_reservada) as QuantidadeDisponivel
        from farmalocal.lote_estoque le
        where
            le.filial_id = @FilialId
            and le.apresentacao_id = @ApresentacaoId
            and le.ativo = true
            and (le.data_validade is null or le.data_validade >= current_date)
            and (le.quantidade_atual - le.quantidade_reservada) >= @QuantidadeDesejada
        order by
            le.data_validade nulls last,
            le.id
        limit 1;
        """;

    public const string BaixarEstoque = """
        update farmalocal.lote_estoque
        set
            quantidade_atual = quantidade_atual - @Quantidade,
            data_atualizacao = now()
        where
            id = @LoteId
            and quantidade_atual >= @Quantidade;
        """;
}
```

---

# 9. Repositório Dapper

## `EstoqueRepository.cs`

```csharp
using Dapper;
using FarmaLocal.Application.Abstractions.Data;
using FarmaLocal.Application.Abstractions.Repositories;
using FarmaLocal.Application.DTOs.Estoque;
using FarmaLocal.Infrastructure.Persistence.Queries;
using System.Data;
using System.Data.Common;

namespace FarmaLocal.Infrastructure.Persistence.Repositories;

public sealed class EstoqueRepository : IEstoqueRepository
{
    private readonly IDbConnectionFactory _connectionFactory;
    private readonly IUnitOfWork _unitOfWork;

    public EstoqueRepository(
        IDbConnectionFactory connectionFactory,
        IUnitOfWork unitOfWork)
    {
        _connectionFactory = connectionFactory;
        _unitOfWork = unitOfWork;
    }

    public async Task<long> InserirLoteAsync(
        long filialId,
        long apresentacaoId,
        long? fornecedorId,
        string numeroLote,
        DateOnly? dataFabricacao,
        DateOnly? dataValidade,
        decimal quantidadeAtual,
        decimal? custoUnitario,
        CancellationToken cancellationToken)
    {
        var connection = _unitOfWork.Connection;
        var transaction = _unitOfWork.Transaction;

        return await connection.ExecuteScalarAsync<long>(
            new CommandDefinition(
                EstoqueSql.InserirLote,
                new
                {
                    FilialId = filialId,
                    ApresentacaoId = apresentacaoId,
                    FornecedorId = fornecedorId,
                    NumeroLote = numeroLote,
                    DataFabricacao = dataFabricacao,
                    DataValidade = dataValidade,
                    QuantidadeAtual = quantidadeAtual,
                    CustoUnitario = custoUnitario
                },
                transaction,
                cancellationToken: cancellationToken));
    }

    public async Task RegistrarMovimentoAsync(
        long loteId,
        string tipoMovimento,
        decimal quantidade,
        string origem,
        string? documentoReferencia,
        string? observacoes,
        long? usuarioId,
        CancellationToken cancellationToken)
    {
        var connection = _unitOfWork.Connection;
        var transaction = _unitOfWork.Transaction;

        await connection.ExecuteAsync(
            new CommandDefinition(
                EstoqueSql.InserirMovimento,
                new
                {
                    LoteId = loteId,
                    TipoMovimento = tipoMovimento,
                    Quantidade = quantidade,
                    DocumentoReferencia = documentoReferencia,
                    Origem = origem,
                    Observacoes = observacoes,
                    UsuarioId = usuarioId
                },
                transaction,
                cancellationToken: cancellationToken));
    }

    public async Task<IReadOnlyList<LoteEstoqueDto>> ListarLotesAsync(
        long filialId,
        long? apresentacaoId,
        CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        var items = await connection.QueryAsync<LoteEstoqueDto>(
            new CommandDefinition(
                EstoqueSql.ListarLotes,
                new
                {
                    FilialId = filialId,
                    ApresentacaoId = apresentacaoId
                },
                cancellationToken: cancellationToken));

        return items.ToList();
    }

    public async Task<LoteDisponivelDto?> ObterLoteFefoDisponivelAsync(
        long filialId,
        long apresentacaoId,
        decimal quantidadeDesejada,
        CancellationToken cancellationToken)
    {
        var connection = _unitOfWork.Transaction is not null
            ? _unitOfWork.Connection
            : _connectionFactory.CreateConnection();

        try
        {
            return await connection.QuerySingleOrDefaultAsync<LoteDisponivelDto>(
                new CommandDefinition(
                    EstoqueSql.ObterLoteFefoDisponivel,
                    new
                    {
                        FilialId = filialId,
                        ApresentacaoId = apresentacaoId,
                        QuantidadeDesejada = quantidadeDesejada
                    },
                    _unitOfWork.Transaction,
                    cancellationToken: cancellationToken));
        }
        finally
        {
            if (_unitOfWork.Transaction is null)
                connection.Dispose();
        }
    }

    public async Task BaixarEstoqueAsync(
        long loteId,
        decimal quantidade,
        CancellationToken cancellationToken)
    {
        var connection = _unitOfWork.Connection;
        var transaction = _unitOfWork.Transaction;

        var rows = await connection.ExecuteAsync(
            new CommandDefinition(
                EstoqueSql.BaixarEstoque,
                new
                {
                    LoteId = loteId,
                    Quantidade = quantidade
                },
                transaction,
                cancellationToken: cancellationToken));

        if (rows == 0)
            throw new InvalidOperationException("Não foi possível baixar o estoque do lote informado.");
    }
}
```

---

# 10. Registro na DI

Atualize o `AddInfrastructure`:

```csharp
using FarmaLocal.Application.Abstractions.Repositories;
using FarmaLocal.Infrastructure.Persistence.Repositories;
```

E acrescente:

```csharp
services.AddScoped<IEstoqueRepository, EstoqueRepository>();
```

Atualize também o `AddApplication`:

```csharp
using FarmaLocal.Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace FarmaLocal.Application;

public static class ApplicationServiceCollectionExtensions
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<ProdutoAppService>();
        services.AddScoped<EstoqueAppService>();
        return services;
    }
}
```

---

# 11. Controller de estoque

## `EstoqueController.cs`

```csharp
using FarmaLocal.Application.Commands.Estoque;
using FarmaLocal.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace FarmaLocal.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class EstoqueController : ControllerBase
{
    private readonly EstoqueAppService _estoqueAppService;

    public EstoqueController(EstoqueAppService estoqueAppService)
    {
        _estoqueAppService = estoqueAppService;
    }

    [HttpPost("lotes")]
    public async Task<IActionResult> RegistrarEntrada(
        [FromBody] RegistrarEntradaLoteCommand command,
        CancellationToken cancellationToken)
    {
        var loteId = await _estoqueAppService.RegistrarEntradaAsync(command, cancellationToken);
        return CreatedAtAction(nameof(ListarLotes), new { filialId = command.FilialId, apresentacaoId = command.ApresentacaoId }, new { loteId });
    }

    [HttpGet("lotes")]
    public async Task<IActionResult> ListarLotes(
        [FromQuery] long filialId,
        [FromQuery] long? apresentacaoId,
        CancellationToken cancellationToken)
    {
        var result = await _estoqueAppService.ListarLotesAsync(filialId, apresentacaoId, cancellationToken);
        return Ok(result);
    }

    [HttpGet("fefo")]
    public async Task<IActionResult> ObterLoteFefo(
        [FromQuery] long filialId,
        [FromQuery] long apresentacaoId,
        [FromQuery] decimal quantidade,
        CancellationToken cancellationToken)
    {
        var lote = await _estoqueAppService.ObterLoteFefoDisponivelAsync(
            filialId,
            apresentacaoId,
            quantidade,
            cancellationToken);

        if (lote is null)
            return NotFound();

        return Ok(lote);
    }
}
```

---

# 12. Exemplos de uso

## Registrar entrada de lote

### `POST /api/estoque/lotes`

```json
{
  "filialId": 1,
  "apresentacaoId": 1,
  "fornecedorId": 1,
  "numeroLote": "LOT2026001",
  "dataFabricacao": "2026-02-01",
  "dataValidade": "2028-02-01",
  "quantidade": 150,
  "custoUnitario": 8.75,
  "usuarioId": 1,
  "documentoReferencia": "NF-12345",
  "observacoes": "Entrada inicial do estoque"
}
```

## Listar lotes

### `GET /api/estoque/lotes?filialId=1&apresentacaoId=1`

## Obter lote FEFO

### `GET /api/estoque/fefo?filialId=1&apresentacaoId=1&quantidade=2`

---

# 13. Ajuste importante no fluxo de venda

Agora o módulo de venda já pode usar esta sequência:

* abrir transação
* chamar `ObterLoteFefoDisponivelAsync`
* inserir item
* chamar `BaixarEstoqueAsync`
* chamar `RegistrarMovimentoAsync` com `SAIDA`

Isso já te dá consistência operacional.

---

# 14. Próximo passo ideal

Agora que o catálogo e o estoque estão prontos, o passo mais valioso é montar o **módulo de venda completo**, com:

* `Venda`
* `VendaItem`
* `Pagamento`
* `ReceitaVendaItem`
* serviço transacional `RealizarVendaAsync`
* `CancelarVendaAsync`
* `VendasController`

Esse é o ponto em que o FarmaLocal começa a ficar realmente forte como projeto de portfólio.

Posso seguir exatamente nessa próxima etapa: **módulo de vendas completo em .NET + Dapper**.
