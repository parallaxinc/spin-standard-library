{{
***************************************
*  RealRandom Demo v1.0               *
*  Author: Chip Gracey                *
*  Copyright (c) 2007 Parallax, Inc.  *
*  See end of file for terms of use.  *
***************************************

This program demonstrates how the RealRandom object
can generate a random number on each power-up. It also
conveys continuous random numbers to the headphones
for listening -- be warned, it is loud whitenoise.

It uses the Propeller Demo Board, or any equivalent
TV and audio circuits on a raw Propeller.

}}

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


OBJ

  text  : "display.tv.text"
  rr    : "math.realrandom"
  

PUB start | i

  'start RealRandom
  rr.start

  'start terminal and show a random number
  text.start(12)
  text.str(string(10,16,11,6))
  text.hex(rr.random, 8)
                                         
  'output the random numbers' lsb's to headphones
  i := rr.random_ptr 
  dira[11..10]~~
  repeat
    outa[11..10] := long[i]

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
