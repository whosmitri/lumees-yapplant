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
    estacao_ano: str # "Verão", "Inverno", "Primavera", "Outono"

# iniciando o app do FastAPI
app = FastAPI(title="Lumees API - IA")

# caminho da pasta onde estão os .pkl
PASTA_MODELS = os.path.join("backend", "src", "models")

# mapeamento dos modelos para sabermos qual arquivo abrir na pasta
ESPECIES = [
    "suculenta",
    "salsinha",
    "cebolinha",
    "lirio_paz"
]

# mapeamento para traduzir a string do banco para o número que o treino espera
MAPA_ESTACOES = {
    "verão": 1,
    "primavera": 2,
    "inverno": 3,
    "outono": 4
}

# dicionários onde vamos guardar os modelos + scalres carregados na memória do PC (para agilizar processo)
modelos_carregados = {}
scalers_carregados = {}

# loop para API só ler os arquivos uma vez: quando inicial. depois disso o modelo já estará na memória RAM e quando o usuário requisitar o backend pode responder em alguns segundos
print("Carregando os cérebros do Lee e os scalers na memória...")
for especie in ESPECIES:
    caminho_modelo = os.path.join(PASTA_MODELS, f"lee_{especie}.pkl")
    caminho_scaler = os.path.join(PASTA_MODELS, f"scaler_{especie}.pkl")
    
    if os.path.exists(caminho_modelo) and os.path.exists(caminho_scaler):
        with open(caminho_modelo, 'rb') as file_model:
            modelos_carregados[especie] = pickle.load(file_model)
        with open(caminho_scaler, 'rb') as file_scaler:
            scalers_carregados[especie] = pickle.load(file_scaler)
        print(f"Sistema completo pronto para: {especie}")
    else:
        print(f"Erro ao carregar arquivos para a espécie: {especie}")

# RODA DA ANÁLISE IA
@app.post("/lumees-api/v1/ia/analise")
def analisar_planta(dados: RequisicaoAnalise):
    especie = dados.id_especie.lower()

    # 1. validando se a espécie enviada existe no modelo
    if especie not in modelos_carregados:
        raise HTTPException(
            status_code=400, 
            detail=f"A espécie '{dados.id_especie}' não é suportada ou o modelo não foi carregado."
        )
    
    # recupera o modelo e o scaler corretos dos dicionários
    modelo_knn = modelos_carregados[especie]
    scaler = scalers_carregados[especie]

    # CONVERSÃO: transforma a string da estação no inteiro correspondente
    estacao_nome = dados.estacao_ano.lower()
    estacao_inteiro = MAPA_ESTACOES.get(estacao_nome, 1) # padrão 1 caso venha algo estranho
    
    # monta a matriz de features exatamente na ordem que o modelo foi treinado
    # ordem do treino: umidade_solo_atual, umidade_solo_ha_7_dias, estacao_inteiro
    dados_brutos = [[dados.umidade_solo_bruto, dados.umidade_ha_7_dias, estacao_inteiro]]
    
    # normaliza os dados reais usando a mesma régua do treinamento!
    dados_normalizados = scaler.transform(dados_brutos)
    
    # Lee faz a previsão
    resultado_knn = modelo_knn.predict(dados_normalizados)
    status_bruto = str(resultado_knn[0]) # retorna: Excelente, Bom, Razoável, Ruim, Crítico
    
    # ESTRUTURA DE STATUS (mensagens baseadas nas classes do treino)
    status_interface = ""
    texto_explicativo = ""
    
    if status_bruto == "Excelente":
        status_interface = "Excelente"
        texto_explicativo = "Análise concluída! Sua plantinha está em excelentes condições. Os sensores indicam um ambiente saudável e favorável ao crescimento. Continue com esse cuidado incrível!"
        
    elif status_bruto == "Bom":
        status_interface = "Bom"
        texto_explicativo = "Tudo dentro dos parâmetros esperados. Sua planta está saudável e os cuidados atuais estão funcionando bem!"
        
    elif status_bruto == "Razoável":
        status_interface = "Razoável"
        texto_explicativo = "Detectei algumas mudanças nas condições da planta. Ela ainda está estável, mas merece um pouco mais de atenção. Recomendo acompanhar os próximos relatórios e realizar pequenos ajustes se necessário"
        
    elif status_bruto == "Ruim":
        status_interface = "Ruim"
        texto_explicativo = "Alerta de saúde!!! As condições atuais não estão favorecendo o desenvolvimento da planta. Recomendo revisar os cuidados."
        
    elif status_bruto == "Crítico":
        status_interface = "Crítico"
        texto_explicativo = "Alerta crítico!!!! A saúde da planta está comprometida e requer atenção imediata. Quanto mais rápido você agir, maiores serão as chances de recuperação."

    # Retorno estruturado pronto para mandar para o Firebase
    return {
        "uid": dados.uid,
        "id_planta": dados.id_planta,
        "estado_classificado": status_interface,
        "texto_explicativo": texto_explicativo
    }

###

# instancia o cliente de teste do FastAPI apontando para o app
cliente = TestClient(app)
    
# cria o JSON simulando exatamente o que será enviado
dados_teste = {
    "uid": "user_senai_2026",
    "id_planta": "planta_cebolinha_01",
    "id_especie": "cebolinha",
    "umidade_solo_bruto": 850.0,  # solo bem seco na régua de 1023
    "umidade_ha_7_dias": 500.0,
    "estacao_ano": "Inverno"
}
    
# dispara a requisição simulada via código
resposta = cliente.post("/lumees-api/v1/ia/analise", json=dados_teste)

print("\nRESULTADO DO TESTE")
print(f"Status HTTP esperado: 200 | Obtido: {resposta.status_code}")
print("JSON retornado pela API:")
print(resposta.json())