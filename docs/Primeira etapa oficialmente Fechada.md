# 1. Objetivo do módulo

Esse módulo resolve o que faltava entre o cadastro do **produto base** e a operação de **estoque/venda**.

## Ele precisa permitir

* cadastrar apresentação vendável do produto
* consultar apresentação por id
* buscar apresentações por produto
* cadastrar detalhe regulatório de medicamento
* consultar detalhe regulatório
* atualizar apresentação
* atualizar detalhe de medicamento

## Em termos de domínio

* `produto` = item mestre
* `produto_apresentacao` = unidade comercial vendável
* `medicamento_detalhe` = extensão regulatória da apresentação

Exemplo:

* Produto: Dipirona
* Apresentação: Dipirona 500mg comprimido caixa com 20
* MedicamentoDetalhe: Genérico, sem tarja, não controlado, não exige retenção

---

# 2. Estrutura de arquivos

## `FarmaLocal.Domain`

```text
Entities/
  ProdutoApresentacao.cs
  MedicamentoDetalhe.cs
```

## `FarmaLocal.Application`

```text
Abstractions/Repositories/
  IProdutoApresentacaoRepository.cs

Commands/ProdutoApresentacao/
  CadastrarProdutoApresentacaoCommand.cs
  AtualizarProdutoApresentacaoCommand.cs
  CadastrarMedicamentoDetalheCommand.cs
  AtualizarMedicamentoDetalheCommand.cs

DTOs/ProdutoApresentacao/
  ProdutoApresentacaoDto.cs
  MedicamentoDetalheDto.cs
  ProdutoApresentacaoListItemDto.cs

Services/
  ProdutoApresentacaoAppService.cs
```

## `FarmaLocal.Infrastructure`

```text
Persistence/Queries/
  ProdutoApresentacaoSql.cs

Persistence/Repositories/
  ProdutoApresentacaoRepository.cs
```

## `FarmaLocal.Api`

```text
Controllers/
  ProdutoApresentacoesController.cs
```

---

# 3. Entidades de domínio

## `ProdutoApresentacao.cs`

```csharp
namespace FarmaLocal.Domain.Entities;

public sealed class ProdutoApresentacao
{
    public long Id { get; set; }
    public long ProdutoId { get; set; }
    public string? CodigoEan { get; set; }
    public string SkuInterno { get; set; } = string.Empty;
    public string UnidadeMedida { get; set; } = string.Empty;
    public decimal? QuantidadeEmbalagem { get; set; }
    public string? FormaFarmaceutica { get; set; }
    public string? DosagemTexto { get; set; }
    public string? VolumeTexto { get; set; }
    public string? ConcentracaoTexto { get; set; }
    public string DescricaoApresentacao { get; set; } = string.Empty;
    public decimal PrecoVenda { get; set; }
    public bool PermiteFracionamento { get; set; }
    public bool Ativo { get; set; } = true;
    public DateTime DataCriacao { get; set; }
    public DateTime? DataAtualizacao { get; set; }
}
```

## `MedicamentoDetalhe.cs`

```csharp
namespace FarmaLocal.Domain.Entities;

public sealed class MedicamentoDetalhe
{
    public long ApresentacaoId { get; set; }
    public string TipoMedicamento { get; set; } = string.Empty;
    public string? RegistroAnvisa { get; set; }
    public string Tarja { get; set; } = string.Empty;
    public bool RequerReceita { get; set; }
    public bool RetencaoReceita { get; set; }
    public bool ControladoSngpc { get; set; }
    public bool Antimicrobiano { get; set; }
    public bool UsoContinuo { get; set; }
    public bool PermiteIntercambialidade { get; set; }
    public string? Observacoes { get; set; }
    public DateTime DataCriacao { get; set; }
    public DateTime? DataAtualizacao { get; set; }
}
```

---

# 4. DTOs

## `ProdutoApresentacaoDto.cs`

```csharp
namespace FarmaLocal.Application.DTOs.ProdutoApresentacao;

public sealed class ProdutoApresentacaoDto
{
    public long Id { get; init; }
    public long ProdutoId { get; init; }
    public string? CodigoEan { get; init; }
    public string SkuInterno { get; init; } = string.Empty;
    public string UnidadeMedida { get; init; } = string.Empty;
    public decimal? QuantidadeEmbalagem { get; init; }
    public string? FormaFarmaceutica { get; init; }
    public string? DosagemTexto { get; init; }
    public string? VolumeTexto { get; init; }
    public string? ConcentracaoTexto { get; init; }
    public string DescricaoApresentacao { get; init; } = string.Empty;
    public decimal PrecoVenda { get; init; }
    public bool PermiteFracionamento { get; init; }
    public bool Ativo { get; init; }
}
```

## `MedicamentoDetalheDto.cs`

```csharp
namespace FarmaLocal.Application.DTOs.ProdutoApresentacao;

public sealed class MedicamentoDetalheDto
{
    public long ApresentacaoId { get; init; }
    public string TipoMedicamento { get; init; } = string.Empty;
    public string? RegistroAnvisa { get; init; }
    public string Tarja { get; init; } = string.Empty;
    public bool RequerReceita { get; init; }
    public bool RetencaoReceita { get; init; }
    public bool ControladoSngpc { get; init; }
    public bool Antimicrobiano { get; init; }
    public bool UsoContinuo { get; init; }
    public bool PermiteIntercambialidade { get; init; }
    public string? Observacoes { get; init; }
}
```

## `ProdutoApresentacaoListItemDto.cs`

```csharp
namespace FarmaLocal.Application.DTOs.ProdutoApresentacao;

public sealed class ProdutoApresentacaoListItemDto
{
    public long Id { get; init; }
    public long ProdutoId { get; init; }
    public string SkuInterno { get; init; } = string.Empty;
    public string? CodigoEan { get; init; }
    public string DescricaoApresentacao { get; init; } = string.Empty;
    public decimal PrecoVenda { get; init; }
    public bool Ativo { get; init; }
}
```

---

# 5. Commands

## `CadastrarProdutoApresentacaoCommand.cs`

```csharp
namespace FarmaLocal.Application.Commands.ProdutoApresentacao;

public sealed class CadastrarProdutoApresentacaoCommand
{
    public long ProdutoId { get; init; }
    public string? CodigoEan { get; init; }
    public string SkuInterno { get; init; } = string.Empty;
    public string UnidadeMedida { get; init; } = string.Empty;
    public decimal? QuantidadeEmbalagem { get; init; }
    public string? FormaFarmaceutica { get; init; }
    public string? DosagemTexto { get; init; }
    public string? VolumeTexto { get; init; }
    public string? ConcentracaoTexto { get; init; }
    public string DescricaoApresentacao { get; init; } = string.Empty;
    public decimal PrecoVenda { get; init; }
    public bool PermiteFracionamento { get; init; }
}
```

## `AtualizarProdutoApresentacaoCommand.cs`

```csharp
namespace FarmaLocal.Application.Commands.ProdutoApresentacao;

public sealed class AtualizarProdutoApresentacaoCommand
{
    public long Id { get; init; }
    public string? CodigoEan { get; init; }
    public string UnidadeMedida { get; init; } = string.Empty;
    public decimal? QuantidadeEmbalagem { get; init; }
    public string? FormaFarmaceutica { get; init; }
    public string? DosagemTexto { get; init; }
    public string? VolumeTexto { get; init; }
    public string? ConcentracaoTexto { get; init; }
    public string DescricaoApresentacao { get; init; } = string.Empty;
    public decimal PrecoVenda { get; init; }
    public bool PermiteFracionamento { get; init; }
    public bool Ativo { get; init; }
}
```

## `CadastrarMedicamentoDetalheCommand.cs`

```csharp
namespace FarmaLocal.Application.Commands.ProdutoApresentacao;

public sealed class CadastrarMedicamentoDetalheCommand
{
    public long ApresentacaoId { get; init; }
    public string TipoMedicamento { get; init; } = string.Empty;
    public string? RegistroAnvisa { get; init; }
    public string Tarja { get; init; } = string.Empty;
    public bool RequerReceita { get; init; }
    public bool RetencaoReceita { get; init; }
    public bool ControladoSngpc { get; init; }
    public bool Antimicrobiano { get; init; }
    public bool UsoContinuo { get; init; }
    public bool PermiteIntercambialidade { get; init; } = true;
    public string? Observacoes { get; init; }
}
```

## `AtualizarMedicamentoDetalheCommand.cs`

```csharp
namespace FarmaLocal.Application.Commands.ProdutoApresentacao;

public sealed class AtualizarMedicamentoDetalheCommand
{
    public long ApresentacaoId { get; init; }
    public string TipoMedicamento { get; init; } = string.Empty;
    public string? RegistroAnvisa { get; init; }
    public string Tarja { get; init; } = string.Empty;
    public bool RequerReceita { get; init; }
    public bool RetencaoReceita { get; init; }
    public bool ControladoSngpc { get; init; }
    public bool Antimicrobiano { get; init; }
    public bool UsoContinuo { get; init; }
    public bool PermiteIntercambialidade { get; init; }
    public string? Observacoes { get; init; }
}
```

---

# 6. Contrato do repositório

## `IProdutoApresentacaoRepository.cs`

```csharp
using FarmaLocal.Application.DTOs.ProdutoApresentacao;

namespace FarmaLocal.Application.Abstractions.Repositories;

public interface IProdutoApresentacaoRepository
{
    Task<long> InserirApresentacaoAsync(
        long produtoId,
        string? codigoEan,
        string skuInterno,
        string unidadeMedida,
        decimal? quantidadeEmbalagem,
        string? formaFarmaceutica,
        string? dosagemTexto,
        string? volumeTexto,
        string? concentracaoTexto,
        string descricaoApresentacao,
        decimal precoVenda,
        bool permiteFracionamento,
        CancellationToken cancellationToken);

    Task AtualizarApresentacaoAsync(
        long id,
        string? codigoEan,
        string unidadeMedida,
        decimal? quantidadeEmbalagem,
        string? formaFarmaceutica,
        string? dosagemTexto,
        string? volumeTexto,
        string? concentracaoTexto,
        string descricaoApresentacao,
        decimal precoVenda,
        bool permiteFracionamento,
        bool ativo,
        CancellationToken cancellationToken);

    Task<ProdutoApresentacaoDto?> ObterApresentacaoPorIdAsync(long id, CancellationToken cancellationToken);

    Task<IReadOnlyList<ProdutoApresentacaoListItemDto>> ListarPorProdutoAsync(long produtoId, CancellationToken cancellationToken);

    Task InserirMedicamentoDetalheAsync(
        long apresentacaoId,
        string tipoMedicamento,
        string? registroAnvisa,
        string tarja,
        bool requerReceita,
        bool retencaoReceita,
        bool controladoSngpc,
        bool antimicrobiano,
        bool usoContinuo,
        bool permiteIntercambialidade,
        string? observacoes,
        CancellationToken cancellationToken);

    Task AtualizarMedicamentoDetalheAsync(
        long apresentacaoId,
        string tipoMedicamento,
        string? registroAnvisa,
        string tarja,
        bool requerReceita,
        bool retencaoReceita,
        bool controladoSngpc,
        bool antimicrobiano,
        bool usoContinuo,
        bool permiteIntercambialidade,
        string? observacoes,
        CancellationToken cancellationToken);

    Task<MedicamentoDetalheDto?> ObterMedicamentoDetalheAsync(long apresentacaoId, CancellationToken cancellationToken);
}
```

---

# 7. SQL Dapper

## `ProdutoApresentacaoSql.cs`

```csharp
namespace FarmaLocal.Infrastructure.Persistence.Queries;

public static class ProdutoApresentacaoSql
{
    public const string InserirApresentacao = """
        insert into farmalocal.produto_apresentacao
        (
            produto_id,
            codigo_ean,
            sku_interno,
            unidade_medida,
            quantidade_embalagem,
            forma_farmaceutica,
            dosagem_texto,
            volume_texto,
            concentracao_texto,
            descricao_apresentacao,
            preco_venda,
            permite_fracionamento,
            ativo,
            data_criacao
        )
        values
        (
            @ProdutoId,
            @CodigoEan,
            @SkuInterno,
            @UnidadeMedida,
            @QuantidadeEmbalagem,
            @FormaFarmaceutica,
            @DosagemTexto,
            @VolumeTexto,
            @ConcentracaoTexto,
            @DescricaoApresentacao,
            @PrecoVenda,
            @PermiteFracionamento,
            true,
            now()
        )
        returning id;
        """;

    public const string AtualizarApresentacao = """
        update farmalocal.produto_apresentacao
        set
            codigo_ean = @CodigoEan,
            unidade_medida = @UnidadeMedida,
            quantidade_embalagem = @QuantidadeEmbalagem,
            forma_farmaceutica = @FormaFarmaceutica,
            dosagem_texto = @DosagemTexto,
            volume_texto = @VolumeTexto,
            concentracao_texto = @ConcentracaoTexto,
            descricao_apresentacao = @DescricaoApresentacao,
            preco_venda = @PrecoVenda,
            permite_fracionamento = @PermiteFracionamento,
            ativo = @Ativo,
            data_atualizacao = now()
        where id = @Id;
        """;

    public const string ObterApresentacaoPorId = """
        select
            id,
            produto_id as ProdutoId,
            codigo_ean as CodigoEan,
            sku_interno as SkuInterno,
            unidade_medida as UnidadeMedida,
            quantidade_embalagem as QuantidadeEmbalagem,
            forma_farmaceutica as FormaFarmaceutica,
            dosagem_texto as DosagemTexto,
            volume_texto as VolumeTexto,
            concentracao_texto as ConcentracaoTexto,
            descricao_apresentacao as DescricaoApresentacao,
            preco_venda as PrecoVenda,
            permite_fracionamento as PermiteFracionamento,
            ativo as Ativo
        from farmalocal.produto_apresentacao
        where id = @Id;
        """;

    public const string ListarPorProduto = """
        select
            id,
            produto_id as ProdutoId,
            sku_interno as SkuInterno,
            codigo_ean as CodigoEan,
            descricao_apresentacao as DescricaoApresentacao,
            preco_venda as PrecoVenda,
            ativo as Ativo
        from farmalocal.produto_apresentacao
        where produto_id = @ProdutoId
        order by descricao_apresentacao;
        """;

    public const string InserirMedicamentoDetalhe = """
        insert into farmalocal.medicamento_detalhe
        (
            apresentacao_id,
            tipo_medicamento,
            registro_anvisa,
            tarja,
            requer_receita,
            retencao_receita,
            controlado_sngpc,
            antimicrobiano,
            uso_continuo,
            permite_intercambialidade,
            observacoes,
            data_criacao
        )
        values
        (
            @ApresentacaoId,
            @TipoMedicamento,
            @RegistroAnvisa,
            @Tarja,
            @RequerReceita,
            @RetencaoReceita,
            @ControladoSngpc,
            @Antimicrobiano,
            @UsoContinuo,
            @PermiteIntercambialidade,
            @Observacoes,
            now()
        );
        """;

    public const string AtualizarMedicamentoDetalhe = """
        update farmalocal.medicamento_detalhe
        set
            tipo_medicamento = @TipoMedicamento,
            registro_anvisa = @RegistroAnvisa,
            tarja = @Tarja,
            requer_receita = @RequerReceita,
            retencao_receita = @RetencaoReceita,
            controlado_sngpc = @ControladoSngpc,
            antimicrobiano = @Antimicrobiano,
            uso_continuo = @UsoContinuo,
            permite_intercambialidade = @PermiteIntercambialidade,
            observacoes = @Observacoes,
            data_atualizacao = now()
        where apresentacao_id = @ApresentacaoId;
        """;

    public const string ObterMedicamentoDetalhe = """
        select
            apresentacao_id as ApresentacaoId,
            tipo_medicamento as TipoMedicamento,
            registro_anvisa as RegistroAnvisa,
            tarja as Tarja,
            requer_receita as RequerReceita,
            retencao_receita as RetencaoReceita,
            controlado_sngpc as ControladoSngpc,
            antimicrobiano as Antimicrobiano,
            uso_continuo as UsoContinuo,
            permite_intercambialidade as PermiteIntercambialidade,
            observacoes as Observacoes
        from farmalocal.medicamento_detalhe
        where apresentacao_id = @ApresentacaoId;
        """;
}
```

---

# 8. Repositório

## `ProdutoApresentacaoRepository.cs`

```csharp
using Dapper;
using FarmaLocal.Application.Abstractions.Data;
using FarmaLocal.Application.Abstractions.Repositories;
using FarmaLocal.Application.DTOs.ProdutoApresentacao;
using FarmaLocal.Infrastructure.Persistence.Queries;

namespace FarmaLocal.Infrastructure.Persistence.Repositories;

public sealed class ProdutoApresentacaoRepository : IProdutoApresentacaoRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public ProdutoApresentacaoRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<long> InserirApresentacaoAsync(
        long produtoId,
        string? codigoEan,
        string skuInterno,
        string unidadeMedida,
        decimal? quantidadeEmbalagem,
        string? formaFarmaceutica,
        string? dosagemTexto,
        string? volumeTexto,
        string? concentracaoTexto,
        string descricaoApresentacao,
        decimal precoVenda,
        bool permiteFracionamento,
        CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        return await connection.ExecuteScalarAsync<long>(
            new CommandDefinition(
                ProdutoApresentacaoSql.InserirApresentacao,
                new
                {
                    ProdutoId = produtoId,
                    CodigoEan = codigoEan,
                    SkuInterno = skuInterno,
                    UnidadeMedida = unidadeMedida,
                    QuantidadeEmbalagem = quantidadeEmbalagem,
                    FormaFarmaceutica = formaFarmaceutica,
                    DosagemTexto = dosagemTexto,
                    VolumeTexto = volumeTexto,
                    ConcentracaoTexto = concentracaoTexto,
                    DescricaoApresentacao = descricaoApresentacao,
                    PrecoVenda = precoVenda,
                    PermiteFracionamento = permiteFracionamento
                },
                cancellationToken: cancellationToken));
    }

    public async Task AtualizarApresentacaoAsync(
        long id,
        string? codigoEan,
        string unidadeMedida,
        decimal? quantidadeEmbalagem,
        string? formaFarmaceutica,
        string? dosagemTexto,
        string? volumeTexto,
        string? concentracaoTexto,
        string descricaoApresentacao,
        decimal precoVenda,
        bool permiteFracionamento,
        bool ativo,
        CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        var rows = await connection.ExecuteAsync(
            new CommandDefinition(
                ProdutoApresentacaoSql.AtualizarApresentacao,
                new
                {
                    Id = id,
                    CodigoEan = codigoEan,
                    UnidadeMedida = unidadeMedida,
                    QuantidadeEmbalagem = quantidadeEmbalagem,
                    FormaFarmaceutica = formaFarmaceutica,
                    DosagemTexto = dosagemTexto,
                    VolumeTexto = volumeTexto,
                    ConcentracaoTexto = concentracaoTexto,
                    DescricaoApresentacao = descricaoApresentacao,
                    PrecoVenda = precoVenda,
                    PermiteFracionamento = permiteFracionamento,
                    Ativo = ativo
                },
                cancellationToken: cancellationToken));

        if (rows == 0)
            throw new InvalidOperationException("Apresentação não encontrada para atualização.");
    }

    public async Task<ProdutoApresentacaoDto?> ObterApresentacaoPorIdAsync(long id, CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        return await connection.QuerySingleOrDefaultAsync<ProdutoApresentacaoDto>(
            new CommandDefinition(
                ProdutoApresentacaoSql.ObterApresentacaoPorId,
                new { Id = id },
                cancellationToken: cancellationToken));
    }

    public async Task<IReadOnlyList<ProdutoApresentacaoListItemDto>> ListarPorProdutoAsync(long produtoId, CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        var items = await connection.QueryAsync<ProdutoApresentacaoListItemDto>(
            new CommandDefinition(
                ProdutoApresentacaoSql.ListarPorProduto,
                new { ProdutoId = produtoId },
                cancellationToken: cancellationToken));

        return items.ToList();
    }

    public async Task InserirMedicamentoDetalheAsync(
        long apresentacaoId,
        string tipoMedicamento,
        string? registroAnvisa,
        string tarja,
        bool requerReceita,
        bool retencaoReceita,
        bool controladoSngpc,
        bool antimicrobiano,
        bool usoContinuo,
        bool permiteIntercambialidade,
        string? observacoes,
        CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        await connection.ExecuteAsync(
            new CommandDefinition(
                ProdutoApresentacaoSql.InserirMedicamentoDetalhe,
                new
                {
                    ApresentacaoId = apresentacaoId,
                    TipoMedicamento = tipoMedicamento,
                    RegistroAnvisa = registroAnvisa,
                    Tarja = tarja,
                    RequerReceita = requerReceita,
                    RetencaoReceita = retencaoReceita,
                    ControladoSngpc = controladoSngpc,
                    Antimicrobiano = antimicrobiano,
                    UsoContinuo = usoContinuo,
                    PermiteIntercambialidade = permiteIntercambialidade,
                    Observacoes = observacoes
                },
                cancellationToken: cancellationToken));
    }

    public async Task AtualizarMedicamentoDetalheAsync(
        long apresentacaoId,
        string tipoMedicamento,
        string? registroAnvisa,
        string tarja,
        bool requerReceita,
        bool retencaoReceita,
        bool controladoSngpc,
        bool antimicrobiano,
        bool usoContinuo,
        bool permiteIntercambialidade,
        string? observacoes,
        CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        var rows = await connection.ExecuteAsync(
            new CommandDefinition(
                ProdutoApresentacaoSql.AtualizarMedicamentoDetalhe,
                new
                {
                    ApresentacaoId = apresentacaoId,
                    TipoMedicamento = tipoMedicamento,
                    RegistroAnvisa = registroAnvisa,
                    Tarja = tarja,
                    RequerReceita = requerReceita,
                    RetencaoReceita = retencaoReceita,
                    ControladoSngpc = controladoSngpc,
                    Antimicrobiano = antimicrobiano,
                    UsoContinuo = usoContinuo,
                    PermiteIntercambialidade = permiteIntercambialidade,
                    Observacoes = observacoes
                },
                cancellationToken: cancellationToken));

        if (rows == 0)
            throw new InvalidOperationException("Detalhe de medicamento não encontrado para atualização.");
    }

    public async Task<MedicamentoDetalheDto?> ObterMedicamentoDetalheAsync(long apresentacaoId, CancellationToken cancellationToken)
    {
        using var connection = _connectionFactory.CreateConnection();

        return await connection.QuerySingleOrDefaultAsync<MedicamentoDetalheDto>(
            new CommandDefinition(
                ProdutoApresentacaoSql.ObterMedicamentoDetalhe,
                new { ApresentacaoId = apresentacaoId },
                cancellationToken: cancellationToken));
    }
}
```

---

# 9. Service de aplicação

## `ProdutoApresentacaoAppService.cs`

```csharp
using FarmaLocal.Application.Abstractions.Repositories;
using FarmaLocal.Application.Commands.ProdutoApresentacao;
using FarmaLocal.Application.DTOs.ProdutoApresentacao;
using FarmaLocal.Domain.Exceptions;

namespace FarmaLocal.Application.Services;

public sealed class ProdutoApresentacaoAppService
{
    private static readonly string[] TiposMedicamentoValidos = ["REFERENCIA", "GENERICO", "SIMILAR"];
    private static readonly string[] TarjasValidas = ["SEM_TARJA", "AMARELA", "VERMELHA", "PRETA"];

    private readonly IProdutoApresentacaoRepository _repository;

    public ProdutoApresentacaoAppService(IProdutoApresentacaoRepository repository)
    {
        _repository = repository;
    }

    public async Task<long> CadastrarApresentacaoAsync(
        CadastrarProdutoApresentacaoCommand command,
        CancellationToken cancellationToken)
    {
        if (command.ProdutoId <= 0)
            throw new DomainException("Produto inválido.");

        if (string.IsNullOrWhiteSpace(command.SkuInterno))
            throw new DomainException("SKU interno é obrigatório.");

        if (string.IsNullOrWhiteSpace(command.UnidadeMedida))
            throw new DomainException("Unidade de medida é obrigatória.");

        if (string.IsNullOrWhiteSpace(command.DescricaoApresentacao))
            throw new DomainException("Descrição da apresentação é obrigatória.");

        if (command.PrecoVenda < 0)
            throw new DomainException("Preço de venda inválido.");

        if (command.QuantidadeEmbalagem.HasValue && command.QuantidadeEmbalagem.Value < 0)
            throw new DomainException("Quantidade da embalagem inválida.");

        return await _repository.InserirApresentacaoAsync(
            command.ProdutoId,
            LimparTexto(command.CodigoEan),
            command.SkuInterno.Trim(),
            command.UnidadeMedida.Trim().ToUpperInvariant(),
            command.QuantidadeEmbalagem,
            LimparTexto(command.FormaFarmaceutica),
            LimparTexto(command.DosagemTexto),
            LimparTexto(command.VolumeTexto),
            LimparTexto(command.ConcentracaoTexto),
            command.DescricaoApresentacao.Trim(),
            command.PrecoVenda,
            command.PermiteFracionamento,
            cancellationToken);
    }

    public async Task AtualizarApresentacaoAsync(
        AtualizarProdutoApresentacaoCommand command,
        CancellationToken cancellationToken)
    {
        if (command.Id <= 0)
            throw new DomainException("Apresentação inválida.");

        if (string.IsNullOrWhiteSpace(command.UnidadeMedida))
            throw new DomainException("Unidade de medida é obrigatória.");

        if (string.IsNullOrWhiteSpace(command.DescricaoApresentacao))
            throw new DomainException("Descrição da apresentação é obrigatória.");

        if (command.PrecoVenda < 0)
            throw new DomainException("Preço de venda inválido.");

        if (command.QuantidadeEmbalagem.HasValue && command.QuantidadeEmbalagem.Value < 0)
            throw new DomainException("Quantidade da embalagem inválida.");

        await _repository.AtualizarApresentacaoAsync(
            command.Id,
            LimparTexto(command.CodigoEan),
            command.UnidadeMedida.Trim().ToUpperInvariant(),
            command.QuantidadeEmbalagem,
            LimparTexto(command.FormaFarmaceutica),
            LimparTexto(command.DosagemTexto),
            LimparTexto(command.VolumeTexto),
            LimparTexto(command.ConcentracaoTexto),
            command.DescricaoApresentacao.Trim(),
            command.PrecoVenda,
            command.PermiteFracionamento,
            command.Ativo,
            cancellationToken);
    }

    public Task<ProdutoApresentacaoDto?> ObterApresentacaoPorIdAsync(long id, CancellationToken cancellationToken)
        => _repository.ObterApresentacaoPorIdAsync(id, cancellationToken);

    public Task<IReadOnlyList<ProdutoApresentacaoListItemDto>> ListarPorProdutoAsync(long produtoId, CancellationToken cancellationToken)
    {
        if (produtoId <= 0)
            throw new DomainException("Produto inválido.");

        return _repository.ListarPorProdutoAsync(produtoId, cancellationToken);
    }

    public async Task CadastrarMedicamentoDetalheAsync(
        CadastrarMedicamentoDetalheCommand command,
        CancellationToken cancellationToken)
    {
        ValidarMedicamentoDetalhe(
            command.ApresentacaoId,
            command.TipoMedicamento,
            command.Tarja);

        await _repository.InserirMedicamentoDetalheAsync(
            command.ApresentacaoId,
            command.TipoMedicamento.Trim().ToUpperInvariant(),
            LimparTexto(command.RegistroAnvisa),
            command.Tarja.Trim().ToUpperInvariant(),
            command.RequerReceita,
            command.RetencaoReceita,
            command.ControladoSngpc,
            command.Antimicrobiano,
            command.UsoContinuo,
            command.PermiteIntercambialidade,
            LimparTexto(command.Observacoes),
            cancellationToken);
    }

    public async Task AtualizarMedicamentoDetalheAsync(
        AtualizarMedicamentoDetalheCommand command,
        CancellationToken cancellationToken)
    {
        ValidarMedicamentoDetalhe(
            command.ApresentacaoId,
            command.TipoMedicamento,
            command.Tarja);

        await _repository.AtualizarMedicamentoDetalheAsync(
            command.ApresentacaoId,
            command.TipoMedicamento.Trim().ToUpperInvariant(),
            LimparTexto(command.RegistroAnvisa),
            command.Tarja.Trim().ToUpperInvariant(),
            command.RequerReceita,
            command.RetencaoReceita,
            command.ControladoSngpc,
            command.Antimicrobiano,
            command.UsoContinuo,
            command.PermiteIntercambialidade,
            LimparTexto(command.Observacoes),
            cancellationToken);
    }

    public Task<MedicamentoDetalheDto?> ObterMedicamentoDetalheAsync(long apresentacaoId, CancellationToken cancellationToken)
    {
        if (apresentacaoId <= 0)
            throw new DomainException("Apresentação inválida.");

        return _repository.ObterMedicamentoDetalheAsync(apresentacaoId, cancellationToken);
    }

    private static void ValidarMedicamentoDetalhe(long apresentacaoId, string tipoMedicamento, string tarja)
    {
        if (apresentacaoId <= 0)
            throw new DomainException("Apresentação inválida.");

        if (string.IsNullOrWhiteSpace(tipoMedicamento))
            throw new DomainException("Tipo de medicamento é obrigatório.");

        if (string.IsNullOrWhiteSpace(tarja))
            throw new DomainException("Tarja é obrigatória.");

        var tipoNormalizado = tipoMedicamento.Trim().ToUpperInvariant();
        var tarjaNormalizada = tarja.Trim().ToUpperInvariant();

        if (!TiposMedicamentoValidos.Contains(tipoNormalizado))
            throw new DomainException("Tipo de medicamento inválido.");

        if (!TarjasValidas.Contains(tarjaNormalizada))
            throw new DomainException("Tarja inválida.");
    }

    private static string? LimparTexto(string? valor)
        => string.IsNullOrWhiteSpace(valor) ? null : valor.Trim();
}
```

---

# 10. Controller

## `ProdutoApresentacoesController.cs`

```csharp
using FarmaLocal.Application.Commands.ProdutoApresentacao;
using FarmaLocal.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace FarmaLocal.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public sealed class ProdutoApresentacoesController : ControllerBase
{
    private readonly ProdutoApresentacaoAppService _service;

    public ProdutoApresentacoesController(ProdutoApresentacaoAppService service)
    {
        _service = service;
    }

    [HttpPost]
    public async Task<IActionResult> Post(
        [FromBody] CadastrarProdutoApresentacaoCommand command,
        CancellationToken cancellationToken)
    {
        var id = await _service.CadastrarApresentacaoAsync(command, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id }, new { id });
    }

    [HttpPut("{id:long}")]
    public async Task<IActionResult> Put(
        long id,
        [FromBody] AtualizarProdutoApresentacaoCommand command,
        CancellationToken cancellationToken)
    {
        await _service.AtualizarApresentacaoAsync(
            new AtualizarProdutoApresentacaoCommand
            {
                Id = id,
                CodigoEan = command.CodigoEan,
                UnidadeMedida = command.UnidadeMedida,
                QuantidadeEmbalagem = command.QuantidadeEmbalagem,
                FormaFarmaceutica = command.FormaFarmaceutica,
                DosagemTexto = command.DosagemTexto,
                VolumeTexto = command.VolumeTexto,
                ConcentracaoTexto = command.ConcentracaoTexto,
                DescricaoApresentacao = command.DescricaoApresentacao,
                PrecoVenda = command.PrecoVenda,
                PermiteFracionamento = command.PermiteFracionamento,
                Ativo = command.Ativo
            },
            cancellationToken);

        return NoContent();
    }

    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetById(long id, CancellationToken cancellationToken)
    {
        var item = await _service.ObterApresentacaoPorIdAsync(id, cancellationToken);

        if (item is null)
            return NotFound();

        return Ok(item);
    }

    [HttpGet("por-produto/{produtoId:long}")]
    public async Task<IActionResult> ListarPorProduto(long produtoId, CancellationToken cancellationToken)
    {
        var items = await _service.ListarPorProdutoAsync(produtoId, cancellationToken);
        return Ok(items);
    }

    [HttpPost("{apresentacaoId:long}/medicamento-detalhe")]
    public async Task<IActionResult> PostMedicamentoDetalhe(
        long apresentacaoId,
        [FromBody] CadastrarMedicamentoDetalheCommand command,
        CancellationToken cancellationToken)
    {
        await _service.CadastrarMedicamentoDetalheAsync(
            new CadastrarMedicamentoDetalheCommand
            {
                ApresentacaoId = apresentacaoId,
                TipoMedicamento = command.TipoMedicamento,
                RegistroAnvisa = command.RegistroAnvisa,
                Tarja = command.Tarja,
                RequerReceita = command.RequerReceita,
                RetencaoReceita = command.RetencaoReceita,
                ControladoSngpc = command.ControladoSngpc,
                Antimicrobiano = command.Antimicrobiano,
                UsoContinuo = command.UsoContinuo,
                PermiteIntercambialidade = command.PermiteIntercambialidade,
                Observacoes = command.Observacoes
            },
            cancellationToken);

        return NoContent();
    }

    [HttpPut("{apresentacaoId:long}/medicamento-detalhe")]
    public async Task<IActionResult> PutMedicamentoDetalhe(
        long apresentacaoId,
        [FromBody] AtualizarMedicamentoDetalheCommand command,
        CancellationToken cancellationToken)
    {
        await _service.AtualizarMedicamentoDetalheAsync(
            new AtualizarMedicamentoDetalheCommand
            {
                ApresentacaoId = apresentacaoId,
                TipoMedicamento = command.TipoMedicamento,
                RegistroAnvisa = command.RegistroAnvisa,
                Tarja = command.Tarja,
                RequerReceita = command.RequerReceita,
                RetencaoReceita = command.RetencaoReceita,
                ControladoSngpc = command.ControladoSngpc,
                Antimicrobiano = command.Antimicrobiano,
                UsoContinuo = command.UsoContinuo,
                PermiteIntercambialidade = command.PermiteIntercambialidade,
                Observacoes = command.Observacoes
            },
            cancellationToken);

        return NoContent();
    }

    [HttpGet("{apresentacaoId:long}/medicamento-detalhe")]
    public async Task<IActionResult> GetMedicamentoDetalhe(long apresentacaoId, CancellationToken cancellationToken)
    {
        var item = await _service.ObterMedicamentoDetalheAsync(apresentacaoId, cancellationToken);

        if (item is null)
            return NotFound();

        return Ok(item);
    }
}
```

---

# 11. Registro na DI

## `AddInfrastructure`

Adicione:

```csharp
services.AddScoped<IProdutoApresentacaoRepository, ProdutoApresentacaoRepository>();
```

## `AddApplication`

Adicione:

```csharp
services.AddScoped<ProdutoApresentacaoAppService>();
```

---

# 12. Exemplos de payload

## Cadastrar apresentação

### `POST /api/produtoapresentacoes`

```json
{
  "produtoId": 1,
  "codigoEan": "7891234567890",
  "skuInterno": "PARA750-CX20",
  "unidadeMedida": "CX",
  "quantidadeEmbalagem": 20,
  "formaFarmaceutica": "COMPRIMIDO",
  "dosagemTexto": "750MG",
  "volumeTexto": null,
  "concentracaoTexto": "750MG",
  "descricaoApresentacao": "Paracetamol 750mg caixa com 20 comprimidos",
  "precoVenda": 18.90,
  "permiteFracionamento": false
}
```

## Atualizar apresentação

### `PUT /api/produtoapresentacoes/1`

```json
{
  "codigoEan": "7891234567890",
  "unidadeMedida": "CX",
  "quantidadeEmbalagem": 20,
  "formaFarmaceutica": "COMPRIMIDO",
  "dosagemTexto": "750MG",
  "volumeTexto": null,
  "concentracaoTexto": "750MG",
  "descricaoApresentacao": "Paracetamol 750mg caixa com 20 comprimidos - atualizado",
  "precoVenda": 19.50,
  "permiteFracionamento": false,
  "ativo": true
}
```

## Cadastrar detalhe de medicamento

### `POST /api/produtoapresentacoes/1/medicamento-detalhe`

```json
{
  "tipoMedicamento": "GENERICO",
  "registroAnvisa": "1234567890012",
  "tarja": "SEM_TARJA",
  "requerReceita": false,
  "retencaoReceita": false,
  "controladoSngpc": false,
  "antimicrobiano": false,
  "usoContinuo": false,
  "permiteIntercambialidade": true,
  "observacoes": "Medicamento isento de retenção"
}
```

## Atualizar detalhe de medicamento

### `PUT /api/produtoapresentacoes/1/medicamento-detalhe`

```json
{
  "tipoMedicamento": "GENERICO",
  "registroAnvisa": "1234567890012",
  "tarja": "AMARELA",
  "requerReceita": true,
  "retencaoReceita": false,
  "controladoSngpc": false,
  "antimicrobiano": true,
  "usoContinuo": false,
  "permiteIntercambialidade": true,
  "observacoes": "Atualizado para teste de regra"
}
```

---

# 13. Observações importantes

Há três pontos que vale deixar alinhados agora:

## 1. unicidade de `codigo_ean`

No banco você já previu unique parcial.
Ótimo para evitar duplicidade de apresentação comercial.

## 2. `sku_interno` não deve ser alterado no update

Eu mantive o update sem alterar `sku_interno`. Isso é bom porque:

* SKU costuma ser identidade operacional
* trocar SKU no meio pode quebrar integrações e estoque

## 3. detalhe de medicamento pressupõe que a apresentação já exista

Ou seja:

* primeiro cria `produto`
* depois cria `produto_apresentacao`
* depois cria `medicamento_detalhe`

Esse fluxo está correto.

---

# 14. Primeira etapa fechada

Com este módulo, a **primeira etapa do FarmaLocal** fica fechada de forma coerente.

## O que já está pronto

### Banco

* DER técnico completo
* dicionário de dados
* script PostgreSQL
* constraints e índices
* seeds iniciais

### Backend base

* solution em camadas
* API ASP.NET Core
* Dapper
* connection factory
* unit of work
* middleware global de erro
* DI

### Catálogo

* produto
* produto_apresentacao
* medicamento_detalhe

### Estoque

* lote_estoque
* movimento_estoque
* entrada de lote
* consulta de lotes
* FEFO

### Venda

* venda
* venda_item
* pagamento
* receita_venda_item
* venda transacional
* cancelamento com estorno

---

# 15. Checklist oficial da etapa 1

## Etapa 1 — Core operacional do FarmaLocal

* [x] modelagem do domínio
* [x] banco PostgreSQL inicial
* [x] projeto .NET organizado
* [x] módulo de produto
* [x] módulo de apresentação
* [x] módulo de medicamento
* [x] módulo de estoque
* [x] módulo de venda
* [x] FEFO
* [x] receita por item
* [x] cancelamento com reposição de estoque

**Status:** etapa 1 concluída.

---

# 16. O que eu recomendo para a etapa 2

A etapa 2 ideal seria:

* autenticação/autorização
* usuário real logado nos endpoints
* cliente + convênio completos
* substância ativa + relação da apresentação
* relatórios operacionais
* auditoria
* testes de integração
* dockerização da API + PostgreSQL

A ordem que eu recomendo é:

**1. substância ativa + apresentacao_substancia**
**2. cliente + convênio**
**3. autenticação**
**4. relatórios**

Se você quiser, no próximo passo eu monto o **documento de fechamento da Etapa 1**, em formato profissional, com:

* escopo entregue
* arquitetura adotada
* módulos concluídos
* pendências da etapa 2
* riscos e próximos passos.
