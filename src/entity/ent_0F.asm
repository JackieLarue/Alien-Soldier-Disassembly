update_ent_0F:                          ; DATA XREF: ROM:ent_update_fns   o
                movea.w #(PLAYER_STRUCT-M68K_RAM),a0
                clr.w   $56(a5)
                move.w  $10(a0),d5
                move.w  $14(a0),d6
                add.w   (force_UNK8032).w,d5
                add.w   (force_UNK8034).w,d6
                move.w  (force_UNK8030).w,d0
                move.w  (force_UNK8036).w,d7
                add.w   $50(a5),d7
                andi.w  #$1FE,d7
                movea.l #word_1B514,a2
                move.w  -$80(a2,d7.w),d1
                move.w  (a2,d7.w),d2
                muls.w  d0,d1
                muls.w  d0,d2
                asl.l   #2,d1
                asl.l   #2,d2
                swap    d1
                swap    d2
                add.w   d6,d1
                add.w   d5,d2
                move.w  d1,$14(a5)
                move.w  d2,$10(a5)
                move.w  (word_FF803C).w,d0
                cmp.w   $48(a5),d0
                bne.s   end
                movea.w #(stru_FFC2C0-M68K_RAM),a0
                btst    #0,(word_FFA000+1).w
                bne.s   jump
                bclr    #7,2(a0)
                rts
; ---------------------------------------------------------------------------
jump:                                   ; CODE XREF: update_ent_0F+62   j
                bset    #7,2(a0)
                move.w  $10(a5),$10(a0)
                move.w  $14(a5),$14(a0)
end:                                    ; CODE XREF: update_ent_0F+56   j
                rts
; End of function update_ent_0F
