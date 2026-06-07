#include <Wire.h> // habilita comunicação I2C (Inter-Integrated Circuit)
#include <DHT.h> // biblioteca para configurar DHT11
#include <BH1750.h> // biblioteca para configurar BH1750

// MAPEAMENTO DE PINOS
#define PIN_UMIDADE_SOLO 34 // pino do sensor de umidade de solo
#define PIN_DHT 15 // pino do DHT11

// CONFIGURAÇÃO DOS SENSORES
#define DHTTYPE DHT11 // definindo que será o DHT11 (e não DHT22)
DHT dht(PIN_DHT, DHTTYPE); // cria o objeto do DHT11

BH1750 lightMeter; // cria o objeto medidor pela biblioteca do Christopher Laws

// VARIÁVEIS GLOBAIS DE LEITURA
float umidadeSoloBruto = 0.0; // umidade do solo em valor analógico
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

  // 1. iniciando o barramento I2C (Pinos nativos do ESP32: SDA=21, SCL=22)
  Wire.begin();

  // 2. iniciando o Sensor de Luz BH1750
  if (lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE)) {
    Serial.println("Sensor BH1750 (Luz em Lux) iniciado com sucesso!");
  } else {
    Serial.println("Erro ao iniciar o BH1750! Verifique as conexões SCL/SDA.");
  }

  // 3. iniciando o Sensor de Clima DHT11
  dht.begin();
  Serial.println("Sensor DHT11 (Clima Ar) inicializado!");

  // 4. configura o pino do potenciômetro/solo como entrada
  pinMode(PIN_UMIDADE_SOLO, INPUT);
  
  Serial.println("Sistema totalmente iniciado!! Pronto para fazer as coletas...\n");
}

void loop() {
  //
}
