''***************************************
''*  Hex Monitor v1.0                   *
''*  Author: Chip Gracey                *
''*  Copyright (c) 2005 Parallax, Inc.  *
''*  See end of file for terms of use.  *
''***************************************

' connects to a terminal via rx/tx pins
'
' commands:                     (backspace is supported)
'
'       <enter>                 - dump next 256 bytes
'       addr <enter>            - dump 256 bytes starting at addr
'       addr b1 b2 b3 <enter>   - enter bytes starting at addr

CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
    
    MAX_LINE = 64

OBJ

    term : "com.serial.terminal"
    str : "string"

VAR

    long linesize, linepos, hex, address, stack[40]
    byte line[MAX_LINE]

PUB Main

  term.Start (115200)
  
  cognew(monitor, @stack)
  
PUB monitor

  repeat
    term.Str (string(">"))
    
    term.ReadLine (@line, MAX_LINE-4)
    term.Str (@line)
    
{
    if gethex
      address := hex
      if gethex
        repeat
          byte[address++] := hex
        while gethex
      else
        hexpage
    else
      hexpage
      
    term.Newline

PRI hexpage | c

  repeat 16
    term.Hex (address,4)
    term.Char ("-")
    repeat 16
      term.Hex (byte[address++],2)
      term.Char (" ")
    address -= 16
    repeat 16
      c := byte[address++]
      if not lookdown(c : $20..$80)
        c := "."
      term.Char(c)
    term.Char(13)
}