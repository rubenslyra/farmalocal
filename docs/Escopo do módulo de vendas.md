# 1. Escopo do módulo de vendas

Esse módulo precisa cobrir:

* abrir e finalizar venda
* inserir itens
* escolher lote FEFO
* exigir receita quando necessário
* registrar pagamentos
* baixar estoque
* registrar movimentos de saída
* cancelar venda com estorno de estoque

---

# 2. Estrutura de arquivos

## `FarmaLocal.Domain`

```text
Entities/
  Venda.cs
  VendaItem.cs
  Pagamento.cs
  ReceitaVendaItem.cs
```

## `FarmaLocal.Application`

```text
Abstractions/Repositories/
  IVendaRepository.cs

Commands/Venda/
  RealizarVendaCommand.cs
  RealizarVendaItemCommand.cs
  RealizarPagamentoCommand.cs
  ReceitaItemCommand.cs
  CancelarVendaCommand.cs

DTOs/Venda/
  VendaDetalheDto.cs
  VendaItemDto.cs
  PagamentoDto.cs

Services/
  VendaAppService.cs
```

## `FarmaLocal.Infrastructure`

```text
Persistence/Queries/
  VendaSql.cs

Persistence/Repositories/
  VendaRepository.cs
```

## `FarmaLocal.Api`

```text
Controllers/
  VendasController.cs
```

---

# 3. Entidades de domínio

## `Venda.cs`

```csharp
namespace FarmaLocal.Domain.Entities;

public sealed class Venda
{
    public long Id { get; set; }
    public long FilialId { get; set; }
    public long? ClienteId { get; set; }
    public long UsuarioId { get; set; }
    public long? ConvenioId { get; set; }
    public DateTime DataHora { get; set; }
    public decimal Subtotal { get; set; }
    public decimal Desconto { get; set; }
    public decimal Total { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? Observacoes { get; set; }
    public DateTime DataCriacao { get; set; }
    public DateTime? DataAtualizacao { get; set; }
}
```

## `VendaItem.cs`

```csharp
namespace FarmaLocal.Domain.Entities;

public sealed class VendaItem
{
    public long Id { get; set; }
    public long VendaId { get; set; }
    public long ApresentacaoId { get; set; }
    public long? LoteId { get; set; }
    public decimal Quantidade { get; set; }
    public decimal PrecoUnitario { get; set; }
    public decimal Desconto { get; set; }
    public decimal Subtotal { get; set; }
    public DateTime DataCriacao { get; set; }
}
```

## `Pagamento.cs`

```csharp
namespace FarmaLocal.Domain.Entities;

public sealed class Pagamento
{
    public long Id { get; set; }
    public long VendaId { get; set; }
    public string TipoPagamento { get; set; } = string.Empty;
    public decimal Valor { get; set; }
    public string? CodigoAutorizacao { get; set; }
    public string? Observacoes { get; set; }
    public DateTime DataPagamento { get; set; }
}
```

## `ReceitaVendaItem.cs`

```csharp
namespace FarmaLocal.Domain.Entities;

public sealed class ReceitaVendaItem
{
    public long Id { get; set; }
    public long VendaItemId { get; set; }
    public string NomeMedico { get; set; } = string.Empty;
    public string Crm { get; set; } = string.Empty;
    public string UfCrm { get; set; } = string.Empty;
    public string NomePaciente { get; set; } = string.Empty;
    public string? CpfPaciente { get; set; }
    public DateOnly DataEmissaoReceita { get; set; }
    public DateOnly? DataValidadeReceita { get; set; }
    public string? TipoDocumento { get; set; }
    public bool ReceitaRetida { get; set; }
    public string? Observacoes { get; set; }
    public DateTime DataCriacao { get; set; }
}
```

---

# 4. Commands e DTOs

## `ReceitaItemCommand.cs`

```csharp
namespace FarmaLocal.Application.Commands.Venda;

public sealed class ReceitaItemCommand
{
    public string NomeMedico { get; init; } = string.Empty;
    public string Crm { get; init; } = string.Empty;
    public string UfCrm { get; init; } = string.Empty;
    public string NomePaciente { get; init; } = string.Empty;
    public string? CpfPaciente { get; init; }
    public DateOnly DataEmissaoReceita { get; init; }
    public DateOnly? DataValidadeReceita { get; init; }
    public string? TipoDocumento { get; init; }
    public bool ReceitaRetida { get; init; }
    public string? Observacoes { get; init; }
}
```

## `RealizarPagamentoCommand.cs`

```csharp
namespace FarmaLocal.Application.Commands.Venda;

public sealed class RealizarPagamentoCommand
{
    public string TipoPagamento { get; init; } = string.Empty;
    public decimal Valor { get; init; }
    public string? CodigoAutorizacao { get; init; }
    public string? Observacoes { get; init; }
}
```

## `RealizarVendaItemCommand.cs`

```csharp
namespace FarmaLocal.Application.Commands.Venda;

public sealed class RealizarVendaItemCommand
{
    public long ApresentacaoId { get; init; }
    public decimal Quantidade { get; init; }
    public decimal PrecoUnitario { get; init; }
    public decimal Desconto { get; init; }
    public ReceitaItemCommand? Receita { get; init; }
}
```

## `RealizarVendaCommand.cs`

```csharp
namespace FarmaLocal.Application.Commands.Venda;

public sealed class RealizarVendaCommand
{
    public long FilialId { get; init; }
    public long? ClienteId { get; init; }
    public long UsuarioId { get; init; }
    public long? ConvenioId { get; init; }
    public string? Observacoes { get; init; }
    public List<RealizarVendaItemCommand> Itens { get; init; } = [];
    public List<RealizarPagamentoCommand> Pagamentos { get; init; } = [];
}
```

## `CancelarVendaCommand.cs`

```csharp
namespace FarmaLocal.Application.Commands.Venda;

public sealed class CancelarVendaCommand
{
    public long VendaId { get; init; }
    public long UsuarioId { get; init; }
    public string? Observacoes { get; init; }
}
```

## `VendaItemDto.cs`

```csharp
namespace FarmaLocal.Application.DTOs.Venda;

public sealed class VendaItemDto
{
    public long Id { get; init; }
    public long ApresentacaoId { get; init; }
    public long? LoteId { get; init; }
    public decimal Quantidade { get; init; }
    public decimal PrecoUnitario { get; init; }
    public decimal Desconto { get; init; }
    public decimal Subtotal { get; init; }
}
```

## `PagamentoDto.cs`

```csharp
namespace FarmaLocal.Application.DTOs.Venda;

public sealed class PagamentoDto
{
    public long Id { get; init; }
    public string TipoPagamento { get; init; } = string.Empty;
    public decimal Valor { get; init; }
}
```

## `VendaDetalheDto.cs`

```csharp
namespace FarmaLocal.Application.DTOs.Venda;

public sealed class VendaDetalheDto
{
    public long Id { get; init; }
    public long FilialId { get; init; }
    public long? ClienteId { get; init; }
    public long UsuarioId { get; init; }
    public long? ConvenioId { get; init; }
    public DateTime DataHora { get; init; }
    public decimal Subtotal { get; init; }
    public decimal Desconto { get; init; }
    public decimal Total { get; init; }
    public string Status { get; init; } = string.Empty;
    public string? Observacoes { get; init; }
    public List<VendaItemDto> Itens { get; init; } = [];
    public List<PagamentoDto> Pagamentos { get; init; } = [];
}
```

---

# 5. Contrato do repositório de vendas

## `IVendaRepository.cs`

```csharp
using FarmaLocal.Application.Commands.Venda;
using FarmaLocal.Application.DTOs.Venda;

namespace FarmaLocal.Application.Abstractions.Repositories;

public interface IVendaRepository
{
    Task<long> InserirCabecalhoAsync(
        long filialId,
        long? clienteId,
        long usuarioId,
        long? convenioId,
        decimal subtotal,
        decimal desconto,
        decimal total,
        string? observacoes,
        CancellationToken cancellationToken);

    Task<long> InserirItemAsync(
        long vendaId,
        long apresentacaoId,
        long? loteId,
        decimal quantidade,
        decimal precoUnitario,
        decimal desconto,
        decimal subtotal,
        CancellationToken cancellationToken);

    Task InserirReceitaAsync(
        long vendaItemId,
        ReceitaItemCommand receita,
        CancellationToken cancellationToken);

    Task InserirPagamentoAsync(
        long vendaId,
        RealizarPagamentoCommand pagamento,
        CancellationToken cancellationToken);

    Task FinalizarAsync(long vendaId, CancellationToken cancellationToken);
    Task CancelarAsync(long vendaId, string? observacoes, CancellationToken cancellationToken);

    Task<VendaDetalheDto?> ObterPorIdAsync(long vendaId, CancellationToken cancellationToken);

    Task<IReadOnlyList<(long VendaItemId, long? LoteId, decimal Quantidade)>> ObterItensParaCancelamentoAsync(
        long vendaId,
        CancellationToken cancellationToken);

    Task<bool> ExigeReceitaAsync(long apresentacaoId, CancellationToken cancellationToken);
}
```

---

# 6. SQL de vendas

## `VendaSql.cs`

```csharp
namespace FarmaLocal.Infrastructure.Persistence.Queries;

public static class VendaSql
{
    public const string InserirCabecalho = """
        insert into farmalocal.venda
        (
            filial_id,
            cliente_id,
            usuario_id,
            convenio_id,
            data_hora,
            subtotal,
            desconto,
            total,
            status,
            observacoes,
            data_criacao
        )
        values
        (
            @FilialId,
            @ClienteId,
            @UsuarioId,
            @ConvenioId,
            now(),
            @Subtotal,
            @Desconto,
            @Total,
            'ABERTA',
            @Observacoes,
            now()
        )
        returning id;
        """;

    public const string InserirItem = """
        insert into farmalocal.venda_item
        (
            venda_id,
            apresentacao_id,
            lote_id,
            quantidade,
            preco_unitario,
            desconto,
            subtotal,
            data_criacao
        )
        values
        (
            @VendaId,
            @ApresentacaoId,
            @LoteId,
            @Quantidade,
            @PrecoUnitario,
            @Desconto,
            @Subtotal,
            now()
        )
        returning id;
        """;

    public const string InserirReceita = """
        insert into farmalocal.receita_venda_item
        (
            venda_item_id,
            nome_medico,
            crm,
            uf_crm,
            nome_paciente,
            cpf_paciente,
            data_emissao_receita,
            data_validade_receita,
            tipo_documento,
            receita_retida,
            observacoes,
            data_criacao
        )
        values
        (
            @VendaItemId,
            @NomeMedico,
            @Crm,
            @UfCrm,
            @NomePaciente,
            @CpfPaciente,
            @DataEmissaoReceita,
            @DataValidadeReceita,
            @TipoDocumento,
            @ReceitaRetida,
            @Observacoes,
            now()
        );
        """;

    public const string InserirPagamento = """
        insert into farmalocal.pagamento
        (
            venda_id,
            tipo_pagamento,
            valor,
            codigo_autorizacao,
            observacoes,
            data_pagamento
        )
        values
        (
            @VendaId,
            @TipoPagamento,
            @Valor,
            @CodigoAutorizacao,
            @Observacoes,
            now()
        );
        """;

    public const string Finalizar = """
        update farmalocal.venda
        set
            status = 'FINALIZADA',
            data_atualizacao = now()
        where id = @VendaId
          and status = 'ABERTA';
        """;

    public const string Cancelar = """
        update farmalocal.venda
        set
            status = 'CANCELADA',
            observacoes = case
                when @Observacoes is null or trim(@Observacoes) = '' then observacoes
                else concat(coalesce(observacoes, ''), case when observacoes is null or observacoes = '' then '' else ' | ' end, @Observacoes)
            end,
            data_atualizacao = now()
        where id = @VendaId
          and status <> 'CANCELADA';
        """;

    public const string ExigeReceita = """
        select exists(
            select 1
            from farmalocal.medicamento_detalhe md
            where md.apresentacao_id = @ApresentacaoId
              and (
                    md.requer_receita = true
                    or md.retencao_receita = true
                    or md.controlado_sngpc = true
                  )
        );
        """;

    public const string ObterCabecalho = """
        select
            v.id,
            v.filial_id as FilialId,
            v.cliente_id as ClienteId,
            v.usuario_id as UsuarioId,
            v.convenio_id as ConvenioId,
            v.data_hora as DataHora,
            v.subtotal as Subtotal,
            v.desconto as Desconto,
            v.total as Total,
            v.status as Status,
            v.observacoes as Observacoes
        from farmalocal.venda v
        where v.id = @VendaId;
        """;

    public const string ObterItens = """
        select
            vi.id,
            vi.apresentacao_id as ApresentacaoId,
            vi.lote_id as LoteId,
            vi.quantidade as Quantidade,
            vi.preco_unitario as PrecoUnitario,
            vi.desconto as Desconto,
            vi.subtotal as Subtotal
        from farmalocal.venda_item vi
        where vi.venda_id = @VendaId
        order by vi.id;
        """;

    public const string ObterPagamentos = """
        select
            p.id,
            p.tipo_pagamento as TipoPagamento,
            p.valor as Valor
        from farmalocal.pagamento p
        where p.venda_id = @VendaId
        order by p.id;
        """;

    public const string ObterItensParaCancelamento = """
        select
            vi.id as VendaItemId,
            vi.lote_id as LoteId,
            vi.quantidade as Quantidade
        from farmalocal.venda_item vi
        inner join farmalocal.venda v on v.id = vi.venda_id
        where vi.venda_id = @VendaId
          and v.status = 'FINALIZADA';
        """;
}
```

---

# 7. Repositório de vendas

## `VendaRepository.cs`

```csharp
using Dapper;
using FarmaLocal.Application.Abstractions.Data;
using FarmaLocal.Application.Abstractions.Repositories;
using FarmaLocal.Application.Commands.Venda;
using FarmaLocal.Application.DTOs.Venda;
using FarmaLocal.Infrastructure.Persistence.Queries;

namespace FarmaLocal.Infrastructure.Persistence.Repositories;

public sealed class VendaRepository : IVendaRepository
{
    private readonly IDbConnectionFactory _connectionFactory;
    private readonly IUnitOfWork _unitOfWork;

    public VendaRepository(
        IDbConnectionFactory connectionFactory,
        IUnitOfWork unitOfWork)
    {
        _connectionFactory = connectionFactory;
        _unitOfWork = unitOfWork;
    }

    public async Task<long> InserirCabecalhoAsync(
        long filialId,
        long? clienteId,
        long usuarioId,
        long? convenioId,
        decimal subtotal,
        decimal desconto,
        decimal total,
        string? observacoes,
        CancellationToken cancellationToken)
    {
        var connection = _unitOfWork.Connection;
        var transaction = _unitOfWork.Transaction;

        return await connection.ExecuteScalarAsync<long>(
            new CommandDefinition(
                VendaSql.InserirCabecalho,
                new
                {
                    FilialId = filialId,
                    ClienteId = clienteId,
                    UsuarioId = usuarioId,
                    ConvenioId = convenioId,
                    Subtotal = subtotal,
                    Desconto = desconto,
                    Total = total,
                    Observacoes = observacoes
                },
                transaction,
                cancellationToken: cancellationToken));
    }

    public async Task<long> InserirItemAsync(
        long vendaId,
        long apresentacaoId,
        long? loteId,
        decimal quantidade,
        decimal precoUnitario,
        decimal desconto,
        decimal subtotal,
        CancellationToken cancellationToken)
    {
        var connection = _unitOfWork.Connection;
        var transaction = _unitOfWork.Transaction;

        return await connection.ExecuteScalarAsync<long>(
            new CommandDefinition(
                VendaSql.InserirItem,
                new
                {
                    VendaId = vendaId,
                    ApresentacaoId = apresentacaoId,
                    LoteId = loteId,
                    Quantidade = quantidade,
                    PrecoUnitario = precoUnitario,
                    Desconto = desconto,
                    Subtotal = subtotal
                },
                transaction,
                cancellationToken: cancellationToken));
    }

    public async Task InserirReceitaAsync(
        long vendaItemId,
        ReceitaItemCommand receita,
        CancellationToken cancellationToken)
    {
        var connection = _unitOfWork.Connection;
        var transaction = _unitOfWork.Transaction;

        await connection.ExecuteAsync(
            new CommandDefinition(
                VendaSql.InserirReceita,
                new
                {
                    VendaItemId = vendaItemId,
                    receita.NomeMedico,
                    Crm = receita.Crm,
                    UfCrm = receita.UfCrm,
                    receita.NomePaciente,
                    receita.CpfPaciente,
                    DataEmissaoReceita = receita.DataEmissaoReceita,
                    DataValidadeReceita = receita.DataValidadeReceita,
                    receita.TipoDocumento,
                    ReceitaRetida = receita.ReceitaRetida,
                    receita.Observacoes
                },
                transaction,
                cancellationToken: cancellationToken));
    }

    public async Task InserirPagamentoAsync(
        long vendaId,
        RealizarPagamentoCommand pagamento,
        CancellationToken cancellationToken)
    {
        var connection = _unitOfWork.Connection;
        var transaction = _unitOfWork.Transaction;

        await connection.ExecuteAsync(
            new CommandDefinition(
                VendaSql.InserirPagamento,
                new
                {
                    VendaId = vendaId,
                    TipoPagamento = pagamento.TipoPagamento,
                    Valor = pagamento.Valor,
                    CodigoAutorizacao = pagamento.CodigoAutorizacao,
                    Observacoes = pagamento.Observacoes
                },
                transaction,
                cancellationToken: cancellationToken));
    }

    public async Task FinalizarAsync(long vendaId, CancellationToken cancellationToken)
    {
        var connection = _unitOfWork.Connection;
        var transaction = _unitOfWork.Transaction;

        var rows = await connection.ExecuteAsync(
            new CommandDefinition(
                VendaSql.Finalizar,
                new { VendaId = vendaId },
                transaction,
                cancellationToken: cancellationToken));

        if (rows == 0)
            throw new InvalidOperationException("Não foi possível finalizar a venda.");
    }

    public async Task CancelarAsync(long vendaId, string? observacoes, CancellationToken cancellationToken)
    {
        var connection = _unitOfWork.Connection;
        var transaction = _unitOfWork.Transaction;

        var rows = await connection.ExecuteAsync(
            new CommandDefinition(
                VendaSql.Cancelar,
                new { VendaId = vendaId, Observacoes = observacoes },
                transaction,
                cancellationToken: cancellationToken));

        if (rows == 0)
            throw new InvalidOperationException("Não foi possível cancelar a venda.");
    }

    public async Task<bool> ExigeReceitaAsync(long apresentacaoId, CancellationToken cancellationToken)
    {
        var connection = _unitOfWork.Transaction is not null
            ? _unitOfWork.Connection
            : _connectionFactory.CreateConnection();

        try
        {
            return await connection.ExecuteScalarAsync<bool>(
                new CommandDefinition(
                    VendaSql.ExigeReceita,
                    new { ApresentacaoId = apresentacaoId },
                    _unitOfWork.Transaction,
                    cancellationToken: cancellationToken));
        }
        finally
        {
            if (_unitOfWork.Transaction is null)
                connection.Dispose();
        }
    }

    public async Task<VendaDetalheDto?> ObterPorIdAsync(long vendaId, CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        var cabecalho = await connection.QuerySingleOrDefaultAsync<VendaDetalheDto>(
            new CommandDefinition(
                VendaSql.ObterCabecalho,
                new { VendaId = vendaId },
                cancellationToken: cancellationToken));

        if (cabecalho is null)
            return null;

        var itens = await connection.QueryAsync<VendaItemDto>(
            new CommandDefinition(
                VendaSql.ObterItens,
                new { VendaId = vendaId },
                cancellationToken: cancellationToken));

        var pagamentos = await connection.QueryAsync<PagamentoDto>(
            new CommandDefinition(
                VendaSql.ObterPagamentos,
                new { VendaId = vendaId },
                cancellationToken: cancellationToken));

        return new VendaDetalheDto
        {
            Id = cabecalho.Id,
            FilialId = cabecalho.FilialId,
            ClienteId = cabecalho.ClienteId,
            UsuarioId = cabecalho.UsuarioId,
            ConvenioId = cabecalho.ConvenioId,
            DataHora = cabecalho.DataHora,
            Subtotal = cabecalho.Subtotal,
            Desconto = cabecalho.Desconto,
            Total = cabecalho.Total,
            Status = cabecalho.Status,
            Observacoes = cabecalho.Observacoes,
            Itens = itens.ToList(),
            Pagamentos = pagamentos.ToList()
        };
    }

    public async Task<IReadOnlyList<(long VendaItemId, long? LoteId, decimal Quantidade)>> ObterItensParaCancelamentoAsync(
        long vendaId,
        CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        var result = await connection.QueryAsync<(long VendaItemId, long? LoteId, decimal Quantidade)>(
            new CommandDefinition(
                VendaSql.ObterItensParaCancelamento,
                new { VendaId = vendaId },
                cancellationToken: cancellationToken));

        return result.ToList();
    }
}
```

---

# 8. Pequeno ajuste no contrato de estoque

Adicione ao `IEstoqueRepository`:

```csharp
Task ReporEstoqueAsync(
    long loteId,
    decimal quantidade,
    CancellationToken cancellationToken);
```

E no `EstoqueSql.cs`:

```csharp
public const string ReporEstoque = """
    update farmalocal.lote_estoque
    set
        quantidade_atual = quantidade_atual + @Quantidade,
        data_atualizacao = now()
    where id = @LoteId;
    """;
```

No `EstoqueRepository.cs`:

```csharp
public async Task ReporEstoqueAsync(
    long loteId,
    decimal quantidade,
    CancellationToken cancellationToken)
{
    var connection = _unitOfWork.Connection;
    var transaction = _unitOfWork.Transaction;

    await connection.ExecuteAsync(
        new CommandDefinition(
            EstoqueSql.ReporEstoque,
            new
            {
                LoteId = loteId,
                Quantidade = quantidade
            },
            transaction,
            cancellationToken: cancellationToken));
}
```

---

# 9. Serviço de aplicação de vendas

## `VendaAppService.cs`

```csharp
using FarmaLocal.Application.Abstractions.Data;
using FarmaLocal.Application.Abstractions.Repositories;
using FarmaLocal.Application.Commands.Venda;
using FarmaLocal.Application.DTOs.Venda;
using FarmaLocal.Domain.Exceptions;

namespace FarmaLocal.Application.Services;

public sealed class VendaAppService
{
    private readonly IVendaRepository _vendaRepository;
    private readonly IEstoqueRepository _estoqueRepository;
    private readonly IUnitOfWork _unitOfWork;

    public VendaAppService(
        IVendaRepository vendaRepository,
        IEstoqueRepository estoqueRepository,
        IUnitOfWork unitOfWork)
    {
        _vendaRepository = vendaRepository;
        _estoqueRepository = estoqueRepository;
        _unitOfWork = unitOfWork;
    }

    public async Task<long> RealizarVendaAsync(
        RealizarVendaCommand command,
        CancellationToken cancellationToken)
    {
        if (command.FilialId <= 0)
            throw new DomainException("Filial inválida.");

        if (command.UsuarioId <= 0)
            throw new DomainException("Usuário inválido.");

        if (command.Itens.Count == 0)
            throw new DomainException("A venda deve possuir ao menos um item.");

        if (command.Pagamentos.Count == 0)
            throw new DomainException("A venda deve possuir ao menos um pagamento.");

        var subtotal = 0m;
        var descontoTotal = 0m;

        foreach (var item in command.Itens)
        {
            if (item.ApresentacaoId <= 0)
                throw new DomainException("Apresentação inválida.");

            if (item.Quantidade <= 0)
                throw new DomainException("Quantidade do item deve ser maior que zero.");

            if (item.PrecoUnitario < 0)
                throw new DomainException("Preço unitário inválido.");

            if (item.Desconto < 0)
                throw new DomainException("Desconto do item inválido.");

            subtotal += item.Quantidade * item.PrecoUnitario;
            descontoTotal += item.Desconto;
        }

        var total = subtotal - descontoTotal;

        if (total < 0)
            throw new DomainException("Total da venda inválido.");

        var totalPagamentos = command.Pagamentos.Sum(x => x.Valor);

        if (totalPagamentos != total)
            throw new DomainException("A soma dos pagamentos deve ser igual ao total da venda.");

        await _unitOfWork.BeginAsync(cancellationToken);

        try
        {
            var vendaId = await _vendaRepository.InserirCabecalhoAsync(
                command.FilialId,
                command.ClienteId,
                command.UsuarioId,
                command.ConvenioId,
                subtotal,
                descontoTotal,
                total,
                command.Observacoes,
                cancellationToken);

            foreach (var item in command.Itens)
            {
                var exigeReceita = await _vendaRepository.ExigeReceitaAsync(
                    item.ApresentacaoId,
                    cancellationToken);

                if (exigeReceita && item.Receita is null)
                    throw new DomainException($"A apresentação {item.ApresentacaoId} exige receita.");

                var lote = await _estoqueRepository.ObterLoteFefoDisponivelAsync(
                    command.FilialId,
                    item.ApresentacaoId,
                    item.Quantidade,
                    cancellationToken);

                if (lote is null)
                    throw new DomainException($"Estoque insuficiente para a apresentação {item.ApresentacaoId}.");

                var subtotalItem = (item.Quantidade * item.PrecoUnitario) - item.Desconto;

                if (subtotalItem < 0)
                    throw new DomainException("Subtotal do item inválido.");

                var vendaItemId = await _vendaRepository.InserirItemAsync(
                    vendaId,
                    item.ApresentacaoId,
                    lote.Id,
                    item.Quantidade,
                    item.PrecoUnitario,
                    item.Desconto,
                    subtotalItem,
                    cancellationToken);

                if (item.Receita is not null)
                {
                    if (string.IsNullOrWhiteSpace(item.Receita.NomeMedico))
                        throw new DomainException("Nome do médico é obrigatório.");

                    if (string.IsNullOrWhiteSpace(item.Receita.Crm))
                        throw new DomainException("CRM é obrigatório.");

                    if (string.IsNullOrWhiteSpace(item.Receita.UfCrm) || item.Receita.UfCrm.Trim().Length != 2)
                        throw new DomainException("UF do CRM inválida.");

                    if (string.IsNullOrWhiteSpace(item.Receita.NomePaciente))
                        throw new DomainException("Nome do paciente é obrigatório.");

                    await _vendaRepository.InserirReceitaAsync(
                        vendaItemId,
                        item.Receita,
                        cancellationToken);
                }

                await _estoqueRepository.BaixarEstoqueAsync(
                    lote.Id,
                    item.Quantidade,
                    cancellationToken);

                await _estoqueRepository.RegistrarMovimentoAsync(
                    lote.Id,
                    "SAIDA",
                    item.Quantidade,
                    "VENDA",
                    $"VENDA-{vendaId}",
                    "Saída por venda",
                    command.UsuarioId,
                    cancellationToken);
            }

            foreach (var pagamento in command.Pagamentos)
            {
                if (string.IsNullOrWhiteSpace(pagamento.TipoPagamento))
                    throw new DomainException("Tipo de pagamento é obrigatório.");

                if (pagamento.Valor <= 0)
                    throw new DomainException("Valor do pagamento deve ser maior que zero.");

                await _vendaRepository.InserirPagamentoAsync(
                    vendaId,
                    new RealizarPagamentoCommand
                    {
                        TipoPagamento = pagamento.TipoPagamento.Trim().ToUpperInvariant(),
                        Valor = pagamento.Valor,
                        CodigoAutorizacao = pagamento.CodigoAutorizacao,
                        Observacoes = pagamento.Observacoes
                    },
                    cancellationToken);
            }

            await _vendaRepository.FinalizarAsync(vendaId, cancellationToken);

            await _unitOfWork.CommitAsync(cancellationToken);

            return vendaId;
        }
        catch
        {
            await _unitOfWork.RollbackAsync(cancellationToken);
            throw;
        }
    }

    public Task<VendaDetalheDto?> ObterPorIdAsync(long vendaId, CancellationToken cancellationToken)
        => _vendaRepository.ObterPorIdAsync(vendaId, cancellationToken);

    public async Task CancelarVendaAsync(
        CancelarVendaCommand command,
        CancellationToken cancellationToken)
    {
        if (command.VendaId <= 0)
            throw new DomainException("Venda inválida.");

        if (command.UsuarioId <= 0)
            throw new DomainException("Usuário inválido.");

        await _unitOfWork.BeginAsync(cancellationToken);

        try
        {
            var itens = await _vendaRepository.ObterItensParaCancelamentoAsync(
                command.VendaId,
                cancellationToken);

            if (itens.Count == 0)
                throw new DomainException("Venda não encontrada ou não elegível para cancelamento.");

            foreach (var item in itens)
            {
                if (item.LoteId.HasValue)
                {
                    await _estoqueRepository.ReporEstoqueAsync(
                        item.LoteId.Value,
                        item.Quantidade,
                        cancellationToken);

                    await _estoqueRepository.RegistrarMovimentoAsync(
                        item.LoteId.Value,
                        "CANCELAMENTO",
                        item.Quantidade,
                        "CANCELAMENTO_VENDA",
                        $"VENDA-{command.VendaId}",
                        command.Observacoes ?? "Estorno por cancelamento de venda",
                        command.UsuarioId,
                        cancellationToken);
                }
            }

            await _vendaRepository.CancelarAsync(
                command.VendaId,
                command.Observacoes,
                cancellationToken);

            await _unitOfWork.CommitAsync(cancellationToken);
        }
        catch
        {
            await _unitOfWork.RollbackAsync(cancellationToken);
            throw;
        }
    }
}
```

---

# 10. Registro na DI

No `AddInfrastructure`:

```csharp
services.AddScoped<IVendaRepository, VendaRepository>();
```

No `AddApplication`:

```csharp
services.AddScoped<VendaAppService>();
```

---

# 11. Controller de vendas

## `VendasController.cs`

```csharp
using FarmaLocal.Application.Commands.Venda;
using FarmaLocal.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace FarmaLocal.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class VendasController : ControllerBase
{
    private readonly VendaAppService _vendaAppService;

    public VendasController(VendaAppService vendaAppService)
    {
        _vendaAppService = vendaAppService;
    }

    [HttpPost]
    public async Task<IActionResult> Post(
        [FromBody] RealizarVendaCommand command,
        CancellationToken cancellationToken)
    {
        var vendaId = await _vendaAppService.RealizarVendaAsync(command, cancellationToken);

        return CreatedAtAction(nameof(GetById), new { id = vendaId }, new { id = vendaId });
    }

    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetById(long id, CancellationToken cancellationToken)
    {
        var venda = await _vendaAppService.ObterPorIdAsync(id, cancellationToken);

        if (venda is null)
            return NotFound();

        return Ok(venda);
    }

    [HttpPost("{id:long}/cancelar")]
    public async Task<IActionResult> Cancelar(
        long id,
        [FromBody] CancelarVendaCommand body,
        CancellationToken cancellationToken)
    {
        await _vendaAppService.CancelarVendaAsync(
            new CancelarVendaCommand
            {
                VendaId = id,
                UsuarioId = body.UsuarioId,
                Observacoes = body.Observacoes
            },
            cancellationToken);

        return NoContent();
    }
}
```

---

# 12. Exemplo de payload de venda

## `POST /api/vendas`

```json
{
  "filialId": 1,
  "clienteId": 1,
  "usuarioId": 1,
  "convenioId": null,
  "observacoes": "Venda balcão",
  "itens": [
    {
      "apresentacaoId": 1,
      "quantidade": 2,
      "precoUnitario": 12.50,
      "desconto": 0,
      "receita": null
    },
    {
      "apresentacaoId": 2,
      "quantidade": 1,
      "precoUnitario": 35.00,
      "desconto": 5.00,
      "receita": {
        "nomeMedico": "Dr. Paulo Silva",
        "crm": "123456",
        "ufCrm": "ES",
        "nomePaciente": "Maria Souza",
        "cpfPaciente": "123.456.789-00",
        "dataEmissaoReceita": "2026-03-20",
        "dataValidadeReceita": "2026-04-20",
        "tipoDocumento": "RECEITA_SIMPLES",
        "receitaRetida": false,
        "observacoes": "Uso contínuo"
      }
    }
  ],
  "pagamentos": [
    {
      "tipoPagamento": "PIX",
      "valor": 55.00,
      "codigoAutorizacao": null,
      "observacoes": null
    }
  ]
}
```

---

# 13. Observações importantes de robustez

Há 4 pontos que eu recomendo melhorar na próxima rodada:

**1. comparação de decimal**
Hoje está:

```csharp
if (totalPagamentos != total)
```

Melhor fazer arredondamento controlado:

```csharp
if (decimal.Round(totalPagamentos, 2) != decimal.Round(total, 2))
```

**2. concorrência de estoque**
Em cenário real, pode ser interessante bloquear o lote com `for update` ou migrar a baixa para query mais forte com reserva/lock.

**3. validação de receita por regra farmacêutica**
Hoje só validamos obrigatoriedade. Depois dá para validar prazo da receita, retenção, antimicrobiano etc.

**4. cancelamento**
Hoje estorna todo item de venda finalizada. Depois você pode exigir motivo obrigatório, registrar auditoria, e impedir cancelamento tardio conforme regra.

---

# 14. Melhorias pequenas no SQL de FEFO

Para um cenário mais seguro, depois você pode adaptar o `ObterLoteFefoDisponivel` com lock transacional, por exemplo em PostgreSQL:

```sql
for update skip locked
```

Mas, para MVP de estudo, a versão atual já está boa.

---

# 15. Estado atual do FarmaLocal

Com o que você já tem agora, o projeto cobre:

* catálogo base
* cadastro de produto
* entrada de lote
* movimentos de estoque
* seleção FEFO
* venda completa
* pagamento
* receita por item
* cancelamento com estorno

Isso já transforma o FarmaLocal em um projeto de portfólio bem forte.

---

# 16. Próximo passo ideal

Agora existem 3 próximos passos muito bons. A ordem que eu recomendo é:

**1. produto_apresentacao + medicamento_detalhe no backend**
porque hoje a venda já depende disso no banco, mas o CRUD da API ainda está mais simples.

**2. autenticação e usuário**
para proteger endpoints e usar o usuário real da sessão.

**3. relatórios e consultas**
como:

* produtos vencendo
* vendas por período
* itens mais vendidos
* estoque atual por apresentação

A próxima etapa mais útil para consolidar tudo é eu montar o **módulo completo de produto_apresentacao + medicamento_detalhe**, com CRUD e endpoints.
