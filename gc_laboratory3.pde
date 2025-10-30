
// list to hold all dragon objects
ArrayList<Dragon> dragons;

void setup() {
  // set canvas size
  size(900, 600);
  
  // create the array list
  dragons = new ArrayList<Dragon>();
  
  // create a dragon with constant acceleration (moves straight)
  dragons.add(new Dragon(new PVector(150, 150), color(255, 150, 50), 0));
  
  // create a dragon with random acceleration (chaotic movement)
  dragons.add(new Dragon(new PVector(300, 200), color(50, 150, 255), 1));
  
  // create a dragon with perlin noise acceleration (smooth wandering)
  dragons.add(new Dragon(new PVector(450, 300), color(120, 230, 120), 2));
  
  // create a dragon that accelerates towards the mouse (curious)
  dragons.add(new Dragon(new PVector(600, 400), color(255, 80, 100), 3));
}

void draw() {
  // clear the background
  background(245, 235, 220);
  
  // update and display each dragon
  for (Dragon d : dragons) {
    d.update();
    d.display();
  }
}

// class definition for dragon
class Dragon {
  // position, velocity, acceleration vectors
  PVector location, velocity, acceleration;
  
  // dragon color
  color c;
  
  // type of acceleration (0=constant, 1=random, 2=perlin, 3=mouse)
  int type;
  
  // noise offsets for perlin movement
  float noiseOffsetX, noiseOffsetY;
  
  // constructor
  Dragon(PVector loc, color c_, int type_) {
    location = loc.copy();
    velocity = new PVector(random(-1, 1), random(-1, 1));
    acceleration = new PVector();
    c = c_;
    type = type_;
    noiseOffsetX = random(1000);
    noiseOffsetY = random(2000);
  }
  
  // update dragon position and velocity
  void update() {
    switch (type) {
      case 0: // constant acceleration
        acceleration.set(0.05, 0); // small steady push to the right
        break;
        
      case 1: // random acceleration
        // occasional strong random impulses
        if (frameCount % int(random(5, 20)) == 0) {
          float angle = random(TWO_PI);
          float strength = random(0.3, 0.8);
          acceleration = PVector.fromAngle(angle).mult(strength);
        }
        // small random drift in between impulses
        acceleration.add(new PVector(random(-0.05, 0.05), random(-0.05, 0.05)));
        break;
        
      case 2: // perlin noise acceleration
        float ax = map(noise(noiseOffsetX), 0, 1, -0.1, 0.1);
        float ay = map(noise(noiseOffsetY), 0, 1, -0.1, 0.1);
        acceleration.set(ax, ay);
        noiseOffsetX += 0.02;
        noiseOffsetY += 0.02;
        break;
        
      case 3: // accelerate towards mouse
        PVector mouse = new PVector(mouseX, mouseY);
        PVector dir = PVector.sub(mouse, location);
        dir.setMag(0.05); // limit strength
        acceleration = dir;
        break;
    }

    // update velocity and limit speed
    velocity.add(acceleration);
    velocity.limit(4.5);
    
    // update location
    location.add(velocity);
    
    // wrap around edges of the screen
    if (location.x > width) location.x = 0;
    if (location.x < 0) location.x = width;
    if (location.y > height) location.y = 0;
    if (location.y < 0) location.y = height;
  }

  // display dragon on screen
  void display() {
    pushMatrix();
    translate(location.x, location.y); // move to dragon location
    scale(0.25); // make dragon smaller
    drawFullDragon(c); // draw the dragon
    popMatrix();
  }
  
  // draw the full dragon as in lab 1
  void drawFullDragon(color bodyColor) {
    noStroke();
    
    // spikes along the back
    fill(74, 124, 89);
    stroke(74, 124, 89);
    strokeWeight(10);
    strokeJoin(ROUND);
    triangle(250, 120, 270, 110, 230, 100);
    triangle(235, 150, 255, 140, 215, 130);
    triangle(220, 180, 240, 170, 200, 160);
    triangle(205, 210, 225, 200, 185, 190);
    triangle(190, 240, 210, 230, 170, 220);
    triangle(175, 270, 195, 260, 155, 250);
    triangle(160, 300, 180, 290, 140, 280);
    triangle(145, 330, 165, 320, 125, 310);
    triangle(130, 360, 150, 350, 110, 340);
    triangle(115, 390, 135, 380, 95, 370);
    triangle(100, 420, 120, 410, 80, 400);
    triangle(85, 450, 105, 440, 65, 430);
    triangle(70, 480, 90, 470, 50, 460);
    
    // main body
    fill(bodyColor);
    noStroke();
    triangle(10, 540, 330, 100, 330, 540);
    triangle(10, 540, 266, 100, 266, 540);
    
    // head
    rectMode(CORNER);
    fill(bodyColor);
    rect(250, 100, 250, 160, 30);
    
    // body spots
    fill(74, 124, 89);
    noStroke();
    circle(230, 220, 35);
    circle(210, 310, 50);
    circle(180, 410, 60);
    circle(240, 480, 70);
    circle(260, 340, 45);
    circle(120, 450, 50);
    
    // nostril
    circle(470, 120, 12);
    
    // mouth
    fill(245, 235, 220);
    noStroke();
    rect(330, 160, 200, 80, 40);
    
    // tongue
    fill(255, 100, 120);
    noStroke();
    arc(332, 200, 60, 40, -HALF_PI, HALF_PI, CHORD);
    
    // eye
    fill(255);
    ellipse(310, 125, 70, 75);
    fill(0);
    circle(308, 120, 35);
    fill(255);
    circle(315, 110, 15);
    
    // cheek
    fill(245, 166, 35);
    circle(290, 195, 30);
    
    // arms
    fill(bodyColor);
    noStroke();
    triangle(300, 300, 350, 300, 300, 340);
    triangle(280, 335, 370, 335, 280, 385);
  }
}
