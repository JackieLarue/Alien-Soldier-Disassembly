; Custom decompression routine
; Called from cmd2 and cmd3 (so data stream already in A1)
;
; Decompresses into ram b400, where it is ready for compacting and sending to ram/vram
'
; inputs:
;	A1 			- data stream
; input+output:
;	F730 - number of bits remaining in data to process (saved version of D2)
;	F732 - outstanding data to process (saved version of D3)
; outputs:
;	128 bytes written to B400..B480
;
; register usage:
;	A5 - pointer to output buffer write position
;	A4 - pointer to end of output buffer
;
;	D2 - how many unprocessed bits currently in registers
;	D3 - current input word
;	D4 - holds data before being written to output
;	D6 - write loop counter (also offset to output buffer)
;	D7 - general purpose working bits
;
decompress_sub_loc_00002712:
	MOVEM.l	A5/A4/D7/D6/D5/D4/D3/D2, -(SP)	; save register state
	MOVE.w	$FFFFF730.w, D2	; restore any saved decompression state
	MOVE.w	$FFFFF732.w, D3
	LEA	$FFFFB400.w, A5 ; pointer to start of output buffer
	LEA	$80(A5), A4	; A4 holds pointer to end of output buffer (ie. B400 + 128 bytes, B480).
					; Used to check if we filled the buffer yet.
@repeat_all_00002726:	
								; top prep
	SUBQ.w	#5, D2				
	BGT.w	@top_prep_A_00002754
	BEQ.w	@top_prep_B_00002748
								; fall through to top prep C
	MOVE.w	D2, D7						
	ADDQ.w	#5, D2
	LSL.l	D2, D3
	MOVE.w	(A1)+, D3	; read data stream
	NEG.w	D7
	LSL.l	D7, D3
	ADDI.w	#$000B, D2
	MOVE.l	D3, D7
	SWAP	D7
	BRA.w	@common_top_prep_00002758
@top_prep_B_00002748:
	MOVEQ	#$10, D2
	ROL.w	#5, D3
	MOVE.w	D3, D7
	MOVE.w	(A1)+, D3	; read data stream
	BRA.w	@common_top_prep_00002758
@top_prep_A_00002754:		
	ROL.w	#5, D3			
	MOVE.w	D3, D7			
@common_top_prep_00002758:
	ANDI.w	#$001F, D7		; mask off bottom 5 bits
	LSR.w	#1, D7			; shift right 1
	BCS.w	@pre_inner_loop_00002770	; branch carry set? carry set if bit shifted out was 1
										; ie. Did we shunt a 1 out?
								; Direct Write Nibble
								; we're skipping the inner loop
								; so do inner loop replacement code
@_DirectWrite_00002762:
	MOVE.w	D7, D4
	MOVE.w	D4, (A5)+	; WRITE output word and advance
	MOVE.w	D4, D5
	ORI.w	#$8000, D5	; set 15th bit
	BRA.w	@prep_for_shunt_loop_000027F6 ; skip inner loop and go straight to shunting
	
@pre_inner_loop_00002770:
	MOVE.w	D7, D4
	MOVE.w	D4, (A5)+	; WRITE output and advance
	MOVE.w	D4, D5
	BSET.l	#$0F, D5
	MOVEQ	#0, D6
	
; inner decode loop?
@innerLoop:
	SUBQ.w	#2, D2
	BGT.w	@inner_branch_A_000027A2
	BEQ.w	@inner_branch_B_00002796
								; fall through to inner branch C
								; need 2 bits, but only have 1 in register D3
	MOVEQ	#$F, D2		; valid bits will becomes 16
	ADD.w	D3, D3		; 
	MOVE.w	(A1)+, D3	; read data stream
	ADDX.w	D3, D3		; shift top bit off the end of the word
	MOVE.w	D3, D7
	ADDX.w	D7, D7
	BRA.w	@after_inner_branch_000027A6
@inner_branch_B_00002796:		; inner branch B
	MOVEQ	#$10, D2
	ROL.w	#2, D3
	MOVE.w	D3, D7
	MOVE.w	(A1)+, D3		; read data stream
	BRA.w	@after_inner_branch_000027A6
@inner_branch_A_000027A2:		; inner branch A
	ROL.w	#2, D3
	MOVE.w	D3, D7
@after_inner_branch_000027A6:
	ANDI.w	#3, D7
	BEQ.w	@inner_continues_000027BA
	
	; write ahead method 1
@_write_ahead_1_marker_000027AE ; just a dummy for a breakpoint
	ADDQ.w	#6, D7		
	ADD.w	D7, D7
	ADD.w	D7, D6				; add to write offset
	MOVE.w	D5, -$2(A5,D6.w)	; WRITE D5 to write head with offset
	BRA.b	@innerLoop
	
@inner_continues_000027BA:	; jmp here if D7 is zero
	SUBQ.w	#1, D2
	BNE.w	@unknown_skip_000027C8
							; inner reinit
	MOVEQ	#$10, D2
	ADD.w	D3, D3
	MOVE.w	(A1)+, D3		; read data stream
	ROXR.w	#1, D3
@unknown_skip_000027C8:
	ADDX.w	D3, D3
	BCC.w	@prep_for_shunt_loop_000027F6	; exit inner loop
	SUBQ.w	#1, D2
	BNE.w	@unknown_skip_000027DC
							; re-read before write ahead
	MOVEQ	#$10, D2
	ADD.w	D3, D3			
	MOVE.w	(A1)+, D3		; read data stream
	ROXR.w	#1, D3			; now shunt Xtend flag back in
@unknown_skip_000027DC:
	ADDX.w	D3, D3
	BCS.w	@write_ahead_3_000027EC
	
	; write ahead method 2
@_write_ahead_2_marker_000027E2 ; just a dummy for a breakpoint
	ADDI.w	#$C, D6
	MOVE.w	D5, -$2(A5,D6.w)	; WRITE D5 to write head with offset
	BRA.b	@innerLoop
	
	; write ahead method 3
@write_ahead_3_000027EC:
	ADDI.w	#$14, D6
	MOVE.w	D5, -$2(A5,D6.w)	; WRITE D5 to write head with offset
	BRA.b	@innerLoop	; end of inner loop
	
@prep_for_shunt_loop_000027F6: ; 1st arrives here
	MOVEQ	#0, D7
	MOVEQ	#1, D6
									; -------- shunt loop --------
									; look for runs of bits set ie 111100 loops 4 times
									; and outputs D7+4, D6=1,2,4,8,16,32,64,etc.
@shunt_loop_000027FA:
	ADDQ.w	#1, D7		
	ADD.w	D6, D6		
	SUBQ.w	#1, D2		
	BNE.w	@has_more_bits_00002816	; is counter >0?
									; ie. are there still bits left?
									; branch-not-equal (branch if Zero flag clear)
							; fall through here when D2 counter just decremented to 0
	MOVEQ	#$10, D2
	ADD.w	D3, D3			; shunt D3
	BCC.w	@read_input_then_exit_shunt_00002810	; did we just shunt 0?
									; branch-if-carry-clear
									; ie. branch if we shunted 0
	MOVE.w	(A1)+, D3		; READ data stream
	BRA.b	@shunt_loop_000027FA	
	
@read_input_then_exit_shunt_00002810:
	MOVE.w	(A1)+, D3		; READ data stream
	BRA.w	@after_shunt_loop_0000281A					; EXIT SHUNT LOOP
	
@has_more_bits_00002816:	; more bits to process
	ADD.w	D3, D3	; shunt D3
	BCS.b	@shunt_loop_000027FA ; Did we just shunt out a 1?
								 
									; -------- end shunt loop --------
									
							; Prep for write
							; has three paths, A, B, C, plus common finish
@after_shunt_loop_0000281A:	
	SUB.w	D7, D2
	BGT.w	@write_prep_A_00002850 	; is D2>D7?
	BEQ.w	@write_prep_B_00002840
					; fall through to write prep C
	SWAP	D3			; clear upper word of D3
	CLR.w	D3			
	SWAP	D3			
	ADD.w	D7, D2
	LSL.l	D2, D3
	MOVE.w	(A1)+, D3		; read data stream
	SUB.w	D2, D7
	LSL.l	D7, D3
	MOVEQ	#$00000010, D2
	SUB.w	D7, D2
	MOVE.l	D3, D7
	SWAP	D7
	BRA.w	@unknown_skip_0000285A
@write_prep_B_00002840:
	MOVEQ	#$00000010, D2
	SWAP	D3
	CLR.w	D3
	ROL.l	D7, D3
	MOVE.w	D3, D7
	MOVE.w	(A1)+, D3		; read data stream
	BRA.w	@unknown_skip_0000285A
@write_prep_A_00002850: ; 
	SWAP	D3 		
	CLR.w	D3 		
	ROL.l	D7, D3	
	MOVE.w	D3, D7	
	SWAP	D3
@unknown_skip_0000285A:		; finish write prep
	ADD.w	D7, D6 
	SUBQ.w	#3, D6
@_dummy_check_if_should_write_loop_0000285E
	BCS.w	@check_if_buffer_full_00002872	; ie. branch if D6>0
									
								; -------- write loop --------
							; takes the last-written word of the output buffer
							; and repeats that D6 times
							; if bit 15 of current output set, then start writing that instead
							; and clear bit 15
							
@write_loop_00002862:		; when we reach write loop, D6 tells us how many times to repeat
							;
	MOVE.w	(A5), D7		; peek head of output buffer
							
	BPL.w	@unknown_skip_0000286C	; if bit 15 set, then skip ahead
	MOVE.w	D7, D5
	MOVE.b	D5, D4			; write lower byte of output to D4 before full D4.w is output	
@unknown_skip_0000286C:
	MOVE.w	D4, (A5)+		; WRITE D4 to output buffer
	DBF	D6, @write_loop_00002862	; and repeat write loop
							; fall out here when write loop done
							
								; -------- end write loop --------
							
@check_if_buffer_full_00002872:
	CMPA.l	A4, A5					; check current write pointer with address of end of buffer
	BCS.w	@repeat_all_00002726	; if not filled buffer, repeat
									; for first pattern, buffer is full first time around
							
	MOVE.w	D2, $FFFFF730.w	; save decompression state
	MOVE.w	D3, $FFFFF732.w ; save decompression state
	MOVEM.l	(SP)+, D2/D3/D4/D5/D6/D7/A4/A5	; restore register state
	RTS
	