{{
┌────────────────────────────────────┐
│ Parallax Serial Terminal Demo v1.0 │
│ Author: Jeff Martin                │                     
│ Copyright (c) 2009 Parallax Inc.   │                     
│ See end of file for terms of use.  │                      
└────────────────────────────────────┘

Demonstration of various handy features of the Parallax Serial Terminal (object and software).  The Parallax Serial
Terminal software is included with the Propeller Tool installer (v1.2.6 or newer) and provides a simple serial-based
interface to the Propeller chip.  Typically this is done over the programming connection but may use other I/O pins
if desired.

How to use:

 o Run the Parallax Serial Terminal (included with the Propeller Tool) and set it to the connected Propeller
   chip's COM Port with a baud rate of 115200.
 o In the Propeller Tool, press the F10 (or F11) key to compile and load the code.
 o Immediately click the Parallax Serial Terminal's Enable button.  Do not wait until the program is finished
   downloading.
}}

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

CON
  ColPos = 8  

OBJ
  pst   :       "com.serial"

PUB Main | value, base, width, offset
  pst.Start(115_200)                                                            'Set Parallax Serial Terminal to 115200 baud


  '-------- Demo 1 --------
  pst.Str(@DemoHeader)                                                          'Print header; uses string in DAT section.
  pst.Chars("-", strsize(@DemoHeader))                                          'Use Chars method to output hyphens "-"
  pst.Str(String(pst#NL, pst#NL, "*** Number Feedback Example ***"))
  repeat
    pst.Chars(pst#NL, 3)                                                        'Output multiple new lines
    pst.Str(String("Enter a decimal value: "))                                  'Prompt user to enter a number; uses immediate string.
    value := pst.DecIn                                                          'Get number (in decimal).
    pst.Str(String(pst#NL, "Your value is..."))                                 'Announce output
    pst.Str(String(pst#NL, " (Decimal):"))                                      'In decimal
    pst.PositionX(16)                                                           'Move cursor to column 16
    pst.Dec(value)
    pst.Str(String(pst#NL, " (Hexadecimal):", pst#PX, 16))                      'In hexadecimal.  We used PX control code to
    pst.Hex(value, 8)                                                           '  move cursor (alternative to PositionX method).
    pst.Str(String(pst#NL, " (Binary):"))                                       'In binary.
    pst.MoveRight(6)                                                            'Used MoveRight to move cursor (alternative
    pst.Bin(value, 32)                                                          '  to features used above).
    pst.Str(String(pst#NL, pst#NL, "Try again? (Y/N):"))                        'Prompt to repeat
    value := pst.CharIn
  while (value == "Y") or (value == "y")                                        'Loop back if desired


  '-------- Demo 2 --------
  repeat
    pst.Clear                                                                   'Clear screen
    pst.Str(@DemoHeader)                                                        'Print header.
    pst.Chars("-", strsize(@DemoHeader))                                        'Use Chars method to output hyphens "-"
    pst.Str(String(pst#NL, pst#NL, "*** Pseudo-Random Number Example ***"))    
    pst.Chars(pst#NL, 2)                                                        'Output multiple new lines
    pst.Str(String("Enter 'seed' value: "))                                     'Prompt for seed value
    value := pst.DecIn                                                          
    pst.Str(String(pst#NL, "Display decimal, hexadecimal, or binary? (D/H/B)")) 'Prompt for base size
    base := pst.CharIn
    pst.Str(@RandomHeader)                                                      'Output table header
    pst.Dec(value)
    base := lookdownz(base & %11011111: "B", "H", "D") <# 2                     'Convert base to number (B=0, H=1, else = 2)
    offset := ColPos + 4 + width := lookupz(base: 32, 8, 11)                    'Calculate column offset and field width
    pst.Chars(pst#NL, 2)                                                        'New lines
    pst.PositionX(ColPos)                                                       'Position and display first column heading
    pst.Str(@Forward)
    pst.PositionX(offset)                                                       'Position and display second column heading
    pst.Str(@Backward)
    pst.NewLine                                                                 'Draw underlines
    pst.PositionX(ColPos)
    pst.Chars("-", width)
    pst.PositionX(offset)
    pst.Chars("-", width)
    pst.NewLine
     
    'Pseudo-Random Number (Forward)
    repeat 10                                                                   
      waitcnt(clkfreq / 6 + cnt)                                                'Wait 1/6 second
      pst.PositionX(ColPos)                                                     'Position to first column
      ?value                                                                    'Generate random number forward
      case base                                                                 'Output in binary, hexadecimal, or decimal
        0: pst.Bin(value, width) {binary}                                       
        1: pst.Hex(value, width) {hex}
        2: pst.Dec(value)        {decimal}
      pst.MoveDown(1)                                                           'Move to next line
     
    'Pseudo-Random Number (Backward)
    repeat 10
      waitcnt(clkfreq / 6 + cnt)                                                'Wait 1/6 second                          
      pst.MoveUp(1)                                                             'Move to previous line                    
      pst.PositionX(offset)                                                     'Position to second column                
      case base                                                                 'Output in binary, hexadecimal, or decimal
        0: pst.Bin(value, width) {binary}                                                                                 
        1: pst.Hex(value, width) {hex}                                                                                    
        2: pst.Dec(value)        {decimal}                                                                                
      value?                                                                    'Generate random number backward
          
    pst.Position(0, 23)                                                         'Position below table
    pst.Str(String("Try again? (Y/N):"))                                        'Prompt to repeat
    value := pst.CharIn
  while (value == "Y") or (value == "y")                                        'Loop back if desired

  pst.Clear
  pst.Str(String("Thanks for playing."))  
  
DAT

DemoHeader    byte "Parallax Serial Terminal Demonstration", pst#NL, 0
RandomHeader  byte pst#NL, pst#NL, "Pseudo-Random Numbers Generated by Seed Value ", 0
Forward       byte "Forward", 0
Backward      byte "Backward", 0

  
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
