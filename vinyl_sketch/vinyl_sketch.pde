// Processing Sketch - Part II: Color-by-Number Image Reveal
// ===========================================================
// Canvas: 1280 x 1262 (adapted for your drawing)
// Cover shape: VINYL RECORD with segments
// ===========================================================

PImage myDrawing;

// Array to store all the shapes that cover the image
ArrayList<CoverShape> coverShapes;

// Color palette - each number (1-6) corresponds to a color
color[] palette = {
  color(30, 30, 30),      // 1 - Black (vinyl color)
  color(50, 50, 50),      // 2 - Dark gray
  color(70, 70, 70),      // 3 - Medium gray
  color(40, 40, 40),      // 4 - Charcoal
  color(60, 60, 60),      // 5 - Gray
  color(25, 25, 25)       // 6 - Near black
};

// Currently selected color (1-6, 0 means none selected)
int selectedColor = 0;

// Track how many shapes have been revealed
int revealedCount = 0;
int totalShapes = 0;

// Vinyl record parameters
float centerX, centerY;
float outerRadius;
float innerRadius;      // Label area
float holeRadius;       // Center hole

void setup() {
  size(1280, 1262);
  
  // Load your hand-drawn image
  myDrawing = loadImage("sketch.jpg");
  
  if (myDrawing != null) {
    myDrawing.resize(width, height);
  }
  
  // Vinyl record center and size
  centerX = width / 2;
  centerY = height / 2;
  outerRadius = min(width, height) / 2 - 20;  // Outer edge of vinyl
  innerRadius = outerRadius * 0.18;            // Label area (smaller)
  holeRadius = 15;                             // Center spindle hole
  
  // Create the vinyl record cover shapes
  coverShapes = new ArrayList<CoverShape>();
  createVinylRecord();
  
  totalShapes = coverShapes.size();
}

void draw() {
  // Draw the background/hidden image
  if (myDrawing != null) {
    background(myDrawing);
  } else {
    background(200);
    fill(150);
    textAlign(CENTER, CENTER);
    textSize(24);
    text("Add 'sketch.jpg' to the data folder!", width/2, height/2);
  }
  
  // Draw all cover shapes (vinyl record segments)
  for (CoverShape shape : coverShapes) {
    shape.display();
  }
  
  // Draw center hole (always visible)
  fill(myDrawing != null ? color(0, 0, 0, 0) : color(200));
  stroke(30);
  strokeWeight(2);
  ellipse(centerX, centerY, holeRadius * 2, holeRadius * 2);
  
  // Draw the color palette UI
  drawColorPalette();
  
  // Draw instructions
  drawInstructions();
  
  // Check for win condition
  if (revealedCount == totalShapes && totalShapes > 0) {
    drawWinMessage();
  }
}

// ============================================================
// CREATE VINYL RECORD - Concentric rings divided into segments
// ============================================================

void createVinylRecord() {
  int numRings = 8;           // Number of concentric rings (grooves)
  int segmentsPerRing = 12;   // Segments per ring (like pizza slices)
  
  float ringWidth = (outerRadius - innerRadius) / numRings;
  
  for (int ring = 0; ring < numRings; ring++) {
    float innerR = innerRadius + ring * ringWidth;
    float outerR = innerRadius + (ring + 1) * ringWidth;
    
    for (int seg = 0; seg < segmentsPerRing; seg++) {
      float startAngle = map(seg, 0, segmentsPerRing, 0, TWO_PI);
      float endAngle = map(seg + 1, 0, segmentsPerRing, 0, TWO_PI);
      
      // Assign color number (1-6) in a pattern
      int colorNum = ((ring + seg) % 6) + 1;
      
      CoverShape shape = new CoverShape(innerR, outerR, startAngle, endAngle, colorNum);
      coverShapes.add(shape);
    }
  }
  
  // Add center label area as one big circle (divided into segments too)
  int labelSegments = 6;
  for (int seg = 0; seg < labelSegments; seg++) {
    float startAngle = map(seg, 0, labelSegments, 0, TWO_PI);
    float endAngle = map(seg + 1, 0, labelSegments, 0, TWO_PI);
    int colorNum = (seg % 6) + 1;
    
    CoverShape shape = new CoverShape(holeRadius, innerRadius, startAngle, endAngle, colorNum);
    coverShapes.add(shape);
  }
}

// ============================================================
// COVER SHAPE CLASS - Vinyl record segment (arc/wedge shape)
// ============================================================

class CoverShape {
  float innerR, outerR;       // Inner and outer radius
  float startAngle, endAngle; // Angular span
  int colorNumber;
  boolean revealed;
  ArrayList<PVector> vertices;
  
  CoverShape(float innerR, float outerR, float startAngle, float endAngle, int colorNum) {
    this.innerR = innerR;
    this.outerR = outerR;
    this.startAngle = startAngle;
    this.endAngle = endAngle;
    this.colorNumber = colorNum;
    this.revealed = false;
    this.vertices = new ArrayList<PVector>();
    
    generateVertices();
  }
  
  void generateVertices() {
    vertices.clear();
    
    int resolution = 20; // Smoothness of the arc
    
    // Outer arc (from startAngle to endAngle)
    for (int i = 0; i <= resolution; i++) {
      float angle = lerp(startAngle, endAngle, i / (float)resolution);
      float x = centerX + cos(angle) * outerR;
      float y = centerY + sin(angle) * outerR;
      vertices.add(new PVector(x, y));
    }
    
    // Inner arc (from endAngle back to startAngle)
    for (int i = resolution; i >= 0; i--) {
      float angle = lerp(startAngle, endAngle, i / (float)resolution);
      float x = centerX + cos(angle) * innerR;
      float y = centerY + sin(angle) * innerR;
      vertices.add(new PVector(x, y));
    }
  }
  
  void display() {
    if (revealed) {
      return;
    }
    
    // Draw the vinyl segment
    fill(palette[colorNumber - 1]);
    stroke(15);  // Very dark lines between segments (like grooves)
    strokeWeight(1);
    
    beginShape();
    for (PVector v : vertices) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    
    // Draw the number in the center of the segment
    float midAngle = (startAngle + endAngle) / 2;
    float midR = (innerR + outerR) / 2;
    float numX = centerX + cos(midAngle) * midR;
    float numY = centerY + sin(midAngle) * midR;
    
    fill(200);  // Light gray numbers on dark vinyl
    textAlign(CENTER, CENTER);
    textSize(18);
    text(colorNumber, numX, numY);
    
    // Draw subtle groove lines for vinyl effect
    stroke(20, 20, 20, 100);
    strokeWeight(0.5);
    float grooveR = (innerR + outerR) / 2;
    noFill();
    arc(centerX, centerY, grooveR * 2, grooveR * 2, startAngle, endAngle);
  }
  
  // Check if point is inside this arc segment
  boolean containsPoint(float px, float py) {
    if (revealed) return false;
    
    // Convert point to polar coordinates relative to center
    float dx = px - centerX;
    float dy = py - centerY;
    float dist = sqrt(dx * dx + dy * dy);
    float angle = atan2(dy, dx);
    
    // Normalize angle to 0 to TWO_PI
    if (angle < 0) angle += TWO_PI;
    
    // Normalize startAngle and endAngle
    float sA = startAngle;
    float eA = endAngle;
    if (sA < 0) sA += TWO_PI;
    if (eA < 0) eA += TWO_PI;
    
    // Check if within radius range
    if (dist < innerR || dist > outerR) return false;
    
    // Check if within angle range
    if (sA <= eA) {
      return angle >= sA && angle <= eA;
    } else {
      // Wraps around 0
      return angle >= sA || angle <= eA;
    }
  }
  
  void reveal() {
    if (!revealed) {
      revealed = true;
      revealedCount++;
    }
  }
}

// ============================================================
// COLOR PALETTE UI - Vinyl themed
// ============================================================

void drawColorPalette() {
  float paletteX = 20;
  float paletteY = 20;
  float boxSize = 70;
  float spacing = 15;
  
  // Background for palette
  fill(20, 20, 20, 230);
  noStroke();
  rect(10, 10, 6 * (boxSize + spacing) + 20, boxSize + 50, 10);
  
  // Title
  fill(200);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Select a groove color:", paletteX, paletteY);
  
  // Draw color boxes
  for (int i = 0; i < 6; i++) {
    float bx = paletteX + i * (boxSize + spacing);
    float by = paletteY + 28;
    
    // Highlight selected color
    if (selectedColor == i + 1) {
      stroke(255, 200, 0);  // Gold highlight
      strokeWeight(5);
    } else {
      stroke(100);
      strokeWeight(2);
    }
    
    fill(palette[i]);
    rect(bx, by, boxSize, boxSize, 8);
    
    // Draw number on color box
    fill(200);
    textAlign(CENTER, CENTER);
    textSize(28);
    text(i + 1, bx + boxSize/2, by + boxSize/2);
  }
}

void drawInstructions() {
  fill(20, 20, 20, 230);
  noStroke();
  rect(10, height - 120, 500, 110, 10);
  
  fill(200);
  textAlign(LEFT, TOP);
  textSize(18);
  
  String instructions = "VINYL REVEAL GAME:\n";
  instructions += "1. Click a color in the palette (or press 1-6)\n";
  instructions += "2. Click vinyl segments with matching numbers\n";
  instructions += "Progress: " + revealedCount + "/" + totalShapes + " segments revealed";
  
  if (selectedColor > 0) {
    instructions += "\nSelected: Color " + selectedColor;
  }
  
  text(instructions, 20, height - 110);
}

void drawWinMessage() {
  fill(0, 0, 0, 180);
  rect(0, 0, width, height);
  
  fill(255, 200, 0);
  textAlign(CENTER, CENTER);
  textSize(64);
  text("RECORD REVEALED!", width/2, height/2 - 40);
  
  textSize(32);
  fill(255);
  text("Press 'R' to play again", width/2, height/2 + 40);
}

// ============================================================
// MOUSE INTERACTION
// ============================================================

void mousePressed() {
  // Check if clicking on color palette
  float paletteX = 20;
  float paletteY = 48;
  float boxSize = 70;
  float spacing = 15;
  
  for (int i = 0; i < 6; i++) {
    float bx = paletteX + i * (boxSize + spacing);
    float by = paletteY;
    
    if (mouseX >= bx && mouseX <= bx + boxSize &&
        mouseY >= by && mouseY <= by + boxSize) {
      selectedColor = i + 1;
      println("Selected color: " + selectedColor);
      return;
    }
  }
  
  // Check if clicking on a shape
  if (selectedColor > 0) {
    for (CoverShape shape : coverShapes) {
      if (shape.containsPoint(mouseX, mouseY)) {
        if (shape.colorNumber == selectedColor) {
          shape.reveal();
          println("Correct! Segment revealed.");
        } else {
          println("Wrong color! This segment needs color " + shape.colorNumber);
        }
        return;
      }
    }
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    for (CoverShape shape : coverShapes) {
      shape.revealed = false;
    }
    revealedCount = 0;
    selectedColor = 0;
    println("Game reset!");
  }
  
  if (key == 's' || key == 'S') {
    saveFrame("vinyl_reveal_####.png");
    println("Screenshot saved!");
  }
  
  if (key >= '1' && key <= '6') {
    selectedColor = key - '0';
    println("Selected color: " + selectedColor);
  }
}
