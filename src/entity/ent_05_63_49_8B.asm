sub_18986:                              ; CODE XREF: update_ent_63+30   j update_ent_63+3A   j ...
                bset    #4,2(a5)
                rts
; End of function sub_18986
update_ent_05:                          ; DATA XREF: ROM:ent_update_fns   o
                bclr    #7,CRTL_UNK22(a5)
                bne.s   jump0
                bclr    #6,CRTL_UNK23(a5)
                beq.s   jump1
                bclr    #4,CRTL_UNK23(a5)
                bne.s   jump2
jump0:                                  ; CODE XREF: update_ent_05+6   j
                movea.l #word_1B514,a1
                move.w  (RAND_NUM).w,d0
                andi.w  #$1FE,d0
                move.w  -$80(a1,d0.w),d1
                move.w  (a1,d0.w),d2
                ext.l   d1
                ext.l   d2
                asl.l   #4,d1
                asl.l   #4,d2
                move.l  d1,CRTL_YSPD(a5)
                move.l  d2,CRTL_XSPD(a5)
                lea     (word_2AE8A).l,a1
                jsr     (update_ent_61_0xA4).l
                move.w  #$8C80,CRTL_UNK2(a5)
                rts
; ---------------------------------------------------------------------------
jump1:                                  ; CODE XREF: update_ent_05+E   j
                subq.w  #1,CRTL_UNK5E(a5)
                bpl.s   end
                clr.b   CRTL_UNK21(a5)
                move.l  CRTL_XSPD(a5),d0
                asr.l   #1,d0
                move.l  d0,CRTL_XSPD(a5)
                move.l  CRTL_YSPD(a5),d0
                asr.l   #1,d0
                move.l  d0,CRTL_YSPD(a5)
                lea     (word_2AD16).l,a1
                jmp     update_ent_61_0xA4
; ---------------------------------------------------------------------------
end:                                    ; CODE XREF: update_ent_05+56   j
                rts
; ---------------------------------------------------------------------------
jump2:                                  ; CODE XREF: update_ent_05+16   j
                move.l  #word_1805C,CRTL_UNK4A(a5)
                move.w  #$456C,d0
                add.w   (SPRITE_FLAGS_808A).w,d0
                move.w  d0,CRTL_SPRITE_FLAGS(a5)
                move.w  #$F00,CRTL_SPRITE_PTR(a5)
                move.w  #$F0F0,CRTL_SPRITE_XOFF(a5)
loc_18A2C:                              ; CODE XREF: update_ent_49+4C   j update_ent_8B+9E   j
                move.w  #$18C,(a5)
                move.w  #$8C80,CRTL_UNK2(a5)
                clr.b   CRTL_UNK21(a5)
                lea     dword_19632(pc),a1
                nop
                move.w  (RAND_NUM).w,d6
                andi.w  #$7C,d6 ; '|'
                move.l  (a1,d6.w),d0
                move.l  $20(a1,d6.w),d1
                asr.l   #1,d0
                asr.l   #1,d1
                move.l  d0,CRTL_YSPD(a5)
                move.l  d1,CRTL_XSPD(a5)
                move.b  #$C8,d0
                jmp     (play_sfx_id_2).l
; End of function update_ent_05
update_ent_63:                          ; DATA XREF: ROM:ent_update_fns   o
                move.w  CRTL_UNK48(a5),d0
                addq.w  #2,d0
                andi.w  #$E,d0
                move.w  d0,CRTL_UNK48(a5)
                movea.l CRTL_UNK4A(a5),a0
                move.w  (a0,d0.w),d1
                or.w    (SPRITE_FLAGS_808A).w,d1
                move.w  d1,CRTL_SPRITE_FLAGS(a5)
                move.w  $10(a0,d0.w),CRTL_SPRITE_PTR(a5)
                move.w  $20(a0,d0.w),CRTL_SPRITE_XOFF(a5)
                cmpi.w  #$80,CRTL_XPOS(a5)
                bmi.w   sub_18986
                cmpi.w  #$1C0,CRTL_XPOS(a5)
                bpl.w   sub_18986
                cmpi.w  #$A0,CRTL_YPOS(a5)
                bmi.w   sub_18986
                cmpi.w  #$160,CRTL_YPOS(a5)
                bpl.w   sub_18986
                btst    #0,(STAGE_STATE_UNK).w
                bne.s   end
                addi.l  #$4000,CRTL_YSPD(a5)
end:                                    ; CODE XREF: update_ent_63+58   j
                rts
; End of function update_ent_63
update_ent_49:                          ; DATA XREF: ROM:ent_update_fns   o
                bclr    #7,CRTL_UNK22(a5)
                bne.s   jump0
                bclr    #6,CRTL_UNK23(a5)
                beq.s   jump1
                bclr    #4,CRTL_UNK23(a5)
                bne.s   jump2
jump0:                                  ; CODE XREF: update_ent_49+6   j
                clr.l   CRTL_XSPD(a5)
                clr.l   CRTL_YSPD(a5)
                lea     (word_2ACA6).l,a1
                jmp     update_ent_61_0xA4
; ---------------------------------------------------------------------------
jump2:                                  ; CODE XREF: update_ent_49+16   j
                move.w  #$44D6,d0
                add.w   (SPRITE_FLAGS_808A).w,d0
                move.w  d0,CRTL_SPRITE_FLAGS(a5)
                move.w  #$A00,CRTL_SPRITE_PTR(a5)
                move.w  #$F4F4,CRTL_SPRITE_XOFF(a5)
                move.l  #word_1818E,CRTL_UNK4A(a5)
                bra.w   loc_18A2C
; ---------------------------------------------------------------------------
                jmp     update_ent_61_0xA4
; ---------------------------------------------------------------------------
jump1:                                  ; CODE XREF: update_ent_49+E   j
                subq.w  #1,CRTL_UNK48(a5)
                bmi.w   sub_18986
                rts
; End of function update_ent_49
update_ent_8B:                          ; DATA XREF: ROM:ent_update_fns   o
                bclr    #7,CRTL_UNK22(a5)
                bne.s   jump0
                bclr    #6,CRTL_UNK23(a5)
                beq.w   jump1
                bclr    #4,CRTL_UNK23(a5)
                bne.s   jump2
jump0:                                  ; CODE XREF: update_ent_8B+6   j
                tst.w   (force_UNK802C).w
                beq.s   jump3
                move.l  CRTL_XSPD(a5),d0
                asr.l   #3,d0
                move.l  d0,CRTL_XSPD(a5)
                move.l  CRTL_YSPD(a5),d0
                asr.l   #3,d0
                move.l  d0,CRTL_YSPD(a5)
                move.w  #$400,(a5)
                move.w  #$EC00,CRTL_UNK2(a5)
                move.w  #$480,d0
                or.w    (SPRITE_FLAGS_808A).w,d0
                move.w  d0,CRTL_SPRITE_FLAGS(a5)
                move.l  #stru_E9560,CRTL_SPRITE_PTR(a5)
                clr.w   CRTL_UNKC(a5)
                move.w  #5,$26(a5)
                tst.w   (DIFFICULTY).w
                bne.s   end
                move.w  #6,$26(a5)
end:                                    ; CODE XREF: update_ent_8B+60   j
                rts
; ---------------------------------------------------------------------------
jump3:                                  ; CODE XREF: update_ent_8B+1E   j
                clr.l   CRTL_XSPD(a5)
                clr.l   CRTL_YSPD(a5)
                lea     (word_2ACA6).l,a1
                jmp     update_ent_61_0xA4
; ---------------------------------------------------------------------------
jump2:                                  ; CODE XREF: update_ent_8B+18   j
                move.w  #$44D6,d0
                add.w   (SPRITE_FLAGS_808A).w,d0
                move.w  d0,CRTL_SPRITE_FLAGS(a5)
                move.w  #$A00,CRTL_SPRITE_PTR(a5)
                move.w  #$F4F4,CRTL_SPRITE_XOFF(a5)
                move.l  #word_1818E,CRTL_UNK4A(a5)
                bra.w   loc_18A2C
; ---------------------------------------------------------------------------
                jmp     update_ent_61_0xA4
; ---------------------------------------------------------------------------
jump1:                                  ; CODE XREF: update_ent_8B+E   j
                subq.w  #2,CRTL_UNK5E(a5)
                bmi.w   sub_18986
                move.w  CRTL_UNK5E(a5),d0
                asr.w   #2,d0
                cmpi.w  #6,d0
                bmi.s   loc_18BE8
                moveq   #6,d0
loc_18BE8:                              ; CODE XREF: update_ent_8B+BA   j
                andi.w  #6,d0
                move.w  word_18C06(pc,d0.w),d1
                or.w    (SPRITE_FLAGS_808A).w,d1
                move.w  d1,CRTL_SPRITE_FLAGS(a5)
                move.w  word_18C0E(pc,d0.w),CRTL_SPRITE_PTR(a5)
                move.w  word_18C16(pc,d0.w),CRTL_SPRITE_XOFF(a5)
                rts
; End of function update_ent_8B
; ---------------------------------------------------------------------------
word_18C06:     dc.w $45A9,$45A5,$45A1,$45A0 ; DATA XREF: update_ent_8B+C2   r
word_18C0E:     dc.w  $A00, $500, $500,    0 ; DATA XREF: update_ent_8B+CE   r
word_18C16:     dc.w $F4F4,$F8F8,$F8F8,$FCFC ; DATA XREF: update_ent_8B+D4   r
