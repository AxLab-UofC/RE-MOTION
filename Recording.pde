enum Status {
  RECORDING, PLAY, PAUSED, READYING
}

class Movement {
  int timestamp;
  int x;
  int y;
  
  Movement(int t, int xloc, int yloc) {
    timestamp = t;
    x = xloc;
    y = yloc;
  }
}

class recordManager {
  int id;
  boolean isRecording;
  Status status;
  
  LinkedList<Movement> moves;
  int[] toioLoc;
  int currMove;
  int timeElapsed;
  int startTime;
  
  recordManager(int i) {
    id = i;
    isRecording = true;
    status = Status.PAUSED;
    
    toioLoc = new int[]{0, 0};
    moves = new LinkedList<Movement>();
  }
  
  int size() {
    return moves.size();
  }
  
  void changeMode() {
    status = Status.PAUSED;
    isRecording = !isRecording;
    
    cubes[id].midi(10, 68, 255);
    
    if (isRecording) cubes[id].led(0, 255, 0, 0);
    else cubes[id].led(0, 0, 255, 0);
  }
  
  void unpause() {
    restart();
    int[][] notes = {{10, 63, 20},  {2, 0, 0}, {10, 64, 20}};
    int[][] lights;
    
    if (isRecording) {
      startRecording();
      lights = new int[][]{{50, 255, 0, 0}, {50, 0, 0, 0}};
    } else {
      startReady();
      lights = new int[][]{{50, 0, 255, 0}, {50, 0, 0, 0}};
    }
    
    cubes[id].midi(1, notes);
    cubes[id].led(0, lights);
  }
  
  void pause() {
    int[][] notes = {{10, 64, 20}, {2, 0, 0}, {10, 63, 20}};
    cubes[id].midi(1, notes);
    
    status = Status.PAUSED;
    if (isRecording) {
      cubes[id].led(0, 255, 0, 0);
    } else {
      cubes[id].led(0, 0, 255, 0);
    }
  }
  
  void restart() {
    if (moves.size() > 0) toioLoc = new int[]{moves.get(0).x, moves.get(0).y};
    else toioLoc = new int[]{0, 0};
    
    currMove = 0;
    timeElapsed = 0;
    pause();
  }
  
  void startRecording() {
    startTime = millis();
    status = Status.RECORDING;
    toioLoc = new int[]{0, 0};
    moves = new LinkedList<Movement>();
  }
  
  void startReady() {
    currMove = 0;
    timeElapsed = 0;
    status = Status.READYING;
    cubes[id].target(0, toioLoc[0], toioLoc[1], 0);
  }
  
  void startPlay() {
    status = Status.PLAY;
    startTime = millis();
  }
  
  void execute() {
    cubes[id].velocityTarget(toioLoc[0], toioLoc[1]);
  }
  
  void update() {
    switch (status) {
      case READYING:
        if (cubes[id].ready == true) startPlay();
        break;
      
      case PLAY:
        execute();
        
        int currTime = millis() - startTime;
        
        if (currMove > moves.size()) startReady();
        
        while (moves.get(currMove).timestamp < currTime) {
          toioLoc = new int[]{moves.get(currMove).x, moves.get(currMove).y};
          currMove++;
          if (currMove >= moves.size()) {
            startReady();
            break;
          }
        }
        break;
        
       default:
         break;
    }
  }
  
  void addMove(int x, int y) {
    if (status == Status.RECORDING) {
      int t = millis() - startTime;
      moves.add(new Movement(t, x, y));
      
      if (toioLoc[0] == 0 && toioLoc[1] == 0) toioLoc = new int[]{x, y};
    }
  }
  
  Movement getMove(int i) {
    return moves.get(i);
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
}
