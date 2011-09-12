/*
       Team 4 Flood Warning System
       Member 1:                                  Member 4:
       Member 2:Qinghui Zhou                      Member 5:
       Member 3:                                  Member 7:       
*/

#include <NewSoftSerial.h>          //Used the library of NewSoftSerial

NewSoftSerial debugSerial(2,3);     //define the rx/tx pins (rx,tx)

int Pin=8;                          //Pin 8 connected to Trig
int Pin2=7;                         //Pin 7 connected to Echo

int normal_delay=5000;               // delay time for normal situation 
int emergency_delay=1000;            // delay time for emergency
//float waterLevel[3];             // two time higher than this distance, go into emergency mode

float alert_level;

void boardSetting();                    //Change the setting of SIM300
float alertHeight(float data);          //Set the height of river, which makes the alarm warning
float get_data();                       //get data from sensor
float safey_check(float distance,int warning_distance);  //check if the current water height is safe
void connection_whenSafe();
void connection_whenNotSafe();


void setup()
{
  Serial.begin(19200);
  debugSerial.begin(19200);
  pinMode(Pin,OUTPUT);
  pinMode(Pin2,INPUT);
  boardSetting();
  alert_level=alertHeight(get_data()); 
}

void loop()
{
  boolean safe;
  float distance;                   //distance between Sensor and Water in Centimeter;
  distance=get_data();              //get the distance  
  
  safe=safety_check(distance,alert_level);
  
  if(safe)
  {
    connection_whenSafe(); 
  }
  if(!safe)
  {
    connection_whenNotSafe();
  }     
}







float get_data()                     //get Data from Senor in centimeter
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


int safety_check(float distance,int warning_distance)
{
  boolean safe;
  if(distance<warning_distance)
  {
    Serial.print("\n\nDistance to the river is:");
    Serial.print(distance);
    Serial.print("\ntoo high, The next data will be sent once every 5 Mins");
    delay(emergency_delay);
    return safe=true;
    
  }
  else
  {
    Serial.print("\n\nDistance to the river is:");
    Serial.print(distance);
    Serial.print("\nsafe, The next data will be sent after 15 Mins");
    delay(normal_delay);
    return safe=false;
  }
}

void boardSetting()           
{
  delay(1000);
  Serial.println("AT+IFC=1,1");
  delay(1000);
  Serial.println("AT+IPR=19200");
  delay(1000);
  Serial.println("AT&W");
  delay(2000);
}
    
float alertHeight(float data)
{
  float total=0;
  float average;
  for(int counter=0;counter<3;counter++)
  {
    total+=data;
    delay(10000); //wait for the sensor to get data
  }
  average=total/3;
  
  return average*2;
}

void connection_whenSafe()
{
  if(Serial.available())
  {
    Serial.println(debugSerial.read());
    delay(1000);
    //put AT commands here
    //connect to google.doc or send SMS
  }
  
  if(!Serial.available())
  {
    Serial.println("Connection failed");
    delay(1000);
    //use AT command to shutdown or into sleep mode
  }
}

void connection_whenNotSafe()
{
  if(Serial.available())
  {
    Serial.println(debugSerial.read());
    delay(1000);
    //put AT commands here
    //connect to google.doc or send SMS
  }
  
  if(!Serial.available())
  {
    Serial.println("Connection failed");
    delay(1000);
    //use AT command to shutdown or into sleep mode
  }
}
  
  
  
  
  
  
