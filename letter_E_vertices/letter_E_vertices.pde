// Letter "E" Kite Shape - Replace the code in drawColoredLetterKite()

void drawColoredLetterKite() {
  // Letter "E" shape
  // MODIFY THIS TO MATCH YOUR INITIAL!
  
  // Main kite body
  fill(255, 100, 100, 230);
  stroke(80, 40, 40);
  strokeWeight(3);
  
  // Letter "E" outline - going clockwise from top-left
  beginShape();
  vertex(-40, -80);    // Top left corner
  vertex(40, -80);     // Top right corner
  vertex(40, -55);     // Top bar - inner right
  vertex(-10, -55);    // Top bar - inner corner
  vertex(-10, -15);    // Above middle bar - left
  vertex(30, -15);     // Middle bar - right
  vertex(30, 10);      // Middle bar - bottom right
  vertex(-10, 10);     // Middle bar - bottom left
  vertex(-10, 50);     // Below middle bar - left
  vertex(40, 50);      // Bottom bar - inner right
  vertex(40, 75);      // Bottom right corner
  vertex(-40, 75);     // Bottom left corner
  endShape(CLOSE);     // CLOSE connects back to top-left
  
  // Decorative frame lines (kite structure)
  stroke(255, 200, 100);
  strokeWeight(2);
  // Vertical spine
  line(-25, -80, -25, 75);
  // Horizontal crossbars
  line(-40, -20, 40, -20);
  line(-40, 30, 40, 30);
}

// ============================================================
// VISUAL REFERENCE FOR LETTER "E":
// ============================================================
//
//    (-40,-80)■■■■■■■■■■■■■(40,-80)
//             ■           ■
//             ■     ■■■■■■(40,-55)
//             ■     ■(-10,-55)
//             ■     ■
//    (-10,-15)■     ■■■■■■(30,-15)
//             ■           ■
//             ■     ■■■■■■(30,10)
//             ■     ■(-10,10)
//             ■     ■
//     (-10,50)■     ■■■■■■(40,50)
//             ■           ■
//     (-40,75)■■■■■■■■■■■■(40,75)
//
// ============================================================
