   ORG  00H 
   RS  EQU P3.5 
   RW  EQU P3.6 
   E  EQU P3.7 
   MPIN1 EQU P3.0
   MPIN2 EQU P3.1
   GLED EQU P3.2
   YLED EQU P3.3
   RLED EQU P3.4
   MOV P1, #0C0H
   MOV  PSW, #00H 
   MOV R2, #0   ;COUNTS INCORRECT PASSWORD 
   
   CLR MPIN1 
   CLR MPIN2
   
INITIALIZE:     
   MOV R0, #60H ;PASSWORD LOCATION
   MOV R1, #50H	;GIVEN PASSWORD	
   
   ;MOV R3, #0
   MOV R5, #0   ;COUNTS DIGIT MISMATCH
   MOV R6, #4   ;COUNTS 4 DIGIT PASSWORD
   ;MOV R7, #0
  
   MOV 60H, #'1'
   MOV 61H, #'3'
   MOV 62H, #'5'
   MOV 63H, #'7'
   
   CLR GLED
   CLR YLED
   CLR RLED
   
LCD_IN:  
   MOV DPTR,#LCD
DISPLAY_ON:
   CLR A
   MOVC A,@A+DPTR
   LCALL COMNWRT
   LCALL DELAY
   JZ S1  
   INC DPTR
   SJMP DISPLAY_ON    
	
     
S1:
   JNB GLED, S2
   MOV DPTR, #MSG5
M5:
   CLR A
   MOVC A, @A+DPTR
   JZ M51
   ACALL DATAWRT
   ACALL DELAY
   INC DPTR
   SJMP M5
   
M51:
   MOV A, #0C0H
   ACALL COMNWRT
   ACALL DELAY
   MOV DPTR, #MSG6
M6:
   CLR A
   MOVC A, @A+DPTR
   CJNE A, #0, M61
   SJMP $
M61:   
   ACALL DATAWRT
   ACALL DELAY
   INC DPTR
   SJMP M6   
   
S2:
   JNB YLED, S3
S21:   
   MOV DPTR, #MSG5
M52:
   CLR A
   MOVC A, @A+DPTR
   JZ M53
   ACALL DATAWRT
   ACALL DELAY
   INC DPTR
   SJMP M52
   
M53:
   MOV A, #0C0H
   ACALL COMNWRT
   ACALL DELAY
   MOV DPTR, #MSG7
M7:
   CLR A
   MOVC A, @A+DPTR
   CJNE A, #0, M71
   SJMP $
M71:   
   ACALL DATAWRT
   ACALL DELAY
   INC DPTR
   SJMP M7

S3:
JB RLED, S21
        
   MOV DPTR, #MSG1
M1:
   CLR A
   MOVC A, @A+DPTR
   JZ K0
   ACALL DATAWRT
   ACALL DELAY
   INC DPTR
   SJMP M1
   
   
   		
K0: 
   SETB P2.0
   SETB P2.1
   SETB P2.2
   SETB P2.3  
K1:   
   CLR P2.4
   CLR P2.5
   CLR P2.6
   CLR P2.7
   MOV  A, P2    ;read all columns.ensure all keys open 
   ANL  A, #00001111B  ;mask unused bits 
   CJNE  A, #00001111B,K1  ;check till all keys released  
K2:  
   ACALL  DELAY   ;call 20ms delay 
   MOV  A, P2    ;see if any key is pressed 
   ANL  A, #00001111B  ;mask unused bits 
   CJNE   A, #00001111B, OVER ;key pressed, await closure 
   SJMP  K2    ;check is key pressed 
OVER:  
   ACALL  DELAY   ;wait 20ms debounce time 
   MOV  A, P2    ;check key closure 
   ANL  A, #00001111B  ;mask unused bits 
   CJNE  A, #00001111B, OVER1 ;key pressed, find row 
   SJMP  K2    ;if none, keep polling 
OVER1:  
   CLR P2.4
   SETB P2.5
   SETB P2.6
   SETB P2.7
   MOV  A, P2    ;read all columns 
   ANL  A, #00001111B  ;mask unused bits 
   CJNE  A, #00001111B, ROW_0 ;key row 0, find the column 
   SETB P2.4
   CLR P2.5
   SETB P2.6
   SETB P2.7
   MOV  A, P2    ;reall all columns 
   ANL  A, #00001111B  ;mask unused bits 
   CJNE  A, #00001111B, ROW_1 ;key row 1, find the column 
   SETB P2.4
   SETB P2.5
   CLR P2.6
   SETB P2.7   
   MOV  A, P2    ;read all columns 
   ANL  A, #00001111B  ;mask unused bits 
   CJNE  A, #00001111B, ROW_2 ;key row 2, find column 
   SETB P2.4
   SETB P2.5
   SETB P2.6
   CLR P2.7
   MOV  A, P2    ;read all columns 
   ANL  A, #00001111B  ;mask unused bits 
   CJNE  A, #00001111B, ROW_3 ;key row 3, find column 
   LJMP  K2     ;if none, false input, repeat 
ROW_0:  
   MOV  DPTR,  #KCODE0  ;set DPTR=start of row 0 
   SJMP  FIND    ;find column.key belongs to 
ROW_1:   
   MOV  DPTR, #KCODE1  ;set DPTR=start of row 1 
   SJMP  FIND    ;find column.key belongs to 
ROW_2:  
   MOV  DPTR, #KCODE2  ;set DPTR=start of row 2 
   SJMP  FIND    ;find column.key belongs to 
ROW_3:  
   MOV  DPTR, #KCODE3  ;set DPTR=start of row 3 
FIND:  
   RRC  A    ;see if any CY bit is low 
   JNC  MATCH   ;if zero, get the ASCII code 
   INC  DPTR    ;point to the next column address 
   SJMP  FIND    ;keep searching 
MATCH: 
   CLR  A    ;set A=0 (match found) 
   MOVC  A, @A+DPTR  ;get ASCII code from table 
   
   
   MOV @R1, A
   
   MOV A, #'*'
   ACALL DATAWRT   ;call display subroutine 
   ACALL  DELAY   ;give LCD some time
   ;SJMP K0 ;TAKES NEXT INPUT PRINT

   MOV A, @R1
   ACALL DATAWRT   ;call display subroutine 
   ACALL  DELAY   ;give LCD some time
   
   MOV B, @R0
   ;MOVC A, @A+DPTR
   CJNE A, B, L
   INC R5
L:
   INC R1
   INC R0
   DEC R6
   MOV A, R6
   CJNE A, #0, NEX
   SJMP NEXTT

NEX:
   LJMP K0  
    
NEXTT:
   MOV A, #0C0H
   ACALL COMNWRT
   ACALL DELAY
   MOV A, R5
   CJNE A, #4, CE
   MOV DPTR, #MSG2
   SETB GLED
   SETB MPIN1 
   CLR MPIN2
M2:
   CLR A
   MOVC A, @A+DPTR
   CJNE A, #0, M21
   LJMP LCD_IN
M21:   
   ACALL DATAWRT
   ACALL DELAY
   INC DPTR
   SJMP M2
   
CE:
   MOV A, R5
   CJNE A, #3, IC
   MOV DPTR, #MSG3
   SETB YLED
M3:
   CLR A
   MOVC A, @A+DPTR
   JZ FINIC
   ACALL DATAWRT
   ACALL DELAY
   INC DPTR
   SJMP M3
   
IC:  
   MOV DPTR, #MSG4
   SETB RLED
M4:
   CLR A
   MOVC A, @A+DPTR
   JZ FINIC
   ACALL DATAWRT
   ACALL DELAY
   INC DPTR
   SJMP M4


FINIC: 
   INC R2
   MOV A, R2
   CJNE A, #1, FIN1
   MOV P1, #0F9H
   LJMP INITIALIZE
FIN1:   
   CJNE A, #2, FIN2
   MOV P1, #0A4H
   LJMP INITIALIZE  
FIN2:   
   MOV P1, #0B0H
   SETB MPIN2 
   CLR MPIN1
   LJMP LCD_IN

   
FIN3:  
   LJMP INITIALIZE
   
   
   
   ;DJNZ R6, K0 ;LOOPS R6 TIMES BUT AFTER THAT LCD AGAIN AT FIRST POSITION
   
   ;CLR A
   

   
COMNWRT: 
   LCALL READY   ;send command to LCD 
   MOV  P0, A    ;copy reg A to port 1 
   CLR  RS    ;RS=0 for command 
   CLR  RW    ;R/W=0 for write 
   SETB  E    ;E-1 for high pulse  
   ACALL DELAY   ;give LCD some time 
   CLR  E    ;E=0 for H-to-L pulse 
   RET 

 
DATAWRT: 
   LCALL READY   ;write data to LCD 
   MOV  P0, A    ;copy reg A to port1 
   SETB  RS    ;RS=1 for data 
   CLR  RW    ;R/W=0 for write 
   SETB  E    ;E=1 for high pulse 
   ACALL DELAY   ;give LCD some time 
   CLR  E    ;E=0 for H-to-L pulse 
   RET 
   
READY:  
   SETB  P0.7 
   CLR  RS 
   SETB  RW 
WAIT:  
   CLR  E 
   LCALL DELAY 
   SETB  E 
   JB  P0.7, WAIT 
   RET 
 
DELAY:  MOV  R3, #50   ;50 or higher for fast CPUs 
HERE2:  MOV  R4, #255   ;R4=255 
HERE:   DJNZ  R4, HERE   ;stay untill R4 becomes 0 
        DJNZ   R3, HERE2 
        RET 

ORG 300H
;ASCII LOOK-UP TABLE FOR EACH ROW  
KCODE0: DB '1','2','3','A'    ;ROW 0 
KCODE1: DB '4','5','6','B'    ;ROW 1 
KCODE2: DB '7','8','9','C'    ;ROW 2 
KCODE3: DB '*','0','#','D'    ;ROW 3
ORG 400H
MSG1: DB 'PASS:', 0
MSG2: DB 'CORRECT PASS', 0
MSG3: DB 'CLOSE ENOUGH', 0
MSG4: DB 'INCORRECT PASS', 0
MSG5: DB 'MOTOR ROTATING', 0
MSG6: DB 'IN CLOCKWISE', 0
MSG7: DB 'IN ANTICLOCKWISE', 0
LCD : DB 38H,0EH,01,06,80H,0

   END 