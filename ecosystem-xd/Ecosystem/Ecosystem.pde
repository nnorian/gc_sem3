// Interactive Ecosystem Simulation
// Features: Forces, Oscillation, OOP, Lifecycle, Resources

ArrayList<Creature> creatures;
ArrayList<Food> foodItems;
ArrayList<Particle> particles;
boolean showForces = false;
boolean paused = false;
int foodSpawnTimer = 0;

void setup() {
  size(1400, 900);
  
  creatures = new ArrayList<Creature>();
  foodItems = new ArrayList<Food>();
  particles = new ArrayList<Particle>();
  
  // Spawn initial population
  for (int i = 0; i < 8; i++) {
    creatures.add(new BirdCreature(random(width), random(height)));
  }
  for (int i = 0; i < 6; i++) {
    creatures.add(new FishCreature(random(width), random(height)));
  }
  for (int i = 0; i < 3; i++) {
    creatures.add(new Predator(random(width), random(height)));
  }
  
  // Spawn initial food
  for (int i = 0; i < 25; i++) {
    foodItems.add(new Food(random(width), random(height)));
  }
}

void draw() {
  background(230, 240, 255);
  
  if (!paused) {
    // Update and display food
    for (int i = foodItems.size() - 1; i >= 0; i--) {
      Food f = foodItems.get(i);
      f.update();
      f.display();
      
      if (f.shouldRespawn()) {
        foodItems.remove(i);
        foodItems.add(new Food(random(width), random(height)));
      }
    }
    
    // Update and display particles
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      p.display();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
    
    // Update and display creatures
    for (int i = creatures.size() - 1; i >= 0; i--) {
      Creature c = creatures.get(i);
      
      // Apply behaviors
      c.applyBehaviors(creatures, foodItems, particles);
      c.update();
      c.display();
      
      // Check for reproduction
      if (c.canReproduce()) {
        Creature offspring = c.reproduce();
        if (offspring != null) {
          creatures.add(offspring);
        }
      }
      
      // Remove dead creatures
      if (c.isDead()) {
        createDeathParticles(c.position);
        creatures.remove(i);
      }
    }
    
    // Spawn food periodically
    foodSpawnTimer++;
    if (foodSpawnTimer > 120) {
      foodItems.add(new Food(random(width), random(height)));
      foodSpawnTimer = 0;
    }
  } else {
    // Still display when paused
    for (Food f : foodItems) f.display();
    for (Particle p : particles) p.display();
    for (Creature c : creatures) c.display();
  }
  
  // Display UI
  displayUI();
}

void displayUI() {
  fill(0);
  textAlign(LEFT);
  textSize(14);
  text("Creatures: " + creatures.size(), 10, 20);
  text("Food: " + foodItems.size(), 10, 40);
  text("Particles: " + particles.size(), 10, 60);
  text("[F] Spawn Food  [C] Spawn Creature  [P] Pause  [V] Toggle Forces  [R] Reset", 10, height - 10);
  
  if (paused) {
    fill(255, 0, 0);
    text("PAUSED", 10, 80);
  }
  
  // Count creature types
  int birds = 0, fish = 0, predators = 0;
  for (Creature c : creatures) {
    if (c instanceof Predator) predators++;
    else if (c instanceof BirdCreature) birds++;
    else if (c instanceof FishCreature) fish++;
  }
  fill(0);
  text("Birds: " + birds + " | Fish: " + fish + " | Predators: " + predators, 10, 100);
}

void createDeathParticles(PVector pos) {
  for (int i = 0; i < 15; i++) {
    particles.add(new Particle(pos.copy(), random(TWO_PI)));
  }
}

void mousePressed() {
  // Spawn food at mouse position
  foodItems.add(new Food(mouseX, mouseY));
}

void keyPressed() {
  if (key == 'f' || key == 'F') {
    foodItems.add(new Food(mouseX, mouseY));
  }
  if (key == 'c' || key == 'C') {
    float r = random(1);
    if (r < 0.33) {
      creatures.add(new BirdCreature(mouseX, mouseY));
    } else if (r < 0.66) {
      creatures.add(new FishCreature(mouseX, mouseY));
    } else {
      creatures.add(new Predator(mouseX, mouseY));
    }
  }
  if (key == 'p' || key == 'P') {
    paused = !paused;
  }
  if (key == 'v' || key == 'V') {
    showForces = !showForces;
  }
  if (key == 'r' || key == 'R') {
    setup();
  }
}
