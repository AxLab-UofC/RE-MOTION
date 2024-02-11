import java.util.*;
import oscP5.*;
import netP5.*;

// for new Mac OS, in Processing, if your window won't pop up after hitting compile, copy and paste below code before setup()
import com.jogamp.opengl.GLProfile;
{
  GLProfile.initSingleton();
}


//constants
//The soft limit on how many toios a laptop can handle is in the 10-12 range
//the more toios you connect to, the more difficult it becomes to sustain the connection
//int nCubes = 12;
int nCubes = 5;
int cubesPerHost = nCubes;

boolean AngleControlMode = true; // AngleControlMode is experimental, turn this to false, to remove angle to be targetted.
boolean debug = true;


//for OSC
OscP5 oscP5;
//where to send the commands to
NetAddress[] server;

int screenSize = 500;
float scale = 1.2;

Cube[] cubes;
SyncSystem sync;
UI ui = new UI();


PImage axlab;
PImage remotion;

//for new Mac OS, in Processing, if your window won't pop up after hitting compile, copy and paste below code before setup()
import com.jogamp.opengl.GLProfile;
{
  GLProfile.initSingleton();
}


void settings() {
  size( (int) (screenSize * scale) + 200, (int) (screenSize * scale) + 50, P2D);
  
  smooth();

}

void setup() {
  //launch OSC sercer
  oscP5 = new OscP5(this, 3333);
  server = new NetAddress[1];
  server[0] = new NetAddress("127.0.0.1", 3334);
  sync = new SyncSystem();

  cubes = new Cube[nCubes];
  for (int i = 0; i < nCubes; i++) {
    cubes[i] = new Cube(i);
    cubes[i].led(0, 255, 0, 0);
  }
  axlab = loadImage("axlab.png");
  remotion = loadImage("remotion.png");
  frameRate(60);
  
}

void draw() {
  background(200);
  image(remotion, 45, 25, remotion.width/6, remotion.height/6);
  float scaleFactor = (remotion.height/5.5) / (float) axlab.height;

  image(axlab, width - 45 - (axlab.width * scaleFactor), 25, axlab.width * scaleFactor, axlab.height * scaleFactor);


  push();
  translate(0, 50);
  fill(255);

  //image(img, 0, 0, width/2, height/2);
  rect(45, 45, 410 * scale, 410 * scale);

  sync.update();
  long now = System.currentTimeMillis();


  for (int i = 0; i < nCubes; i++) {
    for (int j = 0; j < cubes[i].record.size(); j++) {
      Movement move = cubes[i].record.getMove(j);
      push();
      stroke(200, 200, 200, 0);
      fill(cubes[i].record.getVelColor(j));
      circle(move.x * scale, move.y * scale, 10 * scale);
      pop();
    }
  }

  for (int i = 0; i < nCubes; i++) {
    cubes[i].record.update();
    cubes[i].checkActive(now);

    if (cubes[i].isActive) {


      pushMatrix();
      translate(cubes[i].x * scale, cubes[i].y * scale);
      rotate(radians(cubes[i].theta));
      push();
      strokeWeight(2);
      stroke(0);
      fill(255,50);
      rect(-(20* scale)/2, -(20* scale)/2, 20* scale, 20 * scale);
      line(0, 0, (20* scale)/2, 0);
      pop();
      popMatrix();

      if (!cubes[i].record.isRecording) {
        push();
        int[] toioLoc = new int[]{cubes[i].record.toioLoc[0], cubes[i].record.toioLoc[1], cubes[i].record.toioLoc[2]};
        stroke(150);
        //strokeWeight(1);

        line(cubes[i].x * scale, cubes[i].y * scale, toioLoc[0] * scale, toioLoc[1] * scale);

        pushMatrix();
        translate(toioLoc[0] * scale, toioLoc[1] * scale);
        rotate(radians(toioLoc[2]));

        noFill();
        rect(-(20* scale)/2, -(20* scale)/2, 20* scale, 20 * scale);
        line(0, 0, (20* scale)/2, 0);
        popMatrix();
        pop();
      }
    }

    if (cubes[i].buttonDown && millis() - cubes[i].lastPressed > 1000) {
      cubes[i].record.changeMode();
      cubes[i].buttonDown = false;
    }
  }

  ui.draw();
  pop();
}

void keyPressed() {
  switch (key) {
  case 's':
    selectOutput("Select a file to write to:", "saveRecording");
    break;

  case 'l':
    selectInput("Select a file to process:", "loadRecording");
    break;
    
  case 'd':
    debug = !debug;
    if (!debug) {
      for (int i = 0; i < nCubes; i++) {
        cubes[i].led(0, 0, 0, 0);
      }
    }
    break;
  }
}

void mousePressed() {
  ui.checkButtons(mouseX, mouseY);
}
