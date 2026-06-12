// Oscillator class - creates periodic motion using sine waves
class Oscillator {
  float angle;
  float angleVelocity;
  float amplitude;
  float period;
  float phaseOffset;
  
  Oscillator() {
    angle = 0;
    angleVelocity = 0.1;
    amplitude = 1.0;
    period = 0.1;
    phaseOffset = 0;
  }
  
  void update() {
    angle += angleVelocity;
  }
  
  float getAngle() {
    return sin(angle + phaseOffset) * amplitude;
  }
  
  float getPosition() {
    return amplitude * sin(angle + phaseOffset);
  }
  
  void setPeriod(float p) {
    period = p;
    angleVelocity = TWO_PI * period;
  }
}
