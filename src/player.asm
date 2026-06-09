clear_player_flags_off0_off2:           ; CODE XREF: update_player+A   j
                clr.w   (a5)
                clr.w   CRTL_UNK2(a5)
                rts
; End of function clear_player_flags_off0_off2
set_bit_7_unk2_if_FF183C_non_neg:       ; CODE XREF: update_player+12   j
                tst.w   (word_FF813C).w
                bmi.s   end             ; jumptable 00015060 cases 22-24
                bset    #7,CRTL_UNK2(a5)
pstate_unused:                          ; CODE XREF: set_bit_7_unk2_if_FF183C_non_neg+4   j
                                        ; player_state_machine+E   j
                                        ; DATA XREF: ...
end:                                    ; jumptable 00015060 cases 22-24
                rts
; End of function set_bit_7_unk2_if_FF183C_non_neg
update_player:                          ; CODE XREF: gamemode_play_stage:loc_1C70E   p sub_1EE3C   p ...
                movea.w #(PLAYER_STRUCT-M68K_RAM),a5
                btst    #1,(STAGE_STATE_UNK).w
                bne.w   clear_player_flags_off0_off2
                tst.b   (byte_FF813E).w
                bmi.s   set_bit_7_unk2_if_FF183C_non_neg
                jsr     (player_199F4).l
                bsr.w   copy_controls
                clr.b   (byte_FF8244).w
                clr.w   CRTL_VSTATE(a5)
                tst.w   (PL_DEATH_STATE).w
                beq.s   check_if_dead
                bpl.w   player_16ACE
check_if_dead:                          ; CODE XREF: update_player+2A   j
                tst.w   (STAGE_TIMER).w
                beq.w   kill_yourself_now
                tst.w   (HEALTH).w
                beq.w   kill_yourself_now
                btst    #0,(STAGE_STATE_UNK).w
                bne.w   player_19DAE
                btst    #2,(STAGE_STATE_UNK).w
                bne.w   player_1A274
                bsr.w   set_some_fmode_palette
                bsr.w   set_firing_direction
                bclr    #6,CRTL_UNK22(a5)
                beq.s   jump
                bsr.w   player_162A8
                bra.s   after_state_machine
; ---------------------------------------------------------------------------
jump:                                   ; CODE XREF: update_player+62   j
                bclr    #1,CRTL_UNK22(a5)
                beq.s   check_in_bounds
                bsr.w   player_16210
                bra.s   after_state_machine
; ---------------------------------------------------------------------------
check_in_bounds:                        ; CODE XREF: update_player+70   j
                cmpi.w  #DROWN,CRTL_PSTATE(a5)
                beq.s   run_player_smachine
                tst.w   CRTL_YSPD(a5)
                bmi.s   run_player_smachine
                btst    #0,(bounds_check_flag_FF8245).w
                bne.s   run_player_smachine
                cmpi.w  #369,CRTL_YPOS(a5) ; oob check
                bpl.w   pstate_pit
run_player_smachine:                    ; CODE XREF: update_player+7E   j update_player+84   j ...
                bsr.w   counterforce_check
                bsr.w   player_state_machine
after_state_machine:                    ; CODE XREF: update_player+68   j update_player+76   j
                bsr.w   player_16B5C
                move.b  CRTL_DOWN(a5),CRTL_RELEASED(a5)
                bsr.w   player_16C00
                bsr.w   pl_dma_queue_shenanigans
                clr.b   (byte_FF8311).w
                bra.w   player_16BCE
; End of function update_player
player_state_machine:                   ; CODE XREF: update_player+9C   p
                move.w  CRTL_PSTATE(a5),d0
                movea.w pstate_jmp_tbl(pc,d0.w),a0
                adda.l  #pstate_pit,a0
                jmp     (a0)            ; switch 48 cases
; End of function player_state_machine
; ---------------------------------------------------------------------------
pstate_jmp_tbl: dc.w pstate_idle-$150C2 ; DATA XREF: player_state_machine+4   o
                dc.w pstate_walk-$150C2 ; jump table for switch statement
                dc.w pstate_walk_backwards-$150C2
                dc.w pstate_airtime-$150C2
                dc.w pstate_airtime-$150C2
                dc.w pstate_skid-$150C2
                dc.w pstate_force_choose-$150C2
                dc.w pstate_crouch-$150C2
                dc.w pstate_dash-$150C2
                dc.w pstate_clamber_up-$150C2
                dc.w pstate_airtime-$150C2
                dc.w pstate_land-$150C2
                dc.w pstate_rev_idle-$150C2
                dc.w pstate_rev_walk-$150C2
                dc.w pstate_rev_walk_backwards-$150C2
                dc.w pstate_rev_skid-$150C2
                dc.w pstate_rev_force_choose-$150C2
                dc.w pstate_rev_crouch-$150C2
                dc.w pstate_dash-$150C2
                dc.w pstate_unk26-$150C2
                dc.w pstate_airtime-$150C2
                dc.w pstate_hurt-$150C2
                dc.w pstate_unused-$150C2
                dc.w pstate_unused-$150C2
                dc.w pstate_unused-$150C2
                dc.w pstate_tumble-$150C2
                dc.w pstate_tumble-$150C2
                dc.w pstate_drown-$150C2
                dc.w pstate_drown_recover-$150C2
                dc.w pstate_counter_force-$150C2
                dc.w pstate_air_counter_force-$150C2
                dc.w pstate_rev_counter_force-$150C2
                dc.w pstate_mid_dash-$150C2
                dc.w pstate_mid_dash-$150C2
                dc.w pstate_unk44-$150C2
                dc.w pstate_hover-$150C2
                dc.w pstate_rev_hover_idk-$150C2
                dc.w pstate_unk4A-$150C2
                dc.w pstate_unk4C-$150C2
                dc.w pstate_start_hover-$150C2
                dc.w pstate_pnx_start-$150C2
                dc.w pstate_pnx_unk0-$150C2
                dc.w pstate_pnx_unk1-$150C2
                dc.w pstate_pnx_end-$150C2
                dc.w pstate_speen-$150C2
                dc.w pstate_speen_faster-$150C2
                dc.w pstate_phoenix0-$150C2
                dc.w pstate_phoenix1-$150C2
pstate_pit:                             ; CODE XREF: update_player+94   j
                                        ; DATA XREF: player_state_machine+8   o
                move.b  #$2B,d0 ; '+'
                jsr     (play_sfx_id_2).l
                move.b  #%1110011,(PCRTL_MASK).w
                move.w  #$8000,(PL_DEATH_STATE).w
                jsr     (clear_BFC0_0x660_bytes).l
                move.b  #1,(word_FF8224).w
                move.b  #1,(word_FF8224+1).w
                move.w  #DROWN,CRTL_PSTATE(a5)
                move.w  #$C100,CRTL_UNK2(a5)
                bclr    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                move.b  CRTL_SPRITE_FLAGS(a5),CRTL_UNK4C(a5)
                move.b  CRTL_UNK20(a5),CRTL_UNK4D(a5)
                bset    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bset    #PFLAG_BOSS_FIGHT,CRTL_SPRITE_FLAGS(a5)
                move.b  #$81,CRTL_UNK21(a5)
                clr.l   CRTL_XSPD(a5)
                clr.l   CRTL_YSPD(a5)
                move.w  #288,CRTL_YPOS(a5)
                move.w  #3,CRTL_UNK48(a5)
                move.w  #$A0,CRTL_UNK4A(a5)
pstate_drown:                           ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                bset    #5,(byte_FF8244).w ; jumptable 00015060 case 27
                bset    #0,(byte_FF8244).w
                move.b  #8,CRTL_UNK20(a5)
                btst    #0,(word_FFA000+1).w
                bne.s   loc_15152
                subq.w  #1,(HEALTH).w
loc_15152:                              ; CODE XREF: pstate_pit+8A   j
                subq.w  #1,(HEALTH).w
                bpl.s   loc_1515C
                clr.w   (HEALTH).w
loc_1515C:                              ; CODE XREF: pstate_pit+94   j
                move.w  #$10,CRTL_UNK5E(a5)
                subq.w  #1,CRTL_UNK4A(a5)
                bmi.s   loc_15186
                move.b  CRTL_PRESSED(a5),d0 ; pit_mode_buttons
                andi.w  #$70,d0 ; 'p'
                beq.s   no_pit_button
                move.b  #$BD,d0
                jsr     (play_sfx_id_2).l
                subq.w  #1,CRTL_UNK48(a5)
                bmi.s   loc_15186
no_pit_button:                          ; CODE XREF: pstate_pit+AE   j
                bra.w   sub_1720C
; ---------------------------------------------------------------------------
loc_15186:                              ; CODE XREF: pstate_pit+A4   j pstate_pit+BE   j
                clr.w   (PL_DEATH_STATE).w
                move.b  #$7F,(PCRTL_MASK).w
                move.w  #DROWN_RECOVER,CRTL_PSTATE(a5)
                move.w  #$CD00,CRTL_UNK2(a5)
                move.w  #$C,CRTL_UNK5C(a5)
                move.l  #$FFF70000,CRTL_YSPD(a5)
                move.w  #$50,CRTL_UNK5E(a5) ; 'P'
                clr.w   CRTL_UNK48(a5)
                clr.w   CRTL_UNK4A(a5)
                move.b  CRTL_UNK4C(a5),CRTL_SPRITE_FLAGS(a5)
                move.b  CRTL_UNK4D(a5),CRTL_UNK20(a5)
                move.w  #368,CRTL_YPOS(a5)
                move.w  #$FF80,CRTL_UNK52(a5)
pstate_drown_recover:                   ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                bclr    #0,(COUNTER_FLAG).w ; jumptable 00015060 case 28
                addi.l  #$3000,CRTL_YSPD(a5)
                bmi.w   loc_15D12
                clr.b   (word_FF8224).w
                clr.b   (word_FF8224+1).w
                bra.w   loc_15D12
; End of function pstate_pit
sub_151EE:                              ; CODE XREF: pstate_counter_force+18   j
                                        ; pstate_air_counter_force+40   j ...
                move.b  #$7F,(PCRTL_MASK).w
                bclr    #0,(COUNTER_FLAG).w
                clr.w   (word_FF8224).w
                move.w  #IDLE,CRTL_PSTATE(a5)
                clr.l   CRTL_XSPD(a5)
                clr.w   CRTL_UNK48(a5)
                move.w  #$FFFF,CRTL_UNKC(a5)
                move.w  #4,CRTL_UNK5C(a5)
                bra.w   set_pl_dir_based_on_firedir
; End of function sub_151EE
nullsub_29:                             ; CODE XREF: pstate_idle+1C   j pstate_idle+22   j
                rts
; End of function nullsub_29
; jumptable 00015060 case 0
pstate_idle:                            ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                bsr.w   sub_16CE8
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                beq.w   sub_15C34
                bsr.w   sub_17514
                bsr.w   fire_mode_check
                bne.s   nullsub_29
                bsr.w   jump_dash_check
                bne.s   nullsub_29
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_15286
                btst    #button_B,CRTL_DOWN(a5)
                beq.s   loc_1525A
                tst.w   (FIRING_MODE).w
                bne.s   loc_15278
loc_1525A:                              ; CODE XREF: pstate_idle+34   j
                btst    #button_DOWN,CRTL_DOWN(a5)
                bne.w   sub_153D4
                btst    #button_LEFT,CRTL_DOWN(a5)
                bne.w   sub_1564C
                btst    #button_RIGHT,CRTL_DOWN(a5)
                bne.w   sub_1564C
loc_15278:                              ; CODE XREF: pstate_idle+3A   j
                btst    #button_B,CRTL_DOWN(a5)
                beq.w   sub_16EC8
                bra.w   sub_17086
; ---------------------------------------------------------------------------
loc_15286:                              ; CODE XREF: pstate_idle+2A   j pstate_crouch+2C   j ...
                bsr.w   sub_153BC
                move.b  #$7F,(PCRTL_MASK).w
                jsr     (clear_entity_buffer0_0x600_bytes).l
                move.w  #COUNTER_FORCE,CRTL_PSTATE(a5)
                move.w  #$FFFC,CRTL_UNK48(a5)
                move.w  #$A,CRTL_UNK4A(a5)
                move.w  #$FFFF,CRTL_UNKC(a5)
                move.w  #4,CRTL_UNK5C(a5)
                move.l  #$FFFE0000,CRTL_XSPD(a5)
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.s   end
                neg.l   CRTL_XSPD(a5)
end:                                    ; CODE XREF: pstate_idle+A4   j
                rts
; End of function pstate_idle
; jumptable 00015060 case 29
pstate_counter_force:                   ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                bsr.w   sub_16CE8
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                beq.w   loc_1533A
                subq.w  #1,CRTL_UNK4A(a5)
                bmi.w   sub_151EE
                bsr.w   sub_1539C
                bne.w   do_jump_dash
                move.l  #$2000,d1
                bsr.w   cap_speed_stop0
                bra.w   sub_17334
; ---------------------------------------------------------------------------
loc_152FC:                              ; CODE XREF: pstate_airtime+82   j pstate_start_hover+64   j ...
                bsr.w   sub_153BC
                move.b  #%1111111,(PCRTL_MASK).w
                jsr     (clear_entity_buffer0_0x600_bytes).l
                move.w  #$FFFC,CRTL_UNK48(a5)
                move.w  #$A,CRTL_UNK4A(a5)
                move.w  #$FFFF,CRTL_UNKC(a5)
                move.l  #$FFFE0000,CRTL_YSPD(a5)
                move.l  #$FFFC0000,CRTL_XSPD(a5)
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.s   loc_1533A
                neg.l   CRTL_XSPD(a5)
loc_1533A:                              ; CODE XREF: pstate_counter_force+10   j pstate_counter_force+6A   j ...
                move.w  #AIR_COUNTER_FORCE,CRTL_PSTATE(a5)
                rts
; End of function pstate_counter_force
; jumptable 00015060 case 30
pstate_air_counter_force:               ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                addi.l  #$5000,CRTL_YSPD(a5)
                jsr     sub_16CD8(pc)
                nop
                tst.w   CRTL_YSPD(a5)
                bmi.s   loc_15366
                bsr.w   sub_16CFE
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_15502
                bra.s   loc_15386
; ---------------------------------------------------------------------------
loc_15366:                              ; CODE XREF: pstate_air_counter_force+12   j
                clr.b   CRTL_VSTATE(a5)
                jsr     sub_16D2A(pc)
                nop
                bra.s   loc_15386
; ---------------------------------------------------------------------------
                jsr     sub_16CC8(pc)
                nop
                bsr.w   sub_16CE8
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_151EE
loc_15386:                              ; CODE XREF: pstate_air_counter_force+22   j
                                        ; pstate_air_counter_force+2E   j
                subq.w  #1,CRTL_UNK4A(a5)
                bmi.w   loc_15C3C
                move.l  #$1800,d1
                bsr.w   cap_speed_stop0
                bra.w   sub_17334
; End of function pstate_air_counter_force
sub_1539C:                              ; CODE XREF: pstate_counter_force+1C   p
                btst    #button_C,CRTL_PRESSED(a5)
                beq.s   end
                btst    #button_DOWN,CRTL_DOWN(a5)
                beq.s   end
                move.w  (HEALTH).w,d0
                sub.w   (MAX_HEALTH).w,d0
                move.w  d0,(GFX_HP_EMPTY_IDK).w
                moveq   #1,d0
end:                                    ; CODE XREF: sub_1539C+6   j sub_1539C+E   j
                rts
; End of function sub_1539C
sub_153BC:                              ; CODE XREF: pstate_idle:loc_15286   p
                                        ; pstate_counter_force:loc_152FC   p ...
                moveq   #$FFFFFFFC,d0
                move.l  #$FFFC0000,d2
                moveq   #$FFFFFFF6,d1
                btst    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                beq.s   loc_153D0
                moveq   #$A,d1
loc_153D0:                              ; CODE XREF: sub_153BC+10   j
                bra.w   sub_17386
; End of function sub_153BC
sub_153D4:                              ; CODE XREF: pstate_idle+42   j pstate_skid+30   j ...
                move.w  #2,CRTL_UNK48(a5)
loc_153DA:                              ; CODE XREF: pstate_dash+84   j pstate_mid_dash+34   j
                bclr    #0,(COUNTER_FLAG).w
                clr.w   (word_FF8224).w
                move.w  #CROUCH,CRTL_PSTATE(a5)
                move.w  #$A,CRTL_UNK4A(a5)
                move.w  #$FFFF,CRTL_UNKC(a5)
                move.w  #8,CRTL_UNK5C(a5)
                move.b  #%1111111,(PCRTL_MASK).w
                bra.w   set_pl_dir_based_on_firedir
; End of function sub_153D4
end_15406:                              ; CODE XREF: pstate_crouch+1E   j pstate_crouch+24   j
                rts
; End of function end_15406
; jumptable 00015060 case 7
pstate_crouch:                          ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                bset    #1,(byte_FF8244).w
                jsr     sub_16CC8(pc)
                nop
                bsr.w   sub_16CE8
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                beq.w   sub_15C34
                bsr.w   fire_mode_check
                bne.s   end_15406
                bsr.w   jump_dash_check
                bne.s   end_15406
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_15286
                bsr.w   cap_speed_stop
                subq.w  #1,CRTL_UNK48(a5)
                bpl.s   loc_15460
                move.w  #$FFFF,CRTL_UNK48(a5)
                btst    #button_B,CRTL_DOWN(a5)
                beq.s   loc_15456
                tst.w   (FIRING_MODE).w
                bne.s   loc_15460
loc_15456:                              ; CODE XREF: pstate_crouch+46   j
                btst    #button_DOWN,CRTL_DOWN(a5)
                beq.w   sub_151EE
loc_15460:                              ; CODE XREF: pstate_crouch+38   j pstate_crouch+4C   j
                btst    #button_B,CRTL_DOWN(a5)
                beq.w   sub_16EF2
                bra.w   loc_170F6
; End of function pstate_crouch
set_state_skid:                         ; CODE XREF: pstate_land+6C   j sub_1564C+3A   j ...
                move.b  #%1111111,(PCRTL_MASK).w
                clr.w   (word_FF8224).w
                move.w  #SKID,CRTL_PSTATE(a5)
                clr.w   CRTL_UNK48(a5)
                move.w  #4,CRTL_UNK5C(a5)
                bra.w   set_pl_dir_based_on_firedir
; End of function set_state_skid
; jumptable 00015060 case 5
pstate_skid:                            ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                bsr.w   sub_16CE8
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                beq.w   sub_15C34
                bsr.w   fire_mode_check
                bne.s   end_15500
                bsr.w   jump_dash_check
                bne.s   end_15500
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_15286
                btst    #button_DOWN,CRTL_DOWN(a5)
                bne.w   sub_153D4
                bsr.w   cap_speed_stop
                move.l  CRTL_XSPD(a5),d0
                bne.s   loc_154E2
                btst    #button_LEFT,CRTL_DOWN(a5)
                bne.w   loc_1565C
                btst    #button_RIGHT,CRTL_DOWN(a5)
                bne.w   loc_1565C
                bra.w   sub_151EE
; ---------------------------------------------------------------------------
loc_154E2:                              ; CODE XREF: pstate_skid+3C   j
                btst    #button_B,CRTL_DOWN(a5)
                bne.w   sub_17146
                movea.l #word_E8972,a1
                movea.l #word_E89C2,a2
                moveq   #0,d5
                moveq   #6,d6
                bra.w   set_player_sprite
; ---------------------------------------------------------------------------
end_15500:                              ; CODE XREF: pstate_skid+18   j pstate_skid+1E   j ...
                rts
; End of function pstate_skid
sub_15502:                              ; CODE XREF: pstate_air_counter_force+1E   j pstate_airtime+50   j ...
                move.b  #%1111111,(PCRTL_MASK).w
                clr.w   (word_FF8224).w
                move.w  #LAND,CRTL_PSTATE(a5)
                move.w  #2,CRTL_UNK48(a5)
                move.w  #6,CRTL_UNK4A(a5)
                move.w  #8,CRTL_UNK5C(a5)
                move.b  #$B1,d0
                jsr     (play_sfx_id_2).l
                bra.w   set_pl_dir_based_on_firedir
; End of function sub_15502
; jumptable 00015060 case 11
pstate_land:                            ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                bset    #1,(byte_FF8244).w
                jsr     sub_16CC8(pc)
                nop
                bsr.w   sub_16CE8
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                beq.w   sub_15C34
                bsr.w   fire_mode_check
                bne.s   end_15500
                bsr.w   jump_dash_check
                bne.s   end_15500
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_15286
                move.l  #$4000,d1
                bsr.w   cap_speed_stop0
                subq.w  #1,CRTL_UNK4A(a5)
                subq.w  #1,CRTL_UNK48(a5)
                bpl.s   loc_155A2
                btst    #button_DOWN,CRTL_DOWN(a5)
                beq.s   loc_1558A
                bsr.w   sub_153D4
                move.w  #$FFFF,CRTL_UNK48(a5)
                bra.s   loc_155A2
; ---------------------------------------------------------------------------
loc_1558A:                              ; CODE XREF: pstate_land+4A   j
                btst    #button_LEFT,CRTL_DOWN(a5)
                bne.w   loc_1565C
                btst    #button_RIGHT,CRTL_DOWN(a5)
                bne.w   loc_1565C
                bra.w   set_state_skid
; ---------------------------------------------------------------------------
loc_155A2:                              ; CODE XREF: pstate_land+42   j pstate_land+56   j
                btst    #button_B,CRTL_DOWN(a5)
                beq.w   sub_16EF2
                bra.w   loc_170F6
; End of function pstate_land
fire_mode_check:                        ; CODE XREF: pstate_idle+18   p pstate_crouch+1A   p ...
                btst    #button_A,CRTL_PRESSED(a5)
                beq.s   no_a_press
                btst    #button_DOWN,CRTL_DOWN(a5)
                bne.w   fire_mode_change
                tst.w   (FORCE_CHG_COOLDOWN).w
                bmi.s   weapon_cycle_idle
no_a_press:                             ; CODE XREF: fire_mode_check+6   j
                moveq   #0,d0
                rts
; ---------------------------------------------------------------------------
weapon_cycle_idle:                      ; CODE XREF: fire_mode_check+16   j
                move.w  (FORCE_CURRENT).w,(FORCE_MENU_INIT_HOVER).w
                move.w  #$12,(FORCE_CHANGE).w
                move.b  #$7F,(PCRTL_MASK).w
                move.w  #0,(force_UNK8032).w
                move.w  #$FFEE,(force_UNK8034).w
                clr.l   CRTL_XSPD(a5)
                clr.l   CRTL_YSPD(a5)
                move.w  #FMENU_IDLE,CRTL_PSTATE(a5)
                move.w  #4,CRTL_UNK5C(a5)
                btst    #button_DOWN,CRTL_DOWN(a5)
                beq.s   loc_1560C
                move.w  #8,CRTL_UNK5C(a5)
loc_1560C:                              ; CODE XREF: fire_mode_check+54   j
                moveq   #1,d0
                rts
; End of function fire_mode_check
; jumptable 00015060 case 6
pstate_force_choose:                    ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                bsr.w   sub_16CE8
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                beq.w   sub_15C34
                cmpi.w  #$12,(FORCE_CHANGE).w
                bmi.w   sub_151EE
                bra.w   sub_16EC8
; End of function pstate_force_choose
fire_mode_change:                       ; CODE XREF: fire_mode_check+E   j air_hang_fmove_mode_check+10   p
                move.b  #%1111111,(PCRTL_MASK).w
                eori.w  #2,(FIRING_MODE).w
                move.b  #$A3,d0
                jsr     (play_sfx_id_2).l
                moveq   #0,d0
                rts
; End of function fire_mode_change
sub_1564C:                              ; CODE XREF: pstate_idle+4C   j pstate_idle+56   j
                btst    #button_B,CRTL_DOWN(a5)
                beq.s   loc_15694
                tst.w   (FIRING_MODE).w
                beq.s   loc_1566C
                rts
; ---------------------------------------------------------------------------
loc_1565C:                              ; CODE XREF: pstate_skid+44   j pstate_skid+4E   j ...
                btst    #button_B,CRTL_DOWN(a5)
                beq.s   loc_15694
                tst.w   (FIRING_MODE).w
                bne.w   sub_151EE
loc_1566C:                              ; CODE XREF: sub_1564C+C   j
                btst    #button_RIGHT,CRTL_DOWN(a5)
                beq.s   loc_15680
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.w   set_state_walk_back
                bra.s   loc_15694
; ---------------------------------------------------------------------------
loc_15680:                              ; CODE XREF: sub_1564C+26   j
                btst    #button_LEFT,CRTL_DOWN(a5)
                beq.w   set_state_skid
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                beq.w   set_state_walk_back
loc_15694:                              ; CODE XREF: sub_1564C+6   j sub_1564C+16   j ...
                move.b  #$7F,(PCRTL_MASK).w
                move.w  #WALK,CRTL_PSTATE(a5)
                move.w  #4,CRTL_UNK48(a5)
                move.w  #$FFFF,CRTL_UNKC(a5)
                move.w  #4,CRTL_UNK5C(a5)
                bra.w   set_pl_dir_based_on_firedir
; ---------------------------------------------------------------------------
end_156B6:                              ; CODE XREF: sub_1564C+84   j sub_1564C+8A   j
                rts
; ---------------------------------------------------------------------------
pstate_walk:                            ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)   ; jumptable 00015060 case 1
                nop
                bsr.w   sub_16CE8
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                beq.w   sub_15C34
                bsr.w   fire_mode_check
                bne.s   end_156B6
                bsr.w   jump_dash_check
                bne.s   end_156B6
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_15286
                btst    #button_DOWN,CRTL_DOWN(a5)
                bne.w   sub_153D4
                btst    #button_B,CRTL_DOWN(a5)
                beq.s   loc_156FC
                tst.w   (FIRING_MODE).w
                bne.w   set_state_skid
loc_156FC:                              ; CODE XREF: sub_1564C+A6   j
                btst    #button_LEFT,CRTL_DOWN(a5)
                bne.s   loc_1570E
                btst    #button_RIGHT,CRTL_DOWN(a5)
                beq.w   set_state_skid
loc_1570E:                              ; CODE XREF: sub_1564C+B6   j
                bsr.w   cap_x_speed_walk
                btst    #button_B,CRTL_DOWN(a5)
                beq.w   sub_16F36
                btst    #button_RIGHT,CRTL_DOWN(a5)
                beq.s   loc_15732
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                beq.w   set_state_walk_back
                bra.w   sfx_pl_step
; ---------------------------------------------------------------------------
loc_15732:                              ; CODE XREF: sub_1564C+D6   j
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.w   set_state_walk_back
                bra.w   sfx_pl_step
; ---------------------------------------------------------------------------
set_state_walk_back:                    ; CODE XREF: sub_1564C+2E   j sub_1564C+44   j ...
                move.w  #WALK_BACK,CRTL_PSTATE(a5)
                clr.w   CRTL_UNK48(a5)
                move.w  #$FFFF,CRTL_UNKC(a5)
                move.w  #4,CRTL_UNK5C(a5)
end_15756:                              ; CODE XREF: pstate_walk_backwards+18   j pstate_walk_backwards+1E   j
                rts
; End of function sub_1564C
; jumptable 00015060 case 2
pstate_walk_backwards:                  ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                bsr.w   sub_16CE8
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                beq.w   sub_15C34
                bsr.w   fire_mode_check
                bne.s   end_15756
                bsr.w   jump_dash_check
                bne.s   end_15756
                btst    #button_DOWN,CRTL_DOWN(a5)
                bne.w   sub_153D4
                btst    #button_B,CRTL_DOWN(a5)
                beq.w   loc_15694
                bsr.w   sub_16FDC
                btst    #button_LEFT,CRTL_DOWN(a5)
                beq.s   loc_157A6
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                beq.w   loc_15694
                bra.w   cap_x_spd_walk_back_r
; ---------------------------------------------------------------------------
loc_157A6:                              ; CODE XREF: pstate_walk_backwards+3E   j
                btst    #button_RIGHT,CRTL_DOWN(a5)
                beq.w   set_state_skid
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.w   loc_15694
                bra.w   cap_x_spd_walk_back_l
; End of function pstate_walk_backwards
unused_pnx_state:
                move.w  #PNX_SCENE_END,CRTL_PSTATE(a5)
                move.w  #8,CRTL_UNK4E(a5)
                move.b  #%1110011,(PCRTL_MASK).w
                jsr     (clear_entity_buffer0_0x600_bytes).l
                move.b  #1,(word_FF8224).w
                move.b  #1,(word_FF8224+1).w
                move.w  #$C,CRTL_UNK50(a5)
                clr.w   CRTL_XPOS_SUBPIXEL(a5)
                clr.l   CRTL_XSPD(a5)
                clr.l   CRTL_YSPD(a5)
                btst    #button_LEFT,CRTL_DOWN(a5)
                bne.s   loc_1580C
                btst    #button_RIGHT,CRTL_DOWN(a5)
                bne.s   loc_1581C
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.s   loc_1581C
loc_1580C:                              ; CODE XREF: unused_pnx_state+3C   j
                move.l  #$FFF88000,CRTL_UNK48(a5)
                bclr    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bra.s   loc_1582A
; ---------------------------------------------------------------------------
loc_1581C:                              ; CODE XREF: unused_pnx_state+44   j unused_pnx_state+4C   j
                move.l  #$78000,CRTL_UNK48(a5)
                bset    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
loc_1582A:                              ; CODE XREF: unused_pnx_state+5C   j
                move.l  #word_E86AA,CRTL_SPRITE_PTR(a5)
                bsr.w   sub_158C6
                moveq   #1,d0
                rts
; End of function unused_pnx_state
; jumptable 00015060 case 43
pstate_pnx_end:                         ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                btst    #button_C,CRTL_PRESSED(a5)
                beq.s   loc_15848
                move.w  #7,CRTL_UNK50(a5)
loc_15848:                              ; CODE XREF: pstate_pnx_end+6   j
                subq.w  #1,CRTL_UNK4E(a5)
                bpl.w   loc_158A0
                jsr     (clear_entity_buffer0_0x600_bytes).l
                clr.w   CRTL_UNK4E(a5)
                cmpi.w  #7,CRTL_UNK50(a5)
                beq.s   loc_15866
                addq.w  #2,CRTL_UNK4E(a5)
loc_15866:                              ; CODE XREF: pstate_pnx_end+26   j
                move.w  #START_DASH,CRTL_PSTATE(a5)
                btst    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                beq.s   loc_1587A
                move.w  #R_START_DASH,CRTL_PSTATE(a5)
loc_1587A:                              ; CODE XREF: pstate_pnx_end+38   j
                tst.w   (GFX_HP_EMPTY_IDK).w
                bne.s   loc_15896
                btst    #7,(bounds_check_flag_FF8245).w
                bne.s   loc_15896
                move.l  #word_E8E6A,CRTL_SPRITE_PTR(a5)
                bsr.w   sub_173FA
                bra.s   loc_158A0
; ---------------------------------------------------------------------------
loc_15896:                              ; CODE XREF: pstate_pnx_end+44   j pstate_pnx_end+4C   j
                move.b  #$A6,d0
                jsr     (play_sfx_id_2).l
loc_158A0:                              ; CODE XREF: pstate_pnx_end+12   j pstate_pnx_end+5A   j
                move.w  #1,(word_FF809C).w
                bset    #6,CRTL_UNK21(a5)
                bset    #4,CRTL_UNK23(a5)
                bset    #4,(byte_FF8244).w
                clr.w   CRTL_VSTATE(a5)
                bsr.w   sub_16D60
                bsr.w   sub_16D40
                rts
; End of function pstate_pnx_end
sub_158C6:                              ; CODE XREF: unused_pnx_state+74   p
                movea.w #(PLAYER_STRUCT_COPY_IDK-M68K_RAM),a0
                moveq   #0,d7
                bsr.s   sub_158D4
next_entry:
                lea     $60(a0),a0
                addq.w  #2,d7
; End of function sub_158C6
sub_158D4:                              ; CODE XREF: sub_158C6+6   p
                move.w  #$10,(a0)
                clr.b   CRTL_UNK21(a0)
                move.w  #$C800,CRTL_UNK2(a0)
                move.l  #word_E8680,CRTL_SPRITE_PTR(a0)
                move.w  CRTL_SPRITE_FLAGS(a5),d0
                andi.w  #$FFFF,d0
                move.w  d0,CRTL_SPRITE_FLAGS(a0)
                move.b  CRTL_UNK20(a5),CRTL_UNK20(a0)
                subq.b  #4,CRTL_UNK20(a0)
                bpl.s   loc_15906
                clr.b   CRTL_UNK20(a0)
loc_15906:                              ; CODE XREF: sub_158D4+2C   j
                move.w  CRTL_XPOS(a5),CRTL_XPOS(a0)
                move.w  CRTL_YPOS(a5),CRTL_YPOS(a0)
                clr.w   $1A(a0)
                move.w  x_pos_15926(pc,d7.w),d0
                add.w   d0,CRTL_XPOS(a0)
                move.w  x_spd_1592A(pc,d7.w),CRTL_XSPD(a0)
                rts
; End of function sub_158D4
; ---------------------------------------------------------------------------
x_pos_15926:    dc.w   $20,$FFE0        ; DATA XREF: sub_158D4+42   r
x_spd_1592A:    dc.w $FFF8,    8        ; DATA XREF: sub_158D4+4A   r
reverse_dash:                           ; CODE XREF: reverse_dash_check+E   j pstate_rev_crouch+34   j
                move.w  #R_START_DASH,CRTL_PSTATE(a5)
                bra.s   loc_1593C
; ---------------------------------------------------------------------------
do_jump_dash:                           ; CODE XREF: pstate_counter_force+20   j jump_dash_check+1A   j ...
                move.w  #START_DASH,CRTL_PSTATE(a5)
loc_1593C:                              ; CODE XREF: reverse_dash+6   j
                move.b  #$73,(PCRTL_MASK).w ; 's'
                jsr     (clear_entity_buffer0_0x600_bytes).l
                move.b  #1,(word_FF8224).w
                move.b  #1,(word_FF8224+1).w
                clr.w   CRTL_UNK4E(a5)
                move.w  #$C,CRTL_UNK50(a5)
                clr.w   CRTL_XPOS_SUBPIXEL(a5)
                clr.l   CRTL_XSPD(a5)
                clr.l   CRTL_YSPD(a5)
                btst    #button_LEFT,CRTL_DOWN(a5)
                bne.s   loc_15982
                btst    #button_RIGHT,CRTL_DOWN(a5)
                bne.s   loc_15992
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.s   loc_15992
loc_15982:                              ; CODE XREF: reverse_dash+42   j
                move.l  #$FFF88000,CRTL_UNK48(a5)
                bclr    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bra.s   loc_159A0
; ---------------------------------------------------------------------------
loc_15992:                              ; CODE XREF: reverse_dash+4A   j reverse_dash+52   j
                move.l  #$78000,CRTL_UNK48(a5)
                bset    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
loc_159A0:                              ; CODE XREF: reverse_dash+62   j
                tst.w   (GFX_HP_EMPTY_IDK).w
                bne.s   loc_159C4
                btst    #7,(bounds_check_flag_FF8245).w
                bne.s   loc_159C4
                bsr.w   sub_173FA
                move.l  #word_E8E6A,CRTL_SPRITE_PTR(a5)
                move.w  #$78,(GFX_HP_EMPTY_IDK).w ; 'x'
                moveq   #1,d0
                rts
; ---------------------------------------------------------------------------
loc_159C4:                              ; CODE XREF: reverse_dash+76   j reverse_dash+7E   j
                move.b  #$A6,d0
                jsr     (play_sfx_id_2).l
                move.l  #word_E86AA,CRTL_SPRITE_PTR(a5)
                move.w  #$78,(GFX_HP_EMPTY_IDK).w ; 'x'
                moveq   #1,d0
                rts
; End of function reverse_dash
; jumptable 00015060 cases 8,18
pstate_dash:                            ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                tst.b   (byte_FF8311).w
                bne.s   loc_159F0
                subq.w  #1,CRTL_UNK50(a5)
                bmi.s   loc_159F0
                bra.w   loc_15A6E
; ---------------------------------------------------------------------------
loc_159F0:                              ; CODE XREF: pstate_dash+4   j pstate_dash+A   j
                bsr.w   sub_16D40
loc_159F4:                              ; CODE XREF: pstate_dash:loc_15A6C   j
                clr.w   (word_FFC5C0).w
                bclr    #0,(COUNTER_FLAG).w
                bclr    #6,CRTL_UNK21(a5)
                bclr    #4,CRTL_UNK23(a5)
                moveq   #0,d0
                btst    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                beq.s   loc_15A16
                moveq   #1,d0
loc_15A16:                              ; CODE XREF: pstate_dash+32   j
                btst    d0,CRTL_VSTATE(a5)
                bne.s   loc_15A46
                move.w  #$FFE0,CRTL_UNK52(a5)
                move.l  CRTL_UNK48(a5),CRTL_XSPD(a5)
                tst.w   CRTL_UNK4E(a5)
                beq.s   loc_15A38
                move.l  CRTL_XSPD(a5),d0
                asr.l   #1,d0
                move.l  d0,CRTL_XSPD(a5)
loc_15A38:                              ; CODE XREF: pstate_dash+4C   j
                btst    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                beq.w   loc_15C3C
                bra.w   reverse_jump_fall
; ---------------------------------------------------------------------------
loc_15A46:                              ; CODE XREF: pstate_dash+3A   j
                clr.w   (word_FF8224).w
                tst.w   CRTL_UNK4E(a5)
                bne.s   loc_15A5E
                btst    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                beq.w   sub_15AF4
                bra.w   sub_15AF4
; ---------------------------------------------------------------------------
loc_15A5E:                              ; CODE XREF: pstate_dash+6E   j
                btst    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                beq.w   loc_153DA
                bra.w   set_rev_crouch0
; ---------------------------------------------------------------------------
loc_15A6C:                              ; CODE XREF: pstate_dash+A4   j pstate_dash+AA   j ...
                bra.s   loc_159F4
; ---------------------------------------------------------------------------
loc_15A6E:                              ; CODE XREF: pstate_dash+C   j
                move.w  #1,(word_FF809C).w
                bset    #6,CRTL_UNK21(a5)
                bset    #4,CRTL_UNK23(a5)
                bsr.w   sub_15A9C
                bne.s   loc_15A6C
                bsr.w   sub_15A9C
                bne.s   loc_15A6C
                bsr.w   sub_15A9C
                bne.s   loc_15A6C
                bset    #4,(byte_FF8244).w
                bra.w   sub_177B6
; End of function pstate_dash
sub_15A9C:                              ; CODE XREF: pstate_dash+A0   p pstate_dash+A6   p ...
                clr.w   CRTL_VSTATE(a5)
                bsr.w   sub_16D60
                bsr.w   sub_16D40
                tst.w   CRTL_UNK48(a5)
                bmi.s   loc_15AB8
                btst    #1,CRTL_HSTATE(a5)
                beq.s   loc_15AC0
                rts
; ---------------------------------------------------------------------------
loc_15AB8:                              ; CODE XREF: sub_15A9C+10   j
                btst    #0,CRTL_HSTATE(a5)
                bne.s   locret_15AF2
loc_15AC0:                              ; CODE XREF: sub_15A9C+18   j
                move.l  CRTL_UNK48(a5),d0
                add.l   d0,CRTL_XPOS(a5)
                btst    #1,(bounds_check_flag_FF8245).w
                bne.s   loc_15AF0
                cmpi.w  #$1AF,CRTL_XPOS(a5)
                bmi.s   loc_15AE2
                move.w  #$1AF,CRTL_XPOS(a5)
                moveq   #0,d0
                rts
; ---------------------------------------------------------------------------
loc_15AE2:                              ; CODE XREF: sub_15A9C+3A   j
                cmpi.w  #$90,CRTL_XPOS(a5)
                bpl.s   loc_15AF0
                move.w  #$90,CRTL_XPOS(a5)
loc_15AF0:                              ; CODE XREF: sub_15A9C+32   j sub_15A9C+4C   j
                moveq   #0,d0
locret_15AF2:                           ; CODE XREF: sub_15A9C+22   j
                rts
; End of function sub_15A9C
sub_15AF4:                              ; CODE XREF: pstate_dash+76   j pstate_dash+7A   j ...
                move.b  #$7F,(PCRTL_MASK).w
                move.w  #MID_DASH,CRTL_PSTATE(a5)
                move.w  #4,CRTL_UNK5C(a5)
                move.l  #$FFFE0000,CRTL_XSPD(a5)
                tst.w   CRTL_UNK48(a5)
                bmi.s   loc_15B18
                neg.l   CRTL_XSPD(a5)
loc_15B18:                              ; CODE XREF: sub_15AF4+1E   j
                move.w  #2,CRTL_UNK48(a5)
                rts
; End of function sub_15AF4
; jumptable 00015060 cases 32,33
pstate_mid_dash:                        ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                bsr.w   sub_16D40
                moveq   #0,d0
                btst    #4,CRTL_SPRITE_FLAGS(a5)
                beq.s   loc_15B36
                moveq   #1,d0
loc_15B36:                              ; CODE XREF: pstate_mid_dash+12   j
                btst    d0,CRTL_VSTATE(a5)
                beq.w   sub_15C34
                move.l  #$4000,d1
                bsr.w   cap_speed_stop0
                tst.l   CRTL_XSPD(a5)
                bne.s   loc_15B5C
                btst    #4,CRTL_SPRITE_FLAGS(a5)
                beq.w   loc_153DA
                bra.w   set_rev_crouch0
; ---------------------------------------------------------------------------
loc_15B5C:                              ; CODE XREF: pstate_mid_dash+2C   j
                subq.w  #1,CRTL_UNK48(a5)
                bra.w   sub_16EF2
; End of function pstate_mid_dash
loco_ret_15B64:
                rts
; End of function loco_ret_15B64
sub_15B66:
                move.w  #pUNK_0x44,CRTL_PSTATE(a5)
                move.w  #4,CRTL_UNK5C(a5)
                bclr    #4,CRTL_SPRITE_FLAGS(a5)
                move.l  #$FFFCE000,CRTL_XSPD(a5)
                tst.w   CRTL_UNK48(a5)
                bmi.s   end
                neg.l   CRTL_XSPD(a5)
end:                                    ; CODE XREF: sub_15B66+1E   j
                rts
; End of function sub_15B66
; jumptable 00015060 case 34
pstate_unk44:                           ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CD8(pc)
                nop
                addi.l  #$8800,CRTL_YSPD(a5)
                bsr.w   sub_16CFE
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                beq.s   locret_15BB6
                bsr.w   sub_15AF4
                move.l  CRTL_XSPD(a5),d0
                asr.l   #1,d0
                move.l  d0,CRTL_XSPD(a5)
                rts
; ---------------------------------------------------------------------------
locret_15BB6:                           ; CODE XREF: pstate_unk44+18   j
                rts
; End of function pstate_unk44
jump_dash_check:                        ; CODE XREF: pstate_idle+1E   p pstate_crouch+20   p ...
                btst    #button_C,CRTL_PRESSED(a5)
                beq.s   end_15C1E
                btst    #button_DOWN,CRTL_DOWN(a5)
                beq.w   loc_15BF2
                move.b  CRTL_DOWN(a5),d0
                andi.b  #$C,d0
                bne.w   do_jump_dash
                btst    #6,(bounds_check_flag_FF8245).w
                bne.w   do_jump_dash
                btst    #VSTATE_ON_PLATFORM,CRTL_VSTATE(a5)
                beq.w   do_jump_dash
                bsr.w   clamber_down
                moveq   #1,d0
                rts
; ---------------------------------------------------------------------------
loc_15BF2:                              ; CODE XREF: jump_dash_check+E   j
                move.w  #JUMP,CRTL_PSTATE(a5)
                move.l  #$FFFA8000,CRTL_YSPD(a5)
                move.w  #$C,CRTL_UNK5C(a5)
                move.w  #5,CRTL_UNK48(a5)
                clr.w   CRTL_UNK4A(a5)
                clr.w   (word_FF8224).w
                clr.w   CRTL_UNK52(a5)
                move.b  #$7F,(PCRTL_MASK).w
end_15C1E:                              ; CODE XREF: jump_dash_check+6   j reverse_dash_check+6   j
                rts
; End of function jump_dash_check
reverse_dash_check:                     ; CODE XREF: pstate_rev_idle+20   p pstate_rev_skid+1C   p ...
                btst    #button_C,CRTL_PRESSED(a5)
                beq.s   end_15C1E
                btst    #button_UP,CRTL_DOWN(a5)
                bne.w   reverse_dash
                bra.s   sub_15C66
; End of function reverse_dash_check
sub_15C34:                              ; CODE XREF: pstate_idle+10   j pstate_crouch+16   j ...
                clr.w   (word_FF8224).w
                clr.w   CRTL_UNK52(a5)
loc_15C3C:                              ; CODE XREF: pstate_air_counter_force+48   j pstate_dash+5E   j ...
                bclr    #0,(COUNTER_FLAG).w
                move.w  #FALL,CRTL_PSTATE(a5)
                bclr    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                move.w  #$C,CRTL_UNK5C(a5)
                move.w  #$FFFF,CRTL_UNK48(a5)
                clr.w   CRTL_UNK4A(a5)
                move.b  #%1111111,(PCRTL_MASK).w
                rts
; End of function sub_15C34
sub_15C66:                              ; CODE XREF: reverse_dash_check+12   j
                bsr.s   reverse_jump
                move.l  #$20000,CRTL_YSPD(a5)
                rts
; End of function sub_15C66
reverse_jump:                           ; CODE XREF: sub_15C66   p pstate_rev_idle+12   j ...
                clr.w   (word_FF8224).w
                clr.w   CRTL_UNK52(a5)
reverse_jump_fall:                      ; CODE XREF: pstate_dash+62   j
                bclr    #0,(COUNTER_FLAG).w
                move.w  #R_JUMP_FALL,CRTL_PSTATE(a5)
                bclr    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                move.w  #$C,CRTL_UNK5C(a5)
                move.l  #$12000,CRTL_YSPD(a5)
                move.w  #$FFFF,CRTL_UNK48(a5)
                clr.w   CRTL_UNK4A(a5)
                move.b  #%1111111,(PCRTL_MASK).w
                rts
; End of function reverse_jump
clamber_down:                           ; CODE XREF: jump_dash_check+32   p
                bclr    #0,(COUNTER_FLAG).w
                move.w  #$FFE0,CRTL_UNK52(a5)
                move.w  #CLAMBER_DOWN,CRTL_PSTATE(a5)
                move.l  #$3A000,CRTL_YSPD(a5)
                move.w  #$C,CRTL_UNK5C(a5)
                move.w  #$FFFF,CRTL_UNK48(a5)
                move.w  #4,CRTL_UNK4A(a5)
                clr.w   (word_FF8224).w
                move.b  #%1111111,(PCRTL_MASK).w
                rts
; End of function clamber_down
pstate_airtime:                         ; CODE XREF: player_state_machine+E   j pstate_hurt+2E   j
                                        ; DATA XREF: ...
                bset    #0,(byte_FF8244).w ; jumptable 00015060 cases 3,4,10,20
                btst    #button_C,CRTL_DOWN(a5)
                bne.s   loc_15CF8
                move.w  #$FFFF,CRTL_UNK48(a5)
loc_15CF8:                              ; CODE XREF: pstate_airtime+C   j
                tst.w   CRTL_UNK48(a5)
                bmi.s   loc_15D0A
                subq.w  #1,CRTL_UNK48(a5)
                tst.l   CRTL_YSPD(a5)
                bmi.s   loc_15D3A
                bpl.s   loc_15D1E
loc_15D0A:                              ; CODE XREF: pstate_airtime+18   j
                addi.l  #$8800,CRTL_YSPD(a5)
loc_15D12:                              ; CODE XREF: pstate_pit+11C   j pstate_pit+128   j
                jsr     sub_16CD8(pc)
                nop
                tst.w   CRTL_YSPD(a5)
                bmi.s   loc_15D3A
loc_15D1E:                              ; CODE XREF: pstate_airtime+24   j
                tst.w   CRTL_UNK4A(a5)
                bmi.s   loc_15D2A
                subq.w  #1,CRTL_UNK4A(a5)
                bra.s   loc_15D60
; ---------------------------------------------------------------------------
loc_15D2A:                              ; CODE XREF: pstate_airtime+3E   j
                bsr.w   sub_16CFE
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_15502
                bra.s   loc_15D60
; ---------------------------------------------------------------------------
loc_15D3A:                              ; CODE XREF: pstate_airtime+22   j pstate_airtime+38   j
                clr.b   CRTL_VSTATE(a5)
                jsr     sub_16D2A(pc)
                nop
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_1663A
                btst    #VSTATE_ON_PLATFORM,CRTL_VSTATE(a5)
                beq.s   loc_15D60
                btst    #button_UP,CRTL_DOWN(a5)
                bne.w   sub_15E90
loc_15D60:                              ; CODE XREF: pstate_airtime+44   j pstate_airtime+54   j ...
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_152FC
                btst    #button_C,CRTL_PRESSED(a5) ; air_dash_check
                beq.s   loc_15D8E
                btst    #button_DOWN,CRTL_DOWN(a5)
                bne.s   loc_15D84
                tst.b   (word_FF8224+1).w
                bne.s   loc_15D8E
                bra.w   sub_15F6A
; ---------------------------------------------------------------------------
loc_15D84:                              ; CODE XREF: pstate_airtime+94   j
                tst.b   (word_FF8224).w
                bne.s   loc_15D8E
                bra.w   do_jump_dash
; ---------------------------------------------------------------------------
loc_15D8E:                              ; CODE XREF: pstate_airtime+8C   j pstate_airtime+9A   j ...
                tst.w   CRTL_UNK52(a5)
                bne.s   loc_15D9E
                btst    #button_B,CRTL_DOWN(a5)
                bne.w   loc_15DBE
loc_15D9E:                              ; CODE XREF: pstate_airtime+AE   j
                bsr.w   sub_15F04
                move.w  #2,d1
                tst.w   CRTL_UNK52(a5)
                bne.w   sub_171CA
                bsr.w   set_pl_upper_sprite_air
                bsr.w   set_pl_lower_sprite_air
                moveq   #0,d5
                moveq   #0,d6
                bra.w   set_player_sprite
; ---------------------------------------------------------------------------
loc_15DBE:                              ; CODE XREF: pstate_airtime+B6   j
                btst    #button_LEFT,CRTL_DOWN(a5)
                beq.s   loc_15DF0
loc_15DC6:                              ; CODE XREF: pstate_airtime+144   j
                move.l  #$FFFC8000,d1
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                beq.s   loc_15DDA
                move.l  #$FFFD4000,d1
loc_15DDA:                              ; CODE XREF: pstate_airtime+EE   j
                move.l  CRTL_XSPD(a5),d0
                bpl.s   loc_15DE8
                cmp.l   d1,d0
                bpl.s   loc_15DE8
                move.l  d1,d0
                bra.s   loc_15E2A
; ---------------------------------------------------------------------------
loc_15DE8:                              ; CODE XREF: pstate_airtime+FA   j pstate_airtime+FE   j
                subi.l  #$7777,d0
                bra.s   loc_15E2A
; ---------------------------------------------------------------------------
loc_15DF0:                              ; CODE XREF: pstate_airtime+E0   j
                btst    #button_RIGHT,CRTL_DOWN(a5)
                beq.s   loc_15E22
loc_15DF8:                              ; CODE XREF: pstate_airtime+142   j
                move.l  #loc_38000,d1
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.s   loc_15E0C
                move.l  #$2C000,d1
loc_15E0C:                              ; CODE XREF: pstate_airtime+120   j
                move.l  CRTL_XSPD(a5),d0
                bmi.s   loc_15E1A
                cmp.l   d1,d0
                bmi.s   loc_15E1A
                move.l  d1,d0
                bra.s   loc_15E2A
; ---------------------------------------------------------------------------
loc_15E1A:                              ; CODE XREF: pstate_airtime+12C   j pstate_airtime+130   j
                addi.l  #$7777,d0
                bra.s   loc_15E2A
; ---------------------------------------------------------------------------
loc_15E22:                              ; CODE XREF: pstate_airtime+112   j
                move.l  CRTL_XSPD(a5),d0
                bmi.s   loc_15DF8
                bne.s   loc_15DC6
loc_15E2A:                              ; CODE XREF: pstate_airtime+102   j pstate_airtime+10A   j ...
                move.l  d0,CRTL_XSPD(a5)
                bsr.w   set_pl_lower_sprite_air
                lea     (word_198D2).l,a4
                moveq   #$FFFFFFFF,d5
                moveq   #3,d6
                bra.w   sub_17274
; End of function pstate_airtime
set_pl_upper_sprite_air:                ; CODE XREF: pstate_airtime+CA   p
                tst.w   CRTL_YSPD(a5)
                bmi.s   rising
                cmpi.w  #3,CRTL_YSPD(a5)
                bmi.s   rising
falling:
                movea.l #pl_arms_in_air_map,a1
                rts
; ---------------------------------------------------------------------------
rising:                                 ; CODE XREF: set_pl_upper_sprite_air+4   j
                                        ; set_pl_upper_sprite_air+C   j
                movea.l #pl_arms_to_side_map,a1
                rts
; End of function set_pl_upper_sprite_air
set_pl_lower_sprite_air:                ; CODE XREF: pstate_airtime+CE   p pstate_airtime+14A   p
                move.w  CRTL_YSPD(a5),d0
                bpl.s   check
                neg.w   d0
check:                                  ; CODE XREF: set_pl_lower_sprite_air+4   j
                cmpi.w  #7,d0
                bpl.s   kick            ; if abs(y_spd) > 7, branch
                cmpi.w  #2,d0
                bmi.s   kick            ; if abs(y_spd) < 2, branch
                tst.w   CRTL_YSPD(a5)
                bmi.s   rising          ; if y_spd < 0, branch
default:
                movea.l #word_E8C6A,a2
                rts
; ---------------------------------------------------------------------------
kick:                                   ; CODE XREF: set_pl_lower_sprite_air+C   j
                                        ; set_pl_lower_sprite_air+12   j
                movea.l #word_E8C2A,a2
                rts
; ---------------------------------------------------------------------------
rising:                                 ; CODE XREF: set_pl_lower_sprite_air+18   j
                movea.l #word_E8C52,a2
                rts
; End of function set_pl_lower_sprite_air
sub_15E90:                              ; CODE XREF: pstate_airtime+78   j
                jsr     (sub_14534).l
                move.w  #CLAMBER_UP,CRTL_PSTATE(a5)
                move.l  #$FFF86000,CRTL_YSPD(a5)
                clr.l   CRTL_XSPD(a5)
                move.w  #6,CRTL_UNK52(a5)
                move.b  #%1111111,(PCRTL_MASK).w
                rts
; End of function sub_15E90
; jumptable 00015060 case 9
pstate_clamber_up:                      ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                bset    #0,(byte_FF8244).w
                addi.l  #$8800,CRTL_YSPD(a5)
                jsr     sub_16CD8(pc)
                nop
                tst.w   CRTL_YSPD(a5)
                bmi.s   loc_15EE0
                bsr.w   sub_16CFE
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_15502
                bra.s   loc_15EF4
; ---------------------------------------------------------------------------
loc_15EE0:                              ; CODE XREF: pstate_clamber_up+18   j
                clr.b   CRTL_VSTATE(a5)
                jsr     sub_16D2A(pc)
                nop
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_1663A
loc_15EF4:                              ; CODE XREF: pstate_clamber_up+28   j
                cmpi.w  #$38,CRTL_UNK52(a5) ; '8'
                bpl.w   sub_15C34
                moveq   #2,d1
                bra.w   sub_171D6
; End of function pstate_clamber_up
sub_15F04:                              ; CODE XREF: pstate_airtime:loc_15D9E   p
                btst    #button_LEFT,CRTL_DOWN(a5)
                beq.s   loc_15F30
                bclr    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                move.l  CRTL_XSPD(a5),d0
                bpl.s   loc_15F28
                cmpi.l  #$FFFC8000,d0
                bpl.s   loc_15F28
                move.l  #$FFFC8000,d0
                bra.s   loc_15F64
; ---------------------------------------------------------------------------
loc_15F28:                              ; CODE XREF: sub_15F04+12   j sub_15F04+1A   j ...
                subi.l  #$7777,d0
                bra.s   loc_15F64
; ---------------------------------------------------------------------------
loc_15F30:                              ; CODE XREF: sub_15F04+6   j
                btst    #button_RIGHT,CRTL_DOWN(a5)
                beq.s   loc_15F5C
                bset    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                move.l  CRTL_XSPD(a5),d0
                bmi.s   loc_15F54
                cmpi.l  #loc_38000,d0
                bmi.s   loc_15F54
                move.l  #loc_38000,d0
                bra.s   loc_15F64
; ---------------------------------------------------------------------------
loc_15F54:                              ; CODE XREF: sub_15F04+3E   j sub_15F04+46   j ...
                addi.l  #$7777,d0
                bra.s   loc_15F64
; ---------------------------------------------------------------------------
loc_15F5C:                              ; CODE XREF: sub_15F04+32   j
                move.l  CRTL_XSPD(a5),d0
                bmi.s   loc_15F54
                bne.s   loc_15F28
loc_15F64:                              ; CODE XREF: sub_15F04+22   j sub_15F04+2A   j ...
                move.l  d0,CRTL_XSPD(a5)
                rts
; End of function sub_15F04
sub_15F6A:                              ; CODE XREF: pstate_airtime+9C   j
                bclr    #0,(COUNTER_FLAG).w
                move.b  #$7F,(PCRTL_MASK).w
                move.w  #START_HOVER,CRTL_PSTATE(a5)
                move.l  CRTL_XSPD(a5),d0
                asr.l   #2,d0
                move.l  d0,CRTL_XSPD(a5)
                move.l  #$FFFE8000,CRTL_YSPD(a5)
                move.w  #$C,CRTL_UNK5C(a5)
                move.w  #$FFFF,CRTL_UNK48(a5)
                clr.w   CRTL_UNK4A(a5)
                move.w  #5,CRTL_UNK4C(a5)
                move.b  #1,(word_FF8224+1).w
                movea.w #(PLAYER_STRUCT_COPY_IDK-M68K_RAM),a0
                moveq   #7,d7
                jsr     (clear_96_byte_increments).l
                move.b  #$B0,d0
                jsr     (play_sfx_id_2).l
                bra.w   sub_17642
; End of function sub_15F6A
; jumptable 00015060 case 39
pstate_start_hover:                     ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                subq.w  #1,CRTL_UNK4C(a5)
                bpl.s   loc_15FE0
                move.w  #$46,CRTL_PSTATE(a5) ; 'F'
                clr.l   CRTL_XSPD(a5)
                clr.l   CRTL_YSPD(a5)
                bsr.w   set_pl_dir_based_on_firedir
                bra.w   pstate_hover    ; jumptable 00015060 case 35
; ---------------------------------------------------------------------------
loc_15FE0:                              ; CODE XREF: pstate_start_hover+4   j
                bset    #0,(byte_FF8244).w
                bset    #6,(byte_FF8244).w
                jsr     sub_16CD8(pc)
                nop
                addi.l  #$C000,CRTL_YSPD(a5)
                bmi.s   loc_16010
                clr.b   CRTL_VSTATE(a5)
loc_16000:                              ; DATA XREF: sub_4475A+4E6   o
                bsr.w   sub_16CFE
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_15502
                bra.s   loc_16022
; ---------------------------------------------------------------------------
loc_16010:                              ; CODE XREF: pstate_start_hover+36   j
                clr.b   CRTL_VSTATE(a5)
                bsr.w   sub_16D2A
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_1663A
loc_16022:                              ; CODE XREF: pstate_start_hover+4A   j
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_152FC
                btst    #button_C,CRTL_PRESSED(a5)
                beq.s   loc_16056
                tst.b   (word_FF8224).w
                bne.s   loc_16044
                btst    #button_DOWN,CRTL_DOWN(a5)
                bne.w   do_jump_dash
loc_16044:                              ; CODE XREF: pstate_start_hover+74   j
                move.l  #$FFF80000,CRTL_YSPD(a5)
                move.w  #$FFE0,CRTL_UNK52(a5)
                bra.w   loc_15C3C
; ---------------------------------------------------------------------------
loc_16056:                              ; CODE XREF: pstate_start_hover+6E   j
                movea.l #word_E8F3A,a2
                btst    #0,(word_FFA000+1).w
                bne.s   loc_1606A
                movea.l #word_E8F6A,a2
loc_1606A:                              ; CODE XREF: pstate_start_hover+9E   j
                btst    #button_B,CRTL_DOWN(a5)
                bne.w   loc_16086
                bsr.w   set_pl_dir_hover
                movea.l #word_E8972,a1
                moveq   #$FFFFFFFF,d5
                moveq   #$FFFFFFFE,d6
                bra.w   set_player_sprite
; ---------------------------------------------------------------------------
loc_16086:                              ; CODE XREF: pstate_start_hover+AC   j
                lea     (word_198B2).l,a4
                moveq   #0,d5
                moveq   #$FFFFFFFF,d6
                lea     off_172F8(pc),a0
                nop
                bra.w   loc_1727A
; End of function pstate_start_hover
; jumptable 00015060 case 35
pstate_hover:                           ; CODE XREF: player_state_machine+E   j pstate_start_hover+18   j
                                        ; DATA XREF: ...
                bset    #0,(byte_FF8244).w
                bset    #6,(byte_FF8244).w
                jsr     sub_16CD8(pc)
                nop
                clr.b   CRTL_VSTATE(a5)
                bsr.w   sub_16CFE
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_15502
                clr.b   CRTL_VSTATE(a5)
                bsr.w   sub_16D2A
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_1663A
                bsr.w   air_hang_fmove_mode_check
                bne.w   end
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_152FC
                btst    #button_C,CRTL_PRESSED(a5) ; air_hang_dash_check
                beq.s   loc_16116
                tst.b   (word_FF8224).w
                bne.s   loc_160FA
                btst    #button_DOWN,CRTL_DOWN(a5)
                bne.w   do_jump_dash
loc_160FA:                              ; CODE XREF: pstate_hover+54   j
                move.l  #$FFF80000,CRTL_YSPD(a5)
                bra.s   loc_1610C
; ---------------------------------------------------------------------------
                move.l  #$FFFD8000,CRTL_YSPD(a5)
loc_1610C:                              ; CODE XREF: pstate_hover+68   j
                move.w  #$FFE0,CRTL_UNK52(a5)
                bra.w   loc_15C3C
; ---------------------------------------------------------------------------
loc_16116:                              ; CODE XREF: pstate_hover+4E   j
                movea.l #word_E8F3A,a2
                btst    #0,(word_FFA000+1).w
                bne.s   loc_1612A
                movea.l #word_E8F6A,a2
loc_1612A:                              ; CODE XREF: pstate_hover+88   j
                btst    #button_B,CRTL_DOWN(a5)
                bne.w   loc_16146
                bsr.w   set_pl_dir_hover
                movea.l #word_E8972,a1
                moveq   #$FFFFFFFF,d5
                moveq   #$FFFFFFFE,d6
                bra.w   set_player_sprite
; ---------------------------------------------------------------------------
loc_16146:                              ; CODE XREF: pstate_hover+96   j
                lea     (word_198B2).l,a4
                moveq   #0,d5
                moveq   #$FFFFFFFF,d6
                lea     off_172F8(pc),a0
                nop
                bra.w   loc_1727A
; ---------------------------------------------------------------------------
end:                                    ; CODE XREF: pstate_hover+3A   j
                rts
; End of function pstate_hover
air_hang_fmove_mode_check:              ; CODE XREF: pstate_hover+36   p
                btst    #button_A,CRTL_PRESSED(a5)
                beq.s   loc_1617A
                btst    #button_DOWN,CRTL_DOWN(a5)
                beq.s   loc_16174
                bsr.w   fire_mode_change
                moveq   #0,d0
                rts
; ---------------------------------------------------------------------------
loc_16174:                              ; CODE XREF: air_hang_fmove_mode_check+E   j
                tst.w   (FORCE_CHG_COOLDOWN).w
                bmi.s   weapon_cycle_hover
loc_1617A:                              ; CODE XREF: air_hang_fmove_mode_check+6   j
                moveq   #0,d0
                rts
; ---------------------------------------------------------------------------
weapon_cycle_hover:                     ; CODE XREF: air_hang_fmove_mode_check+1C   j
                move.w  (FORCE_CURRENT).w,(FORCE_MENU_INIT_HOVER).w
                move.w  #$12,(FORCE_CHANGE).w
                move.b  #$7F,(PCRTL_MASK).w
                move.w  #0,(force_UNK8032).w
                move.w  #$FFEE,(force_UNK8034).w
                move.w  #$54,CRTL_PSTATE(a5) ; 'T'
                moveq   #1,d0
                rts
; End of function air_hang_fmove_mode_check
; jumptable 00015060 case 42
pstate_pnx_unk1:                        ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                bset    #0,(byte_FF8244).w
                bset    #6,(byte_FF8244).w
                jsr     sub_16CD8(pc)
                nop
                clr.b   CRTL_VSTATE(a5)
                bsr.w   sub_16CFE
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_15502
                clr.b   CRTL_VSTATE(a5)
                bsr.w   sub_16D2A
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                bne.w   sub_1663A
                cmpi.w  #$12,(FORCE_CHANGE).w
                bpl.s   loc_161EE
                move.w  #HOVER,CRTL_PSTATE(a5)
                bsr.w   set_pl_dir_based_on_firedir
loc_161EE:                              ; CODE XREF: pstate_pnx_unk1+3C   j
                movea.l #word_E8F3A,a2
                btst    #0,(word_FFA000+1).w
                bne.s   loc_16202
                movea.l #word_E8F6A,a2
loc_16202:                              ; CODE XREF: pstate_pnx_unk1+54   j
                movea.l #word_E8972,a1
                moveq   #$FFFFFFFF,d5
                moveq   #$FFFFFFFE,d6
                bra.w   set_player_sprite
; End of function pstate_pnx_unk1
player_16210:                           ; CODE XREF: update_player+72   p
                move.b  #$7F,(PCRTL_MASK).w
                move.w  #$8000,(PL_DEATH_STATE).w
                move.w  #TUMBLE,WALK_BACK(a5)
                move.b  #$80,CRTL_UNK21(a5)
                move.w  #4,CRTL_UNK5C(a5)
                clr.w   CRTL_UNK48(a5)
                clr.w   CRTL_UNK4A(a5)
                clr.w   CRTL_UNK52(a5)
                clr.l   CRTL_XSPD(a5)
                clr.l   CRTL_YSPD(a5)
                bset    #1,(byte_FF825C).w
                rts
; End of function player_16210
; jumptable 00015060 cases 25,26
pstate_tumble:                          ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                bset    #3,(byte_FF8244).w
                bclr    #0,(byte_FF825C).w
                bne.s   loc_1625C
                bra.w   loc_1629E
; ---------------------------------------------------------------------------
loc_1625C:                              ; CODE XREF: pstate_tumble+C   j
                bclr    #2,(byte_FF825C).w
                bne.s   loc_16286
                move.b  CRTL_PRESSED(a5),d0
                andi.b  #$2C,d0 ; ','
                beq.s   loc_16272
                addq.w  #1,CRTL_UNK4A(a5)
loc_16272:                              ; CODE XREF: pstate_tumble+22   j
                move.w  (word_FF824E).w,d0
                cmp.w   CRTL_UNK4A(a5),d0
                bpl.s   loc_16286
                bclr    #1,(byte_FF825C).w
                bra.w   loc_1629E
; ---------------------------------------------------------------------------
loc_16286:                              ; CODE XREF: pstate_tumble+18   j pstate_tumble+30   j
                bset    #1,(byte_FF825C).w
                move.w  (word_FF8250).w,CRTL_XPOS(a5)
                move.w  (word_FF8252).w,CRTL_YPOS(a5)
                moveq   #$FFFFFFFE,d1
                bra.w   sub_171D6
; ---------------------------------------------------------------------------
loc_1629E:                              ; CODE XREF: pstate_tumble+E   j pstate_tumble+38   j
                move.b  #$30,(byte_FF825D).w ; '0'
                bra.w   *+4
; End of function pstate_tumble
player_162A8:                           ; CODE XREF: update_player+64   p pstate_tumble+5A   j
                move.b  #$7F,(PCRTL_MASK).w
                bclr    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                move.w  #$8000,(PL_DEATH_STATE).w
                jsr     (clear_BFC0_0x660_bytes).l
                move.w  #HURT,CRTL_PSTATE(a5)
                move.w  #$C,CRTL_UNK48(a5)
                tst.w   CRTL_UNK5E(a5)
                bpl.s   loc_16312
                move.w  (word_FFA000).w,d0
                andi.w  #7,d0
                bne.s   loc_162E6
                move.b  #$19,d0
                jsr     (play_sfx_id_2).l
loc_162E6:                              ; CODE XREF: player_162A8+32   j
                move.l  #$FFFEA000,CRTL_YSPD(a5)
                tst.l   (dword_FF8300).w
                beq.s   loc_162FC
loc_162F4:                              ; CODE XREF: player_162A8+80   j
                move.l  (dword_FF8300).w,CRTL_XSPD(a5)
                rts
; ---------------------------------------------------------------------------
loc_162FC:                              ; CODE XREF: player_162A8+4A   j
                move.l  #$FFFF7000,CRTL_XSPD(a5)
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.s   locret_16310
                neg.l   CRTL_XSPD(a5)
locret_16310:                           ; CODE XREF: player_162A8+62   j
                rts
; ---------------------------------------------------------------------------
loc_16312:                              ; CODE XREF: player_162A8+28   j
                move.b  #$19,d0
                jsr     (play_sfx_id_2).l
                move.l  #$FFFE8000,CRTL_YSPD(a5)
                tst.w   (dword_FF8300).w
                bne.w   loc_162F4
                bra.s   loc_16344
; ---------------------------------------------------------------------------
                bmi.s   loc_1633A
                move.l  #$38000,CRTL_XSPD(a5)
                rts
; ---------------------------------------------------------------------------
loc_1633A:                              ; CODE XREF: player_162A8+86   j
                move.l  #$FFFC8000,CRTL_XSPD(a5)
                rts
; ---------------------------------------------------------------------------
loc_16344:                              ; CODE XREF: player_162A8+84   j
                move.l  #$FFFC8000,CRTL_XSPD(a5)
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.s   end
                neg.l   CRTL_XSPD(a5)
end:                                    ; CODE XREF: player_162A8+AA   j
                rts
; End of function player_162A8
; jumptable 00015060 case 21
pstate_hurt:                            ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                movea.l #word_E8BAA,a1
                movea.l #word_E89C2,a2
                moveq   #$FFFFFFFF,d5
                moveq   #$FFFFFFFF,d6
                bsr.w   set_player_sprite
                subq.w  #1,CRTL_UNK48(a5)
                bpl.s   loc_1638C
                bsr.w   loc_163BE
                bsr.w   sub_15C34
                move.b  #1,(word_FF8224).w
                move.b  #1,(word_FF8224+1).w
                bra.w   pstate_airtime
; ---------------------------------------------------------------------------
loc_1638C:                              ; CODE XREF: pstate_hurt+18   j
                addi.l  #$6000,CRTL_YSPD(a5)
                bsr.w   sub_16CD8
                tst.w   CRTL_YSPD(a5)
                bmi.s   loc_163B2
                bsr.w   sub_16CFE
                btst    #VSTATE_GROUNDED,CRTL_VSTATE(a5)
                beq.s   locret_163BC
                bsr.w   loc_163BE
                bra.w   sub_15502
; ---------------------------------------------------------------------------
loc_163B2:                              ; CODE XREF: pstate_hurt+42   j
                clr.b   CRTL_VSTATE(a5)
                jmp     sub_16D2A(pc)
; ---------------------------------------------------------------------------
                align 4
locret_163BC:                           ; CODE XREF: pstate_hurt+4E   j
                rts
; ---------------------------------------------------------------------------
loc_163BE:                              ; CODE XREF: pstate_hurt+1A   p pstate_hurt+50   p
                clr.w   (PL_DEATH_STATE).w
                move.w  #$CD00,CRTL_UNK2(a5)
                move.b  #$81,CRTL_UNK21(a5)
                rts
; ---------------------------------------------------------------------------
                rts
; End of function pstate_hurt
pstate_unk4A_0:                         ; CODE XREF: pstate_rev_counter_force+1A   j pstate_rev_crouch+66   j ...
                move.b  #%1111111,(PCRTL_MASK).w
                bclr    #0,(COUNTER_FLAG).w
                clr.w   (word_FF8224).w
                move.w  #R_IDLE,CRTL_PSTATE(a5)
                clr.l   CRTL_XSPD(a5)
                clr.w   CRTL_UNK48(a5)
                move.w  #$FFFF,CRTL_UNKC(a5)
                move.w  #$10,CRTL_UNK5C(a5)
                bra.w   set_pl_dir_based_on_firedir
; End of function pstate_unk4A_0
end_16400:                              ; CODE XREF: pstate_rev_idle+1E   j pstate_rev_idle+24   j
                rts
; End of function end_16400
; jumptable 00015060 case 12
pstate_rev_idle:                        ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                jsr     sub_16D14(pc)
                nop
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                beq.w   reverse_jump
                bsr.w   sub_17514
                bsr.w   reverse_fmove_check
                bne.s   end_16400
                bsr.w   reverse_dash_check
                bne.s   end_16400
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_1646C
                btst    #button_B,CRTL_DOWN(a5)
                beq.s   loc_16440
                tst.w   (FIRING_MODE).w
                bne.s   loc_1645E
loc_16440:                              ; CODE XREF: pstate_rev_idle+36   j
                btst    #button_UP,CRTL_DOWN(a5)
                bne.w   set_rev_crouch
                btst    #button_LEFT,CRTL_DOWN(a5)
                bne.w   sub_16782
                btst    #button_RIGHT,CRTL_DOWN(a5)
                bne.w   sub_16782
loc_1645E:                              ; CODE XREF: pstate_rev_idle+3C   j
                btst    #button_B,CRTL_DOWN(a5)
                beq.w   sub_16EC8
                bra.w   sub_17052
; ---------------------------------------------------------------------------
loc_1646C:                              ; CODE XREF: pstate_rev_idle+2C   j pstate_rev_crouch+3E   j ...
                bsr.w   sub_153BC
                move.b  #%1111111,(PCRTL_MASK).w
                jsr     (clear_entity_buffer0_0x600_bytes).l
                move.w  #R_COUNTER_FORCE,CRTL_PSTATE(a5)
                move.w  #65532,CRTL_UNK48(a5)
                move.w  #$A,CRTL_UNK4A(a5)
                move.w  #$FFFF,CRTL_UNKC(a5)
                move.w  #$10,CRTL_UNK5C(a5)
                move.l  #$FFFE0000,CRTL_XSPD(a5)
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.s   locret_164AE
                neg.l   CRTL_XSPD(a5)
locret_164AE:                           ; CODE XREF: pstate_rev_idle+A6   j
                rts
; End of function pstate_rev_idle
; jumptable 00015060 case 31
pstate_rev_counter_force:               ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                jsr     sub_16D14(pc)
                nop
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                beq.w   loc_1533A
                subq.w  #1,CRTL_UNK4A(a5)
                bmi.w   pstate_unk4A_0
                move.l  #$2000,d1
                bsr.w   cap_speed_stop0
                bra.w   sub_17334
; End of function pstate_rev_counter_force
sub_164DC:
                btst    #button_C,CRTL_PRESSED(a5)
                beq.s   end
                btst    #button_UP,CRTL_DOWN(a5)
                beq.s   end
                move.w  (HEALTH).w,d0
                sub.w   (MAX_HEALTH).w,d0
                move.w  d0,(GFX_HP_EMPTY_IDK).w
                moveq   #1,d0
end:                                    ; CODE XREF: sub_164DC+6   j sub_164DC+E   j
                rts
; End of function sub_164DC
set_rev_crouch:                         ; CODE XREF: pstate_rev_idle+44   j pstate_rev_skid+32   j ...
                move.w  #2,CRTL_UNK48(a5)
set_rev_crouch0:                        ; CODE XREF: pstate_dash+88   j pstate_mid_dash+38   j
                move.w  #R_CROUCH,CRTL_PSTATE(a5)
                bset    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                move.w  #$A,CRTL_UNK4A(a5)
                move.w  #$FFFF,CRTL_UNKC(a5)
                move.w  #$14,CRTL_UNK5C(a5)
                move.b  #%1111111,(PCRTL_MASK).w
                bra.w   set_pl_dir_based_on_firedir
; ---------------------------------------------------------------------------
end_1652A:                              ; CODE XREF: pstate_rev_crouch+20   j
                rts
; End of function set_rev_crouch
; jumptable 00015060 case 17
pstate_rev_crouch:                      ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                bset    #1,(byte_FF8244).w
                jsr     sub_16CC8(pc)
                nop
                jsr     sub_16D14(pc)
                nop
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                beq.w   reverse_jump
                bsr.w   reverse_fmove_check
                bne.s   end_1652A
                btst    #button_C,CRTL_PRESSED(a5) ; reverse_crouch_dash_jump_check
                beq.s   loc_16564
                btst    #button_UP,CRTL_DOWN(a5)
                beq.w   reverse_jump
                bra.w   reverse_dash
; ---------------------------------------------------------------------------
loc_16564:                              ; CODE XREF: pstate_rev_crouch+28   j
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_1646C
                bsr.w   cap_speed_stop
                subq.w  #1,CRTL_UNK48(a5)
                bpl.s   loc_16596
                move.w  #$FFFF,CRTL_UNK48(a5)
                btst    #button_B,CRTL_DOWN(a5)
                beq.s   loc_1658C
                tst.w   (FIRING_MODE).w
                bne.s   loc_16596
loc_1658C:                              ; CODE XREF: pstate_rev_crouch+58   j
                btst    #button_UP,CRTL_DOWN(a5)
                beq.w   pstate_unk4A_0
loc_16596:                              ; CODE XREF: pstate_rev_crouch+4A   j pstate_rev_crouch+5E   j
                btst    #button_B,CRTL_DOWN(a5)
                beq.w   sub_16EF2
                bra.w   sub_170BA
; End of function pstate_rev_crouch
sub_165A4:                              ; CODE XREF: pstate_unk26+68   j sub_16782+3A   j ...
                move.b  #%1111111,(PCRTL_MASK).w
                clr.w   (word_FF8224).w
                move.w  #R_SKID,CRTL_PSTATE(a5)
                clr.w   CRTL_UNK48(a5)
                move.w  #$10,CRTL_UNK5C(a5)
                bra.w   set_pl_dir_based_on_firedir
; End of function sub_165A4
; jumptable 00015060 case 15
pstate_rev_skid:                        ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                jsr     sub_16D14(pc)
                nop
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                beq.w   reverse_jump
                bsr.w   reverse_fmove_check
                bne.s   end_16638
                bsr.w   reverse_dash_check
                bne.s   end_16638
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_1646C
                btst    #button_UP,CRTL_DOWN(a5)
                bne.w   set_rev_crouch
                bsr.w   cap_speed_stop
                move.l  CRTL_XSPD(a5),d0
                bne.s   loc_1661A
                btst    #button_LEFT,CRTL_DOWN(a5)
                bne.w   loc_16792
                btst    #button_RIGHT,CRTL_DOWN(a5)
                bne.w   loc_16792
                bra.w   pstate_unk4A_0
; ---------------------------------------------------------------------------
loc_1661A:                              ; CODE XREF: pstate_rev_skid+3E   j
                btst    #button_B,CRTL_DOWN(a5)
                bne.w   loc_17132
                movea.l #word_E8972,a1
                movea.l #word_E89C2,a2
                moveq   #0,d5
                moveq   #6,d6
                bra.w   set_player_sprite
; ---------------------------------------------------------------------------
end_16638:                              ; CODE XREF: pstate_rev_skid+1A   j pstate_rev_skid+20   j ...
                rts
; End of function pstate_rev_skid
sub_1663A:                              ; CODE XREF: pstate_airtime+66   j pstate_clamber_up+3A   j ...
                move.b  #%1111111,(PCRTL_MASK).w
                clr.w   (word_FF8224).w
                move.w  #%100110,CRTL_PSTATE(a5)
                bset    #4,CRTL_SPRITE_FLAGS(a5)
                move.w  #2,CRTL_UNK48(a5)
                move.w  #6,CRTL_UNK4A(a5)
                move.w  #$14,CRTL_UNK5C(a5)
                move.b  #$B1,d0
                jsr     (play_sfx_id_2).l
                bra.w   set_pl_dir_based_on_firedir
; End of function sub_1663A
; jumptable 00015060 case 19
pstate_unk26:                           ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                jsr     sub_16D14(pc)
                nop
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                beq.w   reverse_jump
                bsr.w   reverse_fmove_check
                bne.s   end_16638
                bsr.w   reverse_dash_check
                bne.s   end_16638
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_1646C
                move.l  #$4000,d1
                bsr.w   cap_speed_stop0
                subq.w  #1,CRTL_UNK4A(a5)
                subq.w  #1,CRTL_UNK48(a5)
                bpl.s   loc_166DC
                btst    #button_UP,CRTL_DOWN(a5)
                beq.s   loc_166C4
                bsr.w   set_rev_crouch
                move.w  #$FFFF,CRTL_UNK48(a5)
                bra.s   loc_166DC
; ---------------------------------------------------------------------------
loc_166C4:                              ; CODE XREF: pstate_unk26+46   j
                btst    #button_LEFT,CRTL_DOWN(a5)
                bne.w   loc_16792
                btst    #button_RIGHT,CRTL_DOWN(a5)
                bne.w   loc_16792
                bra.w   sub_165A4
; ---------------------------------------------------------------------------
loc_166DC:                              ; CODE XREF: pstate_unk26+3E   j pstate_unk26+52   j
                btst    #button_B,CRTL_DOWN(a5)
                beq.w   sub_16EF2
                bra.w   sub_170BA
; End of function pstate_unk26
reverse_fmove_check:                    ; CODE XREF: pstate_rev_idle+1A   p pstate_rev_crouch+1C   p ...
                btst    #button_A,CRTL_PRESSED(a5)
                beq.s   end
                btst    #button_UP,CRTL_DOWN(a5)
                bne.w   loc_1676E
                tst.w   (FORCE_CHG_COOLDOWN).w
                bmi.s   reverse_weapon_cycle
end:                                    ; CODE XREF: reverse_fmove_check+6   j
                moveq   #0,d0
                rts
; ---------------------------------------------------------------------------
reverse_weapon_cycle:                   ; CODE XREF: reverse_fmove_check+16   j
                move.w  (FORCE_CURRENT).w,(FORCE_MENU_INIT_HOVER).w
                move.w  #$12,(FORCE_CHANGE).w
                move.b  #%1111111,(PCRTL_MASK).w
                move.w  #0,(force_UNK8032).w
                move.w  #0,(force_UNK8034).w
                clr.l   CRTL_XSPD(a5)
                clr.l   CRTL_YSPD(a5)
                move.w  #R_FMENU_IDLE,CRTL_PSTATE(a5)
                move.w  #$10,CRTL_UNK5C(a5)
                btst    #button_UP,CRTL_DOWN(a5)
                beq.s   loc_16746
                move.w  #$14,CRTL_UNK5C(a5)
loc_16746:                              ; CODE XREF: reverse_fmove_check+54   j
                moveq   #1,d0
                rts
; ---------------------------------------------------------------------------
pstate_rev_force_choose:                ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                cmpi.w  #$12,(FORCE_CHANGE).w ; jumptable 00015060 case 16
                bmi.w   pstate_unk4A_0
                jsr     sub_16CC8(pc)
                nop
                jsr     sub_16D14(pc)
                nop
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                beq.w   reverse_jump
                bra.w   sub_16EC8
; ---------------------------------------------------------------------------
loc_1676E:                              ; CODE XREF: reverse_fmove_check+E   j
                eori.w  #2,(FIRING_MODE).w
                move.b  #$A3,d0
                jsr     (play_sfx_id_2).l
                moveq   #0,d0
                rts
; End of function reverse_fmove_check
sub_16782:                              ; CODE XREF: pstate_rev_idle+4E   j pstate_rev_idle+58   j
                btst    #button_B,CRTL_DOWN(a5)
                beq.s   loc_167CA
                tst.w   (FIRING_MODE).w
                beq.s   loc_167A2
                rts
; ---------------------------------------------------------------------------
loc_16792:                              ; CODE XREF: pstate_rev_skid+46   j pstate_rev_skid+50   j ...
                btst    #button_B,CRTL_DOWN(a5)
                beq.s   loc_167CA
                tst.w   (FIRING_MODE).w
                bne.w   pstate_unk4A_0
loc_167A2:                              ; CODE XREF: sub_16782+C   j
                btst    #button_RIGHT,CRTL_DOWN(a5)
                beq.s   loc_167B6
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.w   loc_16878
                bra.s   loc_167CA
; ---------------------------------------------------------------------------
loc_167B6:                              ; CODE XREF: sub_16782+26   j
                btst    #button_LEFT,CRTL_DOWN(a5)
                beq.w   sub_165A4
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                beq.w   loc_16878
loc_167CA:                              ; CODE XREF: sub_16782+6   j sub_16782+16   j ...
                move.b  #%1111111,(PCRTL_MASK).w
                move.w  #R_WALK,CRTL_PSTATE(a5)
                move.w  #4,CRTL_UNK48(a5)
                move.w  #$FFFF,CRTL_UNKC(a5)
                move.w  #$10,CRTL_UNK5C(a5)
                bra.w   set_pl_dir_based_on_firedir
; ---------------------------------------------------------------------------
end_167EC:                              ; CODE XREF: pstate_rev_walk+1A   j pstate_rev_walk+20   j
                rts
; End of function sub_16782
; jumptable 00015060 case 13
pstate_rev_walk:                        ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                jsr     sub_16D14(pc)
                nop
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                beq.w   reverse_jump
                bsr.w   reverse_fmove_check
                bne.s   end_167EC
                bsr.w   reverse_dash_check
                bne.s   end_167EC
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_1646C
                btst    #button_UP,CRTL_DOWN(a5)
                bne.w   set_rev_crouch
                btst    #button_B,CRTL_DOWN(a5)
                beq.s   loc_16834
                tst.w   (FIRING_MODE).w
                bne.w   sub_165A4
loc_16834:                              ; CODE XREF: pstate_rev_walk+3C   j
                btst    #button_LEFT,CRTL_DOWN(a5)
                bne.s   loc_16846
                btst    #button_RIGHT,CRTL_DOWN(a5)
                beq.w   sub_165A4
loc_16846:                              ; CODE XREF: pstate_rev_walk+4C   j
                bsr.w   cap_x_speed_walk
                btst    #button_B,CRTL_DOWN(a5)
                beq.w   sub_16F36
                btst    #button_RIGHT,CRTL_DOWN(a5)
                beq.s   loc_1686A
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                beq.w   loc_16878
                bra.w   sub_1715A
; ---------------------------------------------------------------------------
loc_1686A:                              ; CODE XREF: pstate_rev_walk+6C   j
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.w   loc_16878
                bra.w   sub_1715A
; ---------------------------------------------------------------------------
loc_16878:                              ; CODE XREF: sub_16782+2E   j sub_16782+44   j ...
                move.w  #R_WALK_BACK,CRTL_PSTATE(a5)
                clr.w   CRTL_UNK48(a5)
                move.w  #$FFFF,CRTL_UNKC(a5)
                move.w  #$10,CRTL_UNK5C(a5)
end_1688E:                              ; CODE XREF: pstate_rev_walk_backwards+1A   j
                                        ; pstate_rev_walk_backwards+20   j
                rts
; End of function pstate_rev_walk
; jumptable 00015060 case 14
pstate_rev_walk_backwards:              ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                jsr     sub_16CC8(pc)
                nop
                jsr     sub_16D14(pc)
                nop
                btst    #VSTATE_REV_GROUNDED,CRTL_VSTATE(a5)
                beq.w   reverse_jump
                bsr.w   reverse_fmove_check
                bne.s   end_1688E
                bsr.w   reverse_dash_check
                bne.s   end_1688E
                btst    #0,(COUNTER_FLAG).w
                bne.w   loc_1646C
                btst    #button_UP,CRTL_DOWN(a5)
                bne.w   set_rev_crouch
                btst    #button_B,CRTL_DOWN(a5)
                beq.w   loc_167CA
                bsr.w   sub_16FCC
                btst    #button_LEFT,CRTL_DOWN(a5)
                beq.s   loc_168EA
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                beq.w   loc_167CA
                bra.w   cap_x_spd_walk_back_r
; ---------------------------------------------------------------------------
loc_168EA:                              ; CODE XREF: pstate_rev_walk_backwards+4A   j
                btst    #button_RIGHT,CRTL_DOWN(a5)
                beq.w   sub_165A4
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.w   loc_167CA
                bra.w   cap_x_spd_walk_back_l
; End of function pstate_rev_walk_backwards
; jumptable 00015060 case 36
pstate_rev_hover_idk:                   ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                bset    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                btst    #button_LEFT,(CRTL1_DOWN).w
                beq.s   loc_16918
                bclr    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                rts
; ---------------------------------------------------------------------------
loc_16918:                              ; CODE XREF: pstate_rev_hover_idk+C   j
                btst    #button_RIGHT,(CRTL1_DOWN).w
                beq.s   end
                bset    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
end:                                    ; CODE XREF: pstate_rev_hover_idk+1C   j
                rts
; End of function pstate_rev_hover_idk
; jumptable 00015060 case 37
; Attributes: thunk
pstate_unk4A:                           ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                bra.w   pstate_unk4A_0
; End of function pstate_unk4A
; jumptable 00015060 case 38
pstate_unk4C:                           ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                addi.l  #$8800,CRTL_YSPD(a5)
                bpl.w   sub_15C34
                bclr    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                bra.w   loc_16EF8
; End of function pstate_unk4C
; jumptable 00015060 case 40
pstate_pnx_start:                       ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                clr.w   (PL_DEATH_STATE).w
                move.b  #%1110000,(PCRTL_MASK).w
                bset    #0,(bounds_check_flag_FF8245).w
                move.w  #$CD00,CRTL_UNK2(a5)
                addq.w  #2,CRTL_PSTATE(a5)
                clr.w   CRTL_UNK48(a5)
                jsr     (clear_BFC0_0x660_bytes).l
                move.w  #$78,CRTL_XPOS(a5) ; 'x'
                move.w  #$100,CRTL_YPOS(a5)
                move.l  #$41000,CRTL_XSPD(a5)
                move.l  #$18000,CRTL_YSPD(a5)
                bset    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bclr    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                movea.w #(word_FFC5C0-M68K_RAM),a0
                move.w  #$230,(a0)
                move.b  #$54,$21(a0) ; 'T'
                move.w  #$4000,2(a0)
                move.l  #word_E8F22,8(a0)
                move.w  CRTL_SPRITE_FLAGS(a5),d0
                andi.w  #$FFFF,d0
                move.w  d0,$E(a0)
                eori.w  #$1000,$E(a0)
                move.b  CRTL_UNK20(a5),$20(a0)
                move.w  CRTL_XPOS(a5),$10(a0)
                move.w  CRTL_YPOS(a5),$14(a0)
                move.b  #$E0,d0
                jsr     (play_sfx_id_2).l
                move.l  #word_E8E6A,CRTL_SPRITE_PTR(a5)
pstate_pnx_unk0:                        ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                tst.w   CRTL_UNK48(a5)  ; jumptable 00015060 case 41
                bne.w   loc_16A0E
                subi.l  #$620,CRTL_YSPD(a5)
                subi.l  #$C00,CRTL_XSPD(a5)
                bset    #6,CRTL_UNK21(a5)
                bset    #4,CRTL_UNK23(a5)
                bset    #4,(byte_FF8244).w
                bra.w   sub_177B6
; ---------------------------------------------------------------------------
loc_16A0E:                              ; CODE XREF: pstate_pnx_start+A2   j
                bclr    #6,CRTL_UNK21(a5)
                bclr    #4,CRTL_UNK23(a5)
                jsr     (clear_BFC0_0x660_bytes).l
                bclr    #0,(bounds_check_flag_FF8245).w
                move.w  #$FFE0,CRTL_UNK52(a5)
                move.l  #$68000,CRTL_XSPD(a5)
                move.w  #$FFFF,CRTL_YSPD(a5)
                bra.w   loc_15C3C
; End of function pstate_pnx_start
; jumptable 00015060 case 44
pstate_speen:                           ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                moveq   #4,d1
                bra.w   sub_171CA
; End of function pstate_speen
; jumptable 00015060 case 45
pstate_speen_faster:                    ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                moveq   #$FFFFFFFC,d1
                bra.w   sub_171CA
; End of function pstate_speen_faster
; jumptable 00015060 case 46
pstate_phoenix0:                        ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                addq.w  #2,CRTL_PSTATE(a5)
                move.b  #%1110000,(PCRTL_MASK).w
                bset    #0,(bounds_check_flag_FF8245).w
                move.w  #$CD00,CRTL_UNK2(a5)
                jsr     (clear_BFC0_0x660_bytes).l
                move.w  #$120,CRTL_XPOS(a5)
                move.w  #$100,CRTL_YPOS(a5)
                bset    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bclr    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                move.l  #word_E8E6A,CRTL_SPRITE_PTR(a5)
pstate_phoenix1:                        ; CODE XREF: player_state_machine+E   j
                                        ; DATA XREF: ROM:pstate_jmp_tbl   o
                bset    #4,CRTL_UNK23(a5) ; jumptable 00015060 case 47
                move.l  #word_E8EBA,CRTL_SPRITE_PTR(a5)
                btst    #0,(word_FFA000+1).w
                bne.w   end
                move.l  #word_E8E6A,CRTL_SPRITE_PTR(a5)
end:                                    ; CODE XREF: pstate_phoenix0+50   j
                rts
; End of function pstate_phoenix0
kill_yourself_now:                      ; CODE XREF: update_player+34   j update_player+3C   j
                move.w  #2,(PL_DEATH_STATE).w
                move.w  #$100,CRTL_UNK2(a5)
                clr.b   CRTL_UNK21(a5)
                move.b  #$10,CRTL_UNK23(a5)
                move.w  #$30,CRTL_UNK48(a5) ; '0'
                move.b  #$1F,d0
                jmp     (play_sfx_id_2).l
; End of function kill_yourself_now
player_16ACE:                           ; CODE XREF: update_player+2C   j
                bclr    #7,CRTL_UNK2(a5)
                tst.w   CRTL_UNK48(a5)
                bmi.s   end
                subq.w  #1,CRTL_UNK48(a5)
                bne.s   loc_16AFC
                move.w  #1,(word_FF8230).w
                move.w  #$8002,(word_FF80F2).w
                clr.w   (word_FF80F0).w
                move.w  #$E000,(word_FF80F4).w
                move.b  #%10000000,(CRTL_FLAG).w
loc_16AFC:                              ; CODE XREF: player_16ACE+10   j
                jmp     update_ent_81
; ---------------------------------------------------------------------------
end:                                    ; CODE XREF: player_16ACE+A   j
                rts
; End of function player_16ACE
copy_controls:                          ; CODE XREF: update_player+1A   p
                tst.w   (CRTL_ENABLED).w
                bne.s   end
                move.b  (CRTL1_DOWN).w,CRTL_DOWN(a5)
                move.b  (CRTL1_PRESSED).w,CRTL_PRESSED(a5)
                move.b  (PCRTL_MASK).w,d0
                and.b   d0,CRTL_DOWN(a5)
                and.b   d0,CRTL_PRESSED(a5)
end:                                    ; CODE XREF: copy_controls+4   j
                rts
; End of function copy_controls
counterforce_check:                     ; CODE XREF: update_player:run_player_smachine   p
                                        ; player_19DAE:jump0   p
                subq.w  #1,(COUNTER_COOLDOWN).w
                bmi.s   counter_reset
                btst    #button_B,CRTL_PRESSED(a5)
                beq.s   end
                bset    #0,(COUNTER_FLAG).w
                bra.s   end
; ---------------------------------------------------------------------------
counter_reset:                          ; CODE XREF: counterforce_check+4   j
                move.w  #$FFFF,(COUNTER_COOLDOWN).w
                btst    #button_B,CRTL_PRESSED(a5)
                beq.s   end
                move.w  #$10,(COUNTER_COOLDOWN).w
end:                                    ; CODE XREF: counterforce_check+C   j counterforce_check+14   j ...
                move.w  (HEALTH).w,d0
                sub.w   (MAX_HEALTH).w,d0
                move.w  d0,(GFX_HP_EMPTY_IDK).w
                rts
; End of function counterforce_check
player_16B5C:                           ; CODE XREF: update_player:after_state_machine   p
                                        ; player_19DAE:y_neg   p
                btst    #5,(byte_FF8244).w
                bne.s   end
                bclr    #PFLAG_BOSS_FIGHT,CRTL_SPRITE_FLAGS(a5)
                move.w  (SPRITE_FLAGS_808A).w,d0
                or.w    d0,CRTL_SPRITE_FLAGS(a5)
end:                                    ; CODE XREF: player_16B5C+6   j
                rts
; End of function player_16B5C
pl_dma_queue_shenanigans:               ; CODE XREF: update_player+AE   p player_19DAE+48   p
                move.w  CRTL_UNK5C(a5),d0
                beq.s   end
                clr.w   CRTL_UNK5C(a5)
                subq.w  #4,d0
                move.l  dword_16BB2(pc,d0.w),d0
                btst    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                beq.s   loc_16BAC
                move.l  d0,(DMA_QUEUE_SRC0).w
                move.l  d0,(DMA_QUEUE_SRC1).w
                move.b  (DMA_QUEUE_SRC1).w,d1
                neg.b   d1
                move.b  d1,(DMA_QUEUE_SRC0+1).w
                move.b  (DMA_QUEUE_SRC1+1).w,d1
                neg.b   d1
                move.b  d1,(DMA_QUEUE_SRC0).w
                move.l  (DMA_QUEUE_SRC0).w,d0
loc_16BAC:                              ; CODE XREF: pl_dma_queue_shenanigans+16   j
                move.l  d0,CRTL_UNK28_Y(a5)
end:                                    ; CODE XREF: pl_dma_queue_shenanigans+4   j
                rts
; End of function pl_dma_queue_shenanigans
; ---------------------------------------------------------------------------
dword_16BB2:    dc.l $E01EF808,$FC1EF808,$E018F808,$E01CF808 ; DATA XREF: pl_dma_queue_shenanigans+C   r
                dc.l $FC1CF808,$E016F808,$E012F808
player_16BCE:                           ; CODE XREF: update_player+B6   j player_19DAE+52   j
                move.b  CRTL_UNK2A_X(a5),d0
                ext.w   d0
                move.b  CRTL_UNK2B_X(a5),d1
                ext.w   d1
                add.w   d1,d0
                asr.w   #1,d0
                add.w   CRTL_XPOS(a5),d0
                move.w  d0,(SOME_PL_X_VALUE).w
                move.b  CRTL_UNK28_Y(a5),d0
                ext.w   d0
                move.b  CRTL_UNK29_Y(a5),d1
                ext.w   d1
                add.w   d1,d0
                asr.w   #1,d0
                add.w   CRTL_YPOS(a5),d0
                move.w  d0,(SOME_PL_Y_VALUE).w
                rts
; End of function player_16BCE
player_16C00:                           ; CODE XREF: update_player+AA   p player_19DAE+42   p
                bset    #7,CRTL_UNK2(a5)
                subq.w  #1,CRTL_UNK5E(a5)
                bpl.s   jump
                move.w  #$FFFF,CRTL_UNK5E(a5)
                btst    #6,CRTL_UNK21(a5)
                bne.s   end
                bclr    #4,CRTL_UNK23(a5)
                rts
; ---------------------------------------------------------------------------
jump:                                   ; CODE XREF: player_16C00+A   j
                bset    #4,CRTL_UNK23(a5)
                btst    #5,(byte_FF8244).w
                bne.s   end
                btst    #0,(word_FFA000+1).w
                beq.s   end
                bclr    #7,CRTL_UNK2(a5)
end:                                    ; CODE XREF: player_16C00+18   j player_16C00+2E   j ...
                rts
; End of function player_16C00
set_pl_dir_hover:                       ; CODE XREF: pstate_start_hover+B0   p pstate_hover+9A   p ...
                btst    #button_LEFT,CRTL_DOWN(a5)
                beq.s   check_right
                bclr    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5) ; set x dir left
                rts
; ---------------------------------------------------------------------------
check_right:                            ; CODE XREF: set_pl_dir_hover+6   j
                btst    #button_RIGHT,CRTL_DOWN(a5)
                beq.w   end
                bset    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5) ; set x dir right
end:                                    ; CODE XREF: set_pl_dir_hover+16   j
                rts
; End of function set_pl_dir_hover
sub_16C62:                              ; CODE XREF: sub_177B6:loc_177D8   p sub_177B6+7A   p
                movea.w #(ENTITY_BUFFER0-M68K_RAM),a0
                moveq   #$B,d7
                jmp     entity_get_flag0
; End of function sub_16C62
set_some_fmode_palette:                 ; CODE XREF: update_player+54   p player_19DAE   p
                tst.w   (GFX_HP_EMPTY_IDK).w
                bne.s   loc_16C8C
                move.w  (word_FFA000).w,d0
                btst    #4,d0
                bne.s   loc_16C8C
                andi.w  #3,d0
                bne.s   loc_16C8C
                lea     pal_fmode_idk(pc),a0
                nop
                bra.s   loc_16C9E
; ---------------------------------------------------------------------------
loc_16C8C:                              ; CODE XREF: set_some_fmode_palette+4   j set_some_fmode_palette+E   j ...
                lea     pal_fmode_run(pc),a0
                nop
                tst.w   (FIRING_MODE).w
                beq.s   loc_16C9E
                lea     pal_fmode_fixed(pc),a0
                nop
loc_16C9E:                              ; CODE XREF: set_some_fmode_palette+1C   j
                                        ; set_some_fmode_palette+28   j
                movea.w #(PAL_2_COL_9-M68K_RAM),a1
                movea.w #(PAL1_2_COL_9-M68K_RAM),a2
                move.l  (a0),(a1)+
                move.l  (a0)+,(a2)+
                move.l  (a0),(a1)+
                move.l  (a0)+,(a2)+
                rts
; End of function set_some_fmode_palette
; ---------------------------------------------------------------------------
pal_fmode_run:  dc.w   $22,  $46, $488, $8CC ; DATA XREF: set_some_fmode_palette:loc_16C8C   o
pal_fmode_fixed:dc.w  $220, $442, $888, $CCC ; DATA XREF: set_some_fmode_palette+2A   o
pal_fmode_idk:  dc.w  $C88, $EAA, $ECC, $EEE ; DATA XREF: set_some_fmode_palette+16   o
sub_16CC8:                              ; CODE XREF: pstate_idle   p pstate_counter_force   p ...
                btst    #5,(bounds_check_flag_FF8245).w
                bne.w   end_16D7E
                jmp     sub_14648
; End of function sub_16CC8
sub_16CD8:                              ; CODE XREF: pstate_air_counter_force+8   p pstate_unk44   p ...
                btst    #5,(bounds_check_flag_FF8245).w
                bne.w   end_16D7E
                jmp     sub_1468A
; End of function sub_16CD8
sub_16CE8:                              ; CODE XREF: pstate_idle+6   p pstate_counter_force+6   p ...
                btst    #5,(bounds_check_flag_FF8245).w
                bne.w   end_16D7E
                jsr     (sub_142D8).l
                jmp     sub_146FC
; End of function sub_16CE8
sub_16CFE:                              ; CODE XREF: pstate_air_counter_force+14   p pstate_unk44+E   p ...
                btst    #5,(bounds_check_flag_FF8245).w
                bne.w   end_16D7E
                jsr     (sub_142D8).l
                jmp     sub_14760
; End of function sub_16CFE
sub_16D14:                              ; CODE XREF: pstate_rev_idle+6   p pstate_rev_counter_force+6   p ...
                btst    #5,(bounds_check_flag_FF8245).w
                bne.w   end_16D7E
                jsr     (sub_142D8).l
                jmp     sub_147D6
; End of function sub_16D14
sub_16D2A:                              ; CODE XREF: pstate_air_counter_force+28   p pstate_airtime+5A   p ...
                btst    #5,(bounds_check_flag_FF8245).w
                bne.w   end_16D7E
                jsr     (sub_142D8).l
                jmp     sub_1483A
; End of function sub_16D2A
sub_16D40:                              ; CODE XREF: pstate_pnx_end+86   p pstate_dash:loc_159F0   p ...
                btst    #5,(bounds_check_flag_FF8245).w
                bne.w   end_16D7E
                jsr     (sub_142D8).l
                btst    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                beq.w   sub_146FC       ; branch if not upside down
                jmp     sub_147D6
; End of function sub_16D40
sub_16D60:                              ; CODE XREF: pstate_pnx_end+82   p sub_15A9C+4   p
                btst    #5,(bounds_check_flag_FF8245).w
                bne.w   end_16D7E
                moveq   #$FFFFFFE8,d6
                btst    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                beq.w   loc_14694       ; branch if not upside down
                moveq   #$18,d6
                jmp     loc_14694
; ---------------------------------------------------------------------------
end_16D7E:                              ; CODE XREF: sub_16CC8+6   j sub_16CD8+6   j ...
                rts
; End of function sub_16D60
set_firing_direction:                   ; CODE XREF: update_player+58   p player_19DAE+6   p
                tst.w   (CRTL_ENABLED).w
                bne.w   end
                move.b  CRTL_DOWN(a5),d1
                move.w  (FIRING_MODE).w,d0
                beq.s   b_press_check
b_held_check:
                btst    #button_B,CRTL_DOWN(a5)
                bne.s   check_left
                rts
; ---------------------------------------------------------------------------
b_press_check:                          ; CODE XREF: set_firing_direction+10   j
                btst    #button_B,CRTL_PRESSED(a5)
                bne.s   check_left
                rts
; ---------------------------------------------------------------------------
check_left:                             ; CODE XREF: set_firing_direction+18   j set_firing_direction+22   j
                btst    #button_LEFT,d1
                beq.s   check_right
                bclr    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bclr    #button_RIGHT,d1
                bra.s   find_fire_dir
; ---------------------------------------------------------------------------
check_right:                            ; CODE XREF: set_firing_direction+2A   j
                btst    #button_RIGHT,d1
                beq.s   find_fire_dir
                bset    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bclr    #button_LEFT,d1
find_fire_dir:                          ; CODE XREF: set_firing_direction+36   j set_firing_direction+3C   j
                andi.w  #$F,d1
                bne.s   fire_dir_map
                moveq   #4,d0
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                beq.s   set_fire_dir
                moveq   #0,d0
                bra.s   set_fire_dir
; ---------------------------------------------------------------------------
fire_dir_map:                           ; CODE XREF: set_firing_direction+4C   j
                move.b  fdir_mapping(pc,d1.w),d0
set_fire_dir:                           ; CODE XREF: set_firing_direction+56   j set_firing_direction+5A   j
                move.b  d0,CRTL_FIRE_DIR(a5)
end:                                    ; CODE XREF: set_firing_direction+4   j
                rts
; End of function set_firing_direction
; ---------------------------------------------------------------------------
fdir_mapping:   dc.b   0,  6,  2,  0    ; DATA XREF: set_firing_direction:fire_dir_map   r
                dc.b   4,  5,  3,  0
                dc.b   0,  7,  1,  0
                dc.b   0,  0,  0,  0
set_pl_dir_based_on_firedir:            ; CODE XREF: sub_151EE+2A   j sub_153D4+2E   j ...
                tst.w   (FIRING_MODE).w
                bne.s   end             ; if firing mode is fixed, return
                btst    #button_B,CRTL_DOWN(a5)
                beq.s   end             ; if b is not being held down, return
                move.b  CRTL_FIRE_DIR(a5),d0
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                beq.s   left_update     ; if facing left, branch
right_update:
                cmpi.b  #FDIR_SOUTHWEST,d0
                bmi.s   end
                cmpi.b  #FDIR_NORTH,d0
                bmi.s   change_dir
                rts
; ---------------------------------------------------------------------------
left_update:                            ; CODE XREF: set_pl_dir_based_on_firedir+18   j
                cmpi.b  #FDIR_SOUTH,d0
                bmi.s   change_dir
                cmpi.b  #FDIR_NORTHEAST,d0
                bpl.s   change_dir
                rts
; ---------------------------------------------------------------------------
change_dir:                             ; CODE XREF: set_pl_dir_based_on_firedir+24   j
                                        ; set_pl_dir_based_on_firedir+2C   j ...
                eori.w  #%100000000000,CRTL_SPRITE_FLAGS(a5)
end:                                    ; CODE XREF: set_pl_dir_based_on_firedir+4   j
                                        ; set_pl_dir_based_on_firedir+C   j ...
                rts
; End of function set_pl_dir_based_on_firedir
cap_x_speed_walk:                       ; CODE XREF: sub_1564C:loc_1570E   p pstate_rev_walk:loc_16846   p
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                bne.s   walk_right
walk_left:
                move.l  CRTL_XSPD(a5),d0
                bpl.s   walk_l_subtract
                cmpi.l  #$FFFBE000,d0
                bmi.s   set_speed
walk_l_subtract:                        ; CODE XREF: cap_x_speed_walk+C   j
                subi.l  #$A800,d0
                move.l  d0,CRTL_XSPD(a5)
                rts
; ---------------------------------------------------------------------------
walk_right:                             ; CODE XREF: cap_x_speed_walk+6   j
                move.l  CRTL_XSPD(a5),d0
                bmi.s   walk_r_add
                cmpi.l  #$42000,d0
                bpl.s   set_speed
walk_r_add:                             ; CODE XREF: cap_x_speed_walk+26   j
                addi.l  #$A800,d0
set_speed:                              ; CODE XREF: cap_x_speed_walk+14   j cap_x_speed_walk+2E   j
                move.l  d0,CRTL_XSPD(a5)
                rts
; End of function cap_x_speed_walk
cap_x_spd_walk_back_r:                  ; CODE XREF: pstate_walk_backwards+4A   j
                                        ; pstate_rev_walk_backwards+56   j
                move.l  CRTL_XSPD(a5),d0
                bpl.s   subtract_spd
                cmpi.l  #$FFFD6000,d0
                bmi.s   set_speed
subtract_spd:                           ; CODE XREF: cap_x_spd_walk_back_r+4   j
                subi.l  #$A800,d0
set_speed:                              ; CODE XREF: cap_x_spd_walk_back_r+C   j
                move.l  d0,CRTL_XSPD(a5)
                rts
; End of function cap_x_spd_walk_back_r
cap_x_spd_walk_back_l:                  ; CODE XREF: pstate_walk_backwards+62   j
                                        ; pstate_rev_walk_backwards+6E   j
                move.l  CRTL_XSPD(a5),d0
                bmi.s   add_spd
                cmpi.l  #$2A000,d0
                bpl.s   set_speed
add_spd:                                ; CODE XREF: cap_x_spd_walk_back_l+4   j
                addi.l  #$A800,d0
set_speed:                              ; CODE XREF: cap_x_spd_walk_back_l+C   j
                move.l  d0,CRTL_XSPD(a5)
                rts
; End of function cap_x_spd_walk_back_l
cap_speed_stop:                         ; CODE XREF: pstate_crouch+30   p pstate_skid+34   p ...
                move.l  #$C000,d1
cap_speed_stop0:                        ; CODE XREF: pstate_counter_force+2A   p
                                        ; pstate_air_counter_force+52   p ...
                move.l  CRTL_XSPD(a5),d0
                bmi.s   spd_neg
spd_pos:
                sub.l   d1,d0
                bpl.s   set_speed
                moveq   #0,d0
                move.l  d0,CRTL_XSPD(a5)
                rts
; ---------------------------------------------------------------------------
spd_neg:                                ; CODE XREF: cap_speed_stop+A   j
                add.l   d1,d0
                bmi.s   set_speed
                moveq   #0,d0
set_speed:                              ; CODE XREF: cap_speed_stop+E   j cap_speed_stop+1A   j
                move.l  d0,CRTL_XSPD(a5)
                rts
; End of function cap_speed_stop
sub_16EC8:                              ; CODE XREF: pstate_idle+60   j pstate_force_choose+1E   j ...
                move.w  (word_FFA000).w,d0
                asr.w   #2,d0
                andi.w  #6,d0
                move.b  byte_16EEA(pc,d0.w),d5
                move.b  byte_16EEA+1(pc,d0.w),d6
                movea.l #word_E8972,a1
                movea.l #word_E8942,a2
                bra.w   set_player_sprite
; End of function sub_16EC8
; ---------------------------------------------------------------------------
byte_16EEA:     dc.b   1,$FE            ; DATA XREF: sub_16EC8+A   r sub_16EC8+E   r
                dc.b   0,$FF
                dc.b   0,  0
                dc.b   0,$FF
sub_16EF2:                              ; CODE XREF: pstate_crouch+5E   j pstate_land+76   j ...
                tst.w   CRTL_UNK48(a5)
                bpl.s   loc_16F1A
loc_16EF8:                              ; CODE XREF: pstate_unk4C+12   j
                move.w  (word_FFA000).w,d0
                asr.w   #2,d0
                andi.w  #6,d0
                move.b  byte_16F2E(pc,d0.w),d5
                move.b  byte_16F2E+1(pc,d0.w),d6
                movea.l #word_E8972,a1
                movea.l #word_E8F0A,a2
                bra.w   set_player_sprite
; ---------------------------------------------------------------------------
loc_16F1A:                              ; CODE XREF: sub_16EF2+4   j
                moveq   #0,d5
                moveq   #8,d6
                movea.l #word_E8972,a1
                movea.l #word_E89C2,a2
                bra.w   set_player_sprite
; End of function sub_16EF2
; ---------------------------------------------------------------------------
byte_16F2E:     dc.b   1, $F            ; DATA XREF: sub_16EF2+10   r sub_16EF2+14   r
                dc.b   0,$10
                dc.b   0,$11
                dc.b   0,$10
sub_16F36:                              ; CODE XREF: sub_1564C+CC   j pstate_rev_walk+62   j
                bclr    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                btst    #button_LEFT,CRTL_DOWN(a5)
                bne.s   loc_16F4A
                bset    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
loc_16F4A:                              ; CODE XREF: sub_16F36+C   j
                subq.w  #1,CRTL_UNKC(a5)
                bmi.s   loc_16F52
                rts
; ---------------------------------------------------------------------------
loc_16F52:                              ; CODE XREF: sub_16F36+18   j
                move.w  #3,CRTL_UNKC(a5)
                addq.w  #4,CRTL_UNK48(a5)
                andi.w  #$1C,CRTL_UNK48(a5)
                move.w  CRTL_UNK48(a5),d1
                cmpi.w  #$10,d1
                beq.s   loc_16F72
                cmpi.w  #0,d1
                bne.s   loc_16F7C
loc_16F72:                              ; CODE XREF: sub_16F36+34   j
                move.b  #$D6,d0
                jsr     (play_sfx_id_2).l
loc_16F7C:                              ; CODE XREF: sub_16F36+3A   j
                movea.l off_16F8C(pc,d1.w),a1
                movea.l off_16FAC(pc,d1.w),a2
                moveq   #0,d5
                moveq   #0,d6
                bra.w   set_player_sprite
; End of function sub_16F36
; ---------------------------------------------------------------------------
off_16F8C:      dc.l word_E86FA,word_E871A,word_E873A,word_E8762 ; DATA XREF: sub_16F36:loc_16F7C   r
                dc.l word_E8782,word_E87A2,word_E87C2,word_E86E2
off_16FAC:      dc.l word_E8812,word_E8842,word_E886A,word_E889A ; DATA XREF: sub_16F36+4A   r
                                        ; sub_1717A:loc_171AA   o
                dc.l word_E88C2,word_E88EA,word_E891A,word_E87EA
sub_16FCC:                              ; CODE XREF: pstate_rev_walk_backwards+40   p
                bsr.s   sub_16FEC
                moveq   #1,d5
                addq.w  #3,d6
                lea     (word_198F2).l,a4
                bra.w   sub_17274
; End of function sub_16FCC
sub_16FDC:                              ; CODE XREF: pstate_walk_backwards+34   p
                bsr.s   sub_16FEC
                moveq   #1,d5
                addq.w  #3,d6
                lea     (word_198B2).l,a4
                bra.w   sub_17274
; End of function sub_16FDC
sub_16FEC:                              ; CODE XREF: sub_16FCC   p sub_16FDC   p
                move.w  CRTL_UNK48(a5),d1
                subq.w  #1,CRTL_UNKC(a5)
                bpl.s   loc_17022
                move.w  #4,CRTL_UNKC(a5)
                addq.w  #4,CRTL_UNK48(a5)
                cmpi.w  #$18,CRTL_UNK48(a5)
                bmi.s   loc_1700C
                clr.w   CRTL_UNK48(a5)
loc_1700C:                              ; CODE XREF: sub_16FEC+1A   j
                cmpi.w  #0,d1
                beq.s   loc_17018
                cmpi.w  #$C,d1
                bne.s   loc_17022
loc_17018:                              ; CODE XREF: sub_16FEC+24   j
                move.b  #$D6,d0
                jsr     (play_sfx_id_2).l
loc_17022:                              ; CODE XREF: sub_16FEC+8   j sub_16FEC+2A   j
                movea.l off_1703A(pc,d1.w),a2
                asr.w   #1,d1
                move.w  word_1702E(pc,d1.w),d6
                rts
; End of function sub_16FEC
; ---------------------------------------------------------------------------
word_1702E:     dc.w $FFFF,$FFFF,    0,$FFFF ; DATA XREF: sub_16FEC+3C   r
                dc.w $FFFF,    0
off_1703A:      dc.l word_E8CC2,word_E8CDA,word_E8CEA,word_E8D12 ; DATA XREF: sub_16FEC:loc_17022   r
                dc.l word_E8D2A,word_E8992
sub_17052:                              ; CODE XREF: pstate_rev_idle+66   j
                tst.w   (FIRING_MODE).w
                beq.s   loc_17072
                lea     (word_198F2).l,a4
                moveq   #0,d5
                moveq   #0,d6
                lea     off_172F8(pc),a0
                nop
                movea.l #word_E8942,a2
                bra.w   loc_1727A
; ---------------------------------------------------------------------------
loc_17072:                              ; CODE XREF: sub_17052+4   j
                lea     (word_19912).l,a4
                moveq   #$FFFFFFFF,d5
                moveq   #4,d6
                movea.l #word_E8992,a2
                bra.w   sub_17274
; End of function sub_17052
sub_17086:                              ; CODE XREF: pstate_idle+64   j
                tst.w   (FIRING_MODE).w
                beq.s   loc_170A6
                lea     (word_198B2).l,a4
                moveq   #0,d5
                moveq   #0,d6
                lea     off_172F8(pc),a0
                nop
                movea.l #word_E8942,a2
                bra.w   loc_1727A
; ---------------------------------------------------------------------------
loc_170A6:                              ; CODE XREF: sub_17086+4   j
                lea     (word_198D2).l,a4
                moveq   #$FFFFFFFF,d5
                moveq   #4,d6
                movea.l #word_E8992,a2
                bra.w   sub_17274
; End of function sub_17086
sub_170BA:                              ; CODE XREF: pstate_rev_crouch+74   j pstate_unk26+76   j
                tst.w   CRTL_UNK48(a5)
                bpl.w   loc_17132
                tst.w   (FIRING_MODE).w
                beq.s   loc_170E2
                lea     (word_19902).l,a4
                moveq   #0,d5
                moveq   #$11,d6
                lea     off_172F8(pc),a0
                nop
                movea.l #word_E8F0A,a2
                bra.w   loc_1727A
; ---------------------------------------------------------------------------
loc_170E2:                              ; CODE XREF: sub_170BA+C   j
                lea     (word_19922).l,a4
                moveq   #$FFFFFFFF,d5
                moveq   #$13,d6
                movea.l #word_E89F2,a2
                bra.w   sub_17274
; ---------------------------------------------------------------------------
loc_170F6:                              ; CODE XREF: pstate_crouch+62   j pstate_land+7A   j
                tst.w   CRTL_UNK48(a5)
                bpl.w   sub_17146
                tst.w   (FIRING_MODE).w
                beq.s   loc_1711E
                lea     (word_198C2).l,a4
                moveq   #0,d5
                moveq   #$11,d6
                lea     off_172F8(pc),a0
                nop
                movea.l #word_E8F0A,a2
                bra.w   loc_1727A
; ---------------------------------------------------------------------------
loc_1711E:                              ; CODE XREF: sub_170BA+48   j
                lea     (word_198E2).l,a4
                moveq   #0,d5
                moveq   #$13,d6
                movea.l #word_E89F2,a2
                bra.w   sub_17274
; ---------------------------------------------------------------------------
loc_17132:                              ; CODE XREF: pstate_rev_skid+5E   j sub_170BA+4   j
                movea.l #word_E89C2,a2
                moveq   #0,d5
                moveq   #$C,d6
                lea     (word_19912).l,a4
                bra.w   sub_17274
; End of function sub_170BA
sub_17146:                              ; CODE XREF: pstate_skid+5C   j sub_170BA+40   j
                movea.l #word_E89C2,a2
                moveq   #0,d5
                moveq   #$C,d6
                lea     (word_198D2).l,a4
                bra.w   sub_17274
; End of function sub_17146
sub_1715A:                              ; CODE XREF: pstate_rev_walk+78   j pstate_rev_walk+86   j
                bsr.s   sub_1717A
                moveq   #$FFFFFFFF,d5
                addq.w  #3,d6
                lea     (word_19912).l,a4
                bra.w   sub_17274
; End of function sub_1715A
sfx_pl_step:                            ; CODE XREF: sub_1564C+E2   j sub_1564C+F0   j
                bsr.s   sub_1717A
                moveq   #$FFFFFFFF,d5
                addq.w  #3,d6
                lea     (word_198D2).l,a4
                bra.w   sub_17274
; End of function sfx_pl_step
sub_1717A:                              ; CODE XREF: sub_1715A   p sfx_pl_step   p
                move.w  CRTL_UNK48(a5),d1
                subq.w  #1,CRTL_UNKC(a5)
                bpl.s   loc_171AA
                move.w  #3,CRTL_UNKC(a5)
                addq.w  #4,CRTL_UNK48(a5)
                andi.w  #$1C,CRTL_UNK48(a5)
                cmpi.w  #$10,d1
                beq.s   loc_171A0
                cmpi.w  #0,d1
                bne.s   loc_171AA
loc_171A0:                              ; CODE XREF: sub_1717A+1E   j
                move.b  #$D6,d0
                jsr     (play_sfx_id_2).l
loc_171AA:                              ; CODE XREF: sub_1717A+8   j sub_1717A+24   j
                lea     off_16FAC(pc),a2
                movea.l (a2,d1.w),a2
                asr.w   #1,d1
                move.w  word_171BA(pc,d1.w),d6
                rts
; End of function sub_1717A
; ---------------------------------------------------------------------------
word_171BA:     dc.w $FFFE,$FFFF,    0,$FFFF ; DATA XREF: sub_1717A+3A   r
                dc.w $FFFE,$FFFF,    0,$FFFF
sub_171CA:                              ; CODE XREF: pstate_airtime+C6   j pstate_speen+2   j ...
                bsr.s   sub_171D6
                tst.w   CRTL_UNK52(a5)
                beq.w   set_pl_dir_based_on_firedir
                rts
; End of function sub_171CA
sub_171D6:                              ; CODE XREF: pstate_clamber_up+4A   j pstate_tumble+50   j ...
                move.w  CRTL_UNK52(a5),d0
                add.w   d1,d0
                move.w  d0,CRTL_UNK52(a5)
                andi.w  #$1C,d0
                move.l  off_171EC(pc,d0.w),CRTL_SPRITE_PTR(a5)
                rts
; End of function sub_171D6
; ---------------------------------------------------------------------------
off_171EC:      dc.l word_E8A1A,word_E8A4A,word_E8A82,word_E8ABA ; DATA XREF: sub_171D6+E   r
                dc.l word_E8AE2,word_E8B12,word_E8B4A,word_E8B82
sub_1720C:                              ; CODE XREF: pstate_pit:no_pit_button   j
                movea.w #(word_FFA100-M68K_RAM),a0
                movea.w a0,a1
                move.w  CRTL_UNK48(a5),d0
                move.w  CRTL_XPOS(a5),d1
                addi.w  #-$10,d1
loc_1721E:                              ; CODE XREF: sub_1720C+18   j
                bsr.w   sub_17262
                subq.w  #1,d0
                bpl.s   loc_1721E
                move.w  #$FFFF,(a1)+
                jsr     (gfx_insert_sprite_258C).l
                move.w  (word_FFA000).w,d0
                asl.w   #2,d0
                andi.w  #$1C,d0
                move.l  off_17242(pc,d0.w),CRTL_SPRITE_PTR(a5)
                rts
; End of function sub_1720C
; ---------------------------------------------------------------------------
off_17242:      dc.l word_E8F9A,word_E8FC2,word_E8FEA,word_E9012 ; DATA XREF: sub_1720C+2E   r
                dc.l word_E903A,word_E904A,word_E905A,word_E906A
sub_17262:                              ; CODE XREF: sub_1720C:loc_1721E   p
                move.w  #$138,(a1)+
                move.w  #0,(a1)+
                move.w  #$CFDB,(a1)+
                move.w  d1,(a1)+
                addq.w  #8,d1
                rts
; End of function sub_17262
sub_17274:                              ; CODE XREF: pstate_airtime+158   j sub_16FCC+C   j ...
                lea     off_172BC(pc),a0
                nop
loc_1727A:                              ; CODE XREF: pstate_start_hover+D2   j pstate_hover+BC   j ...
                lea     word_176E2(pc),a1
                nop
set_pl_sprite_idk:
                btst    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                beq.s   loc_1728E
                lea     word_176F2(pc),a1
                nop
loc_1728E:                              ; CODE XREF: sub_17274+12   j
                moveq   #0,d1
                move.b  CRTL_FIRE_DIR(a5),d1
                asl.w   #1,d1
                move.w  (a1,d1.w),d0
                movea.l (a0,d0.w),a1
                asl.w   #1,d0
                move.w  (word_FFA000).w,d1
                andi.w  #6,d1
                add.w   d1,d0
                add.b   $14(a0,d0.w),d6
                add.b   $15(a0,d0.w),d5
                bsr.w   set_player_sprite
                jmp     sub_17ED8
; End of function sub_17274
; ---------------------------------------------------------------------------
off_172BC:      dc.l word_E8D92,word_E8DC2,word_E8DAA,word_E8D72,word_E8D52 ; DATA XREF: sub_17274   o
                dc.b $FD,$FF,$FD,$FE
                dc.b $FD,$FD,$FD,$FE
                dc.b $FE,$FF,$FD,  0
                dc.b $FC,  1,$FD,  0
                dc.b $FE,$FE,$FD,$FF
                dc.b $FC,  1,$FD,$FF
                dc.b $FA,$FD,$FB,$FE
                dc.b $FC,  0,$FB,$FE
                dc.b $FA,$FE,$FB,$FF
                dc.b $FC,  0,$FB,$FF
off_172F8:      dc.l word_E8E12,word_E8E4A,word_E8E32,word_E8DF2,word_E8DDA
                                        ; DATA XREF: pstate_start_hover+CC   o pstate_hover+B6   o ...
                dc.b $FC,  2,$FC,  1
                dc.b $FD,  0,$FC,  1
                dc.b $FF,$FE,$FD,$FE
                dc.b $FC,$FF,$FD,$FE
                dc.b $FE,$FF,$FD,  0
                dc.b $FC,  1,$FD,  0
                dc.b $FB,$FF,$FC,  0
                dc.b $FD,  1,$FC,  0
                dc.b $FB,  0,$FC,  0
                dc.b $FD,  1,$FC,  0
sub_17334:                              ; CODE XREF: pstate_counter_force+2E   j
                                        ; pstate_air_counter_force+56   j ...
                subq.w  #1,CRTL_UNKC(a5)
                bpl.s   loc_17344
                move.w  #2,CRTL_UNKC(a5)
                addq.w  #4,CRTL_UNK48(a5)
loc_17344:                              ; CODE XREF: sub_17334+4   j
                move.w  CRTL_UNK48(a5),d0
                movea.l off_1735E(pc,d0.w),a1
                movea.l off_1736E(pc,d0.w),a2
                asr.w   #1,d0
                move.b  byte_1737E(pc,d0.w),d5
                move.b  byte_1737E+1(pc,d0.w),d6
                bra.w   set_player_sprite
; End of function sub_17334
; ---------------------------------------------------------------------------
off_1735E:      dc.l word_E8BC2,word_E8BE2,word_E8BFA,word_E8C0A ; DATA XREF: sub_17334+14   o
off_1736E:      dc.l word_E8942,word_E89C2,word_E89C2,word_E89C2 ; DATA XREF: sub_17334+18   o
byte_1737E:     dc.b   0,  0,  0,  5    ; DATA XREF: sub_17334+1E   r sub_17334+22   r
                dc.b   0,  5,  4,  5
sub_17386:                              ; CODE XREF: sub_153BC:loc_153D0   j
                move.w  #$E0,(word_FF8140).w
                move.b  #$E0,(byte_FF8142).w
                move.b  #8,(byte_FF8143).w
                movea.w #(word_FFC5C0-M68K_RAM),a0
                move.w  #$1CC,(a0)
                move.w  #$E900,2(a0)
                move.b  #$50,$21(a0) ; 'P'
                move.w  #8,$48(a0)
                move.l  #stru_E9800,8(a0)
                move.w  $E(a5),d7
                andi.w  #$8000,d7
                addi.w  #$480,d7
                move.w  d7,$E(a0)
                move.w  #2,$26(a0)
                btst    #3,$E(a5)
                beq.s   loc_173DC
                neg.w   d0
                neg.l   d2
loc_173DC:                              ; CODE XREF: sub_17386+50   j
                add.w   $10(a5),d0
                add.w   $14(a5),d1
                move.w  d0,$10(a0)
                move.w  d1,$14(a0)
                move.l  d2,$18(a0)
                move.b  #$43,d0 ; 'C'
                jmp     (play_sfx_id_2).l
; End of function sub_17386
sub_173FA:                              ; CODE XREF: pstate_pnx_end+56   p reverse_dash+80   p ...
                move.b  #$41,d0 ; 'A'
                jsr     (play_sfx_id_2).l
                move.w  #$E0,(word_FF8140).w
                move.b  #$20,(byte_FF8142).w ; ' '
                move.b  #2,(byte_FF8143).w
                movea.w #(word_FFC5C0-M68K_RAM),a0
                move.w  #$230,(a0)
                move.b  #$54,$21(a0) ; 'T'
                move.w  #$4000,2(a0)
                move.l  #word_E8F22,8(a0)
                move.w  CRTL_SPRITE_FLAGS(a5),d0
                andi.w  #$FFFF,d0
                move.w  d0,$E(a0)
                eori.w  #$1000,$E(a0)
                move.b  CRTL_UNK20(a5),$20(a0)
                move.w  CRTL_XPOS(a5),$10(a0)
                move.w  CRTL_YPOS(a5),$14(a0)
                tst.w   (DIFFICULTY).w
                bne.s   hard_mode
                move.w  #$26,$26(a0) ; '&'
                subi.w  #$1E,(HEALTH).w
                move.w  #$801E,(HEALTH_SMTH).w
                move.w  #$30,(word_FF8268).w ; '0'
                rts
; ---------------------------------------------------------------------------
hard_mode:                              ; CODE XREF: sub_173FA+60   j
                move.w  #$23,$26(a0) ; '#'
                subi.w  #$32,(HEALTH).w ; '2'
                move.w  #$8032,(HEALTH_SMTH).w
                move.w  #$30,(word_FF8268).w ; '0'
                rts
; End of function sub_173FA
sub_17490:
                bne.s   loc_17498
                bset    #1,(byte_FF8244).w
loc_17498:                              ; CODE XREF: sub_17490   j
                movea.l $48(a5),a0
                move.w  (word_FFA000).w,d0
                asr.w   #1,d0
                andi.w  #$C,d0
                rts
; End of function sub_17490
set_player_sprite:                      ; CODE XREF: pstate_skid+70   j pstate_airtime+D6   j ...
                movea.w #(player_sprite_ram_idk-M68K_RAM),a3
                move.l  a3,CRTL_SPRITE_PTR(a5)
                clr.l   CRTL_SPRITE_PTR_PREV(a5)
                moveq   #$F,d4
                ext.w   d5
                asl.w   #8,d6
loop:                                   ; CODE XREF: set_player_sprite+2C   j
                move.w  (a1)+,d0
                bclr    d4,d0
                bne.s   d4_0xF_bit_set
                move.w  d0,(a3)+
                move.l  (a1)+,(a3)+
                move.w  (a1)+,d1
                move.w  d1,d2
                andi.w  #$FF00,d2
                add.w   d6,d2
                add.b   d5,d1
                move.b  d1,d2
                move.w  d2,(a3)+
                bra.s   loop
; ---------------------------------------------------------------------------
d4_0xF_bit_set:                         ; CODE XREF: set_player_sprite+16   j
                move.w  d0,(a3)+
                andi.w  #$3FF,d0
                moveq   #0,d1
                move.b  (a1),d1
                move.w  d1,d2
                andi.w  #3,d2
                addq.w  #1,d2
                lsr.w   #2,d1
                addq.w  #1,d1
                muls.w  d2,d1
                add.w   d1,d0
                move.l  (a1)+,(a3)+
                move.w  (a1)+,d1
                move.w  d1,d2
                andi.w  #$FF00,d2
                add.w   d6,d2
                add.b   d5,d1
                move.b  d1,d2
                move.w  d2,(a3)+
loop2:                                  ; CODE XREF: set_player_sprite+68   j
                move.w  (a2)+,d1
                move.w  d1,d2
                add.w   d0,d2
                move.w  d2,(a3)+
                move.l  (a2)+,(a3)+
                move.w  (a2)+,(a3)+
                btst    d4,d1
                beq.s   loop2
                rts
; End of function set_player_sprite
sub_17514:                              ; CODE XREF: pstate_idle+14   p pstate_rev_idle+16   p ...
                btst    #button_B,CRTL_DOWN(a5)
                bne.w   locret_175B6
                move.w  (RAND_NUM+2).w,d0
                andi.w  #$E000,d0
                bne.w   locret_175B6
                bsr.w   entity_get_flag0_C320
                bne.w   locret_175B6
                lea     (word_2AE58).l,a1
                jsr     (update_ent_61_a0).l
                lea     (word_1B514).l,a1
                move.w  (RAND_NUM).w,d0
                andi.w  #$1FE,d0
                move.w  -$80(a1,d0.w),d1
                move.w  (a1,d0.w),d2
                ext.l   d1
                ext.l   d2
                move.w  (RAND_NUM).w,d0
                andi.w  #3,d0
                asl.l   d0,d1
                move.w  (RAND_NUM).w,d0
                asr.w   #1,d0
                andi.w  #3,d0
                asl.l   d0,d2
                move.l  d1,$1C(a0)
                move.l  d2,$18(a0)
                movem.l a0,-(sp)
                jsr     (random_number).l
                movem.l (sp)+,a0
                move.b  (RAND_NUM).w,d0
                andi.w  #$1F,d0
                subi.w  #$10,d0
                add.w   CRTL_XPOS(a5),d0
                move.w  d0,$10(a0)
                moveq   #$10,d1
                btst    #PFLAG_YDIR,CRTL_SPRITE_FLAGS(a5)
                beq.s   loc_175A4
                moveq   #$10,d1
loc_175A4:                              ; CODE XREF: sub_17514+8C   j
                move.b  (RAND_NUM+1).w,d0
                andi.w  #$1F,d0
                sub.w   d1,d0
                add.w   CRTL_YPOS(a5),d0
                move.w  d0,$14(a0)
locret_175B6:                           ; CODE XREF: sub_17514+6   j sub_17514+12   j ...
                rts
; End of function sub_17514
sub_175B8:
                subq.w  #1,CRTL_UNK4A(a5)
                bpl.w   locret_17640
                move.w  #$FFFF,CRTL_UNK4A(a5)
                btst    #CRTL_PSTATE,CRTL_DOWN(a5)
                bne.w   locret_17640
                subq.w  #2,(GFX_HP_EMPTY_IDK).w
                bpl.s   loc_175DA
                clr.w   (GFX_HP_EMPTY_IDK).w
loc_175DA:                              ; CODE XREF: sub_175B8+1C   j
                move.w  (word_FFA000).w,d0
                andi.w  #$F,d0
                bne.s   loc_175EE
                move.b  #$AC,d0
                jsr     (play_sfx_id_2).l
loc_175EE:                              ; CODE XREF: sub_175B8+2A   j
                bsr.w   entity_get_flag0_C320
                bne.w   locret_17640
                lea     (word_2AE58).l,a1
                jsr     (update_ent_61_a0).l
                lea     (word_1B514).l,a1
                move.w  (RAND_NUM).w,d0
                andi.w  #$1FE,d0
                move.w  -$80(a1,d0.w),d1
                move.w  (a1,d0.w),d2
                ext.l   d1
                ext.l   d2
                asl.l   #4,d1
                asl.l   #4,d2
                move.l  d1,$1C(a0)
                move.l  d2,$18(a0)
                asl.l   #3,d1
                asl.l   #3,d2
                move.w  CRTL_YPOS(a5),$14(a0)
                sub.l   d1,$14(a0)
                move.w  CRTL_XPOS(a5),$10(a0)
                sub.l   d2,$10(a0)
locret_17640:                           ; CODE XREF: sub_175B8+4   j sub_175B8+14   j ...
                rts
; End of function sub_175B8
sub_17642:                              ; CODE XREF: sub_15F6A+56   j
                movea.w #(PLAYER_STRUCT_COPY_IDK-M68K_RAM),a0
                move.w  CRTL_XPOS(a5),d4
                moveq   #3,d5
                moveq   #2,d7
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                beq.s   loc_1765E
                move.w  #$C0,d6
                subq.w  #8,d4
                bra.s   loc_17664
; ---------------------------------------------------------------------------
loc_1765E:                              ; CODE XREF: sub_17642+12   j
                addq.w  #8,d4
                move.w  #$1E0,d6
loc_17664:                              ; CODE XREF: sub_17642+1A   j sub_17642+30   j
                move.l  #stru_E9560,8(a0)
                bsr.s   sub_176A0
                addi.w  #$40,d6 ; '@'
                dbf     d7,loc_17664
                rts
; End of function sub_17642
sub_17678:
                moveq   #4,d5
                move.w  #$FFC0,d6
                moveq   #4,d7
                btst    #PFLAG_XDIR,CRTL_SPRITE_FLAGS(a5)
                beq.s   loc_1768C
                addi.w  #$80,d6
loc_1768C:                              ; CODE XREF: sub_17678+E   j sub_17678+22   j
                move.l  #stru_E9560,8(a0)
                bsr.s   sub_176A0
                addi.w  #$40,d6 ; '@'
                dbf     d7,loc_1768C
                rts
; End of function sub_17678
sub_176A0:                              ; CODE XREF: sub_17642+2A   p sub_17678+1C   p
                jsr     (sub_2A79E).l
                move.b  CRTL_UNK20(a5),$20(a0)
                lea     (word_1B514).l,a1
                andi.w  #$1FE,d6
                move.w  -$80(a1,d6.w),d1
                move.w  (a1,d6.w),d2
                ext.l   d1
                ext.l   d2
                asl.l   d5,d1
                asl.l   d5,d2
                move.l  d1,$1C(a0)
                move.l  d2,$18(a0)
                move.w  CRTL_YPOS(a5),$14(a0)
                subq.w  #8,$14(a0)
                move.w  d4,$10(a0)
                lea     $60(a0),a0
                rts
; End of function sub_176A0
; ---------------------------------------------------------------------------
word_176E2:     dc.w     0,    8,    4,    8 ; DATA XREF: sub_17274:loc_1727A   o
                dc.w     0,   $C,  $10,   $C
word_176F2:     dc.w     0,   $C,  $10,   $C ; DATA XREF: sub_17274+14   o
                dc.w     0,    8,    4,    8
sub_17702:
                tst.w   (HEALTH_SMTH).w
                beq.w   locret_1771A
                tst.b   (byte_FF813E).w
                bmi.s   loc_17728
                subq.w  #1,(word_FF8268).w
                bpl.s   loc_1771C
                clr.w   (HEALTH_SMTH).w
locret_1771A:                           ; CODE XREF: sub_17702+4   j
                rts
; ---------------------------------------------------------------------------
loc_1771C:                              ; CODE XREF: sub_17702+12   j
                btst    #0,(word_FFA000+1).w
                bne.s   loc_17728
                subq.w  #1,(word_FF8266).w
loc_17728:                              ; CODE XREF: sub_17702+C   j sub_17702+20   j
                move.b  (HEALTH_SMTH).w,d0
                andi.w  #$10,d0
                addi.w  #-$3841,d0
                lea     (bcd_table).l,a0
                move.w  (HEALTH_SMTH).w,d4
                andi.w  #$FFF,d4
                asl.w   #1,d4
                move.b  (a0,d4.w),d1
                andi.w  #$F,d1
                move.b  1(a0,d4.w),d2
                move.b  d2,d3
                asr.w   #4,d2
                andi.w  #$F,d2
                andi.w  #$F,d3
                addi.w  #-$383C,d1
                addi.w  #-$383C,d2
                addi.w  #-$383C,d3
                move.w  #0,d4
                move.w  (word_FF8264).w,d5
                move.w  (word_FF8266).w,d6
                cmpi.w  #$A0,d6
                bpl.s   loc_1777E
                move.w  #$A0,d6
loc_1777E:                              ; CODE XREF: sub_17702+76   j
                movea.w #(word_FFA100-M68K_RAM),a0
                move.w  d6,(a0)+
                move.w  d4,(a0)+
                move.w  d0,(a0)+
                move.w  d5,(a0)+
                addq.w  #8,d5
                move.w  d6,(a0)+
                move.w  d4,(a0)+
                move.w  d1,(a0)+
                move.w  d5,(a0)+
                addq.w  #8,d5
                move.w  d6,(a0)+
                move.w  d4,(a0)+
                move.w  d2,(a0)+
                move.w  d5,(a0)+
                addq.w  #8,d5
                move.w  d6,(a0)+
                move.w  d4,(a0)+
                move.w  d3,(a0)+
                move.w  d5,(a0)+
                move.w  #$FFFF,(a0)
                movea.w #(word_FFA100-M68K_RAM),a0
                jmp     (gfx_insert_sprite_258C).l
; End of function sub_17702
sub_177B6:                              ; CODE XREF: pstate_dash+B8   j pstate_pnx_start+C8   j ...
                tst.w   (word_FFC5C0).w
                beq.s   loc_177D8
                move.l  #word_E8EBA,CRTL_SPRITE_PTR(a5)
                btst    #0,(word_FFA000+1).w
                bne.w   end
                move.l  #word_E8E6A,CRTL_SPRITE_PTR(a5)
                rts
; ---------------------------------------------------------------------------
loc_177D8:                              ; CODE XREF: sub_177B6+4   j
                bsr.w   sub_16C62
                bne.w   end
                move.w  #$250,(a0)
                clr.b   $21(a0)
                move.w  #$C880,CRTL_UNK2(a0)
                move.l  #word_E8680,CRTL_SPRITE_PTR(a0)
                move.w  CRTL_SPRITE_FLAGS(a5),d0
                andi.w  #$FFFF,d0
                move.w  d0,CRTL_SPRITE_FLAGS(a0)
                move.b  CRTL_UNK20(a5),CRTL_UNK20(a0)
                addq.b  #4,CRTL_UNK20(a0)
                move.w  #3,CRTL_UNK48(a0)
                move.w  CRTL_XPOS(a5),CRTL_XPOS(a0)
                move.w  CRTL_YPOS(a5),CRTL_YPOS(a0)
                move.l  CRTL_UNK48(a5),d0
                neg.l   d0
                move.l  d0,CRTL_XSPD(a0)
                add.l   d0,CRTL_XPOS(a0)
                move.l  d0,CRTL_UNK4C(a0)
                bsr.w   sub_16C62
                bne.s   end
                lea     (word_2ADFA).l,a1
                move.w  #$FFF4,CRTL_XSPD(a0)
                tst.w   $48(a5)
                bpl.s   loc_17852
                lea     (word_2AE14).l,a1
                neg.w   CRTL_XSPD(a0)
loc_17852:                              ; CODE XREF: sub_177B6+90   j
                jsr     (update_ent_61_a0).l
                move.w  #$8880,CRTL_UNK2(a0)
                move.b  CRTL_UNK20(a5),CRTL_UNK20(a0)
                subq.b  #4,CRTL_UNK20(a0)
                move.w  CRTL_XPOS(a5),CRTL_XPOS(a0)
                move.b  (RAND_NUM).w,d0
                andi.w  #$1F,d0
                subi.w  #$10,d0
                add.w   CRTL_YPOS(a5),d0
                move.w  d0,CRTL_YPOS(a0)
end:                                    ; CODE XREF: sub_177B6+14   j sub_177B6+26   j ...
                rts
; End of function sub_177B6
