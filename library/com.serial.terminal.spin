' Original Authors: Jeff Martin, Andy Lindsay, Chip Gracey  

{{
    This object adds extra features specific to Parallax serial terminals.

    This object is heavily based on FullDuplexSerialPlus (by Andy Lindsay), which is itself
    heavily based on FullDuplexSerial (by Chip Gracey).

    # Usage 

    -   Call Start, or StartRxTx, first.
    -   Be sure to set the Parallax Serial Terminal software to the baudrate specified in Start, and the proper COM port.
    -   At 80 MHz, this object properly receives/transmits at up to 250 Kbaud, or performs transmit-only at up to 1 Mbaud.
}}
  
CON

    '' Control Character Constants

    CS = 16  ' Clear Screen      
    CE = 11  ' Clear to End of line     
    CB = 12  ' Clear lines Below 
    
    HM =  1  ' HoMe cursor       
    PC =  2  ' Position Cursor in x,y          
    PX = 14  ' Position cursor in X         
    PY = 15  ' Position cursor in Y         
    
    NL = 13  ' New Line        
    LF = 10  ' Line Feed       
    ML =  3  ' Move cursor Left          
    MR =  4  ' Move cursor Right         
    MU =  5  ' Move cursor Up          
    MD =  6  ' Move cursor Down
    TB =  9  ' TaB          
    BS =  8  ' BackSpace          
             
CON

   MAXSTR_LENGTH = 49                                   ' Maximum length of received numerical string (not including zero terminator).

OBJ

    ser : "com.serial"
    num : "string.numbers"

VAR

    byte    str_buffer[MAXSTR_LENGTH+1]                     ' String buffer for numerical strings

PUB Start(baudrate) : okay
{{
    Start communication with the Parallax Serial Terminal using the Propeller's programming connection.
    Waits 1 second for connection, then clears screen.
  
    Parameters:
        baudrate -  bits per second.  Make sure it matches the Parallax Serial Terminal's
                    Baud Rate field.
  
    Returns True (non-zero) if cog started, or False (0) if no cog is available.
}}

    okay := ser.Start(baudrate)
    Clear
    return okay

PUB StartRxTx(rxpin, txpin, mode, baudrate)
{{
    Start serial communication with designated pins, mode, and baud.

    Parameters:
        rxpin - input pin; receives signals from external device's TX pin.
        txpin - output pin; sends signals to  external device's RX pin.
        mode  - signaling mode (4-bit pattern).
                   bit 0 - inverts rx.
                   bit 1 - inverts tx.
                   bit 2 - open drain/source tx.
                   bit 3 - ignore tx echo on rx.
        baudrate - bits per second.

    Returns    : True (non-zero) if cog started, or False (0) if no cog is available.
}}

    return ser.StartRxTx(rxpin, txpin, mode, baudrate)

PUB Stop
{{
    Stop serial communication; frees a cog.
}}

    ser.Stop

PUB Char(bytechr)
{{
    Send single-byte character.  Waits for room in transmit buffer if necessary.

    Parameter:
        bytechr - character (ASCII byte value) to send.
}}

    ser.Char(bytechr)

PUB Chars(bytechr, count)
{{
    Send `count` number of a single-byte character.

    Parameter:

     - bytechr - character (ASCII byte value) to send.
     - count - number of characters to send.
}}

    repeat count
        ser.Char(bytechr)

PUB CharIn
{{
    Receive single-byte character.  Waits until character received.

    Returns: $00..$FF
}}

    return ser.CharIn

PUB Str(stringptr)
{{
    Send zero terminated string.
    Parameter:
        stringptr - pointer to zero terminated string to send.
}}

    repeat strsize(stringptr)
        ser.Char(byte[stringptr++])

PUB StrIn(stringptr)
{{
    Receive a string (carriage return terminated) and stores it (zero terminated) starting at stringptr.
    Waits until full string received.

    Parameter:
        stringptr - pointer to memory in which to store received string characters.
                    Memory reserved must be large enough for all string characters plus a zero terminator.
}}
    
    StrInMax(stringptr, -1)

PUB StrInMax(stringptr, maxcount)
{{
    Receive a string of characters (either carriage return terminated or maxcount in 
    length) and stores it (zero terminated) starting at stringptr.  Waits until either 
    full string received or maxcount characters received.

    Parameters:
        stringptr - pointer to memory in which to store received string characters.
                    Memory reserved must be large enough for all string characters plus a zero terminator (maxcount + 1).
        maxcount  - maximum length of string to receive, or -1 for unlimited.
}}
    
    repeat while (maxcount--)                                                     'While maxcount not reached
        if (byte[stringptr++] := ser.CharIn) == NL                                      'Get chars until NL
            quit
    byte[stringptr+(byte[stringptr-1] == NL)]~                                    'Zero terminate string; overwrite NL or append 0 char

PUB Dec(value) | i, x
{{
    Send value as decimal characters.
    Parameter:
        value - byte, word, or long value to send as decimal characters.
}}

    Str(num.Dec(value))

PUB DecIn : value
{{
    Receive carriage return terminated string of characters representing a decimal value.
  
    Returns: the corresponding decimal value.
}}

    StrInMax(@str_buffer, MAXSTR_LENGTH)
    value := num.StrToBase(@str_buffer, 10)

PUB Bin(value, digits)
{{
    Send value as binary characters up to digits in length.
  
    Parameters:
        value  - byte, word, or long value to send as binary characters.
        digits - number of binary digits to send.  Will be zero padded if necessary.
}}

    Str(num.Bin(value,digits))

PUB BinIn : value
{{
    Receive carriage return terminated string of characters representing a binary value.
    
    Returns: the corresponding binary value.
}}
   
    StrInMax(@str_buffer, MAXSTR_LENGTH)
    value := num.StrToBase(@str_buffer, 2)
   
PUB Hex(value, digits)
{{
    Send value as hexadecimal characters up to digits in length.
    Parameters:
        value  - byte, word, or long value to send as hexadecimal characters.
        digits - number of hexadecimal digits to send.  Will be zero padded if necessary.
}}

    Str(num.Hex(value, digits))

PUB HexIn : value
{{
    Receive carriage return terminated string of characters representing a hexadecimal value.
  
    Returns: the corresponding hexadecimal value.
}}

    StrInMax(@str_buffer, MAXSTR_LENGTH)
    value := num.StrToBase(@str_buffer, 16)

PUB Clear
{{
    Clear screen and place cursor at top-left.
}}
  
    ser.Char(CS)

PUB ClearEnd
{{
    Clear line from cursor to end of line.
}}
  
    ser.Char(CE)
  
PUB ClearBelow
{{
    Clear all lines below cursor.
}}
  
    ser.Char(CB)
  
PUB Home
{{
    Send cursor to home position (top-left).
}}
  
    ser.Char(HM)
  
PUB Position(x, y)
{{
    Position cursor at column x, row y (from top-left).
}}
  
    ser.Char(PC)
    ser.Char(x)
    ser.Char(y)
  
PUB PositionX(x)
{{
    Position cursor at column x of current row.
}}

    ser.Char(PX)
    ser.Char(x)
  
PUB PositionY(y)
{{
    Position cursor at row y of current column.
}}
    ser.Char(PY)
    ser.Char(y)

PUB NewLine
{{
    Send cursor to new line (carriage return plus line feed).
}}
  
    ser.Char(NL)
  
PUB LineFeed
{{
    Send cursor down to next line.
}}
  
    ser.Char(LF)
  
PUB MoveLeft(x)
{{
    Move cursor left x characters.
}}
  
    repeat x
        ser.Char(ML)
  
PUB MoveRight(x)
{{
    Move cursor right x characters.
}}
  
    repeat x
        ser.Char(MR)
  
PUB MoveUp(y)
{{
    Move cursor up y lines.
}}
  
    repeat y
        ser.Char(MU)
  
PUB MoveDown(y)
{{
    Move cursor down y lines.
}}
  
    repeat y
        ser.Char(MD)
  
PUB Tab
{{
    Send cursor to next tab position.
}}
  
    ser.Char(TB)
  
PUB Backspace
{{
    Delete one character to left of cursor and move cursor there.
}}
  
    ser.Char(BS)
  
PUB RxCount : count
{{
    Get count of characters in receive buffer.

    Returns: number of characters waiting in receive buffer.
}}

    return ser.RxCount

PUB RxFlush
{{
    Flush receive buffer.
}}

    ser.RxFlush
