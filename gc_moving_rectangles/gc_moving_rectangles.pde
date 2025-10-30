// Array of rectangles
MyRectangle[] rects = new MyRectangle[25];
MyRectangle r; // single rectangle example

void setup() {
  size(600, 400);

  // create 25 rectangles with random positions and colors
  for (int i = 0; i < rects.length; i++) {
    rects[i] = new MyRectangle(
      random(width), 
      random(height), 
      color(random(255), random(255), random(255))
    );
  }

  // one rectangle with default constructor
  r = new MyRectangle();
}

void draw() {
  background(240);

  // draw background text
  fill(0, 0, 139); // dark blue color
  textAlign(CENTER);
  textSize(32);
  text("Kushnirenko Ecaterina", width / 2, height / 2);

  // draw the rectangles
  for (int i = 0; i < rects.length; i++) {
    rects[i].display();
    rects[i].logic();
  }

  // draw the single one too
  r.display();
  r.logic();
}

// ---- Rectangle class ----
class MyRectangle {
  color c;
  float xpos;
  float ypos;
  float xspeed;
  float yspeed;
  float w;
  float h;

  // Default constructor
  MyRectangle() {
    xpos = width / 2;
    ypos = height / 2;
    c = color(175);
    xspeed = random(1, 3);
    yspeed = random(1, 3);
    w = 60;
    h = 35;
  }

  // Constructor with parameters
  MyRectangle(float x, float y, color col) {
    xpos = x;
    ypos = y;
    c = col;
    xspeed = random(1, 3);
    yspeed = random(1, 3);
    w = random(30, 80);
    h = random(20, 60);
  }

  void display() {
    rectMode(CENTER);
    stroke(0);
    fill(c);
    rect(xpos, ypos, w, h);
  }

  void logic() {
    xpos += xspeed;
    ypos += yspeed;

    // bounce and color change
    if (xpos > width - w/2 || xpos < w/2) {
      xspeed *= -1;
      c = color(random(255), random(255), random(255));
    }
    if (ypos > height - h/2 || ypos < h/2) {
      yspeed *= -1;
      c = color(random(255), random(255), random(255));
    }
  }
}
