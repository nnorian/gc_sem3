/*
 * Computer Graphics - Midterm 2
 * Variant: 1
 * Name: Kushnirenko Ecaterina
 * FAF-243
 */

//GLOBAL VARIABLES 

PImage backgroundImg;
Attractor letterAttractor;
Liquid water;
ArrayList<Creature> creatures;
int pocketDivider;
int numCreatures = 12;

//SETUP
void setup() {
  size(900, 700);
  
  //middle of screen
  pocketDivider = height / 2;
  backgroundImg = loadImage("background.jpg");
  // Initialize the attractor at the center of the letter "K"
  letterAttractor = new Attractor(width/2, pocketDivider/2);
  // Initialize the liquid in the bottom pocket
  water = new Liquid(0, pocketDivider, width, height - pocketDivider, 0.15);
  // Create creatures with random positions
  creatures = new ArrayList<Creature>();
  for (int i = 0; i < numCreatures; i++) {
    float x = random(50, width - 50);
    float y = random(50, height - 50);
    
    // Alternate between TriangleFanCreature and QuadStripCreature
    if (i % 2 == 0) {
      creatures.add(new TriangleFanCreature(x, y));
    } else {
      creatures.add(new QuadStripCreature(x, y));
    }
  }
}

//DRAW 
void draw() {
  // Draw background image
  if (backgroundImg != null) {
    image(backgroundImg, 0, 0, width, height);
  } else {
    background(30, 40, 60);
  }
  
  drawPockets();
  drawLetterK();
  water.display();
  
//display all creatures
  for (Creature c : creatures) {
// Check if creature is in top pocket
    if (c.location.y < pocketDivider) {
// Apply attraction force from the letter
      PVector attractForce = letterAttractor.attract(c);
      c.applyForce(attractForce);
    }
    
// Check if creature is in the liquid
    if (water.contains(c)) {
// Apply drag force from liquid
      PVector dragForce = water.calculateDrag(c);
      c.applyForce(dragForce);
      
// Apply water gravity
      PVector waterGravity = water.getGravity();
      c.applyForce(waterGravity);
    } else {
// Apply normal gravity when not in water
    PVector gravity = new PVector(0, 0.03 * c.mass);
    c.applyForce(gravity);
    }
    c.update();
    c.display();
  }
}

//HELPER FUNCTIONS

// Draw semi-transparent overlays for the two pockets
void drawPockets() {
  noStroke();
  
// Top pocket - slightly blue tint
  fill(50, 100, 200, 30);
  rect(0, 0, width, pocketDivider);
  
}

//"K" using vertex(), beginShape(), endShape()
void drawLetterK() {
  float cx = width / 2; // Center X
  float cy = pocketDivider / 2; // Center Y
  float letterHeight = 180;
  float letterWidth = 120;
  float thickness = 25;
  
  // Calculate letter bounds
  float left = cx - letterWidth / 2;
  float right = cx + letterWidth / 2;
  float top = cy - letterHeight / 2;
  float bottom = cy + letterHeight / 2;
  float midY = cy;
  
  // Set letter style with gradient effect
  noStroke();
  // Main letter body with solid color
  fill(150, 200, 255);
  // Vertical stroke
  beginShape();
  vertex(left, top);
  vertex(left + thickness, top);
  vertex(left + thickness, bottom);
  vertex(left, bottom);
  endShape(CLOSE);
  // Upper diagonal
  beginShape();
  vertex(left + thickness, midY - thickness/3);
  vertex(left + thickness + 10, midY);
  vertex(right, top);
  vertex(right - thickness, top);
  endShape(CLOSE);
  // Lower diagonal
  beginShape();
  vertex(left + thickness, midY + thickness/3);
  vertex(left + thickness + 10, midY);
  vertex(right - thickness, bottom);
  vertex(right, bottom);
  endShape(CLOSE);
  
}
//ATTRACTOR CLASS
class Attractor {
  PVector location;
  float mass;
  float gravity;
  
  Attractor(float x, float y) {
    location = new PVector(x, y);
    mass = 80;
    gravity = 5.0;
  }
  
  PVector attract(Creature creature) {
    PVector force = PVector.sub(location, creature.location);
    float distance = force.mag();
    distance = constrain(distance, 5, 100);
    force.normalize();
    float strength = (gravity * mass * creature.mass) / (distance * distance);
    force.mult(strength);
    return force;
  }
  
  float getDistance(Creature creature) {
    return PVector.dist(location, creature.location);
  }
}

// LIQUID CLASS
class Liquid {
  float x, y;
  float w, h;
  float dragCoefficient;
  PVector gravity;
// Constructor
  Liquid(float x, float y, float w, float h, float c) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.dragCoefficient = c;
// Reduced gravity in water
    gravity = new PVector(0, 0.05);
  }
  
// Check if a creature is inside the liquid
  boolean contains(Creature creature) {
    PVector loc = creature.location;
    return loc.x > x && loc.x < x + w && 
           loc.y > y && loc.y < y + h;
  }
  
// Calculate drag force on a creature
  PVector calculateDrag(Creature creature) {
// Get creature velocity
    PVector velocity = creature.velocity.copy();
    float speed = velocity.mag();
    float dragMagnitude = dragCoefficient * speed * speed;
// Get direction of velocity
    velocity.normalize();
// Drag acts opposite to velocity
    velocity.mult(-1);
// Scale by drag magnitude
    PVector force = velocity.mult(dragMagnitude);
    return force;
  }
// Get gravity force in liquid
  PVector getGravity() {
    return gravity.copy();
  }
  
  void display() {
    noStroke();
// Multiple layers for depth effect
    for (int i = 0; i < 3; i++) {
      fill(30, 100 + i * 30, 180 + i * 20, 60 - i * 15);
      beginShape();
      vertex(x, y + h);
      vertex(x, y);  
// Animated wave surface
      for (float wx = x; wx <= x + w; wx += 20) {
        float waveHeight = sin((wx + frameCount * 2) * 0.05) * (8 - i * 2);
        vertex(wx, y + waveHeight + i * 5);
      }
      vertex(x + w, y);
      vertex(x + w, y + h);
      endShape(CLOSE);
    }
    endShape();
  }
}

//PARENT CREATURE CLASS
class Creature {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
  color fillColor;
  float size;
  float oscillationSpeed;
  float oscillationAmount;
  float angle;
  
  // Constructor
  Creature(float x, float y) {
    location = new PVector(x, y);
    velocity = new PVector(random(-1, 1), random(-1, 1));
    acceleration = new PVector(0, 0);
    mass = random(1, 3);
    size = mass * 15;
// Random fill color
    fillColor = color(random(100, 255), random(100, 255), random(100, 255));
 // Random oscillation parameters
    oscillationSpeed = random(0.02, 0.08);
    oscillationAmount = random(5, 15);
    angle = random(TWO_PI);
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }
  
  void update() {
// Update velocity
    velocity.add(acceleration);
// Limit velocity
    velocity.limit(5);
// Update position
    location.add(velocity);
 // Reset acceleration
    acceleration.mult(0);
// Update oscillation angle
    angle += oscillationSpeed;
  }
  
  void display() {
    fill(fillColor);
    noStroke();
    ellipse(location.x, location.y, size, size);
  }
}

// TRIANGLE FAN CREATURE

class TriangleFanCreature extends Creature {
  int numPoints;
  float[] pointAngles;
  float rotationSpeed;
  color[] pointColors;
  
  // Constructor
  TriangleFanCreature(float x, float y) {
    super(x, y);  // Call parent constructor
    numPoints = int(random(5, 10));
    pointAngles = new float[numPoints];
    pointColors = new color[numPoints];
    rotationSpeed = random(-0.03, 0.03);
    // Initialize point angles and colors
    for (int i = 0; i < numPoints; i++) {
      pointAngles[i] = map(i, 0, numPoints, 0, TWO_PI);
      // Random gradient colors
      pointColors[i] = color(
        random(150, 255),
        random(100, 200),
        random(150, 255),
        200
      );
    }
  }
  
  @Override
  void display() {
    pushMatrix();
    translate(location.x, location.y);
    rotate(angle * rotationSpeed * 10);
    float oscillatingSize = size + sin(angle) * oscillationAmount;
    beginShape(TRIANGLE_FAN);
    // Center point of the fan
    fill(fillColor);
    vertex(0, 0);
    
    // Outer points with oscillation
    for (int i = 0; i <= numPoints; i++) {
      int idx = i % numPoints;
      float pointAngle = pointAngles[idx];
      // Add oscillation to each point
      float oscillation = sin(angle + idx * 0.5) * oscillationAmount * 0.3;
      float r = oscillatingSize + oscillation;
      float px = cos(pointAngle) * r;
      float py = sin(pointAngle) * r;
      
      fill(pointColors[idx]);
      vertex(px, py);
    }
    
    endShape();
    
// center
    fill(255, 200);
    noStroke();
    ellipse(0, 0, size * 0.3, size * 0.3);
//eye
    fill(50);
    float eyeOffset = size * 0.15;
    ellipse(-eyeOffset, -eyeOffset * 0.5, size * 0.12, size * 0.12);
    ellipse(eyeOffset, -eyeOffset * 0.5, size * 0.12, size * 0.12);
    
    popMatrix();
  }
}

// QUAD STRIP CREATURE
class QuadStripCreature extends Creature {
  int numSegments;
  float segmentWidth;
  color[] segmentColors;
  float waveSpeed;
  float waveAmount;
  
  // Constructor
  QuadStripCreature(float x, float y) {
    super(x, y);  // Call parent constructor
    numSegments = int(random(4, 8));
    segmentWidth = size / numSegments;
    waveSpeed = random(0.05, 0.15);
    waveAmount = random(3, 8);
// Initialize segment colors with gradient
    segmentColors = new color[numSegments + 1];
    color startColor = color(random(100, 200), random(150, 255), random(100, 200));
    color endColor = color(random(200, 255), random(100, 200), random(150, 255));
    
    for (int i = 0; i <= numSegments; i++) {
      float t = map(i, 0, numSegments, 0, 1);
      segmentColors[i] = lerpColor(startColor, endColor, t);
    }
  }
  
  @Override
  void display() {
    pushMatrix();
    translate(location.x, location.y);
// Calculate oscillating factors
    float oscillation1 = sin(angle) * oscillationAmount;
    float oscillation2 = cos(angle * 1.5) * oscillationAmount * 0.5;
// Body made with QUAD_STRIP
    noStroke();
    beginShape(QUAD_STRIP);
    float totalWidth = size * 1.5 + oscillation1;
    float bodyHeight = size + oscillation2;
    
    for (int i = 0; i <= numSegments; i++) {
      float t = map(i, 0, numSegments, -0.5, 0.5);
      float x = t * totalWidth;
      // Wave effect on the body
      float wave = sin(angle * waveSpeed * 50 + i * 0.8) * waveAmount;
      // Top and bottom vertices for quad strip
      float topY = -bodyHeight / 2 + wave;
      float bottomY = bodyHeight / 2 + wave * 0.5;
      // Taper the ends
      float taper = 1 - abs(t) * 0.6;
      topY *= taper;
      bottomY *= taper;
      fill(segmentColors[i]);
      vertex(x, topY);
      vertex(x, bottomY);
    }
    
    endShape();
    
// tail fin
    fill(lerpColor(fillColor, color(255), 0.3));
    beginShape();
    float tailX = -totalWidth / 2 - 5;
    vertex(tailX, 0);
    vertex(tailX - 15, -bodyHeight * 0.4 + sin(angle * 2) * 5);
    vertex(tailX - 10, 0);
    vertex(tailX - 15, bodyHeight * 0.4 + sin(angle * 2) * 5);
    endShape(CLOSE);
    
// Dorsal fin
    fill(segmentColors[numSegments / 2], 180);
    beginShape();
    vertex(0, -bodyHeight / 2);
    
vertex(-size * 0.15, -bodyHeight / 2 - size * 0.3 + sin(angle) * 3);
    vertex(size * 0.15, -bodyHeight / 2 - size * 0.2 + sin(angle * 1.2) * 2);
    endShape(CLOSE);
    
// Draw eye
    fill(255);
    float eyeX = totalWidth / 3;
    float eyeY = -bodyHeight * 0.1;
    ellipse(eyeX, eyeY, size * 0.2, size * 0.2);
    fill(30);
    ellipse(eyeX + 2, eyeY, size * 0.1, size * 0.12);
    popMatrix();
  }
}

//MOUSE INTERACTION
void mousePressed() {
  if (mouseButton == LEFT) {
    if (random(1) > 0.5) {
      creatures.add(new TriangleFanCreature(mouseX, mouseY));
    } else {
      creatures.add(new QuadStripCreature(mouseX, mouseY));
    }
  }
}
