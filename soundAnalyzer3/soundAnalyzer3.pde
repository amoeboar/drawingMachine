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
  size(500, 500);
  frameRate(60);
  minim = new Minim(this);

  // Font stuff
  font = loadFont("Edmondsans-Bold-48.vlw");
  textFont(font, 20);
  textAlign(CENTER);
  
  
  // Record from internal mic
  input = minim.getLineIn(minim.STEREO, 512);

  // Not using, for now
  // a beat detection object SOUND_ENERGY mode with a default sensitivity of 10 milliseconds
  // beat = new BeatDetect();
  // set sensitivity
  // beat.setSensitivity(0);

  // perform an FFT on the input that was previously saved.
  fft = new FFT(input.bufferSize(), input.sampleRate());

  // load the recorded audio clip. Placed here to avoid null pointer in draw
  recorded = minim.loadFile("test.wav", 512);
}

void draw() {
  background(0);

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
  
  //Display text and symbol for whether or not recording
  if (recording) {
    fill(100);
    rect(width/2-20, height/2-20, 40, 40);
    text("Recording...Click to stop", width/2, height/2-30);
  } 
  else {
    fill(255, 0, 0);
    ellipse(width/2, height/2, 40, 40);
    text("Click to record", width/2, height/2-30);
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
    
    // perform a new FFT on the input that was previously saved.
    fft = new FFT(recorded.bufferSize(), recorded.sampleRate());
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

