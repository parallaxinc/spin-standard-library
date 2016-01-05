{{
    This object contains functions to test individual character types.
}}
OBJ

    cc : "string.char"

PUB IsAlphaNumeric(stringptr)
{{
    Check if string is alphanumeric.
}}

    repeat strsize(stringptr)
        if not cc.IsAlphaNumeric (byte[stringptr++])
            return false

    return true

PUB IsAlpha(stringptr)
{{
    Check if character is alphabetic.
}}

    repeat strsize(stringptr)
        if not cc.IsAlpha (byte[stringptr++])
            return false

    return true

PUB IsDigit(stringptr)
{{
    Check if character is decimal.
}}

    repeat strsize(stringptr)
        if not cc.IsDigit (byte[stringptr++])
            return false

    return true

PUB IsLower(stringptr)
{{
    Check if character is lowercase.
}}

    repeat strsize(stringptr)
        if not cc.IsLower (byte[stringptr++])
            return false

    return true

PUB IsUpper(stringptr)
{{
    Check if character is uppercase.
}}

    repeat strsize(stringptr)
        if not cc.IsUpper (byte[stringptr++])
            return false

    return true

PUB IsSpace(stringptr)
{{
    Check if character is whitespace.
}}

    repeat strsize(stringptr)
        if not cc.IsSpace (byte[stringptr++])
            return false

    return true

