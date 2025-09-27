smps_cmd_handler:                       ; CODE XREF: fm_rhythm_control+1C   p fm_control+3C   p ...
                subi.w  #$E0,d5
                lsl.w   #2,d5
                jmp     cf_tbl(pc,d5.w)
; End of function smps_cmd_handler
cf_tbl:
                bra.w   cfE0_Pan
; ---------------------------------------------------------------------------
                bra.w   cfE1_Detune
; ---------------------------------------------------------------------------
                bra.w   cfE2_SetComm
; ---------------------------------------------------------------------------
                bra.w   cfE3_MuteTrack
; ---------------------------------------------------------------------------
                bra.w   cfE4_PanAnim
; ---------------------------------------------------------------------------
                bra.w   cfE5_ChgPFMVol
; ---------------------------------------------------------------------------
                bra.w   cfE6_ChgFMVol
; ---------------------------------------------------------------------------
                bra.w   cfE7_Hold
; ---------------------------------------------------------------------------
                bra.w   cfE8_NoteStop
; ---------------------------------------------------------------------------
                bra.w   cfE9_SetLFO
; ---------------------------------------------------------------------------
                bra.w   cfEA_SetTempo
; ---------------------------------------------------------------------------
                bra.w   cfEB_PlaySnd
; ---------------------------------------------------------------------------
                bra.w   cfEC_ChgPSGVol
; ---------------------------------------------------------------------------
                bra.w   cfED_RegSet
; ---------------------------------------------------------------------------
                bra.w   cfEE_FMWrite
; ---------------------------------------------------------------------------
                bra.w   cfEF_SetFMIns
; ---------------------------------------------------------------------------
                bra.w   cfF0_ModSetup
; ---------------------------------------------------------------------------
                bra.w   cfF1_ModTypePFM
; ---------------------------------------------------------------------------
                bra.w   cfF2_StopTrk
; ---------------------------------------------------------------------------
                bra.w   cfF3_PSGNoise
; ---------------------------------------------------------------------------
                bra.w   cfF4_ModType
; ---------------------------------------------------------------------------
                bra.w   cfF5_SetPSGIns
; ---------------------------------------------------------------------------
                bra.w   cfF6_GoTo
; ---------------------------------------------------------------------------
                bra.w   cfF7_Loop
; ---------------------------------------------------------------------------
                bra.w   cfF8_GoSub
; ---------------------------------------------------------------------------
                bra.w   cfF9_Return
; ---------------------------------------------------------------------------
                bra.w   cfFA_TickMult
; ---------------------------------------------------------------------------
                bra.w   cfFB_ChgTransp
; ---------------------------------------------------------------------------
                bra.w   cfFC_ModulatOn
; ---------------------------------------------------------------------------
                bra.w   cfFD_ModulatOff
; ---------------------------------------------------------------------------
                bra.w   cfFE_SpcFM3Mode
; ---------------------------------------------------------------------------
                moveq   #0,d0
                move.b  (a4)+,d0
                lsl.w   #2,d0
                jmp     cf_meta_tbl(pc,d0.w)
; ---------------------------------------------------------------------------
cf_meta_tbl:                            ; DATA XREF: cf_tbl+82   o
                bra.w   cf00_SSGEG
; ---------------------------------------------------------------------------
                bra.w   cf01_MusPause
; ---------------------------------------------------------------------------
                bra.w   cf02_TickMulAll
; ---------------------------------------------------------------------------
                bra.w   cf03_FadeIn_On
; ---------------------------------------------------------------------------
                bra.w   cf04_FadeIn_Off
; ---------------------------------------------------------------------------
cfE0_Pan:                               ; CODE XREF: cf_tbl   j
                move.b  (a4)+,d1
                tst.b   channelno(a5)
                bmi.s   pan_end
                move.b  pandata(a5),d0
                andi.b  #%110111,d0
                or.b    d0,d1
                move.b  d1,pandata(a5)
                jmp     send_pan(pc)
; ---------------------------------------------------------------------------
pan_end:                                ; CODE XREF: cf_tbl+A0   j
                rts
; End of function cf_tbl
cfE1_Detune:                            ; CODE XREF: cf_tbl+4   j
                move.b  (a4)+,fdt_freq(a5)
                rts
; End of function cfE1_Detune
cfE2_SetComm:                           ; CODE XREF: cf_tbl+8   j
                move.b  (a4)+,(t_flg_).w
                rts
; End of function cfE2_SetComm
cfE3_MuteTrack:                         ; CODE XREF: cf_tbl+C   j
                jsr     total_level_and_release_off(pc)
                bra.w   cfF2_StopTrk
; End of function cfE3_MuteTrack
cfE4_PanAnim:                           ; CODE XREF: cf_tbl+10   j
                move.b  (a4)+,pan_no(a5)
                beq.s   pan_off
                move.b  (a4)+,pan_tbl(a5)
                move.b  (a4)+,pan_start(a5)
                move.b  (a4)+,pan_limit(a5)
                move.b  (a4),pan_length(a5)
                move.b  (a4)+,pan_count(a5)
                rts
; ---------------------------------------------------------------------------
pan_off:                                ; CODE XREF: cfE4_PanAnim+4   j
                move.b  pandata(a5),d1
                jmp     send_pan(pc)
; End of function cfE4_PanAnim
cfE5_ChgPFMVol:                         ; CODE XREF: cf_tbl+14   j
                move.b  (a4)+,d0
                tst.b   channelno(a5)
                bpl.s   cfE6_ChgFMVol
                add.b   d0,volume(a5)
                addq.w  #1,a4
                rts
; ---------------------------------------------------------------------------
cfE6_ChgFMVol:                          ; CODE XREF: cf_tbl+18   j cfE5_ChgPFMVol+6   j
                move.b  (a4)+,d0
                add.b   d0,volume(a5)
                bra.w   vol_set
; End of function cfE5_ChgPFMVol
cfE7_Hold:                              ; CODE XREF: cf_tbl+1C   j
                bset    #_tie,(a5)
                rts
; End of function cfE7_Hold
cfE8_NoteStop:                          ; CODE XREF: cf_tbl+20   j
                move.b  (a4),gate_count(a5)
                move.b  (a4)+,gate_data(a5)
                rts
; End of function cfE8_NoteStop
cfE9_SetLFO:                            ; CODE XREF: cf_tbl+24   j
                movea.l (sng_voice_addr_).w,a1
                beq.s   jlfo_ss
                movea.l sfx_voice_addr(a5),a1
jlfo_ss:                                ; CODE XREF: cfE9_SetLFO+4   j
                move.b  (a4),d3
                adda.w  #9,a0
                lea     lfo_reg_tbl(pc),a2
                moveq   #3,d6
jlfo_loop:                              ; CODE XREF: cfE9_SetLFO+2A   j
                move.b  (a1)+,d1
                move.b  (a2)+,d0
                btst    #7,d3
                beq.s   jflo_not
                bset    #7,d1
                jsr     opn_wrt_chk(pc)
jflo_not:                               ; CODE XREF: cfE9_SetLFO+1E   j
                lsl.w   #1,d3
                dbf     d6,jlfo_loop
                move.b  (a4)+,d1
                moveq   #lfo_fq,d0
                jsr     opn1_wrt_chk(pc)
                move.b  (a4)+,d1
                move.b  pandata(a5),d0
                andi.b  #$C0,d0
                or.b    d0,d1
                move.b  d1,pandata(a5)
                jmp     send_pan(pc)
; End of function cfE9_SetLFO
; ---------------------------------------------------------------------------
lfo_reg_tbl:    dc.b $60,$68,$64,$6C    ; DATA XREF: cfE9_SetLFO+10   o
cfEA_SetTempo:                          ; CODE XREF: cf_tbl+28   j
                move.b  (a4),(cuntst_).w
                move.b  (a4)+,(rcunt_).w
                rts
; End of function cfEA_SetTempo
cfEB_PlaySnd:                           ; CODE XREF: cf_tbl+2C   j
                move.b  (a4)+,(keyflag_buf).w
                rts
; End of function cfEB_PlaySnd
cfEC_ChgPSGVol:                         ; CODE XREF: cf_tbl+30   j
                move.b  (a4)+,d0
                add.b   d0,volume(a5)
                rts
; End of function cfEC_ChgPSGVol
cfED_RegSet:                            ; CODE XREF: cf_tbl+34   j
                move.b  (a4)+,d0
                move.b  (a4)+,d1
                bra.w   opn_wrt_chk
; End of function cfED_RegSet
cfEE_FMWrite:                           ; CODE XREF: cf_tbl+38   j
                move.b  (a4)+,d0
                move.b  (a4)+,d1
                bra.w   opn1_wrt_chk
; End of function cfEE_FMWrite
cfEF_SetFMIns:                          ; CODE XREF: cf_tbl+3C   j
                moveq   #0,d0
                move.b  (a4)+,d0
                move.b  d0,voice_env_no(a5)
                btst    #_write_protect,(a5)
                bne.w   jfenv_end
                movea.l (sng_voice_addr_).w,a1
                tst.b   (sfxflag_).w
                beq.s   jfenv0
                movea.l sfx_flag_(a5),a1
                bmi.s   jfenv0
                movea.l (back_voice_addr_).w,a1
; End of function cfEF_SetFMIns
jfenv0:                                 ; CODE XREF: stop_sfx+5C   p stop_back_sfx+2E   p ...
                subq.w  #1,d0
                bmi.s   jump1
                move.w  #$19,d1
loop:                                   ; CODE XREF: jfenv0+A   j
                adda.w  d1,a1
                dbf     d0,loop
jump1:                                  ; CODE XREF: jfenv0+2   j
                move.b  (a1)+,d1
                move.b  d1,algo(a5)
                move.b  d1,d4
                move.b  #$B0,d0
                jsr     opn_write(pc)
                lea     fm_reg_tbl(pc),a2
                moveq   #$13,d3
loop2:                                  ; CODE XREF: jfenv0+2C   j
                move.b  (a2)+,d0
                move.b  (a1)+,d1
                jsr     opn_write(pc)
                dbf     d3,loop2
                moveq   #3,d5
                andi.w  #7,d4
                move.b  vol_flg_tbl(pc,d4.w),d4
                move.b  volume(a5),d3
loop_t:                                 ; CODE XREF: jfenv0+4C   j
                move.b  (a2)+,d0
                move.b  (a1)+,d1
                lsr.b   #1,d4
                bcc.s   jump_t
                add.b   d3,d1
jump_t:                                 ; CODE XREF: jfenv0+44   j
                jsr     opn_write(pc)
                dbf     d5,loop_t
                cmpi.b  #6,1(a5)
                bne.w   jfenv_lrpan
                cmpa.l  #$40,a5 ; '@'
                beq.w   jfenv_end
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
loop_s:                                 ; CODE XREF: jfenv0+7A   j
                bset    #0,(IO_Z80BUS).l
                bne.s   loop_s
                move.b  (z80use_flg).l,d0
                beq.w   jmp_j
                move.b  pandata(a5),(z80_pandata0).l
jmp_j:                                  ; CODE XREF: jfenv0+82   j
                move.w  #z80_bus_off,(IO_Z80BUS).l
                move    (sp)+,sr
                tst.b   d0
                bne.s   jfenv_end
jfenv_lrpan:                            ; CODE XREF: jfenv0+56   j
                move.b  pandata(a5),d1
                move.b  #lr_mod,d0
                jsr     opn_write(pc)
jfenv_end:                              ; CODE XREF: cfEF_SetFMIns+C   j jfenv0+60   j ...
                rts
; End of function jfenv0
; ---------------------------------------------------------------------------
vol_flg_tbl:    dc.b   8,  8,  8,  8, $A, $E, $E, $F ; DATA XREF: jfenv0+36   r vol_set+42   r
vol_set:                                ; CODE XREF: fadeout_check:jump   p volume_ramp_idk+EE   p ...
                btst    #_write_protect,(a5)
                bne.s   end
                moveq   #0,d0
                move.b  voice_env_no(a5),d0
                movea.l (sng_voice_addr_).w,a1
                tst.b   (sfxflag_).w
                beq.s   jump1
                movea.l sfx_voice_addr(a5),a1
                tst.b   (sfxflag_).w
                bmi.s   jump1
                movea.l (back_voice_addr_).w,a1
jump1:                                  ; CODE XREF: vol_set+14   j vol_set+1E   j
                subq.w  #1,d0
                bmi.s   vol_s0
                move.w  #voice_vol,d1
loop_a:                                 ; CODE XREF: vol_set+2E   j
                adda.w  d1,a1
                dbf     d0,loop_a
vol_s0:                                 ; CODE XREF: vol_set+26   j
                adda.w  #$15,a1
                lea     tl_reg_tbl(pc),a2
                move.b  algo(a5),d0
                andi.w  #7,d0
                move.b  vol_flg_tbl(pc,d0.w),d4
                move.b  volume(a5),d3
                bmi.s   end
                moveq   #3,d5
loop_set:                               ; CODE XREF: vol_set:jump   j
                move.b  (a2)+,d0
                move.b  (a1)+,d1
                lsr.b   #1,d4
                bcc.s   jump
                add.b   d3,d1
                bcs.s   jump
                jsr     opn_write(pc)
jump:                                   ; CODE XREF: vol_set+54   j vol_set+58   j
                dbf     d5,loop_set
end:                                    ; CODE XREF: vol_set+4   j vol_set+4A   j
                rts
; End of function vol_set
; ---------------------------------------------------------------------------
fm_reg_tbl:     dc.b MU1,MU2,MU3,MU4    ; DATA XREF: jfenv0+1E   o
                dc.b AR1,AR2,AR3,AR4
                dc.b DR1,DR2,DR3,DR4
                dc.b SR1,SR2,SR3,SR4
                dc.b RR1,RR2,RR3,RR4
tl_reg_tbl:     dc.b TL1,TL2,TL3,TL4    ; DATA XREF: vol_set+36   o
cfF0_ModSetup:                          ; CODE XREF: cf_tbl+40   j
                bset    #_enable,$A(a5)
                move.l  a4,fvr_addr(a5)
                move.b  (a4)+,v_delay(a5)
                move.b  (a4)+,v_cont(a5)
                move.b  (a4)+,v_add(a5)
                move.b  (a4)+,d0
                lsr.b   #1,d0
                move.b  d0,v_limit(a5)
                clr.w   v_freq(a5)
                rts
; End of function cfF0_ModSetup
cfF1_ModTypePFM:                        ; CODE XREF: cf_tbl+44   j
                move.b  (a4)+,d0
                tst.b   1(a5)
                bpl.w   cfF4_ModType
                move.b  d0,$A(a5)
                move.b  (a4)+,d0
                rts
; ---------------------------------------------------------------------------
cfF2_StopTrk:                           ; CODE XREF: cf_tbl+48   j cfE3_MuteTrack+4   j
                bclr    #_enable,(a5)
                bclr    #_tie,(a5)
                tst.b   channelno(a5)
                bmi.s   jend_psg
                tst.b   (rhythm_flag_).w
                bmi.w   jend_end
                jsr     key_off(pc)
                bra.s   jend_jump2
; ---------------------------------------------------------------------------
jend_psg:                               ; CODE XREF: cfF1_ModTypePFM+1E   j
                jsr     psg_off(pc)
jend_jump2:                             ; CODE XREF: cfF1_ModTypePFM+2C   j
                tst.b   (sfxflag_).w
                bpl.w   jend_end
                clr.b   (priority_flg_).w
                moveq   #0,d0
                move.b  channelno(a5),d0
                bmi.s   psgse
                lea     sfx_song_tbl(pc),a0
                movea.l a5,a3
                cmpi.b  #4,d0
                bne.s   jend_jump_se1
                tst.b   (back_sfx_wk_).w
                bpl.s   jend_jump_se1
                lea     (back_sfx_wk_).w,a5
                movea.l (back_voice_addr_).w,a1
                bra.s   jend_jump_se2
; ---------------------------------------------------------------------------
jend_jump_se1:                          ; CODE XREF: cfF1_ModTypePFM+50   j cfF1_ModTypePFM+56   j
                subq.b  #2,d0
                lsl.b   #2,d0
                movea.l (a0,d0.w),a5
                tst.b   (a5)
                bpl.s   jend_jump_se3
                movea.l (sng_voice_addr_).w,a1
jend_jump_se2:                          ; CODE XREF: cfF1_ModTypePFM+60   j
                bclr    #_write_protect,(a5)
                bset    #_null,(a5)
                move.b  voice_env_no(a5),d0
                jsr     jfenv0(pc)
jend_jump_se3:                          ; CODE XREF: cfF1_ModTypePFM+6C   j
                movea.l a3,a5
                cmpi.b  #2,channelno(a5)
                bne.s   jend_end
                tst.b   (se_mode_flg_).w
                bne.s   jend_end
                moveq   #nomal_mode,d1
                moveq   #mode_tim,d0
                jsr     opn1_wrt_chk(pc)
                bra.s   jend_end
; ---------------------------------------------------------------------------
psgse:                                  ; CODE XREF: cfF1_ModTypePFM+44   j
                lea     (back_sfx2_wk_).w,a0
                tst.b   (a0)
                bpl.s   jend_jump_se4
                cmpi.b  #$E0,d0
                beq.s   jend_jump_se5
                cmpi.b  #$C0,d0
                beq.s   jend_jump_se5
jend_jump_se4:                          ; CODE XREF: cfF1_ModTypePFM+A2   j
                lea     sfx_song_tbl(pc),a0
                lsr.b   #3,d0
                movea.l (a0,d0.w),a0
jend_jump_se5:                          ; CODE XREF: cfF1_ModTypePFM+A8   j cfF1_ModTypePFM+AE   j
                bclr    #_write_protect,(a0)
                bset    #_null,(a0)
                cmpi.b  #$E0,channelno(a0)
                bne.s   jend_end
                move.b  noisetype(a0),(VDP_PSG).l
jend_end:                               ; CODE XREF: cfF1_ModTypePFM+24   j cfF1_ModTypePFM+36   j ...
                addq.w  #8,sp
                rts
; ---------------------------------------------------------------------------
cfF3_PSGNoise:                          ; CODE XREF: cf_tbl+4C   j
                move.b  #$E0,channelno(a5)
                move.b  (a4)+,noisetype(a5)
                btst    #_write_protect,(a5)
                bne.s   jrnoise_end
                move.b  -1(a4),(VDP_PSG).l
jrnoise_end:                            ; CODE XREF: cfF1_ModTypePFM+E4   j
                rts
; ---------------------------------------------------------------------------
cfF4_ModType:                           ; CODE XREF: cf_tbl+50   j cfF1_ModTypePFM+6   j
                move.b  (a4)+,$A(a5)
                rts
; End of function cfF1_ModTypePFM
cfF5_SetPSGIns:                         ; CODE XREF: cf_tbl+54   j
                move.b  (a4)+,voice_env_no(a5)
                rts
; End of function cfF5_SetPSGIns
cfF6_GoTo:                              ; CODE XREF: cf_tbl+58   j cfF7_Loop+14   j ...
                move.b  (a4)+,d0
                lsl.w   #8,d0
                move.b  (a4)+,d0
                adda.w  d0,a4
                subq.w  #1,a4
                rts
; End of function cfF6_GoTo
cfF7_Loop:                              ; CODE XREF: cf_tbl+5C   j
                moveq   #0,d0
                move.b  (a4)+,d0
                move.b  (a4)+,d1
                tst.b   repeat_count(a5,d0.w)
                bne.s   jrloop_end
                move.b  d1,repeat_count(a5,d0.w)
jrloop_end:                             ; CODE XREF: cfF7_Loop+A   j
                subq.b  #1,repeat_count(a5,d0.w)
                bne.s   cfF6_GoTo
                addq.w  #2,a4
                rts
; End of function cfF7_Loop
cfF8_GoSub:                             ; CODE XREF: cf_tbl+60   j
                moveq   #0,d0
                move.b  stack_ptr(a5),d0
                subq.b  #4,d0
                move.l  a4,(a5,d0.w)
                move.b  d0,stack_ptr(a5)
                bra.s   cfF6_GoTo
; End of function cfF8_GoSub
cfF9_Return:                            ; CODE XREF: cf_tbl+64   j
                moveq   #0,d0
                move.b  stack_ptr(a5),d0
                movea.l (a5,d0.w),a4
                addq.w  #2,a4
                addq.b  #4,d0
                move.b  d0,stack_ptr(a5)
                rts
; End of function cfF9_Return
cfFA_TickMult:                          ; CODE XREF: cf_tbl+68   j
                move.b  (a4)+,cbase_count(a5)
                rts
; End of function cfFA_TickMult
cfFB_ChgTransp:                         ; CODE XREF: cf_tbl+6C   j
                move.b  (a4)+,d0
                add.b   d0,bias(a5)
                rts
; End of function cfFB_ChgTransp
cfFC_ModulatOn:                         ; CODE XREF: cf_tbl+70   j
                bset    #modulat_flag,modulat_data(a5)
                rts
; End of function cfFC_ModulatOn
cfFD_ModulatOff:                        ; CODE XREF: cf_tbl+74   j
                bclr    #modulat_flag,modulat_data(a5)
                rts
; End of function cfFD_ModulatOff
cfFE_SpcFM3Mode:                        ; CODE XREF: cf_tbl+78   j
                lea     (fm3mode_idk).w,a0
                tst.b   (sfxflag_).w
                bne.s   jst_jump
                lea     (dt1_).w,a0
                move.b  #$80,(se_mode_flg_).w
jst_jump:                               ; CODE XREF: cfFE_SpcFM3Mode+8   j
                moveq   #3,d0
jst_loop:                               ; CODE XREF: cfFE_SpcFM3Mode+20   j
                moveq   #0,d1
                move.b  (a4)+,d1
                lsl.w   #1,d1
                move.w  fm3_freqvals(pc,d1.w),(a0)+
                dbf     d0,jst_loop
                move.b  #mode_tim,d0
                moveq   #se_mode,d1
                bra.w   opn1_wrt_chk
; End of function cfFE_SpcFM3Mode
; ---------------------------------------------------------------------------
fm3_freqvals:   dc.w     0, $180, $1F4, $260 ; DATA XREF: cfFE_SpcFM3Mode+1C   r
cf00_SSGEG:                             ; CODE XREF: cf_tbl:cf_meta_tbl   j
                lea     ssg_reg_tbl(pc),a1
                moveq   #3,d3
jssg_loop:                              ; CODE XREF: cf00_SSGEG+16   j
                move.b  (a1)+,d0
                move.b  (a4)+,d1
                jsr     opn_wrt_chk(pc)
                move.b  (a1)+,d0
                moveq   #$1F,d1
                jsr     opn_wrt_chk(pc)
                dbf     d3,jssg_loop
                rts
; End of function cf00_SSGEG
; ---------------------------------------------------------------------------
ssg_reg_tbl:    dc.b SSG1,AR1,SSG2,AR2  ; DATA XREF: cf00_SSGEG   o
                dc.b SSG3,AR3,SSG4,AR4
cf01_MusPause:                          ; CODE XREF: cf_tbl+8A   j
                moveq   #$30,d3 ; '0'
                move.b  (a4)+,d0
                beq.s   loc_83D4A
                movea.l a5,a3
                lea     (wk_top_).w,a5
                btst    #7,(a5)
                beq.s   loc_83D08
                bclr    #7,(a5)
                bset    #0,(a5)
loc_83D08:                              ; CODE XREF: cf01_MusPause+10   j
                moveq   #5,d4
loc_83D0A:                              ; CODE XREF: cf01_MusPause:loc_83D28   j
                adda.w  d3,a5
                btst    #7,(a5)
                beq.s   loc_83D28
                bclr    #7,(a5)
                bset    #0,(a5)
                move.b  #$B4,d0
                moveq   #0,d1
                jsr     opn_wrt_chk(pc)
                jsr     key_off(pc)
loc_83D28:                              ; CODE XREF: cf01_MusPause+22   j
                dbf     d4,loc_83D0A
                moveq   #2,d4
loc_83D2E:                              ; CODE XREF: cf01_MusPause:loc_83D42   j
                adda.w  d3,a5
                btst    #7,(a5)
                beq.s   loc_83D42
                bclr    #7,(a5)
                bset    #0,(a5)
                jsr     psg_off(pc)
loc_83D42:                              ; CODE XREF: cf01_MusPause+46   j
                dbf     d4,loc_83D2E
                movea.l a3,a5
                rts
; ---------------------------------------------------------------------------
loc_83D4A:                              ; CODE XREF: cf01_MusPause+4   j
                movea.l a5,a3
                lea     (wk_top_).w,a5
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #z80_bus_on,(IO_Z80BUS).l
loc_83D5E:                              ; CODE XREF: cf01_MusPause+78   j
                bset    #0,(IO_Z80BUS).l
                bne.s   loc_83D5E
                move.b  (z80use_flg).l,d0
                move.b  (z80_pandata1).l,d1
                move.b  (dac_pan_reg_0).l,d2
                move.w  #0,(IO_Z80BUS).l
                move    (sp)+,sr
                tst.b   d0
                beq.w   loc_83D98
                bpl.w   loc_83D90
                move.b  d2,d1
loc_83D90:                              ; CODE XREF: cf01_MusPause+9C   j
                move.b  #$B6,d0
                jsr     opn2_write1(pc)
loc_83D98:                              ; CODE XREF: cf01_MusPause+98   j
                btst    #0,(a5)
                beq.s   loc_83DA6
                bset    #7,(a5)
                bclr    #0,(a5)
loc_83DA6:                              ; CODE XREF: cf01_MusPause+AE   j
                moveq   #5,d4
loc_83DA8:                              ; CODE XREF: cf01_MusPause:loc_83E02   j
                adda.w  d3,a5
                btst    #0,(a5)
                beq.s   loc_83E02
                bset    #7,(a5)
                bclr    #0,(a5)
                btst    #2,(a5)
                bne.s   loc_83E02
                move.b  $27(a5),d1
                cmpi.b  #6,1(a5)
                bne.w   loc_83DFA
                move    sr,-(sp)
                ori     #$700,sr
                move.w  #$100,(IO_Z80BUS).l
loc_83DDA:                              ; CODE XREF: cf01_MusPause+F4   j
                bset    #0,(IO_Z80BUS).l
                bne.s   loc_83DDA
                move.b  (z80use_flg).l,d0
                move.w  #0,(IO_Z80BUS).l
                move    (sp)+,sr
                tst.b   d0
                bne.w   loc_83E02
loc_83DFA:                              ; CODE XREF: cf01_MusPause+DA   j
                move.b  #$B4,d0
                jsr     opn_write(pc)
loc_83E02:                              ; CODE XREF: cf01_MusPause+C0   j cf01_MusPause+CE   j ...
                dbf     d4,loc_83DA8
                moveq   #2,d4
loc_83E08:                              ; CODE XREF: cf01_MusPause:loc_83E18   j
                adda.w  d3,a5
                btst    #0,(a5)
                beq.s   loc_83E18
                bset    #7,(a5)
                bclr    #0,(a5)
loc_83E18:                              ; CODE XREF: cf01_MusPause+120   j
                dbf     d4,loc_83E08
                movea.l a3,a5
                rts
; End of function cf01_MusPause
cf02_TickMulAll:                        ; CODE XREF: cf_tbl+8E   j
                lea     (wk_top_).w,a0
                move.b  (a4)+,d0
                moveq   #$30,d1 ; '0'
                moveq   #9,d2
loop:                                   ; CODE XREF: cf02_TickMulAll+10   j
                move.b  d0,2(a0)
                adda.w  d1,a0
                dbf     d2,loop
                rts
; End of function cf02_TickMulAll
cf03_FadeIn_On:                         ; CODE XREF: cf_tbl+92   j
                tst.b   (byte_FFF828).w
                beq.w   loc_83E42
                addq.w  #2,a4
                rts
; ---------------------------------------------------------------------------
loc_83E42:                              ; CODE XREF: cf03_FadeIn_On+4   j
                move.b  #1,(byte_FFF828).w
                move.b  (byte_FFF829).w,d0
                or.b    (byte_FFF82A).w,d0
                bne.w   end
                move.b  (a4)+,(byte_FFF829).w
                move.b  (a4)+,(byte_FFF82A).w
end:                                    ; CODE XREF: cf03_FadeIn_On+1A   j
                rts
; End of function cf03_FadeIn_On
cf04_FadeIn_Off:                        ; CODE XREF: cf_tbl+96   j
                cmpi.b  #2,(byte_FFF828).w
                bne.w   end
                move.b  #$80,(byte_FFF828).w
end:                                    ; CODE XREF: cf04_FadeIn_Off+6   j
                rts
; End of function cf04_FadeIn_Off
