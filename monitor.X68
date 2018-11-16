*-----------------------------------------------------------
* Title      : Monitor Project
* Written by : Raul Renteria
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000

SHELL:  DC.B    'MONITOR441>',0
INPUT   DS.B 80         ;input buffer for commands
        DC.B 0














    ORG    $2000
START:                  ; first instruction of program

CMD:
    LEA SHELL,A1       ; will print out MONITOR441>
    MOVE.B #14,D0
    TRAP #15
    LEA INPUT,A1        ; parses cmd and reads command
    MOVE.B #2,D0
    TRAP #15

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
