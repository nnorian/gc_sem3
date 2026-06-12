

import peasy.*;

PeasyCam cam;
PShape housePlant;
PImage texColor;

// Model transformation variables
float modelX = 0;
float modelY = 0;
float modelZ = 0;
float modelScale = 1.0;
float rotationAngle = 0;
boolean autoRotate = true;

// Model info
float modelWidth, modelHeight, modelDepth;
boolean modelLoaded = false;

void setup() {
  size(1200, 800, P3D);
  
  // Initialize PeasyCam with larger initial distance
  cam = new PeasyCam(this, 500);
  cam.setMinimumDistance(10);
  cam.setMaximumDistance(5000);
  
  println("Loading model...");
  
  // Load the OBJ model
  housePlant = loadShape("eb_house_plant_01.obj");
  
  if (housePlant != null) {
    modelLoaded = true;
    println("Model loaded successfully!");
    
    // Get model dimensions
    modelWidth = housePlant.getWidth();
    modelHeight = housePlant.getHeight();
    modelDepth = housePlant.getDepth();
    
    println("Model dimensions:");
    println("  Width: " + modelWidth);
    println("  Height: " + modelHeight);
    println("  Depth: " + modelDepth);
    
    // Calculate scale to fit model to reasonable size (target ~200 units)
    float maxDim = max(modelWidth, max(modelHeight, modelDepth));
    if (maxDim > 0) {
      modelScale = 200.0 / maxDim;
      println("Auto-scale factor: " + modelScale);
    }
    
    // Try to load and apply texture
    texColor = loadImage("eb_house_plant_01_c.tga");
    if (texColor != null) {
      println("Texture loaded: " + texColor.width + "x" + texColor.height);
      housePlant.setTexture(texColor);
    } else {
      println("Could not load texture - model will use default colors");
    }
  } else {
    println("ERROR: Could not load model!");
    println("Make sure eb_house_plant_01.obj is in the data folder");
  }
}

void draw() {
  background(50, 55, 60);
  
  // Simple lighting
  lights();
  ambientLight(100, 100, 100);
  directionalLight(200, 200, 200, 0, 1, -1);
  pointLight(150, 150, 150, 200, -200, 200);
  
  // Draw reference axes to help orientation
  drawAxes();
  
  // Draw ground grid
  drawGroundPlane();
  
  // Draw the model
  pushMatrix();
  
  translate(modelX, modelY, modelZ);
  scale(modelScale);
  
  // Auto-rotation
  if (autoRotate) {
    rotationAngle += 0.01;
  }
  rotateY(rotationAngle);
  
  if (modelLoaded && housePlant != null) {
    // Try different orientations - uncomment one if model appears wrong
    // rotateX(PI);        // Flip upside down
    // rotateX(-HALF_PI);  // Rotate 90 degrees
    
    shape(housePlant);
  } else {
    // Draw placeholder
    drawPlaceholder();
  }
  
  popMatrix();
  
  // Draw HUD
  cam.beginHUD();
  drawHUD();
  cam.endHUD();
}

void drawAxes() {
  // X axis - Red
  stroke(255, 0, 0);
  strokeWeight(2);
  line(0, 0, 0, 100, 0, 0);
  
  // Y axis - Green
  stroke(0, 255, 0);
  line(0, 0, 0, 0, -100, 0);  // Negative because Processing Y is down
  
  // Z axis - Blue
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
  
  strokeWeight(1);
}

void drawGroundPlane() {
  pushMatrix();
  translate(0, 100, 0);
  rotateX(HALF_PI);
  
  stroke(80, 90, 100);
  strokeWeight(1);
  noFill();
  
  int gridSize = 400;
  int spacing = 50;
  
  for (int i = -gridSize; i <= gridSize; i += spacing) {
    line(i, -gridSize, i, gridSize);
    line(-gridSize, i, gridSize, i);
  }
  
  popMatrix();
}

void drawPlaceholder() {
  // Simple placeholder plant
  fill(139, 90, 43);
  noStroke();
  
  // Pot
  pushMatrix();
  translate(0, 30, 0);
  box(60, 40, 60);
  popMatrix();
  
  // Plant
  fill(34, 139, 34);
  pushMatrix();
  translate(0, -20, 0);
  sphere(40);
  popMatrix();
}

void drawHUD() {
  pushStyle();
  
  fill(0, 0, 0, 180);
  noStroke();
  rect(10, 10, 320, 240, 10);
  
  fill(255);
  textSize(14);
  textAlign(LEFT, TOP);
  
  int y = 20;
  int lh = 18;
  
  text("House Plant 3D Viewer", 20, y); y += lh + 5;
  
  if (modelLoaded) {
    fill(100, 255, 100);
    text("Model: LOADED", 20, y); y += lh;
    fill(255);
    text("Size: " + nf(modelWidth, 0, 1) + " x " + nf(modelHeight, 0, 1) + " x " + nf(modelDepth, 0, 1), 20, y); y += lh;
  } else {
    fill(255, 100, 100);
    text("Model: NOT LOADED", 20, y); y += lh;
    fill(255);
  }
  
  y += 5;
  text("Scale: " + nf(modelScale, 0, 3), 20, y); y += lh;
  text("Auto-rotate: " + (autoRotate ? "ON" : "OFF"), 20, y); y += lh + 5;
  
  text("Controls:", 20, y); y += lh;
  text("  Mouse drag - Rotate view", 20, y); y += lh;
  text("  Scroll - Zoom", 20, y); y += lh;
  text("  Arrows - Move model", 20, y); y += lh;
  text("  +/- - Scale model", 20, y); y += lh;
  text("  R - Toggle rotation", 20, y); y += lh;
  text("  0 - Reset", 20, y);
  
  popStyle();
}

void keyPressed() {
  float moveSpeed = 20;
  
  if (keyCode == UP) modelZ -= moveSpeed;
  if (keyCode == DOWN) modelZ += moveSpeed;
  if (keyCode == LEFT) modelX -= moveSpeed;
  if (keyCode == RIGHT) modelX += moveSpeed;
  
  if (key == '+' || key == '=') modelScale *= 1.2;
  if (key == '-' || key == '_') modelScale *= 0.8;
  
  if (key == 'r' || key == 'R') autoRotate = !autoRotate;
  
  if (key == '0') {
    modelX = 0;
    modelY = 0;
    modelZ = 0;
    rotationAngle = 0;
    // Recalculate auto-scale
    if (modelLoaded) {
      float maxDim = max(modelWidth, max(modelHeight, modelDepth));
      if (maxDim > 0) modelScale = 200.0 / maxDim;
    }
  }
  
  // Manual Y movement
  if (key == 'w' || key == 'W') modelY -= moveSpeed;
  if (key == 's' || key == 'S') modelY += moveSpeed;
}
