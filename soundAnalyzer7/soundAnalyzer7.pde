/* 
 * A sound analyzer. Uses FFT algorithm to transform the signal in the time domain (sample buffer)
 * into a signal in the frequency domain (spectrum). Here, frequency and amplitude are returned.
 * BeatDetect analyzes an audio stream for beats (rhythmic onsets). This returns beats per minute.
 *
 * John Capogna, Brett Peterson, Maria Paula Saba
 * ITP, 2012
 */

import ddf.minim.*;
import ddf.minim.analysis.*;

// setup of angle, radius, position, and changing variables
float angle1, position1, r1, x1, y1;
float speed1;
float direction1;
int a;

float startMillis = 0; // current time at playing


//arrays to save the x and y position of the line to be drawn
float x[] = new float [0];
float y[] = new float [0];

Boolean drawing = false;
Boolean donePlaying = false;

Minim minim;
AudioInput input;
FFT fft;
BeatDetect beat;
Boolean recording = false;
Boolean live = true; // Used to indicate whether or not we'll call spectrum() during the draw
AudioRecorder rec; // To record from mic
AudioPlayer recorded; // The recorded file
AudioMetaData metaData; // MetaData class for recorded audio

float radius;
int beginTimer = 0;
float maxAmp = 0; // Maximum amplitude seen this sketch (Volume)
int maxPitch = 0; // Frequency band of the loudest frequency (~ Pitch)
int clipLen = 0;

PFont font;

void setup() {
  size(900, 800);
  smooth();
  frameRate(60);

  //interesting settings changes:
  // speed1 (0-10), direction1 (0-10)
  speed1 =  0;
  direction1 = 0;
  position1 = 0;
  angle1 = 0;
  r1 = 0;
  a = 1;

  minim = new Minim(this);

  // Font stuff
  font = loadFont("Edmondsans-Bold-48.vlw");
  textFont(font, 20);


  // Record from internal mic
  input = minim.getLineIn(minim.STEREO, 512);

  // Not using, for now
  // a beat detection object SOUND_ENERGY mode with a default sensitivity of 10 milliseconds
  // beat = new BeatDetect();
  // set sensitivity
  //  beat.setSensitivity(0);

  // perform an FFT on the input that was previously saved.
  fft = new FFT(input.bufferSize(), input.sampleRate());

  // load the recorded audio clip. Placed here to avoid null pointer in draw
  recorded = minim.loadFile("test.wav", 512);
}

void draw() {
  background(0);


  if (!drawing) {
    // If the recorded clip isn't currently playing, show a live view of the spectrum
    if (!recorded.isPlaying()) {
      spectrum(input.mix);
      //beatsPerMinute();
    } 
    // If the recorded clip is playing, show the live view of the spectrum and analyze
    // It's done this way because the recorded clip must be playing when the fft is run.
    else {

      // Get the values of the freq bands
      float[] bands = spectrum(recorded.mix);

      // Run the analysis on the bands
      analyze(bands);

      // Print out the max values for pitch and volume, and the length of the clip
      println("loudest pitch: "+maxPitch+" volume of pitch: "+maxAmp+" Length of clip: "+clipLen);
    }
    textAlign(CENTER);

    //Display text and symbol for whether or not recording
    if (recording) {
      fill(100);
      rectMode(CORNER);
      rect(width/2-20, height/2-20, 40, 40);
      text("Recording...Click to stop", width/2, height/2-30);
    } 
    else if (donePlaying) {
      fill(255, 0, 0);
      ellipse(width/2, height/2, 40, 40);
      text("Analyzing sound", width/2, height/2-30);
    }
    else {
      fill(255, 0, 0);
      ellipse(width/2, height/2, 40, 40);
      text("Click to record", width/2, height/2-30);
    }
  }

  if (donePlaying && millis() - clipLen > startMillis) {
     if (position1 >=  r1 || position1 < -r1)  a = - a;
     r1 = int(map(maxAmp, 5, 150, 0, 200));
    //r2 = int(map(maxPitch, 1, 10, 0, 100));
    //speed1 = int(map(maxAmp, 5, 150, 1, 5));
    speed1 = int(map(clipLen, 0, 8000, 0, 10));
    direction1 = int(map(maxPitch, 1, 10,  1, 5))*a;
    

    println(position1+","+r1+","+direction1);


    
    drawArt();
    drawing = true;
   
    textAlign(CORNER);
    textFont(font, 16);
    text("max. volume - size: "+r1, 50, 50);
    // text("max. volume - 1st arm speed: "+speed1,50, 70);
    text("max pitch - arm speed:  "+direction1, 330, 50);
    //text("max pitch - 2nd arm speed: "+speed2,330, 70);
    text("duration - rotation speed: "+speed1, 600, 50);
  }
}





void keyPressed() {

  if (key ==' ') {
    drawing = false;
    donePlaying = false;
  }

  if (key == 'd' ) {
    //empty arrays  
    x = new float [0];
    y = new float [0];
  }
}


// Click the mouse to start and stop recording
void mouseClicked() {
  if (!recording) {
    // Create a new audio recorder
    rec = minim.createRecorder(input, "test.wav", true);
    rec.beginRecord();     // Start recording
  } 
  else {
    rec.endRecord();    // Stop recording
    rec.save();    // Save recording

    // Load the recorded file into memory
    recorded = minim.loadFile("test.wav", 512);

    // Zero out the maxAmp and maxPitch for the next recording
    maxAmp = 0;
    maxPitch = 0;

    // Get the clip length
    clipLen = recorded.getMetaData().length();

    // Playback the recorded file. The clip must be playing when the FFT is run 
    recorded.play();

    // Start playing timer
    startMillis = millis();

    // perform a new FFT on the input that was previously saved.
    fft = new FFT(recorded.bufferSize(), recorded.sampleRate());

    // Toggle Done Playing switch
    donePlaying = true;
  }
  recording = !recording; // Toggle state
}

void stop() {
  // always close Minim audio classes when you are finished with them
  input.close();
  // always stop Minim before exiting
  minim.stop();
  super.stop();
}

