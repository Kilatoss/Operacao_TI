const int sensorPins[6] = { A0, A1, A2, A3, A4, A5 };
const int ledAcerto = 13;
const int ledErro = 12;

// HC-SR04
const int trigPin = 9;
const int echoPin = 10;

const int thresholds[6] = {
  110, // A0
  45, // A1
  430, // A2
  380, // A3
  400, // A4
  200  // A5
};

String ultimoComando = "";
unsigned long tempoUltimoErro = 0;
bool erroAtivo = false;
unsigned long duracaoErro = 1000;

void setup() {
  pinMode(ledAcerto, OUTPUT);
  pinMode(ledErro, OUTPUT);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.begin(9600);
}

void loop() {
  // Envia valores dos sensores de luz
  for (int i = 0; i < 6; i++) {
    int sensorValue = analogRead(sensorPins[i]);
    Serial.print("A");
    Serial.print(i);
    Serial.print(":");
    Serial.println(sensorValue);
    delay(10);
  }

  // Envia valor da distância do HC-SR04
  long duration;
  float distance;

  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH, 20000); // timeout de 20ms
  distance = duration * 0.034 / 2;

  Serial.print("DISTANCIA:");
  Serial.println(distance);

  // Recebe comandos do Processing
  if (Serial.available()) {
    String comando = Serial.readStringUntil('\n');
    comando.trim();

    if (comando == "CORRETO") {
      digitalWrite(ledAcerto, HIGH);
      delay(5000); // LED aceso por 5 segundos
      digitalWrite(ledAcerto, LOW);
      erroAtivo = false;
      ultimoComando = "CORRETO";
    }
    else if (comando == "ERRO") {
      // Só reage se não está em erro ou já passou o tempo de bloqueio
      if (!erroAtivo || millis() - tempoUltimoErro > duracaoErro) {
        digitalWrite(ledErro, HIGH);
        delay(5000); // LED aceso por 5 segundos
        digitalWrite(ledErro, LOW);

        erroAtivo = true;
        tempoUltimoErro = millis();
        ultimoComando = "ERRO";
      }
    }
  }

  delay(200);
}
