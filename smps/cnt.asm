; Attributes: thunk
j_update_sound:                         ; CODE XREF: Reset+252   p sound_engine_update+36   p
                jmp     update_sound(pc)
; End of function j_update_sound
j_load_z80_dac_driver:                  ; CODE XREF: Reset+246   p
                jmp     load_z80_dac_driver(pc)
; End of function j_load_z80_dac_driver
update_sound:                           ; CODE XREF: j_update_sound   j
                                        ; DATA XREF: j_update_sound   o
                clr.b   (sfxflag_).w
                tst.b   (pause_flg_).w
                bne.w   pause_check
                jsr     fade_spc_check(pc)
                jsr     delay_control(pc)
                jsr     fadeout_check(pc)
                tst.l   (keyflag_buf).w
                beq.s   rhythm_scan
                jsr     bufscan(pc)
rhythm_scan:                            ; CODE XREF: update_sound+1C   j
                jsr     play_snd_id(pc)
                lea     (wk_top_).w,a5
                tst.b   (a5)
                bpl.s   fm_scan
                jsr     fm_rhythm_control(pc)
fm_scan:                                ; CODE XREF: update_sound+2C   j
                clr.b   (rhythm_flag_).w
                moveq   #fm_no-1,d7
fm_scan_loop:                           ; CODE XREF: update_sound:fm_scan_jump   j
                adda.w  #flgvol,a5
                tst.b   (a5)
                bpl.s   fm_scan_jump
                jsr     fm_control(pc)
fm_scan_jump:                           ; CODE XREF: update_sound+3E   j
                dbf     d7,fm_scan_loop
                moveq   #2,d7
psg_scan:                               ; CODE XREF: update_sound:psg_scan_jump   j
                adda.w  #flgvol,a5
                tst.b   (a5)
                bpl.s   psg_scan_jump
                jsr     psg_control(pc)
psg_scan_jump:                          ; CODE XREF: update_sound+50   j
                dbf     d7,psg_scan
                move.b  #$80,(sfxflag_).w
                moveq   #2,d7
fm_sfx_scan:                            ; CODE XREF: update_sound:fm_sfx_jump   j
                adda.w  #flgvol,a5
                tst.b   (a5)
                bpl.s   fm_sfx_jump
                jsr     fm_control(pc)
fm_sfx_jump:                            ; CODE XREF: update_sound+68   j
                dbf     d7,fm_sfx_scan
                moveq   #2,d7
psg_sfx_scan:                           ; CODE XREF: update_sound:psg_sfx_jump   j
                adda.w  #flgvol,a5
                tst.b   (a5)
                bpl.s   psg_sfx_jump
                jsr     psg_control(pc)
psg_sfx_jump:                           ; CODE XREF: update_sound+7A   j
                dbf     d7,psg_sfx_scan
                move.b  #$40,(sfxflag_).w ; '@'
                moveq   #1,d7
fm_back_scan:                           ; CODE XREF: update_sound:fm_back_jump   j
                adda.w  #flgvol,a5
                tst.b   (a5)
                bpl.s   fm_back_jump
                tst.b   channelno(a5)
                bmi.s   fm_back_psg
                jsr     fm_control(pc)
                bra.s   fm_back_jump
; ---------------------------------------------------------------------------
fm_back_psg:                            ; CODE XREF: update_sound+98   j
                jsr     psg_control(pc)
fm_back_jump:                           ; CODE XREF: update_sound+92   j update_sound+9E   j
                dbf     d7,fm_back_scan
                rts
; End of function update_sound
fm_rhythm_control:                      ; CODE XREF: update_sound+2E   p
                                        ; DATA XREF: update_sound+2E   o
                subq.b  #1,len_count(a5)
                bne.w   rhythm_end
                move.b  #$80,(rhythm_flag_).w
                movea.l mus_tbl_ptr(a5),a4
rhythm_cmdchk:                          ; CODE XREF: fm_rhythm_control+20   j
                moveq   #0,d5
                move.b  (a4)+,d5
                cmpi.b  #$E0,d5
                bcs.s   rhythm_nextd0
                jsr     smps_cmd_handler(pc)
                bra.s   rhythm_cmdchk
; ---------------------------------------------------------------------------
rhythm_nextd0:                          ; CODE XREF: fm_rhythm_control+1A   j
                tst.b   d5
                bpl.s   rhythm_len
                move.b  d5,basefreq(a5)
                move.b  (a4)+,d5
                bpl.s   rhythm_len
                subq.w  #1,a4
                move.b  len_data(a5),len_count(a5)
                bra.s   rhythm_flag_set
; ---------------------------------------------------------------------------
rhythm_len:                             ; CODE XREF: fm_rhythm_control+24   j fm_rhythm_control+2C   j
                jsr     tick_length_set(pc)
rhythm_flag_set:                        ; CODE XREF: fm_rhythm_control+36   j
                move.l  a4,mus_tbl_ptr(a5)
                moveq   #0,d0
                move.b  basefreq(a5),d0
                subi.b  #$81,d0
                bcs.s   rhythm_end
                ext.w   d0
                asl.w   #3,d0
                lea     DACDrum_Table(pc,d0.w),a3
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
wait_z80_loop:                          ; CODE XREF: fm_rhythm_control+6A   j
                bset    #0,(IO_Z80BUS).l
                bne.s   wait_z80_loop
                tst.b   (z80use_flg).l
                bmi.s   pass
                move.b  (z80_ram_byte_A01FFC).l,d0
                andi.b  #$C0,d0
                move.b  dac_list_entry.priority(a3),d1
                andi.b  #$C0,d1
                cmp.b   d0,d1
                bcs.w   pass
                move.b  #1,(z80use_flg).l
                move.b  (a3)+,(dac_bank_offset0_0).l
                move.b  (a3)+,(dac_bank_offset1_0).l
                move.b  (a3)+,(dac_sinfo_offset0_0).l
                move.b  (a3)+,(dac_sinfo_offset1_0).l
                move.b  (a3)+,(dac_pitch_0).l
                move.b  (a3)+,(dac_priority_0).l
                move.b  pandata(a5),(z80_pandata1).l
pass:                                   ; CODE XREF: fm_rhythm_control+72   j fm_rhythm_control+88   j
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
rhythm_end:                             ; CODE XREF: fm_rhythm_control+4   j fm_rhythm_control+4A   j
                rts
; End of function fm_rhythm_control
; ---------------------------------------------------------------------------
DACDrum_Table:  dc.w  $980              ; bank_offset ; DATA XREF: fm_rhythm_control+50   o
                dc.w   $80              ; sinfo_offset
                dc.b   5                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w  $480              ; sinfo_offset
                dc.b   2                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w  $880              ; sinfo_offset
                dc.b   1                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w  $C80              ; sinfo_offset
                dc.b   7                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $1080              ; sinfo_offset
                dc.b   7                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $1480              ; sinfo_offset
                dc.b   1                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $1880              ; sinfo_offset
                dc.b  $D                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $1C80              ; sinfo_offset
                dc.b   1                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $1080              ; sinfo_offset
                dc.b   3                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $1080              ; sinfo_offset
                dc.b   9                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $1080              ; sinfo_offset
                dc.b  $F                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $2080              ; sinfo_offset
                dc.b  $A                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $2480              ; sinfo_offset
                dc.b $17                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $2480              ; sinfo_offset
                dc.b   8                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $2480              ; sinfo_offset
                dc.b $10                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $2480              ; sinfo_offset
                dc.b  $D                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $2480              ; sinfo_offset
                dc.b   6                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $2880              ; sinfo_offset
                dc.b   1                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $2C80              ; sinfo_offset
                dc.b   1                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $3080              ; sinfo_offset
                dc.b   5                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $2480              ; sinfo_offset
                dc.b   8                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
                dc.w  $980              ; bank_offset
                dc.w $2480              ; sinfo_offset
                dc.b  $E                ; pitch
                dc.b   0                ; priority
                dc.b   0                ; pan_reg
                dc.b   0                ; unused
fm_control:                             ; CODE XREF: update_sound+40   p update_sound+6A   p ...
                subq.b  #1,len_count(a5)
                bne.s   fm_control1
                bclr    #_tie,(a5)
                jsr     fm_nextd(pc)
                jsr     fm_freq_write__(pc)
                jsr     pan_set(pc)
                bra.w   key_on
; ---------------------------------------------------------------------------
fm_control1:                            ; CODE XREF: fm_control+4   j
                jsr     gate_check(pc)
                jsr     pan_check(pc)
                jsr     vibr_check(pc)
                bra.w   vibr_freq_set
; ---------------------------------------------------------------------------
fm_nextd:                               ; CODE XREF: fm_control+A   p
                                        ; DATA XREF: fm_control+A   o
                movea.l mus_tbl_ptr(a5),a4
                bclr    #_null,(a5)
fm_cmd_check:                           ; CODE XREF: fm_control+40   j
                moveq   #0,d5
                move.b  (a4)+,d5
                cmpi.b  #$E0,d5
                bcs.s   fm_nextd0
                jsr     smps_cmd_handler(pc)
                bra.s   fm_cmd_check
; ---------------------------------------------------------------------------
fm_nextd0:                              ; CODE XREF: fm_control+3A   j
                jsr     key_off(pc)
                tst.b   d5
                bpl.s   fm_nextd1
                jsr     fm_freq_get(pc)
                move.b  (a4)+,d5
                bpl.s   fm_nextd1
                subq.w  #1,a4
                bra.w   smps_flag_set
; ---------------------------------------------------------------------------
fm_nextd1:                              ; CODE XREF: fm_control+48   j fm_control+50   j
                jsr     tick_length_set(pc)
                bra.w   smps_flag_set
; ---------------------------------------------------------------------------
fm_freq_get:                            ; CODE XREF: fm_control+4A   p
                                        ; DATA XREF: fm_control+4A   o
                subi.b  #$80,d5
                beq.s   null_flag_set
                add.b   bias(a5),d5
                andi.l  #$7F,d5
                divu.w  #$C,d5
                swap    d5
                lsl.w   #1,d5
                lea     fm_scale(pc),a0
                move.w  (a0,d5.w),d6
                swap    d5
                andi.w  #7,d5
                moveq   #$B,d0
                lsl.w   d0,d5
                or.w    d5,d6
                move.w  d6,basefreq(a5)
                rts
; ---------------------------------------------------------------------------
tick_length_set:                        ; CODE XREF: fm_rhythm_control:rhythm_len   p fm_control:fm_nextd1   p ...
                move.b  d5,d0
                move.b  cbase_count(a5),d1
loop:                                   ; CODE XREF: fm_control+9E   j
                subq.b  #1,d1
                beq.s   end
                add.b   d5,d0
                bra.s   loop
; ---------------------------------------------------------------------------
end:                                    ; CODE XREF: fm_control+9A   j
                move.b  d0,len_data(a5)
                move.b  d0,len_count(a5)
                rts
; ---------------------------------------------------------------------------
null_flag_set:                          ; CODE XREF: fm_control+64   j
                bset    #_null,(a5)
                clr.w   basefreq(a5)
smps_flag_set:                          ; CODE XREF: fm_control+54   j fm_control+5C   j ...
                move.l  a4,mus_tbl_ptr(a5)
                move.b  len_data(a5),len_count(a5)
                btst    #_tie,(a5)
                bne.s   end_
                move.b  gate_data(a5),gate_count(a5)
                clr.b   env_counter(a5)
                clr.b   $26(a5)
                clr.b   dtstr(a5)
                btst    #7,modulat_data(a5)
                beq.s   end_
                movea.l fvr_addr(a5),a0
                move.b  (a0)+,v_delay(a5)
                move.b  (a0)+,v_cont(a5)
                move.b  (a0)+,v_add(a5)
                move.b  (a0)+,d0
                lsr.b   #1,d0
                move.b  d0,v_limit(a5)
                clr.w   v_freq(a5)
end_:                                   ; CODE XREF: fm_control+C0   j fm_control+DA   j
                rts
; ---------------------------------------------------------------------------
gate_check:                             ; CODE XREF: fm_control:fm_control1   p psg_control:psg_cnt1   p
                                        ; DATA XREF: ...
                tst.b   gate_count(a5)
                beq.s   __end
                subq.b  #1,gate_count(a5)
                bne.s   __end
                bset    #_null,(a5)
                tst.b   channelno(a5)
                bmi.w   psg
                jsr     key_off(pc)
                addq.w  #4,sp
                rts
; ---------------------------------------------------------------------------
psg:                                    ; CODE XREF: fm_control+10E   j
                jsr     psg_off(pc)
                addq.w  #4,sp
__end:                                  ; CODE XREF: fm_control+FE   j fm_control+104   j
                rts
; ---------------------------------------------------------------------------
vibr_check:                             ; CODE XREF: fm_control+22   p psg_control+1E   p
                                        ; DATA XREF: ...
                btst    #7,modulat_data(a5)
                beq.s   vibr_end
                tst.b   v_delay(a5)
                beq.s   vibr_count
                subq.b  #1,v_delay(a5)
                rts
; ---------------------------------------------------------------------------
vibr_count:                             ; CODE XREF: fm_control+12E   j
                subq.b  #1,v_cont(a5)
                beq.s   vibr_limit
                rts
; ---------------------------------------------------------------------------
vibr_limit:                             ; CODE XREF: fm_control+13A   j
                movea.l fvr_addr(a5),a0
                move.b  1(a0),v_cont(a5)
                tst.b   v_limit(a5)
                bne.s   vibr_add
                move.b  3(a0),v_limit(a5)
                neg.b   v_add(a5)
                rts
; ---------------------------------------------------------------------------
vibr_add:                               ; CODE XREF: fm_control+14C   j
                subq.b  #1,v_limit(a5)
                move.b  v_add(a5),d6
                ext.w   d6
                add.w   v_freq(a5),d6
                move.w  d6,v_freq(a5)
                add.w   basefreq(a5),d6
vibr_end:                               ; CODE XREF: fm_control+128   j
                rts
; ---------------------------------------------------------------------------
fm_freq_write__:                        ; CODE XREF: fm_control+E   p
                                        ; DATA XREF: fm_control+E   o
                move.w  basefreq(a5),d6
                bne.s   fm_freq_write
                bset    #_null,(a5)
                rts
; ---------------------------------------------------------------------------
vibr_freq_set:                          ; CODE XREF: fm_control+26   j
                tst.b   modulat_data(a5)
                beq.w   fm_freq_end
fm_freq_write:                          ; CODE XREF: fm_control+176   j
                btst    #_null,(a5)
                bne.w   fm_freq_end
                btst    #_write_protect,(a5)
                bne.w   fm_freq_end
                jsr     envelope_set(pc)
                tst.b   (se_mode_flg_).w
                beq.s   vibr_freq_write
                cmpi.b  #2,channelno(a5)
                beq.w   dt_freq_set
vibr_freq_write:                        ; CODE XREF: fm_control+19E   j
                move.w  d6,d1
                lsr.w   #8,d1
                move.b  #blk_f_num2,d0
                jsr     opn_write(pc)
                move.b  d6,d1
                move.b  #f_num1,d0
                jsr     opn_write(pc)
fm_freq_end:                            ; CODE XREF: fm_control+182   j fm_control+18A   j ...
                rts
; ---------------------------------------------------------------------------
envelope_set:                           ; CODE XREF: fm_control+196   p psg_control+A8   p
                                        ; DATA XREF: ...
                moveq   #0,d6
                move.b  modulat_data(a5),d0
                andi.w  #$7F,d0
                beq.s   loc_82764
                lea     ModEnvPtrs(pc),a0
                subq.w  #1,d0
                lsl.w   #2,d0
                movea.l (a0,d0.w),a0
envelope_scan:                          ; CODE XREF: fm_control+232   j fm_control+238   j ...
                moveq   #0,d0
                move.b  $26(a5),d0
                addq.b  #1,$26(a5)
                move.b  (a0,d0.w),d6
                bpl.s   jump1
                cmpi.b  #reset_env,d6
                beq.s   reset_envelope
                cmpi.b  #hold_env,d6
                beq.s   hold_envelope
                cmpi.b  #stop_env,d6
                beq.s   stop_envelope
                cmpi.b  #loop_env,d6
                beq.s   loop_envelope
                cmpi.b  #add_to_env,d6
                beq.s   add_to_envelope
jump1:                                  ; CODE XREF: fm_control+1E8   j
                ext.w   d6
                move.b  dtstr(a5),d0
                ext.w   d0
                mulu.w  d0,d6
loc_82764:                              ; CODE XREF: fm_control+1CC   j
                move.b  fdt_freq(a5),d0
                ext.w   d0
                add.w   d0,d6
                add.w   basefreq(a5),d6
                tst.b   modulat_data(a5)
                bpl.s   end__
                add.w   v_freq(a5),d6
end__:                                  ; CODE XREF: fm_control+222   j
                rts
; ---------------------------------------------------------------------------
                addq.w  #4,sp
                rts
; ---------------------------------------------------------------------------
reset_envelope:                         ; CODE XREF: fm_control+1EE   j
                clr.b   $26(a5)
                bra.s   envelope_scan
; ---------------------------------------------------------------------------
hold_envelope:                          ; CODE XREF: fm_control+1F4   j
                subq.b  #2,$26(a5)
                bra.s   envelope_scan
; ---------------------------------------------------------------------------
stop_envelope:                          ; CODE XREF: fm_control+1FA   j
                bset    #1,(a5)
                tst.b   1(a5)
                bmi.s   psg_off_
                bra.w   key_off
; ---------------------------------------------------------------------------
psg_off_:                               ; CODE XREF: fm_control+242   j
                bra.w   psg_off
; ---------------------------------------------------------------------------
loop_envelope:                          ; CODE XREF: fm_control+200   j
                move.b  1(a0,d0.w),$26(a5)
                bra.s   envelope_scan
; ---------------------------------------------------------------------------
add_to_envelope:                        ; CODE XREF: fm_control+206   j
                move.b  1(a0,d0.w),d0
                add.b   d0,3(a5)
                addq.b  #1,$26(a5)
                bra.w   envelope_scan
; ---------------------------------------------------------------------------
dt_freq_set:                            ; CODE XREF: fm_control+1A6   j
                lea     dt_reg_tbl(pc),a1
                lea     (dt1_).w,a2
                tst.b   (sfxflag_).w
                beq.s   jump
                lea     (fm3mode_idk).w,a2
jump:                                   ; CODE XREF: fm_control+270   j
                moveq   #3,d5
loop_:                                  ; CODE XREF: fm_control+290   j
                move.w  d6,d1
                move.w  (a2)+,d0
                add.w   d0,d1
                move.w  d1,d3
                lsr.w   #8,d1
                move.b  (a1)+,d0
                jsr     opn1_write0(pc)
                move.b  d3,d1
                move.b  (a1)+,d0
                jsr     opn1_write0(pc)
                dbf     d5,loop_
                rts
; End of function fm_control
; ---------------------------------------------------------------------------
dt_reg_tbl:     dc.b $AD,$A9,$AC,$A8,$AE,$AA,$A6,$A2 ; DATA XREF: fm_control:dt_freq_set   o
pan_set:                                ; CODE XREF: fm_control+12   p
                                        ; DATA XREF: fm_control+12   o
                btst    #_null,(a5)
                bne.s   pan_set_table
                moveq   #0,d0
                move.b  pan_no(a5),d0
                lsl.w   #1,d0
                jmp     pan_set_table(pc,d0.w)
; ---------------------------------------------------------------------------
pan_set_table:                          ; CODE XREF: pan_set+4   j
                                        ; DATA XREF: pan_set+E   o
                rts
; ---------------------------------------------------------------------------
                bra.s   pan_s1
; ---------------------------------------------------------------------------
                bra.s   pan_s2
; ---------------------------------------------------------------------------
                bra.s   pan_s2
; ---------------------------------------------------------------------------
pan_check:                              ; CODE XREF: fm_control+1E   p
                                        ; DATA XREF: fm_control+1E   o
                btst    #_null,(a5)
                bne.s   locret_8281C
                moveq   #0,d0
                move.b  pan_no(a5),d0
                lsl.w   #1,d0
                jmp     locret_8281C(pc,d0.w)
; ---------------------------------------------------------------------------
locret_8281C:                           ; CODE XREF: pan_set+1E   j
                                        ; DATA XREF: pan_set+28   o
                rts
; ---------------------------------------------------------------------------
                rts
; ---------------------------------------------------------------------------
                bra.s   pan_s1
; ---------------------------------------------------------------------------
                bra.s   pan_s1
; ---------------------------------------------------------------------------
pan_s2:                                 ; CODE XREF: pan_set+16   j pan_set+18   j
                move.b  pan_length(a5),pan_count(a5)
                clr.b   pan_start(a5)
pan_s1:                                 ; CODE XREF: pan_set+14   j pan_set+30   j ...
                move.b  pan_count(a5),d0
                cmp.b   pan_length(a5),d0
                bne.s   pan_write
                move.b  pan_limit(a5),d3
                cmp.b   pan_start(a5),d3
                bpl.s   pan_s2_0
                cmpi.b  #2,pan_no(a5)
                beq.s   pan_chk_end
                clr.b   pan_start(a5)
pan_s2_0:                               ; CODE XREF: pan_set+50   j
                clr.b   pan_count(a5)
                addq.b  #1,pan_start(a5)
pan_write:                              ; CODE XREF: pan_set+46   j
                moveq   #0,d0
                move.b  pan_tbl(a5),d0
                subq.w  #1,d0
                lsl.w   #2,d0
                movea.l pan_addr_tbl(pc,d0.w),a0
                moveq   #0,d0
                move.b  pan_start(a5),d0
                subq.w  #1,d0
                move.b  (a0,d0.w),d1
                move.b  pandata(a5),d0  ; lfo recover
                andi.b  #%110111,d0
                or.b    d0,d1
                jsr     send_pan(pc)
                addq.b  #1,pan_count(a5)
pan_chk_end:                            ; CODE XREF: pan_set+58   j
                rts
; End of function pan_set
; ---------------------------------------------------------------------------
pan_addr_tbl:   dc.l pan_1_data,pan_2_data,pan_3_data ; DATA XREF: pan_set+70   o
pan_1_data:     dc.b $40,$80            ; DATA XREF: ROM:pan_addr_tbl   o
pan_2_data:     dc.b $40,$C0,$80        ; DATA XREF: ROM:pan_addr_tbl   o
pan_3_data:     dc.b $C0,$80,$C0,$40    ; DATA XREF: ROM:pan_addr_tbl   o
                dc.b 0
send_pan:                               ; CODE XREF: pan_set+8A   p cf_tbl+B0   j ...
                btst    #_write_protect,(a5)
                bne.s   end
                cmpi.b  #6,channelno(a5)
                bne.w   loc_828EC
                cmpa.l  #$40,a5 ; '@'
                beq.w   end
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
loop1:                                  ; CODE XREF: send_pan+30   j
                bset    #0,(IO_Z80BUS).l
                bne.s   loop1
                move.b  (z80use_flg).l,d0
                beq.w   loc_828DE
                move.b  pandata(a5),(z80_pandata0).l
loc_828DE:                              ; CODE XREF: send_pan+38   j
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
                tst.b   d0
                bne.s   end
loc_828EC:                              ; CODE XREF: send_pan+C   j
                move.b  #$B4,d0
                jsr     opn_write(pc)
end:                                    ; CODE XREF: send_pan+4   j send_pan+16   j ...
                rts
; End of function send_pan
pause_check:                            ; CODE XREF: update_sound+8   j
                cmpi.b  #$FF,(pause_flg_).w
                bne.w   pause_check_on
                rts
; ---------------------------------------------------------------------------
pause_check_on:                         ; CODE XREF: pause_check+6   j
                tst.b   (pause_flg_).w
                bmi.s   pause_check_off
                move.b  #$FF,(pause_flg_).w
                move    sr,-(sp)
                ori     #$700,sr
loop1:                                  ; CODE XREF: pause_check+44   j
                move.w  #z80_bus_on,(IO_Z80BUS).l
loop2:                                  ; CODE XREF: pause_check+2E   j
                bset    #0,(IO_Z80BUS).l
                bne.s   loop2
                tst.b   (z80_ram_byte_A01F2A).l
                beq.s   ram_clear_sound
                move.w  #z80_bus_off,(IO_Z80BUS).l
                bsr.w   sixteen_nop_sub
                bra.s   loop1
; ---------------------------------------------------------------------------
ram_clear_sound:                        ; CODE XREF: pause_check+36   j
                move    (sp)+,sr
                lea     (word_FFFBE0).w,a1
                move.l  (a1)+,-(sp)
                move.l  (a1)+,-(sp)
                move.l  (a1)+,-(sp)
                move.l  (a1)+,-(sp)
                move.l  (a1)+,-(sp)
                move.l  (a1)+,-(sp)
                move.l  (a1)+,-(sp)
                move.l  (a1)+,-(sp)
                jsr     fm_clear1(pc)
                lea     (word_FFFC00).w,a1
                move.l  (sp)+,-(a1)
                move.l  (sp)+,-(a1)
                move.l  (sp)+,-(a1)
                move.l  (sp)+,-(a1)
                move.l  (sp)+,-(a1)
                move.l  (sp)+,-(a1)
                move.l  (sp)+,-(a1)
                move.l  (sp)+,-(a1)
                bra.w   psg_clear
; ---------------------------------------------------------------------------
pause_check_off:                        ; CODE XREF: pause_check+10   j
                clr.b   (pause_flg_).w
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
                lea     (word_FFFBA0).w,a1
                moveq   #2,d2
loc_82988:                              ; CODE XREF: pause_check+AE   j
                moveq   #$40,d0 ; '@'
                add.w   d2,d0
                moveq   #3,d3
loc_8298E:                              ; CODE XREF: pause_check+AA   j
                move.b  (a1,d0.w),d1
                jsr     opn1_write0(pc)
                move.b  $10(a1,d0.w),d1
                jsr     opn2_write1(pc)
                addq.w  #4,d0
                dbf     d3,loc_8298E
                dbf     d2,loc_82988
                rts
; End of function pause_check
bufscan:                                ; CODE XREF: update_sound+1E   p
                                        ; DATA XREF: update_sound+1E   o
                lea     snd_priorities(pc),a0
                lea     (sfxflag_).w,a1
                move.b  (priority_flg_).w,d3
                moveq   #3,d4
snd_buf_loop:                           ; CODE XREF: bufscan:jump1   j
                move.b  -(a1),d0
                move.b  d0,d1
                clr.b   (a1)
                subq.b  #1,d0
                bcs.s   jump1
                andi.w  #$FF,d0
                move.b  (a0,d0.w),d2
                cmpi.b  #$FF,d2
                beq.w   jump3
                move.b  d2,d5
                andi.b  #$7F,d5
                move.b  d3,d6
                andi.b  #$7F,d6
                cmp.b   d6,d5
                bcs.s   jump1
                move.b  d2,d3
                move.b  d1,(kyflag0_).w
jump1:                                  ; CODE XREF: bufscan+16   j bufscan+36   j
                dbf     d4,snd_buf_loop
                tst.b   d3
                bmi.s   jump2
                move.b  d3,(priority_flg_).w
jump2:                                  ; CODE XREF: bufscan+44   j
                rts
; ---------------------------------------------------------------------------
jump3:                                  ; CODE XREF: bufscan+24   j
                move.b  d1,(kyflag0_).w
                bra.s   loop_cont
; ---------------------------------------------------------------------------
loop2:                                  ; CODE XREF: bufscan:loop_cont   j
                move.b  -(a1),d0
                subq.b  #1,d0
                bcs.s   clr_a1
                andi.w  #$FF,d0
                move.b  (a0,d0.w),d2
                cmpi.b  #$FF,d2
                beq.w   loop_cont
clr_a1:                                 ; CODE XREF: bufscan+56   j
                clr.b   (a1)
loop_cont:                              ; CODE XREF: bufscan+50   j bufscan+64   j
                dbf     d4,loop2
                rts
; End of function bufscan
play_snd_id:                            ; CODE XREF: update_sound:rhythm_scan   p
                                        ; DATA XREF: update_sound:rhythm_scan   o
                moveq   #0,d7
                move.b  (kyflag0_).w,d7
                move.b  #$FF,(kyflag0_).w
                tst.b   d7
                beq.w   load_z80_dac_driver
                cmpi.b  #$FF,d7
                beq.s   end
                cmpi.b  #1,d7
                bcs.w   sound_ram_clear ; chamus
                cmpi.b  #dac_sfx_start,d7
                bcs.w   play_snd_cmd    ; utlset
                cmpi.b  #sfx1_start,d7
                bcs.w   play_dac_sfx    ; z80_voice_set - heavily modified
                cmpi.b  #song_start,d7
                bcs.w   play_sfx2
                cmpi.b  #sfx2_start,d7
                bcs.w   play_song       ; songscan
                cmpi.b  #back_sfx_start,d7
                bcs.w   play_sfx
                cmpi.b  #last_no,d7
                bcs.w   play_back_sfx   ; backscan
end:                                    ; CODE XREF: play_snd_id+16   j
                rts
; ---------------------------------------------------------------------------
play_snd_cmd:                           ; CODE XREF: play_snd_id+24   j
                cmpi.b  #5,d7
                bcs.w   utlset
                rts
; ---------------------------------------------------------------------------
utlset:                                 ; CODE XREF: play_snd_id+56   j
                subq.b  #1,d7
                lsl.w   #2,d7
                jmp     utltb(pc,d7.w)
; ---------------------------------------------------------------------------
utltb:
                bra.w   fadeout
; ---------------------------------------------------------------------------
                bra.w   stop_sfx
; ---------------------------------------------------------------------------
                bra.w   stop_back_sfx
; ---------------------------------------------------------------------------
                bra.w   sound_ram_clear
; ---------------------------------------------------------------------------
play_dac_sfx:                           ; CODE XREF: play_snd_id+2C   j
                cmpi.b  #dac_sfx_end,d7
                bcs.w   z80_voice_set
                rts
; ---------------------------------------------------------------------------
z80_voice_set:                          ; CODE XREF: play_snd_id+78   j
                subi.b  #$10,d7
                ext.w   d7
                asl.w   #3,d7
                lea     (DAC_SFX_TBL).l,a0
                lea     (a0,d7.w),a0
                btst    #0,dac_list_entry.priority(a0)
                bne.w   z80opn_chk
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
loop:                                   ; CODE XREF: play_snd_id+B0   j
                bset    #0,(IO_Z80BUS).l
                bne.s   loop
                move.b  (z80_ram_byte_A01FFC).l,d1
                move.b  (dac_priority_1).l,d2
                move.b  (dac_priority_2).l,d3
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
                move.b  d1,d6
                move.b  dac_list_entry.priority(a0),d0
                andi.b  #$C0,d0
                btst    #0,d1
                bne.w   loc_82B06
                andi.b  #$C0,d1
                cmp.b   d1,d0
                bcc.w   loc_82B1C
                rts
; ---------------------------------------------------------------------------
loc_82B06:                              ; CODE XREF: play_snd_id+DC   j
                andi.b  #$C0,d2
                andi.b  #$C0,d3
                cmp.b   d2,d0
                bcs.w   end_82BA0
                cmp.b   d3,d0
                bcc.w   loc_82B1C
                rts
; ---------------------------------------------------------------------------
loc_82B1C:                              ; CODE XREF: play_snd_id+E6   j play_snd_id+FC   j
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
loc_82B2A:                              ; CODE XREF: play_snd_id+118   j
                bset    #0,(IO_Z80BUS).l
                bne.s   loc_82B2A
                move.b  #$80,(z80use_flg).l
                move.b  dac_list_entry.bank_offset(a0),(dac_bank_offset0_0).l
                move.b  dac_list_entry.bank_offset+1(a0),(dac_bank_offset1_0).l
                move.b  dac_list_entry.sinfo_offset(a0),(dac_sinfo_offset0_0).l
                move.b  dac_list_entry.sinfo_offset+1(a0),(dac_sinfo_offset1_0).l
                move.b  dac_list_entry.pitch(a0),(dac_pitch_0).l
                move.b  dac_list_entry.priority(a0),(dac_priority_0).l
                move.b  dac_list_entry.pan_reg(a0),(dac_pan_reg_0).l
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
                btst    #5,dac_list_entry.priority(a0)
                beq.w   end_82BA0
                btst    #5,d6
                bne.w   end_82BA0
                cmpi.b  #2,(fdspc_flg_in).w
                beq.w   end_82BA0
                move.b  #1,(fdspc_flg_in).w
end_82BA0:                              ; CODE XREF: play_snd_id+F6   j play_snd_id+16A   j ...
                rts
; ---------------------------------------------------------------------------
z80opn_chk:                             ; CODE XREF: play_snd_id+96   j
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
loop1:                                  ; CODE XREF: play_snd_id+19E   j
                bset    #0,(IO_Z80BUS).l
                bne.s   loop1
                move.b  (z80_ram_byte_A01FFC).l,d1
                move.b  (dac_priority_1).l,d2
                move.b  (dac_priority_2).l,d3
                move.b  (z80_flg_1).l,d4
                move.b  (z80_flg_2).l,d5
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
                move.b  d1,d6
                move.b  dac_list_entry.priority(a0),d0
                andi.b  #$C0,d0
                btst    #0,d1
                bne.w   loc_82BFE
                andi.b  #$C0,d1
                cmp.b   d1,d0
                bcs.w   end_82C2E
loc_82BFE:                              ; CODE XREF: play_snd_id+1D6   j
                andi.b  #$C0,d2
                andi.b  #$C0,d3
                move.b  dac_list_entry.pan_reg(a0),d1
                andi.b  #$C0,d1
                beq.w   loc_82C30
                cmpi.b  #$C0,d1
                beq.w   loc_82C30
                tst.b   d1
                bpl.w   loc_82C28
                cmp.b   d2,d0
                bcc.w   loc_82C62
                rts
; ---------------------------------------------------------------------------
loc_82C28:                              ; CODE XREF: play_snd_id+202   j
                cmp.b   d3,d0
                bcc.w   loc_82D12
end_82C2E:                              ; CODE XREF: play_snd_id+1E0   j
                rts
; ---------------------------------------------------------------------------
loc_82C30:                              ; CODE XREF: play_snd_id+1F4   j play_snd_id+1FC   j
                tst.b   d4
                beq.w   loc_82C62
                tst.b   d5
                beq.w   loc_82D12
                btst    #0,(byte_FFF82C).w
                bne.w   loc_82C54
                cmp.b   d2,d0
                bcc.w   loc_82C62
                cmp.b   d3,d0
                bcc.w   loc_82D12
                rts
; ---------------------------------------------------------------------------
loc_82C54:                              ; CODE XREF: play_snd_id+228   j
                cmp.b   d3,d0
                bcc.w   loc_82D12
                cmp.b   d2,d0
                bcc.w   loc_82C62
                rts
; ---------------------------------------------------------------------------
loc_82C62:                              ; CODE XREF: play_snd_id+208   j play_snd_id+218   j ...
                bset    #0,(byte_FFF82C).w
                bsr.w   get_pcm_data
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
loc_82C7A:                              ; CODE XREF: play_snd_id+268   j
                bset    #0,(IO_Z80BUS).l
                bne.s   loc_82C7A
                btst    #0,d6
                bne.w   loc_82C9C
                move.b  #$80,(dac_pitch_0).l
                move.b  #$80,(z80use_flg).l
loc_82C9C:                              ; CODE XREF: play_snd_id+26E   j
                move.b  #$80,(z80_flg_1).l
                move.b  dac_list_entry.bank_offset(a0),(dac_bank_offset0_1).l
                move.b  dac_list_entry.bank_offset+1(a0),(dac_bank_offset1_1).l
                move.b  d2,(sinfo_offset0_0).l
                move.b  d3,(sinfo_offset1_0).l
                move.b  d4,(sinfo_len0_0).l
                move.b  d5,(sinfo_len1_0).l
                move.b  dac_list_entry.priority(a0),(dac_priority_0).l
                move.b  dac_list_entry.priority(a0),(dac_priority_1).l
                move.b  #$C0,(dac_pan_reg_0).l
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
                btst    #5,dac_list_entry.priority(a0)
                beq.w   end_82D10
                btst    #5,d6
                bne.w   end_82D10
                cmpi.b  #2,(fdspc_flg_in).w
                beq.w   end_82D10
                move.b  #1,(fdspc_flg_in).w
end_82D10:                              ; CODE XREF: play_snd_id+2DA   j play_snd_id+2E2   j ...
                rts
; ---------------------------------------------------------------------------
loc_82D12:                              ; CODE XREF: play_snd_id+210   j play_snd_id+21E   j ...
                bclr    #0,(byte_FFF82C).w
                bsr.w   get_pcm_data
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
loc_82D2A:                              ; CODE XREF: play_snd_id+318   j
                bset    #0,(IO_Z80BUS).l
                bne.s   loc_82D2A
                btst    #0,d6
                bne.w   loc_82D4C
                move.b  #$80,(dac_pitch_0).l
                move.b  #$80,(z80use_flg).l
loc_82D4C:                              ; CODE XREF: play_snd_id+31E   j
                move.b  #$80,(z80_flg_2).l
                move.b  dac_list_entry.bank_offset(a0),(dac_bank_offset0_2).l
                move.b  dac_list_entry.bank_offset+1(a0),(dac_bank_offset1_2).l
                move.b  d2,(sinfo_offset0_1).l
                move.b  d3,(sinfo_offset1_1).l
                move.b  d4,(sinfo_len0_1).l
                move.b  d5,(sinfo_len1_1).l
                move.b  dac_list_entry.priority(a0),(dac_priority_0).l
                move.b  dac_list_entry.priority(a0),(dac_priority_2).l
                move.b  #$C0,(dac_pan_reg_0).l
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
                btst    #5,dac_list_entry.priority(a0)
                beq.w   end_82DC0
                btst    #5,d6
                bne.w   end_82DC0
                cmpi.b  #2,(fdspc_flg_in).w
                beq.w   end_82DC0
                move.b  #1,(fdspc_flg_in).w
end_82DC0:                              ; CODE XREF: play_snd_id+38A   j play_snd_id+392   j ...
                rts
; End of function play_snd_id
get_pcm_data:                           ; CODE XREF: play_snd_id+24E   p play_snd_id+2FE   p
                moveq   #0,d0
                move.w  dac_list_entry.bank_offset(a0),d0
                lsl.l   #8,d0
                movea.l d0,a2
                move.b  dac_list_entry.sinfo_offset+1(a0),d0
                lsl.w   #8,d0
                move.b  dac_list_entry.sinfo_offset(a0),d0
                andi.w  #$7FFF,d0
                move.b  (a2,d0.w),d2
                move.b  z80_sound_info.start_offset+1(a2,d0.w),d3
                move.b  z80_sound_info.data_length(a2,d0.w),d4
                move.b  z80_sound_info.data_length+1(a2,d0.w),d5
                rts
; End of function get_pcm_data
; ---------------------------------------------------------------------------
DAC_SFX_TBL:    dc.w  $A80              ; bank_offset[0] ; DATA XREF: play_snd_id+86   o
                dc.w  $880              ; sinfo_offset[0]
                dc.b   3                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A80              ; bank_offset[0]
                dc.w   $80              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w  $880              ; sinfo_offset[0]
                dc.b   1                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A80              ; bank_offset[0]
                dc.w   $80              ; sinfo_offset[0]
                dc.b $1B                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A80              ; bank_offset[0]
                dc.w  $480              ; sinfo_offset[0]
                dc.b $45                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B80              ; bank_offset[0]
                dc.w  $880              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B00              ; bank_offset[0]
                dc.w  $480              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B00              ; bank_offset[0]
                dc.w  $880              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B00              ; bank_offset[0]
                dc.w  $C80              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w $1480              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w $1880              ; sinfo_offset[0]
                dc.b $20                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B00              ; bank_offset[0]
                dc.w $1080              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $A1                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w  $480              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $A1                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B00              ; bank_offset[0]
                dc.w $1880              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B00              ; bank_offset[0]
                dc.w $2480              ; sinfo_offset[0]
                dc.b $40                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A80              ; bank_offset[0]
                dc.w $1080              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $C1                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w   $80              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w $2080              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $C80              ; bank_offset[0]
                dc.w  $C80              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B80              ; bank_offset[0]
                dc.w  $480              ; sinfo_offset[0]
                dc.b   2                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $C00              ; bank_offset[0]
                dc.w   $80              ; sinfo_offset[0]
                dc.b   2                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B80              ; bank_offset[0]
                dc.w $1080              ; sinfo_offset[0]
                dc.b   2                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $C00              ; bank_offset[0]
                dc.w  $880              ; sinfo_offset[0]
                dc.b   2                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $C80              ; bank_offset[0]
                dc.w  $480              ; sinfo_offset[0]
                dc.b   2                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $C80              ; bank_offset[0]
                dc.w  $880              ; sinfo_offset[0]
                dc.b   2                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $C00              ; bank_offset[0]
                dc.w  $480              ; sinfo_offset[0]
                dc.b   2                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B80              ; bank_offset[0]
                dc.w   $80              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w  $C80              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $D00              ; bank_offset[0]
                dc.w  $480              ; sinfo_offset[0]
                dc.b   3                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w $2480              ; sinfo_offset[0]
                dc.b $1A                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w $2480              ; sinfo_offset[0]
                dc.b $27                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B00              ; bank_offset[0]
                dc.w $2880              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B80              ; bank_offset[0]
                dc.w  $C80              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $D00              ; bank_offset[0]
                dc.w   $80              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $D00              ; bank_offset[0]
                dc.w  $880              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $D00              ; bank_offset[0]
                dc.w  $C80              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w $2080              ; sinfo_offset[0]
                dc.b $18                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w $2880              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $C00              ; bank_offset[0]
                dc.w  $C80              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $C80              ; bank_offset[0]
                dc.w $1080              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $D00              ; bank_offset[0]
                dc.w $1080              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $D00              ; bank_offset[0]
                dc.w $1480              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $D80              ; bank_offset[0]
                dc.w   $80              ; sinfo_offset[0]
                dc.b $1A                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w $1C80              ; sinfo_offset[0]
                dc.b   1                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $C80              ; bank_offset[0]
                dc.w   $80              ; sinfo_offset[0]
                dc.b   2                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B00              ; bank_offset[0]
                dc.w $1C80              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $B00              ; bank_offset[0]
                dc.w $2080              ; sinfo_offset[0]
                dc.b $13                ; pitch[0]
                dc.b $81                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
                dc.w  $A00              ; bank_offset[0]
                dc.w $1C80              ; sinfo_offset[0]
                dc.b   1                ; pitch[0]
                dc.b $80                ; priority[0]
                dc.b $C0                ; pan_reg[0]
                dc.b   0                ; unused[0]
play_song:                              ; CODE XREF: play_snd_id+3C   j
                cmpi.b  #sfx2_start,d7
                bcs.w   songscan
                rts
; ---------------------------------------------------------------------------
songscan:                               ; CODE XREF: play_song+4   j
                jsr     stop_sfx(pc)
                jsr     stop_back_sfx(pc)
                jsr     sound_ram_clear_song(pc)
                lea     MUSIC_PTRS(pc),a4
                subi.b  #$81,d7
                lsl.w   #2,d7
                movea.l (a4,d7.w),a4
                moveq   #0,d0
                move.w  (a4),d0
                add.l   a4,d0
                move.l  d0,(sng_voice_addr_).w
                move.b  hd_delay(a4),(cuntst_).w
                move.b  hd_delay(a4),(rcunt_).w
                moveq   #0,d1
                movea.l a4,a3
                addq.w  #hd_fmdt_top,a4
                moveq   #0,d7
                move.b  hd_fm_channel_no(a3),d7
                beq.s   psg_header
                subq.b  #1,d7
                move.b  #$C0,d1         ; d1 = pan data
                move.b  #$80,d3         ; d3 = flag data
                move.b  hd_base(a3),d4  ; d4 = tempo base
                moveq   #flgvol,d6      ; d6 = flag size (stac)
                move.b  #1,d5           ; d5 = lcont data
                lea     (wk_top_).w,a1
                lea     fm_channel_tbl(pc),a2
loop_fm:                                ; CODE XREF: play_song+8A   j
                move.b  d3,(a1)
                move.b  (a2)+,channelno(a1)
                move.b  d4,cbase_count(a1)
                move.b  d6,stack_ptr(a1)
                move.b  d1,pandata(a1)
                move.b  d5,len_count(a1)
                moveq   #0,d0
                move.w  (a4)+,d0
                add.l   a3,d0
                move.l  d0,mus_tbl_ptr(a1)
                move.w  (a4)+,bias(a1)
                adda.w  d6,a1
                dbf     d7,loop_fm
psg_header:                             ; CODE XREF: play_song+46   j
                moveq   #0,d7
                move.b  hd_psg_channel_no(a3),d7
                beq.s   end
                subq.b  #1,d7
                lea     (psg_wk_top_).w,a1
                lea     psg_channel_tbl(pc),a2
loop_psg:                               ; CODE XREF: play_song+CA   j
                move.b  d3,(a1)
                move.b  (a2)+,channelno(a1)
                move.b  d4,cbase_count(a1)
                move.b  d6,stack_ptr(a1)
                move.b  d5,len_count(a1)
                moveq   #0,d0
                move.w  (a4)+,d0
                add.l   a3,d0
                move.l  d0,mus_tbl_ptr(a1)
                move.w  (a4)+,bias(a1)
                move.b  (a4)+,modulat_data(a1)
                move.b  (a4)+,voice_env_no(a1)
                adda.w  d6,a1
                dbf     d7,loop_psg
end:                                    ; CODE XREF: play_song+94   j
                lea     (fm_sfx_wk_top_).w,a1
                moveq   #5,d7
loop_sfx:                               ; CODE XREF: play_song+F8   j
                tst.b   (a1)
                bpl.w   next
                moveq   #0,d0
                move.b  channelno(a1),d0
                bmi.s   psg_sfx
                subq.b  #2,d0
                lsl.b   #2,d0
                bra.s   jump1
; ---------------------------------------------------------------------------
psg_sfx:                                ; CODE XREF: play_song+E0   j
                lsr.b   #3,d0
jump1:                                  ; CODE XREF: play_song+E6   j
                lea     sfx_song_tbl(pc),a0
                movea.l (a0,d0.w),a0
                bset    #_write_protect,(a0)
next:                                   ; CODE XREF: play_song+D6   j
                adda.w  d6,a1
                dbf     d7,loop_sfx
                tst.w   (back_sfx_wk_).w
                bpl.s   jump2
                bset    #_write_protect,(fm4_wk_).w
jump2:                                  ; CODE XREF: play_song+100   j
                tst.w   (back_sfx2_wk_).w
                bpl.s   jump3
                bset    #_write_protect,(psg2_wk_).w
jump3:                                  ; CODE XREF: play_song+10C   j
                lea     (fm_wk_top_).w,a5
                moveq   #5,d4
loop_fm2:                               ; CODE XREF: play_song+120   j
                jsr     key_off(pc)
                adda.w  d6,a5
                dbf     d4,loop_fm2
                moveq   #2,d4
loop_psg2:                              ; CODE XREF: play_song+12C   j
                jsr     psg_off(pc)
                adda.w  d6,a5
                dbf     d4,loop_psg2
                btst    #_write_protect,(psg2_wk_).w
                bne.s   write_protect_on
                move.b  #$FF,(VDP_PSG).l
write_protect_on:                       ; CODE XREF: play_song+136   j
                addq.w  #4,sp
                rts
; End of function play_song
; ---------------------------------------------------------------------------
fm_channel_tbl: dc.b   6,  0,  1,  2    ; DATA XREF: play_song+60   o
                dc.b   4,  5,  6,  0
psg_channel_tbl:dc.b $80,$A0,$C0,  0    ; DATA XREF: play_song+9C   o
play_sfx2:                              ; CODE XREF: play_snd_id+34   j
                cmpi.b  #sfx1_end,d7
                bcs.w   sfx2_jump1
                rts
; ---------------------------------------------------------------------------
sfx2_jump1:                             ; CODE XREF: play_sfx2+4   j
                lea     SFX_PTRS(pc),a0
                addi.w  #$1D,d7
                bra.w   sfx2_jump2
; ---------------------------------------------------------------------------
play_sfx:                               ; CODE XREF: play_snd_id+44   j
                cmpi.b  #back_sfx_start,d7
                bcs.w   sescan
                rts
; ---------------------------------------------------------------------------
sescan:                                 ; CODE XREF: play_sfx2+1A   j
                lea     SFX_PTRS(pc),a0
                subi.b  #sfx2_start,d7
sfx2_jump2:                             ; CODE XREF: play_sfx2+12   j
                lsl.w   #2,d7
                movea.l (a0,d7.w),a3
                movea.l a3,a1
                moveq   #0,d1
                move.w  (a1)+,d1
                add.l   a3,d1
                move.b  (a1)+,d5
                moveq   #0,d7
                move.b  (a1)+,d7
                subq.w  #1,d7
                moveq   #flgvol,d6
loop:                                   ; CODE XREF: play_sfx2:pass1   j
                moveq   #0,d3
                move.b  hd_sfx_channel_no(a1),d3 ; offset from hd channel top
                move.b  d3,d4
                bmi.s   psg
fm:
                subq.w  #2,d3
                lsl.w   #2,d3
                lea     sfx_song_tbl(pc),a5
                movea.l (a5,d3.w),a5
                bset    #_write_protect,(a5)
                bra.s   header
; ---------------------------------------------------------------------------
psg:                                    ; CODE XREF: play_sfx2+48   j
                lsr.w   #3,d3
                movea.l sfx_song_tbl(pc,d3.w),a5
                bset    #_write_protect,(a5)
                cmpi.b  #$C0,d4
                bne.s   header
                move.b  d4,d0
                ori.b   #$1F,d0
                move.b  d0,(VDP_PSG).l
                bchg    #5,d0
                move.b  d0,(VDP_PSG).l
header:                                 ; CODE XREF: play_sfx2+5A   j play_sfx2+6A   j
                movea.l sfx_ram_tbl(pc,d3.w),a5
                movea.l a5,a2
                moveq   #$B,d0
loop1:                                  ; CODE XREF: play_sfx2+8C   j
                clr.l   (a2)+
                dbf     d0,loop1
                move.l  d1,pan_tbl(a5)
                move.w  (a1)+,(a5)
                move.b  d5,cbase_count(a5)
                moveq   #0,d0
                move.w  (a1)+,d0
                add.l   a3,d0
                move.l  d0,mus_tbl_ptr(a5)
                move.w  (a1)+,bias(a5)
                move.b  #1,len_count(a5)
                move.b  d6,stack_ptr(a5)
                tst.b   d4
                bmi.s   pass1
                move.b  #$C0,pandata(a5)
pass1:                                  ; CODE XREF: play_sfx2+B4   j
                dbf     d7,loop
                tst.b   (fm_sfx2_wk).w
                bpl.s   jump1
                bset    #_write_protect,(back_sfx_wk_).w
jump1:                                  ; CODE XREF: play_sfx2+C4   j
                tst.b   (psg_sfx3_wk).w
                bpl.s   jump2
                bset    #_write_protect,(back_sfx2_wk_).w
jump2:                                  ; CODE XREF: play_sfx2+D0   j
                rts
; End of function play_sfx2
; ---------------------------------------------------------------------------
sfx_song_tbl:   dc.l $FFFFF8D0,        0,$FFFFF900,$FFFFF930 ; DATA XREF: play_song:jump1   o play_sfx2+4E   o ...
                dc.l $FFFFF990,$FFFFF9C0,$FFFFF9F0,$FFFFF9F0
sfx_ram_tbl:    dc.l $FFFFFA20,        0,$FFFFFA50,$FFFFFA80 ; DATA XREF: play_sfx2:header   r
                dc.l $FFFFFAB0,$FFFFFAE0,$FFFFFB10,$FFFFFB10
play_back_sfx:                          ; CODE XREF: play_snd_id+4C   j
                cmpi.b  #last_no,d7
                bcs.w   backscan
                rts
; ---------------------------------------------------------------------------
backscan:                               ; CODE XREF: play_back_sfx+4   j
                lea     SPC_SFX_PTRS(pc),a0
                subi.b  #back_sfx_start,d7
                lsl.w   #2,d7
                movea.l (a0,d7.w),a3
                movea.l a3,a1
                moveq   #0,d0
                move.w  (a1)+,d0
                add.l   a3,d0
                move.l  d0,(back_voice_addr_).w
                move.b  (a1)+,d5
                moveq   #0,d7
                move.b  (a1)+,d7
                subq.w  #1,d7
                moveq   #flgvol,d6
loop:                                   ; CODE XREF: play_back_sfx:pass1   j
                move.b  hd_sfx_channel_no(a1),d4 ; offset from hd channel top
                bmi.s   psg
                bset    #_write_protect,(fm4_wk_).w
                lea     (back_sfx_wk_).w,a5
                bra.s   header
; ---------------------------------------------------------------------------
psg:                                    ; CODE XREF: play_back_sfx+32   j
                bset    #_write_protect,(psg2_wk_).w
                lea     (back_sfx2_wk_).w,a5
header:                                 ; CODE XREF: play_back_sfx+3E   j
                movea.l a5,a2
                moveq   #$B,d0
loop1:                                  ; CODE XREF: play_back_sfx+50   j
                clr.l   (a2)+
                dbf     d0,loop1
                move.w  (a1)+,(a5)
                move.b  d5,cbase_count(a5)
                moveq   #0,d0
                move.w  (a1)+,d0
                add.l   a3,d0
                move.l  d0,mus_tbl_ptr(a5)
                move.w  (a1)+,bias(a5)
                move.b  #1,len_count(a5)
                move.b  d6,stack_ptr(a5)
                tst.b   d4
                bmi.s   pass1
                move.b  #$C0,pandata(a5)
pass1:                                  ; CODE XREF: play_back_sfx+74   j
                dbf     d7,loop
                tst.b   (fm_sfx2_wk).w
                bpl.s   jump1
                bset    #_write_protect,(back_sfx_wk_).w
jump1:                                  ; CODE XREF: play_back_sfx+84   j
                tst.b   (psg_sfx3_wk).w
                bpl.s   jump3
                bset    #_write_protect,(back_sfx2_wk_).w
                ori.b   #$1F,d4
                move.b  d4,(VDP_PSG).l
                bchg    #5,d4
                move.b  d4,(VDP_PSG).l
jump3:                                  ; CODE XREF: play_back_sfx+90   j
                rts
; End of function play_back_sfx
; ---------------------------------------------------------------------------
bsfx_song_tbl:  dc.l $FFFFF900
                dc.l $FFFFF9F0
bsfx_sfx_tbl:   dc.l $FFFFFA50
                dc.l $FFFFFB10
bsfx_ram_tbl:   dc.l $FFFFFB40
                dc.l $FFFFFB70
stop_sfx:                               ; CODE XREF: play_snd_id+68   j play_song:songscan   p
                                        ; DATA XREF: ...
                clr.b   (priority_flg_).w
                moveq   #mode_tim,d0
                moveq   #nomal_mode,d1
                jsr     opn1_wrt_chk(pc)
                lea     (fm_sfx_wk_top_).w,a5
                moveq   #5,d6
loop:                                   ; CODE XREF: stop_sfx+9E   j
                tst.b   (a5)
                bpl.w   next
                bclr    #_enable,(a5)
                moveq   #0,d3
                move.b  channelno(a5),d3
                bmi.s   psg
                jsr     key_off(pc)
                cmpi.b  #4,d3
                bne.s   jump1
                tst.b   (back_sfx_wk_).w
                bpl.s   jump1
                lea     (back_sfx_wk_).w,a5
                movea.l (back_voice_addr_).w,a1
                bra.s   jump2
; ---------------------------------------------------------------------------
jump1:                                  ; CODE XREF: stop_sfx+2C   j stop_sfx+32   j
                subq.b  #2,d3
                lsl.b   #2,d3
                lea     sfx_song_tbl(pc),a0
                movea.l a5,a3
                movea.l (a0,d3.w),a5
                movea.l (sng_voice_addr_).w,a1
jump2:                                  ; CODE XREF: stop_sfx+3C   j
                bclr    #_write_protect,(a5)
                bset    #_null,(a5)
                move.b  voice_env_no(a5),d0
                jsr     jfenv0(pc)
                movea.l a3,a5
                bra.s   next
; ---------------------------------------------------------------------------
psg:                                    ; CODE XREF: stop_sfx+22   j
                jsr     psg_off(pc)
                lea     (back_sfx2_wk_).w,a0
                cmpi.b  #$E0,d3
                beq.s   jump3
                cmpi.b  #$C0,d3
                beq.s   jump3
                lsr.b   #3,d3
                lea     sfx_song_tbl(pc),a0
                movea.l (a0,d3.w),a0
jump3:                                  ; CODE XREF: stop_sfx+70   j stop_sfx+76   j
                bclr    #_write_protect,(a0)
                bset    #_null,(a0)
                cmpi.b  #$E0,channelno(a0)
                bne.s   next
                move.b  noisetype(a0),(VDP_PSG).l
next:                                   ; CODE XREF: stop_sfx+14   j stop_sfx+62   j ...
                adda.w  #flgvol,a5
                dbf     d6,loop
                rts
; End of function stop_sfx
stop_back_sfx:                          ; CODE XREF: play_snd_id+6C   j play_song+E   p
                                        ; DATA XREF: ...
                lea     (back_sfx_wk_).w,a5
                tst.b   (a5)
                bpl.s   back2
                bclr    #_enable,(a5)
                btst    #_write_protect,(a5)
                bne.s   back2
                jsr     key_off0(pc)
                lea     (fm4_wk_).w,a5  ; song FM 4ch
                bclr    #_write_protect,(a5)
                bset    #_null,(a5)
                tst.b   (a5)
                bpl.s   back2
                movea.l (sng_voice_addr_).w,a1
                move.b  voice_env_no(a5),d0
                jsr     jfenv0(pc)
back2:                                  ; CODE XREF: stop_back_sfx+6   j stop_back_sfx+10   j ...
                lea     (back_sfx2_wk_).w,a5
                tst.b   (a5)
                bpl.s   end
                bclr    #_enable,(a5)
                btst    #_write_protect,(a5)
                bne.s   end
                jsr     psg_off0(pc)
                lea     (psg2_wk_).w,a5 ; song PSG C0ch
                bclr    #_write_protect,(a5)
                bset    #_null,(a5)
                tst.b   (a5)
                bpl.s   end
                cmpi.b  #$E0,channelno(a5)
                bne.s   end
                move.b  noisetype(a5),(VDP_PSG).l
end:                                    ; CODE XREF: stop_back_sfx+38   j stop_back_sfx+42   j ...
                rts
; End of function stop_back_sfx
fadeout:                                ; CODE XREF: play_snd_id:utltb   j
                move.b  #fout_ct0,(fadeout_timer_).w
                move.b  #fout_ct1,(fadeout_flg_).w
                clr.b   (wk_top_).w
                rts
; End of function fadeout
fadeout_check:                          ; CODE XREF: update_sound+14   p
                                        ; DATA XREF: update_sound+14   o
                moveq   #0,d0
                move.b  (fadeout_flg_).w,d0
                beq.s   end
                move.b  (fadeout_timer_).w,d0
                beq.s   fout_cnt
                subq.b  #1,(fadeout_timer_).w
end:                                    ; CODE XREF: fadeout_check+6   j
                rts
; ---------------------------------------------------------------------------
fout_cnt:                               ; CODE XREF: fadeout_check+C   j
                subq.b  #1,(fadeout_flg_).w
                beq.w   sound_ram_clear
                move.b  #fout_ct0,(fadeout_timer_).w
                lea     (fm_wk_top_).w,a5
                moveq   #5,d7
loop:                                   ; CODE XREF: fadeout_check+40   j
                tst.b   (a5)
                bpl.s   pass
                addq.b  #1,volume(a5)
                bpl.s   jump
                bclr    #_enable,(a5)
                bra.s   pass
; ---------------------------------------------------------------------------
jump:                                   ; CODE XREF: fadeout_check+30   j
                jsr     vol_set(pc)
pass:                                   ; CODE XREF: fadeout_check+2A   j fadeout_check+36   j
                adda.w  #flgvol,a5
                dbf     d7,loop
                moveq   #2,d7
loop1:                                  ; CODE XREF: fadeout_check+68   j
                tst.b   (a5)
                bpl.s   pass1
                addq.b  #1,volume(a5)
                cmpi.b  #$10,volume(a5)
                bcs.s   jump1
                bclr    #_enable,(a5)
                bra.s   pass1
; ---------------------------------------------------------------------------
jump1:                                  ; CODE XREF: fadeout_check+54   j
                move.b  volume(a5),d6
                jsr     psg_att_set(pc)
pass1:                                  ; CODE XREF: fadeout_check+48   j fadeout_check+5A   j
                adda.w  #flgvol,a5
                dbf     d7,loop1
                rts
; End of function fadeout_check
delay_control:                          ; CODE XREF: update_sound+10   p
                                        ; DATA XREF: update_sound+10   o
                tst.b   (cuntst_).w
                beq.s   end
                subq.b  #1,(rcunt_).w
                bne.s   end
                move.b  (cuntst_).w,(rcunt_).w
                lea     (wk_top_).w,a0
                moveq   #flgvol,d0
                moveq   #9,d1
loop:                                   ; CODE XREF: delay_control+24   j
                tst.b   (a0)
                bpl.s   next
                addq.b  #1,len_count(a0)
next:                                   ; CODE XREF: delay_control+1C   j
                adda.w  d0,a0
                dbf     d1,loop
end:                                    ; CODE XREF: delay_control+4   j delay_control+A   j
                rts
; End of function delay_control
total_level_and_release_off:            ; CODE XREF: cfE3_MuteTrack   p
                                        ; DATA XREF: cfE3_MuteTrack   o
                moveq   #3,d4
                moveq   #TL1,d3
                moveq   #$7F,d1
loop:                                   ; CODE XREF: total_level_and_release_off+E   j
                move.b  d3,d0
                jsr     opn_write(pc)
                addq.b  #4,d3
                dbf     d4,loop
                moveq   #3,d4
                move.b  #RR1,d3
                moveq   #$F,d1
loop1:                                  ; CODE XREF: total_level_and_release_off+22   j
                move.b  d3,d0
                jsr     opn_write(pc)
                addq.b  #4,d3
                dbf     d4,loop1
                rts
; End of function total_level_and_release_off
fm_clear:                               ; CODE XREF: sound_ram_clear+1C   p
                                        ; DATA XREF: sound_ram_clear+1C   o
                moveq   #2,d2
                moveq   #$28,d0 ; '('
loop0:                                  ; CODE XREF: fm_clear+10   j
                move.b  d2,d1
                jsr     opn1_write0(pc)
                addq.b  #4,d1
                jsr     opn1_write0(pc)
                dbf     d2,loop0
; End of function fm_clear
fm_clear1:                              ; CODE XREF: pause_check+5C   p
                                        ; DATA XREF: pause_check+5C   o
                moveq   #$7F,d1
                moveq   #2,d2
loop1:                                  ; CODE XREF: fm_clear1+18   j
                moveq   #$40,d0 ; '@'
                add.w   d2,d0
                moveq   #3,d3
loop2:                                  ; CODE XREF: fm_clear1+14   j
                jsr     opn1_write0(pc)
                jsr     opn2_write1(pc)
                addq.w  #4,d0
                dbf     d3,loop2
                dbf     d2,loop1
                rts
; End of function fm_clear1
sound_ram_clear:                        ; CODE XREF: play_snd_id+1C   j play_snd_id+70   j ...
                moveq   #mode_tim,d0
                moveq   #nomal_mode,d1
                jsr     opn1_wrt_chk(pc)
                lea     (priority_flg_).w,a0
                move.w  #$E3,d0         ; (channel_no * flgvol + $30) / 4-1
loop:                                   ; CODE XREF: sound_ram_clear+12   j
                clr.l   (a0)+
                dbf     d0,loop
                move.b  #$FF,(kyflag0_).w
                jsr     fm_clear(pc)
                bra.w   psg_clear
; End of function sound_ram_clear
sound_ram_clear_song:                   ; CODE XREF: play_song+12   p
                                        ; DATA XREF: play_song+12   o
                moveq   #$27,d0 ; '''
                moveq   #0,d1
                jsr     opn1_wrt_chk(pc)
                move.b  (priority_flg_).w,d0
                move.w  d0,-(sp)
                lea     (priority_flg_).w,a0
                move.w  #$87,d0
loop:                                   ; CODE XREF: sound_ram_clear_song+18   j
                clr.l   (a0)+
                dbf     d0,loop
                move.w  (sp)+,d0
                move.b  d0,(priority_flg_).w
                move.b  #$FF,(kyflag0_).w
                rts
; End of function sound_ram_clear_song
load_z80_dac_driver:                    ; CODE XREF: j_load_z80_dac_driver   j play_snd_id+E   j
                                        ; DATA XREF: ...
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
checkz80_loop:                          ; CODE XREF: load_z80_dac_driver+16   j
                bset    #0,(IO_Z80BUS).l
                bne.s   checkz80_loop
                lea     DACDrvData(pc),a0
                lea     (Z80_RAM).l,a1
                move.w  #$BFF,d0
load_loop:                              ; CODE XREF: load_z80_dac_driver+28   j
                move.b  (a0)+,(a1)+
                dbf     d0,load_loop
                move.w  #z80_res_on,(IO_Z80RES).l
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                move.w  #z80_res_off,(IO_Z80RES).l
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
                bra.w   sound_ram_clear
; End of function load_z80_dac_driver
key_on:                                 ; CODE XREF: fm_control+16   j
                btst    #_null,(a5)
                bne.s   end
                btst    #_write_protect,(a5)
                bne.s   end
                moveq   #key_cont,d0
                move.b  channelno(a5),d1
                ori.b   #$F0,d1
                bra.w   opn1_wrt_chk
; ---------------------------------------------------------------------------
end:                                    ; CODE XREF: key_on+4   j key_on+A   j
                rts
; End of function key_on
key_off:                                ; CODE XREF: fm_control:fm_nextd0   p fm_control+112   p ...
                btst    #_tie,(a5)
                bne.s   end
                btst    #_write_protect,(a5)
                bne.s   end
key_off0:                               ; CODE XREF: stop_back_sfx+12   p
                                        ; DATA XREF: stop_back_sfx+12   o
                moveq   #key_cont,d0
                move.b  channelno(a5),d1
                bra.w   opn1_wrt_chk
; ---------------------------------------------------------------------------
end:                                    ; CODE XREF: key_off+4   j key_off+A   j
                rts
; End of function key_off
opn_wrt_chk:                            ; CODE XREF: cfE9_SetLFO+24   p cfED_RegSet+4   j ...
                btst    #_write_protect,(a5)
                beq.w   opn_write
                rts
; End of function opn_wrt_chk
opn1_wrt_chk:                           ; CODE XREF: stop_sfx+8   p sound_ram_clear+4   p ...
                bra.w   opn1_write0
; End of function opn1_wrt_chk
opn_write:                              ; CODE XREF: fm_control+1B2   p fm_control+1BC   p ...
                move.b  channelno(a5),d2
                bclr    #2,d2
                bne.s   opn2_write0
                add.b   d2,d0
; End of function opn_write
opn1_write0:                            ; CODE XREF: fm_control+284   p fm_control+28C   p ...
                cmpi.b  #$50,d0 ; 'P'
                bcc.w   opn1_write
                cmpi.b  #$40,d0 ; '@'
                bcs.w   opn1_write
                andi.w  #$FF,d0
                lea     (word_FFFBA0).w,a0
                move.b  d1,(a0,d0.w)
opn1_write:                             ; CODE XREF: opn1_write0+4   j opn1_write0+C   j
                lea     (opn_status).l,a0
loop1:                                  ; CODE XREF: opn1_write0+48   j
                move.w  #z80_bus_on,(IO_Z80BUS).l
loop2:                                  ; CODE XREF: opn1_write0+32   j
                bset    #0,(IO_Z80BUS).l ; is z80 bus busy?
                bne.s   loop2           ; if so, wait
                tst.b   (z80_ram_byte_A01F2A).l
                beq.s   write_wait_loop0
                move.w  #z80_bus_off,(IO_Z80BUS).l
                bsr.w   sixteen_nop_sub
                bra.s   loop1
; ---------------------------------------------------------------------------
write_wait_loop0:                       ; CODE XREF: opn1_write0+3A   j opn1_write0+4C   j
                tst.b   (a0)
                bmi.s   write_wait_loop0
                move.b  d0,0.w(a0)      ; fm register set
                nop
write_wait_loop1:                       ; CODE XREF: opn1_write0+56   j
                tst.b   (a0)
                bmi.s   write_wait_loop1
                move.b  d1,1(a0)        ; fm data set
                move.w  #z80_bus_off,(IO_Z80BUS).l
                rts
; End of function opn1_write0
opn2_write0:                            ; CODE XREF: opn_write+8   j
                add.b   d2,d0
; End of function opn2_write0
opn2_write1:                            ; CODE XREF: pause_check+A4   p fm_clear1+E   p ...
                cmpi.b  #$50,d0 ; 'P'
                bcc.w   opn2_write
                cmpi.b  #$40,d0 ; '@'
                bcs.w   opn2_write
                andi.w  #$FF,d0
                lea     (word_FFFBA0).w,a0
                move.b  d1,byte_FFFBB0-word_FFFBA0(a0,d0.w)
opn2_write:                             ; CODE XREF: opn2_write1+4   j opn2_write1+C   j
                lea     (opn_status).l,a0
loop1:                                  ; CODE XREF: opn2_write1+48   j
                move.w  #z80_bus_on,(IO_Z80BUS).l
loop2:                                  ; CODE XREF: opn2_write1+32   j
                bset    #0,(IO_Z80BUS).l
                bne.s   loop2
                tst.b   (z80_ram_byte_A01F2A).l
                beq.s   wait_not_busy_loop0
                move.w  #z80_bus_off,(IO_Z80BUS).l
                bsr.w   sixteen_nop_sub
                bra.s   loop1
; ---------------------------------------------------------------------------
wait_not_busy_loop0:                    ; CODE XREF: opn2_write1+3A   j opn2_write1+4C   j
                tst.b   (a0)
                bmi.s   wait_not_busy_loop0
                move.b  d0,2(a0)        ; fm register set
                nop
wait_not_busy_loop1:                    ; CODE XREF: opn2_write1+56   j
                tst.b   (a0)
                bmi.s   wait_not_busy_loop1
                move.b  d1,3(a0)        ; fm data set
                move.w  #0,(IO_Z80BUS).l
                rts
; End of function opn2_write1
sixteen_nop_sub:                        ; CODE XREF: pause_check+40   p opn1_write0+44   p ...
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                rts
; End of function sixteen_nop_sub
fade_spc_check:                         ; CODE XREF: update_sound+C   p
                                        ; DATA XREF: update_sound+C   o
                cmpi.b  #2,(fdspc_flg_in).w
                beq.w   fadein
                move.b  (fdspc_flg).w,d0
                beq.w   fadein
                bmi.w   fadeout
                cmpi.b  #1,d0
                bne.w   fadein
                move.b  #2,(fdspc_flg).w
                bra.w   raise_vol
; ---------------------------------------------------------------------------
fadeout:                                ; CODE XREF: fade_spc_check+12   j
                move.b  #0,(fdspc_flg).w
                bra.w   lower_vol
; ---------------------------------------------------------------------------
fadein:                                 ; CODE XREF: fade_spc_check+6   j fade_spc_check+E   j ...
                cmpi.b  #2,(fdspc_flg).w
                beq.w   end
                move.b  (fdspc_flg_in).w,d0
                beq.w   end
                cmpi.b  #1,d0
                bne.w   jump4
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
z80loop0:                               ; CODE XREF: fade_spc_check+62   j
                bset    #0,(IO_Z80BUS).l
                bne.s   z80loop0
                move.b  (z80_ram_byte_A01FFC).l,d7
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
                btst    #5,d7
                beq.w   end
                move.b  #2,(fdspc_flg_in).w
                move.b  (fdspc_add_fm).w,d0
                or.b    (fdspc_add_psg).w,d0
                bne.w   raise_vol
                move.b  #$A,(fdspc_add_fm).w
                move.b  #2,(fdspc_add_psg).w
                bra.w   raise_vol
; ---------------------------------------------------------------------------
jump4:                                  ; CODE XREF: fade_spc_check+48   j
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
z80loop1:                               ; CODE XREF: fade_spc_check+B4   j
                bset    #0,(IO_Z80BUS).l
                bne.s   z80loop1
                move.b  (z80_ram_byte_A01FFC).l,d7
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
                btst    #5,d7
                bne.w   end
                move.b  #0,(fdspc_flg_in).w
                bra.w   lower_vol
; ---------------------------------------------------------------------------
end:                                    ; CODE XREF: fade_spc_check+38   j fade_spc_check+40   j ...
                rts
; ---------------------------------------------------------------------------
raise_vol:                              ; CODE XREF: fade_spc_check+24   j fade_spc_check+8A   j ...
                move.b  (fdspc_add_fm).w,d6
                lea     (fm_wk_top_).w,a5
                moveq   #5,d7
raise_fm:                               ; CODE XREF: fade_spc_check+F6   j
                tst.b   (a5)
                bpl.s   is_neg
                add.b   d6,volume(a5)
                bmi.s   is_neg
                jsr     vol_set(pc)
is_neg:                                 ; CODE XREF: fade_spc_check+E6   j fade_spc_check+EC   j
                adda.w  #flgvol,a5
                dbf     d7,raise_fm
                move.b  (fdspc_add_psg).w,d5
                moveq   #2,d7
raise_psg:                              ; CODE XREF: fade_spc_check+11C   j
                tst.b   (a5)
                bpl.s   end0
                add.b   d5,volume(a5)
                cmpi.b  #$10,volume(a5)
                bcc.s   end0
                move.b  volume(a5),d6
                jsr     psg_att_set(pc)
end0:                                   ; CODE XREF: fade_spc_check+102   j fade_spc_check+10E   j
                adda.w  #flgvol,a5
                dbf     d7,raise_psg
                rts
; ---------------------------------------------------------------------------
lower_vol:                              ; CODE XREF: fade_spc_check+2E   j fade_spc_check+D4   j
                move.b  (fdspc_add_fm).w,d6
                lea     (fm_wk_top_).w,a5
                moveq   #5,d7
lower_fm:                               ; CODE XREF: fade_spc_check+13C   j
                tst.b   (a5)
                bpl.s   is_pos
                sub.b   d6,volume(a5)
                jsr     vol_set(pc)
is_pos:                                 ; CODE XREF: fade_spc_check+12E   j
                adda.w  #flgvol,a5
                dbf     d7,lower_fm
                move.b  (fdspc_add_psg).w,d5
                moveq   #2,d7
lower_psg:                              ; CODE XREF: fade_spc_check+15A   j
                tst.b   (a5)
                bpl.s   end1
                sub.b   d5,volume(a5)
                move.b  volume(a5),d6
                jsr     psg_att_set(pc)
end1:                                   ; CODE XREF: fade_spc_check+148   j
                adda.w  #flgvol,a5
                dbf     d7,lower_psg
                clr.b   (fdspc_add_fm).w
                clr.b   (fdspc_add_psg).w
                rts
; End of function fade_spc_check
; ---------------------------------------------------------------------------
fm_scale:       dc.w   606,  644,  683,  723,  766,  813 ; DATA XREF: fm_control+78   o
                dc.w   860,  911,  965, 1023, 1084, 1148
