USE [farmalocal];
GO

DBCC CHECKIDENT ('farmalocal.filial', RESEED);
DBCC CHECKIDENT ('farmalocal.categoria', RESEED);
DBCC CHECKIDENT ('farmalocal.fabricante', RESEED);
DBCC CHECKIDENT ('farmalocal.fornecedor', RESEED);
DBCC CHECKIDENT ('farmalocal.substancia_ativa', RESEED);
DBCC CHECKIDENT ('farmalocal.cliente', RESEED);
DBCC CHECKIDENT ('farmalocal.convenio', RESEED);
DBCC CHECKIDENT ('farmalocal.usuario', RESEED);
DBCC CHECKIDENT ('farmalocal.produto', RESEED);
DBCC CHECKIDENT ('farmalocal.produto_apresentacao', RESEED);
DBCC CHECKIDENT ('farmalocal.apresentacao_substancia', RESEED);
DBCC CHECKIDENT ('farmalocal.produto_atributo_extra', RESEED);
DBCC CHECKIDENT ('farmalocal.cliente_convenio', RESEED);
DBCC CHECKIDENT ('farmalocal.lote_estoque', RESEED);
DBCC CHECKIDENT ('farmalocal.movimento_estoque', RESEED);
DBCC CHECKIDENT ('farmalocal.venda', RESEED);
DBCC CHECKIDENT ('farmalocal.venda_item', RESEED);
DBCC CHECKIDENT ('farmalocal.pagamento', RESEED);
DBCC CHECKIDENT ('farmalocal.receita_venda_item', RESEED);
DBCC CHECKIDENT ('farmalocal.auditoria_log', RESEED);
GO
