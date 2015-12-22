{{
─────────────────────────────────────────────────
File: Float32Full.spin
Version: 1.6
Copyright (c) 2009 Parallax, Inc.
See end of file for terms of use.

Author: Cam Thompson                                      
─────────────────────────────────────────────────
}}

{
HISTORY:
  This object provides IEEE 754 compliant 32-bit floating point math routines implemented in assembler.
  The following table summarizes the differences between: FloatMath, Float32, and Float32Full.

   ┌──────────────────────────┬────────────┬───────────┬───────────┐
   │                          │ FloatMath  │  Float32  │Float32Full│
   ├──────────────────────────┼────────────┼───────────┼───────────┤
   │ Cogs required:           │     0      │     1     │     2     │
   ├──────────────────────────┼────────────┼───────────┼───────────┤
   │ Execution Speed:         │    Slow    │    Fast   │    Fast   │
   │   e.g. FADD (usec)       │    371     │     39    │     39    │
   ├──────────────────────────┼────────────┼───────────┼───────────┤ 
   │ Methods:                 │            │           │           │
   │   FAdd, FSub, FMul, FDiv │     •      │     •     │     •     │
   │   FFloat, FTrunc, FRound │     •      │     •     │     •     │
   │   FSqr, FNeg, FAbs       │     •      │     •     │     •     │
   ├──────────────────────────┼────────────┼───────────┼───────────┤ 
   │   Sin, Cos, Tan          │            │     •     │     •     │
   │   Radians, Degrees       │            │     •     │     •     │
   │   Log, Log10, Exp, Exp10 │            │     •     │     •     │
   │   Pow, Frac              │            │     •     │     •     │
   │   FMod                   │            │     •     │     •     │
   │   Fmin, Fmax             │            │     •     │     •     │
   ├──────────────────────────┼────────────┼───────────┼───────────┤ 
   │   FMod                   │            │           │     •     │
   │   ASin, ACos, ATan       │            │           │     •     │
   │   ATan2                  │            │           │     •     │
   │   Floor, Ceil            │            │           │     •     │
   │   FFunc                  │            │           │     •     │
   └──────────────────────────┴────────────┴───────────┴───────────┘
  Additional documentation is provided in the file: Propeller Floating Point.pdf

  V1.6 - December 15, 2009
  • fixed problem in Exp function, and base=0 case in Pow  
  V1.5 - July 14, 2009
  • added comments to Spin methods
  • removed sendCmd comments
  • added stop call to release FLOAT32A cog
  V1.4 - September 25, 2007
  • fixed problem in loadTable routine used by Log and Exp functions
  V1.3 - April 1, 2007
  • fixed Sin/Cos interpolation code
  V1.2 - March 26, 2007
  • fixed Pow to handle negative base values
  V1.1 - June 22, 2006
  • updated Sin/Cos code to correct problem with negative values 
  V1.0 - May 17, 2006 
  • original version

USAGE:
  • call start first.
  • Float32 uses one cog for its operation.   
}


CON
  FAddCmd       = 1 << 16
  FSubCmd       = 2 << 16
  FMulCmd       = 3 << 16
  FDivCmd       = 4 << 16
  FFloatCmd     = 5 << 16 
  FTruncCmd     = 6 << 16
  FRoundCmd     = 7 << 16
  FSqrCmd       = 8 << 16
  FCmpCmd       = 9 << 16
  SinCmd        = 10 << 16
  CosCmd        = 11 << 16
  TanCmd        = 12 << 16
  LogCmd        = 13 << 16
  Log10Cmd      = 14 << 16
  ExpCmd        = 15 << 16
  Exp10Cmd      = 16 << 16
  PowCmd        = 17 << 16
  FracCmd       = 18 << 16

  FModCmd       = 19 << 16 
  ASinCmd       = 20 << 16
  ACosCmd       = 21 << 16
  ATanCmd       = 22 << 16
  ATan2Cmd      = 23 << 16
  FloorCmd      = 24 << 16
  CeilCmd       = 25 << 16
  
  FFuncCmd      = $8000<<16
  LoadCmd       = $8000<<16
  SaveCmd       = $8001<<16
  FNegCmd       = $8002<<16
  FAbsCmd       = $8003<<16
  JmpCmd        = $8004<<16
  JmpEqCmd      = $8005<<16
  JmpNeCmd      = $8006<<16
  JmpLtCmd      = $8007<<16
  JmpLeCmd      = $8008<<16
  JmpGtCmd      = $8009<<16
  JmpGeCmd      = $800A<<16
  JmpNaNCmd     = $800B<<16
    
  SignFlag      = $1
  ZeroFlag      = $2
  NaNFlag       = $8
  
VAR

  long  cog
  long  command2, cmdReturn2, arg1, arg2, command, cmdReturn
  
OBJ

  fa             : "math.float.32.full.core"
  
PUB start : okay
{{Start start floating point engine in a new cog.
  Returns:     True (non-zero) if cog started, or False (0) if no cog is available.}}

  stop
  okay := cog := cognew(@getCommand, @command) + 1
  fa.start(@command2)

PUB stop
{{Stop floating point engine and release the cog.}}

  if cog
    fa.stop
    cogstop(cog~ - 1)
  command~
         
PUB FAdd(a, b)
{{Addition: result = a + b
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value
  Returns:   32-bit floating point value}}

  command := FAddCmd + @a
  repeat while command
  return cmdReturn
          
PUB FSub(a, b)
{{Subtraction: result = a - b
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value
  Returns:   32-bit floating point value}}

  command := FSubCmd + @a
  repeat while command
  return cmdReturn
  
PUB FMul(a, b)
{{Multiplication: result = a * b
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value
  Returns:   32-bit floating point value}}

  command := FMulCmd + @a
  repeat while command
  return cmdReturn
          
PUB FDiv(a, b)
{{Division: result = a / b
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value
  Returns:   32-bit floating point value}}

  command := FDivCmd + @a
  repeat while command
  return cmdReturn

PUB FFloat(n)
{{Convert integer to floating point.
  Parameters:
    n        32-bit integer value
  Returns:   32-bit floating point value}}

  command := FFloatCmd + @n
  repeat while command
  return cmdReturn  

PUB FTrunc(a)
{{Convert floating point to integer (with truncation).
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit integer value }}

  command := FTruncCmd + @a
  repeat while command
  return cmdReturn  

PUB FRound(a)
{{Convert floating point to integer (with rounding).
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit integer value }}
  
  command := FRoundCmd + @a
  repeat while command
  return cmdReturn  

PUB FSqr(a)
{{Square root.
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value }}

  command := FSqrCmd + @a
  repeat while command
  return cmdReturn  

PUB FCmp(a, b)
{{Floating point comparison.
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value
  Returns:   32-bit integer value
             -1 if a < b
              0 if a == b
              1 if a > b}}
              
  command := FCmpCmd + @a
  repeat while command
  return cmdReturn

PUB Sin(a)
{{Sine of an angle. 
  Parameters:
    a        32-bit floating point value (angle in radians)
  Returns:   32-bit floating point value}}
  
  command := SinCmd + @a
  repeat while command
  return cmdReturn  

PUB Cos(a)
{{Cosine of an angle.
  Parameters:
    a        32-bit floating point value (angle in radians)
  Returns:   32-bit floating point value}}
  
  command := CosCmd + @a
  repeat while command
  return cmdReturn  

PUB Tan(a)
{{Tangent of an angle.
  Parameters:
    a        32-bit floating point value (angle in radians)
  Returns:   32-bit floating point value}}
  
  command := TanCmd + @a
  repeat while command
  return cmdReturn

PUB Log(a)
{{Logarithm (base e).
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value}}
  
  command := LogCmd + @a
  repeat while command
  return cmdReturn  

PUB Log10(a)
{{Logarithm (base 10).
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value}}
  
  command := Log10Cmd + @a
  repeat while command
  return cmdReturn  

PUB Exp(a)
{{Exponential (e raised to the power a).
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value}}
  
  command := ExpCmd + @a
  repeat while command
  return cmdReturn  

PUB Exp10(a)
{{Exponential (10 raised to the power a).
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value}}
  
  command := Exp10Cmd + @a
  repeat while command
  return cmdReturn  

PUB Pow(a, b)
{{Power (a to the power b).
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value  
  Returns:   32-bit floating point value}}
  
  command := PowCmd + @a
  repeat while command
  return cmdReturn

PUB Frac(a)
{{Fraction (returns fractional part of a).
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value}}
  
  command := FracCmd + @a
  repeat while command
  return cmdReturn
  
PUB FNeg(a)
{{Negate: result = -a.
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value}}
  
  return a ^ $8000_0000

PUB FAbs(a)
{{Absolute Value: result = |a|.
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value}}
  
  return a & $7FFF_FFFF
  
PUB Radians(a) | b, c
{{Convert to radians
  Parameters:
    a        32-bit floating point value (angle in degrees)
  Returns:   32-bit floating point value (angle in radians)}}
  
  b := a
  c := constant(pi / 180.0)
  'sendCmd(FMulCmd + @a) 
  command := FMulCmd + @b
  repeat while command
  return cmdReturn  

PUB Degrees(a) | b, c
{{Convert to degrees
  Parameters:
    a        32-bit floating point value (angle in radians)
  Returns:   32-bit floating point value (angle in degrees)}}
  
  b := a
  c := constant(180.0 / pi)  
  'sendCmd(FMulCmd + @a) 
  command := FMulCmd + @b
  repeat while command
  return cmdReturn  

PUB FMin(a, b)
{{Minimum: result = the minimum value a or b.
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value  
  Returns:   32-bit floating point value}}
  
  command := FCmpCmd + @a
  repeat while command
  if cmdReturn < 0
    return a
  return b
  
PUB FMax(a, b)
{{Maximum: result = the maximum value a or b.
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value  
  Returns:   32-bit floating point value}}
  
  command := FCmpCmd + @a
  repeat while command
  if cmdReturn < 0
    return b
  return a

{┌───────────────────┐
 │ Float32A routines │
 └───────────────────┘}

PUB FMod(a, b)
{{Floating point remainder: result = the remainder of a / b.
  Parameters:
    a        32-bit floating point value
    b        32-bit floating point value  
  Returns:   32-bit floating point value}}
  
  command2 := FModCmd + @a
  repeat while command2
  return cmdReturn2

PUB ASin(a)
{{Arc Sine of a. 
  Parameters:
    a        32-bit floating point value (|a| must be < 1)
  Returns:   32-bit floating point value (angle in radians)}}
  
  command2 := ASinCmd + @a
  repeat while command2
  return cmdReturn2

PUB ACos(a)
{{Arc Cosine of a. 
  Parameters:
    a        32-bit floating point value (|a| must be < 1)
  Returns:   32-bit floating point value (angle in radians)
             if |a| > 1, NaN is returned}}

  command2 := ACosCmd + @a
  repeat while command2
  return cmdReturn2

PUB ATan(a)
{{Arc Tangent of a. 
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value (angle in radians)}}

  command2 := ATanCmd + @a
  repeat while command2
  return cmdReturn2

PUB ATan2(a, b)
{{Arc Tangent of a / b. 
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value (angle in radians)}}
  
  command2 := ATan2Cmd + @a
  repeat while command2
  return cmdReturn2

PUB Floor(a)
{{Calculate the floating point value of the nearest integer <= a. 
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value}}
  
  command2 := FloorCmd + @a
  repeat while command2
  return cmdReturn2

PUB Ceil(a)
{{Calculate the floating point value of the nearest integer >= a. 
  Parameters:
    a        32-bit floating point value
  Returns:   32-bit floating point value}}
  
  command2 := CeilCmd + @a
  repeat while command2
  return cmdReturn2

PUB FFunc(cmdPointer)
{{User-defined function processor. 
  Parameters:
    cmdPointer        pointer to command list in DAT section}}
    
  command2 := FFuncCmd + cmdPointer
  repeat while command2
  return cmdReturn2

DAT

'---------------------------
' Assembly language routines
'---------------------------
                        org

getCommand              rdlong  t1, par wz              ' wait for command
          if_z          jmp     #getCommand

                        mov     t2, t1                  ' load fnumA
                        rdlong  fnumA, t2
                        add     t2, #4          
                        rdlong  fnumB, t2               ' load fnumB

                        shr     t1, #16 wz              ' get command
                        cmp     t1, #(FracCmd>>16)+1 wc ' check for valid command
          if_z_or_nc    jmp     #:exitNaN 
                        shl     t1, #1
                        add     t1, #:cmdTable-2 
                        jmp     t1                      ' jump to command

:cmdTable               call    #_FAdd                  ' command dispatch table
                        jmp     #endCommand
                        call    #_FSub
                        jmp     #endCommand
                        call    #_FMul
                        jmp     #endCommand
                        call    #_FDiv
                        jmp     #endCommand
                        call    #_FFloat
                        jmp     #endCommand
                        call    #_FTrunc
                        jmp     #endCommand
                        call    #_FRound
                        jmp     #endCommand
                        call    #_FSqr
                        jmp     #endCommand
                        call    #cmd_FCmp
                        jmp     #endCommand
                        call    #_Sin
                        jmp     #endCommand
                        call    #_Cos
                        jmp     #endCommand
                        call    #_Tan
                        jmp     #endCommand
                        call    #_Log
                        jmp     #endCommand
                        call    #_Log10
                        jmp     #endCommand
                        call    #_Exp
                        jmp     #endCommand
                        call    #_Exp10
                        jmp     #endCommand
                        call    #_Pow
                        jmp     #endCommand
                        call    #_Frac
                        jmp     #endCommand
:cmdTableEnd

:exitNaN                mov     fnumA, NaN              ' unknown command

endCommand              mov     t1, par                 ' return result
                        add     t1, #4
                        wrlong  fnumA, t1
                        wrlong  Zero,par                ' clear command status
                        jmp     #getCommand             ' wait for next command

'------------------------------------------------------------------------------

cmd_FCmp                call    #_FCmp                  ' compare fnumA and fnumB
                        mov     fnumA, status           ' return compare status
cmd_FCmp_ret            ret

'------------------------------------------------------------------------------
' _FAdd    fnumA = fnumA + fNumB
' _FAddI   fnumA = fnumA + {Float immediate}
' _FSub    fnumA = fnumA - fNumB
' _FSubI   fnumA = fnumA - {Float immediate}
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1
'------------------------------------------------------------------------------

_FSubI                  movs    :getB, _FSubI_ret       ' get immediate value
                        add     _FSubI_ret, #1
:getB                   mov     fnumB, 0

_FSub                   xor     fnumB, Bit31            ' negate B
                        jmp     #_FAdd                  ' add values                                               

_FAddI                  movs    :getB, _FAddI_ret       ' get immediate value
                        add     _FAddI_ret, #1
:getB                   mov     fnumB, 0

_FAdd                   call    #_Unpack2               ' unpack two variables                    
          if_c_or_z     jmp     #_FAdd_ret              ' check for NaN or B = 0

                        test    flagA, #SignFlag wz     ' negate A mantissa if negative
          if_nz         neg     manA, manA
                        test    flagB, #SignFlag wz     ' negate B mantissa if negative
          if_nz         neg     manB, manB

                        mov     t1, expA                ' align mantissas
                        sub     t1, expB
                        abs     t1, t1
                        max     t1, #31
                        cmps    expA, expB wz,wc
          if_nz_and_nc  sar     manB, t1
          if_nz_and_c   sar     manA, t1
          if_nz_and_c   mov     expA, expB        

                        add     manA, manB              ' add the two mantissas
                        cmps    manA, #0 wc, nr         ' set sign of result
          if_c          or      flagA, #SignFlag
          if_nc         andn    flagA, #SignFlag
                        abs     manA, manA              ' pack result and exit
                        call    #_Pack  
_FSubI_ret
_FSub_ret 
_FAddI_ret
_FAdd_ret               ret      

'------------------------------------------------------------------------------
' _FMul    fnumA = fnumA * fNumB
' _FMulI   fnumA = fnumA * {Float immediate}
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2
'------------------------------------------------------------------------------

_FMulI                  movs    :getB, _FMulI_ret       ' get immediate value
                        add     _FMulI_ret, #1
:getB                   mov     fnumB, 0

_FMul                   call    #_Unpack2               ' unpack two variables
          if_c          jmp     #_FMul_ret              ' check for NaN

                        xor     flagA, flagB            ' get sign of result
                        add     expA, expB              ' add exponents
                        mov     t1, #0                  ' t2 = upper 32 bits of manB
                        mov     t2, #32                 ' loop counter for multiply
                        shr     manB, #1 wc             ' get initial multiplier bit 
                                    
:multiply if_c          add     t1, manA wc             ' 32x32 bit multiply
                        rcr     t1, #1 wc
                        rcr     manB, #1 wc
                        djnz    t2, #:multiply

                        shl     t1, #3                  ' justify result and exit
                        mov     manA, t1                        
                        call    #_Pack 
_FMulI_ret
_FMul_ret               ret

'------------------------------------------------------------------------------
' _FDiv    fnumA = fnumA / fNumB
' _FDivI   fnumA = fnumA / {Float immediate}
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2
'------------------------------------------------------------------------------

_FDivI                  movs    :getB, _FDivI_ret       ' get immediate value
                        add     _FDivI_ret, #1
:getB                   mov     fnumB, 0

_FDiv                   call    #_Unpack2               ' unpack two variables
          if_c_or_z     mov     fnumA, NaN              ' check for NaN or divide by 0
          if_c_or_z     jmp     #_FDiv_ret
        
                        xor     flagA, flagB            ' get sign of result
                        sub     expA, expB              ' subtract exponents
                        mov     t1, #0                  ' clear quotient
                        mov     t2, #30                 ' loop counter for divide

:divide                 shl     t1, #1                  ' divide the mantissas
                        cmps    manA, manB wz,wc
          if_z_or_nc    sub     manA, manB
          if_z_or_nc    add     t1, #1
                        shl     manA, #1
                        djnz    t2, #:divide

                        mov     manA, t1                ' get result and exit
                        call    #_Pack                        
_FDivI_ret
_FDiv_ret               ret

'------------------------------------------------------------------------------
' _FFloat  fnumA = float(fnumA)
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------
         
_FFloat                 mov     flagA, fnumA            ' get integer value
                        mov     fnumA, #0               ' set initial result to zero
                        abs     manA, flagA wz          ' get absolute value of integer
          if_z          jmp     #_FFloat_ret            ' if zero, exit
                        shr     flagA, #31              ' set sign flag
                        mov     expA, #31               ' set initial value for exponent
:normalize              shl     manA, #1 wc             ' normalize the mantissa 
          if_nc         sub     expA, #1                ' adjust exponent
          if_nc         jmp     #:normalize
                        rcr     manA, #1                ' justify mantissa
                        shr     manA, #2
                        call    #_Pack                  ' pack and exit
_FFloat_ret             ret

'------------------------------------------------------------------------------
' _FTrunc  fnumA = fix(fnumA)
' _FRound  fnumA = fix(round(fnumA))
' changes: fnumA, flagA, expA, manA, t1 
'------------------------------------------------------------------------------

_FTrunc                 mov     t1, #0                  ' set for no rounding
                        jmp     #fix

_FRound                 mov     t1, #1                  ' set for rounding

fix                     call    #_Unpack                ' unpack floating point value
          if_c          jmp     #_FRound_ret            ' check for NaN
                        shl     manA, #2                ' left justify mantissa 
                        mov     fnumA, #0               ' initialize result to zero
                        neg     expA, expA              ' adjust for exponent value
                        add     expA, #30 wz
                        cmps    expA, #32 wc
          if_nc_or_z    jmp     #_FRound_ret
                        shr     manA, expA
                                                       
                        add     manA, t1                ' round up 1/2 lsb   
                        shr     manA, #1
                        
                        test    flagA, #signFlag wz     ' check sign and exit
                        sumnz   fnumA, manA
_FTrunc_ret
_FRound_ret             ret
                                  
'------------------------------------------------------------------------------
' _FSqr    fnumA = sqrt(fnumA)
' changes: fnumA, flagA, expA, manA, t1, t2, t3, t4, t5 
'------------------------------------------------------------------------------

_FSqr                   call    #_Unpack                 ' unpack floating point value
          if_nc         mov     fnumA, #0                ' set initial result to zero
          if_c_or_z     jmp     #_FSqr_ret               ' check for NaN or zero
                        test    flagA, #signFlag wz      ' check for negative
          if_nz         mov     fnumA, NaN               ' yes, then return NaN                       
          if_nz         jmp     #_FSqr_ret
          
                        test    expA, #1 wz             ' if even exponent, shift mantissa 
          if_z          shr     manA, #1
                        sar     expA, #1                ' get exponent of root
                        mov     t1, Bit30               ' set root value to $4000_0000                ' 
                        mov     t2, #31                 ' get loop counter

:sqrt                   or      fnumA, t1               ' blend partial root into result
                        mov     t3, #32                 ' loop counter for multiply
                        mov     t4, #0
                        mov     t5, fnumA
                        shr     t5, #1 wc               ' get initial multiplier bit
                        
:multiply if_c          add     t4, fnumA wc            ' 32x32 bit multiply
                        rcr     t4, #1 wc
                        rcr     t5, #1 wc
                        djnz    t3, #:multiply

                        cmps    manA, t4 wc             ' if too large remove partial root
          if_c          xor     fnumA, t1
                        shr     t1, #1                  ' shift partial root
                        djnz    t2, #:sqrt              ' continue for all bits
                        
                        mov     manA, fnumA             ' store new mantissa value and exit
                        shr     manA, #1
                        call    #_Pack
_FSqr_ret               ret

'------------------------------------------------------------------------------
' _FCmp    set Z and C flags for fnumA - fNumB
' _FCmpI   set Z and C flags for fnumA - {Float immediate}
' changes: status, t1
'------------------------------------------------------------------------------

_FCmpI                  movs    :getB, _FCmpI_ret       ' get immediate value
                        add     _FCmpI_ret, #1
:getB                   mov     fnumB, 0

_FCmp                   mov     t1, fnumA               ' compare signs
                        xor     t1, fnumB
                        and     t1, Bit31 wz
          if_z          jmp     #:cmp1                  ' same, then compare magnitude
          
                        mov     t1, fnumA               ' check for +0 or -0 
                        or      t1, fnumB
                        andn    t1, Bit31 wz,wc         
          if_z          jmp     #:exit
                    
                        test    fnumA, Bit31 wc         ' compare signs
                        jmp     #:exit

:cmp1                   test    fnumA, Bit31 wz         ' check signs
          if_nz         jmp     #:cmp2
                        cmp     fnumA, fnumB wz,wc
                        jmp     #:exit

:cmp2                   cmp     fnumB, fnumA wz,wc      ' reverse test if negative

:exit                   mov     status, #1              ' if fnumA > fnumB, t1 = 1
          if_c          neg     status, status          ' if fnumA < fnumB, t1 = -1
          if_z          mov     status, #0              ' if fnumA = fnumB, t1 = 0
_FCmpI_ret
_FCmp_ret               ret

'------------------------------------------------------------------------------
' _Sin     fnumA = sin(fnumA)
' _Cos     fnumA = cos(fnumA)
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
' changes: t1, t2, t3, t4, t5, t6
'------------------------------------------------------------------------------

_Cos                    call    #_FAddI                 ' cos(x) = sin(x + pi/2)
                        long    pi / 2.0

_Sin                    mov     t6, fnumA               ' save original angle
                        call    #_FDivI                 ' reduce angle to 0 to 2pi
                        long    2.0 * pi
                        call    #_FTrunc
                        cmp     fnumA, NaN wz           ' check for NaN
          if_z          jmp     #_Sin_ret               
                        call    #_FFloat
                        call    #_FMulI
                        long    2.0 * pi
                        mov     fnumB, fnumA
                        mov     fnumA, t6
                        call    #_FSub
                        test    fnumA, bit31 wz
          if_z          jmp     #:sin1
                        call    #_FAddI
                        long    2.0 * pi

:sin1                   call    #_FMulI                 ' convert to 13 bit integer plus fraction
                        long    8192.0 / (2.0 * pi)
                        mov     t5, fnumA               ' get fraction
                        call    #_Frac
                        mov     t4, fnumA
                        mov     fnumA, t5               ' get integer
                        call    #_FTrunc                        

                        test    fnumA, Sin_90 wc        ' set C flag for quandrant 2 or 4
                        test    fnumA, Sin_180 wz       ' set Z flag for quandrant 3 or 4
                        negc    fnumA, fnumA            ' if quandrant 2 or 4, negate offset
                        or      fnumA, SineTable        ' blend in sine table address
                        shl     fnumA, #1               ' get table offset

                        rdword  t2, fnumA               ' get first table value
                        negnz   t2, t2                  ' if quandrant 3 or 4, negate
          if_nc         add     fnumA, #2               ' get second table value  
          if_c          sub     fnumA, #2
                        rdword  t3, fnumA
                        negnz   t3, t3                  ' if quandrant 3 or 4, negate

                        mov     fnumA, t2               ' result = float(value1)
                        call    #_FFloat
                        mov     fnumB, t4 wz            ' exit if no fraction
          if_z          jmp     #:sin2

                        mov     t5, fnumA               ' interpolate the fractional value 
                        mov     fnumA, t3
                        sub     fnumA, t2
                        call    #_FFloat 
                        call    #_FMul
                        mov     fnumB, t5
                        call    #_FAdd

:sin2                   call    #_FDivI                 ' set range from -1.0 to 1.0 and exit
                        long    65535.0
_Cos_ret
_Sin_ret                ret

'------------------------------------------------------------------------------
' _Tan   fnumA = tan(fnumA)
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
' changes: t1, t2, t3, t4, t5, t6, t7, t8
'------------------------------------------------------------------------------

_Tan                    mov     t7, fnumA               ' tan(x) = sin(x) / cos(x)
                        call    #_Cos
                        mov     t8, fnumA
                        mov     fnumA, t7    
                        call    #_Sin
                        mov     fnumB, t8
                        call    #_FDiv
_Tan_ret                ret

'------------------------------------------------------------------------------
' _Log     fnumA = log (base e) fnumA
' _Log10   fnumA = log (base 10) fnumA
' _Log2    fnumA = log (base 2) fnumA
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1, t2, t3, t5
'------------------------------------------------------------------------------

_Log                    call    #_Log2                  ' log base e
                        call    #_FDivI
                        long    1.442695041
_Log_ret                ret

_Log10                  call    #_Log2                  ' log base 10
                        call    #_FDivI
                        long    3.321928095
_Log10_ret              ret

_Log2                   call    #_Unpack                ' unpack variable 
          if_z_or_c     jmp     #:exitNaN               ' if NaN or <= 0, return NaN   
                        test    flagA, #SignFlag wz              
          if_nz         jmp     #:exitNaN
                      
                        mov     t5, expA                ' save exponent                                                
                        mov     t1, manA                ' get first 11 bits of fraction
                        shr     t1, #17                 ' get table offset
                        and     t1, TableMask
                        add     t1, LogTable            ' get table address
                        call    #float18Bits            ' remainder = lower 18 bits 
                        mov     t2, fnumA
                        call    #loadTable              ' get fraction from log table
                        mov     fnumB, fnumA
                        mov     fnumA, t5               ' convert exponent to float         
                        call    #_FFloat
                        call    #_FAdd                  ' result = exponent + fraction                               
                        jmp     #_Log2_ret

:exitNaN                mov     fnumA, NaN              ' return NaN

_Log2_ret               ret

'------------------------------------------------------------------------------
' _Exp     fnumA = e ** fnumA
' _Exp10   fnumA = 10 ** fnumA
' _Exp2    fnumA = 2 ** fnumA
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
' changes: t1, t2, t3, t4, t5
'------------------------------------------------------------------------------

_Exp                    call    #_FMulI                 ' e ** fnum
                        long    1.442695041
                        jmp     #_Exp2

_Exp10                  call    #_FMulI                 ' 10 ** fnum
                        long    3.321928095

_Exp2                   call    #_Unpack                ' unpack variable                    
          if_c          jmp     #_Exp2_ret              ' check for NaN
          if_z          mov     fnumA, One              ' if 0, return 1.0
          if_z          jmp     #_Exp2_ret

                        mov     t5, fnumA               ' save sign value
                        call    #_FTrunc                ' get positive integer
                        abs     t4, fnumA
                        mov     fnumA, t5
                        call    #_Frac                  ' get fraction
                        call    #_Unpack
                        neg     expA, expA              ' get first 11 bits of fraction
                        shr     manA, expA
                        mov     t1, manA                ' 
                        shr     t1, #17                 ' get table offset
                        and     t1, TableMask
                        add     t1, AlogTable           ' get table address
                        call    #float18Bits            ' remainder = lower 18 bits 
                        mov     t2, fnumA
                        call    #loadTable              ' get fraction from log table                  
                        call    #_FAddI                 ' add 1.0
                        long    1.0
                        call    #_Unpack                ' align fraction
                        add     expA, t4                ' add integer to exponent  
                        call    #_Pack

                        test    t5, Bit31 wz            ' check if negative
          if_z          jmp     #_Exp2_ret
                        mov     fnumB, fnumA            ' yes, then invert
                        mov     fnumA, One
                        call    #_FDiv
_Exp_ret             
_Exp10_ret           
_Exp2_ret               ret

'------------------------------------------------------------------------------
' _Pow     fnumA = fnumA raised to power fnumB
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB
'          t1, t2, t3, t5, t6, t7
'------------------------------------------------------------------------------

_Pow                    test    fnumB, NaN wz           ' check exponent
          if_z          mov     fnumA, One              ' if exponent=0, set base to 1.0
          
                        mov     t7, fnumA wc            ' save sign of result
          if_nc         jmp     #:pow3                  ' check sign of base

                        mov     fnumA, fnumB            ' check exponent
                        call    #_Unpack
                        mov     fnumA, t7               ' restore base
          if_z          jmp     #:pow2                  ' check for exponent = 0
          
                        test    expA, Bit31 wz          ' if exponent < 0, return NaN
          if_nz         jmp     #:pow1

                        max     expA, #23               ' check if exponent = integer
                        shl     manA, expA    
                        and     manA, Mask29 wz, nr                         
          if_z          jmp     #:pow2                  ' yes, then check if odd
          
:pow1                   mov     fnumA, NaN              ' return NaN
                        jmp     #_Pow_ret

:pow2                   test    manA, Bit29 wz          ' if odd, then negate result
          if_z          andn    t7, Bit31

:pow3                   test    fnumB, Bit31 wc         ' check sign of exponent
                        andn    fnumA, Bit31 wz         ' get |fnumA|
          if_z_and_c    jmp     #:pow1                  ' if 0^-n, return NaN
          if_z          jmp     #_Pow_ret               ' if 0^+n, return Zero

                        mov     t6, fnumB               ' save power
                        call    #_Log2                  ' get log of base
                        mov     fnumB, t6               ' multiply by power
                        call    #_FMul
                        call    #_Exp2                  ' get result      

                        test    t7, Bit31 wz            ' check for negative
          if_nz         xor     fnumA, Bit31
_Pow_ret                ret

'------------------------------------------------------------------------------
' _Frac fnumA = fractional part of fnumA
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------

_Frac                   call    #_Unpack                ' get fraction
                        test    expA, Bit31 wz          ' check for exp < 0 or NaN
          if_c_or_nz    jmp     #:exit
                        max     expA, #23               ' remove the integer
                        shl     manA, expA    
                        and     manA, Mask29
                        mov     expA, #0                ' return fraction

:exit                   call    #_Pack
                        andn    fnumA, Bit31
_Frac_ret               ret

'------------------------------------------------------------------------------
' input:   t1           table address (long)
'          t2           remainder (float) 
' output:  fnumA        interpolated table value (float)
' changes: fnumA, flagA, expA, manA, fnumB, t1, t2, t3
'------------------------------------------------------------------------------

loadTable               rdword  t3, t1                  ' t3 = first table value
                        cmp     t2, #0 wz               ' if remainder = 0, skip interpolation
          if_z          mov     t1, #0
          if_z          jmp     #:load2

                        add     t1, #2                  ' load second table value
                        test    t1, TableMask wz        ' check for end of table
          if_z          mov     t1, Bit16               ' t1 = second table value
          if_nz         rdword  t1, t1
                        sub     t1, t3                  ' t1 = t1 - t3

:load2                  mov     manA, t3                ' convert t3 to float
                        call    #float16Bits
                        mov     t3, fnumA           
                        mov     manA, t1                ' convert t1 to float
                        call    #float16Bits
                        mov     fnumB, t2               ' t1 = t1 * remainder
                        call    #_FMul
                        mov     fnumB, t3               ' result = t1 + t3
                        call    #_FAdd
loadTable_ret           ret

float18Bits             shl     manA, #14               ' float lower 18 bits
                        jmp     #floatBits
float16Bits             shl     manA, #16               ' float lower 16 bits
floatBits               shr     manA, #3                ' align to bit 29
                        mov     flagA, #0               ' convert table value to float 
                        mov     expA, #0
                        call    #_Pack                  ' pack and exit
float18Bits_ret
float16Bits_ret
floatBits_ret           ret

'------------------------------------------------------------------------------
' input:   fnumA        32-bit floating point value
'          fnumB        32-bit floating point value 
' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
'          flagB        fnumB flag bits (Nan, Infinity, Zero, Sign)
'          expB         fnumB exponent (no bias)
'          manB         fnumB mantissa (aligned to bit 29)
'          C flag       set if fnumA or fnumB is NaN
'          Z flag       set if fnumB is zero
' changes: fnumA, flagA, expA, manA, fnumB, flagB, expB, manB, t1
'------------------------------------------------------------------------------

_Unpack2                mov     t1, fnumA               ' save A
                        mov     fnumA, fnumB            ' unpack B to A
                        call    #_Unpack
          if_c          jmp     #_Unpack2_ret           ' check for NaN

                        mov     fnumB, fnumA            ' save B variables
                        mov     flagB, flagA
                        mov     expB, expA
                        mov     manB, manA

                        mov     fnumA, t1               ' unpack A
                        call    #_Unpack
                        cmp     manB, #0 wz             ' set Z flag                      
_Unpack2_ret            ret

'------------------------------------------------------------------------------
' input:   fnumA        32-bit floating point value 
' output:  flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
'          C flag       set if fnumA is NaN
'          Z flag       set if fnumA is zero
' changes: fnumA, flagA, expA, manA
'------------------------------------------------------------------------------

_Unpack                 mov     flagA, fnumA            ' get sign
                        shr     flagA, #31
                        mov     manA, fnumA             ' get mantissa
                        and     manA, Mask23
                        mov     expA, fnumA             ' get exponent
                        shl     expA, #1
                        shr     expA, #24 wz
          if_z          jmp     #:zeroSubnormal         ' check for zero or subnormal
                        cmp     expA, #255 wz           ' check if finite
          if_nz         jmp     #:finite
                        mov     fnumA, NaN              ' no, then return NaN
                        mov     flagA, #NaNFlag
                        jmp     #:exit2        

:zeroSubnormal          or      manA, expA wz,nr        ' check for zero
          if_nz         jmp     #:subnorm
                        or      flagA, #ZeroFlag        ' yes, then set zero flag
                        neg     expA, #150              ' set exponent and exit
                        jmp     #:exit2
                                 
:subnorm                shl     manA, #7                ' fix justification for subnormals  
:subnorm2               test    manA, Bit29 wz
          if_nz         jmp     #:exit1
                        shl     manA, #1
                        sub     expA, #1
                        jmp     #:subnorm2

:finite                 shl     manA, #6                ' justify mantissa to bit 29
                        or      manA, Bit29             ' add leading one bit
                        
:exit1                  sub     expA, #127              ' remove bias from exponent
:exit2                  test    flagA, #NaNFlag wc      ' set C flag
                        cmp     manA, #0 wz             ' set Z flag
_Unpack_ret             ret       

'------------------------------------------------------------------------------
' input:   flagA        fnumA flag bits (Nan, Infinity, Zero, Sign)
'          expA         fnumA exponent (no bias)
'          manA         fnumA mantissa (aligned to bit 29)
' output:  fnumA        32-bit floating point value
' changes: fnumA, flagA, expA, manA 
'------------------------------------------------------------------------------

_Pack                   cmp     manA, #0 wz             ' check for zero                                        
          if_z          mov     expA, #0
          if_z          jmp     #:exit1

:normalize              shl     manA, #1 wc             ' normalize the mantissa 
          if_nc         sub     expA, #1                ' adjust exponent
          if_nc         jmp     #:normalize
                      
                        add     expA, #2                ' adjust exponent
                        add     manA, #$100 wc          ' round up by 1/2 lsb
          if_c          add     expA, #1

                        add     expA, #127              ' add bias to exponent
                        mins    expA, Minus23
                        maxs    expA, #255
 
                        cmps    expA, #1 wc             ' check for subnormals
          if_nc         jmp     #:exit1

:subnormal              or      manA, #1                ' adjust mantissa
                        ror     manA, #1

                        neg     expA, expA
                        shr     manA, expA
                        mov     expA, #0                ' biased exponent = 0

:exit1                  mov     fnumA, manA             ' bits 22:0 mantissa
                        shr     fnumA, #9
                        movi    fnumA, expA             ' bits 23:30 exponent
                        shl     flagA, #31
                        or      fnumA, flagA            ' bit 31 sign            
_Pack_ret               ret

'-------------------- constant values -----------------------------------------

Zero                    long    0                       ' constants
One                     long    $3F80_0000
NaN                     long    $7FFF_FFFF
Minus23                 long    -23
Mask23                  long    $007F_FFFF
Mask29                  long    $1FFF_FFFF
Bit16                   long    $0001_0000
Bit29                   long    $2000_0000
Bit30                   long    $4000_0000
Bit31                   long    $8000_0000
LogTable                long    $C000
ALogTable               long    $D000
TableMask               long    $0FFE
SineTable               long    $E000 >> 1
Sin_90                  long    $0800
Sin_180                 long    $1000

'-------------------- local variables -----------------------------------------

t1                      res     1                       ' temporary values
t2                      res     1
t3                      res     1
t4                      res     1
t5                      res     1
t6                      res     1
t7                      res     1
t8                      res     1

status                  res     1                       ' last compare status

fnumA                   res     1                       ' floating point A value
flagA                   res     1
expA                    res     1
manA                    res     1

fnumB                   res     1                       ' floating point B value
flagB                   res     1
expB                    res     1
manB                    res     1

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
