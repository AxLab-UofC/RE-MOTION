enum Status {
  RECORDING, PLAY, PAUSED, READYING
}

class Movement {
  int timestamp;
  int x;
  int y;
  int theta;

  Movement(int t, int xloc, int yloc, int thetaloc) {
    timestamp = t;
    x = xloc;
    y = yloc;
    theta = thetaloc;
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

    toioLoc = new int[]{0, 0, 0};
    moves = new LinkedList<Movement>();
  }

  int size() {
    return moves.size();
  }

  void setLed() {
    if (!debug) return;
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
<<<<<<< Updated upstream

    cubes[id].midi(10, 68, 255);
=======
    
    if (debug) cubes[id].midi(10, 68, 255);
>>>>>>> Stashed changes
    setLed();
  }

  void unpause() {
    restart();
    int[][] notes = {{10, 63, 20}, {2, 0, 0}, {10, 64, 20}};

    if (isRecording) startRecording();
    else sync.startReady(id);
<<<<<<< Updated upstream

    cubes[id].midi(1, notes);
=======
    
    if (debug) cubes[id].midi(1, notes);
>>>>>>> Stashed changes
    setLed();
  }

  void pause() {
    int[][] notes = {{10, 64, 20}, {2, 0, 0}, {10, 63, 20}};
<<<<<<< Updated upstream
    cubes[id].midi(1, notes);

=======
    if (debug) cubes[id].midi(1, notes);
    
>>>>>>> Stashed changes
    status = Status.PAUSED;
    setLed();
  }

  void restart() {
    if (moves.size() > 0) toioLoc = new int[]{moves.get(0).x, moves.get(0).y, moves.get(0).theta};
    else toioLoc = new int[]{0, 0, 0};

    currMove = 0;
    timeElapsed = 0;
  }

  void startRecording() {
    startTime = millis();
    status = Status.RECORDING;
    toioLoc = new int[]{0, 0, 0};
    moves = new LinkedList<Movement>();
  }

  void startReady() {
    isRecording = false;
    restart();
    status = Status.READYING;
    cubes[id].target(0, toioLoc[0], toioLoc[1], toioLoc[2]);
    setLed();
  }

  void startPlay() {
    status = Status.PLAY;
    startTime = millis();
  }

  void execute() {
<<<<<<< Updated upstream
    if (AngleControlMode) {
      cubes[id].velocityTargetAngle(toioLoc[0], toioLoc[1], toioLoc[2]);
    } else {
      cubes[id].velocityTarget(toioLoc[0], toioLoc[1]);
=======
    cubes[id].velocityTarget(toioLoc[0], toioLoc[1]);
    
    // cubes[id].velocityTargetAngle(toioLoc[0], toioLoc[1]);
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
          toioLoc = new int[]{moves.get(currMove).x, moves.get(currMove).y, moves.get(currMove).theta};
          currMove++;
          if (currMove >= moves.size()) {
            startReady();
            if (debug) cubes[id].midi(20, 64, 255);
            break;
          }
        }
        break;
        
       default:
         break;
>>>>>>> Stashed changes
    }
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
        toioLoc = new int[]{moves.get(currMove).x, moves.get(currMove).y, moves.get(currMove).theta};
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

  void addMove(int x, int y, int theta) {
    if (status == Status.RECORDING) {
      addMove(millis() - startTime, x, y, theta);
    }
  }

  void addMove(int t, int x, int y, int theta) {
    moves.add(new Movement(t, x, y, theta));
    if (toioLoc[0] == 0 && toioLoc[1] == 0) toioLoc = new int[]{x, y, theta};
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

      return sqrt(pow(move2.x - move1.x, 2) + pow(move2.y - move1.y, 2)) / 6;
    }
  }

  color getVelColor(int i) {
    float v = getVelocity(i);
    if (v > 1) v = 1;

    if (v < .5) return color(lerp(183, 252, v * 2), lerp(225, 232, v * 2), lerp(205, 178, v * 2));
    else return color(lerp(252, 244, (v - .5) * 2), lerp(232, 199, (v - .5) * 2), lerp(178, 195, (v - .5) * 2));
  }

  String getStatus() {
    switch(status) {
    case RECORDING:
      return "RECORDING";

    case PLAY:
      return "PLAY";

    case READYING:
      return "READYING";

    default:
      return "STANDBY";
    }
  }
}

void saveRecording(File selection) {
  if (selection == null) {
    ui.addMsg("Saving Failed.");
    return;
  }

  Table table = new Table();

  table.addColumn("datatype");
  table.addColumn("syncgroup");
  table.addColumn("id");
  table.addColumn("timestamp");
  table.addColumn("x");
  table.addColumn("y");
  table.addColumn("theta");

  for (int i = 0; i < nCubes; i++) {
    for (int j = 0; j < cubes[i].record.size(); j++) {
      Movement move = cubes[i].record.getMove(j);
      TableRow newRow = table.addRow();
      newRow.setInt("datatype", 0);
      newRow.setInt("id", i);
      newRow.setInt("timestamp", move.timestamp);
      newRow.setInt("x", move.x);
      newRow.setInt("y", move.y);
      newRow.setInt("theta", move.theta);
    }
  }

  for (int i = 0; i <  sync.syncedSets.size(); i++) {
    for (int j = 0; j < sync.syncedSets.get(i).size(); j++) {
      TableRow newRow = table.addRow();
      newRow.setInt("datatype", 1);
      newRow.setInt("syncgroup", i);
      newRow.setInt("id", j);
    }
  }

  String name = selection.getAbsolutePath();
  if (name.substring(name.length() - 4) == ".csv") saveTable(table, selection.getAbsolutePath());
  else saveTable(table, name + ".csv");
  ui.addMsg("Recording Saved!");
}

void loadRecording(File selection) {
  if (selection == null) {
    ui.addMsg("Loading Failed.");
    return;
  }

  try {
    Table table = loadTable(selection.getAbsolutePath(), "header");
    sync.syncedSets = new LinkedList<>();

    for (int i = 0; i < nCubes; i++) {
      cubes[i].record.isRecording = false;
      cubes[i].record.status = Status.PAUSED;

      cubes[i].record.toioLoc = new int[]{0, 0, 0};
      cubes[i].record.moves = new LinkedList<Movement>();
    }

    for (TableRow row : table.rows()) {
      if (row.getInt("datatype") == 0) {
        int id = row.getInt("id");
        int timestamp = row.getInt("timestamp");
        int x = row.getInt("x");
        int y = row.getInt("y");
        int theta = row.getInt("theta");

        cubes[id].record.addMove(timestamp, x, y, theta);
      } else {
        int syncGroup = row.getInt("syncgroup");
        int id = row.getInt("id");

        if (syncGroup + 1> sync.syncedSets.size()) {
          while (syncGroup + 1 > sync.syncedSets.size()) {
            sync.syncedSets.add(new LinkedList<>());
          }
        }

        sync.syncedSets.get(syncGroup).add(id);
        if (sync.unsynced.contains(id)) sync.unsynced.remove(sync.unsynced.indexOf(id));
      }
    }

    for (int i = 0; i < nCubes; i++) {
      if (cubes[i].record.moves.size() == 0) cubes[i].record.isRecording = true;
      cubes[i].record.setLed();
    }

    ui.addMsg("Recording Loaded!");
  }
  catch (Exception e) {
    ui.addMsg("Loading Failed.");
    return;
  }
}
