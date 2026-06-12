// Fish Creature - swims with oscillating tail
class FishCreature extends Creature {
  Oscillator tail;
  ArrayList<PVector> bodySegments;
  
  FishCreature(float x, float y) {
    super(x, y);
    
    // Fish properties
    size = 14;
    maxSpeed = 3.5;
    maxForce = 0.35;
    mass = 1.2;
    creatureColor = color(255, 150, 100);
    
    perceptionRadius = 120;
    
    // Create tail oscillator
    tail = new Oscillator();
    tail.amplitude = size * 1.2;
    tail.period = 0.15;
    
    // Body segments for smooth swimming motion
    bodySegments = new ArrayList<PVector>();
    for (int i = 0; i < 5; i++) {
      bodySegments.add(new PVector(0, 0));
    }
  }
  
  void update() {
    super.update();
    
    // Update tail oscillation based on speed
    float speed = velocity.mag();
    float swimSpeed = map(speed, 0, maxSpeed, 0.08, 0.25);
    
    tail.angleVelocity = swimSpeed;
    
    // Swimming costs energy
    health -= swimSpeed * 0.04;
    
    tail.update();
    
    // Tail propulsion - pushes creature forward
    if (speed > 0.3) {
      float tailForce = sin(tail.angle) * 0.03;
      PVector propulsion = velocity.copy();
      propulsion.normalize();
      propulsion.mult(tailForce);
      applyForce(propulsion);
    }
    
    // Update body segments to follow
    updateBodySegments();
  }
  
  void updateBodySegments() {
    // First segment follows the head
    if (bodySegments.size() > 0) {
      float segmentDistance = size * 0.6;
      PVector direction = velocity.copy();
      direction.normalize();
      direction.mult(-segmentDistance);
      
      bodySegments.set(0, PVector.add(position, direction));
      
      // Other segments follow previous segment
      for (int i = 1; i < bodySegments.size(); i++) {
        PVector prev = bodySegments.get(i - 1);
        PVector current = bodySegments.get(i);
        
        PVector toTarget = PVector.sub(prev, current);
        toTarget.setMag(segmentDistance);
        bodySegments.set(i, PVector.sub(prev, toTarget));
      }
    }
  }
  
  void display() {
    pushMatrix();
    translate(position.x, position.y);
    
    // Rotate to face direction of movement
    float angle = velocity.heading();
    rotate(angle);
    
    // Draw body segments
    noStroke();
    fill(creatureColor, 200);
    
    // Draw from tail to head
    for (int i = bodySegments.size() - 1; i >= 0; i--) {
      pushMatrix();
      PVector seg = bodySegments.get(i);
      float segSize = map(i, 0, bodySegments.size() - 1, size * 0.5, size * 0.8);
      
      // Convert to local coordinates
      PVector local = PVector.sub(seg, position);
      local.rotate(-angle);
      
      translate(local.x, local.y);
      ellipse(0, 0, segSize * 1.2, segSize * 0.9);
      popMatrix();
    }
    
    // Draw main body
    fill(creatureColor);
    ellipse(0, 0, size * 1.8, size);
    
    // Draw head
    ellipse(size * 0.8, 0, size * 1.2, size * 0.9);
    
    // Draw eye
    fill(0);
    ellipse(size * 1.1, -size * 0.2, 4, 4);
    
    // Draw tail with oscillation
    stroke(creatureColor);
    strokeWeight(2);
    noFill();
    
    float tailAngle = tail.getAngle();
    float tailX = -size * 1.2;
    float tailY = sin(tailAngle) * tail.amplitude;
    
    // Tail fin
    beginShape();
    vertex(tailX, 0);
    vertex(tailX - size * 0.8, tailY - size * 0.5);
    vertex(tailX - size * 1.2, tailY);
    vertex(tailX - size * 0.8, tailY + size * 0.5);
    vertex(tailX, 0);
    endShape();
    
    // Draw dorsal fin
    noStroke();
    fill(creatureColor, 180);
    triangle(-size * 0.3, -size * 0.5, 
             size * 0.2, -size * 0.8, 
             size * 0.5, -size * 0.5);
    
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
    FishCreature baby = new FishCreature(position.x + random(-20, 20), position.y + random(-20, 20));
    
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
