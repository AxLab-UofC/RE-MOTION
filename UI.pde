class UI {
  int offsetX = 230;
  int offsetY = 45;
  int mainBoxWidth = 200;
  int subBoxHeight = 50;
  int padding = 10;
  int boxWidth = mainBoxWidth - (2 * padding);
  float buttonSize = subBoxHeight - (padding * 2.5);
  int colorHeight = 10;
  int textPadding = 10;
  int textBoxHeight = 30;
  String msg = "Press 'S' to Save or 'L' to Load";
  int msgUpdate = 0;
  
  int[][] buttons;
  
  UI() {
  }
  
  void drawBox(int baseline, int id) {
    push();
    strokeWeight(2);
    rect(width - offsetX + padding, baseline, boxWidth, subBoxHeight + (1.5 * padding));

    fill(0);
    textSize(subBoxHeight * .75);
    text("toio " + id, width - offsetX + padding * 2, baseline + (subBoxHeight  * 3 / 4));
    textSize(subBoxHeight * .3);
    if (cubes[id].record.isRecording) fill(255, 50, 50);
    else fill(50, 150, 50);
    text(cubes[id].record.getStatus(), width - offsetX + padding * 2, baseline + (subBoxHeight * 1.1));
    pop();
    
    if (cubes[id].record.size() == 0) return;
    push();
    stroke(0, 0);
    float colorWidth = boxWidth / ((float) cubes[id].record.size());
    for (int i = 0; i < cubes[id].record.size(); i++) {
      fill(cubes[id].record.getVelColor(i));
      rect(width - offsetX + padding + (i * colorWidth), baseline, colorWidth, colorHeight);
    }

    fill(255);
    float xBase = width - offsetX + padding + (colorWidth * cubes[id].record.currMove);
    triangle(xBase, baseline, xBase + 3, baseline + colorHeight, xBase - 3, baseline + colorHeight);
    pop();
    
    push();
    fill(0, 0, 0, 0);
    strokeWeight(2);
    rect(width - offsetX + padding, baseline, boxWidth, subBoxHeight + (1.5 * padding));
    pop();
  }
  
  void drawButton(int baseline, int id) {
    float xBase = width - offsetX + boxWidth - buttonSize;
    float yBase = baseline + (padding * 1.5);
    float buttonPadding = padding * .75;
    push();
    fill(200);
    square(xBase, yBase, buttonSize);
    stroke(255);
    strokeWeight(3);
    line(xBase + buttonPadding, yBase + buttonPadding, xBase + buttonSize - buttonPadding, yBase + buttonSize - buttonPadding);
    line(xBase + buttonPadding, yBase + buttonSize - buttonPadding, xBase + buttonSize - buttonPadding, yBase + buttonPadding);
    pop();
  }
  
  void drawBoxes() {
    int baselineY = offsetY;
    push();
    for (int i = 0; i < sync.syncedSets.size(); i++) {
      int numBoxes = sync.syncedSets.get(i).size();
      if (numBoxes == 0) continue;
      rect(width - offsetX, baselineY, mainBoxWidth, padding + ((subBoxHeight + (2.5 * padding)) * numBoxes));
      
      for (int j = 0; j < numBoxes; j++) {
        baselineY += padding;
        drawBox(baselineY, sync.syncedSets.get(i).get(j));
        drawButton(baselineY, sync.syncedSets.get(i).get(j));
        baselineY += subBoxHeight + (1.5 * padding);
      }
      baselineY += 2 * padding;
    }
    
    baselineY -= padding;
    
    for (int i = 0; i < sync.unsynced.size(); i++) {
      baselineY += padding;
      drawBox(baselineY, sync.unsynced.get(i));
      baselineY += subBoxHeight + (1.5 * padding);
    }
    pop();
  }
  
  void pressButton(int set, int id) {
    sync.syncRemove(id);
    
    if (sync.syncedSets.get(set).size() == 1) {
      sync.unsynced.add(sync.syncedSets.get(set).get(0));
      sync.syncedSets.get(set).remove(0);
    }
  }
  
  void checkButtons(int x, int y) {
    int baselineY = offsetY + 45;
    float xBase = width - offsetX + boxWidth - buttonSize;
    for (int i = 0; i < sync.syncedSets.size(); i++) {
      int numBoxes = sync.syncedSets.get(i).size();
      if (numBoxes == 0) continue;
      
      for (int j = 0; j < numBoxes; j++) {
        baselineY += padding;
        float yBase = baselineY + (padding * 1.5);
        if (x >= xBase && y >= yBase && x <= xBase + buttonSize && y <= yBase + buttonSize) {
          println(i, sync.syncedSets.get(i).get(j));
          pressButton(i, sync.syncedSets.get(i).get(j));
        } 
        baselineY += subBoxHeight + (1.5 * padding);
      }
      baselineY += 2 * padding;
    }
  }
  
  void drawmsg() {
    push();
    textSize(textBoxHeight * .75);
    fill(0);
    rect(45, 45 + (410 * scale), (textWidth(msg)) + (3 * textPadding), textBoxHeight + textPadding);
    fill(255);
    text(msg, 45 + textPadding, 45 + (410 * scale) + textPadding + (textBoxHeight / 2));
    fill(255);
    pop();
  }
  
  void draw() {
    drawBoxes();
    
    if (millis() - msgUpdate < 5000) {
      drawmsg();
    }
  }
  
  void addMsg(String newMsg) {
    msg = newMsg;
    msgUpdate = millis();
  }
  
}
