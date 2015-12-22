{{
''*******************************************
''*  HM55B Compass Module Serial DEMO  V1.1 *
''*  Author: Beau Schwabe                   *
''*  Copyright (c) 2009 Parallax, Inc.      *               
''*  See end of file for terms of use.      *               
''*******************************************


Revision History:
  Version 1.0   - (03/24/2009) Serial version released

  Version 1.1   - (03/24/2009) Added Serial graphics    

}}
CON     ''General Constants for Propeller Setup
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000


CON     ''Setup Constants for the Compass
    Enable = 0
     Clock = 1
      Data = 2
   
{{

            ┌────┬┬────┐
      ┌────│1  6│── +5V       P0 = Enable
      │ 1K  │  ├┴──┴┤  │               P1 = Clock
  P2 ┻──│2 │ /\ │ 5│── P0        P2 = Data
            │  │/  \│  │
    VSS ──│3 └────┘ 4│── P1
            └──────────┘

}}      

VAR     ''Setup variables related to the compass    
    long CorrectHeading
    long Deg, OldDeg               

OBJ     ''Setup Object references that make this demo work
    Ser       : "com.serial.fullduplex"
    HM55B     : "sensor.compass.hm55b"
    Calibrate : "HM55B Compass Calibration"

PUB DEMO_Initialization | i,dx,dy

    Ser.start(31, 30, 0, 38400)                          '' Initialize serial communication to the PC

    HM55B.start(Enable,Clock,Data)                      '' Initialize Compass Object

    Compass_Demo                                        '' Start the Compass DEMO

PUB Compass_Demo|RawHeading
    repeat
      ser.tx(1)                                         ' Send the HOME code to the DEBUG terminal
      ser.str(string("HM55B Propeller Compass Demo"))   ' Display Header Text
      ser.tx(13)                                        ' Send the RETURN key code to the DEBUG terminal
      ser.tx(13)                                        ' Send the RETURN key code to the DEBUG terminal
      ser.tx(13)                                        ' Send the RETURN key code to the DEBUG terminal            

      RawHeading := HM55B.Theta                         ' Read RAW 13-bit Angle

      CorrectHeading := Calibrate.Correct(RawHeading)   ' Calibrate Correct Heading 
            
      Deg := CorrectHeading * 45 / 1024                 ' Convert 13-Bit Angle to Deg
                                                        ' Note: This only makes it easier for us Humans to
                                                        '       read.

      ser.str(string("Correct Heading: "))              ' Display Correct Heading as a Degree
      ser.dec(Deg)
      ser.str(string("   "))

      ser.tx(13)                                        ' Send the RETURN key code to the DEBUG terminal
      ser.tx(13)                                        ' Send the RETURN key code to the DEBUG terminal      


''#########################################################
''#########################################################

''        This section for Calibration purposes only.   - See 'HM55B Compass Calibration.Spin' 
''        You may remove or comment after calibration.

      ser.str(string("RAW Heading: "))                  ' Display RAW Heading as a 13-Bit Angle
      ser.dec(RawHeading/11*11)                         ' Reduce returned Coordic value down to about 0.5 Deg
      ser.str(string("    "))                           ' resolution.  This helps to reduce LSB jitter

''#########################################################
''#########################################################


''#########################################################
''#########################################################

''        This section for DEBUG graphics only. 

      if Deg<>OldDeg                                    'No need to update if position has not moved
         DrawCompassNeedle(OldDeg,(" "))
         DrawCompassNeedle(Deg,("#"))
         OldDeg := Deg

      DrawCompassCircle

''#########################################################
''#########################################################
                 
PUB DrawCompassNeedle(_Deg,Character)|LineStep,Line,X,Y,X_Size,Y_Size,X_Center,Y_Center

    _Deg := 360 - (_Deg + 180)                          'Adjust Deg value for screen coordinate system
    
    X_Size := 26
    Y_Size := 13
    X_Center := 50
    Y_Center := 15

    LineStep := 5

    repeat Line from 0 to LineStep                            
      X := X_Center + (GetSine(Deg2Bit13(_Deg))* ((X_Size * Line)/LineStep))/ 65535
      Y := Y_Center + (GetCoSine(Deg2Bit13(_Deg))* ((Y_Size * Line)/LineStep))/ 65535
      CRSRXY(X,Y)
      ser.tx(Character)

PUB DrawCompassCircle|_Deg,X,Y,X_Size,Y_Size,X_Center,Y_Center
    X_Size := 30
    Y_Size := 15
    X_Center := 50
    Y_Center := 15
    
    repeat _Deg from 0 to 360 step 5
      X := X_Center + (GetSine(Deg2Bit13(_Deg))* X_Size)/ 65535
      Y := Y_Center + (GetCoSine(Deg2Bit13(_Deg))* Y_Size)/ 65535
      CRSRXY(X,Y)
      ser.tx("+")
           

PUB Deg2Bit13(_Deg)
    Return _Deg*1024/45

PUB GetCosine(angle)
    return GetSine(angle+$0800)
    
PUB GetSine(angle)|C,Z
    C := (angle & $0800)/$0800                          'Get quadrant 2/4 into C
    Z := 1-(angle & $1000)/$1000                        'Get quadrant 3/4 into Z
    if C==1
       -angle                                           'if quadrant 2/4, negate offset
    angle |= ($E000 >> 1)                               'or in sin table address >> 1
    angle <<= 1                                         'shift left to get final word address
    angle := word[angle]                                'read word sample from $E000 to $F000
    if Z==0
       -angle                                           'if quadrant 3/4, negate sample
    Return angle

PUB CRSRXY(X,Y)                                         'Equal to the BS2 DEBUG command CRSRXY
      ser.tx(2)
      ser.tx(X)
      ser.tx(Y)

      
CON
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
