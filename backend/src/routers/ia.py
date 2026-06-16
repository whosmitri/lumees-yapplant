# importando bibliotecas
import os
import pickle
from datetime import datetime
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from firebase_admin import firestore
from datetime import datetime, timedelta, time, timezone

router = APIRouter()

# definimos o contrato de entrada. o flutter DEVE mandar esses 3 dados:
class RequisicaoAnalise(BaseModel):
    id_planta: str    # ID específico daquela plantinha no banco
    id_especie: str   # Ex: "suculenta", "cebolinha"
    estacao_ano: str  # "Verão", "Inverno", "Primavera", "Outono"


# pega o caminho absoluto de onde o arquivo ia.py está rodando
CAMINHO_ATUAL = os.path.dirname(os.path.abspath(__file__))

# volta uma pasta para trás para sair de "routers" e ir para "src"
PASTA_SRC = os.path.dirname(CAMINHO_ATUAL)

# entra na pasta "models" que está dentro de "src"
PASTA_MODELS = os.path.join(PASTA_SRC, "models")

print(f"Buscando os arquivos em: {PASTA_MODELS}")

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


# função que pega o último valor bruto da umidade do solo lido/enviado há 7 dias
def buscar_umidade_7_dias(db, id_planta: str, umidade_atual_fallback: float) -> float:
    
    # busca a última leitura de umidade bruta de 7 dias atrás, se não encontrar, usa a umidade atual como fallback para não quebrar a IA
    agora = datetime.now(timezone.utc)
    sete_dias_atras = agora - timedelta(days=7)
    fim_do_dia_alvo = datetime.combine(sete_dias_atras.date(), time(23, 59, 59), tzinfo=timezone.utc)
    
    # faz a query exatamente na subcoleção 'historico_leituras' daquela planta
    query = (db.collection("plantas").document(id_planta)
             .collection("historico_leituras")
             .where("timestamp", "<=", fim_do_dia_alvo)
             .order_by("timestamp", direction=firestore.Query.DESCENDING)
             .limit(1))
    
    resultados = list(query.stream())
    
    if resultados:
        # pega a primeira linha de tudo enviado pelo firebase (a última leitura feita naquele dia)
        dados_leitura = resultados[0].to_dict()
        return dados_leitura.get("umidade_solo_bruto", umidade_atual_fallback)
    
    return umidade_atual_fallback


# ROTA DA ANÁLISE IA
@router.post("/ia/analise")
def analisar_planta(dados: RequisicaoAnalise):
    especie = dados.id_especie.lower()

    # 1. validando se a espécie enviada existe no modelo
    if especie not in modelos_carregados:
        raise HTTPException(
            status_code=400, 
            detail=f"A espécie '{dados.id_especie}' não é suportada ou o modelo não foi carregado."
        )

    
    # 2. conexão com o firebase
    try:
        db = firestore.client()  # puxa o cliente conectado lá no main.py
        
        # buscando o documento da planta específica
        ref_doc_planta = db.collection("plantas").document(dados.id_planta)
        doc_planta = ref_doc_planta.get()
        
        # em caso de falha:
        if not doc_planta.exists:
            raise HTTPException(status_code=404, detail="Planta não encontrada, verifique se você tem mesmo uma planta cadastrada")
        
        # transforma a resposta do firebase em dicionário python
        dados_firebase = doc_planta.to_dict()

        # pegando a umidade do solo atual
        ultima_leitura = dados_firebase.get("ultima_leitura", {})
        umidade_solo_bruto = ultima_leitura.get("umidade_solo_bruto")
        
        # busca a leitura de 7 dias atrás
        umidade_ha_7_dias = buscar_umidade_7_dias(db, dados.id_planta, umidade_solo_bruto)
        
    except Exception as e:
        if isinstance(e, HTTPException): raise e
        raise HTTPException(status_code=500, detail=f"Erro ao conectar à base de dados: {e}")

    
    # 3. execução do modelo ia
    # recupera o modelo e o scaler corretos dos dicionários
    modelo_knn = modelos_carregados[especie]
    scaler = scalers_carregados[especie]

    # CONVERSÃO: transforma a string da estação no inteiro correspondente
    estacao_nome = dados.estacao_ano.lower()
    estacao_inteiro = MAPA_ESTACOES.get(estacao_nome, 1) # padrão 1 caso venha algo estranho
    
    # monta a matriz de features exatamente na ordem que o modelo foi treinado
    # ordem do treino: umidade_solo_atual, umidade_solo_ha_7_dias, estacao_inteiro
    dados_brutos = [[umidade_solo_bruto, umidade_ha_7_dias, estacao_inteiro]]
    
    # normaliza os dados reais usando a mesma régua do treinamento!
    dados_normalizados = scaler.transform(dados_brutos)
    
    # Lee faz a previsão
    resultado_knn = modelo_knn.predict(dados_normalizados)
    status_bruto = str(resultado_knn[0]) # retorna: Excelente, Bom, Razoável, Ruim, Crítico
    
    # ESTRUTURA DE STATUS (mensagens baseadas nas classes do treino)
    status_interface = ""
    texto_explicativo = ""
    
    if status_bruto == "Excelente":
        texto_explicativo = "Análise concluída! Sua plantinha está em excelentes condições. Os sensores indicam um ambiente saudável e favorável ao crescimento. Continue com esse cuidado incrível!"
        
    elif status_bruto == "Bom":
        texto_explicativo = "Tudo dentro dos parâmetros esperados. Sua planta está saudável e os cuidados atuais estão funcionando bem!"
        
    elif status_bruto == "Razoável":
        texto_explicativo = "Detectei algumas mudanças nas condições da planta. Ela ainda está estável, mas merece um pouco mais de atenção. Recomendo acompanhar os próximos relatórios e realizar pequenos ajustes se necessário"
        
    elif status_bruto == "Ruim":
        texto_explicativo = "Alerta de saúde!!! As condições atuais não estão favorecendo o desenvolvimento da planta. Recomendo revisar os cuidados."
        
    elif status_bruto == "Crítico":
        texto_explicativo = "Alerta crítico!!!! A saúde da planta está comprometida e requer atenção imediata. Quanto mais rápido você agir, maiores serão as chances de recuperação."

    # retorno estruturado pronto para mandar para o Firebase
    resultado_final = {
        "id_planta": dados.id_planta,
        "timestamp": datetime.now(timezone.utc),
        "estado_classificado": status_bruto,
        "texto_explicativo": texto_explicativo
    }

    try:
        # salva no histórico de análises da planta
        ref_doc_planta.collection("analises_ia").add(resultado_final)

    except Exception as e:
        print(f"AVISO: Modelo analisou, mas falhou ao atualizar o doc da planta: {e}")

    return resultado_final