# 🌱 Mobile: Interface Gamificada e Monitoramento

Este diretório contém o código-fonte da aplicação móvel do ecossistema **Lumees Yapplant**. Desenvolvido inteiramente em **Flutter (Dart)**, o aplicativo atua como a interface principal do usuário, transformando os dados brutos de telemetria em uma experiência visual, gamificada e interativa.

## ✨ Principais Funcionalidades

* **Gamificação Botânica:** O avatar da planta altera sua expressão e interface dinamicamente com base nas leituras em tempo real (ex: "com sede", "com calor", "encharcada"), priorizando o estado mais crítico.
* **Ambiente Dinâmico:** A interface reage ao mundo real utilizando a localização do dispositivo para definir a estação do ano e consultando a *Sunrise-Sunset API* para alternar o fundo de tela entre Dia e Noite.
* **Monitoramento em Tempo Real:** Uso de `StreamBuilder` conectado ao **Firebase Firestore** para atualizar os *cards* de sensores instantaneamente assim que o ESP32 envia uma nova leitura.
* **Análise Histórica e Gráficos:** Implementação de gráficos de linha e barra interativos (via `fl_chart`) para visualizar o comportamento da umidade, luminosidade e temperatura nas últimas 5 horas.
* **Diagnóstico com IA (Lee):** Integração HTTP direta com o microsserviço em FastAPI para solicitar análises complexas baseadas no algoritmo KNN, retornando relatórios humanizados.
* **Exportação de Dados:** Geração e download do histórico completo da planta em formato CSV (não disponível por dependência do Firebase).



## 📁 Arquitetura do Projeto (Padrão MVC/Services)

O código foi estruturado visando fácil entendimento, separando a lógica de negócio da camada de interface visual. Toda a base de código reside na pasta `lib/`:

```text
lib/
├── main.dart                  # Ponto de entrada e configuração de rotas
├── firebase_options.dart      # Credenciais geradas pelo FlutterFire CLI
│
├── pages/                     # Telas completas da aplicação (Screens)
│
├── widgets/                   # Componentes visuais reutilizáveis
│   ├── app_bottom_navigation.dart # Barra de navegação customizada
│   ├── card_sensor.dart       # Cards padronizados para leitura dos sensores
│   └── *_chart.dart           # Componentização individual de cada gráfico
│
├── services/                  # Lógica de negócio, APIs e integrações
│   ├── api_service.dart       # Comunicação HTTP com o Backend FastAPI
│   ├── auth_service.dart      # Métodos de autenticação no Firebase Auth
│   ├── database_service.dart  # Consultas e inserções no Firestore (NoSQL)
│   ├── location_service.dart  # Controle de permissões e GPS via Geolocator
│   └── time_service.dart      # Consulta de horários de nascer/pôr do sol
│
└── theme/                     # Design da aplicação
    └── app_theme.dart         # Paleta de cores, tipografia (Google Fonts) e formas

```


## 📦 Principais Dependências e Pacotes

Este projeto faz uso de pacotes robustos da comunidade Flutter para garantir performance e escalabilidade:

* **`firebase_core`, `firebase_auth`, `cloud_firestore`:** SDKs oficiais para autenticação e banco de dados em tempo real.
* **`fl_chart`:** Biblioteca para a plotagem dos gráficos de telemetria.
* **`http`:** Cliente HTTP para a comunicação com o backend em Python (FastAPI) e APIs externas de tempo.
* **`geolocator`:** Acesso nativo aos serviços de GPS do dispositivo (Android/iOS).
* **`google_fonts`:** Gerenciamento otimizado da tipografia central do app (Inter).


## 🚀 Como Executar o Projeto Localmente

### 1. Pré-requisitos

* [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado na sua máquina.
* Um emulador configurado (Android Studio / VS Code).

### 2. Instalação e Execução

Clone o repositório e navegue até a pasta do aplicativo:

```bash
cd mobile
```

Baixe todas as dependências do projeto listadas no `pubspec.yaml`:

```bash
flutter pub get
```

Execute o aplicativo no dispositivo selecionado:

```bash
flutter run
```

> **Nota sobre o Firebase:** O arquivo `firebase_options.dart` já contém as chaves públicas necessárias para comunicação com o projeto `lumees-yapp`. Não é necessária nenhuma configuração adicional de ambiente para testes de interface.

> **Nota sobre a API da IA:** A comunicação com a Inteligência Artificial está configurada para acessar o ambiente de produção hospedado no Render (`https://lumees-yapplant.onrender.com/lumees-api/v1`). Caso deseje testar a IA localmente, altere a URL base no arquivo `lib/services/api_service.dart` para o seu `localhost` correspondente.