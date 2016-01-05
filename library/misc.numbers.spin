{{
*************************************
* Numbers v1.1                      *
* Author: Jeff Martin               *
* Copyright (c) 2005 Parallax, Inc. *
* See end of file for terms of use. *
*************************************

{-----------------REVISION HISTORY-----------------
 v1.1 - 5/5/2009 fixed formatting bug caused by specifying field width smaller than location of first grouping character.}

}}

VAR
  long  BCX0, BCX1, BCX2, BCX3  'BCX Workspace
  byte  Symbols[7]              'Special symbols (7 characters)
  byte  StrBuf[49]              'Internal String Buffer

PUB Init 
''Initialize to default settings.  Init MUST be called before first object use.
''  ┌──────────────────────────────────────────────────┐
''  │             DEFAULT SPECIAL SYMBOLS              │
''  ├─────┬──────┬─────────────────────────────────────┤
''  │ ID  │ Char │ Usage                               │
''  ├─────┼──────┼─────────────────────────────────────┤
''  │  1  │  ,   │ Comma (digit group separator)       │
''  │  2  │  _   │ Underscore (digit group separator)  │
''  │  3  │  $   │ Dollar Sign (Hexadecimal indicator) │
''  │  4  │  %   │ Percent Sign (Binary indicator)     │
''  │ 5-7 │      │ Unused (User definable via Config)  │
''  └─────┴──────┴─────────────────────────────────────┘
  Config(@DefaultSymbols)

  
PUB Config(SymAddr)
{{Configure for custom symbols.
  PARAMETERS: SymAddr = Address of a string of characters (7 or less) to be used as Special Symbols (indexed from 1 to 7).  New symbols can be added or
              existing symbols can be modified based on regional customs.  Note:  The first four symbols must always be the logical: 1) digit group separator
              (default is ','), 2) general separator (default is '_'), 3) hexadecimal base indicator (default is '$'), and 4) binary base indicator
              (default is '%').}}  
  bytemove(@Symbols, SymAddr, 7)        


PUB ToStr(Num, Format): StrAddr
{{Convert long Num to z-string using Format; returns string address.
  PARAMETERS: Num     = 32-bit signed value to translate to ASCII string.
              Format  = Indicates output format: base, width, grouping, etc. See "FORMAT SYNTAX" for more information.
  RETURNS:    Actual length of output string, not including null terminator.}}
  BCXToText(Format >> 19 & 7, Format >> 13 & $3F, Format >> 12 & 1, Format >> 11 & 1, Format >> 5 & $3F, BinToBCX(Num, Format & $1F #> 2 <# 16))
  StrAddr := @StrBuf
  

PUB FromStr(StrAddr, Format): Num | Idx, N, Val, Char, Base, GChar, IChar, Field
''Convert z-string (at StrAddr) to long Num using Format.
''PARAMETERS: StrAddr = Address of string buffer containing the numeric string to convert.
''            Format  = Indicates input format: base, width, etc. See "FORMAT SYNTAX" for more information.  Note: three Format elements are ignored by
''                      FromStr(): Zero/Space Padding, Hide/Show Plus Sign, and Digit Group Size.  All other elements are actively used during translation.
''RETURNS:    Long containing 32-bit signed result.
  Base := Format & $1F #> 2 <# 16                                                                       'Get base
  if GChar := Format >> 13 & 7                                                                          'Get grouping character
    GChar := Symbols[--GChar #> 0]
  if IChar := Format >> 19 & 7                                                                          'Get indicator character
    IChar := Symbols[--IChar #> 0]
  Field := Format >> 5 & $3F - 1                                                                        'Get field size, if any (subtract out sign char)
  longfill(@Idx, 0, 3)                                                                                  'Clear Idx, N and Val
  repeat while Char := byte[StrAddr][Idx]                                                               'While not null
    if (not IChar or (IChar and Val)) and InBaseRange(Char, Base) > 0                                   'Found first valid digit? (with prefix indicator if required)?
      quit                                                                                              '  exit to process digits
    else                                                                                                'else
      if not Val := IChar and (Char == IChar)                                                           '  look for indicator character (if required)
        N := Char == "-"                                                                                'Update N flag if not indicator
    Idx++
  Field += Val                                                                                          'Subract indicator character from remaining field size
  repeat while (Field--) and (Char := byte[StrAddr][Idx++]) and ((Val := InBaseRange(Char, Base)) > 0 or (GChar and (Char == GChar)))           
    if Val                                                                                              'While not null and valid digit or grouping char
      Num := Num * Base + --Val                                                                         'Accumulate if valid digit
  if N
    -Num                                                                                                'Negate if necessary


PRI BinToBCX(Num, Base): Digits | N
'Convert signed binary Num to signed BCX value (Binary Coded X ;where X (2..16) is determined by Base)
'Returns: Number of significant Digits (not counting zero-left-padding).
  longfill(@BCX0, 0, 4)                                                                                 'Clear BCX Workspace
  N := (Num < 0) & $10000000                                                                            'Remember if Num negative
  repeat                                                                                                'Calc all BCX digits
    byte[@BCX0][Digits++ >> 1] += ||(Num // Base) << (4 * Digits&1)
  while Num /= Base
  BCX3 |= N                                                                                             'If negative, set flag (highest digit of BCX Workspace)

  
PRI BCXToText(IChar, Group, ShowPlus, SPad, Field, Digits): Size | Idx, GCnt, SChar, GChar, X
'Convert BCX Buffer contents to z-string at StrBuf.
'IChar..Field each correspond to elements of Format.  See "FORMAT SYNTAX" for more information.
'If Field = 0, Digits+1+Group is the effective field (always limited to max of 49).
'Digits  : Number of significant digits (not counting zero-left-padding).
'RETURNS:    Actual Size (length) of output string, not including null terminator.
  X := 1-(IChar > 0)                                                                                    'Xtra char count (1 or 2, for sign and optional base indicator)
  IChar := Symbols[--IChar]                                                                             'Get base indicator character
  SChar := "+" + 2*(BCX3 >> 28) + 11*(not (ShowPlus | (BCX3 >> 28)) or ((Digits == 1) and (BCX0 == 0))) 'Determine sign character ('+', ' ' or '-')
  GChar := Symbols[Group & 7 - 1 #> 0]                                                                  'Get group character
  if Field > 0 and SPad^1 and Digits < 32                                                               'Need to add extra zero-padding?
    BCX3 &= $0FFFFFFF                                                                                   '  then clear negative flag and set to 32 digits
    Digits := 32
  Group := -((Group >>= 3)-(Group > 0))*(Group+1 < Digits)                                              'Get group size (0 if not enough Digits)
  Size := (Field - (Field==0)*(Digits+X+((Digits-1)/Group))) <# 49                                      'Field = 0?  Set Size to Digits+X+Group (max 49).
  if Group                                                                                              'Insert group chars
    bytefill(@StrBuf+(Size-Digits-(Digits-1)/Group #> 2), GChar, Digits+(Digits-1)/Group <# Size)
  Idx~~                                                                                                 'Insert digits
  repeat while (++Idx < Digits) and (Idx + (GCnt := Idx/Group) < Size-X)
    byte[@StrBuf][Size-Idx-1-GCnt] := lookupz(byte[@BCX0][Idx>>1] >> (4 * Idx&1) // 16: "0".."9","A".."F")
  bytefill(@StrBuf, " ", Size-Idx-(Idx-1)/Group #> 0)                                                   'Left pad with spaces, if necessary
  byte[@StrBuf][Size-X-Idx-(Idx-1)/Group #> 0] := SChar                                                 'Insert sign
  if X == 2
    byte[@StrBuf][Size-1-Idx-(Idx-1)/Group #> 1] := IChar                                               'Insert base indicator, if necessary
  byte[@StrBuf][Size] := 0                                                                              'Zero-terminate string


PRI InBaseRange(Char, Base): Value
'Compare Char against valid characters for Base (1..16) (adjusting for lower-case automatically).
'Returns 0 if Char outside valid Base chars or, if valid, returns corresponding Value+1.
   Value := ( Value -= (Char - $2F) * (Char => "0" and Char =< "9") + ((Char &= $DF) - $36) * (Char => "A" and Char =< "F") ) * -(Value < ++Base)


DAT
  DefaultSymbols        byte    ",_$%xxx"                                                               'Special, default, symbols ("x" means unused)


''
''
''**************************
''* FUNCTIONAL DESCRIPTION *
''**************************
''
''The Numbers object converts values in variables (longs) to strings and vice-versa in any base from 2 to 16.
''
''Standard/Default Features:
''   * supports full 32-bit signed values
''   * converts using any base from 2 to 16 (binary to hexadecimal)
''   * defaults to variable widths (ouputs entire number, regardless of size)
''   * uses ' ' or '-' for sign character
''
''Optional Features
''   * allows fixed widths (1 to 49 characters); left padded with either zeros (left justified) or spaces (right justified)
''   * can show plus sign for values > 0
''   * allows digit grouping (each 2 to 8 characters) with customizable separators; ex: 1000000 becomes 1,000,000 and 7AB14B9C becomes 7AB1_4B9C
''   * allows base indicator character (inserted right after sign) with customizable characters; ex: 7AB1 becomes $7AB1 and -1011 becomes -%1011 
''   * all special symbols can be customized
''
''
''**************************
''*     FORMAT SYNTAX      *
''**************************
''
''The Format parameter of ToStr() and FromStr() is a 22-bit value indicating the desired output or input format.  Custom values can be used for the Format
''parameter, however, a series of pre-defined constants for common formats as well as each of the elemental building blocks have already been defined by this
''object.  These pre-defined constants are listed below, followed by a detailed explanation of the syntax of the Format parameter.
''
''┌────────────────────────────────────────────────────────────────────────────────────────┐          ┌───────────────────────────────────────┐
''│                                 COMMON FORMAT CONSTANTS                                │          │            Working Examples           │
''├─────────────────────┬───────────┬────────────┬─────────┬─────────────┬─────────────────┤          ├────────────┬────────┬─────────────────┤
''│       CONSTANT      │ INDICATED │ DELIMITING │ PADDING │    BASE     │      WIDTH      │          │ Long Value │ Format │ String Result   │
''│                     │   BASE    │            │         │             │ (incl. symbols) │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ DEC    │ -1234           │
''│ BIN                 │           │            │         │   Binary    │     Variable    │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │    1234    │ DEC    │  1234           │
''│ IBIN                │     %     │            │         │   Binary    │     Variable    │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │    1234    │ HEX    │  4D2            │
''│ DBIN                │           │ Underscore │         │   Binary    │     Variable    │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ IHEX   │ -$4D2           │
''│ IDBIN               │     %     │ Underscore │         │   Binary    │     Variable    │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │    1234    │ BIN    │  10011010010    │
''│ BIN2..BIN33         │           │            │   Zero  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ IBIN   │ -%10011010010   │
''│ IBIN3..IBIN34       │     %     │            │   Zero  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │    1234    │ DDEC   │  1,234          │
''│ DBIN7..DBIN40       │           │ Underscore │   Zero  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ DDEC8  │ -001,234        │
''│ IDBIN8..IDBIN41     │     %     │ Underscore │   Zero  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ DSDEC8 │   -1,234        │
''│ SBIN3..SBIN33       │           │            │  Space  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │    1234    │ DBIN   │  100_1101_0010  │
''│ ISBIN4..ISBIN34     │     %     │            │  Space  │   Binary    │      Fixed      │          ├────────────┼────────┼─────────────────┤
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          │   -1234    │ DBIN15 │ -0100_1101_0010 │
''│ DSBIN7..DSBIN40     │           │ Underscore │  Space  │   Binary    │      Fixed      │          └────────────┴────────┴─────────────────┘
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤          *Note: In these examples, all positive
''│ IDSBIN8..IDSBIN41   │     %     │ Underscore │  Space  │   Binary    │      Fixed      │                 values' output strings have a space
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤                 for the sign character.  Don't forget
''│ DEC                 │           │            │         │   Decimal   │     Variable    │                 that fact when sizing string buffer
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤                 or otherwise using result.
''│ DDEC                │           │   Comma    │         │   Decimal   │     Variable    │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ DEC2..DEC11         │           │            │   Zero  │   Decimal   │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ SDEC3..SDEC11       │           │            │  Space  │   Decimal   │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ DSDEC6..DSDEC14     │           │   Comma    │  Space  │   Decimal   │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ HEX                 │           │            │         │ Hexadecimal │     Variable    │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ IHEX                │     $     │            │         │ Hexadecimal │     Variable    │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ DHEX                │           │ Underscore │         │ Hexadecimal │     Variable    │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ IDHEX               │     $     │ Underscore │         │ Hexadecimal │     Variable    │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ HEX2..HEX9          │           │            │   Zero  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ IHEX3..IHEX10       │     $     │            │   Zero  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ DHEX7..DHEX10       │           │ Underscore │   Zero  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ IDHEX8..IDHEX11     │     $     │ Underscore │   Zero  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ SHEX3..SHEX9        │           │            │  Space  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ ISHEX4..ISHEX10     │     $     │            │  Space  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ DSHEX7..DSHEX10     │           │ Underscore │  Space  │ Hexadecimal │      Fixed      │
''├─────────────────────┼───────────┼────────────┼─────────┼─────────────┼─────────────────┤
''│ IDSHEX8..IDSHEX11   │     $     │ Underscore │  Space  │ Hexadecimal │      Fixed      │
''└─────────────────────┴───────────┴────────────┴─────────┴─────────────┴─────────────────┘
''
''
''If the desired format was not already defined by the Common Format Constants, above, you may use the following constants as building blocks to create
''the customer format you need.
''
''┌─────────────────────────────────────────────────────┐
''│          FORMAT CONSTANT "BUILDING BLOCKS"          │
''│ (use these if no equivelant common format exisits)  │
''├────────────────────┬────────────────────────────────┤
''│     CONSTANT       │           DESCRIPTION          │
''├────────────────────┼────────────────────────────────┤
''│ BIN, DEC or HEX    │ Binary, Decimal or Hexadecimal │
''├────────────────────┼────────────────────────────────┤
''│ CHAR1..CHAR48      │ Field Width (includes symbols) │
''├────────────────────┼────────────────────────────────┤
''│ <nothing> / SPCPAD │        Zero / Space Pad        │
''├────────────────────┼────────────────────────────────┤
''│ <nothing> / PLUS   │        Hide / Show Plus        │
''├────────────────────┼────────────────────────────────┤
''│ COMMA, USCORE      │        Group Character         │
''├────────────────────┼────────────────────────────────┤
''│ GROUP2..GROUP8     │           Group Size           │
''├────────────────────┼────────────────────────────────┤
''│ BINCHAR or HEXCHAR │      Indicator Character       │
''└────────────────────┴────────────────────────────────┘
''
''
''The detailed syntax of the Format parameter is described below.
''
''There are 7 elements of the Format parameter:
''  1) Base,
''  2) Field Width,
''  3) Zero/Space Padding,
''  4) Hide/Show Plus Sign,
''  5) Grouping Character ID,
''  6) Digit Group Size,
''  7) Indicator Character
''Only the Base element is required, all others are optional.
''
''The 22-bit syntax is as follows:
''
''  III ZZZ GGG P S FFFFFF BBBBB
''
''I : Indicator Character ID (0-7).  0 = no indicator character, 1 = Comma, 2 = Underscore, 3 = Dollar Sign, 4 = Percent Sign, etc., as defined by default Init; may be customized via call to Config().
''Z : Digit Group Size (0-7).  0 = no digit group characters, 1 = every 2 chars, 2 = every 3 chars, etc.
''G : Grouping Character ID (0-7).  0 or 1 = Comma, 2 = Underscore, etc., as defined by default Init; may be customized via call to Config().
''P : Hide/Show Plus Sign (0-1).  For Num values > 0, sign char is: ' ' (if P = 0), or '+' (if P = 1).
''S : Zero/Space Pad (0-1).  [Ignored unless Field Width > 0].  0 = left pad with zeros (left justified), 1 = left pad with spaces (right justified).
''F : Field Width (0-48).  String field width, including sign character and any special characters (not including zero terminator).
''B : Base (2-16).  Base to convert number to; 2 = binary, 10 = decimal, 16 = hexadecimal, etc.  This element is required.
''
''Examples:
''
''Conversion to variable-width decimal value:
''  Use Format of: %000_000_000_0_0_000000_01010, or simply %1010 (decimal 10).
''
''Conversion to 5-character wide, fixed-width hexadecimal value (left padded with zeros):
''  Use Format of: %000_000_000_0_0_000101_10000
''
''Conversion to 5-character wide, fixed-width hexadecimal value (left padded with spaces):
''  Use Format of: %000_000_000_0_1_000101_10000
''
''Conversion to variable-width decimal value comma-separated at thousands:
''  Use Format of: %000_010_001_0_0_000000_01010
''
''Conversion to Indicated, 6-character wide, fixed-width hexadecimal value (left padded with spaces):
''  Use Format of: %011_000_000_0_1_000110_10000
''
''For convenience and code readability, a number of pre-defined symbolic constants are included that can be added together for any format
''combination imaginable.  See "FORMAT CONSTANT 'BUILDING BLOCKS'", above.  For example, using these constants, the above example format values become
''the following, respectively:
''  DEC
''  HEX+CHAR5
''  HEX+CHAR5+SPCPAD
''  DEC+GROUP3+COMMA
''  HEX+CHAR6+HEXCHAR+SPCPAD
''
''
''┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
''│                                         32-Bit Statistics for Bases 2 to 16                                        │
''├──────┬────────────┬────────────────────────────────────────────────────────────────────────────┬───────────────────┤
''│ Base │ Max Digits │                                Range (Signed)                              │   Range Is Shown  │
''│      │ w/o symbols│               Minimum                │               Maximum               │     Grouped By    │ 
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   2  │     32     │ -10000000_00000000_00000000_00000000 │ +1111111_11111111_11111111_11111111 │    Bytes (exact)  │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   3  │     20     │             -12112_12221_21102_02102 │            +12112_12221_21102_02101 │       Bytes       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   4  │     16     │                 -2000_0000_0000_0000 │                +1333_3333_3333_3333 │    Bytes (exact)  │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   5  │     14     │                    -13_344223_434043 │                   +13_344223_434042 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   6  │     12     │                       -553032_005532 │                      +553032_005531 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   7  │     12     │                      -10_41342_11162 │                     +10_41342_11161 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   8  │     11     │                       -2_00000_00000 │                      +1_77777_77777 │  Words (15 bits)  │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│   9  │     10     │                         -54787_73672 │                        +54787_73671 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  10  │     10     │                       -2,147,483,648 │                      +2,147,483,647 │ Thousands (exact) │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  11  │      9     │                         -A_0222_0282 │                        +A_0222_0281 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  12  │      9     │                         -4_BB23_08A8 │                        +4_BB23_08A7 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  13  │      9     │                         -2_82BA_4AAB │                        +2_82BA_4AAA │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  14  │      9     │                         -1_652C_A932 │                        +1_652C_A931 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  15  │      8     │                           -C87D_66B8 │                          +C87D_66B7 │       Words       │
''├──────┼────────────┼──────────────────────────────────────┼─────────────────────────────────────┼───────────────────┤
''│  16  │      8     │                           -8000_0000 │                          +7FFF_FFFF │   Words (exact)   │
''└──────┴────────────┴──────────────────────────────────────┴─────────────────────────────────────┴───────────────────┘



CON
'┌──────────────────────────────────────────┐
'│         Format "Building Blocks"         │
'└──────────────────────────────────────────┘
'             III ZZZ GGG P S FFFFFF BBBBB
  CHAR2    =  %000_000_000_0_0_000010_00000     'Fixed Width (includes sign and special symbols)
  CHAR3    =  %000_000_000_0_0_000011_00000
  CHAR4    =  %000_000_000_0_0_000100_00000
  CHAR5    =  %000_000_000_0_0_000101_00000
  CHAR6    =  %000_000_000_0_0_000110_00000
  CHAR7    =  %000_000_000_0_0_000111_00000
  CHAR8    =  %000_000_000_0_0_001000_00000
  CHAR9    =  %000_000_000_0_0_001001_00000
  CHAR10   =  %000_000_000_0_0_001010_00000
  CHAR11   =  %000_000_000_0_0_001011_00000
  CHAR12   =  %000_000_000_0_0_001100_00000
  CHAR13   =  %000_000_000_0_0_001101_00000
  CHAR14   =  %000_000_000_0_0_001110_00000
  CHAR15   =  %000_000_000_0_0_001111_00000
  CHAR16   =  %000_000_000_0_0_010000_00000
  CHAR17   =  %000_000_000_0_0_010001_00000
  CHAR18   =  %000_000_000_0_0_010010_00000
  CHAR19   =  %000_000_000_0_0_010011_00000
  CHAR20   =  %000_000_000_0_0_010100_00000
  CHAR21   =  %000_000_000_0_0_010101_00000
  CHAR22   =  %000_000_000_0_0_010110_00000
  CHAR23   =  %000_000_000_0_0_010111_00000
  CHAR24   =  %000_000_000_0_0_011000_00000
  CHAR25   =  %000_000_000_0_0_011001_00000
  CHAR26   =  %000_000_000_0_0_011010_00000
  CHAR27   =  %000_000_000_0_0_011011_00000
  CHAR28   =  %000_000_000_0_0_011100_00000
  CHAR29   =  %000_000_000_0_0_011101_00000
  CHAR30   =  %000_000_000_0_0_011110_00000
  CHAR31   =  %000_000_000_0_0_011111_00000
  CHAR32   =  %000_000_000_0_0_100000_00000
  CHAR33   =  %000_000_000_0_0_100001_00000
  CHAR34   =  %000_000_000_0_0_100010_00000
  CHAR35   =  %000_000_000_0_0_100011_00000
  CHAR36   =  %000_000_000_0_0_100100_00000
  CHAR37   =  %000_000_000_0_0_100101_00000
  CHAR38   =  %000_000_000_0_0_100110_00000
  CHAR39   =  %000_000_000_0_0_100111_00000
  CHAR40   =  %000_000_000_0_0_101000_00000
  CHAR41   =  %000_000_000_0_0_101001_00000
  CHAR42   =  %000_000_000_0_0_101010_00000
  CHAR43   =  %000_000_000_0_0_101011_00000
  CHAR44   =  %000_000_000_0_0_101100_00000
  CHAR45   =  %000_000_000_0_0_101101_00000
  CHAR46   =  %000_000_000_0_0_101110_00000
  CHAR47   =  %000_000_000_0_0_101111_00000 
  CHAR48   =  %000_000_000_0_0_110000_00000
  CHAR49   =  %000_000_000_0_0_110001_00000

  SPCPAD   =  %000_000_000_0_1_000000_00000     'Space padded

  PLUS     =  %000_000_000_1_0_000000_00000     'Show plus sign '+' for num > 0

  COMMA    =  %000_000_001_0_0_000000_00000     'Comma delimiter
  USCORE   =  %000_000_010_0_0_000000_00000     'Underscore delimiter

  HEXCHAR  =  %011_000_000_0_0_000000_00000     'Hexadecimal prefix '$'
  BINCHAR  =  %100_000_000_0_0_000000_00000     'Binary prefix '%'

  GROUP2   =  %000_001_000_0_0_000000_00000     'Group digits
  GROUP3   =  %000_010_000_0_0_000000_00000
  GROUP4   =  %000_011_000_0_0_000000_00000
  GROUP5   =  %000_100_000_0_0_000000_00000
  GROUP6   =  %000_101_000_0_0_000000_00000
  GROUP7   =  %000_110_000_0_0_000000_00000
  GROUP8   =  %000_111_000_0_0_000000_00000


'┌──────────────────────────────────────────┐
'│        Common Decimal Formatters         │
'└──────────────────────────────────────────┘

  DEC      =  %000_000_000_0_0_000000_01010     'Decimal, variable widths

  DDEC     =  DEC+GROUP3+COMMA                  'Decimal, variable widths, delimited with commas

  DEC2     =  DEC+CHAR2                         'Decimal, fixed widths, zero padded
  DEC3     =  DEC+CHAR3
  DEC4     =  DEC+CHAR4
  DEC5     =  DEC+CHAR5
  DEC6     =  DEC+CHAR6
  DEC7     =  DEC+CHAR7
  DEC8     =  DEC+CHAR8
  DEC9     =  DEC+CHAR9
  DEC10    =  DEC+CHAR10
  DEC11    =  DEC+CHAR11

  SDEC3    =  DEC3+SPCPAD                       'Decimal, fixed widths, space padded
  SDEC4    =  DEC4+SPCPAD
  SDEC5    =  DEC5+SPCPAD
  SDEC6    =  DEC6+SPCPAD
  SDEC7    =  DEC7+SPCPAD
  SDEC8    =  DEC8+SPCPAD
  SDEC9    =  DEC9+SPCPAD
  SDEC10   =  DEC10+SPCPAD
  SDEC11   =  DEC11+SPCPAD

  DSDEC6   =  SDEC6+GROUP3+COMMA                'Decimal, fixed widths, space padded, delimited with commas
  DSDEC7   =  SDEC7+GROUP3+COMMA
  DSDEC8   =  SDEC8+GROUP3+COMMA
  DSDEC9   =  SDEC9+GROUP3+COMMA
  DSDEC10  =  SDEC10+GROUP3+COMMA
  DSDEC11  =  SDEC11+GROUP3+COMMA
  DSDEC12  =  DEC+CHAR12+SPCPAD+GROUP3+COMMA
  DSDEC13  =  DEC+CHAR13+SPCPAD+GROUP3+COMMA
  DSDEC14  =  DEC+CHAR14+SPCPAD+GROUP3+COMMA


'┌──────────────────────────────────────────┐
'│      Common Hexadecimal Formatters       │
'└──────────────────────────────────────────┘

  HEX      =  %000_000_000_0_0_000000_10000     'Hexadecimal, variable widths

  DHEX     =  HEX+GROUP4+USCORE                 'Hexadecimal, variable widths, delimited with underscore

  HEX2     =  HEX+CHAR2                         'Hexadecimal, fixed widths, zero padded
  HEX3     =  HEX+CHAR3
  HEX4     =  HEX+CHAR4
  HEX5     =  HEX+CHAR5
  HEX6     =  HEX+CHAR6
  HEX7     =  HEX+CHAR7
  HEX8     =  HEX+CHAR8
  HEX9     =  HEX+CHAR9

  SHEX3    =  HEX3+SPCPAD                       'Hexadecimal, fixed widths, space padded
  SHEX4    =  HEX4+SPCPAD
  SHEX5    =  HEX5+SPCPAD
  SHEX6    =  HEX6+SPCPAD
  SHEX7    =  HEX7+SPCPAD
  SHEX8    =  HEX8+SPCPAD
  SHEX9    =  HEX9+SPCPAD

  DHEX7    =  HEX7+GROUP4+USCORE                'Hexadecimal, fixed widths, zero padded, delimited with underscore
  DHEX8    =  HEX8+GROUP4+USCORE
  DHEX9    =  HEX9+GROUP4+USCORE
  DHEX10   =  HEX+CHAR10+GROUP4+USCORE

  DSHEX7   =  DHEX7+SPCPAD                      'Hexadecimal, fixed widths, space padded, delimited with underscore
  DSHEX8   =  DHEX8+SPCPAD
  DSHEX9   =  DHEX9+SPCPAD
  DSHEX10  =  DHEX10+SPCPAD

  IHEX     =  HEX+HEXCHAR                       'Indicated hexadecimal, variable widths

  IDHEX    =  DHEX+HEXCHAR                      'Indicated hexadecimal, variable widths, delimited with underscore

  IHEX3    =  HEX3+HEXCHAR                      'Indicated hexadecimal, fixed widths, zero padded
  IHEX4    =  HEX4+HEXCHAR
  IHEX5    =  HEX5+HEXCHAR
  IHEX6    =  HEX6+HEXCHAR
  IHEX7    =  HEX7+HEXCHAR
  IHEX8    =  HEX8+HEXCHAR
  IHEX9    =  HEX9+HEXCHAR
  IHEX10   =  HEX+CHAR10+HEXCHAR

  ISHEX4   =  SHEX4+HEXCHAR                     'Indicated hexadecimal, fixed widths, space padded
  ISHEX5   =  SHEX5+HEXCHAR
  ISHEX6   =  SHEX6+HEXCHAR
  ISHEX7   =  SHEX7+HEXCHAR
  ISHEX8   =  SHEX8+HEXCHAR
  ISHEX9   =  SHEX9+HEXCHAR
  ISHEX10  =  HEX+CHAR10+SPCPAD+HEXCHAR

  IDHEX8   =  DHEX8+HEXCHAR                     'Indicated hexadecimal, fixed widths, zero padded, delimited with underscore
  IDHEX9   =  DHEX9+HEXCHAR
  IDHEX10  =  DHEX10+HEXCHAR
  IDHEX11  =  HEX+CHAR11+GROUP4+USCORE+HEXCHAR

  IDSHEX8  =  DSHEX8+HEXCHAR                    'Indicated hexadecimal, fixed widths, space padded, delimited with underscore
  IDSHEX9  =  DSHEX9+HEXCHAR
  IDSHEX10 =  DSHEX10+HEXCHAR
  IDSHEX11 =  HEX+CHAR11+GROUP4+USCORE+HEXCHAR

'┌──────────────────────────────────────────┐
'│        Common Binary Formatters          │
'└──────────────────────────────────────────┘

  BIN      =  %000_000_000_0_0_000000_00010     'Binary, variable widths

  DBIN     =  BIN+GROUP4+USCORE                 'Binary, variable widths, delimited with underscores

  BIN2     =  BIN+CHAR2                         'Binary, fixed widths, zero padded
  BIN3     =  BIN+CHAR3
  BIN4     =  BIN+CHAR4
  BIN5     =  BIN+CHAR5
  BIN6     =  BIN+CHAR6
  BIN7     =  BIN+CHAR7
  BIN8     =  BIN+CHAR8
  BIN9     =  BIN+CHAR9
  BIN10    =  BIN+CHAR10
  BIN11    =  BIN+CHAR11
  BIN12    =  BIN+CHAR12
  BIN13    =  BIN+CHAR13
  BIN14    =  BIN+CHAR14
  BIN15    =  BIN+CHAR15
  BIN16    =  BIN+CHAR16
  BIN17    =  BIN+CHAR17
  BIN18    =  BIN+CHAR18
  BIN19    =  BIN+CHAR19
  BIN20    =  BIN+CHAR20
  BIN21    =  BIN+CHAR21
  BIN22    =  BIN+CHAR22
  BIN23    =  BIN+CHAR23
  BIN24    =  BIN+CHAR24
  BIN25    =  BIN+CHAR25
  BIN26    =  BIN+CHAR26
  BIN27    =  BIN+CHAR27
  BIN28    =  BIN+CHAR28
  BIN29    =  BIN+CHAR29
  BIN30    =  BIN+CHAR30
  BIN31    =  BIN+CHAR31
  BIN32    =  BIN+CHAR32
  BIN33    =  BIN+CHAR33

  SBIN3    =  BIN3+SPCPAD                       'Binary, fixed widths, space padded
  SBIN4    =  BIN4+SPCPAD
  SBIN5    =  BIN5+SPCPAD
  SBIN6    =  BIN6+SPCPAD
  SBIN7    =  BIN7+SPCPAD
  SBIN8    =  BIN8+SPCPAD
  SBIN9    =  BIN9+SPCPAD
  SBIN10   =  BIN10+SPCPAD
  SBIN11   =  BIN11+SPCPAD
  SBIN12   =  BIN12+SPCPAD
  SBIN13   =  BIN13+SPCPAD
  SBIN14   =  BIN14+SPCPAD
  SBIN15   =  BIN15+SPCPAD
  SBIN16   =  BIN16+SPCPAD
  SBIN17   =  BIN17+SPCPAD
  SBIN18   =  BIN18+SPCPAD
  SBIN19   =  BIN19+SPCPAD
  SBIN20   =  BIN20+SPCPAD
  SBIN21   =  BIN21+SPCPAD
  SBIN22   =  BIN22+SPCPAD
  SBIN23   =  BIN23+SPCPAD
  SBIN24   =  BIN24+SPCPAD
  SBIN25   =  BIN25+SPCPAD
  SBIN26   =  BIN26+SPCPAD
  SBIN27   =  BIN27+SPCPAD
  SBIN28   =  BIN28+SPCPAD
  SBIN29   =  BIN29+SPCPAD
  SBIN30   =  BIN30+SPCPAD
  SBIN31   =  BIN31+SPCPAD
  SBIN32   =  BIN32+SPCPAD
  SBIN33   =  BIN33+SPCPAD

  DBIN7    =  BIN7+GROUP4+USCORE                'Binary, fixed widths, zero padded, delimited with underscores
  DBIN8    =  BIN8+GROUP4+USCORE
  DBIN9    =  BIN9+GROUP4+USCORE
  DBIN10   =  BIN10+GROUP4+USCORE
  DBIN11   =  BIN11+GROUP4+USCORE
  DBIN12   =  BIN12+GROUP4+USCORE
  DBIN13   =  BIN13+GROUP4+USCORE
  DBIN14   =  BIN14+GROUP4+USCORE
  DBIN15   =  BIN15+GROUP4+USCORE
  DBIN16   =  BIN16+GROUP4+USCORE
  DBIN17   =  BIN17+GROUP4+USCORE
  DBIN18   =  BIN18+GROUP4+USCORE
  DBIN19   =  BIN19+GROUP4+USCORE
  DBIN20   =  BIN20+GROUP4+USCORE
  DBIN21   =  BIN21+GROUP4+USCORE
  DBIN22   =  BIN22+GROUP4+USCORE
  DBIN23   =  BIN23+GROUP4+USCORE
  DBIN24   =  BIN24+GROUP4+USCORE
  DBIN25   =  BIN25+GROUP4+USCORE
  DBIN26   =  BIN26+GROUP4+USCORE
  DBIN27   =  BIN27+GROUP4+USCORE
  DBIN28   =  BIN28+GROUP4+USCORE
  DBIN29   =  BIN29+GROUP4+USCORE
  DBIN30   =  BIN30+GROUP4+USCORE
  DBIN31   =  BIN31+GROUP4+USCORE
  DBIN32   =  BIN32+GROUP4+USCORE
  DBIN33   =  BIN33+GROUP4+USCORE
  DBIN34   =  BIN+CHAR34+GROUP4+USCORE
  DBIN35   =  BIN+CHAR35+GROUP4+USCORE
  DBIN36   =  BIN+CHAR36+GROUP4+USCORE
  DBIN37   =  BIN+CHAR37+GROUP4+USCORE
  DBIN38   =  BIN+CHAR38+GROUP4+USCORE
  DBIN39   =  BIN+CHAR39+GROUP4+USCORE
  DBIN40   =  BIN+CHAR40+GROUP4+USCORE

  DSBIN7   =  DBIN7+SPCPAD                      'Binary, fixed widths, space padded, delimited with underscores
  DSBIN8   =  DBIN8+SPCPAD
  DSBIN9   =  DBIN9+SPCPAD
  DSBIN10  =  DBIN10+SPCPAD
  DSBIN11  =  DBIN11+SPCPAD
  DSBIN12  =  DBIN12+SPCPAD
  DSBIN13  =  DBIN13+SPCPAD
  DSBIN14  =  DBIN14+SPCPAD
  DSBIN15  =  DBIN15+SPCPAD
  DSBIN16  =  DBIN16+SPCPAD
  DSBIN17  =  DBIN17+SPCPAD
  DSBIN18  =  DBIN18+SPCPAD
  DSBIN19  =  DBIN19+SPCPAD
  DSBIN20  =  DBIN20+SPCPAD
  DSBIN21  =  DBIN21+SPCPAD
  DSBIN22  =  DBIN22+SPCPAD
  DSBIN23  =  DBIN23+SPCPAD
  DSBIN24  =  DBIN24+SPCPAD
  DSBIN25  =  DBIN25+SPCPAD
  DSBIN26  =  DBIN26+SPCPAD
  DSBIN27  =  DBIN27+SPCPAD
  DSBIN28  =  DBIN28+SPCPAD
  DSBIN29  =  DBIN29+SPCPAD
  DSBIN30  =  DBIN30+SPCPAD
  DSBIN31  =  DBIN31+SPCPAD
  DSBIN32  =  DBIN32+SPCPAD
  DSBIN33  =  DBIN33+SPCPAD
  DSBIN34  =  DBIN34+SPCPAD
  DSBIN35  =  DBIN35+SPCPAD
  DSBIN36  =  DBIN36+SPCPAD
  DSBIN37  =  DBIN37+SPCPAD
  DSBIN38  =  DBIN38+SPCPAD
  DSBIN39  =  DBIN39+SPCPAD
  DSBIN40  =  DBIN40+SPCPAD

  IBIN     =  BIN+BINCHAR                       'Indicated binary, variable widths

  IDBIN    =  DBIN+BINCHAR                      'Indicated binary, variable widths, delimited with underscores

  IBIN3    =  BIN3+BINCHAR                      'Indicated binary, fixed widths, zero padded
  IBIN4    =  BIN4+BINCHAR
  IBIN5    =  BIN5+BINCHAR
  IBIN6    =  BIN6+BINCHAR
  IBIN7    =  BIN7+BINCHAR
  IBIN8    =  BIN8+BINCHAR
  IBIN9    =  BIN9+BINCHAR
  IBIN10   =  BIN10+BINCHAR
  IBIN11   =  BIN11+BINCHAR
  IBIN12   =  BIN12+BINCHAR
  IBIN13   =  BIN13+BINCHAR
  IBIN14   =  BIN14+BINCHAR
  IBIN15   =  BIN15+BINCHAR
  IBIN16   =  BIN16+BINCHAR
  IBIN17   =  BIN17+BINCHAR
  IBIN18   =  BIN18+BINCHAR
  IBIN19   =  BIN19+BINCHAR
  IBIN20   =  BIN20+BINCHAR
  IBIN21   =  BIN21+BINCHAR
  IBIN22   =  BIN22+BINCHAR
  IBIN23   =  BIN23+BINCHAR
  IBIN24   =  BIN24+BINCHAR
  IBIN25   =  BIN25+BINCHAR
  IBIN26   =  BIN26+BINCHAR
  IBIN27   =  BIN27+BINCHAR
  IBIN28   =  BIN28+BINCHAR
  IBIN29   =  BIN29+BINCHAR
  IBIN30   =  BIN30+BINCHAR
  IBIN31   =  BIN31+BINCHAR
  IBIN32   =  BIN32+BINCHAR
  IBIN33   =  BIN33+BINCHAR
  IBIN34   =  BIN+CHAR34+BINCHAR

  ISBIN4   =  SBIN4+BINCHAR                     'Indicated binary, fixed widths, space padded
  ISBIN5   =  SBIN5+BINCHAR
  ISBIN6   =  SBIN6+BINCHAR
  ISBIN7   =  SBIN7+BINCHAR
  ISBIN8   =  SBIN8+BINCHAR
  ISBIN9   =  SBIN9+BINCHAR
  ISBIN10  =  SBIN10+BINCHAR
  ISBIN11  =  SBIN11+BINCHAR
  ISBIN12  =  SBIN12+BINCHAR
  ISBIN13  =  SBIN13+BINCHAR
  ISBIN14  =  SBIN14+BINCHAR
  ISBIN15  =  SBIN15+BINCHAR
  ISBIN16  =  SBIN16+BINCHAR
  ISBIN17  =  SBIN17+BINCHAR
  ISBIN18  =  SBIN18+BINCHAR
  ISBIN19  =  SBIN19+BINCHAR
  ISBIN20  =  SBIN20+BINCHAR
  ISBIN21  =  SBIN21+BINCHAR
  ISBIN22  =  SBIN22+BINCHAR
  ISBIN23  =  SBIN23+BINCHAR
  ISBIN24  =  SBIN24+BINCHAR
  ISBIN25  =  SBIN25+BINCHAR
  ISBIN26  =  SBIN26+BINCHAR
  ISBIN27  =  SBIN27+BINCHAR
  ISBIN28  =  SBIN28+BINCHAR
  ISBIN29  =  SBIN29+BINCHAR
  ISBIN30  =  SBIN30+BINCHAR
  ISBIN31  =  SBIN31+BINCHAR
  ISBIN32  =  SBIN32+BINCHAR
  ISBIN33  =  SBIN33+BINCHAR
  ISBIN34   = BIN+CHAR34+SPCPAD+BINCHAR

  IDBIN8   =  DBIN8+BINCHAR                     'Indicated binary, fixed widths, zero padded, delimited with underscores
  IDBIN9   =  DBIN9+BINCHAR
  IDBIN10  =  DBIN10+BINCHAR
  IDBIN11  =  DBIN11+BINCHAR
  IDBIN12  =  DBIN12+BINCHAR
  IDBIN13  =  DBIN13+BINCHAR
  IDBIN14  =  DBIN14+BINCHAR
  IDBIN15  =  DBIN15+BINCHAR
  IDBIN16  =  DBIN16+BINCHAR
  IDBIN17  =  DBIN17+BINCHAR
  IDBIN18  =  DBIN18+BINCHAR
  IDBIN19  =  DBIN19+BINCHAR
  IDBIN20  =  DBIN20+BINCHAR
  IDBIN21  =  DBIN21+BINCHAR
  IDBIN22  =  DBIN22+BINCHAR
  IDBIN23  =  DBIN23+BINCHAR
  IDBIN24  =  DBIN24+BINCHAR
  IDBIN25  =  DBIN25+BINCHAR
  IDBIN26  =  DBIN26+BINCHAR
  IDBIN27  =  DBIN27+BINCHAR
  IDBIN28  =  DBIN28+BINCHAR
  IDBIN29  =  DBIN29+BINCHAR
  IDBIN30  =  DBIN30+BINCHAR
  IDBIN31  =  DBIN31+BINCHAR
  IDBIN32  =  DBIN32+BINCHAR
  IDBIN33  =  DBIN33+BINCHAR
  IDBIN34  =  DBIN34+BINCHAR
  IDBIN35  =  DBIN35+BINCHAR
  IDBIN36  =  DBIN36+BINCHAR
  IDBIN37  =  DBIN37+BINCHAR
  IDBIN38  =  DBIN38+BINCHAR
  IDBIN39  =  DBIN39+BINCHAR
  IDBIN40  =  DBIN40+BINCHAR
  IDBIN41  =  BIN+CHAR41+GROUP4+USCORE+BINCHAR                  

  IDSBIN8  =  DSBIN8+BINCHAR                    'Indicated binary, fixed widths, space padded, delimited with underscores
  IDSBIN9  =  DSBIN9+BINCHAR
  IDSBIN10 =  DSBIN10+BINCHAR
  IDSBIN11 =  DSBIN11+BINCHAR
  IDSBIN12 =  DSBIN12+BINCHAR
  IDSBIN13 =  DSBIN13+BINCHAR
  IDSBIN14 =  DSBIN14+BINCHAR
  IDSBIN15 =  DSBIN15+BINCHAR
  IDSBIN16 =  DSBIN16+BINCHAR
  IDSBIN17 =  DSBIN17+BINCHAR
  IDSBIN18 =  DSBIN18+BINCHAR
  IDSBIN19 =  DSBIN19+BINCHAR
  IDSBIN20 =  DSBIN20+BINCHAR
  IDSBIN21 =  DSBIN21+BINCHAR
  IDSBIN22 =  DSBIN22+BINCHAR
  IDSBIN23 =  DSBIN23+BINCHAR
  IDSBIN24 =  DSBIN24+BINCHAR
  IDSBIN25 =  DSBIN25+BINCHAR
  IDSBIN26 =  DSBIN26+BINCHAR
  IDSBIN27 =  DSBIN27+BINCHAR
  IDSBIN28 =  DSBIN28+BINCHAR
  IDSBIN29 =  DSBIN29+BINCHAR
  IDSBIN30 =  DSBIN30+BINCHAR
  IDSBIN31 =  DSBIN31+BINCHAR
  IDSBIN32 =  DSBIN32+BINCHAR
  IDSBIN33 =  DSBIN33+BINCHAR
  IDSBIN34 =  DSBIN34+BINCHAR
  IDSBIN35 =  DSBIN35+BINCHAR
  IDSBIN36 =  DSBIN36+BINCHAR
  IDSBIN37 =  DSBIN37+BINCHAR
  IDSBIN38 =  DSBIN38+BINCHAR
  IDSBIN39 =  DSBIN39+BINCHAR
  IDSBIN40 =  DSBIN40+BINCHAR
  IDSBIN41 =  BIN+CHAR41+SPCPAD+GROUP4+USCORE+BINCHAR

