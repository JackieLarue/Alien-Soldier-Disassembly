ModEnvPtrs:     dc.l ModEnv0,ModEnv1,ModEnv2,ModEnv3 ; DATA XREF: fm_control+1CE   o
                dc.l ModEnv4,ModEnv5,ModEnv6,ModEnv7
ModEnv0:        dc.b   0,  1,  2,  3,  4,  5,  6,  7,  8,  9, $A ; DATA XREF: ROM:ModEnvPtrs   o
                dc.b  $B, $C, $D, $E, $F,$10,$11,$12,$13,$14,$83
ModEnv1:        dc.b   0,  1,  2,  3,  4,  5,  6,  7,  8,  9, $A ; DATA XREF: ROM:ModEnvPtrs   o
                dc.b  $B, $C, $D, $E, $F,$10,$11,$12,$13,$14,$80
ModEnv2:        dc.b $D8,$E2,$EC,$F6,  0 ; DATA XREF: ROM:ModEnvPtrs   o
                dc.b  $A,$14,$1E,$28,$83
ModEnv3:        dc.b $D8,$E2,$EC,$F6,  0 ; DATA XREF: ROM:ModEnvPtrs   o
                dc.b  $A,$14,$1E,$28,$80
ModEnv5:        dc.b   4,  4,  4,  4,  3,  3,  3,  3 ; DATA XREF: ROM:ModEnvPtrs   o
                dc.b   2,  2,  2,  2,  1,  1,  1,  1
ModEnv4:        dc.b   0,  0,  0,  0,  0,  0 ; DATA XREF: ROM:ModEnvPtrs   o
                dc.b   0,  0,  0,  0,  1,  1
                dc.b   1,  1,  1,  1,  1,  1
                dc.b   1,  1,  1,  1,  1,  1
                dc.b   2,  2,  2,  2,  2,  2
                dc.b   2,  2,  3,  3,  3,  3
                dc.b   3,  3,  3,  3,  4,$83
ModEnv6:        dc.b   2,$83            ; DATA XREF: ROM:ModEnvPtrs   o
ModEnv7:        dc.b   0,  0,  0,  0,  0,  1,  1,  1 ; DATA XREF: ROM:ModEnvPtrs   o
                dc.b   1,  1,  2,  2,  2,  2,  2,  2
                dc.b   3,  3,  3,  3,  3,  4,  4,  4
                dc.b   4,  4,  5,  5,  5,  5,  5,  6
                dc.b   6,  6,  6,  6,  7,  7,  7,$83
PSGPtrList:     dc.l PSG0,PSG1,PSG2,PSG3,PSG4 ; DATA XREF: psg_control+EA   o
                dc.l PSG5,PSG6,PSG7,PSG8,PSG9
PSG0:           dc.b   0,  0,  0,  1,  1,  1,  2,  2 ; DATA XREF: ROM:PSGPtrList   o
                dc.b   2,  3,  3,  3,  4,  4,  4,  5
                dc.b   5,  5,  6,  6,  6,  7,$83
PSG1:           dc.b   0,  2,  4,  6,  8,$10,$83 ; DATA XREF: ROM:PSGPtrList   o
PSG2:           dc.b   0,  0,  1,  1,  3,  3,  4,  5,$83 ; DATA XREF: ROM:PSGPtrList   o
PSG3:           dc.b   0,  0,  2,  3,  4,  4,  5,  5,  5,  6,$83 ; DATA XREF: ROM:PSGPtrList   o
PSG5:           dc.b   4,  4,  4,  4,  3,  3,  3,  3 ; DATA XREF: ROM:PSGPtrList   o
                dc.b   2,  2,  2,  2,  1,  1,  1,  1
PSG4:           dc.b   0,  0,  0,  0,  0,  0 ; DATA XREF: ROM:PSGPtrList   o
                dc.b   0,  0,  0,  0,  1,  1
                dc.b   1,  1,  1,  1,  1,  1
                dc.b   1,  1,  1,  1,  1,  1
                dc.b   2,  2,  2,  2,  2,  2
                dc.b   2,  2,  3,  3,  3,  3
                dc.b   3,  3,  3,  3,  4,$83
PSG6:           dc.b   2,$83            ; DATA XREF: ROM:PSGPtrList   o
PSG7:           dc.b   0,  0,  0,  0,  0,  1,  1,  1 ; DATA XREF: ROM:PSGPtrList   o
                dc.b   1,  1,  2,  2,  2,  2,  2,  2
                dc.b   3,  3,  3,  3,  3,  4,  4,  4
                dc.b   4,  4,  5,  5,  5,  5,  5,  6
                dc.b   6,  6,  6,  6,  7,  7,  7,$83
PSG8:           dc.b   8,  8,  7,  7,  7,  7,  6,  6 ; DATA XREF: ROM:PSGPtrList   o
                dc.b   6,  6,  5,  5,  5,  5,  4,  4
                dc.b   4,  4,  3,  3,  3,  3,  2,  2
                dc.b   2,  2,  1,  1,  1,  1,  0,$81
PSG9:           dc.b   8,  7,  6,  5,  4,  3,  3 ; DATA XREF: ROM:PSGPtrList   o
                dc.b   2,  2,  1,  1,  0,$81,  0
