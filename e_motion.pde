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
float scale = 1.2;

Cube[] cubes;
int nCubes = 9;

//boolean isRecording = true;
//Recorder recorder;
//Recording recording = new Recording();

void settings() {
  size( (int) (screenSize * scale), (int) (screenSize * scale), P2D);
}

void setup() {
  //launch OSC sercer
  oscP5 = new OscP5(this, 3333);
  server = new NetAddress[1];
  server[0] = new NetAddress("127.0.0.1", 3334);
  
  cubes = new Cube[nCubes];
  for (int i = 0; i < nCubes; i++) {
    cubes[i] = new Cube(i);
    cubes[i].led(0, 255, 0, 0);
  }
  
  frameRate(60);
}

void draw() {
  background(200);
  push();
  noFill();
  rect(45, 45, 410 * scale, 410 * scale);
  pop();
  
  for (int i = 0; i < nCubes; i++) {
    if (cubes[i].isActive) {
      cubes[i].record.update();
      
      for (int j = 0; j < cubes[i].record.size(); j++) {
        Movement move = cubes[i].record.getMove(j);
        push();
        stroke(200, 200, 200, 0);
        fill(cubes[i].record.getVelColor(j));
        circle(move.x * scale, move.y * scale, 10 * scale);
        pop();
      }
      
      if (!cubes[i].record.isRecording) {
        int[] toioLoc = new int[]{cubes[i].record.toioLoc[0], cubes[i].record.toioLoc[1]};
        line(cubes[i].x * scale, cubes[i].y * scale, toioLoc[0] * scale, toioLoc[1] * scale);
        circle(toioLoc[0] * scale, toioLoc[1] * scale, 20);
      }
      
      pushMatrix();
      translate(cubes[i].x * scale, cubes[i].y * scale);
      rect(-10, -10, 20* scale, 20 * scale);
      popMatrix();

    }
    
    if (cubes[i].buttonDown && millis() - cubes[i].lastPressed > 1000) { 
      cubes[i].record.changeMode();
      cubes[i].buttonDown = false;
    }
  }
}
