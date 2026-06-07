from datetime import datetime
from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class ColetaHardware(BaseModel):
    mac_hardware: str
    umidade_solo_bruto: float
    umidade_solo_porcentagem: float
    luminosidade: float
    temperatura_ar: float
    umidade_ar: float
    estacao_ano: str
    periodo_dia: str

@router.post("/hardware/coleta")
def receber_dados_hardware(dados: ColetaHardware):
    # API recebe os dados brutos do ESP32
    print(f"Recebendo dados do ESP32: {dados.mac_hardware}")
    
    # preparando o objeto para gravar no firebase (subcoleção 'historico_leituras')
    dados_leitura = {
        "timestamp": datetime.now(),
        "umidade_solo_bruto": dados.umidade_solo_bruto,
        "umidade_solo_porcentagem": dados.umidade_solo_porcentagem,
        "luminosidade": dados.luminosidade,
        "temperatura_ar": dados.temperatura_ar,
        "umidade_ar": dados.umidade_ar,
        "estacao_ano": dados.estacao_ano,
        "periodo_dia": dados.periodo_dia
    }

    dados_leitura_resumo = {
        "timestamp": datetime.now(),
        "umidade_solo_porcentagem": dados.umidade_solo_porcentagem,
        "luminosidade": dados.luminosidade,
        "temperatura_ar": dados.temperatura_ar,
        "umidade_ar": dados.umidade_ar
    }
    
    # AQUI ENTRARIA O COMANDO DO FIREBASE:
    # db.collection('plantas').document(dados.id_dispositivo).collection('historico_leituras').add(dados_leitura)
    
    # atualizando o "ultima_leitura" (para o Flutter mostrar em tempo real)
    # db.collection('plantas').document(dados.id_dispositivo).update({"ultima_leitura": dados_leitura_resumo})

    # lógica de atualização/envio de dados:
    # where("mac_hardware", "==", mac_recebido

    return {
        "status": "Sucesso",
        "mensagem": f"Leitura de {dados.mac_hardware} registrada com sucesso!",
        "dados_recebidos": dados_leitura
    }