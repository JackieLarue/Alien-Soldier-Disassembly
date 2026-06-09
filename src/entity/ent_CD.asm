update_ent_CD:                          ; DATA XREF: ROM:ent_update_fns   o
                bclr    #7,$22(a5)
                bne.s   jump
                cmpi.w  #$80,$C(a5)
                bmi.s   end
jump:                                   ; CODE XREF: update_ent_CD+6   j
                bset    #4,2(a5)
end:                                    ; CODE XREF: update_ent_CD+E   j
                rts
; End of function update_ent_CD
