' Author: Chip Gracey
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ

    mon : "debug.monitor"

PUB Main
{{
    Starts 'Monitor' in another cog using pins 31 and 30 at 19200 baud.
    Use a terminal program on the host machine to communicate.
}}

    mon.Start(31, 30, 19200)

