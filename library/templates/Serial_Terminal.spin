' Author: Jeff Martin, Andy Lindsay
{{
    Template for Parallax Serial Terminal test applications; use this to quickly get started with a Propeller chip
    running at 80 MHz and the Parallax Serial Terminal software (included with the Propeller Tool).

    How to use:

     - In the Propeller Tool software, press the F7 key to determine the COM port of the connected Propeller chip.

     - Run the Parallax Serial Terminal (included with the Propeller Tool) and set it to the same COM Port with a
       baud rate of 115200.

     - Press the F10 (or F11) key in the Propeller tool to load the code.

     - Immediately click the Parallax Serial Terminal's Enable button.  Do not wait until the program is finished
       downloading.
}}
CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ

  term : "com.serial.terminal"

PUB Main | value

  term.Start(115200)                                                             ' Start the Parallax Serial Terminal cog

''---------------- Replace the code below with your test code ----------------

  term.Str(String("Convert Decimal to Hexadecimal..."))                          ' Heading
  repeat                                                                        ' Main loop
    term.Str(String("Enter decimal value: "))                                    ' Prompt user to enter value
    value := term.DecIn                                                          ' Get value
    term.Str(String(term#NL,"Your value in hexadecimal is: $"))                   ' Announce output
    term.Hex(value, 8)                                                           ' Display hexadecimal value
