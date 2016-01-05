{{
*****************************************
* Frequency Synthesizer demo v1.1       *
* Author: Beau Schwabe                  *
* Copyright (c) 2007 Parallax           *
* See end of file for terms of use.     *
*****************************************
  Original Author: Chip Gracey
  Modified by Beau Schwabe
*****************************************
}}
{
Revision History:
                  Version 1.0   -    original file created

                  Version 1.1   -    For Channel "B" there was a typo in the 'Synth' object
                                     The line that reads...
                                     DIRB[Pin]~~                        'make pin output
                                     ...should read...
                                     DIRA[Pin]~~                        'make pin output
}
CON

  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000


  Pin  = 0

  Frequency = 40_000                                    'DC to 128MHz

VAR

OBJ
  Freq : "signal.synth"

PUB CTR_Demo

    Freq.Synth("A",Pin, Frequency)                      'Synth({Counter"A" or Counter"B"},Pin, Freq)

    repeat                                              'loop forever to keep cog alive

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
