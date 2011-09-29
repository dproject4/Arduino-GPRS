/*
       Team 4 Flood Warning System
       Member 1:                                  Member 4:
       Member 2:Qinghui Zhou                      Member 5:
       Member 3:                                  Member 7:       
*/

#include <NewSoftSerial.h>
#include <Wire.h>
#include <LiquidCrystal.h>

/*
1. In new soft serial, pin 6 is rx, pin 7 is tx
2. For sensor pins, Pin 9 is connected to Trig, Pin 10 is connected to Echo

How to connect LCD to Arduino
PINs  LCD  Arduino
      1    5V

          


*/

//NewSoftSerial GPRS_Serial(6,7);
int Pin=9,Pin2=10;  
LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
int normal_delay=5000;
int emergency_delay=1000;
float alert_level;
//char SMS_warning='Flood incoming';  //Enter the message to send
//char Mobile_num='+61433100616';        //Set the Target Mobile number here


void setup()
{
  Serial.begin(9600);
  pinMode(Pin,OUTPUT);
  pinMode(Pin2,INPUT);
  alert_level=alertHeight(get_data());
  
  Serial.println("Turn on GPRS Modem and wait for 1 minute.");
  delay(1000);
  
  Serial.flush();
  delay(1000);
   
  Serial.println("ATE0\r"); //Command echo off
  Serial.println("ATE0\r Sent!");
  connection_check(4,10);
  
  Serial.println("AT+CIPMUX=0\r"); //We only want a single IP connection
  Serial.println("AT+CIPMUX=0\r Sent!");
  connection_check(4,10);
    
  Serial.println("AT+CIPMODE=0\r"); //Selecting Normal Mode
  Serial.println("AT+CIPMODE=0\r Sent!");
  connection_check(4,10);
  
  Serial.println("AT+CGDCONT=1,\"IP\",\"internet\",\"202.139.83.3\",0,0\r");
  Serial.println("AT+CGDCONT=1,\"IP\",\"internet\",\"202.139.83.3\",0,0\r Sent!");
  connection_check(4,10);
  
  Serial.println("AT+CSTT=\"internet\"\r"); //Start Task and set Access Point Name
  Serial.println("AT+CSTT=\"internet\"\r Sent!");
  connection_check(4,10);
  
  Serial.println("AT+CIICR\r");
  Serial.println("AT+CIICR\r Sent!");
  connection_check(4,10);
  
  Serial.println("AT+CIFSR\r");
  Serial.println("AT+CIFSR\r Sent!");
  connection_check(4,10);  
}

void loop()
{
  boolean safe;
  //float distance;  //Distance between sensor and water in Centimeter;
  safe=safety_check(get_data(),alert_level);
 
  Serial.print("distance:");
  Serial.print(get_data());
  Serial.print("\n");
  
  Serial.println("AT+CIPSTART=\"TCP\",\"api.pachube.com\",\"80\""); //Open a connection to Pachube.com  
  connection_check(12,255); //was 255
  
  Serial.flush();
  Serial.println("AT+CIPSEND\r"); //Start data through TCP connection
  connection_check(1,100);
  
  Serial.flush();
  upload_data();
  
  if(safe)
  {
    Serial.println("Safe Now");
    delay(normal_delay); // Wait for a period of time, the restart the steps
  }
  
  else
  {
    Serial.println("Flooding incoming");
    send_SMS();
    delay(emergency_delay); // Shorter the delay, to send data more frequently
  }
  
}


//***********************************************************************************************
// Functions for GPRS connection checking

char Serial_wait_for_bytes(char no_of_bytes,int timeout)
{
  while(Serial.available()<no_of_bytes)
  {
    delay(200);
    timeout-=1;
    if(timeout==0)
    {
      return 0;
    }
  }
  return 1;
}


char connection_check(char no_of_bytes,int timeout)
{
  if(Serial_wait_for_bytes(no_of_bytes,timeout) == 0) 
  {
    Serial.println("Timeout"); 
  }
  else
  {
    Serial.print("Received:"); 
    while(Serial.available()!=0) 
    {
      Serial.print((unsigned char)Serial.read()); 
    }
  }
}

//***********************************************************************************************

//***********************************************************************************************
//Functions for Sensor, and data calculation

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
    Serial.print("\ntoo high, The next data will be sent once every 5 Mins\n");
    delay(emergency_delay);
    return safe=true;
    
  }
  else
  {
    Serial.print("\n\nDistance to the river is:");
    Serial.print(distance);
    Serial.print("\nsafe, The next data will be sent after 15 Mins\n");
    delay(normal_delay);
    return safe=false;
  }
}

float alertHeight(float data)
{
  float total=0;
  float average;
  for(int counter=0;counter<3;counter++)
  {
    total+=data;
    delay(2000); //wait for the sensor to get data
  }
  average=total/3;
  
  return average*(1/5);
}

//***********************************************************************************************

//***********************************************************************************************
//Functions for LCD

void show(float distance)
{
    lcd.print("The distance is:");
    lcd.setCursor(0, 1);
    lcd.print(distance);
    //Serial.print("\nThe water level is too high, The next data will be sent once every 5 Mins instead of 15 Mins!");
    delay(1000);
}

//***********************************************************************************************

//***********************************************************************************************
// Functions for sending SMS

void send_SMS()
{
  Serial.flush();
  delay(1000);
  Serial.println("AT+CMGF=1\r"); //Change to TEXT mode
  delay(1000);  
  Serial.print("AT+CMGS=\"+61433681377\"\r\t");
  delay(1000);
  Serial.print("FLood Incoming!\r");
  delay(1000);
  Serial.print(26,BYTE); //Equivalent to sending Ctrl+Z
}
//***********************************************************************************************

//***********************************************************************************************
// Functions for uploading data
// Emulate HTTP and use PUT command to upload temperature datapoint using Comma Seperate Value Method
  
void upload_data()
{
  Serial.println("\n");
  Serial.println("PUT /v2/feeds/36575.csv HTTP/1.1\r\n");
  delay(300);
 
  Serial.println("Host: api.pachube.com\r\n");
  delay(300);
 
  Serial.println("X-PachubeApiKey: _0mW-sxmvv-Cl67tzfpJuHProFX7HNdgAJd3foGuj-0\r\n"); //REPLACE THIS KEY WITH YOUR OWN PACHUBE API KEY
  delay(300);
  
  Serial.print("Content-Length: 12\r\n");
  delay(300);
  Serial.print("Connection: close\r\n\r\n");
  delay(300);

  Serial.print("distance: "); 
  delay(300);
  Serial.print(get_data());
  delay(300);
  Serial.print("\r\n"); 
  delay(300);
  Serial.print("\r\n"); 
  delay(300);
  Serial.print(0x1A,BYTE);
  delay(300); //Send End Of Line Character to send all the data and close connection
  connection_check(20,255);
  
}  
//***********************************************************************************************


