# Modelo e Arquitetura — FarmaLocal

Este documento cobre:

- arquitetura da solução
- organização dos projetos
- responsabilidades por camada
- padrão de acesso com Dapper
- fluxo de transação
- convenções
- sugestão de pastas
- primeiros módulos para começar certo

---

## 1. Arquitetura recomendada

Para o FarmaLocal, a base recomendada é:

### Estilo arquitetural

**Clean Architecture simplificada + modularização por domínio**

Isso oferece:

- separação clara de responsabilidades
- facilidade para trocar banco
- facilidade para criar API, desktop e futuras versões
- boa base para Dapper sem engessar o projeto

### Camadas

- **FarmaLocal.Domain**
- **FarmaLocal.Application**
- **FarmaLocal.Infrastructure**
- **FarmaLocal.Api**
- **FarmaLocal.Shared** (opcional)
- **FarmaLocal.Desktop** (no futuro)

---

## 2. Estrutura da solution

```
FarmaLocal.sln

src/
  FarmaLocal.Domain/
  FarmaLocal.Application/
  FarmaLocal.Infrastructure/
  FarmaLocal.Api/
  FarmaLocal.Shared/

tests/
  FarmaLocal.UnitTests/
  FarmaLocal.IntegrationTests/

database/
  postgresql/
    migrations/
    seeds/
    views/
    functions/
    queries/

docs/
  arquitetura/
  dominio/
  banco/
```

---

## 3. Responsabilidade de cada projeto

### `FarmaLocal.Domain`

Contém o núcleo do negócio.

**Deve ter:**

- entidades
- enums
- value objects simples
- regras de negócio centrais
- contratos que pertencem ao domínio
- exceções de domínio

**Exemplos:**

- `Produto`
- `ProdutoApresentacao`
- `MedicamentoDetalhe`
- `LoteEstoque`
- `Venda`
- `VendaItem`
- `Pagamento`
- `Cliente`

---

### `FarmaLocal.Application`

Orquestra os casos de uso.

**Deve ter:**

- services de aplicação
- commands e queries
- DTOs
- interfaces de repositório
- validators
- handlers simples
- contratos transacionais

**Exemplos:**

- `CadastrarProdutoCommand`
- `RegistrarEntradaEstoqueCommand`
- `RealizarVendaCommand`
- `BuscarProdutoPorTermoQuery`
- `IVendaAppService`
- `IProdutoRepository`
- `ILoteRepository`
- `IUnitOfWork`

---

### `FarmaLocal.Infrastructure`

Implementação técnica.

**Deve ter:**

- acesso ao banco com Dapper
- connection factory
- transaction manager
- repositories
- scripts SQL externos, se necessário
- implementações de serviços externos

**Exemplos:**

- `NpgsqlConnectionFactory`
- `DapperContext`
- `ProdutoRepository`
- `VendaRepository`
- `LoteRepository`
- `UnitOfWork`

---

### `FarmaLocal.Api`

Camada de entrada HTTP.

**Deve ter:**

- controllers
- DI
- middlewares
- filters
- autenticação
- mapeamento de rotas
- tratamento de erros

---

### `FarmaLocal.Shared`

Opcional, mas útil.

**Pode conter:**

- Result pattern
- paginação
- resposta padrão
- utilitários
- abstrações compartilhadas

---

## 4. Estrutura interna dos projetos

### `FarmaLocal.Domain`

```
FarmaLocal.Domain/
  Entities/
    Filial.cs
    Usuario.cs
    Categoria.cs
    Fabricante.cs
    Fornecedor.cs
    SubstanciaAtiva.cs
    Produto.cs
    ProdutoApresentacao.cs
    MedicamentoDetalhe.cs
    EquipamentoDetalhe.cs
    ProdutoAtributoExtra.cs
    Cliente.cs
    Convenio.cs
    ClienteConvenio.cs
    LoteEstoque.cs
    MovimentoEstoque.cs
    Venda.cs
    VendaItem.cs
    Pagamento.cs
    ReceitaVendaItem.cs

  Enums/
    TipoProduto.cs
    TipoMedicamento.cs
    TarjaMedicamento.cs
    TipoMovimentoEstoque.cs
    StatusVenda.cs
    TipoPagamento.cs
    PerfilUsuario.cs

  ValueObjects/
    DocumentoCpf.cs
    DocumentoCnpj.cs
    EmailAddress.cs

  Exceptions/
    DomainException.cs

  Services/
    VendaDomainService.cs
```

---

### `FarmaLocal.Application`

```
FarmaLocal.Application/
  Abstractions/
    Data/
      IDbConnectionFactory.cs
      IUnitOfWork.cs
    Repositories/
      IProdutoRepository.cs
      IEstoqueRepository.cs
      IVendaRepository.cs
      IClienteRepository.cs
      ICategoriaRepository.cs
      ISubstanciaAtivaRepository.cs

  DTOs/
    Produto/
    Estoque/
    Venda/
    Cliente/

  Commands/
    Produto/
      CadastrarProdutoCommand.cs
      AtualizarProdutoCommand.cs
    Estoque/
      RegistrarEntradaLoteCommand.cs
    Venda/
      RealizarVendaCommand.cs
      CancelarVendaCommand.cs

  Queries/
    Produto/
      BuscarProdutosQuery.cs
      ObterProdutoPorIdQuery.cs
    Estoque/
      ListarLotesPorApresentacaoQuery.cs
    Venda/
      ObterVendaPorIdQuery.cs

  Services/
    ProdutoAppService.cs
    EstoqueAppService.cs
    VendaAppService.cs

  Validators/
    RealizarVendaValidator.cs
    CadastrarProdutoValidator.cs
```

---

### `FarmaLocal.Infrastructure`

```
FarmaLocal.Infrastructure/
  Persistence/
    Dapper/
      DapperContext.cs
      NpgsqlConnectionFactory.cs
      UnitOfWork.cs
      SqlConstants.cs

    Repositories/
      ProdutoRepository.cs
      EstoqueRepository.cs
      VendaRepository.cs
      ClienteRepository.cs
      CategoriaRepository.cs
      SubstanciaAtivaRepository.cs

    Queries/
      ProdutoSql.cs
      EstoqueSql.cs
      VendaSql.cs
      ClienteSql.cs

  DependencyInjection/
    InfrastructureServiceCollectionExtensions.cs
```

---

### `FarmaLocal.Api`

```
FarmaLocal.Api/
  Controllers/
    ProdutosController.cs
    EstoqueController.cs
    VendasController.cs
    ClientesController.cs

  Middlewares/
    ExceptionHandlingMiddleware.cs

  Filters/
  Extensions/
    ServiceCollectionExtensions.cs
    ApplicationBuilderExtensions.cs

  Models/
    Requests/
    Responses/

  Program.cs
  appsettings.json
  appsettings.Development.json
```

---

## 5. Padrão para entidades do domínio

Como o projeto usa Dapper, o domínio pode ser mais enxuto.

### Exemplo: `Produto`

```csharp
public class Produto
{
    public long Id { get; private set; }
    public long CategoriaId { get; private set; }
    public long FabricanteId { get; private set; }
    public string CodigoInterno { get; private set; } = string.Empty;
    public string? NomeComercial { get; private set; }
    public string NomeReduzido { get; private set; } = string.Empty;
    public string? Descricao { get; private set; }
    public TipoProduto TipoProduto { get; private set; }
    public bool Ativo { get; private set; }

    public void Ativar() => Ativo = true;
    public void Inativar() => Ativo = false;
}
```

Com Dapper, não é necessário exagerar em entidade rica no início. O ideal é um domínio **coeso e legível**, sem virar anêmico demais nem complexo cedo demais.

---

## 6. Padrão para enums

Recomenda-se usar enums em C# e `varchar` controlado no banco.

### Exemplo

```csharp
public enum TipoProduto
{
    Medicamento = 1,
    Higiene     = 2,
    Perfumaria  = 3,
    Equipamento = 4,
    Correlato   = 5,
    Suplemento  = 6
}
```

No banco, grava-se texto. Na aplicação, pode-se mapear texto ↔ enum com conversores ou métodos auxiliares.

### Alternativa mais simples

Manter tudo como string no começo para reduzir fricção no Dapper. Para MVP com Dapper, isso costuma ser mais prático.

---

## 7. Padrão de repositório com Dapper

Com Dapper, repositório precisa ser **SQL-first**, não ORM-first.

### O que isso significa

- queries claras
- joins explícitos
- SQL controlado pelo desenvolvedor
- retorno com DTO quando fizer mais sentido que entidade

### Exemplo de interface

```csharp
public interface IProdutoRepository
{
    Task<long> InserirAsync(Produto produto, CancellationToken cancellationToken);
    Task<Produto?> ObterPorIdAsync(long id, CancellationToken cancellationToken);
    Task<IReadOnlyList<ProdutoListItemDto>> BuscarAsync(string termo, CancellationToken cancellationToken);
}
```

### Exemplo de implementação

```csharp
public class ProdutoRepository : IProdutoRepository
{
    private readonly IDbConnectionFactory _connectionFactory;
    private readonly IUnitOfWork _unitOfWork;

    public ProdutoRepository(IDbConnectionFactory connectionFactory, IUnitOfWork unitOfWork)
    {
        _connectionFactory = connectionFactory;
        _unitOfWork = unitOfWork;
    }

    public async Task<long> InserirAsync(Produto produto, CancellationToken cancellationToken)
    {
        const string sql = """
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

        var connection = _unitOfWork.Connection;
        var transaction = _unitOfWork.Transaction;

        return await connection.ExecuteScalarAsync<long>(
            new CommandDefinition(
                sql,
                new
                {
                    produto.CategoriaId,
                    produto.FabricanteId,
                    produto.CodigoInterno,
                    produto.NomeComercial,
                    produto.NomeReduzido,
                    produto.Descricao,
                    TipoProduto = produto.TipoProduto.ToString().ToUpperInvariant(),
                    produto.Ativo
                },
                transaction,
                cancellationToken: cancellationToken
            ));
    }

    public async Task<Produto?> ObterPorIdAsync(long id, CancellationToken cancellationToken)
    {
        const string sql = """
            select
                p.id,
                p.categoria_id as CategoriaId,
                p.fabricante_id as FabricanteId,
                p.codigo_interno as CodigoInterno,
                p.nome_comercial as NomeComercial,
                p.nome_reduzido as NomeReduzido,
                p.descricao as Descricao,
                p.tipo_produto as TipoProduto,
                p.ativo as Ativo
            from farmalocal.produto p
            where p.id = @Id;
            """;

        var connection = _connectionFactory.CreateConnection();

        return await connection.QuerySingleOrDefaultAsync<Produto>(
            new CommandDefinition(sql, new { Id = id }, cancellationToken: cancellationToken));
    }

    public async Task<IReadOnlyList<ProdutoListItemDto>> BuscarAsync(string termo, CancellationToken cancellationToken)
    {
        const string sql = """
            select
                p.id,
                p.codigo_interno as CodigoInterno,
                coalesce(p.nome_comercial, p.nome_reduzido) as NomeExibicao,
                p.tipo_produto as TipoProduto,
                f.nome_fantasia as Fabricante
            from farmalocal.produto p
            inner join farmalocal.fabricante f on f.id = p.fabricante_id
            where
                p.nome_comercial ilike @Termo
                or p.nome_reduzido ilike @Termo
            order by p.nome_reduzido;
            """;

        var connection = _connectionFactory.CreateConnection();

        var result = await connection.QueryAsync<ProdutoListItemDto>(
            new CommandDefinition(sql, new { Termo = $"%{termo}%" }, cancellationToken: cancellationToken));

        return result.ToList();
    }
}
```

---

## 8. Unit of Work com Dapper

Para o FarmaLocal, isso é essencial por causa da venda e do estoque.

### Interface

```csharp
public interface IUnitOfWork : IAsyncDisposable
{
    IDbConnection Connection { get; }
    IDbTransaction? Transaction { get; }

    Task BeginAsync(CancellationToken cancellationToken = default);
    Task CommitAsync(CancellationToken cancellationToken = default);
    Task RollbackAsync(CancellationToken cancellationToken = default);
}
```

### Implementação

- abre conexão
- inicia transação
- compartilha a mesma conexão entre repositórios
- commit/rollback centralizado

Isso é crítico para:

- inserir venda
- inserir itens
- inserir pagamentos
- baixar lote
- registrar movimento de estoque

Tudo no mesmo contexto transacional.

---

## 9. Fluxo transacional de venda

Essa é a operação mais importante do sistema.

### Passo a passo ideal

1. validar request
2. abrir transação
3. criar cabeçalho da venda
4. para cada item:
   - validar apresentação
   - localizar lote FEFO
   - validar quantidade disponível
   - inserir item
   - validar se exige receita
   - inserir receita quando necessária
   - baixar lote
   - registrar movimento de estoque
5. inserir pagamentos
6. validar total financeiro
7. atualizar status da venda para `FINALIZADA`
8. commit

### Se falhar em qualquer etapa

- rollback

---

## 10. Serviço de aplicação de venda

### Exemplo de orquestração

```csharp
public class VendaAppService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IVendaRepository _vendaRepository;
    private readonly IEstoqueRepository _estoqueRepository;

    public VendaAppService(
        IUnitOfWork unitOfWork,
        IVendaRepository vendaRepository,
        IEstoqueRepository estoqueRepository)
    {
        _unitOfWork = unitOfWork;
        _vendaRepository = vendaRepository;
        _estoqueRepository = estoqueRepository;
    }

    public async Task<long> RealizarVendaAsync(RealizarVendaCommand command, CancellationToken cancellationToken)
    {
        await _unitOfWork.BeginAsync(cancellationToken);

        try
        {
            var vendaId = await _vendaRepository.InserirCabecalhoAsync(command, cancellationToken);

            foreach (var item in command.Itens)
            {
                var lote = await _estoqueRepository.ObterLoteFefoDisponivelAsync(
                    command.FilialId,
                    item.ApresentacaoId,
                    item.Quantidade,
                    cancellationToken);

                if (lote is null)
                    throw new InvalidOperationException("Estoque insuficiente para a apresentação informada.");

                var vendaItemId = await _vendaRepository.InserirItemAsync(vendaId, item, lote.Id, cancellationToken);

                if (item.Receita is not null)
                {
                    await _vendaRepository.InserirReceitaAsync(vendaItemId, item.Receita, cancellationToken);
                }

                await _estoqueRepository.BaixarEstoqueAsync(
                    lote.Id,
                    item.Quantidade,
                    cancellationToken);

                await _estoqueRepository.RegistrarMovimentoSaidaAsync(
                    lote.Id,
                    item.Quantidade,
                    "VENDA",
                    cancellationToken);
            }

            await _vendaRepository.InserirPagamentosAsync(vendaId, command.Pagamentos, cancellationToken);
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
}
```

---

## 11. Organização de SQL

Com Dapper, vale muito a pena não deixar SQL espalhado.

### Estrutura recomendada

```
Infrastructure/
  Persistence/
    Queries/
      ProdutoSql.cs
      EstoqueSql.cs
      VendaSql.cs
```

### Exemplo

```csharp
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
}
```

Isso melhora:

- manutenção
- leitura
- reutilização
- testes

---

## 12. Connection Factory

### Interface

```csharp
public interface IDbConnectionFactory
{
    IDbConnection CreateConnection();
}
```

### Implementação PostgreSQL

```csharp
using System.Data;
using Npgsql;

public class NpgsqlConnectionFactory : IDbConnectionFactory
{
    private readonly string _connectionString;

    public NpgsqlConnectionFactory(string connectionString)
    {
        _connectionString = connectionString;
    }

    public IDbConnection CreateConnection()
        => new NpgsqlConnection(_connectionString);
}
```

---

## 13. Injeção de dependência

### Exemplo

```csharp
public static class InfrastructureServiceCollectionExtensions
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string não configurada.");

        services.AddSingleton<IDbConnectionFactory>(_ => new NpgsqlConnectionFactory(connectionString));

        services.AddScoped<IUnitOfWork, UnitOfWork>();

        services.AddScoped<IProdutoRepository, ProdutoRepository>();
        services.AddScoped<IEstoqueRepository, EstoqueRepository>();
        services.AddScoped<IVendaRepository, VendaRepository>();
        services.AddScoped<IClienteRepository, ClienteRepository>();

        return services;
    }
}
```

---

## 14. Controllers iniciais

### `ProdutosController`

Endpoints iniciais:

- `POST /api/produtos`
- `GET /api/produtos/{id}`
- `GET /api/produtos?termo=`

### `EstoqueController`

- `POST /api/estoque/lotes`
- `GET /api/estoque/lotes?apresentacaoId=&filialId=`
- `GET /api/estoque/produtos-vencendo`

### `VendasController`

- `POST /api/vendas`
- `GET /api/vendas/{id}`
- `POST /api/vendas/{id}/cancelar`

### `ClientesController`

- `POST /api/clientes`
- `GET /api/clientes/{id}`
- `GET /api/clientes?termo=`

---

## 15. DTOs recomendados

### Produto

```csharp
public sealed class ProdutoListItemDto
{
    public long Id { get; init; }
    public string CodigoInterno { get; init; } = string.Empty;
    public string NomeExibicao { get; init; } = string.Empty;
    public string TipoProduto { get; init; } = string.Empty;
    public string Fabricante { get; init; } = string.Empty;
}
```

### Venda

```csharp
public sealed class RealizarVendaCommand
{
    public long FilialId { get; init; }
    public long? ClienteId { get; init; }
    public long UsuarioId { get; init; }
    public long? ConvenioId { get; init; }
    public List<RealizarVendaItemCommand> Itens { get; init; } = [];
    public List<RealizarPagamentoCommand> Pagamentos { get; init; } = [];
}

public sealed class RealizarVendaItemCommand
{
    public long ApresentacaoId { get; init; }
    public decimal Quantidade { get; init; }
    public decimal PrecoUnitario { get; init; }
    public decimal Desconto { get; init; }
    public ReceitaItemCommand? Receita { get; init; }
}

public sealed class RealizarPagamentoCommand
{
    public string TipoPagamento { get; init; } = string.Empty;
    public decimal Valor { get; init; }
}
```

---

## 16. Convenções importantes

### Convenções de código

- namespaces alinhados ao projeto
- classes pequenas
- um caso de uso por método principal
- SQL explícito
- DTO para leitura
- entidade para regra

### Convenções de banco

- sempre usar schema `farmalocal`
- sempre nomear constraints
- migrations numeradas:
  - `001_init.sql`
  - `002_indexes_extra.sql`
  - `003_views.sql`

### Convenções de aplicação

- toda operação de escrita importante com transação
- toda venda validada antes de commit
- toda baixa de estoque gera movimento

---

## 17. Ordem certa de implementação no backend

### Fase 1 — Base técnica

- solution
- projetos
- DI
- connection factory
- unit of work
- middleware global de exceção

### Fase 2 — Catálogo

- categoria
- fabricante
- substância ativa
- produto
- apresentação
- medicamento_detalhe

### Fase 3 — Estoque

- lote_estoque
- movimento_estoque
- consulta FEFO

### Fase 4 — Venda

- venda
- venda_item
- pagamento
- receita_venda_item
- fluxo transacional completo

### Fase 5 — Complementos

- cliente
- convênio
- relatórios
- auditoria

---

## 18. Recomendação prática para começar

Se quiser começar do jeito mais eficiente, faça nesta ordem:

1. subir o banco com o script já montado
2. criar a solution .NET
3. implementar `IDbConnectionFactory`
4. implementar `UnitOfWork`
5. implementar módulo de `Produto`
6. implementar módulo de `LoteEstoque`
7. implementar `RealizarVenda`

Essa sequência gera resultado visível rápido e já ataca o coração do sistema.

---

## 19. Estrutura final resumida

```
FarmaLocal.sln
│
├── src
│   ├── FarmaLocal.Domain
│   ├── FarmaLocal.Application
│   ├── FarmaLocal.Infrastructure
│   ├── FarmaLocal.Api
│   └── FarmaLocal.Shared
│
├── tests
│   ├── FarmaLocal.UnitTests
│   └── FarmaLocal.IntegrationTests
│
├── database
│   └── postgresql
│       ├── migrations
│       ├── seeds
│       ├── views
│       └── functions
│
└── docs
    ├── arquitetura
    ├── dominio
    └── banco
```

---

## 20. Fechamento

Com isso, o FarmaLocal fica com uma base muito boa para:

- PostgreSQL
- .NET
- Dapper
- API REST
- expansão futura para desktop
- espelhamento posterior em SQL Server

O próximo passo mais útil é a **estrutura inicial do código**, com:

- `Program.cs`
- DI
- `IDbConnectionFactory`
- `UnitOfWork`
- primeiro repositório com Dapper
- primeiro controller
- primeiro caso de uso
