''***************************************
''*  Float Demo v1.0.1                  *
''*  Author: Chip Gracey                *
''*  Copyright (c) 2006 Parallax, Inc.  *
''*  See end of file for terms of use.  *
''***************************************

{-----------------REVISION HISTORY-----------------
 v1.0.1 - Updated 5/15/2006 to use TV_Terminal v1.1}
 
CON

        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000


OBJ

        term    : "display.tv.terminal"
        f       : "math.float"
        fp      : "string.float"


PUB start | i

  'start the tv terminal
  term.start(12)

  'print a string
  term.str(string("Float Demo...",13))

  'change to green
  term.out(2)

  'print some decimal numbers
  fp.SetPositiveChr(" ")
  i~
  repeat while fnums1[i]
    term.out(13)
    term.str(fp.FloatToString(fnums1[i++]))
  term.out(13)

  fp.SetPrecision(3)
  i~
  repeat while fnums2[i]
    term.out(13)
    term.str(fp.FloatToMetric(fnums2[i++], "m"))

    
DAT

fnums1  long  pi, ^^2.0, 1.0 / ^^2.0, -0.0000000000194, 1.0 / 13.0, 0

fnums2  long  15e-6, 0.5905675, 1234.0, 0

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
