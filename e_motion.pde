import java.util.*;
import oscP5.*;
import netP5.*;


//constants
//The soft limit on how many toios a laptop can handle is in the 10-12 range
//the more toios you connect to, the more difficult it becomes to sustain the connection
//int nCubes = 12;
int cubesPerHost = 12;


//for OSC
OscP5 oscP5;
//where to send the commands to
NetAddress[] server;

int screenSize = 500;

Cube[] cubes;
int nCubes = 9;

boolean isRecording = true;
Recorder recorder;
Recording recording = new Recording();

void settings() {
  size(screenSize, screenSize, P2D);
}

void setup() {
  //launch OSC sercer
  oscP5 = new OscP5(this, 3333);
  server = new NetAddress[1];
  server[0] = new NetAddress("127.0.0.1", 3334);
  
  cubes = new Cube[nCubes];
  for (int i = 0; i < nCubes; i++) {
    cubes[i] = new Cube(i);
  }
  
  for (int i = 0; i < nCubes; i++) {
    print(i, cubes[i].ready, " ");
  }
  println();
  
  recorder = new Recorder();
  
  //recording = new Recording();
  //for (int i = 0; i < 300; i++) {
  //  recording.addMove(i * 16, 0, i + 60, i + 60);
  //}
  
  recorder.recording = recording;
  
  frameRate(60);
}

void draw() {
  background(200);
  
  //for (int i = 0; i < 100; i++) {
  //  push();
  //  stroke(200, 200, 200, 0);
  //  fill(velColor(i * 0.01));
  //  circle(i * 5, i * 5, 10);
  //  pop();
  //}
  
  for (int i = 0; i < recorder.getMoves().size(); i++) {
    Movement move = recorder.getMove(i);
    push();
    stroke(200, 200, 200, 0);
    fill(recorder.getVelColor(i));
    circle(move.x, move.y, 10);
    pop();
  }
  
  if (!isRecording) {
    if (recording.currMove >= recording.moves.size()) return;
    int[][] toioLocs = recording.toioLocs;
    push();
    fill(255);
    for (int i = 0; i < nCubes; i++) {
      line(cubes[i].x, cubes[i].y, toioLocs[i][0], toioLocs[i][1]);
      circle(toioLocs[i][0], toioLocs[i][1], 20);
    }
    pop();
  }
  
  for (int i = 0; i < nCubes; i++) {
    pushMatrix();
    translate(cubes[i].x, cubes[i].y);
    rect(-10, -10, 20, 20);
    popMatrix();
  }

  if (isRecording) {
    drawUI(recorder.status);
  } else {
    drawUI(recording.status);
    recording.update();
  }
  
}

void keyPressed() {
  switch (key) {
    case 'e':
      if (isRecording) {
        recording = recorder.eject();
        println("Ejected Recording    Start Time:", recording.startTime, "Elapsed Time:", recording.timeElapsed);
        recording.restart();
        isRecording = false;
        recorder.pause(); 
      }
      break;
      
    case ' ':
      if (isRecording) {
        if (recorder.status == "Recording") {
          recorder.pause();
        } else {
          recorder.play();
        }
      } else {
        if (recording.status == "Play") {
          recording.pause();
        } else {
          recording.play();
        }
      }
      break;
      
    case 's':
      if (!isRecording) {
        println("Start Time:", recording.startTime, "Elapsed Time:", recording.timeElapsed);
      }
      break;
      
    case 'r':
      isRecording = true;
      recorder.restart();
      break;
      
    case 'p':
      int[][] lights = {{50, 255, 0, 0}, {50, 0, 0, 0}};
      cubes[0].led(0, lights);
      break;
      
     case 'o':
      cubes[0].led(0, 0, 0, 0);
      break;
     
  }
}

void drawUI(String status) {
  int uiX = 15;
  int uiY = 15;
  int uiScale = 2;
  
  switch (status) {
    case "Pause":
      push();
      fill(100, 225, 100);
      stroke(0,0,0,0);
      translate(width - uiX, uiY);
      rect(0, 0, uiScale * -10, uiScale * 40);
      rect(uiScale * -15,  0, uiScale * -10, uiScale * 40);
      pop();
      break;
      
    case "Play":
      push();
      fill(225, 100, 100);
      stroke(0,0,0,0);
      translate(width - uiX, uiY);
      triangle(0, uiScale * 20, uiScale * -40, uiScale * 40, uiScale * -40, 0);
      pop();
      break;
      
    case "Recording":
      push();
      fill(225, 100, 100);
      stroke(0,0,0,0);
      translate(width - uiX, uiY);
      circle(-40, 40, 40 * uiScale);
      pop();
      break;
    default:
    break;
  }
}
