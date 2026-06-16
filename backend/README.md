# 🌱 Backend: API REST & Inteligência Artificial

Este diretório contém o microsserviço de backend do ecossistema **Lumees Yapplant**. Desenvolvida em **FastAPI**, a API atua como a camada central de inteligência e gerenciamento de dados, conectando o hardware (ESP32), o banco de dados em nuvem (Firebase) e a interface do usuário (Flutter).

## 🚀 Tecnologias e Frameworks

* **FastAPI:** Framework web assíncrono de alta performance para a construção das rotas.
* **Pydantic:** Validação nativa de contratos e tipagem de dados.
* **Firebase Admin SDK:** Integração oficial com os serviços Cloud Firestore e Cloud Storage.
* **Scikit-Learn:** Framework utilizado para a execução e inferência do modelo de Machine Learning.

---

## 🛣️ Rotas da API (Endpoints)

Todas as requisições respondem sob o prefixo de versão `/lumees-api/v1`.

| Método | Endpoint | Descrição | Cliente |
| --- | --- | --- | --- |
| `POST` | `/lumees-api/v1/hardware/coleta` | Recebe as leituras dos sensores e o endereço MAC do dispositivo. | **ESP32** |
| `POST` | `/lumees-api/v1/ia/analise` | Processa o ID da planta, espécie e estação para retornar o diagnóstico de saúde. | **Mobile** |
| `GET` | `/lumees-api/v1/plantas/{id_planta}/exportar-csv` | Gera e exporta o histórico de leituras de 15 dias da planta em formato de planilha. | **Mobile** |

---

## 🗄️ Integração com o Firebase

O backend gerencia os dados operando em duas frentes na nuvem do Google:

### 1. Cloud Firestore (Banco de Dados NoSQL)

* **Vínculo Dinâmico:** A rota `/coleta` recebe o `mac_hardware` do ESP32, localiza a qual `id_planta` ele pertence e associa os dados de forma transparente.
* **Persistência Histórica:** Salva as novas leituras com um *timestamp* UTC na subcoleção `historico_leituras` e simultaneamente atualiza o campo `ultima_leitura` na raiz do documento para refletir o estado atualizado no Flutter.
* **Busca Retroativa:** Recupera dados de umidade de exatamente 7 dias atrás no histórico para alimentar o motor de análise preditiva.

### 2. Cloud Storage (Armazenamento de Arquivos)

Para exportação de relatórios sem onerar o servidor:

1. A API faz a busca das leituras dos últimos 15 dias no Firestore.
2. Formata os dados em formato CSV diretamente na memória RAM (via `io.StringIO`), evitando a gravação de arquivos temporários locais.
3. Faz o upload do buffer diretamente para o caminho `relatorios/historico_{id_planta}.csv`.
4. Retorna para o app uma **Signed URL v4** com permissão restrita de leitura via método `GET` válida por 1 hora.

---

## 🧠 Motor de IA: O Modelo "Lee" (KNN)

A API consome de forma interna um modelo preditivo baseado no algoritmo **K-Nearest Neighbors (KNN)**, apelidado carinhosamente de *Lee*.

* **O Modelo:** Classifica a saúde da planta entre os estados *"Excelente"*, *"Razoável"* ou *"Crítico"*.
* **Variáveis de Entrada:** Cruza a **Umidade Atual Bruta do Solo** com a **Média de Umidade dos Últimos 7 Dias** (tendência de estresse hídrico ou excesso de rega).
* **Treinamento:** Desenvolvido em Python com base em dados sintéticos gerados a partir de estudos botânicos e exportado em formato `.pkl` (Pickle) para carregamento rápido pela API.
* **Tradutor de Estados:** Após a inferência do arquivo `.pkl`, o backend executa uma camada estruturada de condições (*if/else*) para converter o rótulo técnico em uma resposta humanizada e amigável acompanhada de textos explicativos de orientação para o usuário.

---

## 🔄 Fluxo de Dados Completo

```text
App (Solicita análise) 
   ↓
FastAPI (Recebe requisição e id_especie)
   ↓
Firestore (Busca umidade atual e histórico de 7 dias)
   ↓
Modelo Lee (.pkl) (Processa dados e classifica via KNN)
   ↓
FastAPI (Aplica lógica de texto e mensagens de status)
   ↓
App (Exibe humor e diagnóstico personalizado ao usuário)

```

---

### 💡 Dica de Configuração Local

Lembre-se de não subir as credenciais do seu projeto. Antes de rodar a API localmente, crie um arquivo `.env` na raiz desta pasta contendo suas variáveis de ambiente correspondentes.