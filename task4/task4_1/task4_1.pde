
import peasy.*;

PeasyCam cam;
PImage texture1, texture2;

// Shape visibility toggles
boolean showBox = true;
boolean showSphere = true;
boolean showCustom = true;

// Animation
boolean autoRotate = true;
float rotationAngle = 0;

// Lighting
boolean advancedLighting = true;
float lightY = 0;

void setup() {
  size(1000, 700, P3D);
  
  // Initialize PeasyCam for orbit control
  cam = new PeasyCam(this, 500);
  cam.setMinimumDistance(200);
  cam.setMaximumDistance(1000);
  
  // Create procedural textures
  texture1 = createCheckerTexture(256, color(100, 150, 255), color(50, 100, 200));
  texture2 = createGradientTexture(256, color(255, 100, 100), color(100, 255, 100));
  
  textureMode(NORMAL);
}

void draw() {
  background(30, 30, 50);
  
  // Setup lighting
  setupLighting();
  
  // Update rotation
  if (autoRotate) {
    rotationAngle += 0.01;
  }
  
  // Draw coordinate axes for reference
  drawAxes();
  
  // Draw Box with texture
  if (showBox) {
    pushMatrix();
    translate(-150, 0, 0);
    rotateX(rotationAngle);
    rotateY(rotationAngle * 0.7);
    
    // Material properties
    ambient(100, 100, 255);
    specular(255, 255, 255);
    shininess(50);
    
    // Apply texture
    noStroke();
    beginShape(QUADS);
    texture(texture1);
    
    // Front face
    vertex(-50, -50, 50, 0, 0);
    vertex(50, -50, 50, 1, 0);
    vertex(50, 50, 50, 1, 1);
    vertex(-50, 50, 50, 0, 1);
    
    // Back face
    vertex(50, -50, -50, 0, 0);
    vertex(-50, -50, -50, 1, 0);
    vertex(-50, 50, -50, 1, 1);
    vertex(50, 50, -50, 0, 1);
    
    // Top face
    vertex(-50, -50, -50, 0, 0);
    vertex(50, -50, -50, 1, 0);
    vertex(50, -50, 50, 1, 1);
    vertex(-50, -50, 50, 0, 1);
    
    // Bottom face
    vertex(-50, 50, 50, 0, 0);
    vertex(50, 50, 50, 1, 0);
    vertex(50, 50, -50, 1, 1);
    vertex(-50, 50, -50, 0, 1);
    
    // Right face
    vertex(50, -50, 50, 0, 0);
    vertex(50, -50, -50, 1, 0);
    vertex(50, 50, -50, 1, 1);
    vertex(50, 50, 50, 0, 1);
    
    // Left face
    vertex(-50, -50, -50, 0, 0);
    vertex(-50, -50, 50, 1, 0);
    vertex(-50, 50, 50, 1, 1);
    vertex(-50, 50, -50, 0, 1);
    
    endShape();
    popMatrix();
  }
  
  // Draw Sphere
  if (showSphere) {
    pushMatrix();
    translate(150, 0, 0);
    rotateY(rotationAngle);
    rotateZ(rotationAngle * 0.5);
    
    // Material properties for metallic look
    ambient(255, 200, 100);
    specular(255, 255, 255);
    shininess(100);
    emissive(20, 10, 0);
    
    noStroke();
    fill(255, 180, 50);
    sphereDetail(30);
    sphere(60);
    
    // Reset emissive
    emissive(0, 0, 0);
    popMatrix();
  }
  
  // Draw Custom Shape (Pyramid using TRIANGLE_FAN and TRIANGLES)
  if (showCustom) {
    pushMatrix();
    translate(0, 0, 150);
    rotateX(rotationAngle * 0.8);
    rotateY(rotationAngle * 1.2);
    
    // Material properties
    ambient(100, 255, 100);
    specular(200, 255, 200);
    shininess(30);
    
    drawPyramid(80);
    popMatrix();
    
    // Draw a second custom shape - Star using TRIANGLE_STRIP
    pushMatrix();
    translate(0, 0, -150);
    rotateZ(rotationAngle);
    rotateX(rotationAngle * 0.6);
    
    ambient(255, 100, 255);
    specular(255, 200, 255);
    shininess(60);
    
    drawStar3D(50, 25, 20);
    popMatrix();
  }
  
  // Draw visual interaction indicator
  drawInteractionIndicator();
  
  // Draw HUD (heads-up display)
  cam.beginHUD();
  drawHUD();
  cam.endHUD();
}

void setupLighting() {
  if (advancedLighting) {
    // Ambient light for base illumination
    ambientLight(60, 60, 80);
    
    // Main point light (moving with lightY)
    pointLight(255, 255, 255, 200, lightY - 200, 200);
    
    // Colored accent lights
    pointLight(100, 100, 255, -300, 100, -100);  // Blue light
    pointLight(255, 100, 100, 300, 100, -100);   // Red light
    
    // Directional light for shadows
    directionalLight(128, 128, 128, 0, 1, -1);
  } else {
    // Simple lighting
    lights();
  }
}

void drawAxes() {
  strokeWeight(2);
  
  // X axis - Red
  stroke(255, 0, 0);
  line(0, 0, 0, 100, 0, 0);
  
  // Y axis - Green
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);
  
  // Z axis - Blue
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
  
  strokeWeight(1);
}

void drawPyramid(float size) {
  float h = size * 1.2;  // Height
  float s = size;        // Base size
  
  noStroke();
  
  // Base using QUADS
  fill(100, 200, 100);
  beginShape(QUADS);
  vertex(-s/2, h/2, -s/2);
  vertex(s/2, h/2, -s/2);
  vertex(s/2, h/2, s/2);
  vertex(-s/2, h/2, s/2);
  endShape();
  
  // Sides using TRIANGLES
  fill(150, 255, 150);
  beginShape(TRIANGLES);
  
  // Front face
  vertex(0, -h/2, 0);
  vertex(-s/2, h/2, s/2);
  vertex(s/2, h/2, s/2);
  
  // Right face
  vertex(0, -h/2, 0);
  vertex(s/2, h/2, s/2);
  vertex(s/2, h/2, -s/2);
  
  // Back face
  vertex(0, -h/2, 0);
  vertex(s/2, h/2, -s/2);
  vertex(-s/2, h/2, -s/2);
  
  // Left face
  vertex(0, -h/2, 0);
  vertex(-s/2, h/2, -s/2);
  vertex(-s/2, h/2, s/2);
  
  endShape();
}

void drawStar3D(float outerRadius, float innerRadius, float depth) {
  int points = 5;
  float angle = TWO_PI / points;
  float halfAngle = angle / 2.0;
  
  noStroke();
  fill(255, 150, 255);
  
  // Front face using TRIANGLE_FAN
  beginShape(TRIANGLE_FAN);
  vertex(0, 0, depth/2);  // Center
  for (int i = 0; i <= points * 2; i++) {
    float r = (i % 2 == 0) ? outerRadius : innerRadius;
    float a = i * halfAngle - HALF_PI;
    vertex(cos(a) * r, sin(a) * r, depth/2);
  }
  endShape();
  
  // Back face
  fill(200, 100, 200);
  beginShape(TRIANGLE_FAN);
  vertex(0, 0, -depth/2);
  for (int i = 0; i <= points * 2; i++) {
    float r = (i % 2 == 0) ? outerRadius : innerRadius;
    float a = i * halfAngle - HALF_PI;
    vertex(cos(a) * r, sin(a) * r, -depth/2);
  }
  endShape();
  
  // Sides using QUAD_STRIP
  fill(230, 130, 230);
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= points * 2; i++) {
    float r = (i % 2 == 0) ? outerRadius : innerRadius;
    float a = i * halfAngle - HALF_PI;
    vertex(cos(a) * r, sin(a) * r, depth/2);
    vertex(cos(a) * r, sin(a) * r, -depth/2);
  }
  endShape();
}

void drawInteractionIndicator() {
  // Draw a small sphere at light position
  pushMatrix();
  translate(200, lightY - 200, 200);
  emissive(255, 255, 200);
  fill(255, 255, 200);
  noStroke();
  sphere(10);
  emissive(0, 0, 0);
  popMatrix();
}

void drawHUD() {
  fill(255);
  textSize(14);
  textAlign(LEFT);
  
  String[] instructions = {
    "Controls:",
    "Mouse drag: Orbit camera",
    "Scroll: Zoom",
    "'1': Toggle Box (now " + (showBox ? "ON" : "OFF") + ")",
    "'2': Toggle Sphere (now " + (showSphere ? "ON" : "OFF") + ")",
    "'3': Toggle Custom shapes (now " + (showCustom ? "ON" : "OFF") + ")",
    "'A': Toggle auto-rotation (now " + (autoRotate ? "ON" : "OFF") + ")",
    "'L': Toggle lighting (now " + (advancedLighting ? "Advanced" : "Simple") + ")",
    "UP/DOWN: Move light",
    "'R': Reset camera"
  };
  
  for (int i = 0; i < instructions.length; i++) {
    text(instructions[i], 20, 30 + i * 20);
  }
  
  // Frame rate
  textAlign(RIGHT);
  text("FPS: " + nf(frameRate, 0, 1), width - 20, 30);
}

// Create a checker pattern texture
PImage createCheckerTexture(int size, color c1, color c2) {
  PImage img = createImage(size, size, RGB);
  img.loadPixels();
  int tileSize = size / 8;
  
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      boolean isWhite = ((x / tileSize) + (y / tileSize)) % 2 == 0;
      img.pixels[y * size + x] = isWhite ? c1 : c2;
    }
  }
  img.updatePixels();
  return img;
}

// Create a gradient texture
PImage createGradientTexture(int size, color c1, color c2) {
  PImage img = createImage(size, size, RGB);
  img.loadPixels();
  
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      float t = (float)x / size;
      img.pixels[y * size + x] = lerpColor(c1, c2, t);
    }
  }
  img.updatePixels();
  return img;
}

void keyPressed() {
  switch(key) {
    case '1':
      showBox = !showBox;
      break;
    case '2':
      showSphere = !showSphere;
      break;
    case '3':
      showCustom = !showCustom;
      break;
    case 'a':
    case 'A':
      autoRotate = !autoRotate;
      break;
    case 'l':
    case 'L':
      advancedLighting = !advancedLighting;
      break;
    case 'r':
    case 'R':
      cam.reset();
      break;
  }
  
  if (keyCode == UP) {
    lightY -= 20;
  }
  if (keyCode == DOWN) {
    lightY += 20;
  }
}
