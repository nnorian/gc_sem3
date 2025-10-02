size(400, 400);
background(240);

// Tail
stroke(0);
strokeWeight(4.5);
noFill();
fill(245, 235, 210);
ellipse(320, 210, 25, 25);  

// Mane 
fill(200, 180, 160);
noStroke();
// Top row of mane 
circle(135, 120, 60);  
circle(175, 110, 60);  
circle(210, 110, 60);  
circle(245, 110, 60);  
circle(265, 120, 60);  
// Side mane pieces 
ellipse(120, 160, 60, 60);
ellipse(120, 200, 60, 60);
ellipse(120, 240, 60, 60);
// Side mane pieces 
ellipse(280, 160, 60, 60);
ellipse(280, 200, 60, 60);
ellipse(280, 240, 60, 60);
// Bottom mane 
circle(135, 255, 60);  
circle(175, 265, 60);  
circle(210, 265, 60);  
circle(245, 265, 60);  
circle(265, 255, 60);  

// Ears
fill(245, 235, 210);
stroke(0);
strokeWeight(4.5);
ellipse(142, 114, 28, 28);
ellipse(254, 114, 28, 28);


// Face
fill(245, 235, 210);
stroke(0);
strokeWeight(4.5);
rect(120, 120, 150, 120, 25);



// Eyes
fill(0);
ellipse(150, 175, 10, 16);
ellipse(240, 175, 10, 16);

// Mouth
noFill();
arc(194, 185, 13, 20, 0, PI);

// Paws
fill(245, 235, 210);
ellipse(160, 260, 50, 40);
ellipse(240, 260, 50, 40);
