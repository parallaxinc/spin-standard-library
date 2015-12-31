' Original author:         Daniel Harris

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ

  serial        : "com.serial"

  
PUB Main | i
{{
    Starts execution
    
    This test program attempts to test all aspects of the FullDuplexSerial object.
    It executs each public method call provided by FullDuplexSerial.  Set your
    terminal to a baud rate of 9600 baud to see the output.
    
    parameters:    none
    return:        none
    
    example usage: N/A - executes on startup
}}

  serial.Start()                    'requires 1 cog for operation

  repeat 5                                              'small loop to pause the Propeller's exection for 5 seconds.
    Wait_1_Second
  
  serial.Tx($10)
  
  serial.Str(STRING("Testing the FullDuplexSerial object."))     'print a test string
  PrintNewLine

  PrintHorizontalLine

  serial.Str(@test_string)                              'print the string defined in the DAT section below
  PrintNewLine

  serial.Dec(test_dec)                                  'print the test decimal number
  PrintNewLine

  serial.Hex(test_hex, 8)                               'print the test hexadecimal number, 8 hex characters
  PrintNewLine
  
  serial.Bin(test_bin, 32)                              'print the test binary number, 32 bits
  PrintNewLine

  PrintHorizontalLine

  serial.Str(STRING("Now Testing RX functionality"))
  PrintNewLine
  
  serial.Str(STRING("Blocking until you press the letter 'r'"))
  PrintNewLine

  repeat until (i := serial.Rx) == "r"                  'wait here until an "r" character is received

  serial.Str(STRING(13, "You just pressed the letter "))
  serial.Tx(i)
  PrintNewLine
  Wait_1_Second

  
  repeat
    Wait_1_Second
    serial.Str(STRING("Looping until you press the letter 'q'"))
    PrintNewLine
    i := serial.RxCheck

    if i == "q"                                         'leave the loop when "q" is received
      quit

  serial.Str(STRING(13, "You just pressed the letter "))
  serial.Tx(i)
  PrintNewLine

  serial.Str(STRING("On the count of 3, press any key in five seconds or less"))
  PrintNewLine
  Wait_1_Second
  repeat i from 1 to 3
    serial.Dec(i)
    repeat 2
      serial.Tx(".")
    Wait_1_Second
    
  serial.Str(STRING("Go!"))
  PrintNewLine

  serial.RxFlush                                        'tests RxFlush.  If a user pressed a key while
                                                        'the program was counting, a byte would be in the
                                                        'buffer.  This makes sure the buffer is clear.
                                                                                
  
  i := serial.RxTime(5000)                              'wait 5000 ms for a byte to be received

  PrintNewLine
  
  if i > 0                                              'if a byte was received, then print it
    serial.Str(STRING("You just pressed "))
    serial.Tx(i)
  else                                                  'otherwise, report no key presses.
    serial.Str(STRING("You didn't press a key in time."))

  PrintNewLine

  
  serial.Str(STRING("All Done!"))                       'all done with our tests

  Wait_1_Second
  
  serial.Stop                                           'Stop the object

PUB PrintNewLine
{{
  Prints a newline character to the terminal.
    
  parameters:    none
  return:        none
  
  example usage: PrintNewLine
}}

  serial.Tx($0D)                                        'ASCII 13 = carriage return

PUB PrintHorizontalLine
{{
  Prints a horizontal bar of equal signs to the terminal.
    
  parameters:    none
  return:        none
  
  example usage: PrintHorizontalLine
}}

  repeat 50                                             'print a line of "="
    serial.Tx("=")

  PrintNewLine

PUB Wait_1_Second
{{
    Pauses the calling cog's execution for approximately one second.
      
    parameters:    none
    return:        none
    
    example usage: Wait_1_Second
}}

    waitcnt(clkfreq + cnt)
  
DAT

'Pre-initialized Global Variables

test_string   byte      "This is a null-terminated string", 0
test_dec      long      -1_234_567_890
test_hex      long      $AA_FF_43_21
test_bin      long      %1110_0011_0000_1100_1111_1010_0101_1111

