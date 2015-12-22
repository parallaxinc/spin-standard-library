{{
*****************************************
* Stack Length Demo v1.1                *
* Author: Jeff Martin                   *
* Copyright (c) 2006-2010 Parallax Inc. *
* See end of file for terms of use.     *
*****************************************

This code demonstrates the use of the Stack Length object.  See the Stack Length object for more information.

The example object being tested appears under the heading "Code/Object Being Tested for Stack Usage," near the
bottom of this source.  Hypothetically, it is the code written by a developer and given 32 longs of Stack space
during development.

Now that this object is done, the developer wishes to check its actual stack utilization, so he temporarily adds
the code that appears under the heading "Temporary Code to Test Stack Usage," below, downloads with F11, opens
the Parallax Serial Terminal and sets it to the Propeller chip's programming port at (115200 baud), resets the
Propeller and waits for message.

The message "Stack Usage: 9" appears and now he knows his code should reserve only 9 longs of space for Stack.
He makes the change, deletes the "temporary stack testing code" and calls it done!

{{--------------------------REVISION HISTORY--------------------------
 v1.1 - Updated 03/19/2010 to interface with Stack Length v1.1 and use
        the Parallax Serial Terminal at its default baud rate.
}}

{••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••}
{•••••••••••••••••••••••••••••••••  Temporary Code to Test Stack Usage  •••••••••••••••••••••••••••••••••}
{••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••}

CON
  _clkmode      = xtal1 + pll16x                        'Use crystal * 16 for fast serial               
  _xinfreq      = 5_000_000                             'External 5 MHz crystal on XI & XO

OBJ
  Stk   :       "debug.stacklength"                     'Include Stack Length Object

PUB TestStack
  Stk.Init(@Stack, 32)                                  'Initialize reserved Stack space (reserved below)
  Start(16, 500, 0)                                     'Exercise code/object under test
  waitcnt(clkfreq * 2 + cnt)                            'Wait ample time for max stack usage
  Stk.GetLength(30, 115200)                             'Transmit results serially out P30 at 115,200 baud


{••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••}
{••••••••••••••••••••••••••••••  Code/Object Being Tested for Stack Usage  ••••••••••••••••••••••••••••••}
{••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••}

VAR
  long  Stack[32]                                       'Stack space for new cog
  
PUB Start(Pin, DelayMS, Count)
{{Start new toggling process in a new cog.}}

  cognew(Toggle(Pin, DelayMS, Count), @Stack)
  
PUB Toggle(Pin, DelayMS, Count)
{{Toggle Pin, Count times with DelayMS milliseconds in between.
  If Count = 0, toggle Pin forever.}}

  dira[Pin]~~                                           'Set I/O Pin to output direction
  repeat                                                'Repeat the following
    !outa[Pin]                                          '  Toggle I/O Pin
    waitcnt(clkfreq / 1000 * DelayMS + cnt)             '  Wait for DelayMS milliseconds
  while Count := --Count #> -1                          'While Count-1 is not 0 (limit minimum to -1)



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
