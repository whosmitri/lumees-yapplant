from datetime import datetime, timezone
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from firebase_admin import firestore

router = APIRouter()

class ColetaHardware(BaseModel):
    mac_hardware: str
    umidade_solo_bruto: float
    umidade_solo_porcentagem: float
    luminosidade: float
    temperatura_ar: float
    umidade_ar: float
    
    # marcando como opcionais para o ESP32 não ser obrigado a enviar!
    estacao_ano: Optional[str] = None  
    periodo_dia: Optional[str] = None

@router.post("/hardware/coleta")
def receber_dados_hardware(dados: ColetaHardware):
    # API recebe os dados brutos do ESP32
    print(f"Recebendo dados do ESP32: {dados.mac_hardware}")

    try:
        db = firestore.client()
        
        # descobrindo a qual planta pertence esse MAC address
        query_planta = (db.collection("plantas")
                        .where("mac_hardware", "==", dados.mac_hardware)
                        .limit(1))
        
        resultados = list(query_planta.stream())
        
        # se nenhuma planta tiver esse MAC cadastrado, rejeita a requisição
        if not resultados:
            raise HTTPException(
                status_code=404, 
                detail=f"Nenhuma planta localizada com o MAC: {dados.mac_hardware}"
            )
        
        # conseguimos a referência exata do documento da planta, aoba !!
        doc_planta_snap = resultados[0]
        id_planta = doc_planta_snap.id
        ref_doc_planta = db.collection("plantas").document(id_planta)
        
    except Exception as e:
        if isinstance(e, HTTPException): raise e
        raise HTTPException(status_code=500, detail=f"Erro ao buscar dispositivo no Firebase: {e}")
    
    # preparando o objeto para gravar no firebase (subcoleção 'historico_leituras')
    dados_leitura = {
        "timestamp": datetime.now(timezone.utc),
        "umidade_solo_bruto": dados.umidade_solo_bruto,
        "umidade_solo_porcentagem": dados.umidade_solo_porcentagem,
        "luminosidade": dados.luminosidade,
        "temperatura_ar": dados.temperatura_ar,
        "umidade_ar": dados.umidade_ar,
        "estacao_ano": dados.estacao_ano,
        "periodo_dia": dados.periodo_dia
    }

    dados_leitura_resumo = {
        "timestamp": datetime.now(timezone.utc),
        "umidade_solo_bruto": dados.umidade_solo_bruto,
        "umidade_solo_porcentagem": dados.umidade_solo_porcentagem,
        "luminosidade": dados.luminosidade,
        "temperatura_ar": dados.temperatura_ar,
        "umidade_ar": dados.umidade_ar
    }
    
    # gravando no firebase
    try:
        # adiciona a leitura atual na subcoleção
        ref_doc_planta.collection("historico_leituras").add(dados_leitura)
        
        # atualiza o mapa/objeto "ultima_leitura" na raiz do documento para o Flutter ver na hora
        ref_doc_planta.update({
            "ultima_leitura": dados_leitura_resumo
        })
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao gravar dados no Firebase: {e}")

    return {
        "status": "Sucesso",
        "id_planta_associada": id_planta,
        "mensagem": f"Leitura de {dados.mac_hardware} registrada com sucesso!",
    }