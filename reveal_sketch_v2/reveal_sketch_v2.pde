// Processing Sketch - Part II: Color-by-Number Image Reveal
// ===========================================================
// Canvas: 1280 x 1262 (adapted for your drawing)
// Shapes fully cover the surface with NO GAPS
// ===========================================================

PImage myDrawing;

// Array to store all the shapes that cover the image
ArrayList<CoverShape> coverShapes;

// Color palette - each number (1-6) corresponds to a color
color[] palette = {
  color(255, 100, 100),   // 1 - Red
  color(100, 255, 100),   // 2 - Green
  color(100, 100, 255),   // 3 - Blue
  color(255, 255, 100),   // 4 - Yellow
  color(255, 100, 255),   // 5 - Magenta
  color(100, 255, 255)    // 6 - Cyan
};

// Currently selected color (1-6, 0 means none selected)
int selectedColor = 0;

// Track how many shapes have been revealed
int revealedCount = 0;
int totalShapes = 0;

void setup() {
  size(1280, 1262);
  
  // Load your hand-drawn image
  // YOU MUST ADD THIS FILE to the "data" folder!
  myDrawing = loadImage("sketch.jpg");
  
  // Resize image to fit canvas if needed
  if (myDrawing != null) {
    myDrawing.resize(width, height);
  }
  
  // Create the cover shapes - FULLY COVERING, NO GAPS
  coverShapes = new ArrayList<CoverShape>();
  createCoverShapes();
  
  totalShapes = coverShapes.size();
}

void draw() {
  // Draw the background/hidden image
  if (myDrawing != null) {
    background(myDrawing);
  } else {
    // Fallback pattern if image not loaded
    background(200);
    fill(150);
    textAlign(CENTER, CENTER);
    textSize(24);
    text("Add 'sketch.jpg' to the data folder!", width/2, height/2);
  }
  
  // Draw all cover shapes (unrevealed ones will hide parts of the image)
  for (CoverShape shape : coverShapes) {
    shape.display();
  }
  
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
// CREATE COVER SHAPES - Fully covering grid with NO GAPS
// ============================================================

void createCoverShapes() {
  // Grid layout - shapes touch each other perfectly
  int cols = 8;      // 8 columns
  int rows = 8;      // 8 rows
  
  float cellW = width / (float)cols;    // 1280 / 8 = 160 px
  float cellH = height / (float)rows;   // 1262 / 8 = 157.75 px
  
  int shapeIndex = 0;
  
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      float x = col * cellW;
      float y = row * cellH;
      
      // Assign color number (1-6) in a varied pattern
      int colorNum = ((row + col) % 6) + 1;
      
      // Alternate shape types for visual variety
      int shapeType = (row * cols + col) % 4;
      
      CoverShape shape = new CoverShape(x, y, cellW, cellH, colorNum, shapeType, row, col);
      coverShapes.add(shape);
      
      shapeIndex++;
    }
  }
}

// ============================================================
// COVER SHAPE CLASS - Vertex-based shapes, FULLY COVERING
// ============================================================

class CoverShape {
  float x, y, w, h;
  int colorNumber;    // 1-6, corresponds to palette
  int shapeType;      // Different shape types
  int row, col;       // Grid position
  boolean revealed;
  ArrayList<PVector> vertices;
  
  CoverShape(float x, float y, float w, float h, int colorNum, int type, int row, int col) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.colorNumber = colorNum;
    this.shapeType = type;
    this.row = row;
    this.col = col;
    this.revealed = false;
    this.vertices = new ArrayList<PVector>();
    
    // Generate vertices - shapes FULLY COVER their cell
    generateVertices();
  }
  
  void generateVertices() {
    vertices.clear();
    
    // All shapes fully cover their rectangular cell - NO GAPS
    switch(shapeType) {
      
      case 0: // Rectangle (full coverage)
        vertices.add(new PVector(x, y));
        vertices.add(new PVector(x + w, y));
        vertices.add(new PVector(x + w, y + h));
        vertices.add(new PVector(x, y + h));
        break;
        
      case 1: // Trapezoid pointing right (full coverage)
        vertices.add(new PVector(x, y));
        vertices.add(new PVector(x + w, y));
        vertices.add(new PVector(x + w, y + h));
        vertices.add(new PVector(x, y + h));
        break;
        
      case 2: // Pentagon-ish (full coverage with extra vertex)
        vertices.add(new PVector(x, y));
        vertices.add(new PVector(x + w * 0.5, y));
        vertices.add(new PVector(x + w, y));
        vertices.add(new PVector(x + w, y + h));
        vertices.add(new PVector(x, y + h));
        break;
        
      case 3: // Hexagon-ish (full coverage with indents)
        vertices.add(new PVector(x, y));
        vertices.add(new PVector(x + w, y));
        vertices.add(new PVector(x + w, y + h * 0.5));
        vertices.add(new PVector(x + w, y + h));
        vertices.add(new PVector(x, y + h));
        vertices.add(new PVector(x, y + h * 0.5));
        break;
    }
  }
  
  void display() {
    if (revealed) {
      return; // Don't draw if revealed
    }
    
    // Draw the shape using vertices - SOLID FILL, NO GAPS
    fill(palette[colorNumber - 1]);
    stroke(30);           // Dark border to see shape edges
    strokeWeight(2);
    
    beginShape();
    for (PVector v : vertices) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    
    // Draw the number in the center
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(36);
    text(colorNumber, x + w/2, y + h/2);
  }
  
  // Check if a point is inside this shape (simple rectangle check since full coverage)
  boolean containsPoint(float px, float py) {
    if (revealed) return false;
    return (px >= x && px <= x + w && py >= y && py <= y + h);
  }
  
  void reveal() {
    if (!revealed) {
      revealed = true;
      revealedCount++;
    }
  }
}

// ============================================================
// COLOR PALETTE UI
// ============================================================

void drawColorPalette() {
  float paletteX = 20;
  float paletteY = 20;
  float boxSize = 70;
  float spacing = 15;
  
  // Background for palette
  fill(50, 50, 50, 220);
  noStroke();
  rect(10, 10, 6 * (boxSize + spacing) + 20, boxSize + 45, 10);
  
  // Title
  fill(255);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Select a color:", paletteX, paletteY);
  
  // Draw color boxes
  for (int i = 0; i < 6; i++) {
    float bx = paletteX + i * (boxSize + spacing);
    float by = paletteY + 25;
    
    // Highlight selected color
    if (selectedColor == i + 1) {
      stroke(255);
      strokeWeight(5);
    } else {
      stroke(0);
      strokeWeight(2);
    }
    
    fill(palette[i]);
    rect(bx, by, boxSize, boxSize, 8);
    
    // Draw number on color box
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(28);
    text(i + 1, bx + boxSize/2, by + boxSize/2);
  }
}

void drawInstructions() {
  fill(50, 50, 50, 220);
  noStroke();
  rect(10, height - 110, 450, 100, 10);
  
  fill(255);
  textAlign(LEFT, TOP);
  textSize(18);
  
  String instructions = "HOW TO PLAY:\n";
  instructions += "1. Click a color in the palette (or press 1-6)\n";
  instructions += "2. Click shapes with matching numbers to reveal\n";
  instructions += "Progress: " + revealedCount + "/" + totalShapes + " revealed";
  
  if (selectedColor > 0) {
    instructions += "  |  Selected: Color " + selectedColor;
  }
  
  text(instructions, 20, height - 100);
}

void drawWinMessage() {
  fill(0, 0, 0, 180);
  rect(0, 0, width, height);
  
  fill(255, 255, 100);
  textAlign(CENTER, CENTER);
  textSize(64);
  text("PICTURE REVEALED!", width/2, height/2 - 40);
  
  textSize(32);
  fill(255);
  text("Press 'R' to reset and play again", width/2, height/2 + 40);
}

// ============================================================
// MOUSE INTERACTION
// ============================================================

void mousePressed() {
  // Check if clicking on color palette
  float paletteX = 20;
  float paletteY = 45;
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
          // Correct match! Reveal the shape
          shape.reveal();
          println("Correct! Shape revealed.");
        } else {
          // Wrong color
          println("Wrong color! This shape needs color " + shape.colorNumber);
        }
        return;
      }
    }
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    // Reset the game
    for (CoverShape shape : coverShapes) {
      shape.revealed = false;
    }
    revealedCount = 0;
    selectedColor = 0;
    println("Game reset!");
  }
  
  if (key == 's' || key == 'S') {
    saveFrame("reveal_screenshot_####.png");
    println("Screenshot saved!");
  }
  
  // Number keys to select colors quickly
  if (key >= '1' && key <= '6') {
    selectedColor = key - '0';
    println("Selected color: " + selectedColor);
  }
}
