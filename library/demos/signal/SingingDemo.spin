{{
***************************************
*  Singing Demo v1.0                  *
*  Author: Chip Gracey                *
*  Copyright (c) 2006 Parallax, Inc.  *
*  See end of file for terms of use.  *
***************************************

This is a quick demo which runs 4 VocalTract objects concurrently to sing a 4-part harmony from the 16th century.
It also uses the StereoSpatializer object (which is very under-utilized here) to spread them out into a stereo image.
This runs on the Propeller Demo Board, but really just modulates pin 11 and 10 for the left and right audio signals.
If you have a Propeller Demo Board, just plug in some headphones or speakers. After the song is over, it stops.
}}


CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  #0
  
' Notes and octaves
'
' Ab       A       A#       Bb       B       C       C#       Db       D       D#       Eb       E       F       F#       Gb       G       G#
'─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  o0Af[4], o0A[4], o0As[0], o0Bf[4], o0B[4], o0C[4], o0Cs[0], o0Df[4], o0D[4], o0Ds[0], o0Ef[4], o0E[4], o0F[4], o0Fs[0], o0Gf[4], o0G[4], o0Gs[0] 
  o1Af[4], o1A[4], o1As[0], o1Bf[4], o1B[4], o1C[4], o1Cs[0], o1Df[4], o1D[4], o1Ds[0], o1Ef[4], o1E[4], o1F[4], o1Fs[0], o1Gf[4], o1G[4], o1Gs[0] 
  o2Af[4], o2A[4], o2As[0], o2Bf[4], o2B[4], o2C[4], o2Cs[0], o2Df[4], o2D[4], o2Ds[0], o2Ef[4], o2E[4], o2F[4], o2Fs[0], o2Gf[4], o2G[4], o2Gs[0] 
  o3Af[4], o3A[4], o3As[0], o3Bf[4], o3B[4], o3C[4], o3Cs[0], o3Df[4], o3D[4], o3Ds[0], o3Ef[4], o3E[4], o3F[4], o3Fs[0], o3Gf[4], o3G[4], o3Gs[0] 
  o4Af[4], o4A[4], o4As[0], o4Bf[4], o4B[4], o4C[4], o4Cs[0], o4Df[4], o4D[4], o4Ds[0], o4Ef[4], o4E[4], o4F[4], o4Fs[0], o4Gf[4], o4G[4], o4Gs[0] 
  o5Af[4], o5A[4], o5As[0], o5Bf[4], o5B

  #1, pausenote, halfnote

  'names of vocal tract parameters as offsets for indirectly accessing 4 sets
  #0, aa,ga,gp,vp,vr,f1,f2,f3,f4,na,nf,fa,ff

  shift = -24                   'this pitch shift may be changed: try 0 (normal), -48 (-1 octave), -4 (-1 key)
  
  buffer_size = $1000           'this may be reduced to $10 to save memory, but echoes go away


OBJ

  v[4]    : "signal.synth.speech"
  stereo  : "signal.spatializer"


VAR

  byte  vt[4*13]      'vocal tracts
   
  word  input[4]      'spatializer parameters
  word  angle[4]
  word  depth[4]
  word  knobs

  long  state[4], rnd

  long  buffer[buffer_size]


PUB start | i

  repeat i from 0 to 3
    v[i].start(@vt[i*13], -1, -1, -1)   'start a vocal tract
    v[i].set_attenuation(1)            
    input[i] := v[i].sample_ptr         'set spatializer inputs
    angle[i] := i * $5555               'spread out channels evenly across sound stage

  knobs := %000_110_110_000             'set spatializer echoes
  stereo.start(@input, @buffer, buffer_size, 11, -1, 10, -1) 'start spatializer

  set_formants(0, 275, 850, 2400, 3520) 'set each vocal tract to a different vowel sound
  set_formants(1, 700, 1800, 2550, 3400)
  set_formants(2, 280, 2040, 3040, 3600)
  set_formants(3, 650, 1200, 2500, 3500)

  repeat i from 0 to 3
    set(i, vp, 4)                       'set vibrato pitch range                
    set(i, vr, lookupz(i: 66,68,71,75)) 'give each vocal tract a slightly different vibrato rate
    go(i, 1000 + ?rnd ~> 24)            'let each vocal tract slide to formants while silent, plus randomize start times                
    v[i].set_pace(100)                  'try changing the pace from 100% to higher and lower values (ie 50, 200)

  repeat
    advance(0)   'basso                 'try commenting out some of these lines to hear fewer parts
    advance(1)   'tenor                       
    advance(2)   'alto
    advance(3)   'soprano


PRI set_formants(tract, sf1, sf2, sf3, sf4)

  vt[tract*13+f1] := sf1 / 19
  vt[tract*13+f2] := sf2 / 19
  vt[tract*13+f3] := sf3 / 19
  vt[tract*13+f4] := sf4 / 19
  

PRI set(tract, parameter, value)

  vt[tract*13+parameter] := value
  

PRI get(tract, parameter) : value

  return vt[tract*13+parameter]
  

PRI go(tract, time)

  v[tract].go(time)


PRI advance(tract) | note, vol, time

  if state[tract] == -1
    return

  vol := volume[tract]          'get volume for each vocal tract
  if note := byte[@@parts[tract]][state[tract]++]
    set(tract, gp, note & $FC + shift)
    if note & 1                 'pausenote
      set(tract, ga, vol)
      go(tract, 200)
      go(tract, 1000)     
      set(tract, ga, 0)
      go(tract, 500)
      go(tract, 750)
    elseif note & 2             'halfnote
      set(tract, ga, vol)
      go(tract, 200)
      go(tract, 50)
      go(tract, 200)     
      go(tract, 50)
    else                        'normal
      time := 200
      ifnot get(tract, ga)
        go(tract, 2)
        time := 500
      set(tract, ga, vol)
      go(tract, time)
      go(tract, 1000 - time + ?rnd ~> 27)
  else
    set(tract, ga, 0)           'end of notes
    go(tract, 200)
    go(tract, 2000)
    state[tract]~~

    
DAT

soprano byte o3G
        byte o3G                'measure
        byte o3Fs
        byte o3E
        byte o3D
        byte o3G                'measure
        byte o4A
        byte o4B + pausenote
        byte o4B
        byte o4B                'measure
        byte o4B
        byte o4A
        byte o3G
        byte o4C                'measure
        byte o4B
        byte o4A + pausenote
        byte o3G
        byte o4A                'measure
        byte o4B
        byte o4A
        byte o3G
        byte o3E                'measure
        byte o3Fs
        byte o3G + pausenote
        byte o4D
        byte o4B                'measure
        byte o3G
        byte o4A
        byte o4C
        byte o4B                'measure
        byte o4A
        byte o3G + pausenote
        byte 0
        
alto    byte o3D
        byte o3D                'measure
        byte o3D
        byte o3B
        byte o3B
        byte o3B                'measure
        byte o3D
        byte o3D + pausenote
        byte o3D
        byte o3D                'measure
        byte o3D
        byte o3D
        byte o3B
        byte o3E                'measure
        byte o3D
        byte o3D + pausenote
        byte o3B
        byte o3D                'measure
        byte o3D
        byte o3D
        byte o3D
        byte o3C                'measure
        byte o3C
        byte o3D + pausenote
        byte o3D
        byte o3D                'measure
        byte o3E
        byte o3Fs
        byte o4A
        byte o3G                'measure
        byte o3Fs
        byte o3D + pausenote
        byte 0

tenor   byte o3B
        byte o3B                'measure
        byte o3A
        byte o2G
        byte o2Fs
        byte o2G                'measure
        byte o2Fs
        byte o2G + pausenote
        byte o2G
        byte o2G                'measure
        byte o2G
        byte o2Fs
        byte o2G
        byte o2G                'measure
        byte o2G
        byte o2Fs + pausenote
        byte o2G
        byte o2Fs               'measure
        byte o2G
        byte o2Fs
        byte o2G
        byte o2G                'measure
        byte o3A
        byte o3B + pausenote
        byte o3B
        byte o2G                'measure
        byte o3B
        byte o3D
        byte o3E
        byte o3D                'measure
        byte o3D + halfnote
        byte o3C + halfnote
        byte o3B + pausenote
        byte 0

basso   byte o2G
        byte o2G                'measure
        byte o2D
        byte o2E
        byte o2B
        byte o2E                'measure
        byte o2D
        byte o2G + pausenote
        byte o2G
        byte o1G                'measure
        byte o2B
        byte o2D
        byte o2E
        byte o2C                'measure
        byte o1G
        byte o2D + pausenote
        byte o2E
        byte o2D                'measure
        byte o2G
        byte o2D
        byte o2B
        byte o2C + halfnote     'measure
        byte o2B + halfnote
        byte o2A
        byte o1G + pausenote
        byte o2G
        byte o2G                'measure
        byte o2E
        byte o2D
        byte o2A
        byte o2B + halfnote     'measure
        byte o2C + halfnote
        byte o2D
        byte o1G
        byte 0

parts   word @basso, @tenor, @alto, @soprano

volume  byte 50-10, 120-40, 170-35, 60-10

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
