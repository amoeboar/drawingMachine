void beatsPerMinute() {
  int beatCount = 0;
  // Analyzes samples in input buffer. Cumulative, so must be called every frame
  beat.detect(input.mix);
  ellipseMode(CENTER);
  float a = map(radius, 20, 80, 60, 255);
  fill(60, 255, 0, a);
  if ( beat.isOnset() ) {
    radius = 80;
    beatCount++;
//    println(beatCount);
  }
  ellipse(width/2, height/2, radius, radius);
  radius *= 0.95;
  if ( radius < 20 ) { 
    radius = 20;
  }
  beginTimer++;
//  println(beginTimer);
}

//// Start and Stop function
//void keyPressed() {  
//  if (key == CODED) {   //test required to pick up special keys, like arrows
//     switch(keyCode) {
//       case (LEFT):
//         beginTimer++;
//       case (RIGHT):
//         break;
//     }
//  }
//  println(beginTimer);
//}

