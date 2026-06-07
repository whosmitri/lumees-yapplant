from fastapi import FastAPI
from routers import ia, hardware
from fastapi.testclient import TestClient

app = FastAPI(title="Lumees Yapp API")

# modularidade:
app.include_router(ia.router, prefix="/lumees-api/v1", tags=["Inteligência Artificial"])
app.include_router(hardware.router, prefix="/lumees-api/v1", tags=["Hardware"])

@app.get("/")
async def root():
    return {"message": "Bem-vindo ao Backend do Lumees Yapp!"}


if __name__ == "__main__":
    print("\n🧪 Executando testes locais de integração dos módulos...")
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