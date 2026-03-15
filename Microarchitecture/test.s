/* 
Test GPIO
mov r1, #0x3F000000
orr r1, r1, #0x00200000 // GPIO = 0x3F200000
mov r2, #0x1000 // r2 = 1 << 12 (pin 4 come output)
str r2, [r1] // scrivo in GPFSEL0 = 0x3F200000      
mov r2, #0x10 // r2 = 1 << 4
str r2, [r1, #0x1C] // scrivo in GPSET0 = 0x3F20001C
ldr r3, [r1, #0x34] // Leggo GPLEV0 = 0x3F200034 che dovrebbe contenere 0x10 (pin 4 alto)
str r2, [r1, #0x28] // GPCLR0 = 0x3F200028 (r2 contiene 0x10)
//    Ci aspettiamo che r3 ora contenga 0x0 (poiché il pin 4 è stato spento).
ldr r3, [r1, #0x34] // Leggo GPLEV0 = 0x3F200034 che dovrebbe contenere 0x0 (pin 4 basso)

end_loop:
    b end_loop
*/
/*
Test for systimer 
mov r0, #80
bl delay_us
b end
    
delay_us:
    mov r1, #0x3F000000 
    orr r1, r1, #0x00003000 // SYSTIMER = 0x3F003000 
    ldr r2, [r1, #0x4] // time = systimer_clo
    add r2, r2, r0 // time = systimer_clo + delay_us
    str r2, [r1, #0x10] // systimer_c1 = time
    ldr r0, [r1] // r0 = systimer_cs
    orr r0, r0, #0x00000002 // Set the C1 bit in systimer_cs
    str r0, [r1] // systimer_cs = r0 (resettiamo il C1 bit)

delay_loop:
    ldr r0, [r1] // r0 = systimer_cs
    tst r0, #0x00000002 
    beq delay_loop
    mov r15, r14  @ bx lr

end:
    mov r0, #42
*/
/*$monitor("PC:%h, C1: %h, C: %h, CS: %h", PC, dut.systimer.systimer_compare1, 
        dut.systimer.systimer_counter31_0, dut.systimer.systimer_cs);
      #100000;*/