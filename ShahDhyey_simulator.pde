import beads.*;
import controlP5.*;
import org.jaudiolibs.beads.*;
import java.util.*;
import guru.ttslib.*;

ControlP5 cp5;

Gain masterGain;
Glide gainGlide;
String[] soundsToPlay;
boolean soundPlaying = false;
Glide filterGlide;
BiquadFilter filter;
Reverb reverb;
PImage img;
int currentIndex;

void setup() {
  size(600,300);
  ac = new AudioContext();
  cp5 = new ControlP5(this);
  img = loadImage("basketball.jpg");
  currentIndex = 0;
  
  soundsToPlay = new String[3];
  soundsToPlay[0] = "bing1.wav";
  soundsToPlay[1] = "bing2.wav";
  soundsToPlay[2] = "bing3.wav";
  
  gainGlide = new Glide(ac, 1.0, 500);
  masterGain = new Gain(ac, 1, gainGlide);
  filterGlide = new Glide(ac, 10.0, 500);
  filter = new BiquadFilter(ac, BiquadFilter.AP, filterGlide, 0.5);
  reverb = new Reverb(ac,1);
  
  ac.out.addInput(filter);
  ac.out.addInput(reverb);
  ac.out.addInput(masterGain);
  
  cp5.addButton("Play")
   .setPosition(400,100)
   .setSize(140,20)
   .setLabel("Play")
   .activateBy((ControlP5.RELEASE));
  cp5.addSlider("LegsSlider")
   .setPosition(20,20)
   .setSize(40,200)
   .setRange(0,100)
   .setValue(0)
   .setLabel("Legs");
  cp5.addSlider("ShouldersSlider")
   .setPosition(120,20)
   .setSize(40,200)
   .setRange(0,100)
   .setValue(0)
   .setLabel("Shoulders");
  cp5.addSlider("FollowSlider")
   .setPosition(220,20)
   .setSize(40,200)
   .setRange(0,100)
   .setValue(0)
   .setLabel("Follow-Thru");
  
  ac.start();
}

public void LegsSlider(float value) {
  gainGlide.setValue((100.0-value)/100.0);
}

public void ShouldersSlider(float value) {
  filter.setType(BiquadFilter.HP);
  filterGlide.setValue((100-value)*100.0);
}

public void FollowSlider(float value) {
  reverb.setSize(1.0);
  reverb.setDamping(1.0);
  reverb.setEarlyReflectionsLevel(1.0);
  reverb.setLateReverbLevel(value/50.0);
  if (value == 0.0) {
    reverb.setSize(0);
    reverb.setDamping(0);
    reverb.setEarlyReflectionsLevel(0);
    reverb.setLateReverbLevel(0);
  }
}

public void Play() {
  TTS tts = new TTS();
  tts.speak("GET READY... 3... 2... 1...");
  currentIndex = 0;
  PlayMultiple();
}

public void PlayMultiple() {
  if (currentIndex < 3) {
    String soundFile = soundsToPlay[currentIndex];
    SamplePlayer sound = getSamplePlayer(soundFile, true);
    sound.pause(true);
    
    masterGain.addInput(sound);
    if (currentIndex == 1)
      filter.addInput(sound);
    if (currentIndex == 2)
      reverb.addInput(sound);
    currentIndex++;
    
    Bead endListener = new Bead() {
      public void messageReceived(Bead message) {
        SamplePlayer sp = (SamplePlayer) message;
        sp.setEndListener(null);
        println("Done playing " + sp.getSample().getFileName());
        PlayMultiple();
      }
    };
    soundPlaying = true;
    sound.setEndListener(endListener);
    sound.start();
  }
  else {
    soundPlaying = false;
  }  
}

void draw() {
  background(0,0);
  image(img,400,150, img.width/3, img.height/3);
}
