from fastapi import FastAPI
from contextlib import asynccontextmanager
import firebase_admin
from firebase_admin import credentials
from routers import ia, hardware, report
from fastapi.testclient import TestClient

# configurando o ciclo de vida (Lifespan) para iniciar o firebase
@asynccontextmanager
async def lifespan(app: FastAPI):
    # executa QUANDO A API INICIA
    try:
        # caminho para o arquivo de credenciais do firebase
        cred = credentials.Certificate("firebase-credentials.json")
        firebase_admin.initialize_app(cred)
        print("Firebase inicializado com sucesso!")
    except Exception as e:
        print(format(f"Erro ao inicializar o Firebase: {e}"))
    
    yield  # Aqui a API fica rodando normalmente
    
    # apenas notificando o encerramento
    print("Encerrando aplicação...")

app = FastAPI(title="Lumees Yapp API", lifespan=lifespan)

# modularidade:
app.include_router(ia.router, prefix="/lumees-api/v1", tags=["Inteligência Artificial"]) # rota da análise de IA
app.include_router(hardware.router, prefix="/lumees-api/v1", tags=["Hardware"]) # rota da comunicação com hardware
app.include_router(report.router, prefix="/lumees-api/v1", tags=["Relatório CSV"]) # rota para exportar relatório CSV

@app.get("/")
async def root():
    return {"message": "Bem-vindo ao Backend do Lumees Yapp!"}


if __name__ == "__main__":
    print("\nExecutando testes locais de integração dos módulos...")
    cliente = TestClient(app)
    
    dados_teste_ia = {
        "uid": "user_senai_2026",
        "id_planta": "planta_cebolinha_01",
        "id_especie": "cebolinha",
        "umidade_solo_bruto": 850.0,
        "umidade_ha_7_dias": 500.0,
        "estacao_ano": "Inverno"
    }

    dados_teste_hardware = {
        "mac_hardware": "24:0A:C4:B3:11:42",
        "umidade_solo_bruto": "850.0",
        "umidade_solo_porcentagem": "83",
        "luminosidade": "2000",
        "temperatura_ar": "23",
        "umidade_ar": "45",
        "estacao_ano": "verão",
        "periodo_dia": "dia"

    }
    
    resposta_ia = cliente.post("/lumees-api/v1/ia/analise", json=dados_teste_ia)
    print("\n--- [TESTE IA] RESULTADO ---")
    print(f"Status HTTP: {resposta_ia.status_code}")
    print("JSON:", resposta_ia.json())
    print("----------------------------\n")

    resposta_esp = cliente.post("/lumees-api/v1/hardware/coleta", json=dados_teste_hardware)
    print("\n--- [TESTE HARDWARE] RESULTADO ---")
    print(f"Status HTTP: {resposta_esp.status_code}")
    print("JSON:", resposta_esp.json())
    print("----------------------------\n")

    id_planta_teste = "planta_cebolinha_01"
    resposta_report = cliente.get(f"/lumees-api/v1/plantas/{id_planta_teste}/exportar-csv")
    print("\n--- [TESTE REPORT CSV] RESULTADO ---")
    print(f"Status HTTP: {resposta_report.status_code}")
    print(f"JSON: {resposta_report.json()}")
    print("------------------------------------\n")

    # o "TestClient" também dispara os eventos de lifespan, então o Firebase tentará inicializar aqui no teste local mesmo
    resposta = cliente.get("/")
    print(f"Status do teste básico: {resposta.status_code} - {resposta.json()}")