class SyncSystem {
  LinkedList<int[]> tapped;
  LinkedList<Integer> synced;
  
  SyncSystem() {
    tapped = new LinkedList<>();
    synced = new LinkedList<>();
  }
  
  void tapAdd(int id) {
    tapped.add(new int[]{id, millis()});
  }
  
  void syncAdd(int id) {

    
    if (!synced.contains(id)) {
      cubes[id].led(50, 0, 0, 255);
      cubes[id].midi(20, 40, 255);
      synced.add(id);
      cubes[id].record.setLed();
    }
  }
  
  void syncRemove(int id) {
    
  }
  
  void startReady(int id) {
    if (synced.contains(id)) {
      for (int i = 0; i < synced.size(); i++) {
        cubes[i].record.startReady();
      }
    } else {
      cubes[id].record.startReady();
    }
  }
  
  void checkReady(int id) {
    if (synced.contains(id)) {
      boolean ready = true;
      for (int i = 0; i < synced.size(); i++) {
        ready = ready && cubes[i].record.status == Status.READYING && cubes[i].ready;
      }
      
      if (ready) {
        for (int i = 0; i < synced.size(); i++) {
          cubes[i].record.startPlay();
        }
      }
    } else {
      if (cubes[id].ready) {
        cubes[id].record.startPlay();
      }
    }
  }
  
  void update() {
    if (tapped.size() > 1) {
      for (int i = 0; i < tapped.size(); i++) {
        syncAdd(tapped.get(i)[0]);
      }
      
      tapped = new LinkedList<>();
    }
    
    if (tapped.size() > 0) {
      if (millis() - tapped.get(0)[1] > 1000) {
        tapped.removeFirst();
      }
    }
  }
}
