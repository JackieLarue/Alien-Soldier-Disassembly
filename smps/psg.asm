psg_control:                            ; CODE XREF: update_sound+52   p update_sound+7C   p ...
                subq.b  #1,len_count(a5)
                bne.s   psg_cnt1
                bclr    #_tie,(a5)
                jsr     psg_nextd(pc)
                jsr     psg_freq_set0(pc)
                bra.w   enve_set
; ---------------------------------------------------------------------------
psg_cnt1:                               ; CODE XREF: psg_control+4   j
                jsr     gate_check(pc)
                jsr     enve_check(pc)
                jsr     vibr_check(pc)
                bra.w   psg_freq_set
; ---------------------------------------------------------------------------
psg_nextd:                              ; CODE XREF: psg_control+A   p
                                        ; DATA XREF: psg_control+A   o
                bclr    #_null,(a5)
                movea.l mus_tbl_ptr(a5),a4
psg_cmd_check:                          ; CODE XREF: psg_control+3C   j
                moveq   #0,d5
                move.b  (a4)+,d5
                cmpi.b  #$E0,d5
                bcs.s   psg_d
                jsr     smps_cmd_handler(pc)
                bra.s   psg_cmd_check
; ---------------------------------------------------------------------------
psg_d:                                  ; CODE XREF: psg_control+36   j
                tst.b   d5
                bpl.s   psg_length
                jsr     psg_freq(pc)
                move.b  (a4)+,d5
                tst.b   d5
                bpl.s   psg_length
                subq.w  #1,a4
                bra.w   smps_flag_set
; ---------------------------------------------------------------------------
psg_length:                             ; CODE XREF: psg_control+40   j psg_control+4A   j
                jsr     tick_length_set(pc)
                bra.w   smps_flag_set
; ---------------------------------------------------------------------------
psg_freq:                               ; CODE XREF: psg_control+42   p
                                        ; DATA XREF: psg_control+42   o
                subi.b  #$81,d5
                bcs.s   psg_null
                add.b   bias(a5),d5
                andi.w  #$7F,d5
                lsl.w   #1,d5
                lea     psg_scale(pc),a0
                move.w  (a0,d5.w),basefreq(a5)
                bra.w   smps_flag_set
; ---------------------------------------------------------------------------
psg_null:                               ; CODE XREF: psg_control+5E   j
                bset    #_null,(a5)
                move.w  #$FFFF,basefreq(a5)
                jsr     smps_flag_set(pc)
                bra.w   psg_off
; ---------------------------------------------------------------------------
psg_freq_set0:                          ; CODE XREF: psg_control+E   p
                                        ; DATA XREF: psg_control+E   o
                move.w  basefreq(a5),d6
                bpl.s   jump0
                bset    #_null,(a5)
                rts
; ---------------------------------------------------------------------------
psg_freq_set:                           ; CODE XREF: psg_control+22   j
                tst.b   modulat_data(a5)
                beq.s   pvibrs_end
jump0:                                  ; CODE XREF: psg_control+8E   j
                btst    #1,(a5)
                bne.s   pvibrs_end
                btst    #2,(a5)
                bne.s   pvibrs_end
                jsr     envelope_set(pc)
                move.b  1(a5),d0
                cmpi.b  #$E0,d0
                bne.s   jump
                move.b  #$C0,d0
jump:                                   ; CODE XREF: psg_control+B4   j
                move.w  d6,d1
                andi.b  #$F,d1
                or.b    d1,d0
                lsr.w   #4,d6
                andi.b  #$3F,d6 ; '?'
                move.b  d0,(VDP_PSG).l
                move.b  d6,(VDP_PSG).l
pvibrs_end:                             ; CODE XREF: psg_control+9A   j psg_control+A0   j ...
                rts
; ---------------------------------------------------------------------------
enve_check:                             ; CODE XREF: psg_control+1A   p
                                        ; DATA XREF: psg_control+1A   o
                tst.b   voice_env_no(a5)
                beq.w   enve_end
enve_set:                               ; CODE XREF: psg_control+12   j
                move.b  volume(a5),d6
                moveq   #0,d0
                move.b  voice_env_no(a5),d0
                beq.s   psg_att_set
                lea     PSGPtrList(pc),a0
                subq.w  #1,d0
                lsl.w   #2,d0
                movea.l (a0,d0.w),a0
enve_set0:                              ; CODE XREF: psg_control+170   j psg_control+176   j
                moveq   #0,d0
                move.b  env_counter(a5),d0
                addq.b  #1,env_counter(a5)
                move.b  (a0,d0.w),d0
                bpl.s   jump1
                cmpi.b  #stop_env,d0
                beq.s   tb_end
                cmpi.b  #hold_env,d0
                beq.s   tb_hold
                cmpi.b  #loop_env,d0
                beq.s   tb_loop
                cmpi.b  #reset_env,d0
                beq.s   tb_reset
jump1:                                  ; CODE XREF: psg_control+104   j
                add.w   d0,d6
                cmpi.b  #$10,d6
                bcs.s   psg_att_set
                moveq   #$F,d6
psg_att_set:                            ; CODE XREF: fadeout_check+60   p volume_ramp_idk+114   p ...
                btst    #_null,(a5)
                bne.s   enve_end
                btst    #_write_protect,(a5)
                bne.s   enve_end
                btst    #_tie,(a5)
                bne.s   penves_tie
psg_att_write:                          ; CODE XREF: psg_control+14E   j psg_control+154   j
                or.b    channelno(a5),d6
                addi.b  #$10,d6
                move.b  d6,(VDP_PSG).l
enve_end:                               ; CODE XREF: psg_control+DA   j psg_control+12C   j ...
                rts
; ---------------------------------------------------------------------------
penves_tie:                             ; CODE XREF: psg_control+138   j
                tst.b   gate_data(a5)
                beq.s   psg_att_write
                tst.b   gate_count(a5)
                bne.s   psg_att_write
                rts
; ---------------------------------------------------------------------------
tb_end:                                 ; CODE XREF: psg_control+10A   j
                subq.b  #2,env_counter(a5)
                bset    #_null,(a5)
                bra.w   psg_off
; ---------------------------------------------------------------------------
tb_hold:                                ; CODE XREF: psg_control+110   j
                subq.b  #2,env_counter(a5)
                rts
; ---------------------------------------------------------------------------
tb_loop:                                ; CODE XREF: psg_control+116   j
                move.b  1(a0,d0.w),env_counter(a5)
                bra.s   enve_set0
; ---------------------------------------------------------------------------
tb_reset:                               ; CODE XREF: psg_control+11C   j
                clr.b   env_counter(a5)
                bra.w   enve_set0
; ---------------------------------------------------------------------------
psg_off:                                ; CODE XREF: fm_control:psg   p fm_control:psg_off_   j ...
                btst    #_write_protect,(a5)
                bne.s   psg_off_end
psg_off0:                               ; CODE XREF: stop_back_sfx+44   p
                                        ; DATA XREF: stop_back_sfx+44   o
                move.b  channelno(a5),d0
                ori.b   #$1F,d0
                move.b  d0,(VDP_PSG).l
psg_off_end:                            ; CODE XREF: psg_control+17E   j
                rts
; End of function psg_control
psg_clear:                              ; CODE XREF: pause_check+74   j sound_ram_clear+20   j
                lea     (VDP_PSG).l,a0
                move.b  #$9F,(a0)
                move.b  #$BF,(a0)
                move.b  #$DF,(a0)
                move.b  #$FF,(a0)
                rts
; End of function psg_clear
; ---------------------------------------------------------------------------
psg_scale:      dc.w  $356, $326, $2F9, $2CE, $2A5, $280, $25C, $23A ; DATA XREF: psg_control+6A   o
                dc.w  $21A, $1FB, $1DF, $1C4, $1AB, $193, $17D, $167
                dc.w  $153, $140, $12E, $11D, $10D,  $FE,  $EF,  $E2
                dc.w   $D6,  $C9,  $BE,  $B4,  $A9,  $A0,  $97,  $8F
                dc.w   $87,  $7F,  $78,  $71,  $6B,  $65,  $5F,  $5A
                dc.w   $55,  $50,  $4B,  $47,  $43,  $40,  $3C,  $39
                dc.w   $36,  $33,  $30,  $2D,  $2B,  $28,  $26,  $24
                dc.w   $22,  $20,  $1F,  $1D,  $1B,  $1A,  $18,  $17
                dc.w   $16,  $15,  $13,  $12,  $11,    0,    8,$4EF4
                dc.w     8,$5156,    8,$4E78,    8,$4FF2,    8,$4CC8
                dc.w     8,$4D8C,    0,  $A0,    8,$232C,    8,$5166
