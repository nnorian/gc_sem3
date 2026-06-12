//Box, Ellipsoid, Tube, Extrusion, LatheStock
import shapes3d.*;
import shapes3d.utils.*;
import shapes3d.path.*;
import shapes3d.contour.*;
import peasy.*;

// PeasyCam for camera control
PeasyCam cam;

// Shapes3D V3 objects
Ellipsoid myEllipsoid;
Ellipsoid mySphere;
Tube myTube;
Tube myTube2;
Box myBox;

// Textures
PImage woodTexture;
PImage earthTexture;
PImage stoneTexture;
PImage metalTexture;
PImage glassTexture;

// Animation and control variables
float rotationAngle = 0;
boolean animateRotation = true;
boolean showTextures = true;
boolean[] shapeVisible = {true, true, true, true, true};

int selectedShape = 0;

void setup() {
  size(1200, 800, P3D);
  
  // Initialize PeasyCam
  cam = new PeasyCam(this, 500);
  cam.setMinimumDistance(200);
  cam.setMaximumDistance(1500);
  
  // Create procedural textures
  createTextures();
  
  // Create all shapes using Shapes3D V3 constructors
  createShapes();
  
  println("=== Shapes3D V3 Scene Controls ===");
  println("Mouse: Drag to rotate, Scroll to zoom");
  println("Double-click: Reset camera view");
  println("Keys 1-5: Toggle shape visibility");
  println("Key 'r': Toggle rotation animation");
  println("Key 't': Toggle textures on/off");
  println("Key 's': Select next shape");
  println("Arrow keys: Move selected shape");
  println("===================================");
}

void createTextures() {
  // Create wood texture
  woodTexture = createImage(256, 256, RGB);
  woodTexture.loadPixels();
  for (int y = 0; y < 256; y++) {
    for (int x = 0; x < 256; x++) {
      float noise1 = noise(x * 0.02, y * 0.1) * 50;
      float noise2 = noise(x * 0.05, y * 0.02) * 30;
      int r = constrain((int)(139 + noise1 - noise2), 100, 180);
      int g = constrain((int)(90 + noise1 * 0.5 - noise2), 50, 120);
      int b = constrain((int)(43 + noise1 * 0.3), 20, 70);
      woodTexture.pixels[y * 256 + x] = color(r, g, b);
    }
  }
  woodTexture.updatePixels();
  
  // Create earth texture
  earthTexture = createImage(256, 256, RGB);
  earthTexture.loadPixels();
  for (int y = 0; y < 256; y++) {
    for (int x = 0; x < 256; x++) {
      float noise1 = noise(x * 0.03, y * 0.03);
      float noise2 = noise(x * 0.06 + 100, y * 0.06 + 100);
      if (noise1 > 0.45) {
        int r = (int)(34 + noise2 * 80);
        int g = (int)(139 + noise2 * 50);
        int b = (int)(34 + noise2 * 30);
        earthTexture.pixels[y * 256 + x] = color(r, g, b);
      } else {
        int r = (int)(30 + noise2 * 30);
        int g = (int)(100 + noise2 * 50);
        int b = (int)(180 + noise2 * 50);
        earthTexture.pixels[y * 256 + x] = color(r, g, b);
      }
    }
  }
  earthTexture.updatePixels();
  
  // Create stone texture
  stoneTexture = createImage(256, 256, RGB);
  stoneTexture.loadPixels();
  for (int y = 0; y < 256; y++) {
    for (int x = 0; x < 256; x++) {
      float noise1 = noise(x * 0.04, y * 0.04) * 60;
      float noise2 = noise(x * 0.08, y * 0.08) * 30;
      int gray = constrain((int)(120 + noise1 - noise2), 80, 180);
      stoneTexture.pixels[y * 256 + x] = color(gray, (int)(gray * 0.95), (int)(gray * 0.9));
    }
  }
  stoneTexture.updatePixels();
  
  // Create metal texture
  metalTexture = createImage(256, 256, RGB);
  metalTexture.loadPixels();
  for (int y = 0; y < 256; y++) {
    for (int x = 0; x < 256; x++) {
      float pattern = (sin(x * 0.3) + sin(y * 0.3)) * 20;
      float noise1 = noise(x * 0.1, y * 0.1) * 30;
      int r = constrain((int)(180 + pattern + noise1), 140, 220);
      int g = constrain((int)(100 + pattern * 0.5), 60, 140);
      int b = constrain((int)(50 + pattern * 0.5), 30, 80);
      metalTexture.pixels[y * 256 + x] = color(r, g, b);
    }
  }
  metalTexture.updatePixels();
  
  // Create glass texture
  glassTexture = createImage(256, 256, RGB);
  glassTexture.loadPixels();
  for (int y = 0; y < 256; y++) {
    for (int x = 0; x < 256; x++) {
      float shine = sin(x * 0.05) * sin(y * 0.05) * 40;
      float noise1 = noise(x * 0.02, y * 0.02) * 20;
      int r = constrain((int)(150 + shine + noise1), 130, 200);
      int g = constrain((int)(200 + shine + noise1), 180, 240);
      int b = constrain((int)(230 + shine), 210, 255);
      glassTexture.pixels[y * 256 + x] = color(r, g, b);
    }
  }
  glassTexture.updatePixels();
}

void createShapes() {
  // Shapes3D V3: Constructors don't take PApplet (this) parameter!
  
  // Create Ellipsoid (sphere): Ellipsoid(radius, nbrSegs, nbrSlices)
  mySphere = new Ellipsoid(50, 32, 32);
  mySphere.fill(color(100, 149, 237));
  mySphere.stroke(color(70, 130, 180));
  mySphere.strokeWeight(0.5);
  mySphere.drawMode(S3D.SOLID | S3D.WIRE);
  mySphere.texture(earthTexture);
  mySphere.moveTo(-150, -50, 0);
  
  // Create Ellipsoid (stretched): Ellipsoid(radX, radY, radZ, nbrSegs, nbrSlices)
  myEllipsoid = new Ellipsoid(40, 70, 40, 24, 24);
  myEllipsoid.fill(color(150, 200, 230));
  myEllipsoid.stroke(color(100, 150, 200));
  myEllipsoid.strokeWeight(0.5);
  myEllipsoid.drawMode(S3D.SOLID | S3D.WIRE);
  myEllipsoid.texture(glassTexture);
  myEllipsoid.moveTo(150, -50, 0);
  
  // Create Tube - need to use Path for V3
  // Tube follows a path, let's create a linear path
  Path tubePath = new Linear(new PVector(0, -50, 0), new PVector(0, 50, 0), 10);
  myTube = new Tube(tubePath, new Oval(40, 40, 24));
  myTube.fill(color(150, 140, 130));
  myTube.stroke(color(100, 90, 80));
  myTube.strokeWeight(1);
  myTube.drawMode(S3D.SOLID | S3D.WIRE);
  myTube.texture(stoneTexture);
  myTube.moveTo(0, -50, 150);
  
  // Create second Tube with different shape
  Path tubePath2 = new Linear(new PVector(0, -40, 0), new PVector(0, 40, 0), 8);
  myTube2 = new Tube(tubePath2, new Oval(30, 30, 6));  // Hexagonal
  myTube2.fill(color(180, 50, 50));
  myTube2.stroke(color(120, 30, 30));
  myTube2.strokeWeight(1);
  myTube2.drawMode(S3D.SOLID | S3D.WIRE);
  myTube2.texture(metalTexture);
  myTube2.moveTo(-150, 100, 0);
  
  // Create Box
  myBox = new Box(80, 80, 80);
  myBox.fill(color(139, 90, 43));
  myBox.stroke(color(100, 60, 30));
  myBox.strokeWeight(1.5);
  myBox.drawMode(S3D.SOLID | S3D.WIRE);
  myBox.texture(woodTexture);
  myBox.moveTo(150, 100, 0);
}

void draw() {
  background(30, 30, 50);
  
  // Set up lighting
  ambientLight(60, 60, 80);
  pointLight(255, 255, 240, 300, -300, 300);
  pointLight(150, 150, 200, -300, 200, -200);
  directionalLight(100, 100, 120, 0, 1, -1);
  
  // Update rotation angle for animation
  if (animateRotation) {
    rotationAngle += 0.01;
  }
  
  // Draw floor grid
  drawFloorGrid();
  
  // Draw shapes
  drawShapes();
  
  // Draw HUD
  cam.beginHUD();
  drawHUD();
  cam.endHUD();
}

void drawFloorGrid() {
  pushMatrix();
  translate(0, 200, 0);
  stroke(80, 80, 100);
  strokeWeight(1);
  
  int gridSize = 500;
  int gridStep = 50;
  
  for (int x = -gridSize; x <= gridSize; x += gridStep) {
    line(x, 0, -gridSize, x, 0, gridSize);
  }
  for (int z = -gridSize; z <= gridSize; z += gridStep) {
    line(-gridSize, 0, z, gridSize, 0, z);
  }
  popMatrix();
}

void drawShapes() {
  // Draw Sphere
  if (shapeVisible[0]) {
    mySphere.rotateBy(0, 0.01, 0);
    if (showTextures) {
      mySphere.drawMode(S3D.TEXTURE);
    } else {
      mySphere.drawMode(S3D.SOLID | S3D.WIRE);
    }
    mySphere.draw(getGraphics());
  }
  
  // Draw Ellipsoid
  if (shapeVisible[1]) {
    myEllipsoid.rotateBy(0, -0.008, 0.005);
    if (showTextures) {
      myEllipsoid.drawMode(S3D.TEXTURE);
    } else {
      myEllipsoid.drawMode(S3D.SOLID | S3D.WIRE);
    }
    myEllipsoid.draw(getGraphics());
  }
  
  // Draw Tube
  if (shapeVisible[2]) {
    myTube.rotateBy(0.008, 0, 0);
    if (showTextures) {
      myTube.drawMode(S3D.TEXTURE);
    } else {
      myTube.drawMode(S3D.SOLID | S3D.WIRE);
    }
    myTube.draw(getGraphics());
  }
  
  // Draw Tube2
  if (shapeVisible[3]) {
    myTube2.rotateBy(0, 0.012, 0.004);
    if (showTextures) {
      myTube2.drawMode(S3D.TEXTURE);
    } else {
      myTube2.drawMode(S3D.SOLID | S3D.WIRE);
    }
    myTube2.draw(getGraphics());
  }
  
  // Draw Box
  if (shapeVisible[4]) {
    myBox.rotateBy(0.01, 0.005, 0);
    if (showTextures) {
      myBox.drawMode(S3D.TEXTURE);
    } else {
      myBox.drawMode(S3D.SOLID | S3D.WIRE);
    }
    myBox.draw(getGraphics());
  }
}

void drawHUD() {
  fill(0, 0, 0, 150);
  noStroke();
  rect(10, 10, 280, 180, 10);
  
  fill(255);
  textSize(18);
  textAlign(LEFT, TOP);
  text("Shapes3D V3 Demo", 20, 20);
  
  textSize(12);
  fill(200);
  text("Controls:", 20, 50);
  text("Mouse: Rotate/Zoom camera", 20, 70);
  text("Keys 1-5: Toggle shapes", 20, 90);
  text("R: Toggle rotation (" + (animateRotation ? "ON" : "OFF") + ")", 20, 110);
  text("T: Toggle textures (" + (showTextures ? "ON" : "OFF") + ")", 20, 130);
  text("S: Select shape (current: " + getShapeName(selectedShape) + ")", 20, 150);
  
  fill(0, 0, 0, 150);
  rect(width - 180, 10, 170, 140, 10);
  
  fill(255);
  textSize(14);
  text("Shapes:", width - 170, 20);
  
  textSize(12);
  String[] shapeNames = {"1: Sphere", "2: Ellipsoid", "3: Tube", "4: Hex Tube", "5: Box"};
  for (int i = 0; i < 5; i++) {
    if (i == selectedShape) {
      fill(255, 255, 0);
    } else if (shapeVisible[i]) {
      fill(100, 255, 100);
    } else {
      fill(255, 100, 100);
    }
    text(shapeNames[i] + (shapeVisible[i] ? " [ON]" : " [OFF]"), width - 170, 45 + i * 20);
  }
}

String getShapeName(int index) {
  String[] names = {"Sphere", "Ellipsoid", "Tube", "Hex Tube", "Box"};
  return names[index];
}

void keyPressed() {
  if (key >= '1' && key <= '5') {
    int index = key - '1';
    shapeVisible[index] = !shapeVisible[index];
  }
  
  if (key == 'r' || key == 'R') {
    animateRotation = !animateRotation;
  }
  
  if (key == 't' || key == 'T') {
    showTextures = !showTextures;
  }
  
  if (key == 's' || key == 'S') {
    selectedShape = (selectedShape + 1) % 5;
  }
  
  // Move selected shape
  float moveAmount = 20;
  Shape3D[] shapes = {mySphere, myEllipsoid, myTube, myTube2, myBox};
  
  if (keyCode == UP) {
    PVector pos = shapes[selectedShape].getPosVec();
    shapes[selectedShape].moveTo(pos.x, pos.y, pos.z - moveAmount);
  }
  if (keyCode == DOWN) {
    PVector pos = shapes[selectedShape].getPosVec();
    shapes[selectedShape].moveTo(pos.x, pos.y, pos.z + moveAmount);
  }
  if (keyCode == LEFT) {
    PVector pos = shapes[selectedShape].getPosVec();
    shapes[selectedShape].moveTo(pos.x - moveAmount, pos.y, pos.z);
  }
  if (keyCode == RIGHT) {
    PVector pos = shapes[selectedShape].getPosVec();
    shapes[selectedShape].moveTo(pos.x + moveAmount, pos.y, pos.z);
  }
}
