''***************************************
''*         Ping))) Demo V1.2           *
''* Author:  Chris Savage & Jeff Martin *
''* Copyright (c) 2006 Parallax, Inc.   *
''* See end of file for terms of use.   *    
''* Started: 05-08-2006                 *
''***************************************
''
'' Version 1.2 - Updated March 26, 2008 by Jeff Martin to use updated Debug_LCD.

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  PING_Pin = 0                                          ' I/O Pin For PING)))
  LCD_Pin = 1                                           ' I/O Pin For LCD
  LCD_Baud = 19_200                                     ' LCD Baud Rate
  LCD_Lines = 4                                         ' Parallax 4X20 Serial LCD (#27979)


VAR

  long  range

    
OBJ

  LCD  : "debug.lcd.char.4x20"
  ping : "sensor.ping"

  
PUB Start

  LCD.init(LCD_Pin, LCD_Baud, LCD_Lines)                ' Initialize LCD Object
  LCD.cursor(0)                                         ' Turn Off Cursor
  LCD.backlight(true)                                   ' Turn On Backlight   
  LCD.cls                                               ' Clear Display
  LCD.str(string("PING))) Demo", 13, 13, "Inches      -", 13, "Centimeters -"))

  repeat                                                ' Repeat Forever
    LCD.gotoxy(15, 2)                                   ' Position Cursor
    range := ping.Inches(PING_Pin)                      ' Get Range In Inches
    LCD.decx(range, 2)                                  ' Print Inches
    LCD.str(string(".0 "))                              ' Pad For Clarity
    LCD.gotoxy(14, 3)                                   ' Position Cursor
    range := ping.Millimeters(PING_Pin)                 ' Get Range In Millimeters
    LCD.decf(range / 10, 3)                             ' Print Whole Part
    LCD.putc(".")                                       ' Print Decimal Point
    LCD.decx(range // 10, 1)                            ' Print Fractional Part
    waitcnt(clkfreq / 10 + cnt)                         ' Pause 1/10 Second
    
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
