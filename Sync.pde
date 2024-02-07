class SyncSystem {
  LinkedList<int[]> tapped;
  LinkedList<Integer> unsynced;
  LinkedList<LinkedList<Integer>> syncedSets;
  int numSets;
  
  SyncSystem() {
    tapped = new LinkedList<>();
    unsynced = new LinkedList<>();
    syncedSets = new LinkedList<>();
    
    for (int i = 0; i < nCubes; i++) {
      unsynced.add(i);
    }
  }
  
  void tapAdd(int id) {
    tapped.add(new int[]{id, millis()});
  }
  
  void syncAdd(int id) {
    if (unsynced.contains(id)) unsynced.remove(unsynced.indexOf(id));
    cubes[id].led(50, 0, 0, 255);
    cubes[id].midi(20, 40, 255);
    cubes[id].record.setLed();
  }
  
  void syncAdd(LinkedList<Integer> set) {
    for (int i = 0; i < set.size(); i++) {
      int id = set.get(i);
      if (unsynced.contains(id)) unsynced.remove(unsynced.indexOf(id));
      cubes[id].led(50, 0, 0, 255);
      cubes[id].midi(20, 40, 255);
      cubes[id].record.setLed();
    }
  }
  
  void updateSyncSet(LinkedList<Integer> tappedSet) {
    LinkedList<Integer> tappedSyncSets = new LinkedList<>();
    boolean allUnsynced = true;
    int min = syncedSets.size();
    int max = 0;
    
    for (int i = 0; i < tappedSet.size(); i++) {
      int index = indexOf(tappedSet.get(i));
      allUnsynced = allUnsynced && (index == -1);
      if (index > max) max = index;
      if (index < min) min = index;
      if (!tappedSyncSets.contains(index)) tappedSyncSets.add(index);
    }
    
    //print(allUnsynced);
    if (allUnsynced) {
      //println("All Unsynced!");
      
      syncedSets.add(tappedSet);
      syncAdd(tappedSet);
    } else if (tappedSyncSets.size() == 2 && tappedSyncSets.contains(-1)){
      for (int i = 0; i < tappedSet.size(); i++) {
        if (indexOf(tappedSet.get(i)) == -1) {
          syncedSets.get(max).add(tappedSet.get(i));
        }
        syncAdd(syncedSets.get(max));
      }
      println("max:", + max);
    } else {
      println(tappedSyncSets.size());
    }
  }
  
  boolean contains(int id) {
    boolean doesContain = false;
    for (int i = 0; i < syncedSets.size(); i++) {
      doesContain = doesContain || syncedSets.get(i).contains(id);
    }
    return doesContain;
  }
  
  int indexOf(int id) {
    for (int i = 0; i < syncedSets.size(); i++) {
      if (syncedSets.get(i).contains(id)) return i;
    }
    
    return -1;
  }
  
  void startReady(int id) {
    if (unsynced.contains(id)) {
      cubes[id].record.startReady();
    } else {
    //  for (int i = 0; i < synced.size(); i++) {
    //    cubes[i].record.startReady();
    //  }
    }
  }
  
  void checkReady(int id) {
    if (unsynced.contains(id)) {
      if (cubes[id].ready) {
        cubes[id].record.startPlay();
      }
    } else  {
    //  boolean ready = true;
    //  for (int i = 0; i < synced.size(); i++) {
    //    ready = ready && cubes[i].record.status == Status.READYING && cubes[i].ready;
    //  }
      
    //  if (ready) {
    //    for (int i = 0; i < synced.size(); i++) {
    //      cubes[i].record.startPlay();
    //    }
    //  }
    }
  }
  
  void update() {
    LinkedList<Integer> tappedSet = new LinkedList();
    
    if (tapped.size() > 1) {
      for (int i = 0; i < tapped.size(); i++) {
        if (!tappedSet.contains(tapped.get(i)[0])) tappedSet.add(tapped.get(i)[0]);
      }
      if (tappedSet.size() > 1) updateSyncSet(tappedSet);
      tapped = new LinkedList<>();
    }
    
    if (tapped.size() > 0) {
      if (millis() - tapped.get(0)[1] > 1000) {
        tapped.removeFirst();
      }
    }
  }
}
