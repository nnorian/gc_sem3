// Food class - resources that creatures consume
class Food {
  PVector position;
  float nutritionValue;
  float size;
  boolean consumed;
  int consumedTimer;
  int respawnTime;
  color foodColor;
  
  Food(float x, float y) {
    position = new PVector(x, y);
    nutritionValue = random(15, 35);
    size = map(nutritionValue, 15, 35, 6, 12);
    consumed = false;
    consumedTimer = 0;
    respawnTime = 180; // 3 seconds at 60fps
    
    // Color based on nutrition value
    float hue = map(nutritionValue, 15, 35, 60, 120);
    colorMode(HSB);
    foodColor = color(hue, 200, 200);
    colorMode(RGB);
  }
  
  void consume() {
    consumed = true;
    consumedTimer = 0;
  }
  
  void update() {
    if (consumed) {
      consumedTimer++;
    }
  }
  
  boolean shouldRespawn() {
    return consumed && consumedTimer > respawnTime;
  }
  
  void display() {
    if (!consumed) {
      // Draw food as a glowing circle
      noStroke();
      
      // Glow effect
      for (int i = 3; i > 0; i--) {
        fill(foodColor, 30);
        ellipse(position.x, position.y, size * (1 + i * 0.5), size * (1 + i * 0.5));
      }
      
      // Main food
      fill(foodColor);
      ellipse(position.x, position.y, size, size);
      
      // Highlight
      fill(255, 200);
      ellipse(position.x - size * 0.2, position.y - size * 0.2, size * 0.3, size * 0.3);
    }
  }
}
