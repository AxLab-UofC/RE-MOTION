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
  
  void setLed() {
    if (status == Status.PAUSED) {
      if (isRecording) cubes[id].led(0, 255, 0, 0);
      else cubes[id].led(0, 0, 255, 0);
    } else {
      int[][] lights;
      if (isRecording) lights = new int[][]{{50, 255, 0, 0}, {50, 0, 0, 0}};
      else lights = new int[][]{{50, 0, 255, 0}, {50, 0, 0, 0}};
      cubes[id].led(0, lights);
    }
  }
  
  void changeMode() {
    status = Status.PAUSED;
    isRecording = !isRecording;
    
    cubes[id].midi(10, 68, 255);
    setLed();
  }
  
  void unpause() {
    restart();
    int[][] notes = {{10, 63, 20},  {2, 0, 0}, {10, 64, 20}};
    
    if (isRecording) startRecording();
    else sync.startReady(id);
    
    cubes[id].midi(1, notes);
    setLed();
  }
  
  void pause() {
    int[][] notes = {{10, 64, 20}, {2, 0, 0}, {10, 63, 20}};
    cubes[id].midi(1, notes);
    
    status = Status.PAUSED;
    setLed();
  }
  
  void restart() {
    if (moves.size() > 0) toioLoc = new int[]{moves.get(0).x, moves.get(0).y};
    else toioLoc = new int[]{0, 0};
    
    currMove = 0;
    timeElapsed = 0;
  }
  
  void startRecording() {
    startTime = millis();
    status = Status.RECORDING;
    toioLoc = new int[]{0, 0};
    moves = new LinkedList<Movement>();
  }
  
  void startReady() {
    isRecording = false;
    restart();
    status = Status.READYING;
    cubes[id].target(0, toioLoc[0], toioLoc[1], 0);
    setLed();
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
        sync.checkReady(id);
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
      addMove(millis() - startTime, x, y);
    }
  }
  
  void addMove(int t, int x, int y) {
    moves.add(new Movement(t, x, y));
    if (toioLoc[0] == 0 && toioLoc[1] == 0) toioLoc = new int[]{x, y};
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

void saveRecording() {
  Table table = new Table();
  
  table.addColumn("id");
  table.addColumn("timeStamp");
  table.addColumn("x");
  table.addColumn("y");
  
  for (int i = 0; i < nCubes; i++) {
    for (int j = 0; j < cubes[i].record.size(); j++) {
      Movement move = cubes[i].record.getMove(j);
      TableRow newRow = table.addRow();
      newRow.setInt("id", i);
      newRow.setInt("timestamp", move.timestamp);
      newRow.setInt("x", move.x);
      newRow.setInt("y", move.y);
    }
  }
  
  saveTable(table, "data/toio.csv");
}

void loadRecording() {
  Table table = loadTable("toio.csv", "header");
  
  for (int i = 0; i < nCubes; i++) {
    cubes[i].record.isRecording = false;
    cubes[i].record.status = Status.PAUSED;
    
    cubes[i].record.toioLoc = new int[]{0, 0};
    cubes[i].record.moves = new LinkedList<Movement>();
  }
  
   println(table.getRowCount() + " total rows in table");
   println(table.getColumnCount());

  for (TableRow row : table.rows()) {
    int id = row.getInt("id");
    int timestamp = row.getInt("timestamp");
    int x = row.getInt("x");
    int y = row.getInt("y");
    
    cubes[id].record.addMove(timestamp, x, y);
  }
  
  for (int i = 0; i < nCubes; i++) {
    println(cubes[i].record.size());
  }
}
