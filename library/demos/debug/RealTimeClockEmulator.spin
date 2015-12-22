{{      
************************************************
* Propeller RTC Emulator Demo             v1.0 *
* Author: Beau Schwabe                         *
* Copyright (c) 2009 Parallax                  *
* See end of file for terms of use.            *
************************************************
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ
  Clock         : "debug.emulator.rtc"
  Ser           : "com.serial.fullduplex"

VAR
  long  TimeString
  byte  SS,MM,HH,AP,DD,MO,YY,LY
  byte  DateStamp[11], TimeStamp[11]

PUB PropellerRTC_EmulatorDemo

    Ser.start(31, 30, 0, 2400)  '' Initialize serial communication to the PC
  
    Clock.Start(@TimeString)    '' Initiate Prop Clock 

    Clock.Suspend               '' Suspend Clock while being set

    Clock.SetYear(09)           '' 00 - 31 ... Valid from 2000 to 2031
    Clock.SetMonth(03)          '' 01 - 12 ... Month
    Clock.SetDate(11)           '' 01 - 31 ... Date
    
    Clock.SetHour(12)           '' 01 - 12 ... Hour        
    Clock.SetMin(00)            '' 00 - 59 ... Minute    
    Clock.SetSec(00)            '' 00 - 59 ... Second

    Clock.SetAMPM(1)            '' 0 = AM ; 1 = PM

    Clock.Restart               '' Start Clock after being set    

    repeat
      Clock.ParseDateStamp(@DateStamp)
      Clock.ParseTimeStamp(@TimeStamp)

      ser.tx(1)                 '' Send the HOME code to the DEBUG terminal      
      ser.str(@DateStamp)       '' Display Date to the DEBUG terminal 
      ser.str(string("  "))
      ser.str(@TimeStamp)       '' Display Time to the DEBUG terminal

{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}            
