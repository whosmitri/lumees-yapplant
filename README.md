# 🌱 Lumees Yapplant: Sistema Inteligente de Monitoramento e Cuidados de Plantas

O **Lumees Yapplant** é um ecossistema inteligente baseado em Internet das Coisas (IoT), Computação na Nuvem e Inteligência Artificial, projetado para a monitorização residencial e classificação preditiva da saúde de plantas.

Inspirado no conceito de gamificação de bichinhos virtuais (como o *Tamagotchi*), o sistema converte variáveis físicas invisíveis em estados visuais intuitivos de humor e bem-estar, tornando o cuidado botânico diário uma experiência interativa, preventiva e acessível.

---

## 🏗️ Arquitetura Geral do Sistema

O ecossistema é dividido em 4 camadas modulares e integradas:

1. **Camada de Captura (Hardware):** Um módulo eletrónico baseado no microcontrolador **ESP32** que recolhe métricas ambientais a cada 10 minutos.
2. **Camada de Processamento (Backend & IA):** Uma API assíncrona em **FastAPI (Python)** que centraliza as regras de negócio e consome o modelo de Machine Learning.
3. **Camada de Persistência (Base de Dados):** Infraestrutura NoSQL assente no **Firebase Firestore** e **Cloud Storage** para histórico e ficheiros.
4. **Camada de Visualização (App Mobile):** Interface gráfica e responsiva desenvolvida em **Flutter (Dart)** focada na experiência gamificada do utilizador.

![Fluxo Geral](./assets/arquitetura/lumees-yapp_%20fluxo-geral.jpg)

---

## 🛠️ Especificações Técnicas por Módulo

### 1. Hardware e IoT (`/hardware`)

O circuito físico utiliza o **ESP32** conectado a três sensores principais para telemetria:

* **Humidade do Solo:** Higrómetro analógico com dados normalizados de 12 para 10 bits e convertidos para escala percentual (0% a 100%).
* **Clima:** Sensor **DHT11** para temperatura e humidade do ar.
* **Luminosidade:** Sensor **BH1750** via protocolo I2C para medição em Lux.
* **Comunicação:** O endereço MAC do chip funciona como ID único e chave de autenticação nas requisições HTTP para o endpoint `/hardware/coleta`.

### 2. Backend e API REST (`/backend`)

Construído com **FastAPI** e validado via **Pydantic**, responde sob o prefixo `/lumees-api/v1/`:

* `POST /hardware/coleta`: Recebe o payload JSON do ESP32, valida o contrato e persiste os históricos.
* `POST /ia/analise`: Aciona o motor preditivo e devolve o diagnóstico.
* `GET /plantas/{id_planta}/exportar-csv`: Gera em memória RAM (`io.StringIO`) relatórios CSV dos últimos 15 dias, armazena no Cloud Storage e gera uma **Signed URL v4** segura (válida por 1 hora) para download no app.

### 3. Inteligência Artificial (Modelo "Lee")

* **Algoritmo:** *K-Nearest Neighbors* (KNN) implementado via *Scikit-Learn*.
* **Variáveis Consideradas:** Cruza a **Humidade Atual Bruta** com a **Média de Humidade dos Últimos 7 Dias** (capturando tendências de stress hídrico ou excesso de rega).
* **Treinamento:** Modelo treinado em Python com 80% de dados sintéticos baseados em estudos botânicos reais e exportado em formato binário `.pkl`.
* **Tratamento de Status:** Um pipeline condicional (*if/else*) traduz a classificação técnica em *status* amigáveis ("Excelente", "Razoável", "Crítico") e gera mensagens personalizadas de orientação para o utilizador.

### 4. Aplicação Mobile (`/mobile`)

Interface intuitiva focada em usabilidade e UX:

* **Renderização Dinâmica:** O avatar gráfico da planta altera a sua expressão e animação em tempo real com base no diagnóstico da IA.
* **Dashboard Temporal:** Gráficos de linha interativos que plotam o histórico das últimas 5 horas de telemetria.
* **Fluxo de Autenticação:** Controlo de acessos nativo integrado com o Firebase Auth (`uid`).

---

## 📁 Estrutura de Pastas do Repositório

```text
├── backend/               # Código-fonte da API FastAPI e ficheiro do modelo (.pkl)
│   ├── app/               # Rotas, serviços da IA e conexões ao Firebase
│   └── notebooks/         # Jupyter Notebooks (Google Colab) com o treino do KNN
├── hardware/              # Código-fonte do firmware para ESP32
│   └── main/               # Implementação e lógica dos sensores no Wokwi/IDE
├── mobile/                # Código-fonte do aplicativo em Flutter (Dart)
├── docs/                  # Documentação académica em LaTeX (Artigo ABNT e Especificação)
└── README.md              # Este guia de apresentação do ecossistema

```

---

## 👥 Autores

* **whosmitri** - [GitHub](https://github.com/whosmitri)
* **Nekozin** - [GitHub](https://github.com/Nekozin)

---

### 📝 Notas de Configuração

Cada subpasta (`/hardware`, `/backend`, `/mobile`) possui o seu próprio manual de instruções (`README.md`) com as respetivas dependências, diagramas elétricos e observações necessárias para executar o módulo localmente.