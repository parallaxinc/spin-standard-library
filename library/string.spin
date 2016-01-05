' Derived from ASCII0_STREngine.spin
' Original author: Kwabena W. Agyeman, J Moxham
PUB Append(source, destination)
{{
    Concatenates a string onto the end of another. This method can corrupt memory.
    
    Parameters:

    -   source - The string to be appended.
    -   destination - The string that the source string is appended to.
    
    Returns a pointer to the new string.
}}

    bytemove((destination + strsize(destination)), source, (strsize(source) + 1))
    return destination

PUB Compare(str1, str2, casesensitive)
{{
    Compare two strings.
    
    - Return zero if the two strings are equal.
    - Return positive value if `str1` comes after  `str2`.
    - Return negative value if `str1` comes before `str2`.
    
    Parameters:

    - str1 - the first string to compare.
    - str2 - the second string to compare.
    - casesensitive - use `true` for case-sensitive comparison, or `false` for case-insensitive.
}}

    if casesensitive
        repeat
            result := (byte[str1] - byte[str2++])
        while(byte[str1++] and (not(result)))
    else
        repeat
            result := (IgnoreCase(byte[str1]) - IgnoreCase(byte[str2++]))
        while(byte[str1++] and (not(result)))

PUB Copy(source, destination)
{{
    Copies a string from one location to another.
    
    Returns a pointer to the new string.
    
    Destination string must be larger or equal to size of source string.
}}

    bytemove(destination, source, (strsize(source) + 1))
    return destination

PUB Fill(str, char)
{{
    Fills string with characters.
}}

    bytefill(str, char, strsize(str))
    byte[str + strsize(str)] := 0
    return str

PUB Lower(str)
{{
    Converts all uppercase characters in string to lowercase.
    
    Note: This function operates on the original string and does not make a copy.
}}

    repeat strsize(str--)
        result := byte[++str]
        if((result => "A") and (result =< "Z"))
            byte[str] := (result + 32)

PUB Upper(str)
{{
    Converts all lowercase characters in string to uppercase.
}}

    repeat strsize(str--)
        result := byte[++str]
        if((result => "a") and (result =< "z"))
            byte[str] := (result - 32)

PUB IsEmpty(str)
{{
    Returns true if string contains no characters, otherwise false.
}}

    return (strsize(str) == 0)

PUB Strip(str)
{{
    Removes white space and new lines arround the outside of string of characters.
    
    Returns a pointer to the trimmed string of characters.
    
    str - A pointer to a string of characters to be trimmed.
}}

    result := IgnoreSpace(str)
    str := (result + ((strsize(result) - 1) #> 0))
    
    repeat
        case byte[str]
            8 .. 13, 32, 127: byte[str--] := 0
            other: quit

PUB Join(str)
{{
    Removes white space and new lines arround the inside of a string of characters.
    
    Returns a pointer to the tokenized string of characters, or an empty string when out of tokenized strings of characters.
    
    str - A pointer to a string of characters to be tokenized, or null to continue tokenizing a string of characters.
}}
    
    result := str := IgnoreSpace(str)
    
    repeat while(byte[str])
        case byte[str++]
            8 .. 13, 32, 127:
                byte[str - 1] := 0
                quit

PUB FindChar(str, char)
{{
    Searches a string of characters for the first occurence of the specified character.
    
    Returns the address of that character if found and zero if not found.
    
    str - A pointer to the string of characters to search.
    CharacterToFind - The character to find in the string of characters to search.
}}

    repeat strsize(str--)
        if(byte[++str] == char)
            return str

PUB ReplaceChar(str, char, newchar)
{{
    Replaces the first occurence of the specified character in a string of characters with another character.
    
    Returns the address of the next character after the character replaced on success and zero on failure.
    
    str - A pointer to the string of characters to search.
    CharacterToReplace - The character to find in the string of characters to search.
    CharacterToReplaceWith - The character to replace the character found in the string of characters to search.
}}

    result := FindChar(str, char)
    if(result)
        byte[result++] := newchar

PUB ReplaceAllChars(str, char, newchar)
{{
    Replaces all occurences of the specified character in a string of characters with another character.
    
    str - A pointer to the string of characters to search.
    CharacterToReplace - The character to find in the string of characters to search.
    CharacterToReplaceWith - The character to replace the character found in the string of characters to search.
}}

    repeat while(str)
        str := ReplaceChar(str, char, newchar)

PUB Find(str, substr) | index, size '' 7 Stack Longs
{{
    Searches a string of characters for the first occurence of the specified string of characters.
    
    Returns the address of that string of characters if found and zero if not found.
    
    str - A pointer to the string of characters to search.
    substr - A pointer to the string of characters to find in the string of characters to search.
}}

    size := strsize(substr)
    if(size--)
    
        repeat strsize(str--)
            if(byte[++str] == byte[substr])
            
                repeat index from 0 to size
                    if(byte[str][index] <> byte[substr][index])
                        result := true
                        quit
                
                ifnot(result~)
                    return str

PUB Replace(str, substr, newsubstr)
{{
    Replaces the first occurence of the specified string of characters in a string of characters with another string of
    characters. Will not enlarge or shrink a string of characters.
    
    Returns the address of the next character after the string of characters replaced on success and zero on failure.
    
    str - A pointer to the string of characters to search.
    substr - A pointer to the string of characters to find in the string of characters to search.
    newsubstr - A pointer to the string of characters that will replace the string of characters found in the
                          string of characters to search.
}}

    result := Find(str, substr)
    if(result)
        repeat (strsize(newsubstr) <# strsize(substr))
            byte[result++] := byte[newsubstr++]

PUB ReplaceAll(str, substr, newsubstr) '' 19 Stack Longs
{{
    Replaces all occurences of the specified string of characters in a string of characters with another string of
    characters. Will not enlarge or shrink a string of characters.
    
    str - A pointer to the string of characters to search.
    substr - A pointer to the string of characters to find in the string of characters to search.
    newsubstr - A pointer to the string of characters that will replace the string of characters found in the
                          string of characters to search.
}}

    repeat while(str)
        str := Replace(str, substr, newsubstr)

PUB EndsWith(str, substr) | end
{{
    Checks if the string of characters ends with the specified characters.
    
    Returns true if yes and false if no.
    
    str - A pointer to the string of characters to search.
    substr - A pointer to the string of characters to find in the string of characters to search.
}}

    end := str + strsize(str) - strsize(substr)
    return (end == Find(end, substr))

PUB StartsWith(str, substr)
{{
    Checks if the string of characters starts with the specified characters.
}}
    return (str == Find(str, substr))

PUB Left(source, destination, count)
{{
    returns the left number of characters
}}
    bytemove(destination, source, count)
    byte[destination + count] := 0
    return destination
 
PUB Mid(source, destination, start, count)
{{
    returns strings starting at start with number characters
}}

    bytemove(destination, source + start, count)
    byte[destination + count] := 0
    return destination

PUB Right(source, destination, count)
{{
    Copies the `count` rightmost characters of `source` string to `destination` string.
    
    Returns resulting string.
}}

    bytemove(destination, source + strsize(source) - count, count)
    byte[destination + count] := 0
    return destination

PRI IgnoreCase(character)

    result := character
    if((character => "a") and (character =< "z"))
        result -= 32

PRI IgnoreSpace(characters)

    result := characters
    repeat strsize(characters--)
        case byte[++characters]
            8 .. 13, 32, 127:
            other: return characters
