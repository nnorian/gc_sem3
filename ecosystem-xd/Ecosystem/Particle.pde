// Particle class - used for eating effects and death animations
class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  float size;
  color particleColor;
  
  Particle(PVector pos, float angle) {
    position = pos.copy();
    velocity = PVector.fromAngle(angle);
    velocity.mult(random(1, 3));
    acceleration = new PVector(0, 0.05); // Slight gravity
    lifespan = 255;
    size = random(3, 7);
    particleColor = color(100, 200, 100, lifespan);
  }
  
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 4;
    
    // Fade color
    particleColor = color(
      red(particleColor),
      green(particleColor),
      blue(particleColor),
      lifespan
    );
  }
  
  void display() {
    noStroke();
    fill(particleColor);
    ellipse(position.x, position.y, size, size);
  }
  
  boolean isDead() {
    return lifespan <= 0;
  }
}
