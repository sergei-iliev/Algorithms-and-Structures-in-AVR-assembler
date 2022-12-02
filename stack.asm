/*
8/16 stack


8 bit  memory structure
1.byte - index to next free 1 byte slot,starts from 0 index
N size byte array (each element 1 byte long)
N < 256 size byte array (each element 1 byte long)

16 bit memory structure
2.byte - index to next free 2 byte slot, starts from 0 index
N size byte array (each element 2 bytes long)
0<N < 2^16  size byte array (each element 2 byte long MSB:LSB order)

*/
.def    argument=r17
.def    return=r18
.def    counter=r19  

.def	axl=r20
.def	axh=r21

.def	bxl=r22
.def	bxh=r23

.def	cxl=r14
.def	cxh=r15


.cseg
/************************************************************8 bit Stack********************************************/

/**********Init stack***********
@INPUT: X stack pointer
@USAGE: temp
		
**********************/
stack8_init:    
    clr temp
	st X,temp	     
ret
/*********Read current filled/occupied size*******
@INPUT: X stack pointer 
@OUTPUT: return - size of stack

*/
stack8_size:
  ld return,X	;first byte in structure is index      
ret
/*********Push item*******
@INPUT: X - stack pointer
        argument - item
		counter - stack max size
@USAGE: Y,return,temp
@OUTPUT: T flag for success
*/
stack8_push:
  clt
  ld temp,X  
  cp temp,counter
  brlo qenq_0
  set	;insufficient space
ret
qenq_0:
  clr return    
  mov YL,XL
  mov YH,XH
  ;bypass index byte
  adiw Y,1
  ADD16 YL,YH,temp,return
  
  st Y,argument  ;store item
  
  inc temp
  st X,temp   ;increment index  
ret

/*********Pop item*******
@INPUT: X - stack pointer
@USAGE: Y,return,tepm
@OUTPUT:   return 
           T flag for success
*/
stack8_pop:
  clt
  ld temp,X  
  cpi temp,0
  brne qdeq_0
  set	;empty space
ret
qdeq_0:
  clr return
  dec temp	;position to previous slot that will become empty
  
  mov YL,XL
  mov YH,XH
    ;bypass index byte
  adiw Y,1

  ADD16 YL,YH,temp,return
  
  ld return,Y  ;read item 
  st X,temp   ;decremented index  
ret


/**********************************************************************16 bit Stack*****************************************************/

/**********Init 16 bit stack***********
@INPUT: X stack pointer
@USAGE: temp		
*/
stack16_init:    
    clr temp
	st X+,temp
	st X,temp	     
ret
/*********Read current filled/occupied size*******
@INPUT: X stack pointer 
@OUTPUT: cx - current index(size) of stack
*/
stack16_size:
  ld cxh,X+	;first byte in structure is index      
  ld cxl,X
ret
/*********Push item*******
@INPUT: X - stack pointer
        ax - item
		cx - stack max size
@USAGE: Y,bx
@OUTPUT: T flag for success
*/
stack16_push:
  clt
  mov YL,XL
  mov YH,XH

  ld bxh,Y+
  ld bxl,Y
  CP16 bxl,bxh,cxl,cxh
  brlo qenq16_0
  set	;insufficient space
ret
qenq16_0:
  
  ;bypass index byte
  mov YL,XL
  mov YH,XH
  adiw Y,2

  LSL16 bxh,bxl    ;multiply by 2 ->dealing with 2 bytes/word content
  ADD16 YL,YH,bxl,bxh
  
  st Y+,axh  ;store item MSB:LSB
  st Y,axl

  ;increment index  	
  mov YL,XL
  mov YH,XH

  ld bxh,Y+
  ld bxl,Y

  ADDI16 bxl,bxh,1
  ;store  
  st X+,bxh   
  st X,bxl
  
ret

/*********Pop item*******
@INPUT: X - stack pointer		
@USAGE: Y,bx,temp
@OUTPUT: ax
         T flag for success
*/

stack16_pop:
	clt
	mov YL,XL
	mov YH,XH

	ld bxh,Y+
    ld bxl,Y
	CPI16 bxl,bxh,temp,0
	brne qdeq16_0
	set	;empty space
ret
qdeq16_0:
	
	;position to previous slot that will become empty
	SUBI16 bxl,bxh,1

	mov YL,XL
	mov YH,XH
	adiw Y,2

	LSL16 bxh,bxl    ;multiply by 2 ->dealing with 2 bytes/word content
    ADD16 YL,YH,bxl,bxh
  
	ld axh,Y+ ;load item MSB:LSB
	ld axl,Y
	
  ;decrement index  	
	mov YL,XL
	mov YH,XH

	ld bxh,Y+
	ld bxl,Y

	SUBI16 bxl,bxh,1
	;store  
	st X+,bxh   
	st X,bxl

ret

/*********Peek current item without poping*******
@INPUT: X - stack pointer		
@USAGE: Y,bx,temp
@OUTPUT: ax
         T flag for success
*/
stack16_peek:
	clt
	mov YL,XL
	mov YH,XH

	ld bxh,Y+
    ld bxl,Y
	CPI16 bxl,bxh,temp,0
	brne qpeek16_0
	set	;empty space
ret
qpeek16_0:
	;position to begining of array
	mov YL,XL
	mov YH,XH
	adiw Y,2

	SUBI16 bxl,bxh,1	;position to current filled-in slot

	LSL16 bxh,bxl    ;multiply by 2 ->dealing with 2 bytes/word content
    ADD16 YL,YH,bxl,bxh

	ld axh,Y+ ;load item MSB:LSB
	ld axl,Y

ret