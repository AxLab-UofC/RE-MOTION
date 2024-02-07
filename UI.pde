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
    int boxWidth = mainBoxWidth - (2 * padding);
    push();
    rect(width - offsetX + padding, baseline, boxWidth, subBoxHeight);
    fill(0);
    textSize(subBoxHeight * .75);
    text("toio " + id, width - offsetX + padding * 2, baseline + (subBoxHeight  * 3 / 4));
    pop();
  }
  
  void drawBoxes() {
    int baselineY = offsetY;
    push();
    for (int i = 0; i < sync.syncedSets.size(); i++) {
      int numBoxes = sync.syncedSets.get(i).size();
      rect(width - offsetX, baselineY, mainBoxWidth, padding + (subBoxHeight + padding) * numBoxes);
      
      for (int j = 0; j < numBoxes; j++) {
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
