class Cube {
  int id;
  boolean isActive;
  boolean isConnected;
  long lastUpdate;
  long lastMsg;
    
  // position
  int x;
  int y;
  int theta;
  boolean ready;
  
  //velocity targeting
  int targetx;
  int targety;
  int targetTime;
  
  // battery
  int battery;
  
  //button
  boolean buttonDown;
  int lastPressed;
  
  // motion
  boolean isHorizontal;
  boolean collision;
  boolean doubleTap;
  int posture;
  int shake;
  
  // magnetic
  int magState;
  int magStrength;
  int magx;
  int magy;
  int magz;
  
  // posture (euler)
  int roll;
  int pitch;
  int yaw;
  
  // posture (quaternions)
  int qx;
  int qy;
  int qw;
  int qz;
  
  recordManager record;
  
  Cube(int i) {
    id = i;
    lastUpdate = System.currentTimeMillis();
    isActive = false;
    ready = true;
    buttonDown = false;
    
    record = new recordManager(id);
  }
  
  void checkActive(long now) {
    if (lastUpdate < now - 1500 && isActive) {
      isActive = false;
    }
    
    if (lastMsg < now - 1500 && isConnected) {
      isConnected = false;
    }
  }
  
    // Updates position values
  void onPositionUpdate(int upx, int upy, int uptheta) {    
    x = upx;
    y = upy;
    theta = uptheta; 
    
    record.addMove(x, y, theta);
    
    lastUpdate = System.currentTimeMillis();
    isActive = true;
    lastMsg = System.currentTimeMillis();
    isConnected = true;
  }
  
  // Updates battery values
  void onBatteryUpdate(int upbatt) {
    battery = upbatt;
  }
  
  // Updates motion values
  void onMotionUpdate(int flatness, int hit, int double_tap, int face_up, int shake_level) {
     isHorizontal = (flatness == 1);
     collision = (hit == 1);
     doubleTap = (double_tap == 1);
     posture = face_up;
     shake = shake_level;
     
     //insert code here
     
     if (collision) {
       onCollision();
     }
     
     if (doubleTap) {
       onDoubleTap();
     }
     
     lastMsg = System.currentTimeMillis();
    isConnected = true;
  }
  
  // Updates magnetic values 
  void onMagneticUpdate(int upState, int upStrength, int upx, int upy, int upz) {
    magState = upState;
    magStrength = upStrength;
    magx = upx;
    magy = upy;
    magz = upz;
    
    //insert code here
     lastMsg = System.currentTimeMillis();
    isConnected = true;
  }
  
  //Updates posture values (euler)
  void onPostureUpdate(int uproll, int uppitch, int upyaw) {
    roll = uproll;
    pitch = uppitch;
    yaw = upyaw;
    
    //insert code here
     lastMsg = System.currentTimeMillis();
    isConnected = true;
  }
  
  //Updates posture values (quaternion)
  void onPostureUpdate(int upw, int upx, int upy, int upz) {
    qw = upw;
    qx = upx;
    qy = upy;
    qz = upz;
    
    //insert code here
     lastMsg = System.currentTimeMillis();
    isConnected = true;
  }
  
  
  //Execute this code on button press
  void onButtonDown() {
    //println("Button Pressed!");
    buttonDown = true;
    lastPressed = millis();
    
    //insert code here
     lastMsg = System.currentTimeMillis();
    isConnected = true;
  }
  
  //Execute this code on button release
  void onButtonUp() {
    //println("Button Released");
    buttonDown = false;
    
    if (millis() - lastPressed < 1000) {
      if (record.status == Status.PAUSED) {
        record.unpause();
      } else {
        sync.pause(id);
      }
    }
    
    //insert code here
     lastMsg = System.currentTimeMillis();
    isConnected = true;
  }
  
  //Execute this code on collision
  void onCollision() {
    //println("Collision Detected!");
    
    //insert code here
     lastMsg = System.currentTimeMillis();
    isConnected = true;
  }
  
  //Execute this code on double tap
  void onDoubleTap() {
    //println("Double Tap Detected!");
    sync.tapAdd(id);
    
    //insert code here
     lastMsg = System.currentTimeMillis();
    isConnected = true;
  }
  
  //Execute this code on motor response
  void onMotorResponse(int control, int response) {
    //println("Motor Target Response!");
    if (response == 0) {
      ready = true;
    }
    
    //insert code here
     lastMsg = System.currentTimeMillis();
    isConnected = true;
  }
  
  void motor(int leftSpeed,int rightSpeed) {
    motorBasic(id, leftSpeed, rightSpeed);
  }
  
  void motor(int leftSpeed, int rightSpeed, int duration) {
    motorDuration(id, leftSpeed, rightSpeed, duration);
  }
  
  void target(int mode, int x, int y, int theta) {
    motorTarget(id, mode, x, y, theta);
    ready = false;
  }
  
  void target(int control, int timeout, int mode, int maxspeed, int speedchange,  int x, int y, int theta) {
    motorTarget(id, control, timeout, mode, maxspeed, speedchange, x, y, theta);
    ready = false;
  }
  
  boolean velocityTarget(int x, int y) {
    float elapsedTime = millis() - targetTime;
    float vx = (targetx - x) / elapsedTime;
    float vy = (targety - y) / elapsedTime;
    
    boolean val = motorTargetVelocity(id, x, y, vx, vy);
    
    targetx = x;
    targety = y;
    targetTime = millis();
    return val;
  }
  
  void accelerate(int speed, int a, int rotateVelocity, int rotateDir, int dir, int priority, int duration) {
    motorAcceleration(id, speed, a, rotateVelocity, rotateDir, dir, priority, duration);
  }
  
  void multiTarget(int mode, int[][] targets) {
    motorMultiTarget(id, mode, targets);
  }
  
  void multiTarget(int control, int timeout, int mode, int maxspeed, int speedchange,  int[][] targets) {
    motorMultiTarget(id, control, timeout, mode, maxspeed, speedchange, targets);
  }
  
  void led(int duration, int red, int green, int blue) {
    lightLed(id, duration, red, green, blue);
  }
  
  void led(int repetitions, int[][] lights) {
    lightLed(id, repetitions, lights);
  }
  
  void sound(int soundeffect, int volume) {
    soundEffect(id, soundeffect, volume);
  }
  
  void midi(int duration, int noteID, int volume) {
    soundMidi(id, duration, noteID, volume);
  }
  
  void midi(int repetitions, int[][] notes)  {
    soundMidi(id, repetitions, notes);
  }
  
  float distance(Cube o) {
    return distance(o.x, o.y);
  }

  float distance(float ox, float oy) {
    return sqrt ((x-ox)*(x-ox) + (y-oy)*(y-oy));
  }
}
