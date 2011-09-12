//Replace the following items in the code:
//1. Optus APN is  "internet" 
//Optus DNS server name is "202.139.83.3" in the AT+CGDCONT and AT+CSTT
//commands with those of your own service provider.
//
//2. Replace the Pachube API Key with your personal ones assigned
//to your account at pachube.com - Done
//
//3. You may choose a different name for the the data stream.
//I have choosen "WaterLevel". If you use a different name, you will have
//to replace this string with the new name.
//
 
#include <NewSoftSerial.h>
#include "WaterLevel.h"
//Please fetch WaterLevel.h and WaterLevel.cpp from "Stlker logger AM06 Serial.zip"
//available from Seeeduino Stalker v2.0's Wiki Page
#include <Wire.h>
 
 
float convertedtemp; // We then need to multiply our two bytes by a scaling factor, mentioned in the datasheet.
int WaterLevel_val; // an int is capable of storing two bytes, this is where we "chuck" the two bytes together.
 
NewSoftSerial GPRS_Serial(7, 8);
 
void setup()
{
  GPRS_Serial.begin(19200);  //GPRS Shield baud rate
  Serial.begin(19200);
  WaterLevel_init();
 
setup_start:
 
  Serial.println("Turn on GPRS Modem and wait for 1 minute.");
  Serial.println("and then press a key");
  Serial.println("Press c for power on configuration");
  Serial.println("press any other key for uploading");
  Serial.flush();
  while(Serial.available() == 0);
  if(Serial.read()=='c')
  {
    Serial.println("Executing AT Commands for one time power on configuration");
 
 
 
    GPRS_Serial.flush();
 
 
 
    GPRS_Serial.println("ATE0"); //Command echo off
    Serial.println("ATE0   Sent");
    if(GPRS_Serial_wait_for_bytes(4,10) == 0)
    {  
      Serial.println("Timeout");
      goto setup_start;
    }
    else
    {
      Serial.print("Received:");
      while(GPRS_Serial.available()!=0)
      {
        Serial.print((unsigned char)GPRS_Serial.read());
        Serial.print("\n");
      }
    }
 
 
 
 
 
 
    GPRS_Serial.println("AT+CIPMUX=0"); //We only want a single IP Connection at a time.
    Serial.println("AT+CIPMUX=0   Sent");
    if(GPRS_Serial_wait_for_bytes(4,10) == 0)
    {  
      Serial.println("Timeout");
      goto setup_start;
    }
    else
    {
      Serial.print("Received:");
      while(GPRS_Serial.available()!=0)
      {
        Serial.print((unsigned char)GPRS_Serial.read());
        Serial.print("\n");
      }
    }
 
 
 
 
 
 
    GPRS_Serial.println("AT+CIPMODE=0"); //Selecting "Normal Mode" and NOT "Transparent Mode" as the TCP/IP Application Mode
    Serial.println("AT+CIPMODE=0    Sent!");
    if(GPRS_Serial_wait_for_bytes(4,10) == 0)
    {  
      Serial.println("Timeout");
      goto setup_start;
    }
    else
    {
      Serial.print("Received:");
      while(GPRS_Serial.available()!=0)
      {
        Serial.print((unsigned char)GPRS_Serial.read());
        Serial.print("\n");
      }
    }
 
 
 
 
 
 
    GPRS_Serial.println("AT+CGDCONT=1,\"IP\",\"internet\",\"202.139.83.3\",0,0"); //Defining the Packet Data
//Protocol Context - i.e. the Protocol Type, Access Point Name and IP Address
    Serial.println("AT+CGDCONT=1,\"IP\",\"internet\",\"202.139.83.3\",0,0   Sent!");
    if(GPRS_Serial_wait_for_bytes(4,10) == 0)
    {  
      Serial.println("Timeout");
      goto setup_start;
    }
    else
    {
      Serial.print("Received:");
      while(GPRS_Serial.available()!=0)
      {
        Serial.print((unsigned char)GPRS_Serial.read());
        Serial.print("\n");
      }
    }
 
 
 
 
 
 
    GPRS_Serial.println("AT+CSTT=\"internet\""); //Start Task and set Access Point Name (and username and password if any)
    Serial.println("AT+CSTT=\"internet\"   Sent!");
    if(GPRS_Serial_wait_for_bytes(4,10) == 0)
    {  
      Serial.println("Timeout");
      goto setup_start;
    }
    else
    {
      Serial.print("Received:");
      while(GPRS_Serial.available()!=0)
      {
        Serial.print((unsigned char)GPRS_Serial.read());
        Serial.print("\n");
      }
    }
 
 
 
 
 
 
    GPRS_Serial.println("AT+CIPSHUT"); //Close any GPRS Connection if open
    Serial.println("AT+CIPSHUT  Sent!");
    if(GPRS_Serial_wait_for_bytes(7,10) == 0)
    {  
      Serial.println("Timeout");
      goto setup_start;
    }
    else
    {
      Serial.print("Received:");
      while(GPRS_Serial.available()!=0)
      {
        Serial.print((unsigned char)GPRS_Serial.read());
        Serial.print("\n");
      }
    }
  }
}
 
void loop()
{
loop_start:
 
  Serial.println("Press a key to read temperature and upload it");
  Serial.flush();
  while(Serial.available() == 0);
  Serial.read();
 
 
  getTemp102();
  Serial.print("WaterLevel Temperature = ");
  Serial.println(convertedtemp);
 
  GPRS_Serial.println("AT+CIPSTART=\"TCP\",\"api.pachube.com\",\"80\""); //Open a connection to Pachube.com
  Serial.println("AT+CIPSTART=\"TCP\",\"api.pachube.com\",\"80\"  Sent!");
  if(GPRS_Serial_wait_for_bytes(12,255) == 0)
  {  
    Serial.println("Timeout");
    goto loop_start;
  }
  else
  {
    Serial.print("Received:");
    while(GPRS_Serial.available()!=0)
    {
      Serial.print((unsigned char)GPRS_Serial.read());
      Serial.print("\n");
    }
  }
 
  GPRS_Serial.flush();
  GPRS_Serial.println("AT+CIPSEND"); //Start data through TCP connection
  Serial.println("AT+CIPSEND  Sent!");
  if(GPRS_Serial_wait_for_bytes(1,100) == 0)
  {  
    Serial.println("Timeout");
    goto loop_start;
  }
  else
  {
    Serial.print("Received:");
    while(GPRS_Serial.available()!=0)
    {
      Serial.print((unsigned char)GPRS_Serial.read());
      Serial.print("\n");
    }
  }
 
 
  GPRS_Serial.flush();
 
  //Emulate HTTP and use PUT command to upload temperature datapoint using Comma Seperate Value Method
  GPRS_Serial.print("PUT /v2/feeds/24300.csv HTTP/1.1\r\n");
  Serial.println("PUT /v2/feeds/24300.csv HTTP/1.1  Sent!");
  delay(300);
 
  GPRS_Serial.print("Host: api.pachube.com\r\n"); 
  Serial.println("Host: api.pachube.com  Sent!");
  delay(300);
 
  GPRS_Serial.print("X-PachubeApiKey: _0mW-sxmvv-Cl67tzfpJuHProFX7HNdgAJd3foGuj-0\r\n"); //REPLACE THIS KEY WITH YOUR OWN PACHUBE API KEY
  Serial.println("X-PachubeApiKey: _0mW-sxmvv-Cl67tzfpJuHProFX7HNdgAJd3foGuj-0  Sent!"); //REPLACE THIS KEY WITH YOUR OWN PACHUBE API KEY
  delay(300);
 
  GPRS_Serial.print("Content-Length: 12\r\n"); 
  Serial.print("Content-Length: 12  Sent!"); 
  delay(300);
 
  GPRS_Serial.print("Connection: close\r\n\r\n"); 
  Serial.print("Connection: close  Sent!"); 
  delay(300);
  GPRS_Serial.print("WaterLevel,"); //You may replace the stream name "WaterLevel" to any other string that you have choosen.
  delay(300);
  GPRS_Serial.print(convertedtemp); 
  delay(300);
  GPRS_Serial.print("\r\n"); 
  delay(300);
  GPRS_Serial.print("\r\n"); 
  delay(300);
  GPRS_Serial.print(0x1A,BYTE);
  delay(300); //Send End Of Line Character to send all the data and close connection
  if(GPRS_Serial_wait_for_bytes(20,255) == 0)
  {  
    Serial.println("Timeout");
    goto loop_start;
  }
  else
  {
    Serial.print("Received:");
    while(GPRS_Serial.available()!=0)
    {
      Serial.print((unsigned char)GPRS_Serial.read());
      Serial.print("\n");
    }
  }
 
 
 
 
  GPRS_Serial.flush();
  GPRS_Serial.println("AT+CIPSHUT"); //Close the GPRS Connection
  Serial.println("AT+CIPSHUT  Sent!");
  if(GPRS_Serial_wait_for_bytes(4,100) == 0)
  {  
    Serial.println("Timeout");
    goto loop_start;
  }
  else
  {
    Serial.print("Received:");
    while(GPRS_Serial.available()!=0)
    {
      Serial.print((unsigned char)GPRS_Serial.read());
      Serial.print("\n");
    }
  }
}
 
 
 
 
 
 
 
 
 
char GPRS_Serial_wait_for_bytes(char no_of_bytes, int timeout)
{
  while(GPRS_Serial.available() < no_of_bytes)
  {
    delay(200);
    timeout-=1;
    if(timeout == 0)
    {
      return 0;
    }
  }
  return 1;
}
