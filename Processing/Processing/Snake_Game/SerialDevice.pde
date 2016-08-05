/*
 *******************************************************************************
 * Class   SerialDevice
 * Author  Ethan Pan @ Freenove (http://www.freenove.com)
 * Date    2016/7/20
 *******************************************************************************
 * Brief
 *   This class is used to connect a specific serial port.
 *   It will automatically detect and connect to a device (serial port) which 
 *   use the same trans format.
 *******************************************************************************
 * Serial data formats
 *   Baud    115200
 *   Data    Range 0 ~ 99 per data byte
 *   Format  0          1       2       ... n-1       n 
 *           transStart data[0] data[1] ... data[n-1] transEnd
 *******************************************************************************
 * Copyright
 *   Copyright © Freenove (http://www.freenove.com)
 * License
 *   Creative Commons Attribution ShareAlike 3.0 
 *   (http://creativecommons.org/licenses/by-sa/3.0/legalcode)
 *******************************************************************************
 */

/* Includes ------------------------------------------------------------------*/
import processing.serial.*;
/* Private define ------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/

/*
 * Brief  This class is used to save serial command
 *****************************************************************************/
static class SerialCommand
{
  // Trans control command, range 200 ~ 255
  static byte transStart = (byte)200;
  static byte transEnd = (byte)201;

  // General command , range 0 ~ 199
  // The odd command is sent by the requesting party
  // The even command is sent by the responding party
  // Request echo, to confirm the device
  static byte requestEcho = 0;      // Comm
  // Respond echo, to tell this is the device
  static byte echo = 1;             // Comm
  // Request 1 analog value
  static byte requestAnalog = 10;   // Comm 
  // Respond 1 analog value
  static byte Analog = 11;          // Comm A/100 A%100
  // Request n analog values
  static byte requestAnalogs = 12;  // Comm n
  // Respond n analog values
  static byte Analogs = 13;         // Comm A1/100 A1%100 ... An/100 An%100
}

/*
 * Brief  This class is used to automatically detect and connect to a device 
 *        (serial port) which use the same trans format.
 *****************************************************************************/
class SerialDevice
{
  public Serial serial;
  public String serialName;
  private PApplet parent;

  SerialDevice(PApplet pApplet)
  {
    parent = pApplet;
  }

  public boolean active()
  {
    if (serial != null)
      return serial.active();
    return false;
  }

  public boolean start()
  {
    println(time() + "Start connect device...");
    String[] serialNames = Serial.list();
    if (serialNames.length == 0)
      println(time() + "No serial port detected, waiting for connection...");
    while (serialNames.length == 0)
      serialNames = Serial.list();
    print(time() + "Detected serial port: ");
    for (int i = 0; i < serialNames.length; i++)
      print(serialNames[i] + " ");
    println("");
    for (int i = 0; i < serialNames.length; i++)
    {
      stop();
      println(time() + "Attempt to connect " + serialNames[i] + "...");
      try {
        serial = new Serial(parent, serialNames[i], 115200);
        serial.clear();
        delay(2000);
        byte[] data = new byte[1];
        data[0] = SerialCommand.requestEcho;
        write(serial, data);
        delay(100);
        data = read(serial);
        if (data != null)
        {
          if (data[0] == SerialCommand.echo)
          {
            serialName = serialNames[i];
            println(time() + "Device connection success: " + serialDevice.serialName);
            return true;
          }
        }
        serial.stop();
      } 
      catch (Exception e) {
        e.printStackTrace();
      }
    }
    println(time() + "Device connection failed");
    return false;
  }

  public void stop()
  {
    if (serial != null)
      if (serial.active())
        serial.stop();
  }

  public boolean write(byte[] data)
  {
    if (active())
    {
      write(serial, data);
      return true;
    }
    println(time() + "Write failed");
    return false;
  }

  public byte[] read()
  {
    if (active())
    {
      byte[] data = read(serial);
      if (data != null)
        return data;
    }
    println(time() + "Read failed");
    return null;
  }

  private void write(Serial serial, byte[] data)
  {
    serial.clear();
    serial.write(SerialCommand.transStart);
    serial.write(data);
    serial.write(SerialCommand.transEnd);
  }

  private byte[] read(Serial serial)
  {
    byte[] inData = new byte[1024];
    int inNum;

    if (serial.available() > 0)
    {
      inNum = serial.readBytes(inData);

      int inDataStart = 0;
      int inDataEnd = 0;
      for (int i = 0; i < inNum; i++)
      {
        if (inData[i]==SerialCommand.transStart)
        {
          inDataStart = i;
        }
        if (inData[i]==SerialCommand.transEnd)
        {
          inDataEnd = i;
        }
      }

      if (inDataStart >= 0 && inDataEnd > inDataStart)
      {
        byte[] data = new byte[inDataEnd - inDataStart - 1];
        for (int i = 0; i < inDataEnd - inDataStart - 1; i++)
        {
          data[i] = inData[inDataStart + i + 1];
        }
        return data;
      }
    }
    return null;
  }

  int requestAnalog()
  {
    byte[] data = new byte[1];
    data[0] = SerialCommand.requestAnalog;
    write(data);
    delay(20);
    data = read();
    if (data!=null)
    {
      if (data[0] == SerialCommand.Analog)
      {
        return data[1] * 100 + data[2];
      }
    }
    return -1;
  }

  int[] requestAnalogs(int number)
  {
    byte[] data = new byte[2];
    data[0] = SerialCommand.requestAnalogs;
    data[1] = (byte)number;
    write(data);
    delay(20 + number / 5);  // Tested 5ms(send 3bytes + receive 3bytes) + 17ms/100bytes extra
    data = read();
    if (data != null)
    {
      if (data[0] == SerialCommand.Analogs)
      {
        int[] analogs = new int[(data.length - 1) / 2];
        for (int i = 0; i < analogs.length; i++)
        {
          analogs[i] = data[i * 2 + 1] * 100 + data[i * 2 + 2];
        }
        return analogs;
      }
    }
    return null;
  }

  String time()
  {
    return hour() + ":" + minute() + ":" + second() + " ";
  }
}