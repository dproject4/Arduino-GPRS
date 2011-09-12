#include <LiquidCrystal.h>

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);//pin 2,3,4,5 connect to 11,12,13,14. (LCD)Pin 1 is 5V, Pin 2 is ground, Pin 3 is prxxxx
                                      //Arduino Pin 12 to LCD pin 4, arduino Pin 11 to LCD pin 6, Lcd pin 5 ground.
int Pin=8;                          //Pin 8 connected to Trig
int Pin2=7;                         //Pin 7 connected to Echo
int Led=13;                         //pin connected to LED

void setup()
{
  Serial.begin(9600);
  pinMode(Led,OUTPUT);
  pinMode(Pin,OUTPUT);
  pinMode(Pin2,INPUT);
  lcd.begin(16, 2);

}

void loop()
{
  lcd.setCursor(0, 0);
  float distance;                   //distance between Sensor and Water in Centimeter;
  distance=get_data();              //get the distance  
  flash_rate(distance);             //flash_rate depends on distance
  
  show(distance);
  //average(distance);
  
}

int get_data()                     //get Data from Senor in centimeter
{
  float CM;                         // CM means centimeter, how far is the object to the senor
  float duration;                   // The time it takes for the signal to travel and back
  
  digitalWrite(Pin,LOW);           // Give a short low signal first, to make sure we get clean result later
  delayMicroseconds(2);            // wait for 2 ms
  digitalWrite(Pin,HIGH);          
  delayMicroseconds(5);            // wait for 5 ms
  
  
  duration=pulseIn(Pin2,HIGH);     /* The sensor sends signal out when the Echo Pin is high
                                      Then the timer starts
                                      The signal travel out, and reflect back when it touchs an object
                                      Then signal comes back to sensor, and timer stops
                                      So we get the duration in Microsecond */

  CM=duration/29.00/2.00;                /* The speed of sound is 340 m/s or 29 microseconds per centimeter
                                      The signal travels out and back, so need to divide by 2 */
                                      
  return CM;
}

void flash_rate(float flash_rate)
{
  digitalWrite(Led,HIGH);           //Turn on the LED; which is PIN 13
  delay(flash_rate*10);             //The flash rate depends on the distance between sensor and water
  digitalWrite(Led,LOW);            //Turn off
  delay(flash_rate*10);
}

void show(float distance)
{
    lcd.print("The distance is:");
    lcd.setCursor(0, 1);
    lcd.print(distance);
    //Serial.print("\nThe water level is too high, The next data will be sent once every 5 Mins instead of 15 Mins!");
    delay(1000);
}

    
    
    
  
  
  
  
  
  
