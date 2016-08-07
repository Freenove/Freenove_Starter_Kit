/*
  Class serialCommand

  Brief  This class is used to save serial command.

  modified 2016/8/7
  by http://www.freenove.com
*/

class serialCommand
{
  public:
    // Trans control command, range 200 ~ 255
    const byte transStart = (byte)200;
    const byte transEnd = (byte)201;

    // General command , range 0 ~ 199
    // The odd command is sent by the requesting party
    // The even command is sent by the responding party
    // Request echo, to confirm the device
    const byte requestEcho = 0;      // Comm
    // Respond echo, to tell this is the device
    const byte echo = 1;             // Comm
    // Request 1 analog value
    const byte requestAnalog = 10;   // Comm
    // Respond 1 analog value
    const byte Analog = 11;          // Comm A/100 A%100
    // Request n analog values
    const byte requestAnalogs = 12;  // Comm n
    // Respond n analog values
    const byte Analogs = 13;         // Comm A1/100 A1%100 ... An/100 An%100
} SerialCommand;

