class Predator extends Creature {
  Creature target;
  float huntRadius;
  float attackDamage;
  Oscillator jaw;

// <-- MUST be declared here at the top

  Predator(float x, float y) {
    super(x, y);
    // ... initialization ...
  }

  void applyBehaviors(ArrayList<Creature> creatures, ArrayList<Food> food, ArrayList<Particle> particleList) {
    // ... behavior code ...
  }

  Creature findNearestPrey(ArrayList<Creature> creatures) {
    record = 1e30;  // reset for this search
    Creature nearest = null;
    for (Creature c : creatures) {
      if (c == this || c instanceof Predator) continue;
      float d = PVector.dist(position, c.position);
      if (d < record && d < huntRadius) {
        record = d;
        nearest = c;
      }
    }
    return nearest;
  }
  
  void tryAttack(Creature prey, ArrayList<Creature> creatures, ArrayList<Particle> particleList) {
    float d = PVector.dist(position, prey.position);
    if (d < eatRadius) {
      // Deal damage to prey
      prey.health -= attackDamage;
      
      // Gain health from successful attack
      health = min(health + attackDamage * 0.5, maxHealth);
      
      // Create attack particles
      for (int i = 0; i < 8; i++) {
        Particle p = new Particle(prey.position.copy(), random(TWO_PI));
        p.particleColor = color(255, 0, 0);
        particleList.add(p);
      }
      
      // If prey dies, gain extra health
      if (prey.isDead()) {
        health = min(health + 20, maxHealth);
        target = null;
      }
    }
  }
  
  void display() {
    pushMatrix();
    translate(position.x, position.y);
    
    // Rotate to face direction of movement
    float angle = velocity.heading();
    rotate(angle);
    
    // Draw body
    fill(creatureColor);
    noStroke();
    ellipse(0, 0, size * 2, size * 1.2);
    
    // Draw spiky back
    fill(creatureColor - 30);
    for (int i = -1; i <= 1; i++) {
      float spikeX = -size * 0.3 + i * size * 0.4;
      triangle(spikeX, -size * 0.6, 
               spikeX - size * 0.2, -size * 1.1,
               spikeX + size * 0.2, -size * 0.6);
    }
    
    // Draw head
    fill(creatureColor);
    ellipse(size * 0.8, 0, size * 1.3, size);
    
    // Draw eye (angry look)
    fill(255, 255, 0);
    ellipse(size * 1.1, -size * 0.2, 7, 7);
    fill(0);
    ellipse(size * 1.2, -size * 0.25, 4, 4);
    
    // Draw jaw with oscillation
    float jawAngle = jaw.getAngle() * jaw.amplitude;
    
    // Upper jaw
    stroke(creatureColor - 50);
    strokeWeight(3);
    noFill();
    arc(size * 1.2, 0, size * 0.8, size * 0.6, -0.3 - jawAngle, 0.3 - jawAngle);
    
    // Lower jaw
    arc(size * 1.2, 0, size * 0.8, size * 0.6, -0.3 + jawAngle, 0.3 + jawAngle);
    
    // Draw teeth
    stroke(255);
    strokeWeight(2);
    for (int i = 0; i < 4; i++) {
      float toothAngle = map(i, 0, 3, -0.2, 0.2);
      float tx = size * 1.2 + cos(toothAngle) * size * 0.4;
      float ty = sin(toothAngle) * size * 0.3;
      line(tx, ty - 3 - jawAngle * 10, tx, ty - jawAngle * 10);
      line(tx, ty + jawAngle * 10, tx, ty + 3 + jawAngle * 10);
    }
    
    // Draw tail
    noStroke();
    fill(creatureColor, 180);
    triangle(-size * 1.2, 0,
             -size * 1.8, -size * 0.5,
             -size * 1.8, size * 0.5);
    
    popMatrix();
    
    // Draw health bar
    drawHealthBar();
    
    // Draw hunt radius and target line
    if (showForces) {
      noFill();
      stroke(creatureColor, 50);
      strokeWeight(1);
      ellipse(position.x, position.y, huntRadius * 2, huntRadius * 2);
      
      if (target != null) {
        stroke(255, 0, 0, 150);
        strokeWeight(2);
        line(position.x, position.y, target.position.x, target.position.y);
      }
    }
  }
  
  Creature reproduce() {
    super.reproduce();
    
    // Create offspring with slight variation
    Predator baby = new Predator(position.x + random(-30, 30), position.y + random(-30, 30));
    
    // Inherit traits with mutation
    baby.size = size * random(0.85, 1.15);
    baby.maxSpeed = maxSpeed * random(0.9, 1.1);
    baby.attackDamage = attackDamage * random(0.9, 1.1);
    baby.creatureColor = color(
      red(creatureColor) + random(-15, 15),
      green(creatureColor) + random(-10, 10),
      blue(creatureColor) + random(-10, 10)
    );
    baby.health = 60; // Born with more health
    
    return baby;
  }
}
