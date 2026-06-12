/**
 * Box2D Creature Simulation
 * A comprehensive demonstration of the Box2D physics library in Processing
 * 
 * This project creates interactive creatures with complex body structures,
 * joints, collision detection, and user controls.
 * 
 * Controls:
 * - Click to spawn a new creature at mouse position
 * - Arrow keys to control the selected creature (apply forces)
 * - SPACE to make creature jump
 * - 'R' to reset the simulation
 * - 'G' to toggle gravity direction
 * - '1-3' to change environment
 */

import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.collision.*;
import org.jbox2d.collision.shapes.*;

// ============================================================
// GLOBAL VARIABLES
// ============================================================

// Box2D world reference - the physics simulation engine
Box2DProcessing box2d;

// ArrayList to store all creatures in the simulation
ArrayList<Creature> creatures;

// ArrayList to store static boundaries/obstacles
ArrayList<Boundary> boundaries;

// ArrayList to store floating platforms
ArrayList<Platform> platforms;

// Currently selected creature for user control
Creature selectedCreature;

// Environment type (0 = basic, 1 = platforms, 2 = obstacles)
int currentEnvironment = 0;

// Gravity toggle
boolean gravityFlipped = false;

// Colors for visual appeal
color bgColor = color(240, 248, 255);
color groundColor = color(100, 80, 60);
color platformColor = color(80, 120, 80);

// ============================================================
// SETUP - Initialize the simulation
// ============================================================

void setup() {
  size(1200, 800);
  smooth();
  
  // Initialize the Box2D physics world
  // This creates a new Box2D simulation with default gravity (0, -10)
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  
  // Set gravity - Box2D uses meters, Processing uses pixels
  // Positive Y is down in Processing but up in Box2D, so we negate
  box2d.setGravity(0, -25);
  
  // Enable collision listening
  // This allows us to detect when bodies collide
  box2d.listenForCollisions();
  
  // Initialize ArrayLists
  creatures = new ArrayList<Creature>();
  boundaries = new ArrayList<Boundary>();
  platforms = new ArrayList<Platform>();
  
  // Create the initial environment
  createEnvironment(currentEnvironment);
  
  // Spawn initial creature
  spawnCreature(width/2, height/2);
}

// ============================================================
// DRAW - Main rendering loop
// ============================================================

void draw() {
  background(bgColor);
  
  // Step the physics simulation forward
  // Parameters: time step, velocity iterations, position iterations
  // More iterations = more accurate but slower
  box2d.step();
  
  // Draw environment info
  drawUI();
  
  // Draw all boundaries
  for (Boundary b : boundaries) {
    b.display();
  }
  
  // Draw all platforms
  for (Platform p : platforms) {
    p.display();
  }
  
  // Update and draw all creatures
  // Iterate backwards to safely remove dead creatures
  for (int i = creatures.size() - 1; i >= 0; i--) {
    Creature c = creatures.get(i);
    c.display();
    
    // Remove creatures that fall off screen
    if (c.isOffScreen()) {
      c.destroy();
      creatures.remove(i);
      if (c == selectedCreature) {
        selectedCreature = null;
      }
    }
  }
  
  // Highlight selected creature
  if (selectedCreature != null) {
    selectedCreature.highlight();
  }
  
  // Apply continuous forces if keys are held
  handleContinuousInput();
}

// ============================================================
// USER INTERFACE
// ============================================================

void drawUI() {
  fill(0);
  textSize(14);
  textAlign(LEFT, TOP);
  
  String[] instructions = {
    "Box2D Creature Simulation",
    "------------------------",
    "Click: Spawn new creature",
    "Arrows: Move selected creature",
    "SPACE: Jump",
    "R: Reset simulation",
    "G: Flip gravity",
    "1-3: Change environment",
    "",
    "Creatures: " + creatures.size(),
    "Environment: " + getEnvironmentName(),
    "Gravity: " + (gravityFlipped ? "Flipped" : "Normal")
  };
  
  for (int i = 0; i < instructions.length; i++) {
    text(instructions[i], 10, 10 + i * 18);
  }
}

String getEnvironmentName() {
  switch(currentEnvironment) {
    case 0: return "Basic Ground";
    case 1: return "Platforms";
    case 2: return "Obstacles";
    default: return "Unknown";
  }
}

// ============================================================
// ENVIRONMENT CREATION
// ============================================================

void createEnvironment(int type) {
  // Clear existing environment
  for (Boundary b : boundaries) {
    b.destroy();
  }
  boundaries.clear();
  
  for (Platform p : platforms) {
    p.destroy();
  }
  platforms.clear();
  
  // Create ground - always present
  boundaries.add(new Boundary(width/2, height - 20, width, 40, groundColor));
  
  // Create walls
  boundaries.add(new Boundary(10, height/2, 20, height, groundColor));
  boundaries.add(new Boundary(width - 10, height/2, 20, height, groundColor));
  
  // Create ceiling
  boundaries.add(new Boundary(width/2, 10, width, 20, groundColor));
  
  switch(type) {
    case 1: // Platforms environment
      platforms.add(new Platform(300, 600, 200, 20));
      platforms.add(new Platform(600, 500, 200, 20));
      platforms.add(new Platform(900, 400, 200, 20));
      platforms.add(new Platform(450, 300, 200, 20));
      platforms.add(new Platform(750, 200, 200, 20));
      break;
      
    case 2: // Obstacles environment
      // Add some angled platforms
      platforms.add(new Platform(300, 500, 300, 20, PI/12));
      platforms.add(new Platform(900, 500, 300, 20, -PI/12));
      platforms.add(new Platform(600, 350, 400, 20));
      // Add some small obstacles
      boundaries.add(new Boundary(400, height - 60, 60, 80, color(120, 60, 60)));
      boundaries.add(new Boundary(800, height - 60, 60, 80, color(120, 60, 60)));
      break;
  }
}

// ============================================================
// INPUT HANDLING
// ============================================================

void mousePressed() {
  // Check if clicking on existing creature to select it
  boolean foundCreature = false;
  for (Creature c : creatures) {
    if (c.contains(mouseX, mouseY)) {
      selectedCreature = c;
      foundCreature = true;
      break;
    }
  }
  
  // If not clicking on creature, spawn new one
  if (!foundCreature) {
    spawnCreature(mouseX, mouseY);
  }
}

void keyPressed() {
  switch(key) {
    case 'r':
    case 'R':
      resetSimulation();
      break;
      
    case 'g':
    case 'G':
      toggleGravity();
      break;
      
    case '1':
      currentEnvironment = 0;
      createEnvironment(currentEnvironment);
      break;
      
    case '2':
      currentEnvironment = 1;
      createEnvironment(currentEnvironment);
      break;
      
    case '3':
      currentEnvironment = 2;
      createEnvironment(currentEnvironment);
      break;
      
    case ' ':
      if (selectedCreature != null) {
        selectedCreature.jump();
      }
      break;
  }
}

void handleContinuousInput() {
  if (selectedCreature == null) return;
  
  if (keyPressed) {
    if (keyCode == LEFT) {
      selectedCreature.moveLeft();
    }
    if (keyCode == RIGHT) {
      selectedCreature.moveRight();
    }
    if (keyCode == UP) {
      selectedCreature.applyUpwardForce();
    }
    if (keyCode == DOWN) {
      selectedCreature.applyDownwardForce();
    }
  }
}

// ============================================================
// SIMULATION CONTROL
// ============================================================

void spawnCreature(float x, float y) {
  Creature newCreature = new Creature(x, y);
  creatures.add(newCreature);
  selectedCreature = newCreature;
}

void resetSimulation() {
  // Destroy all creatures
  for (Creature c : creatures) {
    c.destroy();
  }
  creatures.clear();
  selectedCreature = null;
  
  // Reset environment
  createEnvironment(currentEnvironment);
  
  // Spawn initial creature
  spawnCreature(width/2, height/2);
}

void toggleGravity() {
  gravityFlipped = !gravityFlipped;
  if (gravityFlipped) {
    box2d.setGravity(0, 25);
  } else {
    box2d.setGravity(0, -25);
  }
}

// ============================================================
// COLLISION DETECTION CALLBACKS
// These methods are called automatically by Box2D
// ============================================================

// Called when two fixtures begin to touch
void beginContact(Contact contact) {
  // Get the fixtures involved in the collision
  Fixture f1 = contact.getFixtureA();
  Fixture f2 = contact.getFixtureB();
  
  // Get the bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  
  // Get user data (our custom objects)
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  
  // Check if two creatures collided
  if (o1 != null && o2 != null) {
    if (o1.getClass() == CreatureBody.class && o2.getClass() == CreatureBody.class) {
      CreatureBody cb1 = (CreatureBody) o1;
      CreatureBody cb2 = (CreatureBody) o2;
      
      // Trigger collision effect on both creatures
      cb1.parent.onCollision();
      cb2.parent.onCollision();
    }
  }
}

// Called when two fixtures cease to touch
void endContact(Contact contact) {
  // Can be used to detect when creatures separate
}

// ============================================================
// CREATURE CLASS
// A complex creature with multiple body parts connected by joints
// ============================================================

class Creature {
  // Main body parts
  CreatureBody mainBody;
  CreatureBody head;
  ArrayList<CreatureLimb> limbs;
  
  // Joints connecting body parts
  RevoluteJoint neckJoint;
  ArrayList<RevoluteJoint> limbJoints;
  ArrayList<DistanceJoint> muscleJoints;
  
  // Visual properties
  color bodyColor;
  color limbColor;
  float hue;
  
  // State
  boolean isColliding = false;
  int collisionTimer = 0;
  
  Creature(float x, float y) {
    // Random color for this creature
    colorMode(HSB, 360, 100, 100);
    hue = random(360);
    bodyColor = color(hue, 70, 90);
    limbColor = color(hue, 50, 70);
    colorMode(RGB, 255);
    
    limbs = new ArrayList<CreatureLimb>();
    limbJoints = new ArrayList<RevoluteJoint>();
    muscleJoints = new ArrayList<DistanceJoint>();
    
    // Create the main body - using BodyDef and FixtureDef
    mainBody = new CreatureBody(x, y, 50, 35, bodyColor, this);
    
    // Create head attached to main body
    head = new CreatureBody(x, y - 40, 25, 25, bodyColor, this);
    
    // Create neck joint (RevoluteJoint) connecting head to body
    createNeckJoint();
    
    // Create limbs (legs and arms)
    createLimbs(x, y);
  }
  
  void createNeckJoint() {
    // RevoluteJointDef defines a joint that allows rotation around a point
    RevoluteJointDef rjd = new RevoluteJointDef();
    
    // Get the anchor point in world coordinates
    Vec2 anchor = mainBody.body.getWorldCenter();
    anchor.y += box2d.scalarPixelsToWorld(25);
    
    // Initialize the joint with both bodies and the anchor point
    rjd.initialize(mainBody.body, head.body, anchor);
    
    // Enable motor for active neck movement
    rjd.enableMotor = true;
    rjd.motorSpeed = 0;
    rjd.maxMotorTorque = 100;
    
    // Enable limits to prevent unnatural rotation
    rjd.enableLimit = true;
    rjd.lowerAngle = -PI/4;
    rjd.upperAngle = PI/4;
    
    // Create the joint in the Box2D world
    neckJoint = (RevoluteJoint) box2d.createJoint(rjd);
  }
  
  void createLimbs(float x, float y) {
    // Create four limbs: 2 arms, 2 legs
    float[][] limbPositions = {
      {-30, 10, 15, 40},  // Left arm
      {30, 10, 15, 40},   // Right arm
      {-20, 30, 12, 45},  // Left leg
      {20, 30, 12, 45}    // Right leg
    };
    
    for (int i = 0; i < 4; i++) {
      float[] pos = limbPositions[i];
      CreatureLimb limb = new CreatureLimb(
        x + pos[0], y + pos[1], 
        pos[2], pos[3], 
        limbColor, this
      );
      limbs.add(limb);
      
      // Create revolute joint for limb
      createLimbJoint(limb, pos[0], pos[1], i < 2);
    }
    
    // Create distance joints (muscles) between limbs for stability
    createMuscleJoints();
  }
  
  void createLimbJoint(CreatureLimb limb, float offsetX, float offsetY, boolean isArm) {
    RevoluteJointDef rjd = new RevoluteJointDef();
    
    // Calculate anchor point at the top of the limb
    Vec2 anchor = mainBody.body.getWorldCenter();
    anchor.x += box2d.scalarPixelsToWorld(offsetX);
    anchor.y -= box2d.scalarPixelsToWorld(offsetY - 15);
    
    rjd.initialize(mainBody.body, limb.body, anchor);
    
    // Different settings for arms vs legs
    if (isArm) {
      rjd.enableLimit = true;
      rjd.lowerAngle = -PI/2;
      rjd.upperAngle = PI/2;
    } else {
      rjd.enableLimit = true;
      rjd.lowerAngle = -PI/3;
      rjd.upperAngle = PI/3;
    }
    
    rjd.enableMotor = true;
    rjd.maxMotorTorque = 200;
    rjd.motorSpeed = 0;
    
    limbJoints.add((RevoluteJoint) box2d.createJoint(rjd));
  }
  
  void createMuscleJoints() {
    // Create distance joints between opposite limbs for stability
    if (limbs.size() >= 4) {
      // Connect left and right legs
      DistanceJointDef djd = new DistanceJointDef();
      
      Vec2 anchorA = limbs.get(2).body.getWorldCenter();
      Vec2 anchorB = limbs.get(3).body.getWorldCenter();
      
      djd.initialize(limbs.get(2).body, limbs.get(3).body, anchorA, anchorB);
      djd.frequencyHz = 4.0f;  // Softness
      djd.dampingRatio = 0.5f; // Damping
      
      muscleJoints.add((DistanceJoint) box2d.createJoint(djd));
    }
  }
  
  void display() {
    // Update collision timer
    if (collisionTimer > 0) {
      collisionTimer--;
      isColliding = collisionTimer > 0;
    }
    
    // Draw limbs first (behind body)
    for (CreatureLimb limb : limbs) {
      limb.display();
    }
    
    // Draw main body
    mainBody.display();
    
    // Draw head
    head.display();
    
    // Draw eyes on head
    drawEyes();
  }
  
  void drawEyes() {
    Vec2 pos = box2d.getBodyPixelCoord(head.body);
    float angle = head.body.getAngle();
    
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-angle);
    
    // Eye whites
    fill(255);
    stroke(0);
    strokeWeight(1);
    ellipse(-8, -5, 12, 14);
    ellipse(8, -5, 12, 14);
    
    // Pupils
    fill(0);
    noStroke();
    ellipse(-6, -5, 5, 5);
    ellipse(10, -5, 5, 5);
    
    popMatrix();
  }
  
  void highlight() {
    Vec2 pos = box2d.getBodyPixelCoord(mainBody.body);
    noFill();
    stroke(255, 200, 0);
    strokeWeight(3);
    ellipse(pos.x, pos.y, 100, 80);
    strokeWeight(1);
  }
  
  boolean contains(float px, float py) {
    Vec2 pos = box2d.getBodyPixelCoord(mainBody.body);
    return dist(px, py, pos.x, pos.y) < 60;
  }
  
  boolean isOffScreen() {
    Vec2 pos = box2d.getBodyPixelCoord(mainBody.body);
    return pos.y > height + 200 || pos.y < -200 || pos.x < -200 || pos.x > width + 200;
  }
  
  void onCollision() {
    isColliding = true;
    collisionTimer = 30; // Flash for 30 frames
    
    // Apply a small velocity change when colliding
    Vec2 currentVel = mainBody.body.getLinearVelocity();
    currentVel.x += random(-5, 5);
    currentVel.y += random(-5, 5);
    mainBody.body.setLinearVelocity(currentVel);
  }
  
  // Movement methods - apply forces to the body
  void moveLeft() {
    Vec2 currentVel = mainBody.body.getLinearVelocity();
    currentVel.x = max(currentVel.x - 2, -15);
    mainBody.body.setLinearVelocity(currentVel);
    
    // Animate legs
    animateLimbs(-1);
  }
  
  void moveRight() {
    Vec2 currentVel = mainBody.body.getLinearVelocity();
    currentVel.x = min(currentVel.x + 2, 15);
    mainBody.body.setLinearVelocity(currentVel);
    
    // Animate legs
    animateLimbs(1);
  }
  
  void jump() {
    Vec2 currentVel = mainBody.body.getLinearVelocity();
    currentVel.y = gravityFlipped ? -40 : 40;
    mainBody.body.setLinearVelocity(currentVel);
  }
  
  void applyUpwardForce() {
    Vec2 currentVel = mainBody.body.getLinearVelocity();
    currentVel.y = min(currentVel.y + 2, 15);
    mainBody.body.setLinearVelocity(currentVel);
  }
  
  void applyDownwardForce() {
    Vec2 currentVel = mainBody.body.getLinearVelocity();
    currentVel.y = max(currentVel.y - 2, -15);
    mainBody.body.setLinearVelocity(currentVel);
  }
  
  void animateLimbs(int direction) {
    // Set motor speed on leg joints to animate walking
    if (limbJoints.size() >= 4) {
      float speed = direction * 5;
      limbJoints.get(2).setMotorSpeed(speed);
      limbJoints.get(3).setMotorSpeed(-speed);
    }
  }
  
  void destroy() {
    // Must destroy joints before bodies
    if (neckJoint != null) {
      box2d.world.destroyJoint(neckJoint);
    }
    
    for (RevoluteJoint j : limbJoints) {
      box2d.world.destroyJoint(j);
    }
    
    for (DistanceJoint j : muscleJoints) {
      box2d.world.destroyJoint(j);
    }
    
    // Destroy bodies
    mainBody.destroy();
    head.destroy();
    
    for (CreatureLimb limb : limbs) {
      limb.destroy();
    }
  }
}

// ============================================================
// CREATURE BODY CLASS
// Represents a single body part of a creature
// Demonstrates BodyDef, Shape, and FixtureDef usage
// ============================================================

class CreatureBody {
  Body body;
  float w, h;
  color col;
  Creature parent;
  
  CreatureBody(float x, float y, float w_, float h_, color c, Creature p) {
    w = w_;
    h = h_;
    col = c;
    parent = p;
    
    // Step 1: Define the body using BodyDef
    // BodyDef contains all the data needed to construct a body
    BodyDef bd = new BodyDef();
    
    // Set the body type - DYNAMIC means it moves and responds to forces
    // Other options: STATIC (doesn't move), KINEMATIC (moves but not affected by forces)
    bd.type = BodyType.DYNAMIC;
    
    // Set the initial position (convert from pixels to Box2D world coordinates)
    bd.position = box2d.coordPixelsToWorld(x, y);
    
    // Set linear damping (air resistance) - reduces velocity over time
    bd.linearDamping = 0.5f;
    
    // Set angular damping - reduces rotation over time
    bd.angularDamping = 0.5f;
    
    // Step 2: Create the body in the Box2D world
    body = box2d.createBody(bd);
    
    // Step 3: Define the shape using PolygonShape
    // PolygonShape can be a box, triangle, or convex polygon
    PolygonShape ps = new PolygonShape();
    
    // Create a box shape (half-widths in Box2D units)
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    ps.setAsBox(box2dW, box2dH);
    
    // Step 4: Define the fixture using FixtureDef
    // Fixtures attach shapes to bodies and define physical properties
    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    
    // Density - affects mass (mass = density * area)
    fd.density = 1.0f;
    
    // Friction - resistance when sliding against other fixtures (0-1)
    fd.friction = 0.5f;
    
    // Restitution - bounciness (0 = no bounce, 1 = perfect bounce)
    fd.restitution = 0.3f;
    
    // Step 5: Attach the fixture to the body
    body.createFixture(fd);
    
    // Step 6: Store reference to parent creature for collision callbacks
    body.setUserData(this);
  }
  
  void display() {
    // Get the body's position and angle from Box2D
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float angle = body.getAngle();
    
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-angle); // Negate because Processing Y is flipped
    
    // Draw with collision effect
    if (parent.isColliding) {
      fill(255, 100, 100);
    } else {
      fill(col);
    }
    stroke(0);
    strokeWeight(2);
    rectMode(CENTER);
    rect(0, 0, w, h, 8);
    
    popMatrix();
  }
  
  void destroy() {
    box2d.world.destroyBody(body);
  }
}

// ============================================================
// CREATURE LIMB CLASS
// A limb with rounded ends (capsule shape)
// ============================================================

class CreatureLimb {
  Body body;
  float w, h;
  color col;
  Creature parent;
  
  CreatureLimb(float x, float y, float w_, float h_, color c, Creature p) {
    w = w_;
    h = h_;
    col = c;
    parent = p;
    
    // Create body definition
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position = box2d.coordPixelsToWorld(x, y);
    bd.linearDamping = 0.3f;
    bd.angularDamping = 0.3f;
    
    body = box2d.createBody(bd);
    
    // For limbs, we create a compound shape using multiple fixtures
    // This creates a capsule-like shape
    
    // Main rectangle body
    PolygonShape ps = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2 - w/2);
    ps.setAsBox(box2dW, box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    fd.density = 0.5f;
    fd.friction = 0.3f;
    fd.restitution = 0.1f;
    body.createFixture(fd);
    
    // Top circle
    CircleShape topCircle = new CircleShape();
    topCircle.m_radius = box2d.scalarPixelsToWorld(w/2);
    topCircle.m_p.set(0, box2dH);
    
    FixtureDef fdTop = new FixtureDef();
    fdTop.shape = topCircle;
    fdTop.density = 0.5f;
    fdTop.friction = 0.3f;
    fdTop.restitution = 0.1f;
    body.createFixture(fdTop);
    
    // Bottom circle
    CircleShape bottomCircle = new CircleShape();
    bottomCircle.m_radius = box2d.scalarPixelsToWorld(w/2);
    bottomCircle.m_p.set(0, -box2dH);
    
    FixtureDef fdBottom = new FixtureDef();
    fdBottom.shape = bottomCircle;
    fdBottom.density = 0.5f;
    fdBottom.friction = 0.3f;
    fdBottom.restitution = 0.1f;
    body.createFixture(fdBottom);
    
    body.setUserData(this);
  }
  
  void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float angle = body.getAngle();
    
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-angle);
    
    fill(col);
    stroke(0);
    strokeWeight(1);
    
    // Draw capsule shape
    rectMode(CENTER);
    rect(0, 0, w, h - w, 4);
    ellipse(0, -(h/2 - w/2), w, w);
    ellipse(0, (h/2 - w/2), w, w);
    
    popMatrix();
  }
  
  void destroy() {
    box2d.world.destroyBody(body);
  }
}

// ============================================================
// BOUNDARY CLASS
// Static rectangular boundaries (ground, walls, obstacles)
// ============================================================

class Boundary {
  Body body;
  float x, y, w, h;
  color col;
  
  Boundary(float x_, float y_, float w_, float h_, color c) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    col = c;
    
    // Create a STATIC body - doesn't move or respond to forces
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position = box2d.coordPixelsToWorld(x, y);
    
    body = box2d.createBody(bd);
    
    // Create shape and fixture
    PolygonShape ps = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    ps.setAsBox(box2dW, box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    fd.friction = 0.8f;
    fd.restitution = 0.2f;
    
    body.createFixture(fd);
  }
  
  void display() {
    fill(col);
    stroke(50);
    strokeWeight(2);
    rectMode(CENTER);
    rect(x, y, w, h);
  }
  
  void destroy() {
    box2d.world.destroyBody(body);
  }
}

// ============================================================
// PLATFORM CLASS
// Static platforms that can be angled
// ============================================================

class Platform {
  Body body;
  float x, y, w, h;
  float angle;
  
  Platform(float x_, float y_, float w_, float h_) {
    this(x_, y_, w_, h_, 0);
  }
  
  Platform(float x_, float y_, float w_, float h_, float a) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
    angle = a;
    
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position = box2d.coordPixelsToWorld(x, y);
    bd.angle = -angle; // Negate for Box2D coordinate system
    
    body = box2d.createBody(bd);
    
    PolygonShape ps = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    ps.setAsBox(box2dW, box2dH);
    
    FixtureDef fd = new FixtureDef();
    fd.shape = ps;
    fd.friction = 0.6f;
    fd.restitution = 0.1f;
    
    body.createFixture(fd);
  }
  
  void display() {
    pushMatrix();
    translate(x, y);
    rotate(angle);
    
    fill(platformColor);
    stroke(50);
    strokeWeight(2);
    rectMode(CENTER);
    rect(0, 0, w, h, 3);
    
    popMatrix();
  }
  
  void destroy() {
    box2d.world.destroyBody(body);
  }
}
