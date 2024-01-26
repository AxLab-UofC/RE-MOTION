class Movement {
  int timestamp;
  int id;
  int x;
  int y;
  
  Movement(int t, int cubeid, int xloc, int yloc) {
    timestamp = t;
    id = cubeid;
    x = xloc;
    y = yloc;
  }
  
  void execute() {
    cubes[id].velocityTarget(x, y);
  }
}

class Recording {
  int[][] toioLocs;
  LinkedList<Movement> moves;
  int currMove;
  int timeElapsed;
  int startTime;
  String status = "Pause";
  
  Recording() {
    moves = new LinkedList<Movement>();
    currMove = 0;
    timeElapsed = 0;
    startTime = 0;
    
    toioLocs = new int[nCubes][2];
    for (int i = 0; i < nCubes; i++) {
      toioLocs[i][0] = 0;
      toioLocs[i][1] = 0;
    }
  }
  
  void addMove(int t, int id, int x, int y) {
    moves.add(new Movement(t, id, x, y));
    if (toioLocs[id][0] == 0 && toioLocs[id][1] == 0) {
      toioLocs[id][0] = x;
      toioLocs[id][1] = y;
    }
  }
  
  void getReady() { 
    for (int i = 0; i < nCubes; i++) {
      if (cubes[i].isActive) {
        cubes[i].target(0, toioLocs[i][0], toioLocs[i][1], 0);
      }
    }
    status = "Prepping";
  }
  
  boolean checkReady(){
    for (int i = 0; i < nCubes; i++) {
      if (!cubes[i].ready) {
        return false;
      }
    }
    return true;
  }
  
  void play() {
    startTime = millis() - timeElapsed;
    status = "Play";
  }
  
  void pause() {
    timeElapsed = millis() - startTime;
    status = "Pause";
  }
  
  void restart() {
    currMove = 0;
    timeElapsed = 0;
    startTime = 0;
    status = "Pause";
  }
  
  Movement getMove(int i) {
    return moves.get(i);
  }
  
  void setMove(Movement move) {
    toioLocs[move.id][0] = move.x;
    toioLocs[move.id][1] = move.y;
  }
  
  void execute() {
    for (int i = 0; i < nCubes; i++) {
      cubes[i].velocityTarget(toioLocs[i][0], toioLocs[i][1]);
    }
  }
  
  float getVelocity(int i) {
    if (i == 0) return 1;
    else {
      Movement move1 = getMove(i - 1);
      Movement move2 = getMove(i);
      
      return sqrt(pow(move2.x - move1.x, 2) + pow(move2.y - move1.y, 2)) / (move2.timestamp - move1.timestamp);
    }
  }
  
  void update() {
    if (status == "Prepping" && checkReady()) status = "Play";
    else if (status != "Play") return;
    
    execute();
    
    int currTime = millis() - startTime;
    
    if (currMove < moves.size()) {
      while (moves.get(currMove).timestamp < currTime) {
       Movement curr = moves.get(currMove);
       setMove(curr);
       currMove++;
       if (currMove >= moves.size()) {
         restart();
         break;
       }
      }
    }
  } 
}

class Recorder {
  Recording recording;
  int timeElapsed;
  int startTime;
  String status = "Pause";
  
  Recorder() {
    recording = new Recording();
    timeElapsed = 0;
    startTime = 0;
  }
  
  void play() { 
    startTime = millis() - timeElapsed;
    status = "Recording";
  }
  
  void pause() {
    timeElapsed = millis() - startTime;
    status = "Pause";
  }
  
  void restart() {
    recording = new Recording();
    timeElapsed = 0;
    startTime = 0;
    status = "Pause";
  }
  
  void update(int id, int x, int y) {
    if (status != "Recording") return;
    
    int currTime = millis() - startTime;
    
    recording.addMove(currTime, id, x, y);
    //println("Recording:", currTime, id, x, y);
  } 
  
  LinkedList<Movement> getMoves() {
    return recording.moves;
  }
  
  Movement getMove(int i) {
    return getMoves().get(i);
  }
  
  float getVelocity(int i) {
    if (i == 0) return 1;
    else {
      Movement move1 = getMove(i - 1);
      Movement move2 = getMove(i);
      
      int delta = move2.timestamp - move1.timestamp;
      if (delta == 0) delta = 1;
      
      return sqrt(pow(move2.x - move1.x, 2) + pow(move2.y - move1.y, 2)) / 3;
    }
  }
  
  color getVelColor(int i) {
    float v = getVelocity(i);
    if (v > 1) v = 1;
    
    if (v < .5) return color(lerp(183, 252, v * 2), lerp(225, 232, v * 2), lerp(205, 178, v * 2));
    else return color(lerp(252, 244, (v - .5) * 2), lerp(232, 199, (v - .5) * 2), lerp(178, 195, (v - .5) * 2));
  }
  
  Recording eject() {
    status = "Done";
    return recording;
  }
  
}

color velColor(float v) {
  
  if (v < .5) return color(lerp(183, 252, v * 2), lerp(225, 232, v * 2), lerp(205, 178, v * 2));
  else return color(lerp(252, 244, (v - .5) * 2), lerp(232, 199, (v - .5) * 2), lerp(178, 195, (v - .5) * 2));
}
