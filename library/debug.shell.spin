CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
    
    MAX_LINE = 40

OBJ

    term            : "com.serial.terminal"
    commandparser   : "debug.shell.commandparser"

VAR

    byte    line[MAX_LINE]
    
PUB Main | hex

    term.Start (115200)

    commandparser.SetDescription(@data_description)
    commandparser.SetPrompt(@data_prompt)
    
    hex := commandparser.AddCommand(@cmd_hex, @cmd_hex_desc)
    commandparser.AddOption (hex, @opt_b, @opt_b_desc)

    commandparser.AddCommand(@cmd_info, @cmd_info_desc)

    commandparser.Start(@line, MAX_LINE)
    
    repeat
        ReadLine
    
PUB ReadLine | i

    term.Flush
    term.Str (@data_prompt)

    term.StrInMax (@line, MAX_LINE)
    
    i := commandparser.Process
    if i <> commandparser#ERROR_NONE
    
        Error(commandparser.ErrorString(i))
        term.Str (commandparser.Usage)
                
    elseif commandparser.IsCommand (@cmd_help)
    
        term.Str (commandparser.Help)
    
    elseif commandparser.IsCommand (@cmd_hex)
    
        HexCommand
    
    elseif commandparser.IsCommand (@cmd_info)
    
        InfoCommand

PUB HexCommand

    if commandparser.IsSet (@opt_b)
        term.Str (commandparser.Value (@opt_b))
        term.NewLine
        
PUB InfoCommand

    term.Str (string("chipver: "))
    term.Dec (chipver)
    term.Newline

    term.Str (string("clkfreq: "))
    term.Dec (clkfreq)
    term.Str (string(" MHz"))
    term.Newline
    
    term.Str (string("clkmode: "))
    term.Bin (clkmode, 8)
    term.NewLine
    
PRI Error(s)

    term.Str (string("ERROR: "))
    term.Str (s)
    term.Newline

DAT

    data_description    byte    "This shell enables an interface to a live Propeller for debugging.",10,0
    data_prompt         byte    "$ ",0

    cmd_help        byte    "help",0
    
    cmd_hex         byte    "hex",0
    cmd_hex_desc    byte    "output hex to terminal",0

    cmd_info        byte    "info",0
    cmd_info_desc   byte    "print information about the running application",0
    
    opt_b           byte    "-b",0
    opt_b_desc      byte    "Enable some feature",0
