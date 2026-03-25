/*
  Template de importação CSV para SQL Server.
  Ajuste:
  1) USE [farmalocal];
  2) @data_dir
  3) nomes/colunas conforme seus CSVs
  4) permissões de acesso do serviço do SQL Server à pasta
*/

USE [farmalocal];
GO

DECLARE @data_dir NVARCHAR(4000) = N'C:\dados\farmalocal_mock_csv';
DECLARE @sql NVARCHAR(MAX);

-- Exemplo: produto.csv
SET @sql = N'
BULK INSERT farmalocal.produto
FROM ''' + @data_dir + N'\produto.csv''
WITH
(
    FORMAT = ''CSV'',
    FIRSTROW = 2,
    FIELDQUOTE = ''"'',
    CODEPAGE = ''65001'',
    TABLOCK
);';
PRINT @sql;
-- EXEC sp_executesql @sql;
GO

-- Exemplo: produto_apresentacao.csv
DECLARE @data_dir2 NVARCHAR(4000) = N'C:\dados\farmalocal_mock_csv';
DECLARE @sql2 NVARCHAR(MAX);

SET @sql2 = N'
BULK INSERT farmalocal.produto_apresentacao
FROM ''' + @data_dir2 + N'\produto_apresentacao.csv''
WITH
(
    FORMAT = ''CSV'',
    FIRSTROW = 2,
    FIELDQUOTE = ''"'',
    CODEPAGE = ''65001'',
    TABLOCK
);';
PRINT @sql2;
-- EXEC sp_executesql @sql2;
GO

/*
  Ordem recomendada para importação:
  1. filial
  2. categoria
  3. fabricante
  4. fornecedor
  5. substancia_ativa
  6. cliente
  7. convenio
  8. usuario
  9. produto
  10. produto_apresentacao
  11. apresentacao_substancia
  12. medicamento_detalhe
  13. equipamento_detalhe
  14. produto_atributo_extra
  15. cliente_convenio
  16. lote_estoque
  17. movimento_estoque
  18. venda
  19. venda_item
  20. pagamento
  21. receita_venda_item
  22. auditoria_log
*/
