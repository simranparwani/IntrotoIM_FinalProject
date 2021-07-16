#include <CapacitiveSensor.h>
#include <SparkFun_TB6612.h>
//#include <LiquidCrystal.h>      

#define AIN1 2
#define BIN1 7
#define AIN2 4
#define BIN2 8
#define PWMA 5
#define PWMB 6
#define STBY 9

 
//LiquidCrystal lcd(19, 18, 17, 16,11, 3);   
// these constants are used to allow you to make your motor configuration 
// line up with function names like forward.  Value can be 1 or -1
const int offsetA = 1;
const int offsetB = 1;
int duration = 2000;
Motor motor1 = Motor(AIN1, AIN2, PWMA, offsetA, STBY);
Motor motor2 = Motor(BIN1, BIN2, PWMB, offsetB, STBY);
int pressed = 0;
long timer;
int threshold = 30;
int timeLength = 10000;
int minutes;
int sec;
CapacitiveSensor   cs_4_2 = CapacitiveSensor(10,12);        //12 is sensor pin
int count = 0;
int piezoPin = 3;

int pot1 = A4;
int pot2 = A5;

void setup()                    
{
   cs_4_2.set_CS_AutocaL_Millis(0xFFFFFFFF);     // turn off autocalibrate on channel 1 - just as an example
   Serial.begin(9600);
   Serial.println(0,0);

//   lcd.begin(16, 2);                 //tell the lcd library that we are using a display that is 16 characters wide and 2 characters high
//  lcd.clear();                      //clear the display
}

void loop()  {
//   while (Serial.available()) {
    
//    timeLength = Serial.parseInt();
//    timeLength *= 60000;

//    if (Serial.read() == '\n') {
  int val1 = analogRead(pot1);
//  Serial.print(val1);
//  Serial.print(",");
  int val2 = analogRead(pot2);
  Serial.write(val1);
  Serial.write(val2);
//  Serial.println(val2);
//   }
//    
//  }

  
//   lcd.setCursor(0, 1);              
//  lcd.print(timeLength);
//  
    long start = millis();
    long cap =  cs_4_2.capacitiveSensor(30);
    if (cap > threshold && pressed != 1){
       
      pressed = 1;
      timer = millis();
      count = 0;

    } else if (cap > threshold && pressed == 1) {
      pressed = 1;
    } else if (cap < threshold && pressed == 1) {
      pressed = 0;
    }
  if (pressed == 1) {
//   lcd.setCursor(0, 0);              
//  lcd.print("sensor on");
//  lcd.setCursor(0, 1);              
//  lcd.print(timeLength);
  if (millis() - timer >= timeLength) {
    timer = millis();
    
   level(count);
   count += 1;
  }
  }  
}

void level(int count) {
  switch(count){
  case 0:
    vibrate(0);
    break;
  case 1:
    vibrate(1);
    break;
  case 2:
    vibrate(2);
    break;
  case 3:
    vibrate(2);
    tone(piezoPin, 200, duration);
    break;
  default:
    vibrate(3);
    tone(piezoPin, 500, duration);
    break;
  }
}
void vibrate(int level) {
  int sp = 0;
  if (level == 0) {
    sp = 75;
  } else if (level == 1) {
    sp = 120;
  } else if (level == 2) {
    sp = 180;
  } else {
  
    sp = 255;
  }

  motor1.drive(sp,duration);
  motor2.drive(sp,duration);
  motor1.brake();
  motor2.brake();
}
