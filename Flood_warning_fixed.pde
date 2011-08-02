/*
       Team 4 Flood Warning System
       Member 1:                                  Member 4:
       Member 2:                                  Member 5:
       Member 3:                                  Member 7:       
*/



int Pin=8;                          //Pin 8 connected to Trig
int Pin2=7;                         //Pin 7 connected to Echo
int Led=13;                         //pin connected to LED

int normal_delay=5000;               // delay time for normal situation 
int emergency_delay=1000;            // delay time for emergency
int warning_distance=10;             // Lower than this distance, go into emergency mode


void setup()
{
  Serial.begin(9600);
  pinMode(Led,OUTPUT);
  pinMode(Pin,OUTPUT);
  pinMode(Pin2,INPUT);
}

void loop()
{
  float distance;                   //distance between Sensor and Water in Centimeter;
  distance=get_data();              //get the distance  
  flash_rate(distance);             //flash_rate depends on distance
  
  safety_check(distance,warning_distance);
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

  CM=duration/29/2;                /* The speed of sound is 340 m/s or 29 microseconds per centimeter
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

void safety_check(float distance,int warning_distance)
{
  if(distance<warning_distance)
  {
    Serial.print("\n\nThe distance to the river is:");
    Serial.print(distance);
    Serial.print("\nThe water level is too high, The next data will be sent once every 5 Mins instead of 15 Mins!");
    delay(emergency_delay);
  }
  else
  {
    Serial.print("\n\nThe distance to the river is:");
    Serial.print(distance);
    Serial.print("\nThe water level is safe, The next data will be sent after 15 Mins!");
    delay(normal_delay);
  }
}

/*void average(float distance)
{
  int counter;
  float total=0;
  float average;
  for(counter=0;counter<3;counter++)
  {
    if(counter>3)
    {
      counter=0;
      Serial.print("\nThe Average level for the last hour is:");
      Serial.print(average);
    }
    total+=distance;
    average=total/(counter+1);
  }
}*/
    
    
    
  
  
  
  
  
  
