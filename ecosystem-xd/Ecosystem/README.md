# Interactive Ecosystem Simulation

A dynamic ecosystem simulation built in Processing featuring physics-based creatures, oscillating locomotion, object-oriented design, and complete lifecycle management.

## Features

### ✅ All Required Features Implemented

1. **Forces System**
   - Seek (attraction to food/prey)
   - Flee (repulsion from predators)
   - Separation (avoid crowding)
   - Wander (random exploration)
   - Boundary avoidance
   - All forces use vector mathematics and steering behaviors

2. **Environment Elements**
   - **Food Items**: Static resources that respawn after consumption
   - **Predators**: Hunt other creatures for sustenance
   - Creatures detect and respond using force-based behaviors

3. **Oscillating Bodies & Locomotion**
   - **BirdCreature**: Oscillating wings that flap faster with speed
   - **FishCreature**: Oscillating tail that undulates with swimming motion
   - Oscillators are anchored to creature positions (move with them)
   - Oscillation speed tied to velocity magnitude
   - Oscillation influences locomotion through propulsion forces

4. **Object-Oriented Design**
   - **Creature** (abstract base class)
     - BirdCreature (subclass)
     - FishCreature (subclass)
     - Predator (subclass)
   - Polymorphism: Main loop treats all creatures uniformly
   - Each subclass overrides `display()` and `reproduce()` methods

5. **Resources, Health & Lifecycle**
   - Health/energy system (decreases over time and with activity)
   - Eating food increases health
   - Creatures die when health ≤ 0
   - Reproduction when health > threshold
   - Genetic variation in offspring (size, speed, color)
   - Competition: First-to-food wins, size affects interactions

### ⭐ Optional Features Included

- **Particle System**: Death particles, eating effects
- **Genetics**: Offspring inherit traits with mutations
- **UI Controls**: Keyboard shortcuts for interaction
- **Debug Visualization**: Toggle force display

## File Structure

```
Ecosystem/
├── Ecosystem.pde          # Main sketch file
├── Creature.pde           # Abstract base class
├── BirdCreature.pde       # Flying creature with wing oscillation
├── FishCreature.pde       # Swimming creature with tail oscillation
├── Predator.pde           # Hunting creature
├── Oscillator.pde         # Periodic motion component
├── Food.pde               # Resource objects
└── Particle.pde           # Visual effects system
```

## How to Run

1. **Install Processing**
   - Download from https://processing.org/download
   - Version 4.0+ recommended

2. **Open the Project**
   - Open `Ecosystem.pde` in Processing
   - All other .pde files must be in the same "Ecosystem" folder

3. **Run**
   - Click the "Run" button (play icon) or press Ctrl+R (Cmd+R on Mac)

## Controls

| Key | Action |
|-----|--------|
| `F` | Spawn food at mouse position |
| `C` | Spawn random creature at mouse position |
| `P` | Pause/Resume simulation |
| `V` | Toggle force visualization (debug mode) |
| `R` | Reset ecosystem |
| **Mouse Click** | Spawn food |

## Creature Types

### 🐦 Bird Creature (Blue)
- Flies with oscillating wings
- Fast and agile
- Medium perception range
- Wings flap faster when moving quickly

### 🐟 Fish Creature (Orange)
- Swims with oscillating tail
- Moderate speed
- Tail undulates to propel forward
- Has body segments that follow smoothly

### 🦖 Predator (Red)
- Hunts other creatures
- Fastest and strongest
- Large perception/hunt radius
- Chomping jaw animation
- Gains health from kills

## Game Mechanics

### Health System
- **Energy Drain**: All creatures lose health over time (metabolism)
- **Movement Cost**: Moving faster costs more energy
- **Oscillation Cost**: Wing/tail movement costs energy
- **Eating**: Increases health (varies by food nutrition value)
- **Combat**: Predators deal damage on contact

### Reproduction
- Triggers when health > 80 (prey) or 90 (predators)
- Costs 40-50 health to reproduce
- Offspring inherit traits with ±10-20% variation:
  - Size
  - Speed
  - Color
- Babies born with 50-60 health
- Cooldown period prevents rapid reproduction

### Competition
- First creature to reach food gets it
- Larger creatures have advantages in crowded areas
- Predators prioritize hunting over food collection
- Separation forces prevent overcrowding

### Food System
- Spawns at random locations
- Nutrition value varies (15-35 health)
- Consumed food respawns after 3 seconds
- Automatic spawning every 2 seconds
- Color indicates nutrition (green = low, yellow = high)

## Code Architecture

### Class Hierarchy
```
Creature (abstract)
├── Properties: position, velocity, acceleration, health, size, maxSpeed
├── Methods: applyForce(), update(), display(), applyBehaviors()
│
├── BirdCreature
│   ├── Has: leftWing, rightWing (Oscillators)
│   └── Overrides: display(), reproduce()
│
├── FishCreature
│   ├── Has: tail (Oscillator), bodySegments[]
│   └── Overrides: display(), reproduce()
│
└── Predator
    ├── Has: jaw (Oscillator), target
    └── Overrides: applyBehaviors(), display(), reproduce()
```

### Force System
Each creature accumulates forces each frame:
```java
applyBehaviors() {
  1. Calculate separation from neighbors
  2. Seek nearest food/prey
  3. Flee from threats (if applicable)
  4. Wander if idle
  5. Avoid boundaries
  6. Apply all forces to acceleration
}
```

### Oscillator Math
Oscillating body parts use sine waves:
```java
angle += angleVelocity
position = sin(angle + phaseOffset) * amplitude
```
- `angleVelocity` tied to creature speed
- `amplitude` determines range of motion
- `phaseOffset` creates phase differences (e.g., wing sync)

## Customization

### Tuning Parameters

In **Creature.pde**:
```java
maxHealth = 100;        // Starting health
maxSpeed = 3;           // Movement speed cap
maxForce = 0.3;         // Steering force limit
perceptionRadius = 100; // Detection range
```

In **main sketch**:
```java
foodSpawnTimer > 120    // Food spawn rate (frames)
initial population      // Starting creatures
```

### Adding New Creature Types

1. Create new class extending `Creature`
2. Override `display()` for unique appearance
3. Override `applyBehaviors()` for custom AI (optional)
4. Override `reproduce()` to spawn same type
5. Add oscillators for body parts

Example:
```java
class SnakeCreature extends Creature {
  Oscillator body;
  
  SnakeCreature(float x, float y) {
    super(x, y);
    body = new Oscillator();
  }
  
  void display() {
    // Custom drawing code
  }
  
  Creature reproduce() {
    // Return new SnakeCreature
  }
}
```

## Performance Notes

- Tested with 50+ simultaneous creatures
- Particle system limits itself naturally (lifespan)
- Spatial partitioning not implemented (works well for <100 entities)
- Use `showForces = false` for better performance

## Observations

### Emergent Behaviors
- **Schooling**: Fish sometimes group naturally due to separation forces
- **Hunting Patterns**: Predators develop patrol routes
- **Population Cycles**: Predator-prey dynamics create oscillating populations
- **Resource Competition**: Creatures cluster around food-rich areas
- **Genetic Drift**: Populations evolve different traits over time

### Balance Tips
- If predators dominate: Reduce their speed or damage
- If prey overpopulate: Increase metabolism rate
- If food is scarce: Reduce spawn timer or increase nutrition values
- For longer lifespans: Reduce energy costs

## Technical Implementation Details

### Force Accumulation
```java
acceleration = Σ(forces) / mass
velocity += acceleration
position += velocity
```

### Steering Behavior
```java
desired = target - position
desired.normalize()
desired *= maxSpeed
steer = desired - velocity
steer.limit(maxForce)
```

### Oscillator Integration
```java
wingFlap = sin(angle) * amplitude
propulsion = wingFlap * forwardDirection
applyForce(propulsion)
```

## Known Issues & Future Enhancements

### Potential Issues
- Very high populations (>100) may slow down
- Creatures occasionally get stuck in corners (boundary avoidance usually prevents this)
- Population can die out if unlucky (add minimum spawn if needed)

### Future Ideas
- Add obstacles/terrain
- Implement flocking/schooling behaviors explicitly
- Add carnivore plants or stationary threats
- Implement gender and mating requirements
- Add weather effects (wind, currents)
- Save/load ecosystem states
- Graph population over time
- Add evolutionary traits (aggression, speed, perception)

## Credits

**Algorithms & Concepts:**
- Steering Behaviors: Craig Reynolds
- Autonomous Agents: Nature of Code by Daniel Shiffman
- Simple Harmonic Motion for oscillators

**Built with Processing 4**

## License

Free to use and modify for educational purposes.

---

## Quick Start Checklist

- [ ] Processing installed
- [ ] All .pde files in same folder
- [ ] Open Ecosystem.pde
- [ ] Press Run
- [ ] Press F to spawn food
- [ ] Press C to spawn creatures
- [ ] Watch the ecosystem evolve!

**Enjoy watching your ecosystem come to life!** 🌱🐦🐟🦖
