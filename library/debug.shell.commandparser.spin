CON
    MAX_ARGUMENTS = 10
    
    MAX_COMMANDS = 5
    MAX_OPTIONS = 5
    
    MAX_ERRORS = 5
    
    MAX_POSITIONAL_ARGUMENTS = 3
    
    MAX_USAGE = (MAX_COMMANDS+MAX_OPTIONS+10)*40
    
    #0, ERROR_NONE, ERROR_MAX_ARGS, ERROR_INVALID_ARGS, ERROR_INVALID_COMMAND, ERROR_MISSING_PARAMETER

OBJ

    str : "string"

VAR

    byte    max_line
    word    ptr_str
    
    word    ptr_prompt
    word    ptr_description
    
    byte    argc
    word    argv[MAX_ARGUMENTS]

    byte    cmdc
    word    command_name[MAX_COMMANDS]
    word    command_description[MAX_COMMANDS]
    word    command_positional_argument_name[MAX_COMMANDS]
    word    command_positional_argument_description[MAX_COMMANDS]
    byte    currentcommand

    byte    optc
    byte    option_cmd[MAX_OPTIONS]
    word    option_name[MAX_OPTIONS]
    word    option_description[MAX_OPTIONS]
    byte    option_hasvalue[MAX_OPTIONS]
    word    option_value[MAX_OPTIONS]

    
    byte    posc
    word    positional_argument
    
    word    error_string[MAX_ERRORS]
    
    byte    data_usage[MAX_USAGE]


PUB Start(s, size)

    ptr_str := s
    max_line := size
    
    error_string[ERROR_MAX_ARGS]            := string("Max arguments")
    error_string[ERROR_INVALID_ARGS]        := string("Invalid arguments")
    error_string[ERROR_INVALID_COMMAND]     := string("Invalid command")
    error_string[ERROR_MISSING_PARAMETER]   := string("Option missing parameter")
    
    AddCommand (string("help"), string("show help"))
    

PUB Process | i

    wordfill(@option_value, 0, MAX_OPTIONS)
    
    argc := 0
    posc := 0
    currentcommand := -1
    argv[argc] := str.Tokenize (ptr_str)       

    currentcommand := MatchCommand(argv[0])
    if (currentcommand == 255)
        return ERROR_INVALID_COMMAND

    argv[++argc] := str.Tokenize (0)    ' pump for arguments
                                        ' 
    

    repeat while argv[argc]
        if argc => MAX_ARGUMENTS
            return ERROR_MAX_ARGS

        
        if (i := MatchOption(argv[argc])) > -1
            if option_hasvalue[i]
                argv[++argc] := str.Tokenize (0)
                
                ifnot argv[argc]
                    return ERROR_MISSING_PARAMETER
                    next
                
                if argc => MAX_ARGUMENTS
                    return ERROR_MAX_ARGS
                    
                if IsOption(argc)
                    return ERROR_INVALID_ARGS
                    
                option_value[i] := argv[argc]                
                
'            return COMMAND_FOUND
        else
            ifnot IsOption(argc)
                positional_argument[posc++] := argv[argc]
            else
                return ERROR_INVALID_ARGS
 '           return COMMAND_FOUND2


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
        
PUB AddOption(cmd, name, description, hasvalue)

    result := optc
    if optc < MAX_OPTIONS
        if MatchOption(name) <> -1
            return -1
        option_cmd[optc] := cmd
        option_name[optc] := name
        option_description[optc] := description
        option_hasvalue[optc] := hasvalue
        optc++
        
PUB AddPositionalArgument(cmd, name, description)

    if posc < MAX_POSITIONAL_ARGUMENTS and cmd => 0 and cmd < MAX_COMMANDS
        command_positional_argument_name[cmd] := name
        command_positional_argument_description[cmd] := description

PUB PositionalArgument

    return positional_argument

PUB IsCommand(cmd)

    return str.Match(argv[0], cmd)

PUB IsSet(option) | i, j

    i := MatchOption(option)
    if option_hasvalue[i]
        return (option_value[i] <> 0)
    else
        j := 0
        repeat while j < argc
            if str.Match(argv[j++], option)
                return true

PUB IsOption(n)

    return (byte[argv[n]][0] == "-")

PUB Value(option) | i

    if (i := MatchOption(option)) > -1
        return option_value[i]

PUB SetPrompt(s)

    ptr_prompt := s
    
PUB SetDescription(s)

    ptr_description := s

PUB ErrorString(err)

    return error_string[err]

PUB Usage | i

    str.Clear (@data_usage)
    
    i := MatchCommand(PositionalArgument)
    
    if (currentcommand == 255)
        BuildHelp
    elseif IsCommand(string("help"))
        if i > -1
            BuildCommandHelp(i)
        else
            BuildHelp
    else
        BuildCommandHelp(i)
        
    str.Append(@data_usage, string(10))

    return @data_usage
    
PRI BuildHelp | i

    str.Append(@data_usage, ptr_description)
    str.Append(@data_usage, string(10,"commands:",10,10))

    i := 0
    repeat while i < cmdc
        AddLine(command_name[i], command_description[i], 0)
        i++

PRI BuildCommandHelp(cmd) | i, c

    str.Append(@data_usage, string("Usage: "))
    str.Append(@data_usage, command_name[cmd])

    c:= 0    
    repeat i from 0 to optc - 1
        if option_cmd[i] == cmd
            c++

    if c > 0
        str.Append(@data_usage, string(" [OPTIONS]..."))

    if command_positional_argument_name[cmd] <> 0
        str.Append(@data_usage, string(" "))
        str.Append(@data_usage, command_positional_argument_name[cmd])
        str.Append(@data_usage, string(10))

    if c > 0
        str.Append(@data_usage, string(10,"options:",10,10))

        i := 0
        repeat while i < optc
            if (option_cmd[i] == cmd)
                AddLine(option_name[i], option_description[i], option_hasvalue[i])
            i++
        
    if command_positional_argument_name[cmd] <> 0
        str.Append(@data_usage, string(10,"positional argument:",10,10))
        AddLine(command_positional_argument_name[cmd], command_positional_argument_description[cmd], 0)

PRI AddLine(name, description, hasvalue)

    str.Append(@data_usage, string("    "))
    str.Append(@data_usage, name)
    if hasvalue
        str.Append(@data_usage, string(" VAL"))
        bytefill  (@data_usage + strsize(@data_usage), " ", 12 - strsize(name) - 4)
    else
        bytefill  (@data_usage + strsize(@data_usage), " ", 12 - strsize(name))
    str.Append(@data_usage, description)
    str.Append(@data_usage, string(10))

PRI MatchCommand(s) | j

    j := 0
    repeat while j < cmdc
    
        if str.Match(s, command_name[j])
            return j
        j++

    return -1

PRI MatchOption(s) | j

    j := 0
    repeat while j < optc
        if currentcommand == option_cmd[j] and str.Match(s, option_name[j])
            return j
        j++

    return -1
