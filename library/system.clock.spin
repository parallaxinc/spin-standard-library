' Author: Jeff Martin
{{
    Provides clock timing functions to:

    -   Set clock mode and frequency at run-time using similar clock setting constants as with
        the _clkmode system constant; like the constant: xtal1_pll16x

    -   Pause execution in units of microseconds, milliseconds, or seconds 

    -   Synchronize code to the start of time-windows in units of microseconds, milliseconds,
        or seconds.
    
    Example of Use:
      
        OBJ                                                 
          clk : "system.clock"           ' Include Clock object in parent object
          
        PUB Main
          clk.Init(5_000_000)            ' Initialize Clock object with external frequency 5 MHz
          <...>
          clk.SetMode(XTAL1_PLL2X)       ' Switch system clock to gain 1 and 2x wind-up (10 MHz)
          <...>
          clk.PauseMS(100)               ' Pause for approximately 100 ms
          <...>     
    
    See "Theory of Operation" below for more information.
}}

CON                                                     
  WMIN = 381                                            'WAITCNT-expression overhead minimum
                                                        'ie: freeze protection
  'Clock Mode constants for the SetMode method          
  RCFAST_         = %0_0_0_00_000                       'Clock mode constants used for the
  RCSLOW_         = %0_0_0_00_001                       'SetMode method.  Each constant name
  XINPUT_         = %0_0_1_00_010                       'represents the expression built of
  XTAL1_          = %0_0_1_01_010                       'similar names from clock setting   
  XTAL2_          = %0_0_1_10_010                       'constants (without trailing "_" and
  XTAL3_          = %0_0_1_11_010                       'with "+" instead of middle "_").
  XINPUT_PLL1X    = %0_1_1_00_011                       '                                  
  XINPUT_PLL2X    = %0_1_1_00_100                       'For example, calling the method
  XINPUT_PLL4X    = %0_1_1_00_101                       'SetMode(XTAL1_PLL16X) changes the
  XINPUT_PLL8X    = %0_1_1_00_110                       'clock mode to the same state at
  XINPUT_PLL16X   = %0_1_1_00_111                       'run-time as the CON block statement
  XTAL1_PLL1X     = %0_1_1_01_011                       '_clkmode = xtal1 + pll16x does at
  XTAL1_PLL2X     = %0_1_1_01_100                       'compile-time.      
  XTAL1_PLL4X     = %0_1_1_01_101                       '                   
  XTAL1_PLL8X     = %0_1_1_01_110                       'Calling SetMode with one of these
  XTAL1_PLL16X    = %0_1_1_01_111                       'constants is much faster than using
  XTAL2_PLL1X     = %0_1_1_10_011                       'the legacy SetClock method from 
  XTAL2_PLL2X     = %0_1_1_10_100                       'previous versions of this Clock
  XTAL2_PLL4X     = %0_1_1_10_101                       'object.            
  XTAL2_PLL8X     = %0_1_1_10_110                       '                   
  XTAL2_PLL16X    = %0_1_1_10_111                       'The values of each are the actual 
  XTAL3_PLL1X     = %0_1_1_11_011                       'CLK Register values that determine
  XTAL3_PLL2X     = %0_1_1_11_100                       'the System Clock mode and frequency
  XTAL3_PLL4X     = %0_1_1_11_101                                           
  XTAL3_PLL8X     = %0_1_1_11_110                                           
  XTAL3_PLL16X    = %0_1_1_11_111                                           
  
                    
VAR                 
  long  syncPoint                                       'Next sync point for WaitSync
                    
                    
PUB Init(xinFrequency)
{{Call this before the first call to SetMode (or legacy SetClock) to inform the object of
the external clock source's frequency, ie: a crystal's frequency.  Only call Init once per
application, unless the external clock source itself changes frequencies.
  PARAMETERS: xinFrequency = Frequency (in Hz) that external crystal/clock is driving
                             into XIN pin.  Use 0 if no external clock source is connected.
}}
   xinFreq := xinFrequency                                                            'Update xinFreq 
   oscDelay[2] := xinFreq / 100 #> WMIN                                               'Update oscDelay for XINPUT 10 ms delay
   
  
PUB SetMode(clockMode): newFreq 
{{Set System Clock to clockMode and adjust frequency appropriately.
  PARAMETERS: clockMode = one of the Clock Mode constants defined in the CON block above,
              such as RCFAST_ or XTAL1_PLL16X.                                              
  RETURNS:    New clock frequency.                                                                      
}}                                                                                                      
  if not (clkmode & $18) and (clockMode & $18)                                        'If switching from a non-feedback to a feedback-based clock source
    clkset(clkmode & $07 | clockMode & $78, clkfreq)                                  '  first rev up oscillator and possibly PLL circuits (using current clock source RCSLOW, RCFAST, XINPUT, or XINPUT + PLLxxx)
    waitcnt(oscDelay[clkmode & $7 <# 2] * |<(clkmode & $7 - 3 #> 0) + cnt)            '  and wait 10 ms to stabilize, accounting for worst-case IRC speed (or XIN + PLL speed)
                           
  clkset(clockMode, newFreq := ircFreq[clockMode <# 2] * |<(clockMode & $7 - 3 #> 0)) 'Switch to new clock mode, indicate new frequency (ideal RCFAST, ideal RCSLOW, or                                                                 
                                                                                      'XINFreq * PLL multiplier) and update return value (new frequency)
           
PUB PauseUSec(duration) 
{{Pause execution in microseconds.
  PARAMETERS: duration = number of microseconds to delay.

  See "To Pause Execution Briefly" for more information.
}}
  waitcnt(((clkfreq / 1_000_000 * duration - 3928) #> WMIN) + cnt)              'Pause in 1/1,000,000 sec units; adjusted for method cost and freeze-protected                   
  

PUB PauseMSec(duration)
{{Pause execution in milliseconds.
  PARAMETERS: duration = number of milliseconds to delay.

  See "To Pause Execution Briefly" for more information.
}}
  waitcnt(((clkfreq / 1_000 * duration - 3932) #> WMIN) + cnt)                  'Pause in 1/1,000 sec units; adjusted for method cost and freeze-protected                   
  

PUB PauseSec(duration)
{{Pause execution in seconds.
  PARAMETERS: duration = number of seconds to delay.

  See "To Pause Execution Briefly" for more information.
}}
  waitcnt(((clkfreq * duration - 3016) #> WMIN) + cnt)                          'Pause in 1 sec units; adjusted for method cost and freeze-protected                   
                                                                                                 
                                                                                                 
PUB MarkSync                                                                                     
{{Mark reference time for synchronized-delay time windows.                                       
Use one of the WaitSync methods to sync to start of next time window.
See "To Synchronize a Command/Routine..." for more information.                            
}}                                                                                               
  syncPoint := cnt                                                                               
                                                                                                 
                                                                                                 
PUB WaitSyncUSec(width)                                                                          
{{Sync to start of next microsecond-based time window.                                           
Must call MarkSync before calling WaitSyncUSec the first time.                                   
  PARAMETERS: width = size of time window in microseconds.                                       

  See "To Synchronize a Command/Routine..." for more information.                            
}}                                                                                               
  waitcnt(syncPoint += (clkfreq / 1_000_000 * width) #> WMIN)                   'Wait for time window in 1/1,000,000 sec units; freeze-resistant                 
                                                                                                 
                                                                                                 
PUB WaitSyncMSec(width)                                                                          
{{Sync to start of next millisecond-based time window.                                           
Must call MarkSync before calling WaitSyncMSec the first time.                                   
  PARAMETERS: width = size of time window in milliseconds.                                       

  See "To Synchronize a Command/Routine..." for more information.                            
}}                                                                                               
  waitcnt(syncPoint += (clkfreq / 1_000 * width) #> WMIN)                       'Wait for time window in 1/1,000 sec units; freeze-resistant                 
                                                                                                 
                                                                                                 
PUB WaitSyncSec(width)                                                                           
{{Sync to start of next second-based time window.                                                
Must call MarkSync before calling WaitSyncSec the first time.                                    
  PARAMETERS: width = size of time window in seconds.                                            

  See "To Synchronize a Command/Routine..." for more information.                            
}}                                                                                               
  waitcnt(syncPoint += (clkfreq * width) #> WMIN)                               'Wait for time window in 1 sec units; freeze-resistant                 

  
DAT
  ircFreq     long      12_000_000                                              'Ideal RCFAST frequency
              long      20_000                                                  'Ideal RCSLOW frequency
  xinFreq     long      0                                                       'External source (XIN) frequency (updated by .Init); MUST reside immediately after ircFreq
  oscDelay    long      20_000_000 / 100                                        'Sys Counter offset for 10 ms oscillator startup delay based on worst-case RCFAST frequency
              long      33_000 / 100 #> WMIN                                    '<same as above> but based on worst-case RCSLOW frequency; limited to WMIN to prevent freeze 
              long      0 {xinFreq / 100 #> WMIN}                               '<same as above> but based on external source (XIN) frequency; updated by .Init
  clkValue    byte      RCFAST_, RCSLOW_, XINPUT_, XTAL1_, XTAL2_, XTAL3_       'Clk Register values corresponding to SetClock's mode (which is converted to index of 0..25)
              byte      XINPUT_PLL1X, XINPUT_PLL2X, XINPUT_PLL4X, XINPUT_PLL8X
              byte      XINPUT_PLL16X, XTAL1_PLL1X, XTAL1_PLL2X, XTAL1_PLL4X   
              byte      XTAL1_PLL8X, XTAL1_PLL16X, XTAL2_PLL1X, XTAL2_PLL2X    
              byte      XTAL2_PLL4X, XTAL2_PLL8X, XTAL2_PLL16X, XTAL3_PLL1X     
              byte      XTAL3_PLL2X, XTAL3_PLL4X, XTAL3_PLL8X, XTAL3_PLL16X    
                        
{{

───────────────────────────────────────────────────────────────────────────────────────────
                                      THEORY OF OPERATION                                   
───────────────────────────────────────────────────────────────────────────────────────────

This object is used to control the system clock function (mode and speed) as well as code
execution (pauses and time-window synchronization).

Normally, clock mode and speed is fixed and set at compile-time with clock setting
constants such as:

      _clkmode = xtal1 + pll16x   'standard mode and  
      _xinfreq = 5_000_000        'frequency (80 MHz)                        

However, the Propeller allows clock mode and speed changes at run-time for flexible power
management.  However, the CLKSET command doesn't accept the same clock setting constants
used by _CLKMODE, above, but rather takes the specific CLK Register values representing
the desired mode.

This object was written for those that would rather use the same clock setting constants
they are familiar with from the _CLKMODE constant.


                                                         
TO SET THE SYSTEM CLOCK AT RUN-TIME:                          Clock Setting Constants                                                        
                                                         ┌─────────────────┬──────────────┐                                                  
    STEP 1: [REQUIRED ONCE] Call the Init method with    │   Valid Clock   │ CLK Register │                                                  
            the frequency (in Hz) of the external        │      Modes      │    Value     │                                                  
            crystal, resonator, or other clock source on ├─────────────────┼──────────────┤                                                  
            the XIN pin (if any). For example, use       │ RCFAST          │ 0_0_0_00_000 │                                                  
            Init(5_000_000) to specify an XIN pin        ├─────────────────┼──────────────┤                                                  
            frequency of 5 MHz.  There's no need to call │ RCSLOW          │ 0_0_0_00_001 │                                                  
            Init more than once per application, unless  ├─────────────────┼──────────────┤                                                  
            the external frequency on XIN is changing.   │ XINPUT          │ 0_0_1_00_010 │                                                  
                                                         ├─────────────────┼──────────────┤                                                  
    STEP 2: Call SetMode with the new clock mode to      │ XTAL1           │ 0_0_1_01_010 │                                                  
            switch to; expressed in clock setting        │ XTAL2           │ 0_0_1_10_010 │                                                  
            constants similar to how the _CLKMODE        │ XTAL3           │ 0_0_1_11_010 │                                                  
            constant is defined for the application's    ├─────────────────┼──────────────┤                                                  
            initial clock setting. For example, use      │ XINPUT + PLL1X  │ 0_1_1_00_011 │                                                  
            SetMode(XTAL1 + PLL4X) to switch the System  │ XINPUT + PLL2X  │ 0_1_1_00_100 │                                                  
            Clock to an external low-speed crystal       │ XINPUT + PLL4X  │ 0_1_1_00_101 │                                                  
            source and wind it up by 4 times.            │ XINPUT + PLL8X  │ 0_1_1_00_110 │                                                  
                                                         │ XINPUT + PLL16X │ 0_1_1_00_111 │                                                  
    CLOCK SETTING CONSTANTS: The table on the right      ├─────────────────┼──────────────┤                                                  
    shows all valid clock setting constants as well as   │ XTAL1 + PLL1X   │ 0_1_1_01_011 │                                                                                                           
    the CLK Register bit patterns they correspond to.    │ XTAL1 + PLL2X   │ 0_1_1_01_100 │                                                                                                           
                                                         │ XTAL1 + PLL4X   │ 0_1_1_01_101 │                                                  
    NOTE: The SetMode method automatically converts the  │ XTAL1 + PLL8X   │ 0_1_1_01_110 │                                                  
    given clock setting constant expression to the       │ XTAL1 + PLL16X  │ 0_1_1_01_111 │                                                  
    corresponding CLK Register value (shown in the       ├─────────────────┼──────────────┤                                                  
    table), calculates and updates the System Clock      │ XTAL2 + PLL1X   │ 0_1_1_10_011 │                                                  
    Frequency value (CLKFREQ) and performs the proper    │ XTAL2 + PLL2X   │ 0_1_1_10_100 │                                                  
    stabilization procedure (10 ms delay), as needed,    │ XTAL2 + PLL4X   │ 0_1_1_10_101 │                                                  
    to ensure a stable clock when switching from a       │ XTAL2 + PLL8X   │ 0_1_1_10_110 │                                                  
    non-feedback clock source to a feedback-based clock  │ XTAL2 + PLL16X  │ 0_1_1_10_111 │                                                  
    source (like crystals and resonators). In addition   ├─────────────────┼──────────────┤                                                  
    to the required stabilization procedure noted above  │ XTAL3 + PLL1X   │ 0_1_1_11_011 │                                                  
    an additional delay of approximately 75 µs occurs    │ XTAL3 + PLL2X   │ 0_1_1_11_100 │                                                  
    while the hardware switches the source.              │ XTAL3 + PLL4X   │ 0_1_1_11_101 │                                                  
                                                         │ XTAL3 + PLL8X   │ 0_1_1_11_110 │                                                  
                                                         │ XTAL3 + PLL16X  │ 0_1_1_11_111 │                                                                                                                      
                                                         └─────────────────┴──────────────┘                                                                                                           
                                                                                                           
TO PAUSE EXECUTION BRIEFLY:
    A pause is a simple delay usually meant to work within the human timeframe; noticeable
    delays a human can detect, but not accurate enough for the synchronization of signals.
    If accuracy is critical, use the technique in "To Synchronize...", below, instead.                                                                                  
          
    STEP 1: Call PauseUSec, PauseMSec, or PauseSec to pause for durations in units of
            microseconds, milliseconds, or seconds, respectively.

    NOTE: The Pause methods automatically do the following:
          • Adjusts for System Clock changes so that their duration is consistent as long
            as the System Clock frequency does not change during a pause operation itself.
          • Adjusts the specified duration down to compensate for the Spin Interpreter
            overhead of calling the method, performing the delay, and returning from the
            method.  This is so the effect of a Pause statement is a delay that is as close
            to the desired delay as possible, rather than being the desired delay plus the
            call/return delay.  The actual length of the delay will vary slightly depending
            on the expression used for the duration.
          • Limits the minimum duration to a "Spin Interpreter" safe value that will not
            cause apparent "lock ups" associated with waiting for a System Counter value
            that has already passed.  This limit code looks like "#> WMIN" and is noted in
            code comments as "freeze-protected", meaning it's well-protected against issues
            of this type.

    Keep in mind that System Clock frequency can greatly affect the shortest durations that
    are possible and clock source accuracy will affect duration accuracy.  For example, in
    Spin code, while running at 80 MHz, the shortest duration for PauseUSec is about 54
    (54 microseconds), but beyond that minimum, it can reliably delay for 55 µs, 56 µs,
    57 µs, etc.  When running as RCSLOW (ideally 20 KHz), the shortest duration is about
    216 (216 milliseconds), but beyond that minimum, using PauseMSec it can delay for about
    217 ms, 218 ms, etc.; however, the RCSLOW and RCFAST clock sources are never ideal for
    accurate timing and can vary wildly from chip to chip, and even within the session of an
    application as environmental temperatures change. 

                                                                       
    
TO SYNCHRONIZE A COMMAND/ROUTINE TO A WINDOW OF TIME (SYNCHRONIZED DELAYS):                                               
    A synchronized delay is an advanced timing mechanism used to accurately synchronize a
    specific command to the start of a defined window of time, and repeat that alignment
    perfectly over multiple loops.  If accuracy or synchronization is not critical, using
    the pause technique shown in "To Pause Execution Briefly", above, may be appropriate.                                                                                  
      
    STEP 1: Call MarkSync to mark the reference point in time.

    STEP 2: Call WaitSyncUSec, WaitSyncMSec, or WaitSyncSec immediately before the
            command/routine you wish to synchronize, to wait for the start of the next
            window of time (measured in units of microseconds, milliseconds, or seconds,
            respectively).
         
    NOTE: The WaitSync methods automatically do the following:
          • Adjusts for System Clock changes so that their time-window width is consistent
            as long as the System Clock frequency does not change during a wait operation
            itself.
          • Limits the minimum width to a "Spin Interpreter" safe value that will not cause
            apparent "lock ups" associated with waiting for a System Counter value that has
            already passed.  Noted in code comments as "freeze-resistant," meaning it has
            simple (but not fool-proof) protection against developer oversights. 
          
    In loops, the MarkSync/WaitSync methods (Synchronized Delays) have an advantage over
    the Pause methods in that they automatically compensate for the loop's overhead so that
    the command following the WaitSync executes at the exact same interval each time, even
    if the loop itself has multiple decision paths that each take different amounts of time
    to execute.


    
THE DIFFERENCE BETWEEN PAUSE AND WAIT METHODS:    
    The following code uses PauseUSec in a loop that toggles a pin.  Note that "clk" is the
    nickname given to this Clock object and we are using an accurate, external clock source.

          dira[16]~~
          repeat
            clk.PauseUSec(100)
            !outa[16]          
          
    This produces a signal on P16 that looks similar to the following timing diagram.

          P16 ─       
                                                      ... 
                0   100  200  300  400  500  600  700  800  900   
                                   Time (µS)
          
    Notice how the edges of the signal do not line up with the shown time reference.  The
    pause method reliably delays for about 100 µS, but the rest of the loop (!outa[16] and
    repeat) take some time to execute also, causing the rising and falling edges to be
    slightly off of the shown time reference window.

    If the intention was for the rising and falling edges to be exactly lined up with our
    time reference window of 100 µS, then the MarkSync/WaitSync methods should be used.

    The following code performs the same toggling task as the previous example.  Note that
    "clk" is the nickname given to this Clock object and we are using an accurate, external
    clock source.

          dira[16]~~
          clk.MarkSync
          repeat
            clk.WaitSyncUSec(100)
            !outa[16]     
          
    This produces a signal on P16 that looks similar to the following timing diagram.

          P16 ─       
                                                      ... 
                0   100  200  300  400  500  600  700  800  900   
                                   Time (µS)
           
    The MarkSync method marks a reference point in time (0 µS) and each call to
    WaitSyncUSec(100) waits until the next multiple of 100 µS from that reference point.
    As long as the loop isn't too long, this effectively compensates for the loop's
    overhead automatically, causing the !outa[16] statement to execute at exact 100 µS
    intervals.       
   

    
SETCLOCK METHOD EXPLANATION:
    This is a description of how the SetMode method works.  It is not necessary to
    understand this in order to use it, but the explanation is here for "the curious" since
    there's not enough "comment" room in the method itself.

    The SetMode method was written to accept the same clock        Clock Setting Constants                               
    setting constants as used by the _CLKMODE constant in an      ┌──────────┬───────┬─────┐                             
    object's CON block.  The clock setting constants are a set    │ Clock    │       │     │                             
    of binary enumerated values (see table at right) that when    │ Setting  │ Value │ Bit │                             
    combined into an expression, like xtal1 + pll16x, form a      │ Constant │       │ ID  │                             
    binary pattern indicating the desired clock mode.  This       ├──────────┼───────┼─────┤                             
    pattern does not match what's required for the Clk Register,  │  PLL16x  │ 1024  │ 10  │                             
    so the SetMode method must translate the binary pattern       │  PLL8x   │  512  │  9  │                             
    given by the clock setting expression (newMode) into the      │  PLL4x   │  256  │  8  │                             
    proper Clk Register binary pattern.                           │  PLL2x   │  128  │  7  │                             
                                                                  │  PLL1x   │   64  │  6  │                             
    Prior to version 1.2 of the Clock object, the clock setting   │  XTAL3   │   32  │  5  │
    expression was parsed and formed into the CLK Register value  │  XTAL2   │   16  │  4  │
    using the elemental bit meanings; however, that was found to  │  XTAL1   │    8  │  3  │
    take a significant amount of time.                            │  XINPUT  │    4  │  2  │
                                                                  │  RCSLOW  │    2  │  1  │
    To improve this, another study was performed on the binary    │  RCFAST  │    1  │  0  │
    patterns of the clock setting constants and the corresponding └──────────┴───────┴─────┘
    CLK Register values.  Through that effort, it was clear that
    a mapping from one to another is the most code-and-time-efficient translation.  With a
    conversion of the clock setting constant to a contiguous index, a simple array access
    is all that is needed to obtain the final value.

    Goal:     Clock Mode expression converted to index of 0..25.
    Purpose:  Reference 26-element array of CLK Register values.
              ie: Expression-to-Index-to-Array = proper CLK Register Value.

    Solution: [Refer to the table below during each bullet of this explanation, noting the
              values in each column]  This table shows Valid Clock Modes (expressions) and
              their binary value.  We'll apply the following operations on those values:
                • Using the Encode operator (>|) the raw value is converted to an "index"
                  value starting with 1..11, then repeating 7..11; close to our goal.
                • That encode operator took care of the leftmost high (1) bit in the value.
                  If the leftmost high bit is removed, isolating the leftover bits, an
                  Encode operation (iso >|) applied to the remaining bit pattern yields a
                  series of 0,3,4,5, and 6.
                • Then an additional transform on the previous result, subtracting 3 and
                  limiting result to a minimum of 0 (-3#>0), yields a series of 0, 1, 2,
                  and 3.
                • Multiplying the last result by 5 (*5) yields: 0, 5, 10, and 15.
                • Finally, adding that last result to that of the first result yields a
                  series of 1..26, or 0..25 (the goal) by simply subtracting 1.  Using
                  this value as the index into a prefilled array containing the
                  corresponding CLK Register values, returns the proper value needed to set
                  the clock.
                • The expression that performs the conversion of mode-to-index is given
                  below, where M is the clock mode value.  The isolation operation is
                  performed by xoring original with the decoded form of the original - 1,
                  or "^ (|<(>|M - 1))."

                    Idx := >|M + ( >|(M ^ (|<(>|M - 1))) - 3 #> 0 ) * 5 - 1

          ┌─────────────────┬──────────────┬┬────┬────┬─────┬────┬─────┬┬─────────────────┐
          │   Valid Clock   │ Binary Value ││    │iso │ iso │    │     ││  CLK Register   │                                
          │      Modes      │              ││ >| │ >| │-3#>0│ *5 │Index││   Value (Hex)   │
          ├─────────────────┼──────────────┼┼────┼────┼─────┼────┼─────┼┼─────────────────┤
          │ RCFAST          │ %00000000001 ││  1 │  0 │  0  │  0 │  1  ││ %00000000 ($00) │
          │ RCSLOW          │ %00000000010 ││  2 │  0 │  0  │  0 │  2  ││ %00000001 ($01) │
          │ XINPUT          │ %00000000100 ││  3 │  0 │  0  │  0 │  3  ││ %00100010 ($22) │
          │ XTAL1           │ %00000001000 ││  4 │  0 │  0  │  0 │  4  ││ %00101010 ($2A) │
          │ XTAL2           │ %00000010000 ││  5 │  0 │  0  │  0 │  5  ││ %00110010 ($32) │
          │ XTAL3           │ %00000100000 ││  6 │  0 │  0  │  0 │  6  ││ %00111010 ($3A) │
          │ XINPUT + PLL1X  │ %00001000100 ││  7 │  3 │  0  │  0 │  7  ││ %01100011 ($63) │
          │ XINPUT + PLL2X  │ %00010000100 ││  8 │  3 │  0  │  0 │  8  ││ %01100100 ($64) │
          │ XINPUT + PLL4X  │ %00100000100 ││  9 │  3 │  0  │  0 │  9  ││ %01100101 ($65) │
          │ XINPUT + PLL8X  │ %01000000100 ││ 10 │  3 │  0  │  0 │ 10  ││ %01100110 ($66) │
          │ XINPUT + PLL16X │ %10000000100 ││ 11 │  3 │  0  │  0 │ 11  ││ %01100111 ($67) │
          │ XTAL1 + PLL1X   │ %00001001000 ││  7 │  4 │  1  │  5 │ 12  ││ %01101011 ($6B) │
          │ XTAL1 + PLL2X   │ %00010001000 ││  8 │  4 │  1  │  5 │ 13  ││ %01101100 ($6C) │
          │ XTAL1 + PLL4X   │ %00100001000 ││  9 │  4 │  1  │  5 │ 14  ││ %01101101 ($6D) │
          │ XTAL1 + PLL8X   │ %01000001000 ││ 10 │  4 │  1  │  5 │ 15  ││ %01101110 ($6E) │
          │ XTAL1 + PLL16X  │ %10000001000 ││ 11 │  4 │  1  │  5 │ 16  ││ %01101111 ($6F) │
          │ XTAL2 + PLL1X   │ %00001010000 ││  7 │  5 │  2  │ 10 │ 17  ││ %01110011 ($73) │
          │ XTAL2 + PLL2X   │ %00010010000 ││  8 │  5 │  2  │ 10 │ 18  ││ %01110100 ($74) │
          │ XTAL2 + PLL4X   │ %00100010000 ││  9 │  5 │  2  │ 10 │ 19  ││ %01110101 ($75) │
          │ XTAL2 + PLL8X   │ %01000010000 ││ 10 │  5 │  2  │ 10 │ 20  ││ %01110110 ($76) │
          │ XTAL2 + PLL16X  │ %10000010000 ││ 11 │  5 │  2  │ 10 │ 21  ││ %01110111 ($77) │
          │ XTAL3 + PLL1X   │ %00001100000 ││  7 │  6 │  3  │ 15 │ 22  ││ %01111011 ($7B) │
          │ XTAL3 + PLL2X   │ %00010100000 ││  8 │  6 │  3  │ 15 │ 23  ││ %01111100 ($7C) │
          │ XTAL3 + PLL4X   │ %00100100000 ││  9 │  6 │  3  │ 15 │ 24  ││ %01111101 ($7D) │
          │ XTAL3 + PLL8X   │ %01000100000 ││ 10 │  6 │  3  │ 15 │ 25  ││ %01111110 ($7E) │
          │ XTAL3 + PLL16X  │ %10000100000 ││ 11 │  6 │  3  │ 15 │ 26  ││ %01111111 ($7F) │
          └─────────────────┴──────────────┴┴────┴────┴─────┴────┴─────┴┴─────────────────┘                                                                        
}}                    
