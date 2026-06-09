sprite_ptr_to_a4(pstruct* a5) {
    a4 = a5.sprite_ptr;
}

load_sprite_helper_2384(pstruct* a5) {
    d7 = a5.dstate;
    d2 = d7;
    d7 &= 0b1111100000000000;
    d2 &= 0b0000011111111111;
    d5 = a5.xpos;
    d6 = a5.ypos;
    if (a5.unk3 != 0xFF) d6 -= SOME_Y_POS_VALUE;
    if (d6 >= 512) return;
    if (d5 >= 544) return;
    d0.b = a5.unk20;
    d0.w &= 0b0000000011111100;
    a1 = d0.w; //sign extended i think?
    a0 = a1 - 0x41FA;
    *(a0 - 5) = d4.b;
    if (d7 & (1 << 0xB)) {
        a0 = &lea_jump1;
        d5 -= 8;
    } else {
        a0 = &lea_jump0;
    } 
    
    
}

gfx_load_player(pstruct* a5) {
    if (a5.unk2 != 0xFF) {
        if (a5.unk2 == 0) return;
        a4 = a5.sprite_ptr;
        sprite_ptr_to_a4(a5);
        return;        
    }
    d0.l = a5.sprite_ptr;
    if (d0 == 0) return;
    a4 = d0;
    sprite_ptr_to_a4(a5);
    if (d7 & (1 << 5)) {
        load_sprite_helper_22C4();
        return;
    } 
    a2 = &a5.unkE0;
    if (a5.sprite_ptr_2 == a4) {
        load_sprite_helper_2384();
        return;
    }
    a5.sprite_ptr_2 = a4;
    load_sprite_helper_2384();
    a4 = &a5.unkE0;
    if (a4.w == a2.w) {
        return;
    }
    a0.w = dma_queue_ptr0;
    d0.w = a5.sprite_dest;
    do {
        a1 = a4++;
        dma_queue_prepend_1F6A(a0, a1, d0);
    } while (a2.w > a4.w);
    dma_queue_ptr0.w = a0.w;
}

dma_queue_prepend_1F6A(void* a0_queue_ptr, a1_header_ptr, d0_dma_dest) {
    
}
