void setup() {
  size(600, 550);
  noLoop();
}

void draw() {
  background(245, 235, 220);
  
  // Spikes
fill(74, 124, 89);
stroke(74, 124, 89);
strokeWeight(10);
strokeJoin(ROUND);

triangle(250, 120, 270, 110, 230, 100);  // spike 1
triangle(235, 150, 255, 140, 215, 130);  
triangle(220, 180, 240, 170, 200, 160); 
triangle(205, 210, 225, 200, 185, 190);  
triangle(190, 240, 210, 230, 170, 220);  
triangle(175, 270, 195, 260, 155, 250);  
triangle(160, 300, 180, 290, 140, 280);  
triangle(145, 330, 165, 320, 125, 310); 
triangle(130, 360, 150, 350, 110, 340); 
triangle(115, 390, 135, 380, 95, 370);   
triangle(100, 420, 120, 410, 80, 400);   
triangle(85, 450, 105, 440, 65, 430);    
triangle(70, 480, 90, 470, 50, 460);     // spike 13
  
  // Main body
  fill(108, 184, 109);
  noStroke();
  triangle(10, 540,330, 100, 330, 540); 
  triangle(10, 540, 266, 100, 266, 540);
  
  // Head
  rectMode(CORNER);
  fill(108, 184, 109);
  rect(250, 100, 250, 160, 30);
  

  // Body spots
  fill(74, 124, 89);
  noStroke();
  circle(230, 220, 35);  // small spot near neck
  circle(210, 310, 50);  // medium spot
  circle(180, 410, 60);  // large spot upper
  circle(240, 480, 70);  // largest spot at bottom
  circle(260, 340, 45);  // spot middle-right
  circle(120, 450, 50);  // spot left side
  
  // Nostril (small circle)
  circle(470, 120, 12);
 
  // Mouth opening
  fill(245, 235, 220);
  noStroke();
  rect(330, 160, 200, 80, 40);
  
  //tongue
  fill(255, 100, 120);
  noStroke();
  arc(332, 200, 60, 40, -HALF_PI, HALF_PI, CHORD);

  // Eye white 
  fill(255);
  ellipse(310, 125, 70, 75);

  // Eye pupil
  fill(0);
  circle(308, 120, 35); 

  // Eye highlight
  fill(255);
  circle(315, 110, 15); 
  
  // Cheek circle
  fill(245, 166, 35);
  circle(290, 195, 30);
  
  // Arms
  fill(108, 184, 109);
  noStroke();
  triangle(300, 300, 350, 300, 300, 340);
  triangle(280, 335, 370, 335, 280, 385);

}
