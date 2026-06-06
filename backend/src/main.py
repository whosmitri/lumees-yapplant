# importando bibliotecas
import os
import pickle
from fastapi import FastAPI, HTTPException
from fastapi.testclient import TestClient
from pydantic import BaseModel
import uvicorn


# definimos o contrato de entrada. o flutter DEVE mandar esses 3 dados:
class RequisicaoAnalise(BaseModel):
    uid: str # ID do usuário dono da planta (Firebase Auth)
    id_planta: str # ID específico daquela plantinha no banco
    id_especie: str # Ex: "Suculenta", "Salsinha", "Cebolinha", "Lírio da Paz"
    umidade_solo_bruto: float # dado instantâneo do sensor
    umidade_ha_7_dias: float # média histórica do Firebase

# iniciando o app do FastAPI
app = FastAPI(title="Lumees API - IA")

# mapeamento dos modelos para sabermos qual arquivo abrir na pasta
ARQUIVOS_MODELOS = {
    "suculenta": "lee_suculenta.pkl",
    "salsinha": "lee_salsinha.pkl",
    "cebolinha": "lee_cebolinha.pkl",
    "lirio-da-paz": "lee_lirio_paz.pkl"
}

# caminho da pasta onde estão os .pkl
PASTA_MODELS = os.path.join("backend", "src", "models")

# dicionário onde vamos guardar os modelos carregados na memória do PC (para agilizar processo)
modelos_carregados = {}

# loop para API só ler os arquivos uma vez: quando inicial. depois disso o modelo já estará na memória RAM e quando o usuário requisitar o backend pode responder em alguns segundos
print("Carregando os cérebros do Lee na memória...")
for especie, nome_arquivo in ARQUIVOS_MODELOS.items():
    caminho_completo = os.path.join(PASTA_MODELS, nome_arquivo)
    
    if os.path.exists(caminho_completo):
        with open(caminho_completo, 'rb') as arquivo:
            modelos_carregados[especie] = pickle.load(arquivo)
        print(f"Lee para {especie} pronto para uso!")
    else:
        print(f"ALERTA: O arquivo {nome_arquivo} não foi encontrado.")

# criando a rota de análise
@app.post("/lumees-api/v1/ia/analise")
def analisar_planta(dados: RequisicaoAnalise):
    # validando se a espécie enviada existe no modelo
    if dados.id_especie not in modelos_carregados:
        raise HTTPException(
            status_code=400, 
            detail=f"A espécie '{dados.id_especie}' não é suportada por nenhum modelo treinado."
        )
    
    # return com dados fixos por enquanto
    return {
        "status": "Recebido",
        "mensagem": f"Dados da planta {dados.id_planta} recebidos. O ID do dono é {dados.uid}."
    }