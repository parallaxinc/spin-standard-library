{{
┌────────────────────────────────────────┐
│ Parallax Serial Terminal Template v1.0 │
│ Author: Jeff Martin, Andy Lindsay      │               
│ Copyright (c) 2009 Parallax Inc.       │               
│ See end of file for terms of use.      │                
└────────────────────────────────────────┘

Template for Parallax Serial Terminal test applications; use this to quickly get started with a Propeller chip
running at 80 MHz and the Parallax Serial Terminal software (included with the Propeller Tool).

How to use:

 o In the Propeller Tool software, press the F7 key to determine the COM port of the connected Propeller chip.
 o Run the Parallax Serial Terminal (included with the Propeller Tool) and set it to the same COM Port with a
   baud rate of 115200.
 o Press the F10 (or F11) key in the Propeller tool to load the code.
 o Immediately click the Parallax Serial Terminal's Enable button.  Do not wait until the program is finished
   downloading.

Revision History:
Version 1.0 - Changed name from "...Terminal QuickStart" to "...Terminal Template" to avoid confusion with the
              QuickStart development board.   
}}

CON
   
  _clkmode = xtal1 + pll16x                 ' Crystal and PLL settings.
  _xinfreq = 5_000_000                      ' 5 MHz crystal (5 MHz x 16 = 80 MHz).

OBJ

  pst    : "com.serial"                     ' Serial communication object

PUB go | value                                  

  pst.Start(115200)                                                             ' Start the Parallax Serial Terminal cog
    
''---------------- Replace the code below with your test code ----------------
  
  pst.Str(String("Convert Decimal to Hexadecimal..."))                          ' Heading
  repeat                                                                        ' Main loop
    pst.Chars(pst#NL, 2)                                                        ' Carriage returns
    pst.Str(String("Enter decimal value: "))                                    ' Prompt user to enter value
    value := pst.DecIn                                                          ' Get value
    pst.Str(String(pst#NL,"Your value in hexadecimal is: $"))                   ' Announce output
    pst.Hex(value, 8)                                                           ' Display hexadecimal value

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
