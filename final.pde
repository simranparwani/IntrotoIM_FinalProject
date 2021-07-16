import http.requests.*;
import processing.serial.*;
import processing.sound.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
BeatDetect beat;
BeatListener bl;

int led[] = {16, 17, 18, 19};

Serial myPort;

Scrollbar bar1;
Scrollbar bar2;

int first = 0;
int second = 0;
float lastX = 0;
float lastY = 0;
Button play;
Button dance;
Button draw;

int seconds;
int minutes;

int timer;
int startTime;

int snakeTimer;

PFont lucida;
PFont avenir;
int state = 0;
String response;
void setup() {
  
    size(1200, 800);
      minim = new Minim(this);
arduino = new Arduino(this, Arduino.list()[2], 57600);

  song = minim.loadFile("redbone.mp3", 2048);
  song.play();
    lucida = createFont("Lucida Bright Italic", 36);
    avenir = createFont("Avenir", 12);
    textAlign(CENTER);
    background(#D08C60);
    GetRequest affirm = new GetRequest("https://dulce-affirmations-api.herokuapp.com/affirmation");
    affirm.send();
    response = affirm.getContent();
    response = response.substring(12, response.length() - 3);
    
    
    
    bar1 = new Scrollbar(20, height/10, 300, 16, 1, 60);
    bar2 = new Scrollbar(20, height/10 + 40, 300, 16, 1, 60);
    adjustTime();
    
     play = new Button("PLAY", width/2 - 150, height/3, 300, 80, 2);
     dance = new Button("DANCE", width/2 - 150, height/3 + 120, 300, 80, 3);
     draw = new Button("DRAW", width/2 - 150, height/3 + 240, 300, 80, 4);
     String portname=Serial.list()[2];
      myPort = new Serial(this,portname,9600);
      myPort.clear();
      myPort.bufferUntil('\n');
      delay(1000);

}

void draw(){
  String s=myPort.readStringUntil('\n');
 println(s);
  s=trim(s);
  if (s!=null){
    
    int values[]=int(split(s,','));
    first = values[0];
    second = values[1];
  }
  myPort.write(bar1.getVal() + "\n");
      
  if (state == 0) {
    background(#D08C60);
    bar1.update();
    bar2.update();
    bar1.display();
    bar2.display();

    fill(#F9F1DC);
    textFont(lucida);
      text("A Reminder...", width/2, height - 140);
      //textFont(avenir);
      text(response, width/2, height - 100);
    textAlign(LEFT);  
    textFont(avenir);
    text("intervals to be woken up in", 340, height/10 + 5);
    text("chunk of time to work for", 340, height/10 + 45);
    calculateTime();
  } else if (state == 1) {
      background(#F1DCA7);
      textFont(avenir);
      textSize(72);
      fill(#997B66);
      text("Time for a break!", width/2, height/8);
      play.display();
      dance.display();
      draw.display();
      play.update();
      dance.update();
      draw.update();
  } else if (state == 2) {
    
      textFont(avenir);
      textSize(42);
      fill(#997B66);
      text("Time for a break. Use the potentiometers to etch a sketch", width/2, height/8);
      textSize(36);
      text("Click ENTER to clear and SPACE to get back to work.", width/2, height/8 + 65);
      
      
      
      float x = map(first, 0, 1023, 0, width);
      float y = map(second, 0, 1023, height/4, height);
      
      stroke(random(0,255), random(0,255), random(0,255));
      line(x, y, lastX, lastY);
      lastX = x;
      lastY = y;
  } 
}

class Scrollbar {
  int sw;
  int sh;
  float xpos;
  float ypos;
  float slider_pos;
  float newpos;
  float sliderMin;
  float sliderMax;
  boolean mouseOnTop;
  boolean moved;
  boolean posChanged;
  int sValMin;
  int sValMax;
  
  Scrollbar(float x, float y, int w, int h, int minVal, int maxVal) {
    sw = w;
    sh = h;
    xpos = x;
    ypos = y - sh/2;
    slider_pos = xpos + sw/2 + sh/2;
    newpos = slider_pos;
    sliderMin = xpos;
    sliderMax = xpos + sw;
    sValMin = minVal;
    sValMax = maxVal;
    posChanged = false;
  }
  
  void update() {
    if (overEvent()) {
      mouseOnTop = true;
    } else {
      mouseOnTop = false;
    }
    
    if (mousePressed && mouseOnTop) {
      moved = true;
    }
    
    if (!mousePressed) {
      moved = false;
    }
    
    if (moved) {
      newpos = constrain(mouseX - sh/2, sliderMin, sliderMax);
    }
    
    if (abs(newpos - slider_pos) > 1) {
      slider_pos += (newpos -slider_pos);  
      adjustTime();
    }
    

  }
  
  float constrain(float val, float smin, float smax) {
    return min(max(val, smin), smax);
  }
  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos + sw && mouseY > ypos && mouseY < ypos + sh) {
      return true;
    } else {
      return false;
    }
  }
  
  void display() {
    noStroke();
    fill(200);
    rect(xpos, ypos, sw,sh);
    fill(#9B9B7A);
    ellipse(slider_pos, ypos + sh/2, 1.5 *sh, 1.5*sh);
    fill(255);
   textAlign(CENTER);
    textFont(avenir);
    text(getVal(), slider_pos, ypos + sh/1.5);
  }
  
  int getVal() {
    float mapVal = map(slider_pos, xpos, xpos + sw, sValMin, sValMax);
    return int(mapVal);
  }
 
}

void adjustTime() {
  timer = bar2.getVal();
  startTime = millis();
  
  
}

void calculateTime() {
  seconds = 60 - ((millis() - startTime)/1000) % 60;
  minutes = timer - 1 - ((millis() - startTime) / 60000);
  
  textFont(avenir);
  textSize(240);
  textAlign(CENTER, BOTTOM);
  if (seconds == 60) {
    text(minutes + 1 + ":00", width/2, 2*height /3);
  } else if (seconds < 10) {
  text(minutes + ":0" + seconds, width/2, 2*height /3);
  } else {
    text(minutes + ":" + seconds, width/2, 2*height /3);
  }
  if (seconds == 60 && minutes <= 0) {
    state = 1;
    background(#F1DCA7);
  }
}


class Button {
  String msg;
  int xpos;
  int ypos;
  int w;
  int h;
  int cntl;
  
  Button(String words, int x, int y, int w_, int h_, int st) {
    msg = words;
    xpos = x;
    ypos = y;
    w = w_;
    h = h_;
    cntl = st;
  }
  
  void display() {
    noStroke();
    if (mouseX > xpos && mouseX < xpos + w && mouseY > ypos && mouseY < ypos + h) {
      fill(#7A6352);
    } else {
      fill(#997B66);
    }
    rect(xpos, ypos, w, h);
    textAlign(CENTER, CENTER);
    fill(#F1DCA7);
    text(msg, xpos + w/2, ypos + h/3);
  }
  
  void update() {
    if (mousePressed && mouseX > xpos && mouseX < xpos + w && mouseY > ypos && mouseY < ypos + h) {
      state = cntl;
      background(#F1DCA7);
    }
  }
}

//class Snake {
//  int len;
//  int xdir;
//  int ydir;
//  int h;
//  int w;
//  int xpos;
//  int ypos;
  
//  Snake() {
//     len = 1;
//  xdir = 0;;
//  ydir = 0;
//  h = 20;
// w = 20;
// xpos = width/2;
// ypos = height/2;
//  }
  
//  void display(){
//    noStroke();
//    fill(#797D62);
//    rect(xpos, ypos, w, h);
//  }
//}

//void newFood() {
//  int x = floor(random(width));
//  int y = floor(random(height/4, height));
//  fill(#D08C60);
//  ellipse(x, y, 20, 20);
//}

void keyPressed() {
  if (state == 2) {
    if (key == ' ') {
      state = 0;
    }
    else if (key == ENTER) {
    background(#F1DCA7); 
    }
  }
}
void serialEvent(Serial myPort){
 String s=myPort.readStringUntil('\n');
 println(s);
  s=trim(s);
  if (s!=null){
    
    int values[]=int(split(s,','));
    first = values[0];
    second = values[1];
  }
  myPort.write(bar1.getVal() + "\n");
}
