import processing.serial.*;
import processing.sound.*;

Serial myPort;

int[][] objetivosSets = {
  {1, 0, 2, 3, 4, 5},
  {1, 3, 2, 0, 4, 5},
  {1, 5, 0, 4, 2, 3},
  {1, 4, 3, 0, 2, 5},
  {1, 2, 5, 0, 3, 4}
};

int[] objetivoAtual;
int indiceObjetivo = 0;

String mensagem = "";
int tempoMensagem = 0;

String[] sensorLabels = {"Cérebro", "Coração", "Pulmões", "Estomago", "Rins", "Intestinos"};
float[] sensorValues = new float[6];
boolean[] sensoresAtivados = new boolean[6];
PImage[] imagens = new PImage[6];
PImage backgroundImg;

int[] xPositions = {280, 340, 200, 340, 270, 270};
int[] yPositions = {100, 500, 530, 640, 760, 830};
int organW = 150;
int organH = 150;

float[] thresholds = {
  75, // A0
  60, // A1
  190, // A2
  220, // A3
  250, // A4
  290  // A5
};

int canvasW, canvasH;
float scaleFactor;

boolean jogoAtivo = true;
boolean jogoTerminado = false;
float distancia = 0;

boolean iniciado = false;
int tempoInicio = 0;
int delayInicial = 10000; // 10 segundos

boolean erroRecente = false;
int tempoUltimoErro = 0;
int tempoBloqueioErro = 5000; // 5 segundos de bloqueio para novo erro

boolean erroAtivo = false;
int intervaloErroSerial = 10000; // 10 segundos
int tempoUltimoEnvioErro = -intervaloErroSerial; // Para garantir envio imediato no 1º erro

SoundFile[] sons = new SoundFile[6];
SoundFile erroSom;
boolean[] sonsAtivados = new boolean[6];  // Para não ativar som duas vezes

void settings() {
  backgroundImg = loadImage("bg.png");
  scaleFactor = 700.0 / backgroundImg.width;
  canvasW = int(backgroundImg.width * scaleFactor);
  canvasH = int(backgroundImg.height * scaleFactor);
  size(canvasW, canvasH);
}

void setup() {
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n');

  objetivoAtual = objetivosSets[int(random(5))];
  for (int i = 0; i < 6; i++) {
    imagens[i] = loadImage("img" + i + ".png");
    sons[i] = new SoundFile(this, "audio" + i + ".mp3");
    sons[i].amp(0.1);
    sonsAtivados[i] = false;
  }
  erroSom = new SoundFile(this, "erro.mp3");
  tempoInicio = millis();
}

void draw() {
  image(backgroundImg, 0, 0, canvasW, canvasH);

  // Delay inicial
  if (!iniciado) {
    fill(0, 180);
    rect(0, 0, width, height);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(32);
    text("Bem vindo ao OPERAÇÃO! \n Coloque os orgãos na ordem certa\n para salvar o Carlos Daniel! \n \n \n A preparar Sensores...", width / 2, height / 2);
    if (millis() - tempoInicio > delayInicial) {
      iniciado = true;
    }
    return;
  }

  // Atualizar mensagem do objetivo
  if (!jogoTerminado && indiceObjetivo < objetivoAtual.length && !erroAtivo) {
    int alvo = objetivoAtual[indiceObjetivo];
    mensagem = "Coloque o(s): " + sensorLabels[alvo];
    tempoMensagem = millis();
  }

  // Mostrar imagens
  if (jogoAtivo) {
    for (int i = 0; i < 6; i++) {
      if (sensorValues[i] <= thresholds[i]) {
        tint(255);
      } else {
        tint(0, 150);
      }
      image(imagens[i], xPositions[i], yPositions[i], organW, organH);
      noTint();
      fill(255);
      textAlign(CENTER);
      text(sensorLabels[i] + ": " + int(sensorValues[i]), xPositions[i] + organW / 2, yPositions[i] + organH + 20);
    }

    // Destaque do sensor atual
    if (!jogoTerminado && indiceObjetivo < objetivoAtual.length) {
    }
  } else {
    fill(0, 200);
    rect(0, 0, width, height);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(32);
    text("JOGO PAUSADO\nAproxime-se do sensor", width / 2, height / 2);
  }

  // Mostrar distância
  fill(255);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Distância: " + nf(distancia, 0, 1) + " cm", 10, 10);

  // Mostrar mensagens temporárias
  if (mensagem != "" && millis() - tempoMensagem < 5000) {
  int boxW = 280;
  int boxH = 100;
  int boxX = width - boxW - 20;
  int boxY = 320;

  fill(50, 180); // Cinzento escuro translúcido
  noStroke();
  rect(boxX, boxY, boxW, boxH, 20);

  fill(255); // Texto branco
  textSize(20);
  textAlign(CENTER, CENTER);
  text(mensagem, boxX + boxW / 2, boxY + boxH / 2);
}

  // Mensagem de jogo terminado
  if (jogoTerminado) {
    fill(0, 220);
    rect(0, 0, width, height);
    fill(0, 255, 0);
    textAlign(CENTER, CENTER);
    textSize(40);
    text("JOGO CONCLUÍDO!\nParabéns!", width / 2, height / 2);
    return;
  }

  // Verificação do sensor
  if (jogoAtivo && indiceObjetivo < objetivoAtual.length && !erroAtivo) {
    for (int i = 0; i < 6; i++) {
      if (!sensoresAtivados[i] && sensorValues[i] <= thresholds[i]) {
        verificarSensorAtivado(i);
        break; // só processar um por frame
      }
    }
  }

  // Lógica para manter mensagem de erro e envio serial a cada 10s
  if (erroAtivo) {
    mensagem = "ERRO";
    // Mostra mensagem durante 5 segundos
    if (millis() - tempoUltimoErro < 5000) {
      // Envia mensagem serial "ERRO" a cada 10 segundos
      if (millis() - tempoUltimoEnvioErro >= intervaloErroSerial) {
        myPort.write("ERRO\n");
        tempoUltimoEnvioErro = millis();
      }
    } else {
      erroAtivo = false;
      tempoMensagem = millis();
    }
  }
}


void serialEvent(Serial myPort) {
  String inString = trim(myPort.readStringUntil('\n'));
  if (inString == null || inString.length() == 0) return;

  try {
    if (inString.startsWith("A")) {
      int idx = int(inString.charAt(1)) - int('0');
      if (idx >= 0 && idx < 6) {
        String[] parts = split(inString, ":");
        if (parts.length == 2) {
          sensorValues[idx] = float(trim(parts[1]));
        }
      }
    } else if (inString.startsWith("DISTANCIA")) {
      String[] parts = split(inString, ":");
      if (parts.length == 2) {
        distancia = float(trim(parts[1]));
        jogoAtivo = distancia <= 60;
      }
    }
  }
  catch (Exception e) {
    println("Erro ao processar: " + inString);
    e.printStackTrace();
  }
}

void verificarSensorAtivado(int idx) {
  if (idx == objetivoAtual[indiceObjetivo]) {
    myPort.write("CORRETO\n");
    mensagem = "Parabéns, acertou!";
    tempoMensagem = millis();

    // Tocar som correspondente se ainda não tiver tocado
    if (!sonsAtivados[idx]) {
      sons[idx].loop();
      sonsAtivados[idx] = true;
    }

    sensoresAtivados[idx] = true; // Ignorar este sensor daqui para a frente
    indiceObjetivo++;
    erroAtivo = false; // Limpa erro se estava ativo

    if (indiceObjetivo >= objetivoAtual.length) {
      println("Objetivo concluído!");
      mensagem = "Sequência completa!";
      tempoMensagem = millis();
    }
  } else if (!erroAtivo) {
    // Só ativa erro se não está ativo
    erroAtivo = true;
    tempoUltimoErro = millis();
    tempoUltimoEnvioErro = millis() - intervaloErroSerial;
    myPort.write("ERRO\n");
    erroSom.play();
  }
}
