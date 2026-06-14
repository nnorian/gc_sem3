// Processing Sketch - Part I: Kite with Background and Decorative Elements
// =========================================================================
// IMPORTANT: You need to add your own background image named "background.jpg" 
// to the sketch folder (inside the "data" subfolder)!
// =========================================================================

PImage bgImage;
PImage kiteTexture;

float windAngle = 0;
float windSpeed = 0.02;
float kiteX, kiteY;
float stringLength = 200;

// Decoration particles
ArrayList<Particle> particles;

void setup() {
  size(800, 600, P2D);  // P2D renderer needed for texture()
  
  // Load background image - YOU MUST ADD THIS FILE!
  // Place an image named "background.jpg" in the "data" folder inside sketch folder
  bgImage = loadImage("background.jpg");
  
  // Load kite texture (optional - can use same image or different one)
  kiteTexture = loadImage("kite_texture.jpg");
  
  // Initialize kite position
  kiteX = width / 2;
  kiteY = height / 3;
  
  // Initialize decorative particles
  particles = new ArrayList<Particle>();
  for (int i = 0; i < 50; i++) {
    particles.add(new Particle(random(width), random(height)));
  }
  
  textureMode(NORMAL); // Use normalized texture coordinates (0-1)
}

void draw() {
  // Draw background image
  imageMode(CORNER);
  if (bgImage != null) {
    background(bgImage);
  } else {
    // Fallback gradient background if image not loaded
    drawGradientBackground();
  }
  
  // Update wind angle (oscillating wind simulation)
  windAngle = sin(frameCount * windSpeed) * PI / 6; // Oscillates between -30 and +30 degrees
  
  // Draw decorative ambient elements using different shape modes
  drawDecorativeElements();
  
  // Update and draw particles
  for (Particle p : particles) {
    p.update(windAngle);
    p.display();
  }
  
  // Draw the kite string
  drawKiteString();
  
  // Draw the kite (letter-shaped)
  drawLetterKite();
  
  // Display instructions
  displayInstructions();
}

// ============================================================
// DECORATIVE ELEMENTS - Demonstrating different beginShape modes
// ============================================================

void drawDecorativeElements() {
  // 1. POINTS mode - Stars in the sky
  stroke(255, 255, 200, 150);
  strokeWeight(3);
  beginShape(POINTS);
  for (int i = 0; i < 20; i++) {
    float x = (i * 40 + frameCount * 0.1) % width;
    float y = 50 + sin(i) * 30;
    vertex(x, y);
  }
  endShape();
  
  // 2. LINES mode - Wind streaks
  stroke(255, 255, 255, 50);
  strokeWeight(1);
  beginShape(LINES);
  for (int i = 0; i < 10; i++) {
    float x1 = (i * 80 + frameCount) % width;
    float y1 = 100 + i * 40;
    float x2 = x1 + 30;
    float y2 = y1 - 5;
    vertex(x1, y1);
    vertex(x2, y2);
  }
  endShape();
  
  // 3. TRIANGLES mode - Decorative bunting/flags
  noStroke();
  beginShape(TRIANGLES);
  for (int i = 0; i < 6; i++) {
    float x = 50 + i * 120;
    float y = 80;
    // Each triangle needs 3 vertices
    if (i % 2 == 0) fill(255, 100, 100, 180);
    else fill(100, 100, 255, 180);
    vertex(x, y);
    vertex(x + 20, y);
    vertex(x + 10, y + 30);
  }
  endShape();
  
  // 4. TRIANGLE_STRIP mode - Ribbon at bottom
  fill(255, 200, 100, 100);
  noStroke();
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < 20; i++) {
    float x = i * 45;
    float y1 = height - 30 + sin(frameCount * 0.05 + i * 0.5) * 10;
    float y2 = height - 10;
    vertex(x, y1);
    vertex(x, y2);
  }
  endShape();
  
  // 5. TRIANGLE_FAN mode - Sun decoration
  fill(255, 220, 100, 200);
  noStroke();
  beginShape(TRIANGLE_FAN);
  float sunX = 700;
  float sunY = 80;
  vertex(sunX, sunY); // Center point
  for (int i = 0; i <= 12; i++) {
    float angle = map(i, 0, 12, 0, TWO_PI);
    float r = 40 + sin(frameCount * 0.1 + i) * 5;
    vertex(sunX + cos(angle) * r, sunY + sin(angle) * r);
  }
  endShape();
  
  // 6. QUADS mode - Checkered pattern ground
  noStroke();
  beginShape(QUADS);
  for (int i = 0; i < 8; i++) {
    float x = i * 100;
    float y = height - 80;
    if (i % 2 == 0) fill(100, 180, 100, 100);
    else fill(80, 150, 80, 100);
    vertex(x, y);
    vertex(x + 100, y);
    vertex(x + 100, y + 80);
    vertex(x, y + 80);
  }
  endShape();
  
  // 7. QUAD_STRIP mode - Path/road
  fill(139, 119, 101, 150);
  noStroke();
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= 10; i++) {
    float x = width/2 - 30 + sin(i * 0.5) * 20;
    float y = height - 80 + i * 8;
    vertex(x - 20, y);
    vertex(x + 20, y);
  }
  endShape();
}

// ============================================================
// KITE DRAWING - Letter-shaped kite (Change 'A' to your initial!)
// ============================================================

void drawLetterKite() {
  pushMatrix();
  
  // Position the kite
  translate(kiteX, kiteY);
  
  // Rotate based on wind
  rotate(windAngle);
  
  // Draw the letter "A" shaped kite
  // CHANGE THIS TO YOUR INITIAL! See the function drawLetterShape()
  
  // Kite body with texture (if available)
  if (kiteTexture != null) {
    drawTexturedLetterKite();
  } else {
    drawColoredLetterKite();
  }
  
  // Draw kite tail
  drawKiteTail();
  
  popMatrix();
}

void drawTexturedLetterKite() {
  // Letter "A" shape with texture
  // MODIFY THE VERTICES BELOW TO MATCH YOUR INITIAL!
  
  fill(255);
  noStroke();
  
  beginShape();
  texture(kiteTexture);
  
  // Letter "A" vertices (simplified kite shape)
  // Top point
  vertex(0, -80, 0.5, 0);
  // Left outer
  vertex(-50, 60, 0, 1);
  // Left inner (crossbar)
  vertex(-25, 20, 0.25, 0.6);
  // Right inner (crossbar)
  vertex(25, 20, 0.75, 0.6);
  // Right outer
  vertex(50, 60, 1, 1);
  
  endShape(CLOSE); // CLOSE connects last vertex to first!
}

void drawColoredLetterKite() {
  // Letter "A" shape without texture
  // MODIFY THE VERTICES BELOW TO MATCH YOUR INITIAL!
  
  // Main kite body
  fill(255, 100, 100, 230);
  stroke(80, 40, 40);
  strokeWeight(3);
  
  // Using endShape(CLOSE) - This connects the last vertex back to the first vertex
  // If we used endShape() without CLOSE, the shape would remain open
  
  beginShape();
  // Letter "A" outline
  vertex(0, -80);      // Top point
  vertex(-50, 60);     // Bottom left
  vertex(-20, 60);     // Inner bottom left
  vertex(0, 10);       // Inner top (the hole in A)
  vertex(20, 60);      // Inner bottom right
  vertex(50, 60);      // Bottom right
  endShape(CLOSE);     // CLOSE connects back to (0, -80)
  
  // Crossbar of letter A
  fill(255, 150, 150, 230);
  beginShape();
  vertex(-30, 20);
  vertex(30, 20);
  vertex(25, 35);
  vertex(-25, 35);
  endShape(CLOSE);
  
  // Decorative frame lines
  stroke(255, 200, 100);
  strokeWeight(2);
  line(0, -80, -50, 60);
  line(0, -80, 50, 60);
  line(-30, 20, 30, 20);
}

void drawKiteTail() {
  // Draw a flowing tail
  noFill();
  stroke(255, 100, 100);
  strokeWeight(2);
  
  beginShape();
  for (int i = 0; i < 8; i++) {
    float x = sin(frameCount * 0.1 + i * 0.5) * (10 + i * 3);
    float y = 60 + i * 20;
    vertex(x, y);
  }
  endShape();
  
  // Tail bows
  for (int i = 1; i < 6; i++) {
    float x = sin(frameCount * 0.1 + i * 0.5) * (10 + i * 3);
    float y = 60 + i * 30;
    fill(255, 200, 100);
    noStroke();
    ellipse(x, y, 15, 8);
  }
}

void drawKiteString() {
  stroke(100, 80, 60);
  strokeWeight(1);
  noFill();
  
  // Curved string from bottom of screen to kite
  beginShape();
  for (int i = 0; i <= 20; i++) {
    float t = i / 20.0;
    float x = lerp(width/2, kiteX, t) + sin(t * PI + frameCount * 0.05) * 20 * (1-t);
    float y = lerp(height - 50, kiteY + 60, t);
    vertex(x, y);
  }
  endShape();
}

// ============================================================
// DIFFERENCE BETWEEN endShape() AND endShape(CLOSE)
// ============================================================
// 
// endShape() - Leaves the shape open. The last vertex is NOT connected 
//              to the first vertex. Good for lines, curves, open paths.
//
// endShape(CLOSE) - Closes the shape by drawing a line from the last 
//                   vertex back to the first vertex. Good for filled 
//                   polygons where you want a complete outline.
//
// Example:
// beginShape();
// vertex(0, 0);
// vertex(100, 0);
// vertex(100, 100);
// endShape();       // Creates an "L" shape (open)
// endShape(CLOSE);  // Creates a triangle (closed)
// ============================================================

// Helper function for gradient background (fallback)
void drawGradientBackground() {
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    color c = lerpColor(color(135, 206, 235), color(255, 200, 150), inter);
    stroke(c);
    line(0, y, width, y);
  }
}

void displayInstructions() {
  fill(0, 0, 0, 150);
  noStroke();
  rect(10, height - 100, 300, 90, 10);
  
  fill(255);
  textSize(12);
  text("Wind Direction: " + nf(degrees(windAngle), 0, 1) + "°", 20, height - 80);
  text("Press 'S' to save screenshot", 20, height - 60);
  text("Press 'R' to reset", 20, height - 40);
  text("ADD background.jpg to data folder!", 20, height - 20);
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    saveFrame("kite_screenshot_####.png");
    println("Screenshot saved!");
  }
  if (key == 'r' || key == 'R') {
    windAngle = 0;
  }
}

// ============================================================
// PARTICLE CLASS - For ambient decoration
// ============================================================

class Particle {
  float x, y;
  float size;
  float speedY;
  color c;
  
  Particle(float x, float y) {
    this.x = x;
    this.y = y;
    this.size = random(3, 8);
    this.speedY = random(0.5, 2);
    this.c = color(random(200, 255), random(200, 255), random(200, 255), random(100, 200));
  }
  
  void update(float wind) {
    x += cos(wind) * 2;
    y += speedY;
    
    // Wrap around
    if (y > height) {
      y = 0;
      x = random(width);
    }
    if (x < 0) x = width;
    if (x > width) x = 0;
  }
  
  void display() {
    noStroke();
    fill(c);
    ellipse(x, y, size, size);
  }
}
