void drawArt() {
  translate(width/2, height/2);

  //drawing the apparatus
  pushMatrix();
  noFill();
  stroke(0);
  strokeWeight(1);
  //center
  ellipse(0, 0, 30, 30);

  //arm1
  rotate(radians (angle1));
  stroke(255);
  line(-200, 0, 200, 0);

  //arm2

  translate(position1, 0);
 // rotate(radians (angle2-45));
  rectMode(CENTER);
  stroke(255);
  rect(0,0,10,10);
  popMatrix();


//drawing the line
  //adding each point to the array
  x1 = cos(radians(angle1))*position1;
  y1 = sin(radians(angle1))*position1;

  x = append (x, x1);
  y = append (y, y1);


  //drawing a line between point and last point
  stroke(255, 0, 0);
  strokeWeight(2); 

  for (int i = 1; i < x.length; i++) {
    line (x[i], y[i], x[i-1], y[i-1]);
  }


  //arm rotation
  angle1 = angle1 + speed1;
  if (angle1 == 360 || angle1 == -360) {
    angle1 = 0;
  }  
  
  position1 = position1 + direction1;
 
  translate(-width/2, -height/2);

} 
