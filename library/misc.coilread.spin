{{
*****************************************
* COILREAD Demo v1.0                    *
* Author: Beau Schwabe                  *
* Copyright (c) 2007 Parallax           *
* See end of file for terms of use.     *
*****************************************
}}

''Each Coil read takes approximately 40µS

CON

  CoilConstant = 85

VAR

   long cogon, cog
   long COILStack[24]
   long CoilTemp
   long CoilCalibrate

OBJ

   time : "system.clock"

PUB start(PingPin,CoilPin,ReadPin,COILAddress)

'' Start COILREAD - starts a cog
'' returns false if no cog available
''

  stop
  cogon := (cog := cognew(COILREAD(PingPin,CoilPin,ReadPin,COILAddress),@COILStack)) > 0

PUB stop

'' Stop COILREAD - frees a cog

  if cogon~
    cogstop(cog)

PUB COILREAD(PingPin,CoilPin,ReadPin,COILAddress)
       dira[ReadPin] := 0                                   'Make ReadPin an INPUT
       outa[PingPin] := 0                                   'Preset PingPin as a LOW
       outa[CoilPin] := 0                                   'Preset CoilPin as a LOW
repeat
       dira[CoilPin] := 0                                   'Make CoilPin an INPUT (disconnect Coil)
       CoilCore(PingPin,ReadPin)                            'Read circuit without coil (Calibration)
       CoilCalibrate := (CoilTemp* CoilConstant)/100        'Load value into CoilCalibrate
       dira[CoilPin] := 1                                   'Make CoilPin an OUTPUT (reconnect Coil)
       CoilCore(PingPin,ReadPin)                            'Read circuit with coil
       CoilTemp := 100-(( CoilTemp * 100 ) / CoilCalibrate ) 'Value calculated is a percentage and
                                                            'should be temperature compensated.
       long [COILAddress] := CoilTemp                       'Update Coilvalue

PRI CoilCore(PingPin,ReadPin)
       dira[PingPin] := 1                                   'Make PingPin an OUTPUT
       outa[PingPin] := 1                                   'Make PingPin HIGH                          'Ping the COIL for 10uS'
       time.PauseUSec(10)                                    'Pause for 10uS
       outa[PingPin] := 0                                   'Make PingPin LOW
       CoilTemp := cnt                                      'grab clock tick counter value
       WAITPEQ(0,|< ReadPin,0)                              'wait until ReadPin goes LOW
       CoilTemp := cnt - CoilTemp                           'see how many clock cycles passed until ReadPin went LOW





       'time.PauseMSec(5)                                    'Allow things to settle for 5mS

'Below is a test to read the coils 500x faster than the above statement that pauses for 5mS
'
       outa[ReadPin] := 0                                   'Preset ReadPin as a LOW
       dira[ReadPin] := 1                                   'Make ReadPin an OUTPUT
       time.PauseUSec(10)                                    'Allow things to settle for 10µS
       dira[ReadPin] := 0                                   'Make ReadPin an INPUT

