*-----------------------------------------------------------
* Title      : Monitor Project
* Written by : Raul Renteria
* Date       :
* Description:
*-----------------------------------------------------------
CR EQU $0D
LF EQU $0A
    ORG    $1000

SHELL:  DC.B    'MONITOR441>',0
INPUT   DS.B 80         ;input buffer for commands
        DC.B 0
        
;Help Commands
USER DC.B 'THIS IS THE USER PROGRAM',0
MDSPHELP DC.B 'MDSP: Outputs Address and Memory contents',CR,LF,'MDSP <address1> <address2> eg: MDSP $908 $90A<CR>',CR,LF,0
SORTWHELP DC.B 'SORTW: Sorts a block of memory. Default: Descending Order.',CR,LF,'A: Ascending order',CR,LF,'D: Descending order',CR,LF,'SORTW <address1> <address2> <order>',CR,LF,0
MMHELP DC.B 'MM: Displays and optionally modifies contents of memory at the specified address',CR,LF,'MM <size> <address>',CR,LF,'All addresses must be prefixed with $',CR,LF,0
MSHELP DC.B 'MS: Stores an ASCII string into memory starting at ADDRESS',CR,LF,'MS <ADDRESS> <STRING>',CR,LF,'All addresses must be prefixed with $',CR,LF,0
BTSTHELP DC.B 'BTST: <STARTADDRESS> <ENDADDRESS>',CR,LF,'All vales are in hex and must be prefixed with $',CR,LF,0
CRCHELP DC.B 'CRC: computes the CRC-16 checksum of the specified data',CR,LF,'CRC <startaddress> <endaddres>',CR,LF,'All vales are in hex and must be prefixed with $',CR,LF,0
BMOVHELP DC.B 'BMOV: Moves N bytes from <SRCADDRESS> to <DESTADDRESS>',CR,LF,'BMOV <SRCADDRESS> <DESTADDRESS> <N>',CR,LF,'All values must be in hexadecimal and prefixed with $',CR,LF,0
BFHELP DC.B 'BF: Fills memory from first address to second address with zero padded word data',CR,LF,'BF <STARTADDRESS> <ENDADDRESS> <WORD DATA>',CR,LF,'All addresses must be prefixed with $ and aligned to a word boundary',CR,LF,0
BSCHHELP DC.B 'BSCH: Searches for the first occurence of <STRING> between <STARTADDRESS> and <ENDADDRESS>',CR,LF,'BSCH <STARTADDRESS> <ENDADDRESS> <STRING>',CR,LF,'All addresses must be prefixed with $',CR,LF,0
GOHELP DC.B 'GO: Begins execution at ADDRESS',CR,LF,'GO <ADDRESS>',CR,LF,0
SETHELP DC.B 'SET REGISTER: .<D{0-7} - A{0-6}> <DATA>  -  Sets <DATA> into <REGISTER>',0
DFHELP DC.B 'DF: Displays nicely formatted register contents',CR,LF,0 
EXITHELP DC.B 'EXIT: Halts execution',CR,LF,0

;Print out for registers
A0REG: DC.B 'A0=',0
A1REG: DC.B 'A1=',0
A2REG: DC.B 'A2=',0
A3REG: DC.B 'A3=',0
A4REG: DC.B 'A4=',0
A5REG: DC.B 'A5=',0
A6REG: DC.B 'A6=',0
A7REG: DC.B 'A7(SSP)=',0
D0REG: DC.B 'D0=',0
D1REG: DC.B 'D1=',0
D2REG: DC.B 'D2=',0
D3REG: DC.B 'D3=',0
D4REG: DC.B 'D4=',0
D5REG: DC.B 'D5=',0
D6REG: DC.B 'D6=',0
D7REG: DC.B 'D7=',0
SRREG: DC.B 'SR=',0
PCREG: DC.B 'PC=',0
USPREG: DC.B 'USP=',0

;Commands to compare input stings to. 
HELPCOMMAND: DC.B 'HELP',0
MDSPCOMMAND DC.B 'MDSP',0
SORTWCOMMAND DC.B 'SORTW',0
CRCCOMMAND DC.B 'CRC',0
MMCOMMAND DC.B 'MM',0
MSCOMMAND DC.B 'MS',0
BFCOMMAND DC.B 'BF',0
BMOVCOMMAND DC.B 'BMOV',0
BTSTCOMMAND DC.B 'BTST',0
BSCHCOMMAND DC.B 'BSCH',0
GOCOMMAND DC.B 'GO',0
DFCOMMAND DC.B 'DF',0
EXITCOMMAND DC.B 'EXIT',0









    ORG    $2000
START:                  ; first instruction of program

CMD:
    LEA SHELL,A1       ; will print out MONITOR441>
    MOVE.B #14,D0
    TRAP #15
    LEA INPUT,A1        ; parses cmd and reads command
    MOVE.B #2,D0
    TRAP #15
    MOVE.W D1,D6        
    CMP.W #0,D1         ; check if the string is empty
    BEQ CMD             ; restart 
    MOVE.W #4, D0
    BSR STRCMP
    TST.W D0            
    BNE MDSPIN
    BSR PRINTHELP
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA CMD
    
MDSP:
    MOVE.L A1,A5
    ADD #5,A5
    MOVE.L A5,A6
    BSR LOCBOUND
    BSR PARSEIN         ;PARSE FIRST ADDRESS
    TST D1
    BNE MDSP_ERR
    MOVE.L D0,D5
    ADD.L #1,A6
    MOVE.L A6,A5
    BSR LOCBOUND
    ADD.L D6,A1         ;CHECK IF 2ND ADDRESS IS VALID
    CMP.L A1,A6
    BEQ MDSPBINARY
    MOVE.L D5,A5
    MOVE.L D5,A6
    ADD.L #16,A6
    BRA MDSP_GO
MDSPBINARY:             ;DISPLAY 16 BYTES IF ONLY ONE ARG GIVEN
    BSR PARSEIN         ;PARSE FIRST ADDRESS
    TST D1
    BNE MDSP_ERR
    MOVE.L D5,A5
    MOVE.L D0,A6
MDSP_GO:
    BSR MDSP
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA CMD
    
 
    


    SIMHALT             ; halt simulator
    
STRCMP:         ;STRING COMPARE, STRINGS AT (A5) AND (A6), LENGTH IN D0.W, RESULT (0 IF EQUAL) RETURNED IN D0
    MOVEM.L A5/A6, -(SP)
    TST D0      ;ZERO BYTES TO COMPARE?
    BEQ SCNOTEQ
    SUB.L #1,D0
STRCMPLOOP:
    CMP.B (A5)+,(A6)+
    BNE SCNOTEQ     ; STRINGS NOT EQUAL IF CHARS DO NOT MATCH
    TST.W D0
    DBEQ.W D0,STRCMPLOOP    ;  DO AT MOST D0 COMPARISONS
    BRA SCEQ  ; KEEP COMPARING OTHERWISE
SCNOTEQ:
    MOVE.L #1,D0
    MOVEM.L (SP)+, A5/A6    ;RETURN 1
    RTS
SCEQ:
    MOVEM.L (SP)+, A5/A6    ;RETURN 0
    RTS
    



MDSPHELPER:
    MOVEM.L D0/A1, -(SP)
    LEA MDSPHELP, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS

SORTWHELPER:
    MOVEM.L D0/A1, -(SP)
    LEA SORTWHELP, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS

MMHELPER:
    MOVEM.L D0/A1, -(SP)
    LEA MMHELP, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
MSHELPER:
    MOVEM.L D0/A1, -(SP)
    LEA MSHELP, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
BFHELPER:
    MOVEM.L D0/A1, -(SP)
    LEA BFHELP, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
BMOVHELPER:
    MOVEM.L D0/A1, -(SP)
    LEA BMOVHELP, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS

BTSTHELPER:
    MOVEM.L D0/A1, -(SP)
    LEA BTSTHELP, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
BSCHHELPER:
    MOVEM.L D0/A1, -(SP)
    LEA BSCHHELP, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS

GOHELPER:
    MOVEM.L D0/A1, -(SP)
    LEA GOHELP, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
SETHELPER:
    MOVEM.L D0/A1, -(SP)
    LEA SETHELP, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
CRCHELPER:
    MOVEM.L D0/A1, -(SP)
    LEA CRCHELP, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS


PRINTHELP:
    BSR MDSPHELPER
    BSR SORTWHELPER
    BSR MMHELPER
    BSR MSHELPER
    BSR BFHELPER
    BSR BMOVHELPER
    BSR BTSTHELPER
    BSR BSCHHELPER
    BSR GOHELPER
    BSR SETHELPER
    BSR CRCHELPER
    MOVEM.L D0/A1, -(SP)
    LEA DFHELP, A1
    MOVE.B #13,D0
    TRAP #15
    LEA EXITHELP, A1
    MOVEM.L (SP)+, D0/A1
    RTS



    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
