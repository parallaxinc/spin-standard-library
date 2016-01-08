CON
    MAX_ARGUMENTS = 10
    
    MAX_COMMANDS = 4
    MAX_OPTIONS = 10
    
    #0, ERROR_NONE, ERROR_MAX_CHARS, ERROR_MAX_ARGS, ERROR_INVALID_ARGS, ERROR_INVALID_COMMAND

OBJ

    str : "string"

VAR

    byte    max_line
    word    ptr_str
    
    word    ptr_prompt
    word    ptr_description
    
    word    ptr_usage
    
    byte    argc
    word    argv[MAX_ARGUMENTS]

    byte    cmdc
    word    command_name[MAX_COMMANDS]        ' pointers to ARGUMENTS
    word    command_description[MAX_COMMANDS]   ' pointers to descriptions

    byte    optc
    word    option_cmd[MAX_OPTIONS]
    word    option_name[MAX_OPTIONS]
    word    option_description[MAX_OPTIONS]
    
    word    error_string[5]
    
    byte    data_usage[(MAX_COMMANDS+MAX_OPTIONS+4)*30]


PUB Start(s, size)

    ptr_str := s
    max_line := size
    
    error_string[ERROR_NONE]            := string("No error")
    error_string[ERROR_MAX_CHARS]       := string("Max characters")    
    error_string[ERROR_MAX_ARGS]        := string("Max arguments")
    error_string[ERROR_INVALID_ARGS]    := string("Invalid arguments")
    error_string[ERROR_INVALID_COMMAND] := string("Invalid command")
    
    AddCommand (string("help"), string("show help"))
    BuildHelp
    
PUB ErrorString(err)

    return error_string[err]

PUB Process

    if strsize(ptr_str) => max_line
        return ERROR_MAX_CHARS
    
    argc := 0
    argv[argc] := str.Tokenize (ptr_str)       

    if MatchCommand(argv[0]) == -1
        return ERROR_INVALID_COMMAND

    repeat while argv[argc]
        if argc => MAX_ARGUMENTS
            return ERROR_MAX_ARGS
    
        ifnot MatchCommand(argv[argc]) <> -1
            return ERROR_INVALID_ARGS

        ' put more stuff here
            
        argv[++argc] := str.Tokenize (0)

PUB AddCommand(name, description)

    result := cmdc
    if cmdc < MAX_COMMANDS
        if MatchCommand(name) <> -1
            return -1
        command_name[cmdc] := name
        command_description[cmdc] := description
        cmdc++
        
PUB AddOption(cmd, name, description)

    result := optc
    if optc < MAX_OPTIONS
        if MatchOption(name) <> -1
            return -1
        option_cmd[optc] := cmd
        option_name[optc] := name
        option_description[optc] := description
        optc++

PUB IsCommand(cmd)

    return str.Match(argv[0], cmd)

PUB IsSet(option) | i, m

    i := 1
    repeat while i < argc
        if str.Match(argv[i++], option)
            return --i

PUB Value(option) | i

    i := IsSet(option)
    if ++i => argc
        return
        
    if byte[argv[i]][0] == "-"
        return
        
    return argv[i]

PUB SetPrompt(s)

    ptr_prompt := s
    
PUB SetDescription(s)

    ptr_description := s

PRI BuildHelp

    str.Copy  (@data_usage, ptr_description)
    str.Append(@data_usage, string("commands:",10,10))
    
    BuildUsage
    
PRI BuildUsage | i, j

    ptr_usage := @data_usage + strsize(@data_usage)

    i := 0
    repeat while i < cmdc
        str.Append(@data_usage, string("    "))
        str.Append(@data_usage, command_name[i])
        bytefill  (@data_usage + strsize(@data_usage), " ", 12 - strsize(command_name[i]))
        str.Append(@data_usage, command_description[i])
        str.Append(@data_usage, string(10))
        i++
       
PUB Help

    return @data_usage
            
PUB Usage

    return ptr_usage

PRI MatchCommand(s) | j

    j := 0
    repeat while j < cmdc
    
        if str.Match(s, command_name[j])
            return cmdc
        j++

    return -1

PRI MatchOption(s) | j

    j := 0
    repeat while j < optc
    
        if str.Match(s, option_name[j])
            return optc
        j++

    return -1
