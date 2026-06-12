import os
from fastapi import FastAPI
from contextlib import asynccontextmanager
import firebase_admin
from firebase_admin import credentials
from routers import ia, hardware, report
from fastapi.middleware.cors import CORSMiddleware
from fastapi.testclient import TestClient

# configurando o ciclo de vida (Lifespan) para iniciar o firebase
@asynccontextmanager
async def lifespan(app: FastAPI):
    # executa QUANDO A API INICIA
    try:
        # caminho para o arquivo de credenciais do firebase
        CAMINHO_MAIN = os.path.dirname(os.path.abspath(__file__))
        CAMINHO_JSON = os.path.join(CAMINHO_MAIN, "firebase-credentials.json")

        cred = credentials.Certificate(CAMINHO_JSON)
        firebase_admin.initialize_app(cred)
        print("Firebase inicializado com sucesso!")
    except Exception as e:
        print(format(f"Erro ao inicializar o Firebase: {e}"))
    
    yield  # Aqui a API fica rodando normalmente
    
    # apenas notificando o encerramento
    print("Encerrando aplicação...")

# cria o app
app = FastAPI(title="Lumees Yapp API", lifespan=lifespan)

# CORS para acesso via web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# modularidade:
app.include_router(ia.router, prefix="/lumees-api/v1", tags=["Inteligência Artificial"]) # rota da análise de IA
app.include_router(hardware.router, prefix="/lumees-api/v1", tags=["Hardware"]) # rota da comunicação com hardware
app.include_router(report.router, prefix="/lumees-api/v1", tags=["Relatório CSV"]) # rota para exportar relatório CSV

@app.get("/")
async def root():
    return {"message": "Bem-vindo ao Backend do Lumees Yapp!"}

"""
if __name__ == "__main__":
    print("\nExecutando testes locais de integração dos módulos...")
    cliente = TestClient(app)

    with cliente:
        
        # Teste Raiz
        resposta = cliente.get("/")
        print(f"Status do teste básico: {resposta.status_code} - {resposta.json()}")
        
        # Dados de Teste IA
        dados_teste_ia = {
            "id_planta": "planta_cebolinha_01",
            "id_especie": "cebolinha",
            "estacao_ano": "Inverno"
        }

        print("\n--- [TESTE IA] RESULTADO ---")
        resposta_ia = cliente.post(
            "/lumees-api/v1/ia/analise",
            json=dados_teste_ia
        )
        print(f"Status HTTP: {resposta_ia.status_code}")
        try:
            print("JSON:", resposta_ia.json())
        except:
            print("Resposta:", resposta_ia.text)
        print("----------------------------\n")

        # Dados de Teste Hardware
        dados_teste_hardware = {
            "mac_hardware": "24:0A:C4:B3:11:42",
            "umidade_solo_bruto": 850.0,
            "umidade_solo_porcentagem": 83.0,
            "luminosidade": 2000.0,
            "temperatura_ar": 23.0,
            "umidade_ar": 45.0,
            "estacao_ano": "verão",
            "periodo_dia": "dia"
        }

        print("\n--- [TESTE HARDWARE] RESULTADO ---")
        resposta_hardware = cliente.post(
            "/lumees-api/v1/hardware/coleta",
            json=dados_teste_hardware
        )
        print(f"Status HTTP: {resposta_hardware.status_code}")
        try:
            print("JSON:", resposta_hardware.json())
        except:
            print("Resposta:", resposta_hardware.text)
        print("---------------------------------\n")

        # Dados de Teste Report CSV
        id_planta_teste = "planta_cebolinha_01"

        print("\n--- [TESTE REPORT CSV] RESULTADO ---")
        resposta_report = cliente.get(
            f"/lumees-api/v1/plantas/{id_planta_teste}/exportar-csv"
        )
        print(f"Status HTTP: {resposta_report.status_code}")
        try:
            print("JSON:", resposta_report.json())
        except:
            print("Resposta:", resposta_report.text)
        print("------------------------------------\n")
"""