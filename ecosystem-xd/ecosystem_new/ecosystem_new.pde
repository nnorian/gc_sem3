/**
 * Interactive Ecosystem Simulation
 * 
 * Features:
 * - Forces: attraction, repulsion, drag, steering behaviors
 * - Environment: Food, Predators, Obstacles (SOLID - block movement)
 * - OSCILLATING BODIES: Caterpillar with segmented body that undulates to move
 * - OOP: Creature base class with Caterpillar and Bird subclasses
 * - Health, lifecycle, reproduction, death
 * - Particle systems attached to creatures
 * - Genetic variation on spawn
 * - UI controls
 */

// ==================== GLOBAL VARIABLES ====================
ArrayList<Creature> creatures;
ArrayList<Food> foods;
ArrayList<Obstacle> obstacles;
ArrayList<Predator> predators;
ParticleSystem globalParticles;

// Environment settings
float dragCoefficient = 0.02;
float globalTime = 0;

// UI state
boolean showForces = false;
boolean showHealth = true;
boolean paused = false;

// Spawn settings
int maxCreatures = 40;
int maxFood = 30;
int maxPredators = 2;

void setup() {
  size(1200, 800);
  
  // Initialize collections
  creatures = new ArrayList<Creature>();
  foods = new ArrayList<Food>();
  obstacles = new ArrayList<Obstacle>();
  predators = new ArrayList<Predator>();
  globalParticles = new ParticleSystem(new PVector(0, 0));
  
  // Create initial creatures - mix of caterpillars and birds
  for (int i = 0; i < 8; i++) {
    creatures.add(new Caterpillar(random(100, width-100), random(100, height-100)));
  }
  for (int i = 0; i < 6; i++) {
    creatures.add(new Bird(random(100, width-100), random(100, height-100)));
  }
  
  // Create initial food
  for (int i = 0; i < 20; i++) {
    foods.add(new Food(random(50, width-50), random(50, height-50)));
  }
  
  // Create obstacles - these are SOLID barriers
  obstacles.add(new Obstacle(300, 300, 70));
  obstacles.add(new Obstacle(750, 450, 90));
  obstacles.add(new Obstacle(500, 180, 55));
  obstacles.add(new Obstacle(900, 250, 60));
  obstacles.add(new Obstacle(200, 550, 65));
  
  // Create predators
  for (int i = 0; i < 2; i++) {
    predators.add(new Predator(random(width), random(height)));
  }
}

void draw() {
  // Draw gradient background
  drawBackground();
  
  if (!paused) {
    globalTime += 0.016;
    
    // Draw obstacles first (they're in background)
    for (Obstacle obs : obstacles) {
      obs.display();
    }
    
    // Update and draw food
    for (int i = foods.size() - 1; i >= 0; i--) {
      Food f = foods.get(i);
      f.update();
      f.display();
      if (f.isConsumed) {
        foods.remove(i);
      }
    }
    
    // Update and draw predators
    for (Predator p : predators) {
      p.update(creatures);
      // Predators also collide with obstacles
      for (Obstacle obs : obstacles) {
        obs.collideWith(p.position, p.velocity, 20);
      }
      p.display();
    }
    
    // Update creatures with all forces
    ArrayList<Creature> newCreatures = new ArrayList<Creature>();
    
    for (int i = creatures.size() - 1; i >= 0; i--) {
      Creature c = creatures.get(i);
      
      // Apply environmental forces
      applyEnvironmentalForces(c);
      
      // Update creature
      c.update();
      
      // SOLID OBSTACLE COLLISION - push creatures out
      for (Obstacle obs : obstacles) {
        obs.collideWith(c.position, c.velocity, c.size/2);
      }
      
      c.display();
      
      // Check for reproduction
      Creature baby = c.tryReproduce();
      if (baby != null && creatures.size() < maxCreatures) {
        newCreatures.add(baby);
      }
      
      // Remove dead creatures
      if (c.isDead()) {
        // Death particles
        for (int j = 0; j < 20; j++) {
          globalParticles.addParticle(c.position.copy(), c.getColor());
        }
        creatures.remove(i);
      }
    }
    
    // Add new creatures
    creatures.addAll(newCreatures);
    
    // Update global particles
    globalParticles.update();
    globalParticles.display();
    
    // Respawn food occasionally
    if (random(1) < 0.02 && foods.size() < maxFood) {
      // Make sure food doesn't spawn inside obstacles
      float fx, fy;
      boolean validPos;
      do {
        fx = random(50, width-50);
        fy = random(50, height-50);
        validPos = true;
        for (Obstacle obs : obstacles) {
          if (PVector.dist(new PVector(fx, fy), obs.position) < obs.radius + 20) {
            validPos = false;
            break;
          }
        }
      } while (!validPos);
      foods.add(new Food(fx, fy));
    }
  }
  
  // Draw UI
  drawUI();
}

void drawBackground() {
  // Gradient background - forest/meadow theme
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    color c = lerpColor(color(180, 220, 255), color(100, 180, 100), inter);
    stroke(c);
    line(0, y, width, y);
  }
  
  // Ground texture
  noStroke();
  for (int i = 0; i < 100; i++) {
    float x = random(width);
    float y = random(height * 0.6, height);
    fill(80, 140, 60, random(20, 50));
    ellipse(x, y, random(3, 8), random(2, 5));
  }
}

void applyEnvironmentalForces(Creature c) {
  // 1. Drag force
  PVector drag = c.velocity.copy();
  float speed = drag.mag();
  drag.normalize();
  drag.mult(-1 * dragCoefficient * speed * speed);
  c.applyForce(drag);
  
  // 2. Food attraction
  Food nearestFood = null;
  float nearestFoodDist = Float.MAX_VALUE;
  for (Food f : foods) {
    if (!f.isConsumed) {
      float d = PVector.dist(c.position, f.position);
      if (d < nearestFoodDist && d < c.senseRadius) {
        nearestFoodDist = d;
        nearestFood = f;
      }
    }
  }
  
  if (nearestFood != null) {
    PVector steer = seek(c, nearestFood.position);
    steer.mult(c.foodAttraction);
    c.applyForce(steer);
    
    // Eat if close enough
    if (nearestFoodDist < c.size + nearestFood.size) {
      c.eat(nearestFood);
    }
  }
  
  // 3. Predator avoidance
  for (Predator p : predators) {
    float d = PVector.dist(c.position, p.position);
    if (d < c.senseRadius * 1.5) {
      PVector flee = seek(c, p.position);
      flee.mult(-2.0); // Strong flee response
      c.applyForce(flee);
    }
  }
  
  // 4. Obstacle avoidance (steering away, collision handled separately)
  for (Obstacle obs : obstacles) {
    float d = PVector.dist(c.position, obs.position);
    float avoidDist = obs.radius + c.senseRadius * 0.3;
    if (d < avoidDist) {
      PVector repel = PVector.sub(c.position, obs.position);
      repel.normalize();
      float strength = map(d, 0, avoidDist, 3.0, 0);
      repel.mult(strength);
      c.applyForce(repel);
    }
  }
  
  // 5. Separation from other creatures
  for (Creature other : creatures) {
    if (other != c) {
      float d = PVector.dist(c.position, other.position);
      if (d < c.size * 2.5) {
        PVector sep = PVector.sub(c.position, other.position);
        sep.normalize();
        sep.mult(30 / (d + 1));
        c.applyForce(sep);
      }
    }
  }
  
  // 6. Boundary forces (soft walls)
  float margin = 50;
  PVector boundary = new PVector(0, 0);
  if (c.position.x < margin) boundary.x = (margin - c.position.x) * 0.3;
  if (c.position.x > width - margin) boundary.x = ((width - margin) - c.position.x) * 0.3;
  if (c.position.y < margin) boundary.y = (margin - c.position.y) * 0.3;
  if (c.position.y > height - margin) boundary.y = ((height - margin) - c.position.y) * 0.3;
  c.applyForce(boundary);
}

PVector seek(Creature c, PVector target) {
  PVector desired = PVector.sub(target, c.position);
  desired.normalize();
  desired.mult(c.maxSpeed);
  PVector steer = PVector.sub(desired, c.velocity);
  steer.limit(c.maxForce);
  return steer;
}

void drawUI() {
  // UI Panel
  fill(0, 0, 0, 180);
  noStroke();
  rect(10, 10, 280, 250, 10);
  
  fill(255);
  textSize(18);
  textAlign(LEFT, TOP);
  text("ECOSYSTEM SIMULATION", 20, 18);
  
  textSize(13);
  int caterpillarCount = 0;
  int birdCount = 0;
  for (Creature c : creatures) {
    if (c instanceof Caterpillar) caterpillarCount++;
    else if (c instanceof Bird) birdCount++;
  }
  
  fill(150, 255, 150);
  text("Caterpillars: " + caterpillarCount, 20, 50);
  fill(255, 200, 100);
  text("Birds: " + birdCount, 20, 70);
  fill(100, 255, 100);
  text("Food: " + foods.size(), 20, 90);
  fill(255, 100, 100);
  text("Predators: " + predators.size(), 20, 110);
  
  fill(200);
  text("Controls:", 20, 140);
  fill(255);
  textSize(11);
  text("SPACE - Pause/Resume", 20, 158);
  text("F - Spawn Food at cursor", 20, 173);
  text("C - Spawn Caterpillar at cursor", 20, 188);
  text("B - Spawn Bird at cursor", 20, 203);
  text("H - Toggle Health Bars", 20, 218);
  text("Click - Spawn food cluster", 20, 233);
  
  // Legend
  fill(0, 0, 0, 180);
  rect(width - 200, 10, 190, 150, 10);
  
  fill(255);
  textSize(14);
  text("Legend:", width - 190, 20);
  
  textSize(11);
  // Caterpillar indicator
  fill(100, 200, 100);
  ellipse(width - 180, 50, 12, 8);
  fill(255);
  text("Caterpillar (oscillates!)", width - 165, 45);
  
  // Bird indicator
  fill(255, 180, 80);
  ellipse(width - 180, 70, 10, 10);
  fill(255);
  text("Bird", width - 165, 65);
  
  // Food indicator
  fill(100, 255, 100);
  ellipse(width - 180, 90, 8, 8);
  fill(255);
  text("Food", width - 165, 85);
  
  // Predator indicator
  fill(255, 50, 50);
  ellipse(width - 180, 110, 12, 12);
  fill(255);
  text("Predator", width - 165, 105);
  
  // Obstacle indicator
  fill(120, 90, 60);
  ellipse(width - 180, 130, 14, 14);
  fill(255);
  text("Obstacle (SOLID)", width - 165, 125);
  
  if (paused) {
    fill(255, 255, 0);
    textSize(36);
    textAlign(CENTER, CENTER);
    text("PAUSED", width/2, height/2);
  }
}

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  }
  if (key == 'f' || key == 'F') {
    // Check not inside obstacle
    boolean valid = true;
    for (Obstacle obs : obstacles) {
      if (PVector.dist(new PVector(mouseX, mouseY), obs.position) < obs.radius + 15) {
        valid = false;
        break;
      }
    }
    if (valid) foods.add(new Food(mouseX, mouseY));
  }
  if (key == 'c' || key == 'C') {
    boolean valid = true;
    for (Obstacle obs : obstacles) {
      if (PVector.dist(new PVector(mouseX, mouseY), obs.position) < obs.radius + 30) {
        valid = false;
        break;
      }
    }
    if (valid) creatures.add(new Caterpillar(mouseX, mouseY));
  }
  if (key == 'b' || key == 'B') {
    boolean valid = true;
    for (Obstacle obs : obstacles) {
      if (PVector.dist(new PVector(mouseX, mouseY), obs.position) < obs.radius + 20) {
        valid = false;
        break;
      }
    }
    if (valid) creatures.add(new Bird(mouseX, mouseY));
  }
  if (key == 'h' || key == 'H') {
    showHealth = !showHealth;
  }
}

void mousePressed() {
  // Spawn food cluster on click
  if (mouseButton == LEFT) {
    for (int i = 0; i < 5; i++) {
      float fx = mouseX + random(-30, 30);
      float fy = mouseY + random(-30, 30);
      boolean valid = true;
      for (Obstacle obs : obstacles) {
        if (PVector.dist(new PVector(fx, fy), obs.position) < obs.radius + 15) {
          valid = false;
          break;
        }
      }
      if (valid) foods.add(new Food(fx, fy));
    }
  }
}

// ==================== PARTICLE SYSTEM ====================
class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  color col;
  float size;
  
  Particle(PVector pos, color c) {
    position = pos.copy();
    velocity = PVector.random2D().mult(random(1, 3));
    acceleration = new PVector(0, 0.05);
    lifespan = 255;
    col = c;
    size = random(3, 8);
  }
  
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 4;
    size *= 0.98;
  }
  
  void display() {
    noStroke();
    fill(col, lifespan);
    ellipse(position.x, position.y, size, size);
  }
  
  boolean isDead() {
    return lifespan < 0;
  }
}

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;
  
  ParticleSystem(PVector origin) {
    this.origin = origin.copy();
    particles = new ArrayList<Particle>();
  }
  
  void addParticle(PVector pos, color c) {
    particles.add(new Particle(pos, c));
  }
  
  void update() {
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
  
  void display() {
    for (Particle p : particles) {
      p.display();
    }
  }
}

// ==================== FOOD ====================
class Food {
  PVector position;
  float size;
  float nutrition;
  boolean isConsumed;
  float pulsePhase;
  color col;
  
  Food(float x, float y) {
    position = new PVector(x, y);
    size = random(8, 15);
    nutrition = map(size, 8, 15, 15, 35);
    isConsumed = false;
    pulsePhase = random(TWO_PI);
    
    // Different food colors (leaves/berries)
    float r = random(1);
    if (r < 0.5) {
      col = color(80, 180, 80); // Leaf green
    } else if (r < 0.8) {
      col = color(200, 80, 100); // Berry red
    } else {
      col = color(255, 200, 50); // Flower yellow
    }
  }
  
  void update() {
    pulsePhase += 0.08;
  }
  
  void display() {
    if (!isConsumed) {
      float pulse = sin(pulsePhase) * 2;
      
      // Glow effect
      noStroke();
      for (int i = 3; i > 0; i--) {
        fill(col, 40);
        ellipse(position.x, position.y, size + pulse + i * 4, size + pulse + i * 4);
      }
      
      // Main body
      fill(col);
      ellipse(position.x, position.y, size + pulse, size + pulse);
      
      // Highlight
      fill(255, 180);
      ellipse(position.x - 2, position.y - 2, size * 0.3, size * 0.3);
    }
  }
  
  void consume() {
    isConsumed = true;
  }
}

// ==================== OBSTACLE (SOLID) ====================
class Obstacle {
  PVector position;
  float radius;
  color col;
  
  Obstacle(float x, float y, float r) {
    position = new PVector(x, y);
    radius = r;
    col = color(100, 80, 60);
  }
  
  // SOLID COLLISION - actually stops and pushes out entities
  void collideWith(PVector pos, PVector vel, float entityRadius) {
    float dist = PVector.dist(pos, position);
    float minDist = radius + entityRadius;
    
    if (dist < minDist) {
      // Push the entity out
      PVector pushDir = PVector.sub(pos, position);
      pushDir.normalize();
      
      // Move position outside the obstacle
      pos.x = position.x + pushDir.x * minDist;
      pos.y = position.y + pushDir.y * minDist;
      
      // Reflect velocity (bounce off)
      // Calculate the component of velocity toward the obstacle
      float dotProduct = vel.dot(pushDir);
      if (dotProduct < 0) {
        // Only reflect if moving toward the obstacle
        PVector reflection = PVector.mult(pushDir, -2 * dotProduct);
        vel.add(reflection);
        vel.mult(0.5); // Dampen the bounce
      }
    }
  }
  
  void display() {
    // Shadow
    noStroke();
    fill(0, 60);
    ellipse(position.x + 6, position.y + 6, radius * 2.1, radius * 2.1);
    
    // Main rock body
    fill(col);
    ellipse(position.x, position.y, radius * 2, radius * 2);
    
    // Rock texture - darker patches
    fill(80, 60, 40);
    ellipse(position.x - radius * 0.35, position.y + radius * 0.25, radius * 0.5, radius * 0.4);
    ellipse(position.x + radius * 0.4, position.y - radius * 0.2, radius * 0.35, radius * 0.25);
    ellipse(position.x + radius * 0.1, position.y + radius * 0.4, radius * 0.3, radius * 0.25);
    
    // Highlight
    fill(140, 120, 100);
    ellipse(position.x - radius * 0.25, position.y - radius * 0.35, radius * 0.6, radius * 0.45);
    
    // Moss patches
    fill(70, 120, 50, 150);
    ellipse(position.x - radius * 0.5, position.y, radius * 0.3, radius * 0.2);
    ellipse(position.x + radius * 0.3, position.y + radius * 0.45, radius * 0.25, radius * 0.15);
  }
}

// ==================== PREDATOR ====================
class Predator {
  PVector position;
  PVector velocity;
  float size;
  float maxSpeed;
  float phase;
  
  Predator(float x, float y) {
    position = new PVector(x, y);
    velocity = PVector.random2D().mult(1);
    size = 45;
    maxSpeed = 2.8;
    phase = random(TWO_PI);
  }
  
  void update(ArrayList<Creature> creatures) {
    phase += 0.12;
    
    // Hunt nearest creature
    Creature target = null;
    float minDist = Float.MAX_VALUE;
    
    for (Creature c : creatures) {
      float d = PVector.dist(position, c.position);
      if (d < minDist && d < 280) {
        minDist = d;
        target = c;
      }
    }
    
    if (target != null) {
      // Steering towards target
      PVector desired = PVector.sub(target.position, position);
      desired.normalize();
      desired.mult(maxSpeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(0.12);
      velocity.add(steer);
      
      // Attack if close
      if (minDist < size/2 + target.size/2) {
        target.health -= 45;
      }
    } else {
      // Wander
      velocity.rotate(random(-0.08, 0.08));
    }
    
    velocity.limit(maxSpeed);
    position.add(velocity);
    
    // Soft boundary wrapping
    float margin = 30;
    if (position.x < margin) velocity.x += 0.2;
    if (position.x > width - margin) velocity.x -= 0.2;
    if (position.y < margin) velocity.y += 0.2;
    if (position.y > height - margin) velocity.y -= 0.2;
    
    position.x = constrain(position.x, 10, width - 10);
    position.y = constrain(position.y, 10, height - 10);
  }
  
  void display() {
    pushMatrix();
    translate(position.x, position.y);
    rotate(velocity.heading());
    
    // Body - wasp/hornet like
    noStroke();
    
    // Abdomen with stripes
    for (int i = 0; i < 4; i++) {
      if (i % 2 == 0) fill(40, 30, 20);
      else fill(255, 200, 0);
      ellipse(-size * 0.15 - i * size * 0.12, 0, size * 0.35, size * 0.28 - i * 0.02);
    }
    
    // Thorax
    fill(60, 40, 20);
    ellipse(size * 0.1, 0, size * 0.4, size * 0.32);
    
    // Head
    fill(50, 35, 20);
    ellipse(size * 0.35, 0, size * 0.28, size * 0.24);
    
    // Stinger
    fill(30, 20, 10);
    triangle(-size * 0.55, 0, -size * 0.7, -size * 0.03, -size * 0.7, size * 0.03);
    
    // Wings (oscillating)
    float wingAngle = sin(phase) * 0.6;
    fill(200, 200, 220, 120);
    stroke(150, 150, 170, 100);
    strokeWeight(1);
    
    pushMatrix();
    rotate(-wingAngle - 0.3);
    ellipse(0, -size * 0.25, size * 0.5, size * 0.15);
    popMatrix();
    
    pushMatrix();
    rotate(wingAngle + 0.3);
    ellipse(0, size * 0.25, size * 0.5, size * 0.15);
    popMatrix();
    
    // Eyes
    noStroke();
    fill(180, 0, 0);
    ellipse(size * 0.42, -size * 0.06, size * 0.12, size * 0.1);
    ellipse(size * 0.42, size * 0.06, size * 0.12, size * 0.1);
    
    // Mandibles
    fill(80, 50, 30);
    triangle(size * 0.48, -size * 0.02, size * 0.55, -size * 0.08, size * 0.52, 0);
    triangle(size * 0.48, size * 0.02, size * 0.55, size * 0.08, size * 0.52, 0);
    
    popMatrix();
  }
}

// ==================== CREATURE BASE CLASS ====================
abstract class Creature {
  PVector position;
  PVector velocity;
  PVector acceleration;
  
  // Physical properties
  float size;
  float mass;
  float maxSpeed;
  float maxForce;
  
  // Behavior
  float senseRadius;
  float foodAttraction;
  
  // Health and lifecycle
  float health;
  float maxHealth;
  float metabolicRate;
  float reproductionThreshold;
  float reproductionCost;
  float reproductionCooldown;
  float lastReproduction;
  
  // Genetics
  color baseColor;
  float speedGene;
  float sizeGene;
  
  // Particle system
  ParticleSystem particles;
  
  // Oscillation parameters
  float oscillationPhase;
  float oscillationSpeed;
  float oscillationAmplitude;
  
  Creature(float x, float y) {
    position = new PVector(x, y);
    velocity = PVector.random2D().mult(random(0.5, 1.5));
    acceleration = new PVector(0, 0);
    
    oscillationPhase = random(TWO_PI);
    oscillationSpeed = 0.15;
    oscillationAmplitude = 1.0;
    
    particles = new ParticleSystem(position);
    
    speedGene = random(0.8, 1.2);
    sizeGene = random(0.8, 1.2);
  }
  
  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }
  
  void update() {
    // Physics
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    acceleration.mult(0);
    
    // Oscillation tied to speed
    float speed = velocity.mag();
    oscillationPhase += oscillationSpeed * (0.5 + speed * 0.8);
    oscillationAmplitude = map(speed, 0, maxSpeed, 0.3, 1.5);
    
    // Metabolism
    health -= metabolicRate;
    health -= speed * metabolicRate * 0.3;
    
    // Update particle system
    updateParticles();
    
    // Reproduction cooldown
    if (lastReproduction > 0) {
      lastReproduction -= 1;
    }
    
    // Keep in bounds
    position.x = constrain(position.x, 20, width - 20);
    position.y = constrain(position.y, 20, height - 20);
  }
  
  abstract void display();
  abstract void updateParticles();
  abstract color getColor();
  abstract Creature createOffspring(float x, float y);
  
  void eat(Food food) {
    health += food.nutrition;
    health = constrain(health, 0, maxHealth);
    food.consume();
    
    for (int i = 0; i < 8; i++) {
      particles.addParticle(position.copy(), food.col);
    }
  }
  
  boolean isDead() {
    return health <= 0;
  }
  
  Creature tryReproduce() {
    if (health > reproductionThreshold && lastReproduction <= 0) {
      health -= reproductionCost;
      lastReproduction = reproductionCooldown;
      
      float angle = random(TWO_PI);
      float dist = size * 2;
      float bx = position.x + cos(angle) * dist;
      float by = position.y + sin(angle) * dist;
      
      // Birth particles
      for (int i = 0; i < 15; i++) {
        particles.addParticle(new PVector(bx, by), getColor());
      }
      
      return createOffspring(bx, by);
    }
    return null;
  }
  
  void drawHealthBar() {
    if (showHealth) {
      float barWidth = size * 1.2;
      float barHeight = 4;
      float healthPercent = health / maxHealth;
      
      // Background
      fill(30);
      noStroke();
      rect(position.x - barWidth/2, position.y - size - 12, barWidth, barHeight, 2);
      
      // Health bar
      color healthColor = lerpColor(color(255, 50, 50), color(50, 255, 50), healthPercent);
      fill(healthColor);
      rect(position.x - barWidth/2, position.y - size - 12, barWidth * healthPercent, barHeight, 2);
    }
  }
}

// ==================== CATERPILLAR - OSCILLATING BODY ====================
/**
 * The Caterpillar has a segmented body that OSCILLATES to create locomotion.
 * Each segment follows the one ahead with a phase delay, creating a wave
 * that travels down the body. The wave amplitude and speed are tied to
 * the creature's velocity - faster movement = faster, larger waves.
 * 
 * This demonstrates:
 * - Oscillator centered on a moving point (each segment oscillates around its target)
 * - Oscillation speed/amplitude tied to motion
 * - Internal oscillation driving/influencing locomotion visually
 */
class Caterpillar extends Creature {
  int numSegments;
  PVector[] segments;      // Position of each segment
  float[] segmentPhases;   // Phase offset for each segment
  float segmentRadius;
  color bodyColor;
  color spotColor;
  
  Caterpillar(float x, float y) {
    super(x, y);
    
    // Caterpillar properties
    numSegments = 8;
    size = 12 * sizeGene;
    segmentRadius = size * 0.45;
    mass = 0.8 * sizeGene;
    maxSpeed = 2.0 * speedGene;
    maxForce = 0.15;
    
    senseRadius = 140;
    foodAttraction = 1.8;
    
    health = 100;
    maxHealth = 100;
    metabolicRate = 0.05;
    reproductionThreshold = 85;
    reproductionCost = 35;
    reproductionCooldown = 350;
    lastReproduction = random(100, 350);
    
    oscillationSpeed = 0.25;
    
    // Initialize segments behind the head
    segments = new PVector[numSegments];
    segmentPhases = new float[numSegments];
    for (int i = 0; i < numSegments; i++) {
      segments[i] = new PVector(x - i * segmentRadius * 1.5, y);
      segmentPhases[i] = i * 0.5; // Phase delay creates traveling wave
    }
    
    // Colors with genetic variation
    bodyColor = color(
      80 + random(-20, 40),
      180 + random(-30, 40),
      80 + random(-20, 30)
    );
    spotColor = color(
      200 + random(-30, 55),
      180 + random(-30, 30),
      50 + random(-20, 30)
    );
    baseColor = bodyColor;
  }
  
  // Constructor for offspring
  Caterpillar(float x, float y, Caterpillar parent) {
    this(x, y);
    
    // Inherit and mutate genes
    this.speedGene = constrain(parent.speedGene + random(-0.1, 0.1), 0.6, 1.4);
    this.sizeGene = constrain(parent.sizeGene + random(-0.1, 0.1), 0.6, 1.4);
    
    this.size = 12 * sizeGene;
    this.segmentRadius = size * 0.45;
    this.mass = 0.8 * sizeGene;
    this.maxSpeed = 2.0 * speedGene;
    
    // Inherit colors with mutation
    this.bodyColor = mutateColor(parent.bodyColor);
    this.spotColor = mutateColor(parent.spotColor);
  }
  
  color mutateColor(color c) {
    return color(
      constrain(red(c) + random(-15, 15), 0, 255),
      constrain(green(c) + random(-15, 15), 0, 255),
      constrain(blue(c) + random(-15, 15), 0, 255)
    );
  }
  
  void update() {
    super.update();
    
    // Update segment positions - THIS IS THE OSCILLATION!
    // Head segment follows the actual position
    segments[0] = position.copy();
    
    // Each subsequent segment follows the one ahead with oscillation
    float speed = velocity.mag();
    
    for (int i = 1; i < numSegments; i++) {
      PVector target = segments[i - 1];
      PVector dir = PVector.sub(target, segments[i]);
      float dist = dir.mag();
      
      // Calculate oscillation perpendicular to movement direction
      // The wave amplitude and frequency scale with speed
      float wavePhase = oscillationPhase - segmentPhases[i];
      float waveAmount = sin(wavePhase) * oscillationAmplitude * segmentRadius * 0.6;
      
      // Get perpendicular direction for the wave
      PVector perp = new PVector(-dir.y, dir.x);
      perp.normalize();
      
      // Move segment toward target position
      if (dist > segmentRadius * 0.8) {
        dir.normalize();
        // Base position: follow the segment ahead
        PVector newPos = PVector.add(target, PVector.mult(dir, -segmentRadius * 1.2));
        // Add perpendicular oscillation (the wave!)
        newPos.add(PVector.mult(perp, waveAmount));
        
        // Smooth interpolation
        segments[i].lerp(newPos, 0.4);
      } else {
        // Still apply oscillation even when close
        PVector oscillationOffset = PVector.mult(perp, waveAmount);
        segments[i].add(PVector.mult(oscillationOffset, 0.1));
      }
    }
  }
  
  void display() {
    particles.display();
    
    float speed = velocity.mag();
    
    // Draw segments from tail to head (so head is on top)
    for (int i = numSegments - 1; i >= 0; i--) {
      PVector seg = segments[i];
      
      // Segment size varies (larger in middle)
      float sizeMult = 1.0 - abs(i - numSegments * 0.4) / (numSegments * 0.8);
      sizeMult = constrain(sizeMult, 0.6, 1.0);
      float r = segmentRadius * sizeMult;
      
      // Segment "breathing" - subtle size oscillation
      float breathe = sin(oscillationPhase * 0.5 + i * 0.3) * r * 0.1;
      
      // Shadow
      noStroke();
      fill(0, 40);
      ellipse(seg.x + 2, seg.y + 3, r * 2 + breathe, r * 1.6 + breathe);
      
      // Main segment body
      fill(bodyColor);
      ellipse(seg.x, seg.y, r * 2 + breathe, r * 1.7 + breathe);
      
      // Spots/markings
      fill(spotColor);
      ellipse(seg.x, seg.y - r * 0.3, r * 0.5, r * 0.4);
      
      // Segment line detail
      stroke(red(bodyColor) - 30, green(bodyColor) - 30, blue(bodyColor) - 30);
      strokeWeight(1);
      noFill();
      arc(seg.x, seg.y, r * 1.6, r * 1.2, PI * 0.2, PI * 0.8);
    }
    
    // Draw head details
    PVector head = segments[0];
    float headAngle = velocity.heading();
    
    pushMatrix();
    translate(head.x, head.y);
    rotate(headAngle);
    
    // Antennae - they oscillate!
    float antennaWave = sin(oscillationPhase * 1.5) * 0.3 * oscillationAmplitude;
    stroke(80, 60, 40);
    strokeWeight(2);
    
    // Left antenna
    float la = -0.4 + antennaWave;
    line(segmentRadius * 0.5, -segmentRadius * 0.3, 
         segmentRadius * 1.2, -segmentRadius * 0.8 + sin(la) * segmentRadius * 0.3);
    // Right antenna  
    float ra = -0.4 - antennaWave;
    line(segmentRadius * 0.5, segmentRadius * 0.3,
         segmentRadius * 1.2, segmentRadius * 0.8 + sin(ra) * segmentRadius * 0.3);
    
    // Antenna tips
    noStroke();
    fill(spotColor);
    ellipse(segmentRadius * 1.2, -segmentRadius * 0.8 + sin(la) * segmentRadius * 0.3, 5, 5);
    ellipse(segmentRadius * 1.2, segmentRadius * 0.8 + sin(ra) * segmentRadius * 0.3, 5, 5);
    
    // Eyes
    fill(30);
    ellipse(segmentRadius * 0.4, -segmentRadius * 0.25, segmentRadius * 0.35, segmentRadius * 0.35);
    ellipse(segmentRadius * 0.4, segmentRadius * 0.25, segmentRadius * 0.35, segmentRadius * 0.35);
    
    // Eye shine
    fill(255);
    ellipse(segmentRadius * 0.45, -segmentRadius * 0.2, segmentRadius * 0.12, segmentRadius * 0.12);
    ellipse(segmentRadius * 0.45, segmentRadius * 0.3, segmentRadius * 0.12, segmentRadius * 0.12);
    
    // Little legs on segments (they wiggle!)
    popMatrix();
    
    // Draw tiny legs on middle segments
    for (int i = 1; i < numSegments - 1; i++) {
      PVector seg = segments[i];
      PVector nextSeg = (i > 0) ? segments[i-1] : seg;
      float segAngle = atan2(nextSeg.y - seg.y, nextSeg.x - seg.x);
      
      // Leg wiggle phase
      float legPhase = oscillationPhase * 2 + i * 0.8;
      float legWiggle = sin(legPhase) * 0.4 * oscillationAmplitude;
      
      pushMatrix();
      translate(seg.x, seg.y);
      rotate(segAngle);
      
      stroke(60, 50, 40);
      strokeWeight(1.5);
      
      // Left legs
      float ll = PI/2 + 0.3 + legWiggle;
      line(0, -segmentRadius * 0.3, cos(ll) * segmentRadius * 0.6, -segmentRadius * 0.3 + sin(ll) * segmentRadius * 0.6);
      
      // Right legs
      float rl = -PI/2 - 0.3 - legWiggle;
      line(0, segmentRadius * 0.3, cos(rl) * segmentRadius * 0.6, segmentRadius * 0.3 + sin(rl) * segmentRadius * 0.6);
      
      popMatrix();
    }
    
    noStroke();
    drawHealthBar();
  }
  
  void updateParticles() {
    particles.update();
    
    // Trail from tail when moving
    if (velocity.mag() > maxSpeed * 0.5 && random(1) < 0.2) {
      PVector tail = segments[numSegments - 1];
      particles.addParticle(tail, color(bodyColor, 100));
    }
  }
  
  color getColor() {
    return bodyColor;
  }
  
  Creature createOffspring(float x, float y) {
    return new Caterpillar(x, y, this);
  }
}

// ==================== BIRD SUBCLASS ====================
class Bird extends Creature {
  color bodyColor;
  color wingColor;
  float wingPhase;
  
  Bird(float x, float y) {
    super(x, y);
    
    // Bird properties - faster, needs more food
    size = 18 * sizeGene;
    mass = 0.6 * sizeGene;
    maxSpeed = 4.0 * speedGene;
    maxForce = 0.35;
    
    senseRadius = 180;
    foodAttraction = 1.2;
    
    health = 80;
    maxHealth = 80;
    metabolicRate = 0.1; // Higher metabolism
    reproductionThreshold = 70;
    reproductionCost = 30;
    reproductionCooldown = 250;
    lastReproduction = random(50, 250);
    
    oscillationSpeed = 0.35;
    wingPhase = random(TWO_PI);
    
    // Bird colors
    bodyColor = color(
      220 + random(-30, 35),
      160 + random(-40, 40),
      80 + random(-30, 30)
    );
    wingColor = color(
      red(bodyColor) - 40,
      green(bodyColor) - 30,
      blue(bodyColor) - 20
    );
    baseColor = bodyColor;
  }
  
  Bird(float x, float y, Bird parent) {
    this(x, y);
    
    this.speedGene = constrain(parent.speedGene + random(-0.1, 0.1), 0.6, 1.4);
    this.sizeGene = constrain(parent.sizeGene + random(-0.1, 0.1), 0.6, 1.4);
    
    this.size = 18 * sizeGene;
    this.mass = 0.6 * sizeGene;
    this.maxSpeed = 4.0 * speedGene;
    
    this.bodyColor = mutateColor(parent.bodyColor);
    this.wingColor = mutateColor(parent.wingColor);
  }
  
  color mutateColor(color c) {
    return color(
      constrain(red(c) + random(-20, 20), 0, 255),
      constrain(green(c) + random(-20, 20), 0, 255),
      constrain(blue(c) + random(-20, 20), 0, 255)
    );
  }
  
  void display() {
    particles.display();
    
    pushMatrix();
    translate(position.x, position.y);
    rotate(velocity.heading());
    
    // Wing flap angle tied to speed
    float wingFlap = sin(oscillationPhase) * oscillationAmplitude * 0.7;
    
    // Shadow
    noStroke();
    fill(0, 30);
    ellipse(3, 4, size * 1.1, size * 0.5);
    
    // Wings (behind body)
    fill(wingColor);
    
    // Left wing
    pushMatrix();
    rotate(-wingFlap - 0.2);
    beginShape();
    vertex(0, 0);
    vertex(-size * 0.3, -size * 0.7);
    vertex(-size * 0.1, -size * 0.5);
    vertex(size * 0.2, -size * 0.3);
    endShape(CLOSE);
    popMatrix();
    
    // Right wing
    pushMatrix();
    rotate(wingFlap + 0.2);
    beginShape();
    vertex(0, 0);
    vertex(-size * 0.3, size * 0.7);
    vertex(-size * 0.1, size * 0.5);
    vertex(size * 0.2, size * 0.3);
    endShape(CLOSE);
    popMatrix();
    
    // Body
    fill(bodyColor);
    ellipse(0, 0, size, size * 0.45);
    
    // Head
    fill(bodyColor);
    ellipse(size * 0.35, 0, size * 0.4, size * 0.35);
    
    // Beak
    fill(255, 180, 50);
    triangle(size * 0.5, 0, size * 0.75, -size * 0.05, size * 0.75, size * 0.05);
    
    // Eye
    fill(30);
    ellipse(size * 0.4, -size * 0.05, size * 0.1, size * 0.1);
    fill(255);
    ellipse(size * 0.42, -size * 0.06, size * 0.04, size * 0.04);
    
    // Tail feathers
    fill(wingColor);
    triangle(-size * 0.5, 0, -size * 0.8, -size * 0.15, -size * 0.7, 0);
    triangle(-size * 0.5, 0, -size * 0.8, size * 0.15, -size * 0.7, 0);
    
    popMatrix();
    
    drawHealthBar();
  }
  
  void updateParticles() {
    particles.update();
    
    // Feather particles when moving fast
    if (velocity.mag() > maxSpeed * 0.7 && random(1) < 0.15) {
      PVector tailPos = PVector.sub(position, PVector.mult(velocity.copy().normalize(), size * 0.5));
      particles.addParticle(tailPos, color(wingColor, 150));
    }
  }
  
  color getColor() {
    return bodyColor;
  }
  
  Creature createOffspring(float x, float y) {
    return new Bird(x, y, this);
  }
}
