class UI {
  int offsetX = 230;
  int offsetY = 45;
  int mainBoxWidth = 200;
  int subBoxHeight = 50;
  int padding = 10;
  
  int textPadding = 10;
  int textBoxHeight = 30;
  String msg = "Press 'S' to Save or 'L' to Load";
  int msgUpdate = 0;
  
  UI() {
  }
  
  void drawBox(int baseline, int id) {
    int colorHeight = 10;
    int boxWidth = mainBoxWidth - (2 * padding);
    push();
    strokeWeight(2);
    rect(width - offsetX + padding, baseline, boxWidth, subBoxHeight);
    fill(0);
    textSize(subBoxHeight * .75);
    text("toio " + id, width - offsetX + padding * 2, baseline + (subBoxHeight  * 3 / 4));
    pop();
    
    if (cubes[id].record.size() == 0) return;
    push();
    stroke(0, 0);
    float colorWidth = boxWidth / ((float) cubes[id].record.size());
    for (int i = 0; i < cubes[id].record.size(); i++) {
      fill(cubes[id].record.getVelColor(i));
      rect(width - offsetX + padding + (i * colorWidth), baseline, colorWidth, colorHeight);
    }
    fill(200, 150);
    rect(width - offsetX + padding, baseline, colorWidth * cubes[id].record.currMove, colorHeight);

    fill(255);
    float xBase = width - offsetX + padding + (colorWidth * cubes[id].record.currMove);
    triangle(xBase, baseline, xBase + 3, baseline + colorHeight, xBase - 3, baseline + colorHeight);
    pop();
    
    push();
    fill(0, 0, 0, 0);
    strokeWeight(2);
    rect(width - offsetX + padding, baseline, boxWidth, subBoxHeight);
    pop();
  }
  
  void drawBoxes() {
    int baselineY = offsetY;
    push();
    for (int i = 0; i < sync.syncedSets.size(); i++) {
      int numBoxes = sync.syncedSets.get(i).size();
      if (numBoxes == 0) continue;
      rect(width - offsetX, baselineY, mainBoxWidth, padding + (subBoxHeight + padding) * numBoxes);
      
      for (int j = 0; j < numBoxes; j++) {
        int id = sync.syncedSets.get(i).get(j);
        //if (!cubes[id].isConnected) return;
        baselineY += padding;
        drawBox(baselineY, sync.syncedSets.get(i).get(j));
        baselineY += subBoxHeight;
      }
      baselineY += 2 * padding;
    }
    
    for (int i = 0; i < sync.unsynced.size(); i++) {
      baselineY += padding;
      drawBox(baselineY, sync.unsynced.get(i));
      baselineY += subBoxHeight;
    }
    pop();
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
