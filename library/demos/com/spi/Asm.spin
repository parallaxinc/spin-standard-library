{{      
************************************************
* Propeller SPI Assembly Demo             v1.0 *
* Author: Beau Schwabe                         *
* Copyright (c) 2009 Parallax                  *
* See end of file for terms of use.            *
************************************************
}}

CON
    _clkmode = xtal1 + pll16x                           
    _xinfreq = 5_000_000

OBJ
    SPI : "com.spi"                               ''The Standalone SPI Assembly engine
    Ser : "com.serial.fullduplex"                 ''Used in this DEMO for Debug

CON
        WrCfg   = $0C           '' write config register
        StartC  = $EE           '' start conversion
        RdTmp   = $AA           '' read temperature

PUB SPI_DEMO|DQ,CLK,RESET,ClockDelay,ClockState,Celsius,Fahrenheit
{{
Once the 'SPI.start' command is called from Spin, it will remain running in its own COG.
If the SHIFTIN or SHIFTOUT command are called with 'Bits' set to Zero, then the COG will shut
down.  Another way to shut the COG down is to call the 'SPI.stop' command from Spin.
    
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
     The DS1620 temperature sensor is used to demonstrate the SPI's SHIFTIN and SHIFTOUT functions.

     most of the code follows the "Stamp Works" documentation that can be found here...

     http://www.parallax.com/Portals/0/Downloads/docs/books/sw/Web-SW-v2.1.pdf
          
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

Schematic:
                    Vdd
                     
            330 ┌────┴────┐
     P0 ────┤1   8   7├──NC
                │         │
     P1 ───────┤2       6├──NC
                │         │
     P2 ───────┤3   4   5├──NC
                └────┬────┘
                     
                    Vss
}}

'' -----[ Initialization ]--------------------------------------------------

''Serial communication Setup
    Ser.start(31, 30, 0, 9600)  '' Initialize serial communication to the PC through the USB connector
                                '' To view Serial data on the PC use the Parallax Serial Terminal (PST) program.

''SPI Setup
  ''SPI.start(ClockDelay, ClockState)
    SPI.start(15,1)             '' Initialize SPI Engine with Clock Delay of 15 and Clock State of 1


''DS1620 Setup
      DQ    := 0                  '' Set DS1620 Data Pin
      CLK   := 1                  '' Set DS1620 Clock Pin
      Reset := 2                  '' Set DS1620 Reset Pin
                                                                             
      HIGH(Reset)                                       '' alert the DS1620
      SPI.SHIFTOUT(DQ, CLK, SPI#LSBFIRST , 8, WrCfg)    '' Request Configuration Write
      SPI.SHIFTOUT(DQ, CLK, SPI#LSBFIRST , 8, %10)      '' configure for ; CPU / Free-run mode
      LOW(Reset)                                        '' release the DS1620

      waitcnt(cnt+clkfreq*10/1000)                      '' Pause for 10ms
      
      HIGH(Reset)                                       '' alert the DS1620
      SPI.SHIFTOUT(DQ, CLK, SPI#LSBFIRST , 8, StartC)   '' Request a Start Conversion   
      LOW(Reset)                                        '' release the DS1620

' -----[ Program Code ]----------------------------------------------------
      repeat
        HIGH(Reset)                                     '' alert the DS1620
        SPI.SHIFTOUT(DQ, CLK, SPI#LSBFIRST , 8, RdTmp)  '' Request to read the temperature
        Celsius := SPI.SHIFTIN(DQ, CLK, SPI#LSBPRE, 9)  '' read the temperature
        LOW(Reset)                                      '' release the DS1620

        Celsius := Celsius << 23 ~> 23                  '' extend sign bit
        Celsius *= 5                                    '' convert to tenths  

        Fahrenheit := Celsius * 9 / 5 + 320             '' convert Celsius reading to Fahrenheit  
        
        Ser.str(string("DS1620 thermometer"))
        Ser.tx(9)
        Ser.tx(9)        
        Ser.dec(Celsius/10)
        Ser.tx(".")
        Ser.dec(Celsius - Celsius/10*10)
        Ser.str(string("°C"))
        Ser.tx(9)
        Ser.tx(9)        
        Ser.dec(Fahrenheit/10)
        Ser.tx(".")
        Ser.dec(Fahrenheit - Fahrenheit/10*10)
        Ser.str(string("°F"))
        Ser.tx(13)

PUB HIGH(Pin)
    dira[Pin]~~
    outa[Pin]~~
         
PUB LOW(Pin)
    dira[Pin]~~
    outa[Pin]~
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
