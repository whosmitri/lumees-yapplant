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

  // 1. iniciando o barramento I2C (Pinos nativos do ESP32: SDA=21, SCL=22)
  Wire.begin();

  // 2. iniciando o Sensor de Luz BH1750
  if (lightMeter.begin(BH1750::ONE_TIME_HIGH_RES_MODE)) {
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

  // 3. LEITURA DO BH1750 (LUMINOSIDADE EM LUX)
  luxLuminosidade = lightMeter.readLightLevel();

  // 4. VALIDAÇÃO DE LEITURAS (se o DHT falhar)
  if (isnan(temperaturaAr) || isnan(umidadeAr)) {
    Serial.println("Falha ao ler o sensor DHT11! Mantendo valores zerados.");
    temperaturaAr = 0.0;
    umidadeAr = 0.0;
  }

  // 5. EXIBIÇÃO DOS DADOS FORMATADOS NO MONITOR SERIAL
  Serial.println("=====================================");
  //Serial.print("* Umidade do Solo (Bruta): "); Serial.print(umidadeSoloBruto);
  //Serial.print(" | Porcentagem: "); Serial.print(umidadeSoloPorcentagem); Serial.println("%");
  
  Serial.print("* Umidade do Solo (0-4095): "); Serial.println(umidadeSoloBruto);
  Serial.print("* Umidade do Solo (0-1023): "); Serial.println(umidadeSoloValor10bits); 
  Serial.print("* Umidade do Solo (%): "); Serial.print(umidadeSoloPorcentagem); Serial.println("%");

  Serial.print("* Temperatura do Ar: "); Serial.print(temperaturaAr); Serial.println("°C");
  Serial.print("* Umidade do Ar: "); Serial.print(umidadeAr); Serial.println("%");
  
  Serial.print("* Luminosidade: "); Serial.print(luxLuminosidade); Serial.println(" lx");
  Serial.println("=====================================\n");

  // o DHT11 precisa de pelo menos 2 segundos entre as leituras para não travar
  delay(2000); 
}
