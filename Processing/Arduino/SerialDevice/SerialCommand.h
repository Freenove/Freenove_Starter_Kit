/*
  Class serialCommand

  Brief  This class is used to save serial command.

  modified 2016/7/18
  by http://www.freenove.com
*/

class serialCommand
{
  public:
    // Trans control command, range 200 ~ 255
    byte transStart = (byte)200;
    byte transEnd = (byte)201;

    // General command , range 0 ~ 199
    // The odd command is sent by the requesting party
    // The even command is sent by the responding party
    // Request echo, to confirm the device
    byte requestEcho = 0;      // Comm
    // Respond echo, to tell this is the device
    byte echo = 1;             // Comm
    // Request 1 analog value
    byte requestAnalog = 10;   // Comm
    // Respond 1 analog value
    byte Analog = 11;          // Comm A/100 A%100
    // Request n analog values
    byte requestAnalogs = 12;  // Comm n
    // Respond n analog values
    byte Analogs = 13;         // Comm A1/100 A1%100 ... An/100 An%100
} SerialCommand;

