// Base Creature class - abstract parent for all creature types
abstract class Creature {
  PVector position;
  PVector velocity;
  PVector acceleration;
  
  float health;
  float maxHealth;
  float size;
  float maxSpeed;
  float maxForce;
  float mass;
  
  float perceptionRadius;
  float eatRadius;
  
  int reproductionCooldown;
  float reproductionThreshold;
  float reproductionCost;
  
  color creatureColor;
  
  Creature(float x, float y) {
    position = new PVector(x, y);
    velocity = new PVector(random(-1, 1), random(-1, 1));
    acceleration = new PVector(0, 0);
        float record = 3.4028235e38; 
    maxHealth = 100;
    health = maxHealth;
    size = 15;
    maxSpeed = 3;
    maxForce = 0.3;
    mass = 1;
    
    perceptionRadius = 100;
    eatRadius = 20;
    
    reproductionCooldown = 0;
    reproductionThreshold = 80;
    reproductionCost = 40;
    
    creatureColor = color(100, 200, 100);
  }
  
  // Apply a force to the creature
  void applyForce(PVector force) {
    PVector f = force.copy();
    f.div(mass);
    acceleration.add(f);
  }
  
  // Main behavior logic - to be called each frame
  void applyBehaviors(ArrayList<Creature> creatures, ArrayList<Food> food, ArrayList<Particle> particleList) {
    // Metabolism - constant energy drain
    health -= 0.05;
    
    // Movement cost
    health -= velocity.mag() * 0.01;
    
    // Separation from other creatures
    PVector separate = separate(creatures);
    separate.mult(1.5);
    applyForce(separate);
    
    // Seek food
    PVector seek = seekFood(food);
    seek.mult(2.0);
    applyForce(seek);
    
    // Try to eat nearby food
    tryEat(food, particleList);
    
    // Wander if no food nearby
    if (seek.mag() < 0.1) {
      PVector wander = wander();
      wander.mult(0.5);
      applyForce(wander);
    }
    
    // Boundary avoidance
    PVector boundary = avoidBoundaries();
    boundary.mult(3.0);
    applyForce(boundary);
    
    // Reproduction cooldown
    if (reproductionCooldown > 0) {
      reproductionCooldown--;
    }
  }
  
  // Seek the nearest food
  PVector seekFood(ArrayList<Food> food) {
    Food nearest = null;
// very large float value

    
    for (Food f : food) {
      if (!f.consumed) {
        float d = PVector.dist(position, f.position);
        if (d < record && d < perceptionRadius) {
          record = d;
          nearest = f;
        }
      }
    }
    
    if (nearest != null) {
      return seek(nearest.position);
    }
    return new PVector(0, 0);
  }
  
  // Steering force towards a target
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);
    desired.normalize();
    desired.mult(maxSpeed);
    
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);
    return steer;
  }
  
  // Steering force away from a target
  PVector flee(PVector target) {
    PVector desired = PVector.sub(position, target);
    desired.normalize();
    desired.mult(maxSpeed);
    
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);
    return steer;
  }
  
  // Separation - avoid crowding neighbors
  PVector separate(ArrayList<Creature> creatures) {
    float desiredSeparation = size * 3;
    PVector steer = new PVector(0, 0);
    int count = 0;
    
    for (Creature other : creatures) {
      float d = PVector.dist(position, other.position);
      if (d > 0 && d < desiredSeparation) {
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d); // Weight by distance
        steer.add(diff);
        count++;
      }
    }
    
    if (count > 0) {
      steer.div(count);
      steer.normalize();
      steer.mult(maxSpeed);
      steer.sub(velocity);
      steer.limit(maxForce);
    }
    return steer;
  }
  
  // Random wandering behavior
  PVector wander() {
    float wanderRadius = 1;
    float wanderDistance = 2;
    float wanderAngle = random(-0.5, 0.5);
    
    PVector circlePos = velocity.copy();
    circlePos.normalize();
    circlePos.mult(wanderDistance);
    
    PVector circleOffset = new PVector(wanderRadius, 0);
    circleOffset.rotate(wanderAngle);
    
    PVector target = PVector.add(circlePos, circleOffset);
    target.normalize();
    target.mult(maxSpeed);
    
    PVector steer = PVector.sub(target, velocity);
    steer.limit(maxForce * 0.5);
    return steer;
  }
  
  // Avoid screen boundaries
  PVector avoidBoundaries() {
    PVector steer = new PVector(0, 0);
    float margin = 50;
    
    if (position.x < margin) {
      steer.x = maxSpeed;
    } else if (position.x > width - margin) {
      steer.x = -maxSpeed;
    }
    
    if (position.y < margin) {
      steer.y = maxSpeed;
    } else if (position.y > height - margin) {
      steer.y = -maxSpeed;
    }
    
    if (steer.mag() > 0) {
      steer.normalize();
      steer.mult(maxSpeed);
      steer.sub(velocity);
      steer.limit(maxForce);
    }
    
    return steer;
  }
  
  // Try to eat nearby food
  void tryEat(ArrayList<Food> food, ArrayList<Particle> particleList) {
    for (Food f : food) {
      if (!f.consumed) {
        float d = PVector.dist(position, f.position);
        if (d < eatRadius) {
          f.consume();
          health = min(health + f.nutritionValue, maxHealth);
          
          // Create eating particles
          for (int i = 0; i < 5; i++) {
            particleList.add(new Particle(f.position.copy(), random(TWO_PI)));
          }
          break;
        }
      }
    }
  }
  
  // Update physics
  void update() {
    // Update velocity and position
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    
    // Reset acceleration
    acceleration.mult(0);
    
    // Wrap around edges (backup)
    if (position.x < 0) position.x = width;
    if (position.x > width) position.x = 0;
    if (position.y < 0) position.y = height;
    if (position.y > height) position.y = 0;
  }
  
  // Check if can reproduce
  boolean canReproduce() {
    return health > reproductionThreshold && reproductionCooldown == 0;
  }
  
  // Create offspring
  Creature reproduce() {
    health -= reproductionCost;
    reproductionCooldown = 300; // 5 seconds at 60fps
    return null; // Subclasses override this
  }
  
  // Check if dead
  boolean isDead() {
    return health <= 0;
  }
  
  // Display the creature - subclasses override
  abstract void display();
  
  // Draw health bar
  void drawHealthBar() {
    float barWidth = size * 2;
    float barHeight = 4;
    float healthPercent = health / maxHealth;
    
    // Background
    fill(100, 50);
    noStroke();
    rect(position.x - barWidth/2, position.y - size - 10, barWidth, barHeight);
    
    // Health
    if (healthPercent > 0.5) fill(0, 255, 0);
    else if (healthPercent > 0.25) fill(255, 200, 0);
    else fill(255, 0, 0);
    rect(position.x - barWidth/2, position.y - size - 10, barWidth * healthPercent, barHeight);
  }
}
