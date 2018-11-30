*-----------------------------------------------------------
* Title      : Monitor Project
* Written by : Raul Renteria
* Date       :
* Description: HELL on earth/Simplified version of TUTOR program
*-----------------------------------------------------------

CR EQU $0D  ; Carrigage return
LF EQU $0A  ; New Line
    ORG    $2000
    
SHELL_PROMPT:  DC.B    'MONITOR441>',0
INPUT   DS.B 100         ;input buffer for commands
        DC.B 0
        
*Commands to compare input stings to*
HELPCOMMAND: DC.B 'HELP',0
MDSPCOMMAND DC.B 'MDSP',0
SORTWCOMMAND DC.B 'SORTW',0
MMCOMMAND DC.B 'MM',0
MSCOMMAND DC.B 'MS',0
BTSTCOMMAND DC.B 'BTST',0
BFCOMMAND DC.B 'BF',0
BMOVCOMMAND DC.B 'BMOV',0
BSCHCOMMAND DC.B 'BSCH',0
GOCOMMAND DC.B 'GO',0
DFCOMMAND DC.B 'DF',0
EXITCOMMAND DC.B 'EXIT',0
CRCCOM DC.B 'CRC',0
FONT DC.B 'FONT',0
ECHOCOMMAND DC.B 'ECHO',0
    
**Help Display prompts**
USERPROGRAM DC.B 'Do cool shit here: ',0
MDSPHELPPROMPT DC.B 'MDSP: Outputs Address and Memory contents from <address1> to <address2>',CR,LF,'MDSP <address1> <address2> eg: MDSP $908 $90A<CR>',CR,LF,0
SORTWHELPPROMPT DC.B 'SORTW: Sorts a block of memory from <address1> to <address2>. The order is specified by the following.',CR,LF,'A: Ascending order',CR,LF,'D: Descending order',CR,LF,'SORTW <address1> <address2> <order>',CR,LF,0
MMHELPPROMPT DC.B 'MM: Display memory and optionally enter new data. Can specify Byte, Word, or Long size.',CR,LF,'MM <size> <address>',CR,LF,0
MSHELPPROMPT DC.B 'MS: Alters memory by setting data into the specified address. Can take ASCII string or HEX',CR,LF,'MS <address> <string>',CR,LF,0
BTSTHELPPROMPT DC.B 'BTST: <address1> <address2>',CR,LF,0
BMOVHELPPROMPT DC.B 'BMOV: Moves bytes of memory from <address1> to <address2>',CR,LF,'BMOV <address1> <address2> <n>',CR,LF,0
BFHELPPROMPT DC.B 'BF: Fills memory from <address1> to <address2> with the provieded data as input. <data> must be word sized  ',CR,LF,'BF <address1> <address2> <data>',CR,LF,0
BSCHHELPPROMPT DC.B 'BSCH: Searches for literal <string>  between <address1> and <address2>',CR,LF,'BSCH <address1> <address2> <string>',CR,LF,0
GOHELPPROMPT DC.B 'GO: Begin execution of program at address',CR,LF,'GO <address>',CR,LF,0
DFHELPPROMPT DC.B 'DF: Displays register contents',CR,LF,0 
FONTHELPROMPT DC.B 'FONT: Changes the color of the font.',CR,LF,'<color> is a 6 digit hex number specifing the RGB. 0xBBGGRR: eg: FONT <color>',CR,LF,0
ECHOHELPPROMPT DC.B 'ECHO: prints put what the user input',CR,LF,'ECHO <string>',CR,LF,0
EXITHELPPROMPT DC.B 'EXIT: Stops Program',CR,LF,0
NL: DC.B 0
    
**Print out for registers**
A0REG: DC.B 'A0: ',0
A1REG: DC.B 'A1:',0
A2REG: DC.B 'A2: ',0
A3REG: DC.B 'A3: ',0
A4REG: DC.B 'A4: ',0
A5REG: DC.B 'A5: ',0
A6REG: DC.B 'A6:',0
A7REG: DC.B 'A7/SSP:',0
D0REG: DC.B 'D0: ',0
D1REG: DC.B 'D1: ',0
D2REG: DC.B 'D2: ',0
D3REG: DC.B 'D3: ',0
D4REG: DC.B 'D4: ',0
D5REG: DC.B 'D5: ',0
D6REG: DC.B 'D6: ',0
D7REG: DC.B 'D7: ',0
USPREG: DC.B 'USP: ',0
SRREG: DC.B 'SR: ',0
PCREG: DC.B 'PC: ',0

**exception prompts**
** GO $6010 - LINE F
** GO $6020 - LINE A
** GO $6030 - ILLEGAL INSTUCTION
** GO $6040 - Divide by Zero
** GO $6050 - Check
** GO $6060 - Privalege
ADDRESS_ER: DC.B 'Address Trap Error ',0
ILLEGAL_ER: DC.B 'Illegal Instruction Trap Error',0
PRIVALAGE_ER: DC.B 'Privelage Violation Exception',0
DIVIDE_Z_ER: DC.B 'Divide by 0 error',0
CHECK_ER: DC.B 'Check instruction error',0
LINEA_ER: DC.B 'Line A Emulator exception',0
LINEF_ER: DC.B 'Line F Emulator exception',0 

*Strings to print out
GO_ADDRESS: DC.B 'GO ADDRESS: ',0
NO_STRING_MATCH DC.B 'Didnt find string',0
STRING_MATCH DC.B 'Found the String!!',0
ADDRESS: DC.B 'ADDRESS ',0
COLON: DC.B ' : ',0

*Storage loction for PC, SSR, 
PC_STORE DS.L 1
REGNUM DS.B 1
REG_STORE DS.L 1
  
      
    ORG    $3000
START:

    **exception vectors**
    MOVE.L #ADDRESS_ERRORV,$C
    MOVE.L #ILLEGAL_INSTRV,$10
    MOVE.L #DIVIDE_ZEROV,$14
    MOVE.L #CHECK_INSTRV,$18
    MOVE.L #PRIVALEGEV,$20
    MOVE.L #LINEAV,$28
    MOVE.L #LINEFV,$2C
    MOVE.L #TRAPING_HOES,$84  
    
INIT:
    BRA SHELL
SHELL_RESET:
    MOVEM.L (SP)+, A0-A6/D0-D7
SHELL:
    MOVEM.L A0-A6/D0-D7, -(SP)
    LEA SHELL_PROMPT,A1       ; will print out MONITOR441>
    MOVE.B #14,D0
    TRAP #15
    LEA INPUT,A1
    MOVE.B #2,D0        ; parse cmd and read input
    TRAP #15
    MOVE.W D1,D6        ; keep length of string for comparisons
    CMP.W #0,D1         ; check if the input string is empty
    BEQ SHELL_RESET     ; if empty, restart prompt
    LEA INPUT,A5        ; put into A5
    LEA MDSPCOMMAND,A6  ; load MDSP command into A6
    MOVE.W #4,D0        ; since MDSP is 4 char long, put 4 into D0 for comp
    BSR CHECK_MATCH      ; compare the two stirngs
    TST.W D0            ; check if D0 == 0
    BNE MM_FUNC         ; if false, there is no match, so branch to test next instruction
    
    **Code to execute MDSP if the test above is true.
    MOVE.L A1,A5
    ADD #5,A5           ; Skip to address1
    MOVE.L A5,A6
    BSR FIND_END        ; find the end of address1
    BSR COMMAND_PARSE         ; A5 has begining of address1 and A6 has end of this. parse this address.
    TST D1              ; D0 will hold address1
    BNE MDSP_ERR        ; wring type of address
    MOVE.L D0,D2
    ADD.L #1,A6         ; go to address2
    MOVE.L A6,A5         
    BSR FIND_END        ; find end of address2
    ADD.L D6,A1         ; increment A1 to end of command
    CMP.L A1,A6         ; compare contents of A1 to A6 to ensure address2 is correct
    BEQ MDSP_2_ARGS     ; two addresses were given
    MOVE.L D2,A5        ; A5= address1, A6=address2
    MOVE.L D2,A6
    ADD.L #16,A6        ; add 16 to address1 since only 1 address was given
    BRA MDSP_EX
    
MDSP_2_ARGS:             
    BSR COMMAND_PARSE         
    TST D1
    BNE MDSP_ERR
    MOVE.L D2,A5
    MOVE.L D0,A6
MDSP_EX:
    BSR MDSP
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
    
MDSP_ERR:
    BSR MDSPHELP      
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL

*Check for MM 
MM_FUNC:
    LEA MMCOMMAND,A6
    MOVE.W #2,D0    ; MM command size is 2
    BSR CHECK_MATCH ; check if input is MM
    TST.W D0                   
    BNE SW_FUNC     ; Not MM? Go to SORTW
    
    **Code to execute MM
    ADD.L #5,A5     ; skip to size arg
    LEA INPUT,A6
    ADD.L D6,A6     ; PPOINT A6 to end of address
    BSR COMMAND_PARSE
    TST D1
    BEQ MM_CHECK_SIZE
    BSR MMHELP      
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
    
MM_CHECK_SIZE:
    SUB.L #2,A5     ; decrement A5 by two to go back to the size
    MOVE.L D0,A0    ; put address to modify in D0 into A0
    CMP.B #'B',(A5) ; check if the parsed arguement is B.
    BEQ MM_B
    CMP.B #'W',(A5)
    BEQ MM_W
    CMP.B #'L',(A5)
    BEQ MM_L
    BSR MMHELP       ; if it's not either one of the three. There's an error.
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
MM_B:           
    CLR.L D7
    BSR MM
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
MM_W:                 
    MOVE.L #1, D7
    BSR MM
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
MM_L:             
    MOVE.L #2, D7
    BSR MM
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL 

*Check for SORTW
SW_FUNC:
    LEA SORTWCOMMAND,A6 ; put sortw into A6     
    MOVE.W #5,D0
    BSR CHECK_MATCH
    TST.W D0            
    BNE BMOV_FUNC
    
    ADD.L #8,A5         ; this is the start of address1     
    MOVE.L A5,A6
    BSR FIND_END        ; find end
    BSR COMMAND_PARSE         ; get inputs 
    TST D1
    BNE SORTW_ERR       ; incorrect arguemnts 
    MOVE.L D0,D6        ; put address1 in D6
    ADD.L #1,A6
    MOVE.L A6,A5
    BSR FIND_END        ; getting second address
    BSR COMMAND_PARSE         
    TST D1
    BNE SORTW_ERR       ; wrong arguments
    LEA INPUT,A5
    ADD.L #6,A5         ; get the letter. D or A
    CMP.B #'A',(A5)
    BEQ SORTA
    CMP.B #'D',(A5)
    BEQ SORTD
    BSR SORTWHELP        ; No letter, or incorrect letter. 
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
    
* descending 
SORTD:
    MOVE.L D6,A5
    MOVE.L D0,A6
    MOVE.B #1,D0            
    BSR SORTW
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
 *aascending  
SORTA:
    MOVE.L D6,A5
    MOVE.L D0,A6
    MOVE.B #0,D0
    BSR SORTW            
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
    
SORTW_ERR:
    BSR SORTWHELP      ;PRINT HELP IF ERROR
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
    
    
BMOV_FUNC:
    LEA BMOVCOMMAND,A6  ;bmov into A6
    MOVE.W #4,D0
    BSR CHECK_MATCH
    TST.W D0          
    BNE MS_FUNC         ; Not BMOV? go to MS
    
    
    ADD.L #5,A5         ; address1 in A5     
    MOVE.L A5,A6
    BSR FIND_END
    BSR COMMAND_PARSE
    TST D1
    BNE BMOV_ERR
    MOVE.L D0,D5        ; address1 goes in d5
    ADD.L #1,A6
    MOVE.L A6,A5
    BSR FIND_END        ; getting address2
    BSR COMMAND_PARSE         ; 
    MOVE.L D0,D4
    TST D1
    BNE BMOV_ERR
    ADD.L #1,A6
    MOVE.L A6,A5
    BSR FIND_END        ; getting number of bytes to move
    BSR COMMAND_PARSE         ; stored in D0
    TST D1
    BNE BMOV_ERR
    MOVE.L D5,A5
    MOVE.L D4,A6
    BSR BMOV            ; call BMOV with A5=address1, A6=address2, D0=count
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
    
BMOV_ERR:
    BSR BMOVHELP
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL 

    
    
MS_FUNC:
    LEA MSCOMMAND,A6    ; put MS into A6
    MOVE.W #2,D0
    BSR CHECK_MATCH
    TST.W D0            
    BNE BF_FUNC         
    
    ADD.L #3,A5         ; starting address    
    MOVE.L A5,A6
    BSR FIND_END
    BSR COMMAND_PARSE
    TST D1
    BNE MS_ERR
    MOVE.L D0,D5        ; address1 goes in D5
    ADD.L #1,A6         ; getting the data to store
    MOVE.L A6,A5        
    LEA INPUT,A6
    ADDA.L D6,A6        
    MOVE.L A6,D0
    SUB.L  A5,D0        ; getting size of bytes to move for BMOV
    ADDI.L #1,D0        
    MOVE.L D5,A6    
    BSR BMOV            ; Call BMOV func for implementation 
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
    
MS_ERR:
    BSR MSHELP
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL    
    
    
BF_FUNC:
    LEA BFCOMMAND,A6        ; put BF into A6
    MOVE.W #2,D0
    BSR CHECK_MATCH
    TST.W D0
    BRA BSCH_FUNC
    
    *implement bf
    ADD.L #3,A5         ; getting address1   
    MOVE.L A5,A6
    BSR FIND_END
    BSR COMMAND_PARSE
    TST D1
    BNE BF_ERR
    MOVE.L D0,D5        ; D5 has address1
    ADD.L #1,A6
    MOVE.L A6,A5
    BSR FIND_END        ; getting address2
    BSR COMMAND_PARSE         
    MOVE.L D0,D4        ; D4 has address2
    TST D1
    BNE BF_ERR
    ADD.L #1,A6
    MOVE.L A6,A5        
    BSR FIND_END        ; getting data to fill blocks with
    BSR COMMAND_PARSE        
    TST D1
    BNE BF_ERR
    MOVE.L D5,A5        ; address1
    MOVE.L D4,A6        ; address2
    BSR BF
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
    
BF_ERR:
    BSR BFHELP
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL   

BSCH_FUNC:
    LEA BSCHCOMMAND,A6  ; PUT bsch IN a6
    MOVE.W #4,D0
    BSR CHECK_MATCH
    TST.W D0            
    BNE GO_FUNC
    
    
    ADD.L #5,A5         ;Start address    
    MOVE.L A5,A6
    BSR FIND_END
    BSR COMMAND_PARSE
    TST D1
    BNE BSCH_ERR
    MOVE.L D0,A0        
    ADD.L #1,A6
    MOVE.L A6,A5
    BSR FIND_END
    BSR COMMAND_PARSE
    TST D1
    BNE BSCH_ERR
    MOVE.L D0,A1        ;second address
    ADD.L #1,A6         ; getting stirng to find
    MOVE.L A6,A5        
    LEA INPUT,A6
    ADDA.L D6,A6        
    MOVE.L A6,D0
    SUB.L  A5,D0        
    MOVE.L D0,D3        
    BSR BSCH
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
BSCH_ERR:
    BSR BSCHHELP
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL
    
GO_FUNC:
    LEA GOCOMMAND,A6    ; put go in A6
    MOVE.W #2,D0
    BSR CHECK_MATCH          
    TST.W D0
    BNE DF_FUNC
    
    ADD.L #3,A5         ; get start address     
    MOVE.L A5,A6
    BSR FIND_END
    BSR COMMAND_PARSE
    TST D1
    BNE GO_ERR
    MOVE.L D0,REG_STORE   ; put starting address of program in memory
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA GO
    
GO_ERR:
    MOVEM.L (SP)+, A0-A6/D0-D7
    BSR GOHELP
    BRA SHELL
    
DF_FUNC:
    LEA DFCOMMAND,A6    ; putting DF ni A6
    MOVE.W #2,D0
    BSR CHECK_MATCH
    TST.W D0            
    BNE FONT_FUNC
    
PC_VAL:
    MOVE.L #PC_VAL,PC_STORE ; put PC in storage location to print out later
    MOVE.W SR,REG_STORE       ; get SR data 
    MOVEM.L (SP)+, A0-A6/D0-D7  
    BSR DF
    BRA SHELL
    
FONT_FUNC:
    LEA FONT,A6
    MOVE.W #4,D0
    BSR CHECK_MATCH          
    TST.W D0
    BNE ECHO_FUNC
    
    ADD.L #5,A5         ; address into A5     
    MOVE.L A5,A6
    BSR FIND_END
    BSR COMMAND_PARSE
    TST D1
    BNE FONT_ERR
    MOVE.L D0,D1    ;value to change font color stored in D1
    MOVE.B #21,D0
    TRAP #15        ;change font color
    BRA SHELL
    
FONT_ERR:
    MOVEM.L (SP)+, A0-A6/D0-D7
    BSR FONTHELP
    BRA SHELL
    
    
ECHO_FUNC:
    LEA ECHOCOMMAND,A6
    MOVE.W #4,D0
    BSR CHECK_MATCH          
    TST.W D0
    BNE EXIT_FUNC
    
    ADD.L #5,A5         ; address into A5     
    MOVE.L A5,A6
    BSR FIND_END
    BSR COMMAND_PARSE
    MOVE.W A5,A1
    SUB.L A5,A6
    MOVE.W A6,D1
    MOVE.W #13,D0
    TRAP #15        ; print out text
    BRA SHELL
    
ECHO_ERR:
    MOVEM.L (SP)+, A0-A6/D0-D7
    BSR GOHELP
    BRA SHELL
    
    

EXIT_FUNC:
    LEA EXITCOMMAND,A6
    MOVE.W #4,D0
    BSR CHECK_MATCH
    TST.W D0           
    BNE ERR 
    
    MOVE.W #9,D0    ; 9 terminates the program
    TRAP #15   
    
ERR:
    BSR ALL_HELP_PROMPTS
    MOVEM.L (SP)+, A0-A6/D0-D7
    BRA SHELL

MMHELP:
    MOVEM.L D0/A1, -(SP)
    LEA MMHELPPROMPT, A1
    MOVE.B #13,D0  
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
MSHELP:
    MOVEM.L D0/A1, -(SP)
    LEA MSHELPPROMPT, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS

SORTWHELP:
    MOVEM.L D0/A1, -(SP)
    LEA SORTWHELPPROMPT, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
MDSPHELP:
    MOVEM.L D0/A1, -(SP)
    LEA MDSPHELPPROMPT, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
BFHELP:
    MOVEM.L D0/A1, -(SP)
    LEA BFHELPPROMPT, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS

BMOVHELP:
    MOVEM.L D0/A1, -(SP)
    LEA BMOVHELPPROMPT, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
BSCHHELP:
    MOVEM.L D0/A1, -(SP)
    LEA BSCHHELPPROMPT, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS

GOHELP:
    MOVEM.L D0/A1, -(SP)
    LEA GOHELPPROMPT, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
FONTHELP:
    MOVEM.L D0/A1, -(SP)
    LEA FONTHELPROMPT, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
ECHOHELP:
    MOVEM.L D0/A1, -(SP)
    LEA ECHOHELPPROMPT, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS


ALL_HELP_PROMPTS:
    BSR MMHELP
    BSR SORTWHELP
    BSR MDSPHELP
    BSR MSHELP
    BSR BFHELP
    BSR BMOVHELP
    BSR BSCHHELP
    BSR GOHELP
    BSR FONTHELP
    BSR ECHOHELP
    MOVEM.L D0/A1, -(SP)
    LEA DFHELPPROMPT, A1
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+, D0/A1
    RTS
    
*Finds end of string. Either char is a 0 or it's empty COLON
FIND_END:    
    CMP.B #0,(A6)   ; check if we are at end
    BEQ END_FOUND
    CMP.B #' ',(A6) ; check if we are at end
    BEQ END_FOUND
    ADDA.L #1,A6    ; keep searching 
    BRA FIND_END
    
END_FOUND:
    RTS
    
 *compare strings
CHECK_MATCH:     
    MOVEM.L A5/A6, -(SP) ;strings are in A5 and A6
    TST D0          ; length of input string is in D0.
    BEQ NO_MATCH     ; if string length is 0 they're not equal
    SUB.L #1,D0
FOR_C_IN_STRING:
    CMP.B (A5)+,(A6)+   ; compare characters byte by byte
    BNE NO_MATCH        ; byte not equal? string is not equal
    TST.W D0            ; compared all the characters in the string?
    DBEQ.W D0,FOR_C_IN_STRING    ;  DO AT MOST D0 COMPARISONS
    BRA MATCH            ; finshed comparing and strings are equal.
    
MATCH:
    MOVEM.L (SP)+, A5/A6  ;D0 will = 0, signifying a match
    RTS
NO_MATCH:
    MOVE.L #1,D0        ; return 1 to signify no match
    MOVEM.L (SP)+, A5/A6
    RTS
    

TRAPING_HOES:
    ADD.L #6,SP        
    MOVEM.L (A7)+,A0-A7/D0-D7
    RTS
    
    
ADDRESS_ERRORV:
    MOVEM.L A1/D0-D2, -(SP)
    MOVE.L #14,D0
    LEA ADDRESS_ER,A1  ;print ADDRESS:
    TRAP #15
    
    MOVE.B #16,D2
    MOVE.L #13,D0
    LEA NL,A1
    TRAP #15
    MOVE.L (26,A7),PC_STORE
    MOVE.W (24,A7),REG_STORE   ; get SR
    MOVEM.L (SP)+, A1/D0-D2
    BSR DF  ; Use Display registers to print out registers and content 
    ADD.L #14,SP     
    JMP SHELL

ILLEGAL_INSTRV:
    MOVEM.L A1/D0, -(SP)
    MOVE.L #13,D0
    LEA ILLEGAL_ER,A1   ; print iilegal instruction erorr
    TRAP #15
    MOVEM.L (SP)+, A1/D0
    MOVE.W (A7),REG_STORE   ; put sr in regstore
    MOVE.L (2,A7),PC_STORE
    BSR DF          
    ADD.L #6,SP     
    JMP SHELL
    
PRIVALEGEV:
    MOVEM.L A1/D0, -(SP)
    MOVE.L #13,D0
    LEA PRIVALAGE_ER,A1
    TRAP #15
    MOVEM.L (SP)+, A1/D0
    MOVE.W (A7),REG_STORE   
    MOVE.L (2,A7),PC_STORE
    BSR DF          
    ADD.L #6,SP     
    JMP SHELL

DIVIDE_ZEROV:
    MOVEM.L A1/D0, -(SP)
    MOVE.L #13,D0
    LEA DIVIDE_Z_ER,A1
    TRAP #15
    MOVEM.L (SP)+, A1/D0
    MOVE.W (A7),REG_STORE   
    MOVE.L (2,A7),PC_STORE
    BSR DF          
    ADD.L #6,SP     
    JMP SHELL
    
CHECK_INSTRV:
    MOVEM.L A1/D0, -(SP)
    MOVE.L #13,D0
    LEA CHECK_ER,A1
    TRAP #15
    MOVEM.L (SP)+, A1/D0
    MOVE.W (A7),REG_STORE   
    MOVE.L (2,A7),PC_STORE
    BSR DF          
    ADD.L #6,SP     
    JMP SHELL
  
LINEAV:
    MOVEM.L A1/D0, -(SP)
    MOVE.L #13,D0
    LEA LINEA_ER,A1
    TRAP #15
    MOVEM.L (SP)+, A1/D0
    MOVE.W (A7),REG_STORE   
    MOVE.L (2,A7),PC_STORE
    BSR DF          
    ADD.L #6,SP     
    JMP SHELL
    
LINEFV:
    MOVEM.L A1/D0, -(SP)
    MOVE.L #13,D0
    LEA LINEF_ER,A1
    TRAP #15
    MOVEM.L (SP)+, A1/D0
    MOVE.W (A7),REG_STORE   
    MOVE.L (2,A7),PC_STORE
    BSR DF          
    ADD.L #6,SP     
    JMP SHELL

    
    
* Parses arguments for a valid command.
COMMAND_PARSE:            
    MOVEM.L A1/A5/A6/D2-D7, -(SP)  
    CLR.L D0
    CLR.L D1
    MOVE.L #0, D2   
    CMP.B #$24,(A5)+ ;checking for $
    BNE PARSE_ERR
    MOVE.L A6,A1
    SUB.L A5,A1
    CMP.L #8,A1
    BGT PARSE_ERR
    
FOR_PARSE:
    CMP A5,A6       ; check if eat ennd of command
    BLE PARSE_DONE
    CLR.L D3        ; use D3 to check
    MOVE.B -(A6),D3
    CMP.B #'F',D3   ; bigger than 16 Hex?
    BGT PARSE_ERR
    CMP.B #'0',D3   ; negative
    BLT PARSE_ERR
    CMP.B #'9',D3
    BLE NUM_CHECK   ; WITHIN 0-9 OR A-F?
    CMP.B #'A',D3
    BGE HEX_CHECK
    BRA PARSE_ERR
    
NUM_CHECK:
    SUBI.B #$30,D3  
    LSL.L D2,D3
    OR.L D3,D0
    ADD.B #4,D2    
    BRA FOR_PARSE
    
HEX_CHECK:
    SUBI.B #55,D3 
    LSL.L D2,D3
    OR.L D3,D0
    ADD.B #4,D2     
    BRA FOR_PARSE
  
PARSE_ERR:
    ADDI.B #1,D1    
PARSE_DONE:
    MOVEM.L (SP)+, A1/A5/A6/D2-D7
    RTS
    
MDSP:                    
    MOVEM.L A0-A6/D0-D7,-(SP)
    CMP.L #0, A6
    BNE MD
    ADD.L #16, A6   ; if A6=0 add 16 to get the end address.
MD:
    MOVE.B #16,D2   ; base of number to display for trap function
    LEA ADDRESS,A1  ; ADDRESS prompt to print
    MOVE.B #14,D0
    TRAP #15        ;Display the NULL terminated string pointed to by (A1).
    MOVE.L A5,D1
    MOVE.B #15,D0   ;Display the unsigned number in D1.L converted to number base (2 through 36) contained in D2.B. 
    TRAP #15        
    LEA COLON,A1    ; put a COLON
    MOVE.B #14,D0
    TRAP #15        ; 
    CLR.L D1
    MOVE.B (A5)+,D1 ; move contents pointed to by A5 to D1 to display 
    MOVE.B #15,D0
    TRAP #15        ; display D1 contents (data)
    LEA NL,A1
    MOVE.B #13,D0
    TRAP #15        ; print empty space for new input
    CMP A5,A6       ; are we at address2?
    BGE MD          ; keep going if we're not
    MOVEM.L (SP)+,A0-A6/D0-D7
    RTS

    
MM:        
    MOVEM.L A0-A6/D0-D7,-(SP)
    CMP #1, D7
    BEQ MM_WORD
    CMP #2, D7
    BEQ MM_LONG
    
MM_BYTE:        
    SUBA.L #1, A0    
BLOOP:    
    MOVE.B #16,D2   
    ADDA #1, A0     ; increment to the next Bbyte 
    LEA ADDRESS,A1  
    MOVE.B #14,D0   ; address
    TRAP #15
    MOVE.L A0,D1
    MOVE.B #15,D0   
    TRAP #15
    LEA COLON,A1
    MOVE.B #14,D0
    TRAP #15
    CLR.L D1
    MOVE.B (A0),D1  ; moving data to D1
    MOVE.B #15,D0   ; printing data
    TRAP #15        
    LEA COLON,A1
    MOVE.B #14,D0   
    TRAP #15
    LEA INPUT,A1
    MOVE.B #2,D0    ; waiting for user input
    TRAP #15
    CMP.W #0,D1     ; if enter was hit, and not input. Restart
    BEQ BLOOP
    CMP.B #$2E,(A1)   ; if we get a period, finish.
    BEQ MM_EXIT
    CMP.W #3,D1          
    BNE MMERR       ; print an error if we get incorret number of charcters
    LEA INPUT,A5
    LEA INPUT,A6
    ADDA D1,A6
    BSR COMMAND_PARSE
    TST D1
    BNE MMERR       
    MOVE.B D0,(A0)  
    BRA BLOOP
    
MM_WORD:           
    SUBA.L #2, A0    
MMWLOOP:    
    MOVE.B #16,D2   ; setting base number to print from
    ADDA #2, A0     ; increment to the next wORD
    LEA ADDRESS,A1  
    MOVE.B #14,D0   
    TRAP #15
    MOVE.L A0,D1
    MOVE.B #15,D0   
    TRAP #15        ; print address
    LEA COLON,A1    
    MOVE.B #14,D0
    TRAP #15
    CLR.L D1
    MOVE.W (A0),D1  ; moving data pointed to by A1 to D1 for printing
    MOVE.B #15,D0
    TRAP #15        ; print current data at this address
    LEA COLON,A1
    MOVE.B #14,D0   
    TRAP #15
    LEA INPUT,A1
    MOVE.B #2,D0    ; wait for input from user
    TRAP #15
    CMP.W #0,D1     ; if enter was hit, and not input. Restart
    BEQ MMWLOOP
    CMP.B #$2E,(A1)   ; if we get a period, finish
    BEQ MM_EXIT
    CMP.W #5,D1       ; 4 character comparison   
    BNE MMERR
    LEA INPUT,A5
    LEA INPUT,A6
    ADDA D1,A6
    BSR COMMAND_PARSE
    TST D1
    BNE MMERR      
    MOVE.W D0,(A0)  ; Move data
    BRA MMWLOOP

MM_LONG:             ;BYTE SIZE MM
    SUBA.L #4, A0     ; SUBTRACT JUST THE FIRST TIME
MMLLOOP:    
    MOVE.B #16,D2   
    ADDA #4, A0     
    LEA ADDRESS,A1  
    MOVE.B #14,D0   
    TRAP #15
    MOVE.L A0,D1
    MOVE.B #15,D0   
    TRAP #15
    LEA COLON,A1    
    MOVE.B #14,D0
    TRAP #15
    CLR.L D1
    MOVE.L (A0),D1  
    MOVE.B #15,D0
    TRAP #15        
    LEA COLON,A1
    MOVE.B #14,D0   
    TRAP #15
    LEA INPUT,A1
    MOVE.B #2,D0    
    TRAP #15
    CMP.W #0,D1     
    BEQ MMLLOOP
    CMP.B #$2E,(A1)   
    BEQ MM_EXIT
    CMP.W #9,D1         
    BNE MMERR
    LEA INPUT,A5
    LEA INPUT,A6
    ADDA D1,A6
    BSR COMMAND_PARSE
    TST D1
    BNE MMERR       
    MOVE.L D0,(A0)  
    BRA MMLLOOP

MMERR:
   BSR MMHELP
MM_EXIT:
   MOVEM.L (SP)+, A0-A6/D0-D7
   RTS


BMOV:                      
   MOVEM.L A5/A6/D0,-(SP)
   SUBI.L #1,D0        ; D0 has count of data to move
BMOV_LOOP:  
   MOVE.B (A5)+,(A6)+  ; move contents from location in A5 to A6
   DBEQ D0,BMOV_LOOP
   BRA BMOV_EXIT
         
BMOV_EXIT:         
   MOVEM.L (SP)+,A5/A6/D0
   RTS   
        

    
BF:                      
   MOVEM.L A5,-(SP)
BF_LOOP:  
   MOVE.W D0,(A5)+  ; fill memory location with data in D0
   CMP A5,A6        ; keep going until we hit address2
   BGT BF_LOOP
   MOVEM.L (SP)+,A5
   RTS
         

  
           
GO:                     
   MOVEM.L A1/D0-D2, -(SP) 
   LEA GO_ADDRESS,A1       ; print address
   MOVE.B #14,D0
   TRAP #15
   MOVE.B #15,D0
   MOVE.L REG_STORE,D1
   MOVE.B #16,D2      ;convert to ascii
   TRAP #15
   LEA NL,A1
   MOVE.B #13,D0
   TRAP #15
   MOVEM.L (SP)+, A1/D0-D2
   MOVE.L REG_STORE, -(SP) 
   RTS                ; be able to retunrn after
          

*sorting algorithm. DO holds value for ascending or descending         
SORTW:
   MOVEM.L A2/A5-A6/D1, -(SP)
   MOVE.L A5,A2         ; address1
   
** for i in range(1,n):
**      for j in range():
SORTW_FOR_I:
   MOVE.L A2,A5
SORTW_FOR_J:
   TST.B D0             ;check for order first
   BEQ DESC             
   CMP.W (A5)+,(A5)+    ; start compare of elements
   BHI.S SWAP           ; if the value is higher, branch to swap elements       
   BRA SORTW_NEXT
DESC:
   CMP.W (A5)+,(A5)+    ; Compare current and next elements
   BLO.S SWAP          
SORTW_NEXT:
   SUBQ.L #2,A5         
   CMP.L A5,A6
   BNE SORTW_FOR_J            ; Did we reach end of string? keep going if no
   BRA SORTW_EXIT
SWAP:
   MOVE.L -(A5),D1      ; get back to start of comaparison and put the two values in D1. eg. D1=11112222
   SWAP.W D1            ; swap the word val. D1=22221111
   MOVE.L D1,(A5)       ; move the values back into memory
   BRA SORTW_FOR_I      ; restart for loop after a swap
   
SORTW_EXIT:  
   MOVEM.L (SP)+, A2/A5-A6/D1
   RTS
   
   
DF: 
                       
    MOVEM.L A0-A7/D0-D7,-(A7)
    MOVE.L A7,A0
    
    *DO*
    LEA D0REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0
    TRAP #15
    MOVE.L (A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15

    *D1*
    LEA D1REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (4,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15

    
    *D2*
    LEA D2REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (8,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15


    *D3*
    LEA D3REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (12,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    
    *D4*
    LEA D4REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (16,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    
    *D5*
    LEA D5REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (20,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    
    *D6*
    LEA D6REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (24,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    
    *D7*
    LEA D7REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (28,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    
    *A0*
    LEA A0REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (32,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    
    *A1*
    LEA A1REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (36,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    
    *A2*
    LEA A2REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (40,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    
    *A3*
    LEA A3REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (44,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    
    *A4*
    LEA A4REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (48,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15

    *A5*
    LEA A5REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0
    TRAP #15
    MOVE.L (52,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    
    *A6*
    LEA A6REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (56,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15

    *A7*
    LEA A7REG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L (60,A0),D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15

    
    *PC*
    LEA PCREG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L PC_STORE,D1 ; get pc val
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    
    *SR*
    LEA SRREG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0
    TRAP #15
    CLR.L D1
    MOVE.W REG_STORE,D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15

    
    *USP*
    MOVE.W SR,D6
    BCLR #13,D6     
    MOVE.W D6,SR
    LEA USPREG, A1
    MOVE.B #16,D2
    MOVE.B #14, D0 
    TRAP #15
    MOVE.L A7,D1
    MOVE.B #15, D0
    TRAP #15
    MOVE.B #13, D0
    LEA NL,A1
    TRAP #15
    TRAP #1 
   
BSCH:
    MOVEM.L A0-A6/D0-D7, -(SP)
    MOVE.L A1,A2    ; address1 in A0, address2 in A1, String in A5
    SUB.L A0,A2     ; len of search space
    CMP.L A2,D3     ; if smaller than string no match
    BGT NO_MATCH_BSCH   ;d3 Hhas len
    MOVE.L A1,A2
    SUB.L D3,A2
FOR_C_IN_SPACE:
    MOVE.L A0,A6    ; address1
    MOVE.W D3,D0    ; len
    BSR CHECK_MATCH
    TST.B D0
    BEQ FOUND
    ADD.L #1,A0    ; c += 1
    CMP.L A2,A0
    BGT NO_MATCH_BSCH    ;reached end, not found
    BRA FOR_C_IN_SPACE
    
NO_MATCH_BSCH:
    LEA NO_STRING_MATCH,A1       
    MOVE.B #13,D0
    TRAP #15
    MOVEM.L (SP)+,A0-A6/D0-D7
    RTS
FOUND:
    LEA STRING_MATCH,A1       ; print found text
    MOVE.B #13,D0
    TRAP #15
    LEA ADDRESS,A1  
    MOVE.B #14,D0   
    TRAP #15
    MOVE.L A0,D1
    MOVE.B #16,D2   
    MOVE.B #15,D0   
    TRAP #15
    LEA COLON,A1    
    MOVE.B #14,D0
    TRAP #15
    MOVE.L A0,A1    
    MOVE.B #0,D0
    MOVE.W D3,D1
    TRAP #15                  
    MOVEM.L (SP)+,A0-A6/D0-D7
    RTS

      
    
    ORG $6000       ; Go
    MOVE.L #13,D0
    LEA USERPROGRAM,A1
    TRAP #15
    BRA SHELL 
    
    *technically all these use go
    ORG $6010
    DC.W $F000      ; Line F emulator
    BRA SHELL
    
    ORG $6020
    DC.W $A000      ; Line A emulator
    BRA SHELL
    
    ORG $6030       ; Illegal instruciton
    DC.W $4AFA          
    BRA SHELL
    
    ORG $6040       ; divide by zero
    MOVE.L #1,D0  
    MOVE.L #0,D1
    DIVU.W D1,D0
    BRA SHELL

    ORG $6050
    MOVE.W #1,D0   ; check instruction
    CLR.W D1
    CHK.W D1,D0
    BRA SHELL
    
    ORG $6060
    ANDI.W #$00FF,SR    ;privelage error
    OR.W #$1000, SR     
    BRA SHELL
    
    END START
    










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
