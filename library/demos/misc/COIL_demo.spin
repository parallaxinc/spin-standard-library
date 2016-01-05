{{
*****************************************
* COILREAD Demo v1.0                    *
* Author: Beau Schwabe                  *
* Copyright (c) 2007 Parallax           *
* See end of file for terms of use.     *
*****************************************
}}

''
''                               3.3V
''                                
''                           ┌──┳─┫
''         220Ω 500Ω      ┌┳┌680pF
''Ping I/O ────┳────└─┻┘ └─╋─────── Read I/O
''               R1 │     │       │
''                  │     220Ω   1M
''                  │ D1  │       │             NPN = 2n3904
''Coil I/O ──────╋─|<──┻───────┫             PNP = 2n3906 (best results when matched)
''                                              D1 = 1n914  (not critical - back EMF protect)
''Coil I/O ─ ─ ─ ┤            GND             R1 = sensitivity adjustment
''
''Coil I/O ─ ─ ─ ┘ (optional Coils)


''Test Case:  ( detection starts at about 1 inch )
''
''Coil - 75 Turns around a 1/2" diameter form.  approximate inductance = 119µH
''
''
''Typical Coil return values range from 0% to 97%


CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  _stack = ($3000 + $3000 + 100) >> 2   'accomodate display memory and stack

  x_tiles = 16
  y_tiles = 12

  paramcount = 14
  bitmap_base = $2000
  display_base = $5000

  lines = 5
  thickness = 2

   PingPin = 1
   ReadPin = 0
   CoilPin = 2   'Note Multiple coils are possible, but you must only read one at a time

VAR
  long  tv_status     '0/1/2 = off/visible/invisible            read-only
  long  tv_enable     '0/? = off/on                            write-only
  long  tv_pins       '%ppmmm = pins                           write-only
  long  tv_mode       '%ccinp = chroma,interlace,ntsc/pal,swap write-only
  long  tv_screen     'pointer to screen (words)               write-only
  long  tv_colors     'pointer to colors (longs)               write-only
  long  tv_hc         'horizontal cells                        write-only
  long  tv_vc         'vertical cells                          write-only
  long  tv_hx         'horizontal cell expansion               write-only
  long  tv_vx         'vertical cell expansion                 write-only
  long  tv_ho         'horizontal offset                       write-only
  long  tv_vo         'vertical offset                         write-only
  long  tv_broadcast  'broadcast frequency (Hz)                write-only
  long  tv_auralcog   'aural fm cog                            write-only

  long    colors[64]

  word screen[x_tiles * y_tiles]

  byte  x[lines]
  byte  y[lines]
  byte  xs[lines]
  byte  ys[lines]


  long IntegerTemp
  long CoilValue

  byte int_string[20],p


OBJ
  tv   : "display.tv"
  gr   : "display.tv.graphics"
  COIL : "misc.coilread"

PUB start | i,dx,dy
  'start tv
  longmove(@tv_status, @tvparams, paramcount)
  tv_screen := @screen
  tv_colors := @colors
  tv.start(@tv_status)

  'init colors
  repeat i from 0 to 64
    colors[i] := $00001010 * (i+4) & $F + $2B060C02

  'init tile screen
  repeat dx from 0 to tv_hc - 1
    repeat dy from 0 to tv_vc - 1
      screen[dy * tv_hc + dx] := display_base >> 6 + dy + dx * tv_vc + ((dy & $3F) << 10)

  'start and setup graphics
  gr.start
  gr.setup(16, 12, 128, 96, bitmap_base)


  'start COILREAD
  COIL.start(PingPin,CoilPin,ReadPin,@CoilValue)

  repeat

    'clear bitmap
    gr.clear

    'draw text
    gr.textmode(1,1,7,5)
    gr.colorwidth(1,0)
    gr.color(6)
    gr.text(0,90,string("Parallax Propeller COILREAD demo"))

    'Convert integer value into a String; place result in 'int_string'
    IntString(CoilValue)
    'display text of CoilValue
    gr.text(0,60,@int_string)

    'display analog meter
    gr.color(1)
    gr.width(0)
    gr.arc(0, 0, 50, 50, 0, 409, 11, 3)
    gr.arc(0, 0, 45, 45, 204, 409, 10, 3)
    gr.color(0)
    gr.width(2)
    gr.arc(0, 0, 42, 42, 0, 204, 21, 3)
    gr.color(1)
    gr.width(0)
    gr.arc(0, 0, 40, 40, 4096-((CoilValue*4096)/100) ,1, 1, 3)
    'arc(x, y, xr, yr, angle, anglestep, steps, arcmode)



    'display bargraph
    gr.color(2)
    gr.plot(-99,-91)
    gr.line(101,-91)
    gr.line(101,-85)
    gr.line(-99,-85)
    gr.line(-99,-91)
    gr.color(3)
    gr.box(-98, -90, CoilValue*2, 5)

    'copy bitmap to display
    gr.copy(display_base)


PUB IntString(Integer)                                  'Converts INTEGER to String (no decimal point)
    p := 0                                              'clear string pointer
    IntegerTemp := (Integer /10)                        'find number of digits
    repeat while IntegerTemp <> 0
           p := p + 1
           IntegerTemp := (IntegerTemp /10)
    int_string[p+1]~                                    'set end of string
    IntegerTemp := (Integer /10)                        'Put digits into string
    repeat while IntegerTemp <> 0
           int_string[p] := (Integer - (IntegerTemp*10))+"0"
           p := p - 1
           Integer := IntegerTemp
           IntegerTemp := (Integer /10)
    int_string[p] := Integer + "0"

DAT
tvparams                long    0               'status
                        long    1               'enable

                        'long   %011_0000       'pins      Old Board
                        long    %001_0101       'pins      New Board

                        long    %0000           'mode
                        long    0               'screen
                        long    0               'colors
                        long    x_tiles         'hc
                        long    y_tiles         'vc
                        long    10              'hx
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    60_000_000'_xinfreq<<4 'broadcast
                        long    0               'auralcog

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
