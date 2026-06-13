// COMPUTER GRAPHICS COURSE MIDTERM 1
// Task 1: Create a cat using 2D primitives with loop decoration

void setup() {
  size(800, 600);
  background(240);
  
  // My info
  fill(0);
  textSize(16);
  text("Variant: 1 | Name: Kushnirenko Ecaterina | Group: FAF", 20, 30);
  
  // Draw the cat in center
  drawCat(400, 350, 1.0);
}

void draw() {
  // Static drawing - no animation needed for Task 1
}

// Function to draw a simplified cat using 2D primitives
void drawCat(float x, float y, float scale) {
  pushMatrix();
  translate(x, y);
  scale(scale);
  
  // Body (ellipse primitive)
  fill(255, 140, 0); // Orange color
  stroke(0);
  strokeWeight(2);
  ellipse(0, 0, 120, 100);
  
  // Head (ellipse primitive)
  ellipse(0, -70, 90, 80);
  
  // Ears (pie/arc primitives)
  fill(255, 140, 0);
  arc(-25, -100, 35, 50, PI, TWO_PI);
  arc(25, -100, 35, 50, PI, TWO_PI);
  
  // Eyes (ellipse primitives)
  fill(0);
  ellipse(-20, -75, 12, 12);
  ellipse(20, -75, 12, 12);
  
  // Nose (small ellipse)
  fill(255, 105, 180); // Pink
  ellipse(0, -55, 10, 8);
  
  // Mouth (line primitives)
  stroke(0);
  strokeWeight(2);
  line(0, -55, -12, -45);
  line(0, -55, 12, -45);
  
  // LOOP DECORATION: Whiskers (line primitives multiplied with for loop)
  stroke(0);
  strokeWeight(1);
  for (int i = 0; i < 3; i++) {
    // Left whiskers
    line(-45, -70 + i*10, -75, -70 + i*10);
    // Right whiskers
    line(45, -70 + i*10, 75, -70 + i*10);
  }
  
  // Legs (rectangle/square primitives)
  fill(255, 140, 0);
  stroke(0);
  strokeWeight(2);
  rect(-30, 40, 15, 35); // Front left leg
  rect(-5, 40, 15, 35);  // Front right leg
  rect(15, 40, 15, 35);  // Back left leg
  rect(40, 40, 15, 35);  // Back right leg
  
  // Tail (simple curve using arc/pie primitive)
  fill(255, 140, 0);
  arc(60, 0, 80, 40, -HALF_PI, HALF_PI);
  
  popMatrix();
}
