dma_read_queue:                         ; CODE XREF: VBLANK+BC   p
                move    sr,-(sp)
                move    #DISABLE_INTR,sr
                lea     (VDP_CTRL).l,a0
                move.w  (VDP_MODE2_RAM).w,d0
                bset    #VDPR_BIT_ENABLE_DMA,d0
                move.w  d0,(a0)
                move.w  #AUTO_INC_2,(a0)
                move.l  #$93409401,(a0) ; set DMA length to $140 ($280 bytes)
                move.w  #VDPR_DMASRC_L,(a0)
                move.w  #$96F0,(a0)
                move.w  #$977F,(a0)     ; set DMA src address to $FFE000
                move.l  #$74000083,(VDP_DEST).w ; VRAM_WRITE at address $F400
                move.w  (VDP_DEST).w,(a0)
                move.w  (VDP_DEST+2).w,(a0)
                tst.b   (CRAM_DATA_FILL_FLAG).w
                bne.w   no_fill
                move.w  #AUTO_INC_2,(a0)
                move.l  #CRAM_ADDR_CMD,(a0)
                lea     (VDP_DATA).l,a1
                move.w  (GFX_PAL_FADE_DIR).w,d1
                move.w  d1,d0
                swap    d1
                move.w  d0,d1
                move.w  #$1F,d0
set_cram_data:                          ; CODE XREF: dma_read_queue+64   j
                move.l  d1,(a1)
                dbf     d0,set_cram_data
                bra.w   load_queue
; ---------------------------------------------------------------------------
no_fill:                                ; CODE XREF: dma_read_queue+40   j
                move.w  #AUTO_INC_2,(a0)
                move.l  #$93409400,(a0) ; set DMA len to $40 ($80 bytes)
                move.w  #$9580,(a0)
                move.w  #$96F1,(a0)
                move.w  #$977F,(a0)     ; set DMA src to $FFE300
                move.l  #CRAM_DMA_CMD,(VDP_DEST).w
                move.w  (VDP_DEST).w,(a0)
                move.w  (VDP_DEST+2).w,(a0)
load_queue:                             ; CODE XREF: dma_read_queue+68   j
                lea     (DMA_QUEUE_HEAD).w,a2
                movea.w (DMA_QUEUE_PTR0).w,a3
                cmpa.w  a2,a3
                beq.w   skip
cpy_loop:                               ; CODE XREF: dma_read_queue+AC   j
                move.l  (a3)+,(a0)
                move.l  (a3)+,(a0)
                move.l  (a3)+,(a0)
                move.w  (a3)+,(a0)
                move.w  (a3)+,(a0)
                cmpa.w  a2,a3
                bne.s   cpy_loop
                move.w  a3,(DMA_QUEUE_PTR0).w
                move.w  a3,(DMA_QUEUE_SRC_70E).w
skip:                                   ; CODE XREF: dma_read_queue+9C   j
                move.w  #AUTO_INC_2,(a0)
                btst    #VDPR_BIT_HORZ_SCROLL,(VDP_MODE3_RAM+1).w ; check HSCR bit
                bne.s   h_tile_scroll
                move.l  #$93029400,(a0) ; set DMA len to $02 ($04 bytes)
                bra.s   h_full_scroll
; ---------------------------------------------------------------------------
h_tile_scroll:                          ; CODE XREF: dma_read_queue+C0   j
                move.l  #$93C09401,(a0) ; set DMA length to $1C0 ($380 bytes)
h_full_scroll:                          ; CODE XREF: dma_read_queue+C8   j
                move.w  #VDPR_DMASRC_L,(a0)
                move.w  #$96F2,(a0)
                move.w  #$977F,(a0)     ; set DMA src to $FFE400
                move.l  #$70000083,(VDP_DEST).w ; VRAM write at address $F000
                move.w  (VDP_DEST).w,(a0)
                move.w  (VDP_DEST+2).w,(a0)
                move.w  #AUTO_INC_2,(a0)
                btst    #VDPR_BIT_VERT_SCROLL,(VDP_MODE3_RAM+1).w
                bne.s   v_tile_scroll
                move.l  #$93029400,(a0) ; set DMA len to $02 ($04 bytes)
                bra.s   v_full_scroll
; ---------------------------------------------------------------------------
v_tile_scroll:                          ; CODE XREF: dma_read_queue+F6   j
                move.l  #$93289400,(a0) ; set DMA len to $28 ($50 bytes)
v_full_scroll:                          ; CODE XREF: dma_read_queue+FE   j
                move.w  #VDPR_DMASRC_L,(a0)
                move.w  #$96F6,(a0)
                move.w  #$977F,(a0)     ; set DMA src to $FFEC00
                move.l  #VSRAM_DMA_CMD,(VDP_DEST).w
                move.w  (VDP_DEST).w,(a0)
                move.w  (VDP_DEST+2).w,(a0)
loc_E34:
                movea.w #(dword_FF84A0-M68K_RAM),a3
                tst.w   (a3)
                beq.s   loc_E46
                move.l  (a3)+,(a0)
                move.l  (a3)+,(a0)
                move.l  (a3)+,(a0)
                move.w  (a3)+,(a0)
                move.w  (a3)+,(a0)
loc_E46:                                ; CODE XREF: dma_read_queue+128   j
                movea.w #(dword_FF8560-M68K_RAM),a3
                tst.w   (a3)
                beq.s   loc_E58
                move.l  (a3)+,(a0)
                move.l  (a3)+,(a0)
                move.l  (a3)+,(a0)
                move.w  (a3)+,(a0)
                move.w  (a3)+,(a0)
loc_E58:                                ; CODE XREF: dma_read_queue+13A   j
                movea.w #(dword_FF8500-M68K_RAM),a3
                tst.w   (a3)
                beq.s   loc_E6A
                move.l  (a3)+,(a0)
                move.l  (a3)+,(a0)
                move.l  (a3)+,(a0)
                move.w  (a3)+,(a0)
                move.w  (a3)+,(a0)
loc_E6A:                                ; CODE XREF: dma_read_queue+14C   j
                move.w  (FORCE_SPRITE).w,d0
                beq.s   end
                cmpi.w  #1,(FORCE_SPRITE).w
                bne.s   end
                clr.w   (FORCE_SPRITE).w
                movea.w #(word_FF8478-M68K_RAM),a3
                move.l  (a3)+,(a0)
                move.l  (a3)+,(a0)
                move.l  (a3)+,(a0)
                move.w  (a3)+,(a0)
                move.w  (a3)+,(a0)
end:                                    ; CODE XREF: dma_read_queue+15C   j dma_read_queue+164   j
                move.w  (VDP_MODE2_RAM).w,d0
                bclr    #VDPR_BIT_ENABLE_DMA,d0
                move.w  d0,(a0)
                move    (sp)+,sr
                clr.b   (DMA_QUEUE_STATUS).w
                rts
; End of function dma_read_queue
vdp_set_regs:                           ; CODE XREF: VBLANK+C0   p
                lea     (VDP_CTRL).l,a0
                move.w  (VDP_MODE2_RAM).w,(a0)
                move.w  (VDP_PLANEA_RAM).w,(a0)
                move.w  (VDP_WINDOW_RAM).w,(a0)
                move.w  (VDP_PLANEB_RAM).w,(a0)
                move.w  (VDP_SPRITE_RAM).w,(a0)
                move.w  (VDP_BGCOL_RAM).w,(a0)
                move.w  (VDP_HRATE_RAM).w,(a0)
                move.w  (VDP_MODE3_RAM).w,(a0)
                move.w  (VDP_MODE4_RAM).w,(a0)
                move.w  (VDP_HSCROLL_RAM).w,(a0)
                move.w  (VDP_INCR_RAM).w,(a0)
                move.w  (VDP_SIZE_RAM).w,(a0)
                move.w  (VDP_WINX_RAM).w,(a0)
                move.w  (VDP_WINY_RAM).w,(a0)
                rts
; End of function vdp_set_regs
vdp_set_mode1_reg:                      ; CODE XREF: VBLANK+48   p
                move.w  (VDP_MODE1_RAM).w,d0
                tst.b   (CRAM_DATA_FILL_FLAG).w
                bne.w   vdp_write
                bclr    #4,d0           ; disable horizontal interupts
vdp_write:                              ; CODE XREF: vdp_set_mode1_reg+8   j
                move.w  d0,(VDP_CTRL).l
                rts
; End of function vdp_set_mode1_reg
_gfx_palette_fade:
                tst.b   (CRTL_FLAG).w
                bpl.w   continue
                rts
; ---------------------------------------------------------------------------
continue:                               ; CODE XREF: _gfx_palette_fade+4   j
                tst.w   (GFX_PAL_FADE_DIR).w
                bne.w   gfx_palette_fade_in
                move.w  (GFX_PAL_FADE_MODE).w,d0
                bmi.w   gfx_pal_fade_out
                bne.w   gfx_pal_fade_out_mirror
                rts
; End of function _gfx_palette_fade
gfx_pal_fade_out:                       ; CODE XREF: _gfx_palette_fade+16   j
                add.w   d0,(GFX_PAL_FADE_SPD).w
                bpl.w   loc_F20
                clr.w   (GFX_PAL_FADE_SPD).w
loc_F20:                                ; CODE XREF: gfx_pal_fade_out+4   j
                lea     (PALETTE_RAM_0).w,a0
                lea     (PALETTE_RAM_1).w,a1
                move.b  (GFX_PAL_FADE_SPD).w,d5
                andi.w  #$FF,d5
                move.w  d5,d6
                lsl.w   #4,d6
                move.w  d6,d7
                lsl.w   #4,d7
                move.w  #$3F,d1 ; '?'
loop:                                   ; CODE XREF: gfx_pal_fade_out+64   j
                move.w  (a1)+,d2
                move.w  d2,d3
                move.w  d2,d4
                andi.w  #$F,d2
                beq.w   loc_F52
                sub.w   d5,d2
                bpl.w   loc_F52
                clr.w   d2
loc_F52:                                ; CODE XREF: gfx_pal_fade_out+32   j gfx_pal_fade_out+38   j
                andi.w  #$F0,d3
                beq.w   loc_F62
                sub.w   d6,d3
                bpl.w   loc_F62
                clr.w   d3
loc_F62:                                ; CODE XREF: gfx_pal_fade_out+42   j gfx_pal_fade_out+48   j
                andi.w  #$F00,d4
                beq.w   loc_F72
                sub.w   d7,d4
                bpl.w   loc_F72
                clr.w   d4
loc_F72:                                ; CODE XREF: gfx_pal_fade_out+52   j gfx_pal_fade_out+58   j
                or.w    d3,d2
                or.w    d4,d2
                move.w  d2,(a0)+
                dbf     d1,loop
                tst.w   (GFX_PAL_FADE_SPD).w
                bne.w   end
                clr.w   (GFX_PAL_FADE_MODE).w
end:                                    ; CODE XREF: gfx_pal_fade_out+6C   j
                rts
; End of function gfx_pal_fade_out
gfx_pal_fade_out_mirror:                ; CODE XREF: _gfx_palette_fade+1A   j
                tst.w   (GFX_PAL_FADE_SPD).w
                bne.w   gfx_pal_fade_out_continue
                add.w   d0,(GFX_PAL_FADE_SPD).w
                lea     (PALETTE_RAM_0).w,a0
                lea     (PALETTE_RAM_1).w,a1
                move.b  (GFX_PAL_FADE_SPD).w,d5
                andi.w  #$FF,d5
                move.w  d5,d6
                lsl.w   #4,d6
                move.w  d6,d7
                lsl.w   #4,d7
                move.w  #$3F,d1 ; '?'
loop:                                   ; CODE XREF: gfx_pal_fade_out_mirror+66   j
                move.w  (a0),d2
                move.w  d2,d3
                move.w  d2,d4
                andi.w  #$F,d2
                beq.w   loc_FC8
                sub.w   d5,d2
                bpl.w   loc_FC8
                clr.w   d2
loc_FC8:                                ; CODE XREF: gfx_pal_fade_out_mirror+32   j
                                        ; gfx_pal_fade_out_mirror+38   j
                andi.w  #$F0,d3
                beq.w   loc_FD8
                sub.w   d6,d3
                bpl.w   loc_FD8
                clr.w   d3
loc_FD8:                                ; CODE XREF: gfx_pal_fade_out_mirror+42   j
                                        ; gfx_pal_fade_out_mirror+48   j
                andi.w  #$F00,d4
                beq.w   loc_FE8
                sub.w   d7,d4
                bpl.w   loc_FE8
                clr.w   d4
loc_FE8:                                ; CODE XREF: gfx_pal_fade_out_mirror+52   j
                                        ; gfx_pal_fade_out_mirror+58   j
                or.w    d3,d2
                or.w    d4,d2
                move.w  d2,(a0)+
                move.w  d2,(a1)+
                dbf     d1,loop
                cmpi.w  #$1000,(GFX_PAL_FADE_SPD).w
                blt.w   end
                move.w  #$1000,(GFX_PAL_FADE_SPD).w
                clr.w   (GFX_PAL_FADE_MODE).w
                bclr    #VDPR_BIT_DISPLAY_OR_FILL,(VDP_MODE2_RAM+1).w ; fill display with background color
                clr.b   (CRAM_DATA_FILL_FLAG).w
end:                                    ; CODE XREF: gfx_pal_fade_out_mirror+70   j
                rts
; End of function gfx_pal_fade_out_mirror
gfx_pal_fade_out_continue:              ; CODE XREF: gfx_pal_fade_out_mirror+4   j
                add.w   d0,(GFX_PAL_FADE_SPD).w
                lea     (PALETTE_RAM_0).w,a0
                lea     (PALETTE_RAM_1).w,a1
                move.b  (GFX_PAL_FADE_SPD).w,d5
                andi.w  #$FF,d5
                move.w  d5,d6
                lsl.w   #4,d6
                move.w  d6,d7
                lsl.w   #4,d7
                move.w  #$3F,d1 ; '?'
loop:                                   ; CODE XREF: gfx_pal_fade_out_continue+5C   j
                move.w  (a1)+,d2
                move.w  d2,d3
                move.w  d2,d4
                andi.w  #$F,d2
                beq.w   loc_104A
                sub.w   d5,d2
                bpl.w   loc_104A
                clr.w   d2
loc_104A:                               ; CODE XREF: gfx_pal_fade_out_continue+2A   j
                                        ; gfx_pal_fade_out_continue+30   j
                andi.w  #$F0,d3
                beq.w   loc_105A
                sub.w   d6,d3
                bpl.w   loc_105A
                clr.w   d3
loc_105A:                               ; CODE XREF: gfx_pal_fade_out_continue+3A   j
                                        ; gfx_pal_fade_out_continue+40   j
                andi.w  #$F00,d4
                beq.w   loc_106A
                sub.w   d7,d4
                bpl.w   loc_106A
                clr.w   d4
loc_106A:                               ; CODE XREF: gfx_pal_fade_out_continue+4A   j
                                        ; gfx_pal_fade_out_continue+50   j
                or.w    d3,d2
                or.w    d4,d2
                move.w  d2,(a0)+
                dbf     d1,loop
                cmpi.w  #$1000,(GFX_PAL_FADE_SPD).w
                blt.w   end
                move.w  #$1000,(GFX_PAL_FADE_SPD).w
                clr.w   (GFX_PAL_FADE_MODE).w
                bclr    #VDPR_BIT_DISPLAY_OR_FILL,(VDP_MODE2_RAM+1).w ; fill display with background color
                clr.b   (CRAM_DATA_FILL_FLAG).w
end:                                    ; CODE XREF: gfx_pal_fade_out_continue+66   j
                rts
; End of function gfx_pal_fade_out_continue
gfx_palette_fade_in:                    ; CODE XREF: _gfx_palette_fade+E   j
                move.w  (GFX_PAL_FADE_MODE).w,d0
                bmi.w   gfx_pal_fade_in
                bne.w   gfx_pal_fade_in_mirror
                rts
; End of function gfx_palette_fade_in
gfx_pal_fade_in:                        ; CODE XREF: gfx_palette_fade_in+4   j
                add.w   d0,(GFX_PAL_FADE_SPD).w
                bpl.w   loc_10AE
                clr.w   (GFX_PAL_FADE_SPD).w
loc_10AE:                               ; CODE XREF: gfx_pal_fade_in+4   j
                lea     (PALETTE_RAM_0).w,a0
                lea     (PALETTE_RAM_1).w,a1
                move.b  (GFX_PAL_FADE_SPD).w,d5
                andi.w  #$FF,d5
                move.w  d5,d6
                lsl.w   #4,d6
                move.w  d6,d7
                lsl.w   #4,d7
                move.w  #$3F,d1 ; '?'
loop:                                   ; CODE XREF: gfx_pal_fade_in+6A   j
                move.w  (a1)+,d2
                move.w  d2,d3
                move.w  d2,d4
                andi.w  #$F,d2
                andi.w  #$F0,d3
                andi.w  #$F00,d4
                add.w   d5,d2
                cmpi.w  #$F,d2
                bls.w   loc_10EA
                move.w  #$F,d2
loc_10EA:                               ; CODE XREF: gfx_pal_fade_in+40   j
                add.w   d6,d3
                cmpi.w  #$F0,d3
                bls.w   loc_10F8
                move.w  #$F0,d3
loc_10F8:                               ; CODE XREF: gfx_pal_fade_in+4E   j
                add.w   d7,d4
                cmpi.w  #$F00,d4
                bls.w   loc_1106
                move.w  #$F00,d4
loc_1106:                               ; CODE XREF: gfx_pal_fade_in+5C   j
                or.w    d3,d2
                or.w    d4,d2
                move.w  d2,(a0)+
                dbf     d1,loop
                tst.w   (GFX_PAL_FADE_SPD).w
                bne.w   end
                clr.w   (GFX_PAL_FADE_MODE).w
end:                                    ; CODE XREF: gfx_pal_fade_in+72   j
                rts
; End of function gfx_pal_fade_in
gfx_pal_fade_in_mirror:                 ; CODE XREF: gfx_palette_fade_in+8   j
                tst.w   (GFX_PAL_FADE_SPD).w
                bne.w   gfx_pal_fade_in_continue
                add.w   d0,(GFX_PAL_FADE_SPD).w
                lea     (PALETTE_RAM_0).w,a0
                lea     (PALETTE_RAM_1).w,a1
                move.b  (GFX_PAL_FADE_SPD).w,d5
                andi.w  #$FF,d5
                move.w  d5,d6
                lsl.w   #4,d6
                move.w  d6,d7
                lsl.w   #4,d7
                move.w  #$3F,d1 ; '?'
loop:                                   ; CODE XREF: gfx_pal_fade_in_mirror+6C   j
                move.w  (a0),d2
                move.w  d2,d3
                move.w  d2,d4
                andi.w  #$F,d2
                andi.w  #$F0,d3
                andi.w  #$F00,d4
                add.w   d5,d2
                cmpi.w  #$F,d2
                bls.w   loc_1166
                move.w  #$F,d2
loc_1166:                               ; CODE XREF: gfx_pal_fade_in_mirror+40   j
                add.w   d6,d3
                cmpi.w  #$F0,d3
                bls.w   loc_1174
                move.w  #$F0,d3
loc_1174:                               ; CODE XREF: gfx_pal_fade_in_mirror+4E   j
                add.w   d7,d4
                cmpi.w  #$F00,d4
                bls.w   loc_1182
                move.w  #$F00,d4
loc_1182:                               ; CODE XREF: gfx_pal_fade_in_mirror+5C   j
                or.w    d3,d2
                or.w    d4,d2
                move.w  d2,(a0)+
                move.w  d2,(a1)+
                dbf     d1,loop
                cmpi.w  #$1000,(GFX_PAL_FADE_SPD).w
                blt.w   end
                move.w  #$1000,(GFX_PAL_FADE_SPD).w
                clr.w   (GFX_PAL_FADE_MODE).w
                bclr    #VDPR_BIT_DISPLAY_OR_FILL,(VDP_MODE2_RAM+1).w
                clr.b   (CRAM_DATA_FILL_FLAG).w
end:                                    ; CODE XREF: gfx_pal_fade_in_mirror+76   j
                rts
; End of function gfx_pal_fade_in_mirror
gfx_pal_fade_in_continue:               ; CODE XREF: gfx_pal_fade_in_mirror+4   j
                add.w   d0,(GFX_PAL_FADE_SPD).w
                lea     (PALETTE_RAM_0).w,a0
                lea     (PALETTE_RAM_1).w,a1
                move.b  (GFX_PAL_FADE_SPD).w,d5
                andi.w  #$FF,d5
                move.w  d5,d6
                lsl.w   #4,d6
                move.w  d6,d7
                lsl.w   #4,d7
                move.w  #$3F,d1 ; '?'
loop:                                   ; CODE XREF: gfx_pal_fade_in_continue+62   j
                move.w  (a1)+,d2
                move.w  d2,d3
                move.w  d2,d4
                andi.w  #$F,d2
                andi.w  #$F0,d3
                andi.w  #$F00,d4
                add.w   d5,d2
                cmpi.w  #$F,d2
                bls.w   loc_11EE
                move.w  #$F,d2
loc_11EE:                               ; CODE XREF: gfx_pal_fade_in_continue+38   j
                add.w   d6,d3
                cmpi.w  #$F0,d3
                bls.w   loc_11FC
                move.w  #$F0,d3
loc_11FC:                               ; CODE XREF: gfx_pal_fade_in_continue+46   j
                add.w   d7,d4
                cmpi.w  #$F00,d4
                bls.w   loc_120A
                move.w  #$F00,d4
loc_120A:                               ; CODE XREF: gfx_pal_fade_in_continue+54   j
                or.w    d3,d2
                or.w    d4,d2
                move.w  d2,(a0)+
                dbf     d1,loop
                cmpi.w  #$1000,(GFX_PAL_FADE_SPD).w
                blt.w   end
                move.w  #$1000,(GFX_PAL_FADE_SPD).w
                clr.w   (GFX_PAL_FADE_MODE).w
                bclr    #6,(VDP_MODE2_RAM+1).w
                clr.b   (CRAM_DATA_FILL_FLAG).w
end:                                    ; CODE XREF: gfx_pal_fade_in_continue+6C   j
                rts
; End of function gfx_pal_fade_in_continue
_dma_queue_prepend_1234:
                movea.w (DMA_QUEUE_PTR0).w,a0
                move.l  #$70000083,-(a0)
                move.l  (_DMA_VSRAM_SRC0).w,d0
                andi.l  #$FFFFFF,d0
                lsr.l   #1,d0
                move.w  #VDPR_DMASRC_L,d1
                move.b  d0,d1
                move.w  d1,-(a0)
                lsr.l   #8,d0
                move.w  #VDPR_DMASRC_M,d1
                move.b  d0,d1
                move.w  d1,-(a0)
                lsr.l   #8,d0
                move.w  #VDPR_DMASRC_H,d1
                move.b  d0,d1
                move.w  d1,-(a0)
                move.w  #AUTO_INC_2,-(a0)
                btst    #1,(VDP_MODE3_RAM+1).w
                bne.w   loc_127E
                move.l  #$94009302,-(a0) ; DMA len set to $200($400 bytes)
                bra.w   loc_1284
; ---------------------------------------------------------------------------
loc_127E:                               ; CODE XREF: _dma_queue_prepend_1234+3C   j
                move.l  #$940193C0,-(a0) ; DMA len set to $C001 ($18002 bytes)
loc_1284:                               ; CODE XREF: _dma_queue_prepend_1234+46   j
                move.w  a0,(DMA_QUEUE_PTR0).w
                rts
; End of function _dma_queue_prepend_1234
_dma_queue_prepend_128A:
                movea.w (DMA_QUEUE_PTR0).w,a0
                move.l  #$40000090,-(a0)
                move.l  (_DMA_VSRAM_SRC1).w,d0
                andi.l  #$FFFFFF,d0
                lsr.l   #1,d0
                move.w  #VDPR_DMASRC_L,d1
                move.b  d0,d1
                move.w  d1,-(a0)
                lsr.l   #8,d0
                move.w  #VDPR_DMASRC_M,d1
                move.b  d0,d1
                move.w  d1,-(a0)
                lsr.l   #8,d0
                move.w  #VDPR_DMASRC_H,d1
                move.b  d0,d1
                move.w  d1,-(a0)
                move.w  #AUTO_INC_2,-(a0)
                btst    #2,(VDP_MODE3_RAM+1).w
                bne.w   loc_12D4
                move.l  #$94009302,-(a0) ; set DMA len to $200 (1024 bytes)
                bra.w   loc_12DA
; ---------------------------------------------------------------------------
loc_12D4:                               ; CODE XREF: _dma_queue_prepend_128A+3C   j
                move.l  #$94009328,-(a0) ; DMA len set to $2800($5000 bytes)
loc_12DA:                               ; CODE XREF: _dma_queue_prepend_128A+46   j
                move.w  a0,(DMA_QUEUE_PTR0).w
                rts
; End of function _dma_queue_prepend_128A
set_vdp_reg_m2_bgcol_ram_clear:         ; CODE XREF: gamemode_play_stage+230   j
                tst.b   (vdp_byte_FFF746).w
                bpl.w   end
                move.w  (VDP_MODE2_RAM).w,d0
                bclr    #VDPR_BIT_DISPLAY_OR_FILL,d0
                move.w  d0,(VDP_CTRL).l
                move.w  #$F,d0
col_clear:                              ; CODE XREF: set_vdp_reg_m2_bgcol_ram_clear+26   j
                move.w  d0,d1
                ori.w   #VDPR_BGCOL,d1
                move.w  d1,(VDP_CTRL).l
                dbf     d0,col_clear
                move.w  (VDP_MODE2_RAM).w,(VDP_CTRL).l
                move.w  (VDP_BGCOL_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: set_vdp_reg_m2_bgcol_ram_clear+4   j
                rts
; End of function set_vdp_reg_m2_bgcol_ram_clear
set_vdp_reg_m2_bgcol_clear_ram:
                tst.b   (vdp_byte_FFF746).w
                bpl.w   end
                move.w  (VDP_MODE2_RAM).w,d0
                bclr    #VDPR_BIT_DISPLAY_OR_FILL,d0
                move.w  d0,(VDP_CTRL).l
                move.w  #VDPR_BGCOL,(VDP_CTRL).l
end:                                    ; CODE XREF: set_vdp_reg_m2_bgcol_clear_ram+4   j
                rts
; End of function set_vdp_reg_m2_bgcol_clear_ram
set_vdp_reg_m2_bgcol_ram:
                tst.b   (vdp_byte_FFF746).w
                bpl.w   end
                move.w  (VDP_MODE2_RAM).w,(VDP_CTRL).l
                move.w  (VDP_BGCOL_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: set_vdp_reg_m2_bgcol_ram+4   j
                rts
; End of function set_vdp_reg_m2_bgcol_ram
hblank_update:                          ; CODE XREF: VBLANK:ntsc   p
                move.w  (HBLANK_FX_ID).w,d0
                movea.l jpt_135E(pc,d0.w),a0
                jmp     (a0)            ; switch 23 cases
; End of function hblank_update
; ---------------------------------------------------------------------------
jpt_135E:       dc.l hblank_fx_0x0_0x14_0x1C ; DATA XREF: hblank_update+4   o
                dc.l hblank_fx_0x4      ; jump table for switch statement
                dc.l hblank_fx_0x8
                dc.l hblank_fx_0xC
                dc.l hblank_fx_0x10
                dc.l hblank_fx_0x0_0x14_0x1C
                dc.l hblank_fx_0x18
                dc.l hblank_fx_0x0_0x14_0x1C
                dc.l hblank_fx_0x20
                dc.l hblank_fx_0x24
                dc.l hblank_fx_0x28
                dc.l hblank_fx_0x2C
                dc.l hblank_fx_0x30_0x38
                dc.l hblank_fx_0x34
                dc.l hblank_fx_0x30_0x38
                dc.l hblank_fx_0x3C
                dc.l hblank_fx_0x40
                dc.l hblank_fx_0x44
                dc.l hblank_fx_0x48
                dc.l hblank_fx_0x4C
                dc.l hblank_fx_0x50
                dc.l hblank_fx_0x54
                dc.l hblank_fx_0x58
; jumptable 0000135E cases 0,5,7
hblank_fx_0x0_0x14_0x1C:                ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                andi.b  #$EF,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
                move.w  #$4E73,(word_FFEE00).w
end:                                    ; CODE XREF: hblank_fx_0x0_0x14_0x1C+4   j
                rts
; End of function hblank_fx_0x0_0x14_0x1C
; jumptable 0000135E case 15
hblank_fx_0x3C:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #0,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1418(pc),a0
                nop
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x3C+4   j
                lea     (word_FF9E00).w,a6
                rts
; End of function hblank_fx_0x3C
; ---------------------------------------------------------------------------
stru_1418:      dc.w T_CPY_RAM          ; type ; DATA XREF: hblank_fx_0x3C+1A   o hblank_fx_0x20+1A   o ...
                dc.l word_1422          ; src
                dc.w $EE00              ; dest
                dc.w $FFFF
word_1422:      dc.w $0020              ; DATA XREF: ROM:stru_1418   o
set_vsram_data_a6:
                move.l  #VSRAM_ADDR_CMD,(VDP_CTRL).l
                move.w  (a6)+,(VDP_DATA).l
                rte
; End of function set_vsram_data_a6
; jumptable 0000135E case 8
hblank_fx_0x20:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #1,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1418(pc),a0
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x20+4   j
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     (word_FF9E00).w,a6
                rts
; End of function hblank_fx_0x20
; jumptable 0000135E case 11
hblank_fx_0x2C:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #7,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1418(pc),a0
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x2C+4   j
                lea     (word_FF9E00).w,a6
                rts
; End of function hblank_fx_0x2C
; jumptable 0000135E case 2
hblank_fx_0x8:                          ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #7,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1418(pc),a0
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x8+4   j
                lea     (word_FF9FC0).w,a6
                rts
; End of function hblank_fx_0x8
; jumptable 0000135E case 3
hblank_fx_0xC:                          ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #0,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1528(pc),a0
                nop
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0xC+4   j
                lea     (word_FF9E00).w,a6
                rts
; End of function hblank_fx_0xC
; ---------------------------------------------------------------------------
stru_1528:      dc.w T_CPY_RAM          ; type ; DATA XREF: hblank_fx_0xC+1A   o hblank_fx_0x10+1A   o ...
                dc.l word_1532          ; src
                dc.w $EE00              ; dest
                dc.w $FFFF
word_1532:      dc.w $20                ; DATA XREF: ROM:stru_1528   o
set_vsram_data_0002_a6:
                move.l  #$40020010,(VDP_CTRL).l ; DO_WRITE_TO_VSRAM_AT_$0002_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (a6)+,(VDP_DATA).l
                rte
; End of function set_vsram_data_0002_a6
; jumptable 0000135E case 9
hblank_fx_0x24:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.s   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1594(pc),a0
                nop
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x24+4   j
                move.l  #$40020010,(VDP_CTRL).l ; DO_WRITE_TO_VSRAM_AT_$0002_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (word_FFEC04).w,(VDP_DATA).l
                move.b  (byte_FFC66B).w,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                rts
; End of function hblank_fx_0x24
; ---------------------------------------------------------------------------
stru_1594:      dc.w T_CPY_RAM          ; type ; DATA XREF: hblank_fx_0x24+12   o
                dc.l word_159E          ; src
                dc.w $EE00              ; dest
                dc.w $FFFF
word_159E:      dc.w $20                ; DATA XREF: ROM:stru_1594   o
sub_15A0:
                move.l  #$40020010,(VDP_CTRL).l ; DO_WRITE_TO_VSRAM_AT_$0002_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (word_FF9E00).w,(VDP_DATA).l
                move.w  #$8AFF,(VDP_CTRL).l ; SET_HBLANK_COUNTER_VALUE_$00FF
                rte
; End of function sub_15A0
; jumptable 0000135E case 4
hblank_fx_0x10:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #1,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1528(pc),a0
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x10+4   j
                lea     (word_FF9E00).w,a6
                rts
; End of function hblank_fx_0x10
; jumptable 0000135E case 1
hblank_fx_0x4:                          ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #3,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1528(pc),a0
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x4+4   j
                lea     (word_FF9E00).w,a6
                rts
; End of function hblank_fx_0x4
; jumptable 0000135E case 10
hblank_fx_0x28:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.s   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #7,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1528(pc),a0
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x28+4   j
                lea     (word_FF9E00).w,a6
                rts
; End of function hblank_fx_0x28
; jumptable 0000135E case 13
hblank_fx_0x34:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #1,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1418(pc),a0
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x34+4   j
                lea     (word_FF9C00).w,a6
                rts
; End of function hblank_fx_0x34
; jumptable 0000135E case 17
hblank_fx_0x44:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #$C0,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_16E6(pc),a0
                nop
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
                move.w  (VDP_WINY_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x44+4   j
                move.w  (VDP_PLANEA_RAM).w,(VDP_CTRL).l
                lea     (VDP_CTRL).l,a6
                rts
; End of function hblank_fx_0x44
; ---------------------------------------------------------------------------
stru_16E6:      dc.w T_CPY_RAM          ; type ; DATA XREF: hblank_fx_0x44+1A   o
                dc.l word_16F0          ; src
                dc.w $EE00              ; dest
                dc.w $FFFF
word_16F0:      dc.w $40                ; DATA XREF: ROM:stru_16E6   o
sub_16F2:
                move.w  #$8210,(a6)     ; SET_PLANE_A_ADDR_$4000
                move.l  #VSRAM_ADDR_CMD,(a6)
                move.w  #0,(VDP_DATA).l
                move.l  #$70000003,(a6) ; DO_WRITE_TO_VRAM_AT_$F000_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (word_FF0180).l,(VDP_DATA).l
                move.w  #$10,(word_FF0186).l
end:                                    ; CODE XREF: sub_16F2+30   j
                subq.w  #1,(word_FF0186).l
                bne.s   end
                move.w  #$8228,(a6)     ; SET_PLANE_A_ADDR_$A000
                rte
; End of function sub_16F2
; jumptable 0000135E case 19
hblank_fx_0x4C:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #1,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1764(pc),a0
                nop
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x4C+4   j
                movea.w #(word_FF9C04-M68K_RAM),a6
                rts
; End of function hblank_fx_0x4C
; ---------------------------------------------------------------------------
stru_1764:      dc.w T_CPY_RAM          ; type ; DATA XREF: hblank_fx_0x4C+1A   o
                dc.l word_176E          ; src
                dc.w $EE00              ; dest
                dc.w $FFFF
word_176E:      dc.w $40                ; DATA XREF: ROM:stru_1764   o
sub_1770:
                move.l  #VSRAM_ADDR_CMD,(VDP_CTRL).l
                move.l  (a6)+,(VDP_DATA).l
                rte
; End of function sub_1770
; jumptable 0000135E cases 12,14
hblank_fx_0x30_0x38:                    ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   jump
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #$C8,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_183C(pc),a0
                nop
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
jump:                                   ; CODE XREF: hblank_fx_0x30_0x38+4   j
                move.w  (VDP_PLANEA_RAM).w,(VDP_CTRL).l
                move.w  (VDP_PLANEB_RAM).w,(VDP_CTRL).l
                move.w  (VDP_BGCOL_RAM).w,(VDP_CTRL).l
                move.l  #$70020003,(VDP_CTRL).l ; DO_WRITE_TO_VRAM_AT_$F002_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (VSRAM_FFE402).w,(VDP_DATA).l
                move.l  #$70000003,(VDP_CTRL).l ; DO_WRITE_TO_VRAM_AT_$F000_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (VSRAM_FFE400).w,(VDP_DATA).l
                move.l  #$40020010,(VDP_CTRL).l ; DO_WRITE_TO_VSRAM_AT_$0002_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (VSRAM_FFEC02).w,(VDP_DATA).l
                move.l  #$40000010,(VDP_CTRL).l ; DO_WRITE_TO_VSRAM_AT_$0000_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (VSRAM_FFEC00).w,(VDP_DATA).l
                movea.w #(word_FF9FF8-M68K_RAM),a0
                move.w  (VSRAM_FFEC00).w,(a0)+
                move.w  (VSRAM_FFEC02).w,(a0)+
                move.w  (word_FFA928).w,d0
                neg.w   d0
                cmpi.w  #$30,(HBLANK_FX_ID).w ; '0'
                beq.s   end
                move.w  (VSRAM_FFE400).w,d0
end:                                    ; CODE XREF: hblank_fx_0x30_0x38+AC   j
                move.w  d0,(a0)+
                movea.w #(word_FF9FF8-M68K_RAM),a6
                rts
; End of function hblank_fx_0x30_0x38
; ---------------------------------------------------------------------------
stru_183C:      dc.w T_CPY_RAM          ; type ; DATA XREF: hblank_fx_0x30_0x38+1A   o
                dc.l word_1846          ; src
                dc.w $EE00              ; dest
                dc.w $FFFF
word_1846:      dc.w $200               ; DATA XREF: ROM:stru_183C   o
sub_1848:
                move.l  #$40020010,(VDP_CTRL).l ; DO_WRITE_TO_VSRAM_AT_$0002_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (a6)+,(VDP_DATA).l
                move.l  #$40000010,(VDP_CTRL).l ; DO_WRITE_TO_VSRAM_AT_$0000_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (a6)+,(VDP_DATA).l
                move.l  #$70020003,(VDP_CTRL).l ; DO_WRITE_TO_VRAM_AT_$F002_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (a6)+,(VDP_DATA).l
                move.l  #$70000003,(VDP_CTRL).l ; DO_WRITE_TO_VRAM_AT_$F000_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  #0,(VDP_DATA).l
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
                move.w  #$8238,(VDP_CTRL).l ; SET_PLANE_A_ADDR_$E000
                move.w  #$8406,(VDP_CTRL).l ; SET_PLANE_B_ADDR_$C000
                move.w  #$8718,(VDP_CTRL).l ; SET_BG_AS_17PAL_9TH_COLOR
                rte
; End of function sub_1848
; jumptable 0000135E case 6
hblank_fx_0x18:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #3,(VDP_HRATE_RAM+1).w
                lea     stru_193E(pc),a0
                nop
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
end:                                    ; CODE XREF: hblank_fx_0x18+4   j
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
                lea     (word_FF9800).w,a6
                rts
; End of function hblank_fx_0x18
; ---------------------------------------------------------------------------
stru_193E:      dc.w T_CPY_RAM          ; type ; DATA XREF: hblank_fx_0x18+12   o
                dc.l word_1948          ; src
                dc.w $EE00              ; dest
                dc.w $FFFF
word_1948:      dc.w $20                ; DATA XREF: ROM:stru_193E   o
sub_194A:
                move.l  #$C00A0000,(VDP_CTRL).l ; DO_WRITE_TO_CRAM_AT_$000A_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (a6)+,(VDP_DATA).l
                rte
; End of function sub_194A
; jumptable 0000135E case 16
hblank_fx_0x40:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   jump
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_19CC(pc),a0
                nop
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
jump:                                   ; CODE XREF: hblank_fx_0x40+4   j
                move.w  (dword_FF8128).w,d1
                neg.w   d1
                add.w   (word_FFA012).w,d1
                move.w  d1,d0
                neg.w   d0
                move.w  d0,(dword_FF8134).w
                addi.w  #$DF,d1
                cmpi.w  #$E2,d1
                bmi.s   end
                move.w  #$E2,d1
end:                                    ; CODE XREF: hblank_fx_0x40+48   j
                andi.w  #$FF,d1
                move.b  d1,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                move.w  (VDP_MODE3_RAM).w,(VDP_CTRL).l
                move.w  (VDP_PLANEB_RAM).w,(VDP_CTRL).l
                rts
; End of function hblank_fx_0x40
; ---------------------------------------------------------------------------
stru_19CC:      dc.w T_CPY_RAM          ; type ; DATA XREF: hblank_fx_0x40+14   o
                dc.l word_19D6          ; src
                dc.w $EE00              ; dest
                dc.w $FFFF
word_19D6:      dc.w $200               ; DATA XREF: ROM:stru_19CC   o
sub_19D8:
                move.l  #$40020010,(VDP_CTRL).l ; DO_WRITE_TO_VSRAM_AT_$0002_ADDR
                                        ; DO_OPERATION_WITHOUT_DMA
                move.w  (dword_FF8134).w,(VDP_DATA).l
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
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                move.w  #$8B00,(VDP_CTRL).l ; SET_HSCROLL_TYPE_AS_FULLSCREEN
                                        ; FULLSCREEN_VSCROLL_MODE
                                        ; DISABLE_EXT_INTERRUPT
                move.w  #$8402,(VDP_CTRL).l ; SET_PLANE_B_ADDR_$4000
                rte
; End of function sub_19D8
; jumptable 0000135E case 18
hblank_fx_0x48:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #3,(VDP_HRATE_RAM+1).w
                lea     stru_1AC8(pc),a0
                nop
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
end:                                    ; CODE XREF: hblank_fx_0x48+4   j
                move.w  (VDP_BGCOL_RAM).w,(VDP_CTRL).l
                move.w  (VDP_MODE4_RAM).w,(VDP_CTRL).l
                movea.w #(word_FF9C00-M68K_RAM),a6
                rts
; End of function hblank_fx_0x48
; ---------------------------------------------------------------------------
stru_1AC8:      dc.w T_CPY_RAM          ; type ; DATA XREF: hblank_fx_0x48+12   o
                dc.l word_1AD2          ; src
                dc.w $EE00              ; dest
                dc.w $FFFF
word_1AD2:      dc.w $20                ; DATA XREF: ROM:stru_1AC8   o
sub_1AD4:
                move.w  (a6)+,(VDP_CTRL).l
                rte
; End of function sub_1AD4
; jumptable 0000135E case 20
hblank_fx_0x50:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #1,(VDP_HRATE_RAM+1).w
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     stru_1418(pc),a0
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x50+4   j
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                lea     (word_FF9C00).w,a6
                rts
; End of function hblank_fx_0x50
; jumptable 0000135E case 21
hblank_fx_0x54:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #0,(VDP_HRATE_RAM+1).w
                lea     stru_1B6E(pc),a0
                nop
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x54+4   j
                move.w  (VDP_MODE3_RAM).w,(VDP_CTRL).l
                move.w  (VDP_PLANEA_RAM).w,(VDP_CTRL).l
                lea     (word_FF9E40).w,a6
                move.w  (VDP_HRATE_RAM).w,(VDP_CTRL).l
                rts
; End of function hblank_fx_0x54
; ---------------------------------------------------------------------------
stru_1B6E:      dc.w T_CPY_RAM          ; type ; DATA XREF: hblank_fx_0x54+12   o
                dc.l word_1B78          ; src
                dc.w $EE00              ; dest
                dc.w $FFFF
word_1B78:      dc.w $200               ; DATA XREF: ROM:stru_1B6E   o
sub_1B7A:
                move.w  (a6)+,(VDP_CTRL).l
                move.l  #VSRAM_ADDR_CMD,(VDP_CTRL).l
                move.w  (a6)+,(VDP_DATA).l
                move.w  (a6)+,(VDP_CTRL).l
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
                move.w  (a6)+,(VDP_CTRL).l
                rte
; End of function sub_1B7A
; jumptable 0000135E case 22
hblank_fx_0x58:                         ; CODE XREF: hblank_update+8   j
                                        ; DATA XREF: ROM:jpt_135E   o
                move.w  (GFX_HBLANK_INIT_FLAG_IDK).w,d0
                bne.w   end
                addq.w  #4,(GFX_HBLANK_INIT_FLAG_IDK).w
                move.b  #$80,(VDP_HRATE_RAM+1).w
                lea     stru_1C6C(pc),a0
                nop
                jsr     (gfx_read_data).l
                ori.b   #$10,(VDP_MODE1_RAM+1).w
                move.w  (VDP_MODE1_RAM).w,(VDP_CTRL).l
end:                                    ; CODE XREF: hblank_fx_0x58+4   j
                move.w  (VDP_PLANEA_RAM).w,(VDP_CTRL).l
                move.w  (VDP_PLANEB_RAM).w,(VDP_CTRL).l
                move.w  (VDP_WINX_RAM).w,(VDP_CTRL).l
                move.w  (VDP_WINY_RAM).w,(VDP_CTRL).l
                rts
; End of function hblank_fx_0x58
; ---------------------------------------------------------------------------
stru_1C6C:      dc.w T_CPY_RAM          ; type ; DATA XREF: hblank_fx_0x58+12   o
                dc.l word_1C76          ; src
                dc.w $EE00              ; dest
                dc.w $FFFF
word_1C76:      dc.w $200               ; DATA XREF: ROM:stru_1C6C   o
sub_1C78:
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
                move.w  #$910A,(VDP_CTRL).l ; MOVE_WINDOW_HORZ_LEFT
                                        ; MOVE_BY_10_CELLS
                move.w  #$9200,(VDP_CTRL).l ; MOVE_WINDOW_VERT_LEFT
                                        ; MOVE_BY_0_CELLS
                rte
; End of function sub_1C78
sub_1D0A:
                ori.w   #$46FC,d0
                move.l  d0,-(a3)
                move.l  #$70000083,(VDP_CTRL).l ; DO_WRITE_TO_VRAM_AT_$F000_ADDR
                                        ; DO_OPERATION_USING_DMA
                move.w  (a6)+,(VDP_DATA).l
                move.l  #VSRAM_ADDR_CMD,(VDP_CTRL).l
                move.w  (a6)+,(VDP_DATA).l
                rte
; End of function sub_1D0A
dma_queue_prepend_1D32:
                clr.b   d3
                bra.s   load_ptr
; ---------------------------------------------------------------------------
                move.b  #1,d3
load_ptr:                               ; CODE XREF: dma_queue_prepend_1D32+2   j
                movea.w (DMA_QUEUE_PTR0).w,a1
                movea.w (DMA_QUEUE_SRC_70E).w,a2
loop0:                                  ; CODE XREF: dma_queue_prepend_1D32+6A   j
                                        ; dma_queue_prepend_1D32+6E   j
                move.w  (a0)+,d0
                move.l  (a0)+,-(a1)
                move.l  a2,d1
                andi.l  #$FFFFFF,d1
                lsr.l   #1,d1
                move.w  #$9500,d2       ; SET_LOWER_BYTE_OF_DMA_SRC_TO_$00
                move.b  d1,d2
                move.w  d2,-(a1)
                lsr.l   #8,d1
                move.w  #$9600,d2       ; SET_MIDDLE_BYTE_OF_DMA_SRC_TO_$00
                move.b  d1,d2
                move.w  d2,-(a1)
                lsr.l   #8,d1
                move.w  #$9700,d2       ; SET_HIGH_BYTE_OF_DMA_SRC_TO_$00
                                        ; SET_COPY_M68K_TO_VRAM_DMA_MODE
                move.b  d1,d2
                move.w  d2,-(a1)
                move.w  #AUTO_INC_2,-(a1)
                move.l  #$94009300,d1   ; SET_LOWER_BYTE_OF_DMA_LEN_TO_$00
                                        ; SET_HIGHER_BYTE_OF_DMA_LEN_TO_$00
loop1:                                  ; CODE XREF: dma_queue_prepend_1D32+5A   j
                                        ; dma_queue_prepend_1D32+60   j
                move.b  (a0)+,d0
                cmpi.b  #$FE,d0
                beq.s   loop0_cond
                cmpi.b  #$FF,d0
                beq.s   end
                tst.b   d3
                beq.s   loop1_cond
                move.w  d0,(a2)+
                addq.b  #1,d1
                bra.s   loop1
; ---------------------------------------------------------------------------
loop1_cond:                             ; CODE XREF: dma_queue_prepend_1D32+54   j
                clr.w   (a2)+
                addq.b  #1,d1
                bra.s   loop1
; ---------------------------------------------------------------------------
loop0_cond:                             ; CODE XREF: dma_queue_prepend_1D32+4A   j
                move.l  d1,-(a1)
                move.w  a0,d2
                btst    #0,d2
                beq.s   loop0
                addq.l  #1,a0
                bra.s   loop0
; ---------------------------------------------------------------------------
end:                                    ; CODE XREF: dma_queue_prepend_1D32+50   j
                move.l  d1,-(a1)
                move.w  a1,(DMA_QUEUE_PTR0).w
                move.w  a2,(DMA_QUEUE_SRC_70E).w
                rts
; End of function dma_queue_prepend_1D32
dma_queue_prepend_1DAE:
                clr.b   d3
                bra.s   loc_1DB6
; ---------------------------------------------------------------------------
                move.b  #1,d3
loc_1DB6:                               ; CODE XREF: dma_queue_prepend_1DAE+2   j
                movea.w (DMA_QUEUE_PTR0).w,a1
                movea.w (DMA_QUEUE_SRC_70E).w,a2
loc_1DBE:                               ; CODE XREF: dma_queue_prepend_1DAE+68   j
                                        ; dma_queue_prepend_1DAE+6C   j
                move.l  (a0)+,-(a1)
                move.l  a2,d1
                andi.l  #$FFFFFF,d1
                lsr.l   #1,d1
                move.w  #$9500,d2       ; SET_LOWER_BYTE_OF_DMA_SRC_TO_$00
                move.b  d1,d2
                move.w  d2,-(a1)
                lsr.l   #8,d1
                move.w  #$9600,d2       ; SET_MIDDLE_BYTE_OF_DMA_SRC_TO_$00
                move.b  d1,d2
                move.w  d2,-(a1)
                lsr.l   #8,d1
                move.w  #$9700,d2       ; SET_HIGH_BYTE_OF_DMA_SRC_TO_$00
                                        ; SET_COPY_M68K_TO_VRAM_DMA_MODE
                move.b  d1,d2
                move.w  d2,-(a1)
                move.w  #AUTO_INC_2,-(a1)
                move.l  #$94009300,d1   ; SET_LOWER_BYTE_OF_DMA_LEN_TO_$00
                                        ; SET_HIGHER_BYTE_OF_DMA_LEN_TO_$00
loc_1DF0:                               ; CODE XREF: dma_queue_prepend_1DAE+58   j
                                        ; dma_queue_prepend_1DAE+5E   j
                move.b  (a0)+,d0
                cmpi.b  #$FE,d0
                beq.s   loc_1E0E
                cmpi.b  #$FF,d0
                beq.s   loc_1E1C
                tst.b   d3
                beq.s   loc_1E08
                move.w  d0,(a2)+
                addq.b  #1,d1
                bra.s   loc_1DF0
; ---------------------------------------------------------------------------
loc_1E08:                               ; CODE XREF: dma_queue_prepend_1DAE+52   j
                clr.w   (a2)+
                addq.b  #1,d1
                bra.s   loc_1DF0
; ---------------------------------------------------------------------------
loc_1E0E:                               ; CODE XREF: dma_queue_prepend_1DAE+48   j
                move.l  d1,-(a1)
                move.w  a0,d2
                btst    #0,d2
                beq.s   loc_1DBE
                addq.l  #1,a0
                bra.s   loc_1DBE
; ---------------------------------------------------------------------------
loc_1E1C:                               ; CODE XREF: dma_queue_prepend_1DAE+4E   j
                move.l  d1,-(a1)
                move.w  a1,(DMA_QUEUE_PTR0).w
                move.w  a2,(DMA_QUEUE_SRC_70E).w
                rts
; End of function dma_queue_prepend_1DAE
dma_queue_prepend_1E28:
                movea.w (DMA_QUEUE_PTR0).w,a1
                movea.w (DMA_QUEUE_SRC_70E).w,a2
                move.l  d2,-(a1)
                move.l  a2,d4
                andi.l  #$FFFFFF,d4
                lsr.l   #1,d4
                move.w  #$9500,d2       ; SET_LOWER_BYTE_OF_DMA_SRC_TO_$00
                move.b  d4,d2
                move.w  d2,-(a1)
                lsr.l   #8,d4
                move.w  #$9600,d2       ; SET_MIDDLE_BYTE_OF_DMA_SRC_TO_$00
                move.b  d4,d2
                move.w  d2,-(a1)
                lsr.l   #8,d4
                move.w  #$9700,d2       ; SET_HIGH_BYTE_OF_DMA_SRC_TO_$00
                                        ; SET_COPY_M68K_TO_VRAM_DMA_MODE
                move.b  d4,d2
                move.w  d2,-(a1)
                move.w  d3,d2
                bne.w   loc_1E6E
                moveq   #5,d3
                move.w  #8,d2
                andi.l  #$FFFF,d1
                bra.w   loc_1E7C
; ---------------------------------------------------------------------------
loc_1E6E:                               ; CODE XREF: dma_queue_prepend_1E28+32   j
                subq.w  #1,d2
                asl.w   #1,d2
                andi.l  #$FFFF,d1
                bra.w   loc_1E94
; ---------------------------------------------------------------------------
loc_1E7C:                               ; CODE XREF: dma_queue_prepend_1E28+42   j
                                        ; dma_queue_prepend_1E28+66   j
                divu.w  word_1EC0(pc,d2.w),d1
                bne.w   loc_1E98
                move.b  #$B4,d0
                move.w  d0,(a2)+
                swap    d1
                subq.w  #2,d2
                bpl.s   loc_1E7C
                bra.w   loc_1EA8
; ---------------------------------------------------------------------------
loc_1E94:                               ; CODE XREF: dma_queue_prepend_1E28+50   j
                                        ; dma_queue_prepend_1E28+7E   j
                divu.w  word_1EC0(pc,d2.w),d1
loc_1E98:                               ; CODE XREF: dma_queue_prepend_1E28+58   j
                addi.b  #-$4B,d1
                move.b  d1,d0
                move.w  d0,(a2)+
                clr.w   d1
                swap    d1
                subq.w  #2,d2
                bpl.s   loc_1E94
loc_1EA8:                               ; CODE XREF: dma_queue_prepend_1E28+68   j
                move.w  #AUTO_INC_2,-(a1)
                move.l  #$94009300,d2   ; SET_LOWER_BYTE_OF_DMA_LEN_TO_$00
                                        ; SET_HIGHER_BYTE_OF_DMA_LEN_TO_$00
                add.b   d3,d2
                move.l  d2,-(a1)
                move.w  a1,(DMA_QUEUE_PTR0).w
                move.w  a2,(DMA_QUEUE_SRC_70E).w
                rts
; End of function dma_queue_prepend_1E28
; ---------------------------------------------------------------------------
word_1EC0:      dc.w     1,   10,  100, 1000
dma_queue_prepend_1EC8:
                move.l  (a0),-(a3)
                movea.w (DMA_QUEUE_PTR0).w,a1
                movea.w (DMA_QUEUE_SRC_70E).w,a2
                move.l  d2,-(a1)
                move.l  a2,d4
                andi.l  #$FFFFFF,d4
                lsr.l   #1,d4
                move.w  #$9500,d2       ; SET_LOWER_BYTE_OF_DMA_SRC_TO_$00
                move.b  d4,d2
                move.w  d2,-(a1)
                lsr.l   #8,d4
                move.w  #$9600,d2       ; SET_MIDDLE_BYTE_OF_DMA_SRC_TO_$00
                move.b  d4,d2
                move.w  d2,-(a1)
                lsr.l   #8,d4
                move.w  #$9700,d2       ; SET_HIGH_BYTE_OF_DMA_SRC_TO_$00
                                        ; SET_COPY_M68K_TO_VRAM_DMA_MODE
                move.b  d4,d2
                move.w  d2,-(a1)
                move.w  d3,d2
                bne.w   loc_1F10
                moveq   #5,d3
                move.w  #8,d2
                andi.l  #$FFFF,d1
                bra.w   loc_1F1E
; ---------------------------------------------------------------------------
loc_1F10:                               ; CODE XREF: dma_queue_prepend_1EC8+34   j
                subq.w  #1,d2
                asl.w   #1,d2
                andi.l  #$FFFF,d1
                bra.w   loc_1F36
; ---------------------------------------------------------------------------
loc_1F1E:                               ; CODE XREF: dma_queue_prepend_1EC8+44   j
                                        ; dma_queue_prepend_1EC8+68   j
                divu.w  word_1F62(pc,d2.w),d1
                bne.w   loc_1F3A
                move.b  #$B4,d0
                move.w  d0,(a2)+
                swap    d1
                subq.w  #2,d2
                bpl.s   loc_1F1E
                bra.w   loc_1F4A
; ---------------------------------------------------------------------------
loc_1F36:                               ; CODE XREF: dma_queue_prepend_1EC8+52   j
                                        ; dma_queue_prepend_1EC8+80   j
                divu.w  word_1F62(pc,d2.w),d1
loc_1F3A:                               ; CODE XREF: dma_queue_prepend_1EC8+5A   j
                addi.b  #-$4B,d1
                move.b  d1,d0
                move.w  d0,(a2)+
                clr.w   d1
                swap    d1
                subq.w  #2,d2
                bpl.s   loc_1F36
loc_1F4A:                               ; CODE XREF: dma_queue_prepend_1EC8+6A   j
                move.w  #AUTO_INC_2,-(a1)
                move.l  #$94009300,d2   ; SET_LOWER_BYTE_OF_DMA_LEN_TO_$00
                                        ; SET_HIGHER_BYTE_OF_DMA_LEN_TO_$00
                add.b   d3,d2
                move.l  d2,-(a1)
                move.w  a1,(DMA_QUEUE_PTR0).w
                move.w  a2,(DMA_QUEUE_SRC_70E).w
                rts
; End of function dma_queue_prepend_1EC8
; ---------------------------------------------------------------------------
word_1F62:      dc.w     1,   16,  256, 4096
dma_queue_prepend_player:               ; CODE XREF: gfx_build_player+50   p gfx_update_unused+62   p
                move.w  (a1)+,d1        ; dma len
                move.w  d0,d7
                rol.w   #2,d7
                andi.w  #3,d7
                ori.w   #$80,d7
                move.w  d7,-(a0)        ; dma dest low
                move.w  d0,d7
                andi.w  #%0011111111111111,d7
                ori.w   #%0100000000000000,d7
                move.w  d7,-(a0)        ; dma dest high
                add.w   d1,d0
                lsr.w   #1,d1
                move.w  #VDPR_DMALEN_L,d7
                move.b  d1,d7
                move.w  d7,-(a0)
                lsr.w   #8,d1
                move.w  #VDPR_DMALEN_H,d7
                move.b  d1,d7
                move.w  d7,-(a0)
                move.w  #AUTO_INC_2,-(a0)
                move.l  a1,d1           ; dma src
                andi.l  #$00FFFFFF,d1
                lsr.l   #1,d1
                move.w  #VDPR_DMASRC_L,d7
                move.b  d1,d7
                move.w  d7,-(a0)
                lsr.l   #8,d1
                move.w  #VDPR_DMASRC_M,d7
                move.b  d1,d7
                move.w  d7,-(a0)
                lsr.l   #8,d1
                move.w  #VDPR_DMASRC_H,d7
                move.b  d1,d7
                move.w  d7,-(a0)
                rts
; End of function dma_queue_prepend_player
copy_to_pal_ram:                        ; CODE XREF: no_recap_screen+8E   p
                lea     (PALETTE_RAM_0).w,a2
                lea     (PALETTE_RAM_1).w,a3
                bsr.w   copy_loop
                bsr.w   copy_loop
                bsr.w   copy_loop
                bsr.w   copy_loop
                rts
; ---------------------------------------------------------------------------
copy_loop:                              ; CODE XREF: copy_to_pal_ram+8   p copy_to_pal_ram+C   p ...
                move.l  (a0)+,d0
                beq.w   jump
                movea.l d0,a1
                move.l  (a1),(a2)+
                move.l  (a1)+,(a3)+
                move.l  (a1),(a2)+
                move.l  (a1)+,(a3)+
                move.l  (a1),(a2)+
                move.l  (a1)+,(a3)+
                move.l  (a1),(a2)+
                move.l  (a1)+,(a3)+
                move.l  (a1),(a2)+
                move.l  (a1)+,(a3)+
                move.l  (a1),(a2)+
                move.l  (a1)+,(a3)+
                move.l  (a1),(a2)+
                move.l  (a1)+,(a3)+
                move.l  (a1),(a2)+
                move.l  (a1)+,(a3)+
                rts
; ---------------------------------------------------------------------------
jump:                                   ; CODE XREF: copy_to_pal_ram+1C   j
                lea     $20(a2),a2
                lea     $20(a3),a3
                rts
; End of function copy_to_pal_ram
gfx_sprite_build:                       ; CODE XREF: gamemode_play_text_crawl+4A   p
                                        ; gamemode_play_options_screen+68   p ...
                tst.b   (GFX_SPR_BUILD_FLAG).w
                bne.w   skip_init
                bsr.w   gfx_sprite_slot_init
skip_init:                              ; CODE XREF: gfx_sprite_build+4   j
                move.b  (byte_FF813E).w,d3
                ror.l   #8,d3
                move.b  (GFX_SPR_SLOTS_USED).w,d4
                movea.w (GFX_SPR_TABLE).w,a3
                lea     (PLAYER_STRUCT).w,a5
                bsr.w   gfx_build_player
                move.w  (OBJECT_CNT).w,d2
                beq.w   is_zero
                subq.w  #1,d2
                lea     (OBJECT_PTRS).w,a2
loop:                                   ; CODE XREF: gfx_sprite_build:next_sprite   j
                movea.w (a2)+,a5
                move.b  CRTL_UNK2(a5),d7
                bpl.s   is_positive
                add.b   d7,d7
                bpl.w   gfx_insert_sprite
                movea.l CRTL_SPRITE_PTR(a5),a4
                add.b   d7,d7
                bpl.s   d7_is_positive
                bsr.w   gfx_advance_sprite_frame_idk
d7_is_positive:                         ; CODE XREF: gfx_sprite_build+44   j
                swap    d2
                bsr.w   gfx_build_sprite_pieces_full
                swap    d2
next_sprite:                            ; CODE XREF: gfx_sprite_build:is_positive   j gfx_sprite_build+66   j ...
                dbf     d2,loop
is_zero:                                ; CODE XREF: gfx_sprite_build+26   j
                move.b  d4,(GFX_SPR_SLOTS_USED).w
                move.w  a3,(GFX_SPR_TABLE).w
                bra.w   gfx_flush_sprite_slots
; ---------------------------------------------------------------------------
is_positive:                            ; CODE XREF: gfx_sprite_build+36   j
                beq.s   next_sprite
                add.b   d7,d7
                bpl.s   next_sprite
                add.b   d7,d7
                bpl.s   next_sprite
                movea.l CRTL_SPRITE_PTR(a5),a4
                pea     next_sprite(pc)
                bra.w   gfx_advance_sprite_frame_idk
; End of function gfx_sprite_build
gfx_build_player:                       ; CODE XREF: gfx_sprite_build+1E   p
                move.w  CRTL_UNK2(a5),d7
                bmi.w   is_neg          ; most likely check: if unk2 == 0xFF, branch
                beq.s   end
                movea.l CRTL_SPRITE_PTR(a5),a4
                bra.w   sprite_ptr_to_a4
; ---------------------------------------------------------------------------
is_neg:                                 ; CODE XREF: gfx_build_player+4   j
                move.l  CRTL_SPRITE_PTR(a5),d0
                beq.w   end
                movea.l d0,a4
                bsr.w   sprite_ptr_to_a4
                btst    #5,d7
                bne.w   gfx_build_sprite_pieces_full
                lea     CRTL_DMA_SRC_INFO(a5),a2
                cmpa.l  CRTL_SPRITE_PTR_PREV(a5),a4
                beq.w   gfx_build_sprite_pieces_dma_list
                move.l  a4,CRTL_SPRITE_PTR_PREV(a5)
                bsr.w   gfx_build_sprite_pieces_dma_list
                lea     CRTL_DMA_SRC_INFO(a5),a4
                cmpa.w  a4,a2
                beq.w   end
                movea.w (DMA_QUEUE_PTR0).w,a0
                move.w  CRTL_SPRITE_DEST(a5),d0
loop:                                   ; CODE XREF: gfx_build_player+58   j
                movea.l (a4)+,a1
                jsr     (dma_queue_prepend_player).l
                cmpa.w  a4,a2
                bhi.s   loop
                move.w  a0,(DMA_QUEUE_PTR0).w
end:                                    ; CODE XREF: gfx_build_player+8   j gfx_build_player+16   j ...
                rts
; End of function gfx_build_player
gfx_update_unused:
                move.b  CRTL_UNK2(a5),d7
                bmi.w   loc_210E
                beq.w   end
                add.b   d7,d7
                bpl.w   end
                add.b   d7,d7
                bpl.w   end
                movea.l CRTL_SPRITE_PTR(a5),a4
                bra.w   sprite_ptr_to_a4
; ---------------------------------------------------------------------------
loc_210E:                               ; CODE XREF: gfx_update_unused+4   j
                move.l  CRTL_SPRITE_PTR(a5),d0
                beq.w   end
                movea.l d0,a4
                btst    #5,d7
                beq.w   loc_2128
                movea.l CRTL_SPRITE_PTR(a5),a4
                bsr.w   sprite_ptr_to_a4
loc_2128:                               ; CODE XREF: gfx_update_unused+2E   j
                lea     CRTL_DMA_SRC_INFO(a5),a2
                cmpa.l  CRTL_SPRITE_PTR_PREV(a5),a4
                beq.w   sub_2442
                move.l  a4,CRTL_SPRITE_PTR_PREV(a5)
                bsr.w   sub_2442
                lea     CRTL_DMA_SRC_INFO(a5),a4
                cmpa.w  a4,a2
                beq.w   end
                movea.w (DMA_QUEUE_PTR0).w,a0
                move.w  CRTL_SPRITE_DEST(a5),d0
loop:                                   ; CODE XREF: gfx_update_unused+6A   j
                movea.l (a4)+,a1
                jsr     (dma_queue_prepend_player).l
                cmpa.w  a4,a2
                bhi.s   loop
                move.w  a0,(DMA_QUEUE_PTR0).w
end:                                    ; CODE XREF: gfx_update_unused+8   j gfx_update_unused+E   j ...
                rts
; End of function gfx_update_unused
gfx_advance_sprite_frame_idk:           ; CODE XREF: gfx_sprite_build+46   p gfx_sprite_build+74   j
                move.w  CRTL_UNKC(a5),d0
                tst.b   d0
                bmi.s   is_neg
                beq.s   is_zero
                tst.l   d3
                bmi.s   jump1
                subq.w  #1,d0
jump1:                                  ; CODE XREF: gfx_advance_sprite_frame_idk+C   j
                bne.s   jump2
                addq.w  #4,a4
                move.w  2(a4),d0
                bne.s   a4_to_sprite_ptr
                adda.w  (a4),a4
is_zero:                                ; CODE XREF: gfx_advance_sprite_frame_idk+8   j
                move.w  2(a4),d0
a4_to_sprite_ptr:                       ; CODE XREF: gfx_advance_sprite_frame_idk+18   j
                move.l  a4,CRTL_SPRITE_PTR(a5)
jump2:                                  ; CODE XREF: gfx_advance_sprite_frame_idk:jump1   j
                move.w  d0,CRTL_UNKC(a5)
is_neg:                                 ; CODE XREF: gfx_advance_sprite_frame_idk+6   j
                adda.w  (a4),a4
                rts
; End of function gfx_advance_sprite_frame_idk
sprite_ptr_to_a4:                       ; CODE XREF: gfx_build_player+E   j gfx_build_player+1C   p ...
                movea.l CRTL_SPRITE_PTR(a5),a4
                rts
; End of function sprite_ptr_to_a4
sub_2192:
                move.b  CRTL_UNKD(a5),d0
                bmi.s   jump0
                bne.s   jump1
                move.b  CRTL_UNKC(a5),d1
                ext.w   d1
                adda.w  d1,a4
                move.b  3(a4),d0
                bra.w   jump2
; ---------------------------------------------------------------------------
jump1:                                  ; CODE XREF: sub_2192+6   j
                move.b  CRTL_UNKC(a5),d1
                ext.w   d1
                adda.w  d1,a4
                tst.b   (byte_FF813E).w
                bmi.s   end
jump2:                                  ; CODE XREF: sub_2192+14   j
                subq.b  #1,d0
                move.b  d0,CRTL_UNKD(a5)
                bne.w   end
                movea.l a4,a2
                addq.w  #4,a2
                addq.w  #4,d1
loop:                                   ; CODE XREF: sub_2192+50   j
                move.b  3(a2),d0
                beq.w   jump3
                move.b  d0,CRTL_UNKD(a5)
                move.b  d1,CRTL_UNKC(a5)
                adda.w  (a4),a4
                rts
; ---------------------------------------------------------------------------
jump3:                                  ; CODE XREF: sub_2192+3A   j
                move.w  (a2),d0
                adda.w  d0,a2
                add.w   d0,d1
                bra.s   loop
; ---------------------------------------------------------------------------
jump0:                                  ; CODE XREF: sub_2192+4   j
                move.b  CRTL_UNKC(a5),d1
                ext.w   d1
                adda.w  d1,a4
end:                                    ; CODE XREF: sub_2192+24   j sub_2192+2C   j
                adda.w  (a4),a4
                rts
; End of function sub_2192
gfx_sprite_slot_init:                   ; CODE XREF: gfx_sprite_build+8   p gamemode_play_text_crawl+26   p ...
                moveq   #$3F,d2 ; '?'
                lea     (GFX_SPR_TABLE_HEAD).w,a0
                move.l  #$0000BE0A,d0
loop:                                   ; CODE XREF: gfx_sprite_slot_init+10   j
                move.l  d0,(a0)+
                addq.w  #4,d0
                dbf     d2,loop
                move.w  (word_FFF756).w,d0
                bne.w   jump
                moveq   #1,d0
jump:                                   ; CODE XREF: gfx_sprite_slot_init+18   j
                move.b  d0,(GFX_SPR_SLOTS_USED).w
                asl.w   #3,d0
                addi.w  #$E000,d0
                move.w  d0,(GFX_SPR_TABLE).w
                move.b  #1,(GFX_SPR_BUILD_FLAG).w
                rts
; End of function gfx_sprite_slot_init
gfx_flush_sprite_slots:                 ; CODE XREF: gfx_sprite_build+5E   j
                move.b  #$50,d0 ; 'P'   ; $50, aka 80 is the sprite max
                sub.b   (GFX_SPR_SLOTS_USED).w,d0
                move.b  d0,(GFX_SPR_SLOTS_FREE).w
                moveq   #$3F,d2 ; '?'
                movea.w #(GFX_SPR_TABLE_HEAD-M68K_RAM),a0
                move.w  (word_FFF756).w,d0
                bne.w   FFF756_nonzero
                moveq   #1,d0
FFF756_nonzero:                         ; CODE XREF: gfx_flush_sprite_slots+16   j
                asl.w   #3,d0
                addi.w  #$E000,d0
                movea.w d0,a1
loop:                                   ; CODE XREF: gfx_flush_sprite_slots+30   j
                move.w  (a0)+,d0
                beq.s   is_zero
                move.b  d0,-5(a1)
                movea.w (a0),a1
is_zero:                                ; CODE XREF: gfx_flush_sprite_slots+26   j
                addq.w  #2,a0
                dbf     d2,loop
                move.b  #0,-5(a1)
                clr.b   (GFX_SPR_BUILD_FLAG).w
                rts
; End of function gfx_flush_sprite_slots
gfx_insert_sprite:                      ; CODE XREF: gfx_sprite_build+3A   j
                cmpi.b  #80,d4          ; sprite limit
                bge.s   end
                move.b  CRTL_SPRITE_YOFF(a5),d6
                ext.w   d6
                add.w   CRTL_YPOS(a5),d6
                tst.b   CRTL_UNK3(a5)
                bmi.s   is_minus
                sub.w   (SOME_Y_POS_OFFSET).w,d6
is_minus:                               ; CODE XREF: gfx_insert_sprite+14   j
                cmpi.w  #512,d6
                bcc.s   end
                move.b  CRTL_SPRITE_XOFF(a5),d5
                ext.w   d5
                add.w   CRTL_XPOS(a5),d5
                beq.s   end
                cmpi.w  #544,d5
                bcc.s   end
                move.b  CRTL_UNK20(a5),d0
                andi.w  #%0000000011111100,d0
                movea.w d0,a1
                movea.w GFX_SPR_TABLE_TAIL-$1000000(a1),a0
                move.b  d4,-5(a0)
                move.w  d6,(a3)+        ; sprite y
                move.w  CRTL_SPRITE_PTR(a5),d0
                addq.b  #1,d4
                move.b  d4,d0
                move.w  d0,(a3)+        ; sprite id
                move.w  CRTL_SPRITE_FLAGS(a5),(a3)+ ; sprite flags
                move.w  d5,(a3)+        ; sprite x
                move.w  a3,GFX_SPR_TABLE_TAIL-$1000000(a1)
end:                                    ; CODE XREF: gfx_insert_sprite+4   j gfx_insert_sprite+1E   j ...
                bra.w   next_sprite
; End of function gfx_insert_sprite
posbound_end:                           ; CODE XREF: gfx_build_sprite_pieces_full+24   j
                                        ; gfx_build_sprite_pieces_full+2A   j
                rts
; End of function posbound_end
gfx_build_sprite_pieces_full:           ; CODE XREF: gfx_sprite_build+4C   p gfx_build_player+24   j
XPOS_d5 = d5
YPOS_d6 = d6
                move.w  CRTL_SPRITE_FLAGS(a5),d7
                move.w  d7,d2
                andi.w  #%1111100000000000,d7
                andi.w  #%0000011111111111,d2
                move.w  CRTL_XPOS(a5),XPOS_d5
                move.w  CRTL_YPOS(a5),YPOS_d6
                tst.b   CRTL_UNK3(a5)
                bmi.s   jump0
                sub.w   (SOME_Y_POS_OFFSET).w,YPOS_d6
jump0:                                  ; CODE XREF: gfx_build_sprite_pieces_full+1A   j
                cmpi.w  #512,YPOS_d6    ; if ypos >= 512, branch
                bcc.s   posbound_end
                cmpi.w  #544,XPOS_d5    ; if xpos >= 544, branch
                bcc.s   posbound_end
                move.b  CRTL_UNK20(a5),d0
                andi.w  #%0000000011111100,d0
                movea.w d0,a1
                movea.w GFX_SPR_TABLE_TAIL-$1000000(a1),a0
                move.b  d4,-5(a0)
                btst    #11,d7
                bne.s   jump1
                lea     lea_loop0(pc),a0
                bra.s   loop_entry
; ---------------------------------------------------------------------------
jump1:                                  ; CODE XREF: gfx_build_sprite_pieces_full+42   j
                lea     lea_loop1(pc),a0
                subq.w  #7,XPOS_d5
                bra.s   loop_entry
; ---------------------------------------------------------------------------
lea_loop1:                              ; DATA XREF: gfx_build_sprite_pieces_full:jump1   o
                neg.w   d0
                move.b  -4(a4),d1
                add.w   d1,d1
                andi.w  #%0000000000011000,d1
                sub.w   d1,d0
lea_loop0:                              ; DATA XREF: gfx_build_sprite_pieces_full+44   o
                add.w   XPOS_d5,d0
                bmi.s   d0_neg
                andi.w  #%0000000111111111,d0
                bne.s   d0_nonzero
d0_neg:                                 ; CODE XREF: gfx_build_sprite_pieces_full+62   j
                moveq   #1,d0
d0_nonzero:                             ; CODE XREF: gfx_build_sprite_pieces_full+68   j
                move.w  d3,d1
                bmi.s   exit_loop
                eor.w   d7,d1
                add.w   d2,d1
                move.w  d1,(a3)+
                move.w  d0,(a3)+
loop_entry:                             ; CODE XREF: gfx_build_sprite_pieces_full+48   j
                                        ; gfx_build_sprite_pieces_full+50   j
                cmpi.b  #$50,d4 ; 'P'
                bge.s   end
                move.w  (a4)+,d3
                move.w  (a4)+,d0
                move.w  d0,d1
                swap    d0
                move.b  (a4)+,d0
                ext.w   d0
                btst    #$C,d7
                beq.s   jump6
                neg.w   d0
                lsr.w   #5,d1
                andi.w  #$18,d1
                addq.w  #8,d1
                sub.w   d1,d0
jump6:                                  ; CODE XREF: gfx_build_sprite_pieces_full+8E   j
                add.w   YPOS_d6,d0
                addq.b  #1,d4
                swap    d0
                move.b  d4,d0
                move.l  d0,(a3)+
                move.b  (a4)+,d0
                ext.w   d0
                jmp     (a0)
; ---------------------------------------------------------------------------
exit_loop:                              ; CODE XREF: gfx_build_sprite_pieces_full+6E   j
                andi.w  #%0111111111111111,d1
                eor.w   d7,d1
                add.w   d2,d1
                move.w  d1,(a3)+
                move.w  d0,(a3)+
                move.w  a3,GFX_SPR_TABLE_TAIL-$1000000(a1)
end:                                    ; CODE XREF: gfx_build_sprite_pieces_full+7C   j
                rts
; End of function gfx_build_sprite_pieces_full
posbound_end1:                          ; CODE XREF: gfx_build_sprite_pieces_dma_list+24   j
                                        ; gfx_build_sprite_pieces_dma_list+2A   j
                rts
; End of function posbound_end1
gfx_build_sprite_pieces_dma_list:       ; CODE XREF: gfx_build_player+30   j gfx_build_player+38   p
                move.w  CRTL_SPRITE_FLAGS(a5),d7
                move.w  d7,d2
                andi.w  #%1111100000000000,d7
                andi.w  #%0000011111111111,d2
                move.w  CRTL_XPOS(a5),d5
                move.w  CRTL_YPOS(a5),d6
                tst.b   CRTL_UNK3(a5)
                bmi.s   jump0
                sub.w   (SOME_Y_POS_OFFSET).w,d6
jump0:                                  ; CODE XREF: gfx_build_sprite_pieces_dma_list+1A   j
                cmpi.w  #512,d6
                bcc.s   posbound_end1
                cmpi.w  #544,d5
                bcc.s   posbound_end1
                move.b  CRTL_UNK20(a5),d0
                andi.w  #%0000000011111100,d0
                movea.w d0,a1
                movea.w GFX_SPR_TABLE_TAIL-$1000000(a1),a0
                move.b  d4,-5(a0)
                btst    #$B,d7
                bne.s   jump1
                lea     lea_jump0(pc),a0
                bra.s   loop
; ---------------------------------------------------------------------------
jump1:                                  ; CODE XREF: gfx_build_sprite_pieces_dma_list+42   j
                lea     lea_jump1(pc),a0
                subq.w  #8,d5
loop:                                   ; CODE XREF: gfx_build_sprite_pieces_dma_list+48   j
                                        ; gfx_build_sprite_pieces_dma_list+B4   j
                cmpi.b  #80,d4          ; sprite limit
                bge.s   end
                move.w  (a4)+,d3
                move.l  (a4)+,d0
                move.l  d0,(a2)+
                swap    d0
                move.b  d4,d0
                move.w  d0,d4
                move.b  (a4)+,d0
                ext.w   d0
                btst    #$C,d7
                beq.s   jump2
                neg.w   d0
                move.w  d4,d1
                lsr.w   #5,d1
                andi.w  #%11000,d1
                addi.w  #9,d1
                sub.w   d1,d0
jump2:                                  ; CODE XREF: gfx_build_sprite_pieces_dma_list+6A   j
                add.w   d6,d0
                move.w  d0,(a3)+
                addq.b  #1,d4
                move.w  d4,(a3)+
                move.w  d3,d0
                andi.w  #$1FFF,d0
                eor.w   d7,d0
                add.w   d2,d0
                move.w  d0,(a3)+
                move.b  (a4)+,d0
                ext.w   d0
                jmp     (a0)
; ---------------------------------------------------------------------------
lea_jump1:                              ; DATA XREF: gfx_build_sprite_pieces_dma_list:jump1   o
                neg.w   d0
                move.b  -6(a4),d1
                add.w   d1,d1
                andi.w  #$18,d1
                sub.w   d1,d0
lea_jump0:                              ; DATA XREF: gfx_build_sprite_pieces_dma_list+44   o
                add.w   d5,d0
                bmi.s   jump3
                andi.w  #$1FF,d0
                bne.s   jump4
jump3:                                  ; CODE XREF: gfx_build_sprite_pieces_dma_list+A6   j
                moveq   #1,d0
jump4:                                  ; CODE XREF: gfx_build_sprite_pieces_dma_list+AC   j
                move.w  d0,(a3)+
                add.w   d3,d3
                bcc.s   loop
                move.w  a3,GFX_SPR_TABLE_TAIL-$1000000(a1)
end:                                    ; CODE XREF: gfx_build_sprite_pieces_dma_list+54   j
                rts
; End of function gfx_build_sprite_pieces_dma_list
posbound_end2:                          ; CODE XREF: sub_2442+24   j sub_2442+2A   j
                rts
; End of function posbound_end2
sub_2442:                               ; CODE XREF: gfx_update_unused+42   j gfx_update_unused+4A   p
                move.w  CRTL_SPRITE_FLAGS(a5),d7
                move.w  d7,d2
                andi.w  #$F800,d7
                andi.w  #$7FF,d2
                move.w  CRTL_XPOS(a5),d5
                move.w  CRTL_YPOS(a5),d6
                tst.b   CRTL_UNK3(a5)
                bmi.s   jump0
                sub.w   (SOME_Y_POS_OFFSET).w,d6
jump0:                                  ; CODE XREF: sub_2442+1A   j
                cmpi.w  #512,d6
                bcc.s   posbound_end2
                cmpi.w  #544,d5
                bcc.s   posbound_end2
                move.b  CRTL_UNK20(a5),d0
                andi.w  #%0000000011111100,d0
                movea.w d0,a1
                movea.w GFX_SPR_TABLE_TAIL-$1000000(a1),a0
                move.b  d4,-5(a0)
                btst    #$B,d7
                bne.s   jump1
                lea     lea_jump0(pc),a0
                bra.s   jump2
; ---------------------------------------------------------------------------
jump1:                                  ; CODE XREF: sub_2442+42   j
                lea     lea_jump1(pc),a0
                subi.w  #9,d5
jump2:                                  ; CODE XREF: sub_2442+48   j sub_2442+B6   j
                cmpi.b  #$50,d4 ; 'P'
                bge.s   end
                move.w  (a4)+,d3
                move.l  (a4)+,d0
                move.l  d0,(a2)+
                swap    d0
                move.b  d4,d0
                move.w  d0,d4
                move.b  (a4)+,d0
                ext.w   d0
                btst    #$C,d7
                beq.s   jump3
                neg.w   d0
                move.w  d4,d1
                lsr.w   #5,d1
                andi.w  #$18,d1
                addi.w  #9,d1
                sub.w   d1,d0
jump3:                                  ; CODE XREF: sub_2442+6C   j
                add.w   d6,d0
                move.w  d0,(a3)+
                addq.b  #1,d4
                move.w  d4,(a3)+
                move.w  d3,d0
                andi.w  #$7FFF,d0
                eor.w   d7,d0
                add.w   d2,d0
                move.w  d0,(a3)+
                move.b  (a4)+,d0
                ext.w   d0
                jmp     (a0)
; ---------------------------------------------------------------------------
lea_jump1:                              ; DATA XREF: sub_2442:jump1   o
                neg.w   d0
                move.b  -6(a4),d1
                add.w   d1,d1
                andi.w  #$18,d1
                sub.w   d1,d0
lea_jump0:                              ; DATA XREF: sub_2442+44   o
                add.w   d5,d0
                bmi.s   jump4
                andi.w  #$1FF,d0
                bne.s   jump5
jump4:                                  ; CODE XREF: sub_2442+A8   j
                moveq   #1,d0
jump5:                                  ; CODE XREF: sub_2442+AE   j
                move.w  d0,(a3)+
                add.w   d3,d3
                bcc.s   jump2
                move.w  a3,GFX_SPR_TABLE_TAIL-$1000000(a1)
end:                                    ; CODE XREF: sub_2442+56   j
                rts
; End of function sub_2442
_sub_2500:
                move.b  9(a5),d0
                beq.w   loc_2518
                addq.b  #1,d0
                beq.w   end
                subq.b  #1,9(a5)
                beq.w   loc_2526
end:                                    ; CODE XREF: _sub_2500+A   j
                rts
; ---------------------------------------------------------------------------
loc_2518:                               ; CODE XREF: _sub_2500+4   j
                move.w  CRTL_UNKC(a5),d0
                bra.w   loc_252C
; ---------------------------------------------------------------------------
loc_2520:                               ; CODE XREF: _sub_2500+30   j
                move.w  d1,d0
                bra.w   loc_252C
; ---------------------------------------------------------------------------
loc_2526:                               ; CODE XREF: _sub_2500+12   j
                move.w  CRTL_UNKC(a5),d0
                addq.w  #6,d0
loc_252C:                               ; CODE XREF: _sub_2500+1C   j _sub_2500+22   j
                move.l  (a0,d0.w),d1
                bmi.s   loc_2520
                move.l  d1,CRTL_SPRITE_PTR(a5)
                move.w  4(a0,d0.w),d1
                andi.w  #%1000000000000000,CRTL_SPRITE_FLAGS(a5)
                eor.w   d1,CRTL_SPRITE_FLAGS(a5)
                move.w  d0,CRTL_UNKC(a5)
                rts
; End of function _sub_2500
sub_254A:
                move.b  9(a5),d0
                beq.w   loc_2562
                addq.b  #1,d0
                beq.w   end
                subq.b  #1,9(a5)
                beq.w   loc_2570
end:                                    ; CODE XREF: sub_254A+A   j
                rts
; ---------------------------------------------------------------------------
loc_2562:                               ; CODE XREF: sub_254A+4   j
                move.w  CRTL_UNKC(a5),d0
                bra.w   update_end
; ---------------------------------------------------------------------------
loop:                                   ; CODE XREF: sub_254A+30   j
                move.w  d1,d0
                bra.w   update_end
; ---------------------------------------------------------------------------
loc_2570:                               ; CODE XREF: sub_254A+12   j
                move.w  CRTL_UNKC(a5),d0
                addq.w  #6,d0
update_end:                             ; CODE XREF: sub_254A+1C   j sub_254A+22   j
                move.l  (a0,d0.w),d1
                bmi.s   loop
                move.l  d1,CRTL_SPRITE_PTR(a5)
                move.w  4(a0,d0.w),CRTL_SPRITE_FLAGS(a5)
                move.w  d0,CRTL_UNKC(a5)
                rts
; End of function sub_254A
gfx_insert_sprite_258C:                 ; CODE XREF: sub_769A+6C   j sub_770C+7C   j ...
                movea.l a0,a4
                move.b  (GFX_SPR_SLOTS_USED).w,d4
                movea.w (GFX_SPR_TABLE).w,a3
                beq.w   end
loop:                                   ; CODE XREF: gfx_insert_sprite_258C+34   j
                cmpi.b  #$50,d4 ; 'P'
                bge.s   no_room         ; sprite table full
                move.l  (a0)+,(a3)+
                move.b  -(a3),d0
                andi.w  #%0000000011111100,d0
                movea.w d0,a1
                movea.w GFX_SPR_TABLE_TAIL-$1000000(a1),a2
                move.b  d4,-5(a2)
                addq.b  #1,d4
                move.b  d4,(a3)+
                move.l  (a0)+,(a3)+
                move.w  a3,GFX_SPR_TABLE_TAIL-$1000000(a1)
                cmpi.w  #$FFFF,(a0)
                bne.s   loop
no_room:                                ; CODE XREF: gfx_insert_sprite_258C+12   j
                move.w  a3,(GFX_SPR_TABLE).w
                move.b  d4,(GFX_SPR_SLOTS_USED).w
                movea.l a4,a0
end:                                    ; CODE XREF: gfx_insert_sprite_258C+A   j
                rts
; End of function gfx_insert_sprite_258C
_sub_25CE:
                movea.l a0,a4
                move.b  (GFX_SPR_SLOTS_USED).w,d4
                movea.w (GFX_SPR_TABLE).w,a3
loop:                                   ; CODE XREF: _sub_25CE+62   j
                cmpi.b  #$50,d4 ; 'P'
                bge.s   loc_2632
                move.b  3(a0),d0
                andi.w  #$FC,d0
                movea.w d0,a1
                movea.w GFX_SPR_TABLE_TAIL-$1000000(a1),a2
                move.b  d4,-5(a2)
                move.w  (a0),d6
                sub.w   (SOME_Y_POS_OFFSET).w,d6
                cmpi.w  #512,d6
                bcs.s   loc_25FE
                clr.w   d6
loc_25FE:                               ; CODE XREF: _sub_25CE+2C   j
                move.w  d6,(a3)+
                move.w  2(a0),d0
                addq.b  #1,d4
                move.b  d4,d0
                move.w  d0,(a3)+
                move.w  4(a0),(a3)+
                move.w  6(a0),d5
                cmpi.w  #544,d5
                bcs.s   loc_261C
                clr.w   -6(a3)
loc_261C:                               ; CODE XREF: _sub_25CE+48   j
                andi.w  #$1FF,d5
                bne.s   loc_2624
                addq.w  #1,d5
loc_2624:                               ; CODE XREF: _sub_25CE+52   j
                move.w  d5,(a3)+
                move.w  a3,GFX_SPR_TABLE_TAIL-$1000000(a1)
                addq.w  #8,a0
                cmpi.w  #$FFFF,(a0)
                bne.s   loop
loc_2632:                               ; CODE XREF: _sub_25CE+E   j
                move.w  a3,(GFX_SPR_TABLE).w
                move.b  d4,(GFX_SPR_SLOTS_USED).w
                movea.l a4,a0
                rts
; End of function _sub_25CE
gfx_read_data:                          ; CODE XREF: hblank_fx_0x3C+20   p hblank_fx_0x20+1E   p ...
                move.w  (a0)+,d0
                bmi.w   end             ; if word read is negative, stop reading
                lsl.w   #2,d0
                movea.l gfx_r_sub_tbl(pc,d0.w),a1
                jsr     (a1)
                bra.s   gfx_read_data
; ---------------------------------------------------------------------------
end:                                    ; CODE XREF: gfx_read_data+2   j
                rts
; End of function gfx_read_data
; ---------------------------------------------------------------------------
gfx_r_sub_tbl:  dc.l gfx_copy_ram       ; DATA XREF: gfx_read_data+8   o
                dc.l gfx_copy_vram
                dc.l gfx_decompress_ghd_ram
                dc.l gfx_decompress_ghd_vram
                dc.l gfx_copy_ram
                dc.l gfx_copy_vram
                dc.l gfx_decompress_rle_ram
                dc.l gfx_decompress_rle_vram
gfx_copy_ram:                           ; DATA XREF: ROM:gfx_r_sub_tbl   o ROM:00002660   o
                movea.l (a0)+,a1
                moveq   #$FFFFFFFF,d2
                move.w  (a0)+,d2
                movea.l d2,a2
                move.w  (a1)+,d1
                lsr.w   #2,d1
                subq.w  #1,d1
loop:                                   ; CODE XREF: gfx_copy_ram+10   j
                move.l  (a1)+,(a2)+
                dbf     d1,loop
                rts
; End of function gfx_copy_ram
gfx_copy_vram:                          ; DATA XREF: ROM:00002654   o ROM:00002664   o
                movea.l (a0)+,a1
                moveq   #0,d1
                move.w  (a0)+,d1
                movea.l d1,a3
                move.w  (a1)+,d0
loop:                                   ; CODE XREF: gfx_copy_vram+4A   j
                move.w  #$200,d1
                cmp.w   d1,d0
                bge.w   vdp_crtl_setup
                move.w  d0,d1
vdp_crtl_setup:                         ; CODE XREF: gfx_copy_vram+10   j
                sub.w   d1,d0
                lsr.w   #2,d1
                subq.w  #1,d1
                lea     (VDP_CTRL).l,a5
                move    sr,-(sp)
                move    #DISABLE_INTR,sr
                move.w  #AUTO_INC_2,(a5)
                move.l  a3,d7
                lsl.l   #2,d7
                lsr.w   #2,d7
                ori.w   #$4000,d7
                swap    d7
                move.l  d7,(a5)
vdp_data_copy:
                lea     (VDP_DATA).l,a5
copy_loop:                              ; CODE XREF: gfx_copy_vram+42   j
                move.l  (a1)+,(a5)
                dbf     d1,copy_loop
                move    (sp)+,sr
                tst.w   d0
                bne.s   loop
                rts
; End of function gfx_copy_vram
gfx_decompress_ghd_ram:                 ; DATA XREF: ROM:00002658   o
                movea.l (a0)+,a1
                moveq   #$FFFFFFFF,d1
                move.w  (a0)+,d1
                movea.l d1,a2
                moveq   #0,d1
                move.b  (a1),d1
                move.w  (a1)+,d3
                moveq   #8,d2
                ror.w   d2,d3
                move.w  d2,(tldcmp_bits_remaining).w
                move.w  d3,(tldcmp_saved_input_word).w
                bsr.w   clear_tldcmp_buf
loop:                                   ; CODE XREF: gfx_decompress_ghd_ram+26   j
                bsr.w   decompress_ghd_tiledata
                bsr.w   tldcmp_copy_ram
                dbf     d1,loop
                rts
; End of function gfx_decompress_ghd_ram
gfx_decompress_ghd_vram:                ; DATA XREF: ROM:0000265C   o
                movea.l (a0)+,a1
                moveq   #$FFFFFFFF,d1
                move.w  (a0)+,d1
                movea.l d1,a3
                moveq   #0,d1
                move.b  (a1),d1
                move.w  (a1)+,d3
                moveq   #8,d2
                ror.w   d2,d3
                move.w  d2,(tldcmp_bits_remaining).w
                move.w  d3,(tldcmp_saved_input_word).w
                bsr.w   clear_tldcmp_buf
loop:                                   ; CODE XREF: gfx_decompress_ghd_vram+26   j
                bsr.w   decompress_ghd_tiledata
                bsr.w   tldcmp_copy_vram
                dbf     d1,loop
                rts
; End of function gfx_decompress_ghd_vram
gfx_decompress_rle_ram:                 ; DATA XREF: ROM:00002668   o
                movea.l (a0)+,a1
                moveq   #0,d0
                move.w  (a1)+,d0
                movea.l a1,a4
                adda.l  d0,a4
                moveq   #$FFFFFFFF,d0
                move.w  (a0)+,d0
                movea.l d0,a2
loop:                                   ; CODE XREF: gfx_decompress_rle_ram+16   j
                bsr.w   decompress_rle_tiledata
                cmpa.l  a4,a1
                bcs.s   loop
                rts
; End of function gfx_decompress_rle_ram
gfx_decompress_rle_vram:                ; DATA XREF: ROM:0000266C   o
                movea.l (a0)+,a1        ; tiledata location
                moveq   #0,d0
                move.w  (a1)+,d0        ; len of tile data
                movea.l a1,a4
                adda.l  d0,a4
                moveq   #0,d0
                move.w  (a0)+,d0        ; dest offset
                movea.l d0,a3
decomp_loop:                            ; CODE XREF: gfx_decompress_rle_vram+56   j
                lea     (tldcmp_output_buffer_0).w,a2
                bsr.w   decompress_rle_tiledata ; if the buffer for the data has been filled, this sub will return. so check below is for that
                cmpa.l  a4,a1           ; if we've read all the src data, escape
                bcc.w   stop_decompress
                move.w  #$FF,d1
                lea     (tldcmp_output_buffer_0).w,a2
                lea     (VDP_CTRL).l,a5
                move    sr,-(sp)
                move    #DISABLE_INTR,sr
                move.w  #AUTO_INC_2,(a5)
                move.l  a3,d2
                lsl.l   #2,d2
                lsr.w   #2,d2
                ori.w   #%0100000000000000,d2
                swap    d2
                move.l  d2,(a5)
                lea     (VDP_DATA).l,a5
cpy_loop:                               ; CODE XREF: gfx_decompress_rle_vram+4C   j
                move.l  (a2)+,(a5)      ; copies from decompression buffer, into vram even if unfinished
                dbf     d1,cpy_loop
                move    (sp)+,sr
                lea     $400(a3),a3     ; goto next output buffer
                bra.s   decomp_loop
; ---------------------------------------------------------------------------
stop_decompress:                        ; CODE XREF: gfx_decompress_rle_vram+1A   j
                move.w  a2,d1
                subi.w  #$B400,d1
                lsr.w   #1,d1
                lea     (tldcmp_output_buffer_0).w,a2
                lea     (VDP_CTRL).l,a5
                move    sr,-(sp)
                move    #DISABLE_INTR,sr
                move.w  #AUTO_INC_2,(a5)
                move.l  a3,d2
                lsl.l   #2,d2
                lsr.w   #2,d2
                ori.w   #%0100000000000000,d2
                swap    d2
                move.l  d2,(a5)
                lea     (VDP_DATA).l,a5
cpy_loop1:                              ; CODE XREF: gfx_decompress_rle_vram+8A   j
                move.w  (a2)+,(a5)      ; then copies complete decompression buffer into vram
                dbf     d1,cpy_loop1
                move    (sp)+,sr
                rts
; End of function gfx_decompress_rle_vram
gfx_read_data_smth:                     ; CODE XREF: gfx_read_data_reset+16   p sub_49CE+3C   p ...
                move.w  (a0)+,d0
                bmi.w   end
                bset    #$F,d0
                move.w  d0,(tldcmp_cmp_type).w
                movea.l (a0)+,a1
                btst    #0,d0
                bne.w   bit_0
                moveq   #$FFFFFFFF,d1
                move.w  (a0)+,d1
                move.l  d1,(tldcmp_dest).w
                move.l  a0,(tldcmp_next).w
                btst    #1,d0
                beq.w   bit_1
                btst    #2,d0
                bne.w   bit_2
loop:                                   ; CODE XREF: gfx_read_data_smth+6E   j
                moveq   #0,d1
                move.b  (a1),d1
                addq.w  #1,d1
                move.w  d1,(tldcmp_data_len).w
                move.w  #8,d2
                move.w  d2,(tldcmp_bits_remaining).w
                move.w  (a1)+,d3
                ror.w   d2,d3
                move.w  d3,(tldcmp_saved_input_word).w
                move.l  a1,(tldcmp_src).w
                bra.w   clear_tldcmp_buf
; ---------------------------------------------------------------------------
bit_0:                                  ; CODE XREF: gfx_read_data_smth+14   j
                moveq   #0,d1
                move.w  (a0)+,d1
                move.l  d1,(tldcmp_dest).w
                move.l  a0,(tldcmp_next).w
                btst    #1,d0
                beq.w   bit_1
                btst    #2,d0
                beq.s   loop
                bra.w   bit_2
; ---------------------------------------------------------------------------
bit_1:                                  ; CODE XREF: gfx_read_data_smth+28   j gfx_read_data_smth+66   j
                move.w  (a1)+,(tldcmp_data_len).w
                move.l  a1,(tldcmp_src).w
                rts
; ---------------------------------------------------------------------------
bit_2:                                  ; CODE XREF: gfx_read_data_smth+30   j gfx_read_data_smth+70   j
                moveq   #0,d1
                move.w  (a1)+,d1
                move.l  a1,(tldcmp_src).w
                adda.l  d1,a1
                move.l  a1,(tldcmp_bits_remaining).w
end:                                    ; CODE XREF: gfx_read_data_smth+2   j
                rts
; End of function gfx_read_data_smth
gfx_read_data_reset:                    ; CODE XREF: Reset+266   p
                move.w  (tldcmp_cmp_type).w,d0
                beq.w   end
                movea.l (tldcmp_next).w,a0
main_loop:                              ; CODE XREF: gfx_read_data_reset+1E   j
                add.w   d0,d0
                add.w   d0,d0           ; quadruple value in d0
                movea.l jsr_tbl_288C(pc,d0.w),a3
                jsr     (a3)            ; switch 8 cases
                bsr.w   gfx_read_data_smth
                cmpi.w  #$FFFF,d0       ; end of stream = 0xFFFF
                bne.s   main_loop
                clr.w   (tldcmp_cmp_type).w
end:                                    ; CODE XREF: gfx_read_data_reset+4   j
                rts
; End of function gfx_read_data_reset
; ---------------------------------------------------------------------------
jsr_tbl_288C:   dc.l tldcomp_cpy_ram    ; DATA XREF: gfx_read_data_reset+10   o
                dc.l tldcomp_cpy_ram_dma ; jump table for switch statement
                dc.l tldcomp_ghd_cpy_ram
                dc.l tldcomp_ghd_cpy_ram_dma
                dc.l tldcomp_cpy_ram
                dc.l tldcomp_cpy_ram_dma
                dc.l tldcomp_rle_cpy_ram
                dc.l tldcomp_rle_cpy_ram_dma
; jumptable 0000287A cases 0,4
tldcomp_cpy_ram:                        ; CODE XREF: gfx_read_data_reset+14   j
                                        ; DATA XREF: ROM:jsr_tbl_288C   o
                movea.l (tldcmp_src).w,a1
                movea.l (tldcmp_dest).w,a2
                move.w  (tldcmp_data_len).w,d1
loop:                                   ; CODE XREF: tldcomp_cpy_ram+12   j
                move.l  (a1)+,(a2)+
                move.l  (a1)+,(a2)+
                subq.w  #8,d1
                bhi.s   loop
                rts
; End of function tldcomp_cpy_ram
; jumptable 0000287A cases 1,5
tldcomp_cpy_ram_dma:                    ; CODE XREF: gfx_read_data_reset+14   j
                                        ; DATA XREF: ROM:jsr_tbl_288C   o
                movea.l (tldcmp_src).w,a2
                movea.w (tldcmp_dest).w,a3
                move.w  (tldcmp_data_len).w,d0
loop:                                   ; CODE XREF: tldcomp_cpy_ram_dma+24   j
                move.w  #$200,d1
                cmp.w   d1,d0
                bge.w   prepend
                move.w  d0,d1
prepend:                                ; CODE XREF: tldcomp_cpy_ram_dma+12   j
                bsr.w   dma_queue_prepend_2C62
dma_wait_loop:                          ; CODE XREF: tldcomp_cpy_ram_dma+20   j
                tst.b   (DMA_QUEUE_STATUS).w
                bne.s   dma_wait_loop
                sub.w   d1,d0
                bne.s   loop
                rts
; End of function tldcomp_cpy_ram_dma
; jumptable 0000287A case 2
tldcomp_ghd_cpy_ram:                    ; CODE XREF: gfx_read_data_reset+14   j
                                        ; DATA XREF: ROM:jsr_tbl_288C   o
                movea.l (tldcmp_src).w,a1
                movea.l (tldcmp_dest).w,a2
                move.w  (tldcmp_data_len).w,d0
                subq.w  #1,d0
loop:                                   ; CODE XREF: tldcomp_ghd_cpy_ram+16   j
                bsr.w   decompress_ghd_tiledata
                bsr.w   tldcmp_copy_ram
                dbf     d0,loop
                rts
; End of function tldcomp_ghd_cpy_ram
; jumptable 0000287A case 3
tldcomp_ghd_cpy_ram_dma:                ; CODE XREF: gfx_read_data_reset+14   j
                                        ; DATA XREF: ROM:jsr_tbl_288C   o
                movea.l (tldcmp_src).w,a1
                movea.l (tldcmp_dest).w,a3
                move.w  (tldcmp_data_len).w,d0
loop:                                   ; CODE XREF: tldcomp_ghd_cpy_ram_dma+44   j
                lea     (tldcmp_output_buffer_1).w,a2
                move.w  #$10,d2
                cmp.w   d2,d0
                bge.w   jump0
                move.w  d0,d2
jump0:                                  ; CODE XREF: tldcomp_ghd_cpy_ram_dma+16   j
                move.w  d2,d1
                asl.w   #5,d1
                sub.w   d2,d0
                subq.w  #1,d2
dcmp_loop:                              ; CODE XREF: tldcomp_ghd_cpy_ram_dma+2C   j
                bsr.w   decompress_ghd_tiledata
                bsr.w   tldcmp_copy_ram
                dbf     d2,dcmp_loop
                tst.w   d0
                beq.w   jump1
                lea     (tldcmp_output_buffer_1).w,a2
                bsr.w   dma_queue_prepend_2C62
clear_loop:                             ; CODE XREF: tldcomp_ghd_cpy_ram_dma+42   j
                tst.b   (DMA_QUEUE_STATUS).w
                bne.s   clear_loop
                bra.s   loop
; ---------------------------------------------------------------------------
jump1:                                  ; CODE XREF: tldcomp_ghd_cpy_ram_dma+32   j
                lea     (tldcmp_output_buffer_1).w,a2
                bsr.w   dma_queue_prepend_2C62
clear_loop1:                            ; CODE XREF: tldcomp_ghd_cpy_ram_dma+52   j
                tst.b   (DMA_QUEUE_STATUS).w
                bne.s   clear_loop1
                rts
; End of function tldcomp_ghd_cpy_ram_dma
; jumptable 0000287A case 6
tldcomp_rle_cpy_ram:                    ; CODE XREF: gfx_read_data_reset+14   j
                                        ; DATA XREF: ROM:jsr_tbl_288C   o
                movea.l (tldcmp_src).w,a1
                movea.l (tldcmp_dest).w,a2
                movea.l (tldcmp_bits_remaining).w,a4
write_loop:                             ; CODE XREF: tldcomp_rle_cpy_ram+12   j
                bsr.w   decompress_rle_tiledata
                cmpa.l  a4,a1
                bcs.s   write_loop
                rts
; End of function tldcomp_rle_cpy_ram
; jumptable 0000287A case 7
tldcomp_rle_cpy_ram_dma:                ; CODE XREF: gfx_read_data_reset+14   j
                                        ; DATA XREF: ROM:jsr_tbl_288C   o
                movea.l (tldcmp_src).w,a1
                movea.l (tldcmp_dest).w,a3
                movea.l (tldcmp_bits_remaining).w,a4
loop:                                   ; CODE XREF: tldcomp_rle_cpy_ram_dma+2C   j
                lea     (tldcmp_output_buffer_0).w,a2
                bsr.w   decompress_rle_tiledata
                cmpa.l  a4,a1
                bcc.w   jump
                move.w  #$400,d1
                lea     (tldcmp_output_buffer_0).w,a2
                bsr.w   dma_queue_prepend_2C62
clear_loop:                             ; CODE XREF: tldcomp_rle_cpy_ram_dma+2A   j
                tst.b   (DMA_QUEUE_STATUS).w
                bne.s   clear_loop
                bra.s   loop
; ---------------------------------------------------------------------------
jump:                                   ; CODE XREF: tldcomp_rle_cpy_ram_dma+16   j
                move.w  a2,d1
                subi.w  #$B400,d1
                lea     (tldcmp_output_buffer_0).w,a2
                bsr.w   dma_queue_prepend_2C62
clear_loop1:                            ; CODE XREF: tldcomp_rle_cpy_ram_dma+40   j
                tst.b   (DMA_QUEUE_STATUS).w
                bne.s   clear_loop1
                rts
; End of function tldcomp_rle_cpy_ram_dma
decompress_rle_tiledata:                ; CODE XREF: gfx_decompress_rle_ram:loop   p
                                        ; gfx_decompress_rle_vram+14   p ...
                movem.l d4-d7/a5,-(sp)  ; save register state
                move.w  a2,d4           ; d4 = current destination offset (lower word)
                addi.w  #$400,d4        ; upper limit for write = a2 + 0x400(1024) bytes
main_loop:                              ; CODE XREF: decompress_rle_tiledata+16   j
                bsr.w   rle_read_control_unit
                cmpa.l  a4,a1           ; if we've read all the source data, quit
                bcc.w   end
                cmp.w   a2,d4           ; if we've written enough data, quit
                bhi.s   main_loop       ; otherwise, keep looping
end:                                    ; CODE XREF: decompress_rle_tiledata+10   j
                movem.l (sp)+,d4-d7/a5  ; restore register state
                rts
; End of function decompress_rle_tiledata
rle_read_control_unit:                  ; CODE XREF: decompress_rle_tiledata:main_loop   p
                move.b  (a1)+,d5        ; d5 bottom five bits nearly always have length
                bmi.w   lz_compression  ; if bit 7 is set, back-reference copy
                btst    #5,d5
                bne.w   rle_one_byte
                btst    #6,d5
                beq.w   no_rle
                bra.w   rle_two_byte
; ---------------------------------------------------------------------------
rle_one_byte:                           ; CODE XREF: rle_read_control_unit+A   j
                btst    #6,d5
                bne.w   constant_stream_pair
                andi.w  #$1F,d5         ; mask off bottom 5 bits
                addq.w  #1,d5
                move.b  (a1)+,d6
loop_rle_1:                             ; CODE XREF: rle_read_control_unit+2C   j
                move.b  d6,(a2)+
                dbf     d5,loop_rle_1
                rts
; ---------------------------------------------------------------------------
rle_two_byte:                           ; CODE XREF: rle_read_control_unit+16   j
                andi.w  #$1F,d5         ; mask off bottom 5 bits
                addq.w  #1,d5
                move.b  (a1)+,d6
                move.b  (a1)+,d7
loop_rle_2:                             ; CODE XREF: rle_read_control_unit+40   j
                move.b  d6,(a2)+
                move.b  d7,(a2)+
                dbf     d5,loop_rle_2
                rts
; ---------------------------------------------------------------------------
constant_stream_pair:                   ; CODE XREF: rle_read_control_unit+1E   j
                andi.w  #$1F,d5         ; mask off bottom 5 bits
                addq.w  #1,d5
                move.b  (a1)+,d6
constant_stream_pair_loop:              ; CODE XREF: rle_read_control_unit+52   j
                move.b  d6,(a2)+
                move.b  (a1)+,(a2)+
                dbf     d5,constant_stream_pair_loop
                rts
; ---------------------------------------------------------------------------
lz_compression:                         ; CODE XREF: rle_read_control_unit+2   j
                move.b  d5,d6
                lsr.b   #2,d5
                andi.w  #$1F,d5         ; mask off bottom 5 bits
                addq.w  #1,d5           ; count = (bottom 5 bits) + 1
                lsl.w   #8,d6
                move.b  (a1)+,d6        ; read second byte to complete offset
                andi.w  #$3FF,d6        ; 10-bit offset
                addq.w  #1,d6           ; length = offset + 1
                movea.l a2,a5
                suba.w  d6,a5           ; a5 = source = a2 - (offset + 1)
lz_loop:                                ; CODE XREF: rle_read_control_unit+72   j
                move.b  (a5)+,(a2)+
                dbf     d5,lz_loop
                rts
; ---------------------------------------------------------------------------
no_rle:                                 ; CODE XREF: rle_read_control_unit+12   j
                andi.w  #$1F,d5         ; mask off bottom 5 bits
no_rle_loop:                            ; CODE XREF: rle_read_control_unit+7E   j
                move.b  (a1)+,(a2)+
                dbf     d5,no_rle_loop
                rts
; End of function rle_read_control_unit
clear_tldcmp_buf:                       ; CODE XREF: gfx_decompress_ghd_ram+1A   p
                                        ; gfx_decompress_ghd_vram+1A   p ...
                lea     (tldcmp_output_buffer_0).w,a5
                moveq   #0,d6
                moveq   #$1F,d7
loop:                                   ; CODE XREF: clear_tldcmp_buf+A   j
                move.l  d6,(a5)+
                dbf     d7,loop
                rts
; End of function clear_tldcmp_buf
decompress_ghd_tiledata:                ; CODE XREF: gfx_decompress_ghd_ram:loop   p
                                        ; gfx_decompress_ghd_vram:loop   p ...
                movem.l d2-d7/a4-a5,-(sp) ; save register state
                move.w  (tldcmp_bits_remaining).w,d2 ; restore any saved decompression state
                move.w  (tldcmp_saved_input_word).w,d3 ; ditto
                lea     (tldcmp_output_buffer_0).w,a5
                lea     tldcmp_output_buffer_end-tldcmp_output_buffer_0(a5),a4
repeat_all:                             ; CODE XREF: decompress_ghd_tiledata+162   j
                subq.w  #5,d2
                bgt.w   more_than_5_bits_remaining_tprep
                beq.w   no_bits_remaining_tprep
                move.w  d2,d7
                addq.w  #5,d2
                lsl.l   d2,d3
                move.w  (a1)+,d3        ; read data stream
                neg.w   d7
                lsl.l   d7,d3
                addi.w  #$B,d2
                move.l  d3,d7
                swap    d7
                bra.w   common_top_prep
; ---------------------------------------------------------------------------
no_bits_remaining_tprep:                ; CODE XREF: decompress_ghd_tiledata+1A   j
                moveq   #$10,d2
                rol.w   #5,d3
                move.w  d3,d7
                move.w  (a1)+,d3        ; read data stream
                bra.w   common_top_prep
; ---------------------------------------------------------------------------
more_than_5_bits_remaining_tprep:       ; CODE XREF: decompress_ghd_tiledata+16   j
                rol.w   #5,d3
                move.w  d3,d7
common_top_prep:                        ; CODE XREF: decompress_ghd_tiledata+32   j
                                        ; decompress_ghd_tiledata+3E   j
                andi.w  #%0000000000011111,d7 ; mask off bottom 5 bits
                lsr.w   #1,d7           ; shift right 1
                bcs.w   pre_inner_loop  ; if bit shunt out is 1, branch
                move.w  d7,d4
                move.w  d4,(a5)+        ; write output word and advance
                move.w  d4,d5
                ori.w   #%1000000000000000,d5 ; set 15th bit
                bra.w   prep_for_shunt_loop ; skip inner loop and go straight to shunting
; ---------------------------------------------------------------------------
pre_inner_loop:                         ; CODE XREF: decompress_ghd_tiledata+4C   j
                move.w  d7,d4
                move.w  d4,(a5)+        ; write output and advance
                move.w  d4,d5
                bset    #$F,d5
                moveq   #0,d6
inner_loop:                             ; CODE XREF: decompress_ghd_tiledata+A6   j
                                        ; decompress_ghd_tiledata+D8   j ...
                subq.w  #2,d2
                bgt.w   inner_branch_A
                beq.w   inner_branch_B
                moveq   #$F,d2          ; valid bits become 16
                add.w   d3,d3
                move.w  (a1)+,d3        ; read data stream
                addx.w  d3,d3           ; shift top bit off of end of word
                move.w  d3,d7
                addx.w  d7,d7
                bra.w   after_inner_branch
; ---------------------------------------------------------------------------
inner_branch_B:                         ; CODE XREF: decompress_ghd_tiledata+70   j
                moveq   #$10,d2
                rol.w   #2,d3
                move.w  d3,d7
                move.w  (a1)+,d3
                bra.w   after_inner_branch
; ---------------------------------------------------------------------------
inner_branch_A:                         ; CODE XREF: decompress_ghd_tiledata+6C   j
                rol.w   #2,d3
                move.w  d3,d7
after_inner_branch:                     ; CODE XREF: decompress_ghd_tiledata+80   j
                                        ; decompress_ghd_tiledata+8C   j
                andi.w  #3,d7
                beq.w   inner_continues
                addq.w  #6,d7
                add.w   d7,d7
                add.w   d7,d6           ; add to write offset
                move.w  d5,-2(a5,d6.w)  ; write d5 to write head with offset
                bra.s   inner_loop
; ---------------------------------------------------------------------------
inner_continues:                        ; CODE XREF: decompress_ghd_tiledata+98   j
                subq.w  #1,d2           ; jmp here if d7 is 0
                bne.w   inner_skip
                moveq   #$10,d2
                add.w   d3,d3
                move.w  (a1)+,d3        ; read data stream
                roxr.w  #1,d3
inner_skip:                             ; CODE XREF: decompress_ghd_tiledata+AA   j
                addx.w  d3,d3
                bcc.w   prep_for_shunt_loop ; exit inner loop
                subq.w  #1,d2
                bne.w   inner_unknown_skip
                moveq   #$10,d2
                add.w   d3,d3
                move.w  (a1)+,d3        ; read data stream
                roxr.w  #1,d3           ; now shunt Xtend flag back in
inner_unknown_skip:                     ; CODE XREF: decompress_ghd_tiledata+BE   j
                addx.w  d3,d3
                bcs.w   write_ahead_3
write_ahead_2:
                addi.w  #$C,d6
                move.w  d5,-2(a5,d6.w)  ; write d5 to write head with offset
                bra.s   inner_loop
; ---------------------------------------------------------------------------
write_ahead_3:                          ; CODE XREF: decompress_ghd_tiledata+CC   j
                addi.w  #$14,d6
                move.w  d5,-2(a5,d6.w)  ; write d5 to write head with offset
                bra.s   inner_loop
; ---------------------------------------------------------------------------
prep_for_shunt_loop:                    ; CODE XREF: decompress_ghd_tiledata+5A   j
                                        ; decompress_ghd_tiledata+B8   j
                moveq   #0,d7
                moveq   #1,d6
shunt_loop:                             ; CODE XREF: decompress_ghd_tiledata+FC   j
                                        ; decompress_ghd_tiledata+106   j
                addq.w  #1,d7           ; looks for runs of bits set ie 111100, loops 4 times, and outputs d7+4, d6=1,2,4,8,16,32,64,etc.
                add.w   d6,d6
                subq.w  #1,d2
                bne.w   has_more_bits   ; is counter > 0 ? ie if still bits left
                moveq   #$10,d2
                add.w   d3,d3
                bcc.w   read_input_then_exit ; branch if we have shunted 0
                move.w  (a1)+,d3        ; read data stream
                bra.s   shunt_loop
; ---------------------------------------------------------------------------
read_input_then_exit:                   ; CODE XREF: decompress_ghd_tiledata+F6   j
                move.w  (a1)+,d3        ; read data stream
                bra.w   after_shunt_loop ; exit shunt loop
; ---------------------------------------------------------------------------
has_more_bits:                          ; CODE XREF: decompress_ghd_tiledata+EE   j
                add.w   d3,d3           ; shunt d3
                bcs.s   shunt_loop      ; did we shunt out a 1?
after_shunt_loop:                       ; CODE XREF: decompress_ghd_tiledata+100   j
                sub.w   d7,d2
                bgt.w   write_prep_A
                beq.w   write_prep_B
                swap    d3              ; fallthrough write prep C
                clr.w   d3
                swap    d3
                add.w   d7,d2
                lsl.l   d2,d3
                move.w  (a1)+,d3        ; read data stream
                sub.w   d2,d7
                lsl.l   d7,d3
                moveq   #$10,d2
                sub.w   d7,d2
                move.l  d3,d7
                swap    d7
                bra.w   write_prep
; ---------------------------------------------------------------------------
write_prep_B:                           ; CODE XREF: decompress_ghd_tiledata+10E   j
                moveq   #$10,d2
                swap    d3
                clr.w   d3
                rol.l   d7,d3
                move.w  d3,d7
                move.w  (a1)+,d3        ; read data stream
                bra.w   write_prep
; ---------------------------------------------------------------------------
write_prep_A:                           ; CODE XREF: decompress_ghd_tiledata+10A   j
                swap    d3
                clr.w   d3
                rol.l   d7,d3
                move.w  d3,d7
                swap    d3
write_prep:                             ; CODE XREF: decompress_ghd_tiledata+12A   j
                                        ; decompress_ghd_tiledata+13A   j
                add.w   d7,d6
                subq.w  #3,d6
                bcs.w   check_if_buf_full ; following section: write loop takes last-written word of output buffer and repeats that d6 times. if bit 15 is set, then start writing that instead and clr bit 15
write_loop:                             ; CODE XREF: decompress_ghd_tiledata+15C   j
                move.w  (a5),d7         ; peek head of output buffer
                bpl.w   write_loop_unknown_skip ; if bit 15 is set, then skip ahead
                move.w  d7,d5
                move.b  d5,d4           ; write lower byte of output to d4 before full d4.w is output
write_loop_unknown_skip:                ; CODE XREF: decompress_ghd_tiledata+152   j
                move.w  d4,(a5)+        ; write d4 to output buffer
                dbf     d6,write_loop   ; and repeat write loop until done
check_if_buf_full:                      ; CODE XREF: decompress_ghd_tiledata+14C   j
                cmpa.l  a4,a5           ; check current write ptr with address of end of buf
                bcs.w   repeat_all      ; if not filled buf, repeat. for first pattern, buffer is full first time around
                move.w  d2,(tldcmp_bits_remaining).w
                move.w  d3,(tldcmp_saved_input_word).w
                movem.l (sp)+,d2-d7/a4-a5
                rts
; End of function decompress_ghd_tiledata
tldcmp_copy_ram:                        ; CODE XREF: gfx_decompress_ghd_ram+22   p tldcomp_ghd_cpy_ram+12   p ...
                lea     (tldcmp_output_buffer_0).w,a5
                moveq   #7,d6
loop:                                   ; CODE XREF: tldcmp_copy_ram+26   j
                move.w  (a5)+,d7        ; copy word from tiledata into d7
                lsl.w   #4,d7           ; shift left by 4 bits
                add.w   (a5)+,d7        ; add the next word in tiledata to that
                lsl.w   #4,d7           ; repeat 2 more times
                add.w   (a5)+,d7
                lsl.w   #4,d7
                add.w   (a5)+,d7
                swap    d7              ; swap upper and lower word of d7
                move.w  (a5)+,d7        ; do the same here
                lsl.w   #4,d7
                add.w   (a5)+,d7
                lsl.w   #4,d7
                add.w   (a5)+,d7
                lsl.w   #4,d7
                add.w   (a5)+,d7
                move.l  d7,(a2)+        ; move the long into the addr at a2, increment a2
                dbf     d6,loop         ; repeat 7 more times
                rts
; End of function tldcmp_copy_ram
tldcmp_copy_vram:                       ; CODE XREF: gfx_decompress_ghd_vram+22   p
                lea     (VDP_CTRL).l,a4
                move    sr,-(sp)
                move    #DISABLE_INTR,sr
                move.w  #AUTO_INC_2,(a4) ; set auto-increment to 2
                moveq   #0,d7
                move.l  a3,d6
                move.w  d6,d7
                lsl.l   #2,d7
                lsr.w   #2,d7
                ori.w   #%0100000000000000,d7
                swap    d7
                move.l  d7,(a4)
                lea     $20(a3),a3
                lea     (VDP_DATA).l,a4
                lea     (tldcmp_output_buffer_0).w,a5
                moveq   #7,d6
cpy_loop:                               ; CODE XREF: tldcmp_copy_vram+52   j
                move.w  (a5)+,d7
                lsl.w   #4,d7
                add.w   (a5)+,d7
                lsl.w   #4,d7
                add.w   (a5)+,d7
                lsl.w   #4,d7
                add.w   (a5)+,d7
                swap    d7
                move.w  (a5)+,d7
                lsl.w   #4,d7
                add.w   (a5)+,d7
                lsl.w   #4,d7
                add.w   (a5)+,d7
                lsl.w   #4,d7
                add.w   (a5)+,d7
                move.l  d7,(a4)
                dbf     d6,cpy_loop
                move    (sp)+,sr
                rts
; End of function tldcmp_copy_vram
dma_queue_prepend_2C62:                 ; CODE XREF: tldcomp_cpy_ram_dma:prepend   p
                                        ; tldcomp_ghd_cpy_ram_dma+3A   p ...
                move    sr,-(sp)
                move    #DISABLE_INTR,sr
                movea.w (DMA_QUEUE_PTR0).w,a5
                move.w  a3,d7
                rol.w   #2,d7
                andi.w  #%0000000000000011,d7
                ori.w   #%0000000010000000,d7
                move.w  d7,-(a5)
                move.w  a3,d7
                andi.w  #%0011111111111111,d7
                ori.w   #%0100000000000000,d7
                move.w  d7,-(a5)
                move.l  a2,d7
                andi.l  #$00FFFFFF,d7
                lsr.l   #1,d7
                move.w  #$9500,d6
                move.b  d7,d6
                move.w  d6,-(a5)
                lsr.l   #8,d7
                move.w  #$9600,d6
                move.b  d7,d6
                move.w  d6,-(a5)
                lsr.l   #8,d7
                move.w  #$9700,d6
                move.b  d7,d6
                move.w  d6,-(a5)
                move.w  #AUTO_INC_2,-(a5)
                move.w  d1,d7
                lsr.w   #1,d7
                move.w  #$9300,d6
                move.b  d7,d6
                move.w  d6,-(a5)
                lsr.w   #8,d7
                move.w  #$9400,d6
                move.b  d7,d6
                move.w  d6,-(a5)
                adda.w  d1,a2
                adda.w  d1,a3
                move.b  #1,(DMA_QUEUE_STATUS).w
                move.w  a5,(DMA_QUEUE_PTR0).w
                move    (sp)+,sr
                rts
; End of function dma_queue_prepend_2C62
_dma_queue_prepend_2CD8:
                movea.w (DMA_QUEUE_PTR0).w,a1
                move.w  d0,-(sp)
                move.w  d0,d2
                rol.w   #2,d2
                andi.w  #3,d2
                ori.w   #$80,d2
                move.w  d2,-(a1)
                andi.w  #$3FFF,d0
                ori.w   #$4000,d0
                move.w  d0,-(a1)
                move.w  (a0)+,d1
                add.w   d1,(sp)
                move.l  a0,d0
                andi.l  #$FFFFFF,d0
                lsr.l   #1,d0
                move.w  #$9500,d2
                move.b  d0,d2
                move.w  d2,-(a1)
                lsr.l   #8,d0
                move.w  #$9600,d2
                move.b  d0,d2
                move.w  d2,-(a1)
                lsr.l   #8,d0
                move.w  #$9700,d2
                move.b  d0,d2
                move.w  d2,-(a1)
                move.w  #AUTO_INC_2,-(a1)
                lsr.w   #1,d1
                move.w  #$9300,d2
                move.b  d1,d2
                move.w  d2,-(a1)
                lsr.w   #8,d1
                move.w  #$9400,d2
                move.b  d1,d2
                move.w  d2,-(a1)
                move.w  (sp)+,d0
                move.w  a1,(DMA_QUEUE_PTR0).w
                rts
; End of function _dma_queue_prepend_2CD8
