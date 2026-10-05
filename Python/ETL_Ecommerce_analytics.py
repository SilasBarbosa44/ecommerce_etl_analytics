import pandas as pd
import logging
from datetime import datetime
from sqlalchemy import create_engine

engine = create_engine("mysql+mysqlconnector://root:@localhost:3306/ETL_ecommerce_analytics")

logging.basicConfig(level=logging.INFO,
                    format="%(message)s - %(levelname)s - %(asctime)s")

logger = logging.getLogger(__name__)

def extrair_dados():
    try:
        
        arquivos = {"clientes":"clientes.xlsx",
                    "vendedores":"vendedores.xlsx",
                    "produtos":"produtos.xlsx",
                    "pedidos":"pedidos.xlsx",
                    "itens_pedido":"itens_pedido.xlsx"}
        
        dfs = {}
        
        for nome, path in arquivos.items():
            dfs[nome] = pd.read_excel(path)
            logger.info(f"Planilhas {nome} carregada com sucesso ! | {len(dfs[nome])}")
            
        return dfs
    except Exception as e:
        logger.exception(f"Erro ao carregar planilhas {e}")
        return None
    
def transformar_clientes(df):
    df = df.copy()
    
    df["id_cliente"] = pd.to_numeric(df["id_cliente"], errors="coerce")
    df["nome"] = df["nome"].str.strip().str.lower()
    df["email"] = df["email"].str.strip().str.lower()
    df["cidade"] = df["cidade"].str.strip().str.title()
    df["estado"] = df["estado"].str.strip().str.upper()
    
    df["data_cadastro"] = pd.to_datetime(df["data_cadastro"], errors="coerce")
    
    return df.dropna(subset=["id_cliente", "nome", "email", "cidade", "estado", "data_cadastro"])

def transformar_vendedores(df):
    df = df.copy()
    df["id_vendedor"] = pd.to_numeric(df["id_vendedor"], errors="coerce")
    df["nome"] = df["nome"].str.strip().str.lower()
    df["departamento"] = df["departamento"].str.strip().str.title()
    
    return df.dropna(subset=["id_vendedor", "nome", "departamento"])

def transformar_produtos(df):
    df = df.copy()
    df["id_produto"] = pd.to_numeric(df["id_produto"], errors="coerce")
    df["nome_produto"] = df["nome_produto"].str.strip().str.lower()
    df["categoria"] = df["categoria"].str.strip().str.title()
    df["estoque"] = pd.to_numeric(df["estoque"], errors="coerce")
    
    df["preco"] = (df["preco"].astype("string")
                   .str.replace("R$", "", regex=False)
                   .str.replace(".", "", regex=False)
                   .str.replace(",", ".", regex=False)
                   .str.strip())
    
    df["preco"] = pd.to_numeric(df["preco"], errors="coerce")
    
    df = df[df["preco"] >= 0]
    
    df["custo"] = (df["custo"].astype("string")
                   .str.replace("R$", "", regex=False)
                   .str.replace(".", "", regex=False)
                   .str.replace(",", ".", regex=False)
                   .str.strip())
    
    df["custo"] = pd.to_numeric(df["custo"], errors="coerce")
    
    df = df[df["custo"] >= 0]
    
    df = df[df["estoque"] >= 0]
    
    return df.dropna(subset=["id_produto", "nome_produto", "categoria", 
                             "estoque", "preco", "custo"])
    
def transformar_pedidos(df):
    df = df.copy()
    df["id_pedido"] = pd.to_numeric(df["id_pedido"], errors="coerce")
    df["id_cliente"] = pd.to_numeric(df["id_cliente"], errors="coerce")
    df["id_vendedor"] = pd.to_numeric(df["id_vendedor"], errors="coerce")
    df["data_pedido"] = pd.to_datetime(df["data_pedido"], errors="coerce")
    df["status"] = df["status"].str.strip().str.lower()
    
    return df.dropna(subset=["id_pedido", "id_cliente", "id_vendedor", 
                             "data_pedido", "status"])
    
def transformar_itens_pedido(df):
    df = df.copy()
    df["id_item"] = pd.to_numeric(df["id_item"], errors="coerce")
    df["id_pedido"] = pd.to_numeric(df["id_pedido"], errors="coerce")
    df["id_produto"] = pd.to_numeric(df["id_produto"], errors="coerce")
    df["quantidade"] = pd.to_numeric(df["quantidade"], errors="coerce")
    
    df["preco_unitario"] = (df["preco_unitario"].astype("string")
                            .str.replace("R$", "", regex=False)
                            .str.replace(".", "", regex=False)
                            .str.replace(",", ".", regex=False)
                            .str.strip())
    
    df["preco_unitario"] = pd.to_numeric(df["preco_unitario"], errors="coerce")
    
    df = df[df["preco_unitario"] >= 0]
    
    return df.dropna(subset=["id_item", "id_pedido", "id_produto", 
                             "quantidade", "preco_unitario"])
    
    
def carregar_dados(dfs:dict):
    try:
        for nome, df in dfs.items():
            df.to_sql(nome, con=engine, if_exists="append", index=False)
            logger.info(f"Dados da planilha carregado no Banco de dados {nome} carregado com sucesso ! | {len(dfs[nome])}")
        return True
    except Exception as e:
        logger.exception(f"Erro ao carregar dados {e} !")
        return False
    
def main():
    inicio = datetime.now()
    dfs = extrair_dados()
    if dfs is None:
        return
    
    dfs["clientes"] = transformar_clientes(dfs["clientes"])
    dfs["vendedores"] = transformar_vendedores(dfs["vendedores"])
    dfs["produtos"] = transformar_produtos(dfs["produtos"])
    dfs["pedidos"] = transformar_pedidos(dfs["pedidos"])
    dfs["itens_pedido"] = transformar_itens_pedido(dfs["itens_pedido"])
    
    if any(df is None or df.empty for df in dfs.values()):
        logger.error("Alguma tabela esta vazia Abortando ETL ")
        return 
    
    carregar_dados(dfs)
    
    fim = datetime.now()
    
    logger.info(f"ETL finalizado em {fim.strftime("%Y/%m/%d")} duração {fim - inicio}")
    
if __name__ == "__main__":
    main()