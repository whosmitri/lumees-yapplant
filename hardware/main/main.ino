#include <Wire.h> // habilita comunicação I2C (Inter-Integrated Circuit)
#include <DHT.h> // biblioteca para configurar DHT11
#include <BH1750.h> // biblioteca para configurar BH1750
#include <WiFi.h> // necessária para ler o chip de WiFi e o MAC
#include <HTTPClient.h> // biblioteca para comunicação HTTP
#include <ArduinoJson.h> // empacota arquivos JSON
#include <WiFiManager.h> // configura WiFi de modo externo

// MAPEAMENTO DE PINOS
#define PIN_UMIDADE_SOLO 34 // pino do sensor de umidade de solo
#define PIN_DHT 15 // pino do DHT11

// CONFIGURAÇÃO DOS SENSORES
#define DHTTYPE DHT11 // definindo que será o DHT11 (e não DHT22)
DHT dht(PIN_DHT, DHTTYPE); // cria o objeto do DHT11

BH1750 lightMeter; // cria o objeto medidor pela biblioteca do Christopher Laws

// CONFIGURAÇÃO DA API
const char* url_api = "https://lumees-yapplant.onrender.com/lumees-api/v1/hardware/coleta"; // em "/lumees-api/v1/hardware/coleta"

// CONFIGURAÇÃO DO DEEP SLEEP
#define FATOR_CONVERSAO_MICROSEGUNDOS 1000000 // 1 segundo = 1.000.000 microsegundos
#define TEMPO_DORMIR_SEGUNDOS  600 // 600 segundos = 10 minutos

// VARIÁVEIS GLOBAIS DE LEITURA
String macHardware = ""; // variável para guardar o endereço MAC
float umidadeSoloBruto = 0.0; // umidade do solo em valor analógico
float umidadeSoloValor10bits = 0.0; // umidade solo na escala de 10bits
float umidadeSoloPorcentagem = 0.0; // umidade do solo em porcentagem
float luxLuminosidade = 0.0; // luminosidade em lux
float temperaturaAr = 0.0; // temperatura do ar
float umidadeAr = 0.0; // umidade do ar

void setup() {
  // 0. iniciando a comunicação Serial + imprimindo desenho legal !!
  Serial.begin(115200);
  Serial.println("     _");
  Serial.println("   _(_)_");
  Serial.println("  (_)@(_)");
  Serial.println("    (_)\\");
  Serial.println("       |");
  Serial.println("      \\|/");
  Serial.println("   __\\\\|/lumees");
  Serial.println("   \\  ___  /");
  Serial.println("    |     |");
  Serial.println("    \\_____/");
  Serial.println("\n[Lumees Yapplanta] Inicializando o Hardware...");

  // 1. WIFIMANAGER (conexão externa)
  WiFiManager wifiMan;

  // se o ESP32 não tiver rede salva, ele cria o ponto de acesso "Lumees_Yapp_Setup"
  // O wokwi vai passar direto por aqui porque ele simula uma rede aberta automaticamente
  Serial.println("Conectando ao Wi-Fi...");
  if(!wifiMan.autoConnect("Lumees_Yapp_Setup", "lumees024")) {
      Serial.println("Falha na conexão e estourou o tempo limite. Reiniciando...");
      ESP.restart();
  } 
  Serial.println("WiFi Conectado com sucesso!!");

  // 2. CAPTURA DO MAC ADDRESS
  // ativando o modo Station do WiFi pro chip acordar o rádio e ler o endereço
  WiFi.mode(WIFI_STA); 
  macHardware = WiFi.macAddress(); // captura o MAC no formato padrão "AA:BB:CC:DD:EE:FF"
  
  Serial.print("MAC Address deste hardware: ");
  Serial.println(macHardware); // esse é o identificado único

  // 3. iniciando o barramento I2C (Pinos nativos do ESP32: SDA=21, SCL=22)
  Wire.begin();

  // 4. iniciando o Sensor de Luz BH1750
  if (lightMeter.begin(BH1750::ONE_TIME_HIGH_RES_MODE)) {
    Serial.println("Sensor BH1750 (Luz em Lux) iniciado com sucesso!");
  } else {
    Serial.println("Erro ao iniciar o BH1750! Verifique as conexões SCL/SDA.");
  }

  // 5. iniciando o Sensor de Clima DHT11
  dht.begin();
  Serial.println("Sensor DHT11 (Clima Ar) inicializado!");

  // 6. configura o pino do potenciômetro/solo como entrada
  pinMode(PIN_UMIDADE_SOLO, INPUT);
  
  Serial.println("Sistema totalmente iniciado!! Pronto para fazer as coletas...\n");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    // 1. LEITURA DO SENSOR DE UMIDADE DE SOLO
    // no ESP32, o analogRead vai de 0 a 4095 (12 bits)
    umidadeSoloBruto = analogRead(PIN_UMIDADE_SOLO);

    //// TRANSFORMA O VALOR LIDO PRA ESCALA DE 10bits
    umidadeSoloValor10bits = map(umidadeSoloBruto, 0, 4095, 0, 1023);
    umidadeSoloValor10bits = constrain(umidadeSoloValor10bits, 0, 1023); // trava de segurança para não ser menor que 0 e não ultrapassar 1023
    
    //// MAPEAMENTO E INVERSÃO DA LÓGICA:
    // solo seco na água cospem valores altos (~4095)
    // solo encharcado cospe valor baixo (~0)
    // mapeando: 4095 vira 0% (seco) e 0 vira 100% (molhado)
    umidadeSoloPorcentagem = map(umidadeSoloBruto, 4095, 0, 0, 100);
    
    // garante que o valor fique travado entre 0% e 100% para não dar bugs visuais
    umidadeSoloPorcentagem = constrain(umidadeSoloPorcentagem, 0, 100);

    // 2. LEITURA DO DHT11 (TEMPERATURA E UMIDADE DO AR)
    temperaturaAr = dht.readTemperature();
    umidadeAr = dht.readHumidity();

    // 3. VALIDAÇÃO DE LEITURAS (se o DHT falhar)
    if (isnan(temperaturaAr) || isnan(umidadeAr)) {
      Serial.println("Falha ao ler o sensor DHT11! Mantendo valores zerados.");
      temperaturaAr = 0.0;
      umidadeAr = 0.0;
    }

    // 4. LEITURA DO BH1750 (modo One-Time limpa o sensor e faz a leitura real)
    lightMeter.begin(BH1750::ONE_TIME_HIGH_RES_MODE);
    delay(180); // aguarda o sensor processar a luz física antes de ler
    luxLuminosidade = lightMeter.readLightLevel();

    // 5. EXIBIÇÃO DOS DADOS FORMATADOS NO MONITOR SERIAL
    Serial.println("=====================================");
    Serial.print("* ID Dispositivo (MAC): "); Serial.println(macHardware);

    Serial.print("* Umidade do Solo (0-4095): "); Serial.println(umidadeSoloBruto);
    Serial.print("* Umidade do Solo (0-1023): "); Serial.println(umidadeSoloValor10bits); 
    Serial.print("* Umidade do Solo (%): "); Serial.print(umidadeSoloPorcentagem); Serial.println("%");

    Serial.print("* Temperatura do Ar: "); Serial.print(temperaturaAr); Serial.println("°C");
    Serial.print("* Umidade do Ar: "); Serial.print(umidadeAr); Serial.println("%");
    
    Serial.print("* Luminosidade: "); Serial.print(luxLuminosidade); Serial.println(" lx");
    Serial.println("=====================================\n");

    // 6. EMPACOTANDO TUDO NO JSON COMPATÍVEL COM API
    // criando um documento JSON estático alocando memória para ele
    StaticJsonDocument<300> doc;
      
    doc["mac_hardware"] = macHardware;
    doc["umidade_solo_bruto"] = umidadeSoloValor10bits; // passando a escala da IA (0-1023)
    doc["umidade_solo_porcentagem"] = umidadeSoloPorcentagem; // passando amigável ao user (0-100)
    doc["luminosidade"] = luxLuminosidade;
    doc["temperatura_ar"] = temperaturaAr;
    doc["umidade_ar"] = umidadeAr;
    
    // transforma o objeto JSON em uma String de texto comum para viajar na rede
    String jsonString;
    serializeJson(doc, jsonString);

    // 7. DISPARANDO O POST HTTP PARA O BACKEND
    HTTPClient http; // criando o cliente HTTP
    http.begin(url_api); // define o endereço do servidor
    http.addHeader("Content-Type", "application/json"); // avisa a API que estamos mandando JSON

    Serial.println("=====================================");
    Serial.println("Enviando dados para a API...");
    Serial.print("Payload: "); Serial.println(jsonString);

    // faz a requisição POST de fato e armazena o status HTTP de resposta (Ex: 200, 400, 500)
    int codigoRespostaHTTP = http.POST(jsonString);

    if (codigoRespostaHTTP > 0) {
      String respostaServidor = http.getString();
      Serial.print("Resposta da API [HTTP "); Serial.print(codigoRespostaHTTP); Serial.println("]:");
      Serial.println(respostaServidor);
    } else {
      Serial.print("Erro no envio HTTP POST: ");
      Serial.println(http.errorToString(codigoRespostaHTTP).c_str());
    }
      
    http.end(); // Fecha a conexão para liberar memória
    Serial.println("=====================================\n");

  } else {
    Serial.println("Wi-Fi desconectado! Tentando reconectar automaticamente...");
  }

  // entre em deep sleep por 10 minutos até a próxima leitura
  irParaDeepSleep();
}

// função auxiliar para ativar o Deep Sleep de forma limpa
void irParaDeepSleep() {
  Serial.println("Desconectando o Wi-Fi para dormir de forma segura...");
  WiFi.disconnect(true);
  
  Serial.println("Entrando em Deep Sleep por 10 minutos agora. Até logo!");
  esp_sleep_enable_timer_wakeup(TEMPO_DORMIR_SEGUNDOS * FATOR_CONVERSAO_MICROSEGUNDOS);
  esp_deep_sleep_start();
}
