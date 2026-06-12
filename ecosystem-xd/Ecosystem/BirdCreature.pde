// Bird Creature - flies with oscillating wings
class BirdCreature extends Creature {
  Oscillator leftWing;
  Oscillator rightWing;
  
  BirdCreature(float x, float y) {
    super(x, y);
    
    // Bird properties
    size = 12;
    maxSpeed = 4;
    maxForce = 0.4;
    mass = 0.8;
    creatureColor = color(100, 150, 255);
    
    perceptionRadius = 150;
    
    // Create wing oscillators
    leftWing = new Oscillator();
    leftWing.amplitude = size * 1.5;
    leftWing.period = 0.1;
    
    rightWing = new Oscillator();
    rightWing.amplitude = size * 1.5;
    rightWing.period = 0.1;
    rightWing.phaseOffset = PI; // Opposite phase
  }
  
  void update() {
    super.update();
    
    // Update wing oscillation based on speed
    float speed = velocity.mag();
    float flapSpeed = map(speed, 0, maxSpeed, 0.05, 0.2);
    
    leftWing.angleVelocity = flapSpeed;
    rightWing.angleVelocity = flapSpeed;
    
    // Oscillation costs energy
    health -= flapSpeed * 0.05;
    
    leftWing.update();
    rightWing.update();
    
    // Wings provide slight lift/propulsion
    if (speed > 0.5) {
      float wingPower = sin(leftWing.angle) * 0.02;
      PVector lift = velocity.copy();
      lift.normalize();
      lift.mult(wingPower);
      applyForce(lift);
    }
  }
  
  void display() {
    pushMatrix();
    translate(position.x, position.y);
    
    // Rotate to face direction of movement
    float angle = velocity.heading();
    rotate(angle);
    
    // Draw wings
    stroke(creatureColor);
    strokeWeight(2);
    
    // Left wing
    float leftWingAngle = leftWing.getAngle();
    line(0, 0, -size * 1.2 * cos(leftWingAngle), size * 1.2 * sin(leftWingAngle));
    
    // Right wing
    float rightWingAngle = rightWing.getAngle();
    line(0, 0, -size * 1.2 * cos(rightWingAngle), -size * 1.2 * sin(rightWingAngle));
    
    // Draw body
    fill(creatureColor);
    noStroke();
    ellipse(0, 0, size * 1.5, size);
    
    // Draw head
    fill(creatureColor);
    ellipse(size * 0.7, 0, size * 0.8, size * 0.8);
    
    // Draw eye
    fill(0);
    ellipse(size * 0.9, -size * 0.15, 3, 3);
    
    // Draw beak
    fill(255, 200, 0);
    triangle(size * 1.1, 0, size * 1.5, -3, size * 1.5, 3);
    
    popMatrix();
    
    // Draw health bar
    drawHealthBar();
    
    // Debug: show perception radius
    if (showForces) {
      noFill();
      stroke(creatureColor, 50);
      strokeWeight(1);
      ellipse(position.x, position.y, perceptionRadius * 2, perceptionRadius * 2);
    }
  }
  
  Creature reproduce() {
    super.reproduce();
    
    // Create offspring with slight variation
    BirdCreature baby = new BirdCreature(position.x + random(-20, 20), position.y + random(-20, 20));
    
    // Inherit traits with mutation
    baby.size = size * random(0.85, 1.15);
    baby.maxSpeed = maxSpeed * random(0.9, 1.1);
    baby.creatureColor = color(
      red(creatureColor) + random(-20, 20),
      green(creatureColor) + random(-20, 20),
      blue(creatureColor) + random(-20, 20)
    );
    baby.health = 50; // Born with half health
    
    return baby;
  }
}
