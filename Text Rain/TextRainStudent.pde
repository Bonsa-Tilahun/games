/**
 CSCI 4611 Spring '16 Assignment #1: Text Rain
 **/


import processing.video.*;
import java.util.List;

// START my classes

// A class representing a letter and its position on the screen
class Letter {
  int x;
  int y;
  char c;
  color col;
  float v;

  Letter(int x, int y, char c, color col) {
    this.x = x;
    this.y = y;
    this.c = c;
    this.col = col;
    v = VELOCITY;
  }

  void update() {
    if (!isSolid(x, y)) {
      v += GRAVITY*dt;
      int newY = y + (int) (dt*v);
      while (!isSolid(x, y+1) && y < newY) y++;
    } else {
      v = 0;
      while (isSolid(x, y) && y > 0) y --;
    }
    if (y > height + 50) toRm.add(this);
  }

  void draw() {
    fill(col);
    text(c, x, y);
  }
}
// END my classes

// Global variables for handling video data and the input selection screen
String[] cameras;
Capture cam;
Movie mov;
PImage inputImage;
boolean inputMethodSelected = false;

// START my vars
static final String ALPHABET = "abcdefghijklmnopqrstuvwxyz";
static final String[] WORDS =("rain fun pretty wonderful hello cat water flower art technology java why purpose destiny fate logical"+
  "question reasoning math proof noise transcendence think play discover love 42").split(" ");
static final float VELOCITY = 50; // pixels per second
static final float GRAVITY = 100; // px.s-2
static final int SPAWN_PERIOD = 400; // ms
static final int MAX_LETTERS = 200; // to prevent keeping to many letters
static final int TO_PLAN = 10;

PFont font;
List<Letter> letters;
List<Letter> toRm;
List<Letter> planned;
PImage processedImg;
int threshold;
boolean debug;
double lastSpawn;
double lastTime;
double dt;
boolean flip;
// END my vars


void setup() {
  size(1280, 720);  
  inputImage = createImage(width, height, RGB);

  // My setup
  font = createFont("consola.ttf", 32);
  textFont(font, 16);
  letters = new ArrayList();
  toRm = new ArrayList();
  planned = new ArrayList();
  processedImg = createImage(width, height, RGB);
  threshold = 128;
  debug = false;
  lastSpawn = millis();
  lastTime = millis();
}


void draw() {
  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y=40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40; 
    for (int i = 0; i < min(9, cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    // START MY CODE prevent letters from spawning because of waiting time in selection

    // END   MY CODE
    return;
  }


  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.


  // STEP 1.  Load an image, either from a movie file or from a live camera feed. Store the result in the inputImage variable

  if ((cam != null) && (cam.available())) {
    cam.read();
    inputImage.copy(cam, 0, 0, cam.width, cam.height, 0, 0, inputImage.width, inputImage.height);
    flip = true;
  } else if ((mov != null) && (mov.available())) {
    mov.read();
    inputImage.copy(mov, 0, 0, mov.width, mov.height, 0, 0, inputImage.width, inputImage.height);
    flip = false;
  }


  // Fill in your code to implement the rest of TextRain here..
  // Tip: This code draws the current input image to the screen
  processImage();
  int t = millis();
  dt = (t - lastTime) / 1000.0;
  while (lastSpawn < t) {
    spawnLetter();
    lastSpawn += SPAWN_PERIOD;
  }
  for (Letter l : letters) {
    l.update();
  }
  letters.removeAll(toRm);
  toRm.clear();
  while (letters.size() > MAX_LETTERS) letters.remove(0);
  lastTime = t;
  if (!debug) {
    if (flip) {
      pushMatrix();
      scale(-1, 1);
      image(inputImage, -width, 0);
      popMatrix();
    } else image(inputImage, 0, 0);
  }
  for (Letter l : letters) {
    l.draw();
  }
}



void keyPressed() {

  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        mov = new Movie(this, "TextRainInput.mov");
        mov.loop();
        inputMethodSelected = true;
      } else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");           
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
    }
    return;
  }


  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  // Fill in your code to handle keypresses here..

  if (key == CODED) {
    if (keyCode == UP) {
      // up arrow key pressed
      threshold = min(threshold + 10, 255);
    } else if (keyCode == DOWN) {
      // down arrow key pressed
      threshold = max(threshold - 10, 0);
    }
  } else if (key == ' ') {
    // space bar pressed
    debug = !debug;
  }
}

// START my functions
void spawnLetter() {
  if (random(1) > .5) {
    while (planned.size() < TO_PLAN) {
      planWord(WORDS[int(random(WORDS.length))]);
    }
    letters.add(planned.remove(int(random(planned.size()))));
  } else {
    int x = int(random(width));
    char c = ALPHABET.charAt(int(random(ALPHABET.length())));
    color col = color(int(random(256)), int(random(256)), int(random(256)));
    letters.add(new Letter(x, 0, c, col));
  }
}

void planWord(String w) {
  int x = int(random(width));
  color col = color(int(random(256)), int(random(256)), int(random(256)));
  for (int i = 0; i < w.length(); i++) {
    planned.add(new Letter(x + i*15, 0, w.charAt(i), col));
  }
}

boolean isSolid(int x, int y) {
  if (x < 0 || y < 0 || x >= width || y >= height) return false;
  return greyMean(pixels[x+width*y]) <= threshold;
}

void processImage() {
  processedImg = inputImage.copy();
  if (flip) {
    pushMatrix();
    scale(-1, 1);
    image(inputImage, -width, 0);
    popMatrix();
  } else image(inputImage, 0, 0);
  filter(THRESHOLD, threshold / 256.0);
  loadPixels();
}

// Compute the grey matching the color
int greyMean(color col) {
  int r = (col >> 8) & 0xFF;
  int g = (col >> 4) & 0xFF;
  int b = (col     ) & 0xFF;
  return (r + g + b) / 3;
}
// END my functions