{{
*****************************************
* RCTIME v1.0                           *
* Author: Beau Schwabe                  *
* Copyright (c) 2007 Parallax           *
* See end of file for terms of use.     *
*****************************************
}}

CON
  
VAR

   long cogon, cog
   long RCStack[16]
   long RCTemp
   long Mode
  
PUB start(Pin,State,RCValueAddress)

'' Start RCTIME - starts a cog
'' returns false if no cog available
''
''   RCTIME_ptr = pointer to RCTIME parameters

  stop
  cogon := (cog := cognew(RCTIME(Pin,State,RCValueAddress),@RCStack)) > 0
  Mode := 1

PUB stop

'' Stop RCTIME - frees a cog

  if cogon~
    cogstop(cog)
    
PUB RCTIME(Pin,State,RCValueAddress)
    repeat
           outa[Pin] := State                   'make I/O an output in the State you wish to measure... and then charge cap
           dira[Pin] := 1                               
           Pause1ms(1)                          'pause for 1mS to charge cap
           dira[Pin] := 0                       'make I/O an input
           RCTemp := cnt                        'grab clock tick counter value
           WAITPEQ(1-State,|< Pin,0)            'wait until pin goes into the opposite state you wish to measure; State: 1=discharge 0=charge
           RCTemp := cnt - RCTemp               'see how many clock cycles passed until desired State changed
           RCTemp := RCTemp - 1600              'offset adjustment (entry and exit clock cycles Note: this can vary slightly with code changes)
           RCTemp := RCTemp >> 4                'scale result (divide by 16) <<-number of clock cycles per itteration loop
           long [RCValueAddress] := RCTemp      'Write RCTemp to RCValue
           
           if Mode == 0                         'Check for forground (0) or background (1) mode of operation; forground = no seperate cog / background = seperate running cog
              quit

PUB Pause1ms(Period)|ClkCycles 
{{Pause execution for Period (in units of 1 ms).}}

  ClkCycles := ((clkfreq / 1000 * Period) - 4296) #> 381     'Calculate 1 ms time unit
  waitcnt(ClkCycles + cnt)                                   'Wait for designated time              

