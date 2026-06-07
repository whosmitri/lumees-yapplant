from fastapi import APIRouter, HTTPException

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
    
    # lógica do firebase:
    # 1. buscar a subcoleção 'historico_leituras' filtrando pelo id_planta
    # 2. converter os dados brutos e timestamps para o formato de linhas CSV
    # 3. fazer o upload desse arquivo para o Firebase Storage
    
    # URL simulada que o Flutter vai receber para iniciar o download
    url_storage_simulada = f"https://storage.googleapis.com/lumees-yapp.appspot.com/relatorios/historico_{id_planta}.csv"
    
    return {
        "status": "Sucesso",
        "id_planta": id_planta,
        "url_download": url_storage_simulada,
        "mensagem": "Relatório CSV processado com sucesso. Link pronto para download."
    }