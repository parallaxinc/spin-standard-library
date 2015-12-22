{{
*****************************************
* 4x4 Keypad Reader Demo      v1.0      *
* Author: Beau Schwabe                  *
* Copyright (c) 2007 Parallax           *               
* See end of file for terms of use.     *               
*****************************************
}}
{

Operation:

This object uses a capacitive PIN approach to reading the keypad.
To do so, ALL pins are made LOW and an OUTPUT to "discharge" the
I/O pins.  Then, ALL pins are set to an INPUT state.  At this point,
only one pin is made HIGH and an OUTPUT at a time.  If the "switch"
is closed, then a HIGH will be read on the input, otherwise a LOW
will be returned.

The keypad decoding routine only requires two subroutines and returns
the entire 4x4 keypad matrix into a single WORD variable indicating
which buttons are pressed.  Multiple button presses are allowed with
the understanding that“BOX entries can be confused. An example of a
BOX entry... 1,2,4,5 or 1,4,3,6 or 4,6,*,#  etc. where any 3 of the 4
buttons pressed will evaluate the non pressed button as being pressed,
even when they are not.  There is no danger of any physical or
electrical damage, that s just the way this sensing method happens to
work.

Schematic:
No resistors, No capacitors.  The connections are directly from the
keypad to the I/O's.  I literally plugged mine right into the demo
board RevC.

Looking at the Back of the 4x4 keypad...

       P7         P0
         ││││││││
┌─────── ││││││││ ───────┐
│     oo ││││││││ o      │
│                        │
│  O    O    O    O    O │ 
│                        │
│  O    O    O    O    O │
│         {LABEL}        │
│  O    O    O    O    O │ 
│                        │
│  O    O    O    O    O │
│                        │
│  O    O    O    O    O │
│             o    o     │
└────────────────────────┘

}

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ
  text : "display.vga.text"
  KP   : "input.keypad.4x4"

VAR
  word  keypad

PUB start
  'start term
  text.start(16)
  text.str(string(13,"4x4 Keypad Demo..."))
  text.str(string($A,1,$B,7))
  text.str(string(13,"RAW keypad value 'word'"))
  
  text.str(string($A,1,$B,13))
  text.str(string(13,"Note: Try pressing multiple keys"))

  repeat
    keypad := KP.ReadKeyPad     '<-- One line command to read the 4x4 keypad
    text.str(string($A,5,$B,2))
    text.bin(keypad>>0, 4)      'Display 1st ROW
    text.str(string($A,5,$B,3))
    text.bin(keypad>>4, 4)      'Display 2nd ROW
    text.str(string($A,5,$B,4))
    text.bin(keypad>>8, 4)      'Display 3rd ROW
    text.str(string($A,5,$B,5))
    text.bin(keypad>>12, 4)     'Display 4th ROW
    text.str(string($A,5,$B,9))
    text.bin(keypad, 16)        'Display RAW keypad value

DAT
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
