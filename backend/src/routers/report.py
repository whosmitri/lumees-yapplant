from fastapi import APIRouter, HTTPException
import csv # biblioteca nativa
import io # input/output. para gerenciar fluxos de arquivos na memória RAM
from datetime import datetime, timezone, timedelta
from fastapi.responses import StreamingResponse
from firebase_admin import firestore, storage

router = APIRouter()

@router.get("/plantas/{id_planta}/exportar-csv")
def exportar_historico_csv(id_planta: str):
    print(f"Gerando relatório analítico para a planta: {id_planta}")
    
    # validação simples para o teste não aceitar string vazia
    if not id_planta or id_planta.strip() == "":
        raise HTTPException(
            status_code=400, 
            detail="O ID da planta não pode ser vazio para a geração do relatório."
        )
    
    try:
        db = firestore.client()

        # CÁLCULO DOS 15 DIAS:
        agora = datetime.now(timezone.utc)
        quinze_dias_atras = agora - timedelta(days=15)  # subtrai exatamente 15 dias da data atual
        
        # BUSCA O HISTÓRICO NO FIRESTORE
        # buscando todas as leituras ordenadas pelas mais recentes
        ref_historico = (db.collection("plantas").document(id_planta)
                         .collection("historico_leituras")
                         .where("timestamp", ">=", quinze_dias_atras) # só traz o que for maior/mais recente do que 15 dias atrás
                         .order_by("timestamp", direction=firestore.Query.DESCENDING)) # ordena do mais novo pro maix velho
        
        docs_leituras = list(ref_historico.stream()) # faz a busca e transforma em lista python
        
        # se a lista for vazia, avisa que não tem dados nesse período
        if not docs_leituras:
            raise HTTPException(
                status_code=404, 
                detail="Nenhum histórico de leituras encontrado para esta planta. Não há dados para exportar."
            )
            
        # CONVERTE OS DADOS PARA CSV (salvando na memória RAM)
        fita_memoria = io.StringIO() # cria um "arquivo de texto virtual" dentro da memória RAM no compiuter
        escritor_csv = csv.writer(fita_memoria, delimiter=';') # configura o gravador de csv para usar ponto e vírgula
        
        # escreve o cabeçalho do arquivo CSV
        escritor_csv.writerow([
            "Data e Hora (UTC)", "Umidade Solo (Bruto)", "Umidade Solo (%)", 
            "Luminosidade (Lux)", "Temperatura Ar (°C)", "Umidade Ar (%)", "Estação", "Período do Dia"
        ])
        
        # varre cada documento que o firebase trouxa pra preencheras linhas do arquivo
        for doc in docs_leituras:
            dados = doc.to_dict() # transforma o documento em dicionário python
            
            # pega o timestamp do firebase e transforma em texto comum (ex: 20/05/2024 11:30:00)
            ts = dados.get("timestamp")
            ts_formatado = ts.strftime("%d/%m/%Y %H:%M:%S") if ts else "N/A"
            
            # escreve uma linha de dados no arquivo virtual csv
            escritor_csv.writerow([
                ts_formatado,
                dados.get("umidade_solo_bruto", "N/A"),
                dados.get("umidade_solo_porcentagem", "N/A"),
                dados.get("luminosidade", "N/A"),
                dados.get("temperatura_ar", "N/A"),
                dados.get("umidade_ar", "N/A"),
                dados.get("estacao_ano", "N/A"),
                dados.get("periodo_dia", "N/A")
            ])
        
        # arquivo ok (finalizado) e preparando para envio
        fita_memoria.seek(0) # move o ponteiro do arquivo de memória para o começo dele (para a linha 1)
        conteudo_csv = fita_memoria.getvalue() # extrai todo o texto do csv gerado como uma única String
        fita_memoria.close() # fecha e limpa a memória RAM usada pelo arquivo virtual

        # 3. FAZ UPLOAD PARA O FIREBASE STORAGE
        # conectamdp no balde/pasta de arquivos geral do firebase
        bucket = storage.bucket()
        caminho_no_storage = f"relatorios/historico_{id_planta}.csv" # define a pasta e o nome do arquivo que ficará na nuvem
        blob = bucket.blob(caminho_no_storage) # cria o objeto do arquivo lá no storage
        
        # faz o upload da string como um arquivo de texto CSV
        blob.upload_from_string(conteudo_csv, content_type="text/csv")
        
        # 4. GERA URL DE DOWNLOAD VÁLIDA
        url_download = blob.generate_signed_url(
            version="v4",
            expiration=timedelta(hours=1), # expira em 1 hora para segurança dos dados
            method="GET" # flutter apenas pega o arquivo
        )

    except Exception as e:
        if isinstance(e, HTTPException): raise e
        raise HTTPException(status_code=500, detail=f"Erro ao processar relatório no Firebase: {e}")

    return {
        "status": "Sucesso",
        "id_planta": id_planta,
        "url_download": url_download,
        "mensagem": "Relatório CSV processado com sucesso. Link pronto para download."
    }