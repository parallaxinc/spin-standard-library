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

  maxline = 64
  

VAR

  long rx, tx, baud, linesize, linepos, hex, address, stack[40]
  byte line[maxline]

  
PUB start(rxpin, txpin, baudrate) : okay

'' Start monitor in another cog

  rx := rxpin
  tx := txpin
  baud := clkfreq / baudrate
  okay := cognew(monitor, @stack) > 0


PRI monitor

' Actual 'monitor' program that runs in another cog

  outa[tx] := dira[tx] := 1

  repeat
    linesize := getline
    linepos := 0
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


PRI gethex : got | c

  hex := 0
  repeat while linepos <> linesize
    case c := line[linepos++]
      " ":   if got
               quit
      other: hex := hex << 4 + lookdownz(c : "0".."9", "A".."F")
             got++


PRI getline : size | c

  serout(">")
  repeat
    case c := uppercase(serin)
      "0".."9", "A".."F", " ":
          if size <> maxline
            line[size++] := c
            serout(c)
      8:  if size
            size--
            serout(8)
            serout(" ")
            serout(8)
      13: serout(c)
          quit


PRI uppercase(c) : chr

  if lookdown(c: "a".."z")
    c -= $20
  chr := c


PRI hexpage | c

  repeat 16
    hexout(address,4)
    serout("-")
    repeat 16
      hexout(byte[address++],2)
      serout(" ")
    address -= 16
    repeat 16
      c := byte[address++]
      if not lookdown(c : $20..$80)
        c := "."
      serout(c)
    serout(13)


PRI hexout(value, digits)

  value <<= (8-digits) << 2
  repeat digits
    serout(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))


PRI serout(b) | t

  b := b.byte << 2 + $400
  t := cnt
  repeat 10
    waitcnt(t += baud)
    outa[tx] := (b >>= 1) & 1


PRI serin : b | t

  waitpeq(0, |< rx, 0)
  t := cnt + baud >> 1
  repeat 8
    waitcnt(t += baud)
    b := ina[rx] << 7 | b >> 1
  waitcnt(t + baud)

