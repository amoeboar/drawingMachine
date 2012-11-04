// setup of angles, radius, positions, and changing variables
float angle1, angle2, r1, r2, x1, y1, x2, y2;
float speed1, speed2;
int increment;


//arrays to save the x and y position of the line to be drawn
float x[] = new float [0];
float y[] = new float [0];


void setup() {
  size(800, 600);
  smooth();
  background(255);

  //interesting settings changes:
  // r1, r2, speed1, speed2, increment
  r1 = random(0, 200);
  r2 = random(0, 100);
  speed1 = random(1, 5);
  speed2 = random(-10, 10);
  increment = int(random(1, 5));

  angle1 = angle2 = 0;
}


void draw() {
  background(255);
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
  line(0, 0, 200, 0);

  //arm2

  translate(r1, 0);
  rotate(radians (angle2-45));
  rectMode(CENTER);
  line(0, 0, r2-15, r2-15);

  //drawing point of the machine (used to displace from the center)
  ellipse(r2-15, r2-15, 10, 10);
  popMatrix();


  //drawing the line
  //adding each point to the array
  x1 = cos(radians(angle1))*r1;
  y1 = sin(radians(angle1))*r1;
  x2 = x1 + cos(radians(angle2+angle1))*r2;
  y2 = y1 + sin(radians(angle2+angle1))*r2;

  x = append (x, x2);
  y = append (y, y2);


  //drawing a line between point and last point
  stroke(255, 0, 0);
  strokeWeight(2); 

  for (int i = 1; i < x.length; i++) {
    line (x[i], y[i], x[i-1], y[i-1]);
  }


  //arm rotation
  angle1 = angle1 + speed1;
  if (angle1 == 360 || angle1 == -360) {
    angle1 = increment;
  }


  // second arm 
  if (angle2 == speed2*360 || angle2 == -speed2*360) {
    angle2 = 0;
  }

  angle2 = angle2+speed2;
  increment = 3;
}




void mousePressed() {
  //empty arrays  
  x = new float [0];
  y = new float [0];
}

void keyPressed() {
  if (key == ' '){
  r1 = random(0, 200);
  r2 = random(0, 100);
  speed1 = random(1, 5);
  speed2 = random(1, 10);
  increment = int(random(1, 5));
  }
}


