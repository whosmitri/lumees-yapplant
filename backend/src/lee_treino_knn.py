# IMPORTANDO BIBLIOTECAS

## para salvar os modelos em arquivo .pkl
import os # define caminhos
import pickle # cria arquivos .pkl

## para gerar os dados
import numpy as np
import pandas as pd

## para KNN
from sklearn.model_selection import train_test_split # separa os dados de treino e teste
from sklearn.preprocessing import StandardScaler # define um padrão para todos os dados
from sklearn.neighbors import KNeighborsClassifier # cria o modelo KNN
from sklearn.metrics import accuracy_score # retorna resultado de teste (acurácia)

# para garantir que a pasta para salvar os modelos existe
PASTA_MODELS = os.path.join("backend", "src", "models")
os.makedirs(PASTA_MODELS, exist_ok=True)

###

# FUNÇÕES DE GERAÇÃO DE DADOS SINTÉTICOS

## suculenta
def gerar_dados_suculenta(quantidade_amostras=2000):
    np.random.seed(40) # mantém os dados iguais toda vez que rodar, significa que os dados são aleatórios mas não tanto

    # gerando as 4 variáveis dos sensores (dados brutos) baseado na modelagem de dados
    umidade_solo_atual = np.random.uniform(0, 1023, quantidade_amostras) # gera dados da umidade do solo, 0=molhado e 1023=seco
    umidade_solo_ha_7_dias = np.random.uniform(0, 1023, quantidade_amostras) # gera dados da umidade do solo de 7 dias atrás

    # gerando a variável de contexto (já convertida em números)
    # estacao_ano: 1 = Verão, 2 = Primavera, 3 = Inverno, 4 = Outono
    estacao_ano = np.random.choice([1, 2, 3, 4], size=quantidade_amostras)

    niveis_saude = []

    # 3. aplicando a lógica de combinação para definir a saúde (o que a IA vai aprender)
    for i in range(quantidade_amostras):
        # cálculo da variação da umidade para análise preditiva
        variacao_umidade = umidade_solo_atual[i] - umidade_solo_ha_7_dias[i]

        # CRÍTICO: solo encharcado hoje (<300) e já estava encharcado há 7 dias (variação menor que 100) #no inverno e outono (3 e 4)
        if umidade_solo_atual[i] < 300 and abs(variacao_umidade) < 100: #and (estacao_ano[i] in [3, 4]):
            niveis_saude.append("Crítico")

        # RUIM: solo secou rápido demais (variação > 500)
        elif variacao_umidade > 500:
            niveis_saude.append("Ruim")

        # EXCELENTE: solo na faixa seca ideal para suculenta (650 a 900) e estável/secando no verão/primavera com boa luz
        elif (650 <= umidade_solo_atual[i] <= 900) and variacao_umidade >= 0:
            niveis_saude.append("Excelente")

        # BOM: solo em faixas aceitáveis sem extremos
        elif (550 <= umidade_solo_atual[i] <= 850):
            niveis_saude.append("Bom")

        # RAZOÁVEL: se não quebrou nenhuma regra e não entra em nenhuma condição, fica no meio termo
        else:
            niveis_saude.append("Razoável")

    # Criando o DataFrame do Pandas
    df = pd.DataFrame({
        'umidade_solo_atual': umidade_solo_atual,
        'umidade_solo_ha_7_dias': umidade_solo_ha_7_dias,
        'estacao_ano': estacao_ano,
        'saude_planta': niveis_saude
    })

    return df

## salsinha
def gerar_dados_salsinha(quantidade_amostras=2000):
    np.random.seed(41)

    umidade_solo_atual = np.random.uniform(0, 1023, quantidade_amostras)
    umidade_solo_ha_7_dias = np.random.uniform(0, 1023, quantidade_amostras)
    estacao_ano = np.random.choice([1, 2, 3, 4], size=quantidade_amostras)

    niveis_saude = []

    for i in range(quantidade_amostras):
        variacao_umidade = umidade_solo_atual[i] - umidade_solo_ha_7_dias[i]

        # CRÍTICO: solo muito seco (acima de 600) e secou muito nos últimos 7 dias (variação > 200)
        if umidade_solo_atual[i] > 600 and variacao_umidade > 200:
            niveis_saude.append("Crítico")

        # RUIM: solo começou a secar (perto de 500)
        elif 400 < umidade_solo_atual[i] <= 600:
            niveis_saude.append("Ruim")

        # EXCELENTE: solo bem úmido (100 a 400) e variação controlada (abaixo de 50, sem secar bruscamente)
        elif (100 <= umidade_solo_atual[i] <= 400) and variacao_umidade < 50:
            niveis_saude.append("Excelente")

        # BOM: solo aceitável
        elif (400 < umidade_solo_atual[i] <= 500):
            niveis_saude.append("Bom")
        else:
            niveis_saude.append("Razoável")

    return pd.DataFrame({
        'umidade_solo_atual': umidade_solo_atual,
        'umidade_solo_ha_7_dias': umidade_solo_ha_7_dias,
        'estacao_ano': estacao_ano,
        'saude_planta': niveis_saude
    })

## cebolinha
def gerar_dados_cebolinha(quantidade_amostras=2000):
    np.random.seed(43)

    umidade_solo_atual = np.random.uniform(0, 1023, quantidade_amostras)
    umidade_solo_ha_7_dias = np.random.uniform(0, 1023, quantidade_amostras)
    estacao_ano = np.random.choice([1, 2, 3, 4], size=quantidade_amostras)

    niveis_saude = []

    for i in range(quantidade_amostras):
        variacao_umidade = umidade_solo_atual[i] - umidade_solo_ha_7_dias[i]

        # CRÍTICO: solo extremamente seco (acima de 700) e subindo rápido (variação > 250)
        # significa que ela está torrando no seco total
        if umidade_solo_atual[i] > 700 and variacao_umidade > 250:
            niveis_saude.append("Crítico")

        # RUIM: solo bem seco (entre 500 e 700)
        elif 500 < umidade_solo_atual[i] <= 700:
            niveis_saude.append("Ruim")

        # EXCELENTE: solo úmido e aceitável (150 a 500) e variação estável (abaixo de 80)
        elif (150 <= umidade_solo_atual[i] <= 500) and variacao_umidade < 80:
            niveis_saude.append("Excelente")

        # BOM: solo ligeiramente mais úmido ou seco, mas contornável
        elif (100 <= umidade_solo_atual[i] < 150) or (500 < umidade_solo_atual[i] <= 550):
            niveis_saude.append("Bom")

        # RAZOÁVEL: meio termo
        else:
            niveis_saude.append("Razoável")

    return pd.DataFrame({
        'umidade_solo_atual': umidade_solo_atual,
        'umidade_solo_ha_7_dias': umidade_solo_ha_7_dias,
        'estacao_ano': estacao_ano,
        'saude_planta': niveis_saude
    })

## lírio-da-paz
def gerar_dados_lirio_paz(quantidade_amostras=2000):
    np.random.seed(42) # mantém os dados iguais toda vez que rodar, significa que os dados são aleatórios mas não tanto

    # gerando as 4 variáveis dos sensores (dados brutos) baseado na modelagem de dados
    umidade_solo_atual = np.random.uniform(0, 1023, quantidade_amostras) # gera dados da umidade do solo, 0=molhado e 1023=seco
    umidade_solo_ha_7_dias = np.random.uniform(0, 1023, quantidade_amostras) # gera dados da umidade do solo de 7 dias atrás

    # gerando a variável de contexto (já convertida em números)
    # estacao_ano: 1 = Verão, 2 = Primavera, 3 = Inverno, 4 = Outono
    estacao_ano = np.random.choice([1, 2, 3, 4], size=quantidade_amostras)

    niveis_saude = []
    for i in range(quantidade_amostras):
        variacao_umidade = umidade_solo_atual[i] - umidade_solo_ha_7_dias[i]

        # CRÍTICO: planta murcha por sede (solo passou de 550)
        if umidade_solo_atual[i] > 750:
            niveis_saude.append("Crítico")

        # RUIM: excesso de água/falta de drenagem (solo < 150 e quase sem variação positiva, ou seja, continua encharcado)
        elif umidade_solo_atual[i] < 150 and variacao_umidade < 50:
            niveis_saude.append("Ruim")

        # EXCELENTE: o equilíbrio perfeito (solo úmido entre 150 e 400, bem drenado)
        elif (200 <= umidade_solo_atual[i] <= 450) and (abs(variacao_umidade) < 250):
            niveis_saude.append("Excelente")

        # BOM: faixa aceitável de transição (400 a 550) antes de murchar
        elif (450 < umidade_solo_atual[i] <= 650):
            niveis_saude.append("Bom")

        # RAZOÁVEL: meio termo
        else:
            niveis_saude.append("Razoável")

    # criando o DataFrame do Pandas
    df = pd.DataFrame({
        'umidade_solo_atual': umidade_solo_atual,
        'umidade_solo_ha_7_dias': umidade_solo_ha_7_dias,
        'estacao_ano': estacao_ano,
        'saude_planta': niveis_saude
    })

    return df

# SCRIPT DE TREINAR E SALVAR OS MODELOS KNN
def treinar_e_salvar_modelo(nome_especie, df_dados):
    print(f"\nIniciando Treinamento: {nome_especie.upper()}")
    
    ###

    ## 1. separando variáveis preditoras (X) e alvo (y)
    X = df_dados.drop(columns=['saude_planta'])
    y = df_dados['saude_planta']

    ## 2. dividindo em treino (80%) e teste (20%)
    X_treino, X_teste, y_treino, y_teste = train_test_split(
        X, y,
        test_size=0.20, # separa 20% para teste
        random_state=42, # garante que a divisão seja igual toda vez que rodar
        stratify=y # mantém a mesma proporção de notas de saúde no treino e no teste (crítico, bom, etc)
    )

    ###

    ## 3. normalização dos dados
    ### cria o objeto que fará a padronização
    scaler = StandardScaler()

    ### 'fit_transform' calcula os limites do treino e já aplica a escala nas 1600 amostras de treino
    X_treino_norm = scaler.fit_transform(X_treino)

    ### 'transform' aplica a MESMA régua do treino nas 400 amostras de teste
    X_teste_norm = scaler.transform(X_teste)

    ###

    ## 4. instanciação e ajuste do modelo KNN (Lee)
    ### criamos o Lee definindo o número de vizinhos (K=5 é um bom padrão)
    lee_modelo = KNeighborsClassifier(n_neighbors=5)

    ### o Lee estuda os dados de treino normalizados
    lee_modelo.fit(X_treino_norm, y_treino)

    # 5. avaliação da Acurácia
    ### Lee faz a prova com os dados de teste que ele nunca viu
    previsoes = lee_modelo.predict(X_teste_norm)

    ### calculamos quanto de acerto o Lee teve no teste (Acurácia)
    acuracia = accuracy_score(y_teste, previsoes)

    ### saída no terminal:
    print(f"Acurácia do Lee para {nome_especie}: {acuracia * 100:.2f}%")

    ## 6. salvando o modelo treinado e o scaler correspondente
    ### alvamos o scaler junto porque a API precisará normalizar os dados reais com a mesma média e desvio padrão calculados no treino.
    caminho_modelo = os.path.join(PASTA_MODELS, f"lee_{nome_especie}.pkl")
    caminho_scaler = os.path.join(PASTA_MODELS, f"scaler_{nome_especie}.pkl")

    ### salvando o modelo treinado dentro de um arquivo
    with open(caminho_modelo, 'wb') as f_model:
        pickle.dump(lee_modelo, f_model)

    ### salvar o scaler dentro de um arquivo
    with open(caminho_scaler, 'wb') as f_scaler:
        pickle.dump(scaler, f_scaler)

    ### saída no terminal
    print(f"Sucesso! Arquivos salvos em '{PASTA_MODELS}' como:")
    print(f"  - lee_{nome_especie}.pkl")
    print(f"  - scaler_{nome_especie}.pkl")


# EXECUÇÃO DO SCRIPT

if __name__ == "__main__":
    ## gerando dados e treinando cada espécie mapeada no ecossistema
    ### gera dados da suculenta
    dados_suculenta = gerar_dados_suculenta(2000)
    ### treina e salva modelo da suculenta
    treinar_e_salvar_modelo("suculenta", dados_suculenta)

    ### gera dados da salsinha
    dados_salsinha = gerar_dados_salsinha(2000)
    ### treina e salva modelo da salsinha
    treinar_e_salvar_modelo("salsinha", dados_salsinha)

    ### gera dados da cebolinha
    dados_cebolinha = gerar_dados_cebolinha(2000)
    ### treina e salva modelo da cebolinha
    treinar_e_salvar_modelo("cebolinha", dados_cebolinha)

    ### gera dados do lírio-da-paz
    dados_lirio = gerar_dados_lirio_paz(2000)
    ### gera dados do lírio-da-paz
    treinar_e_salvar_modelo("lirio_paz", dados_lirio)

    print("\nPROCESSO CONCLUÍDO!! \nTodos os cérebros do Lee foram salvos localmente!")