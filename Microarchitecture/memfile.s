.equ PERIPHERAL_BASE_HI, 0x3F000000
.equ GPIO, 0x00200000
.equ GPFSEL_OFFSET, 0x00000000
.equ GPSET_OFFSET, 0x0000001C
.equ GPCLR_OFFSET, 0x00000028
.equ GPLEV_OFFSET, 0x00000034
.equ SYSTIMER, 0x00003000
.equ CS_OFFSET, 0x00000000
.equ CL0_OFFSET, 0x00000004
.equ C1_OFFSET, 0x00000010

.equ CN03_CMD_SET, 0x7F
.equ CN03_CMD_INCREMENT, 0x80

.equ SPI_PIN_CS,   8
.equ SPI_PIN_MISO, 9
.equ SPI_PIN_MOSI, 10
.equ SPI_PIN_CLK,  11

.equ INPUT,  0
.equ OUTPUT, 1

.equ FAKE_DISPLAY, 0xFF000000

@ int main();
_start:
    mov sp, #0xFC

    bl spi_init

    mov r0, #0
    and r0, r0, #CN03_CMD_SET
    bl cn03_communicate
    bl display_8bit_value

    @ sub sp, sp, #8
    @ str r4, [sp, #0]
    @ str ip, [sp, #4]

    mov r4, #0
for:
    mov r0, #CN03_CMD_INCREMENT
    bl cn03_communicate
    bl display_8bit_value
    add r4, r4, #1
    cmp r4, #100
    bne for

    mov r0, #127
    and r0, r0, #CN03_CMD_SET
    bl cn03_communicate
    bl display_8bit_value

    mov r0, #CN03_CMD_INCREMENT
    bl cn03_communicate
    bl display_8bit_value

    mov r0, #0 @ Reset to visualize last incremented value
    and r0, r0, #CN03_CMD_SET
    bl cn03_communicate
    bl display_8bit_value

end:  
    b end

    @ ldr r4, [sp, #0]
    @ ldr ip, [sp, #4]
    @ add sp, sp, #8

    @ mov pc, lr

@ uint8_t cn03_communicate(uint8_t command);
cn03_communicate:
    sub sp, sp, #8
    str r4, [sp, #0]
    str lr, [sp, #4]

    mov r4, r0
    command    .req r4

    mov r0, #SPI_PIN_CS
    mov r1, #0
    bl digitalWrite

    mov r0, command
    bl spi_transfer
    .unreq    command
    received_value    .req r4
    mov received_value, r0

    mov r0, #SPI_PIN_CS
    mov r1, #1
    bl digitalWrite

    mov r0, #10
    bl delay_us

    mov r0, received_value
    .unreq    received_value

    ldr r4, [sp, #0]
    ldr lr, [sp, #4]
    add sp, sp, #8

    mov pc, lr

@ void display_8bit_value(uint8_t value);
display_8bit_value:
    mov r1, #FAKE_DISPLAY
    str r0, [r1]
    mov pc, lr

@ void pinMode(int pin, int function);
@ Funzione foglia.
@ Registri usati:
@ - r0, r1, r2, r3 (il chiamante deve salvarli).
@ - r4 (salvato sullo stack).
pinMode:
    sub sp, sp, #8
    str r4, [sp, #0]
    str ip, [sp, #4]

    pin         .req r0
    function    .req r1
    reg         .req r2
    mov reg, #0
    mov r3, #10
div10_loop:
    cmp pin, r3 
    blt div10_done
    sub pin, pin, r3 
    add reg, reg, #1
    b   div10_loop
div10_done: // pin = pin % 10, reg = pin / 10
    .unreq    pin
    add r0, r0, r0, lsl #1 // pin * 3
    offset    .req r0
    mov r3, #PERIPHERAL_BASE_HI
    orr r3, r3, #GPIO // r3 = GPIO 
    add r3, r3, reg, lsl #2 // r3 = GPIO + reg * 4
    .unreq    reg
    ldr r4, [r3] // r4 = value of GPFSELk for pin
    mov r2, #7 
    mov r2, r2, lsl offset // r2 = 7 << offset
    bic r4, r4, r2 // GPFSELk &= ~(7 << offset)
    and function, function, #7 
    mov function, function, lsl offset // (function & 7) << offset
    orr r4, r4, function // GPFSELk |= (function & 7) << offset
    str r4, [r3] // Write back to GPFSELk
    .unreq    offset
    .unreq    function

    ldr r4, [sp, #0]
    ldr ip, [sp, #4]
    add sp, sp, #8
    mov pc, lr

@ void digitalWrite(int pin, int val);
@ Funzione foglia.
@ Registri usati:
@ - r0, r1, r2, r3 (il chiamante deve salvarli).
digitalWrite:
    pin    .req r0
    val    .req r1
    reg    .req r2

    mov reg, pin, lsr #5
    and pin, pin, #31

    .unreq    pin
    offset    .req r0
    cmp val, #0
    .unreq    val
    mov r3, #PERIPHERAL_BASE_HI
    orr r3, r3, #GPIO
    beq write_clear
write_set:
    orr r3, r3, #GPSET_OFFSET
    b done
write_clear:
    orr r3, r3, #GPCLR_OFFSET
done:
    add r3, r3, reg, lsl #2
    .unreq    reg
    mov r2, #1
    mov r2, r2, lsl offset
    str r2, [r3]
    .unreq    offset
    mov pc, lr

@ int digitalRead(int pin);
@ Funzione foglia.
@ Registri usati:
@ - r0, r1, r2, r3 (il chiamante deve salvarli).
digitalRead:
    pin    .req r0
    reg    .req r1

    mov reg, pin, lsr #5
    and pin, pin, #31

    .unreq    pin
    offset    .req r0
    mov r3, #PERIPHERAL_BASE_HI
    orr r3, r3, #GPIO
    orr r3, r3, #GPLEV_OFFSET
    add r3, r3, reg, lsl #2
    .unreq    reg
    ldr r2, [r3]
    mov r2, r2, lsr offset
    .unreq    offset
    and r2, r2, #1
    mov r0, r2
    mov pc, lr

@ void spi_init();
spi_init:
    sub sp, sp, #8
    str ip, [sp, #0]
    str lr, [sp, #4]

    mov r0, #SPI_PIN_MOSI
    mov r1, #OUTPUT
    bl pinMode

    mov r0, #SPI_PIN_CLK
    mov r1, #OUTPUT
    bl pinMode

    mov r0, #SPI_PIN_CS
    mov r1, #OUTPUT
    bl pinMode

    mov r0, #SPI_PIN_MISO
    mov r1, #INPUT
    bl pinMode

    mov r0, #SPI_PIN_MOSI
    mov r1, #0
    bl digitalWrite

    mov r0, #SPI_PIN_CLK
    mov r1, #0
    bl digitalWrite

    mov r0, #SPI_PIN_CS
    mov r1, #1
    bl digitalWrite

    ldr ip, [sp, #0]
    ldr lr, [sp, #4]
    add sp, sp, #8
    mov pc, lr

@ uint8_t spi_transfer(uint8_t data_out);
spi_transfer:
    sub sp, sp, #24
    str r4, [sp, #0]
    str r5, [sp, #4]
    str r6, [sp, #8]
    str r7, [sp, #12]
    str ip, [sp, #16]
    str lr, [sp, #20]

    mov r4, r0
    data_out          .req r4
    data_in           .req r5
    mov data_in, #0
    half_period_us    .req r6
    mov half_period_us, #5
    mask              .req r7
    mov mask, #0x80
spi_loop:
    mov r0, #SPI_PIN_MOSI
    and r1, data_out, mask
    @ cmp r1, #0
    @ moveq r1, #0
    @ movne r1, #1
    bl digitalWrite

    mov r0, #SPI_PIN_MISO
    bl digitalRead
    cmp r0, #0
    orrne data_in, data_in, mask

    mov r0, #SPI_PIN_CLK
    mov r1, #1
    bl digitalWrite

    mov r0, half_period_us
    bl delay_us

    mov r0, #SPI_PIN_CLK
    mov r1, #0
    bl digitalWrite

    mov r0, half_period_us
    bl delay_us

    mov mask, mask, lsr #1
    cmp mask, #0
    bne spi_loop

    mov r0, data_in

    .unreq    half_period_us
    .unreq    mask
    .unreq    data_out
    .unreq    data_in
    ldr r4, [sp, #0]
    ldr r5, [sp, #4]
    ldr r6, [sp, #8]
    ldr r7, [sp, #12]
    ldr ip, [sp, #16]
    ldr lr, [sp, #20]
    add sp, sp, #24

    mov pc, lr

@ void delay_us(uint32_t delay);
@ Funzione foglia.
@ Registri usati:
@ - r0, r1, r2 (il chiamante deve salvarli).
delay_us:
    mov r1, #PERIPHERAL_BASE_HI
    orr r1, r1, #SYSTIMER // SYSTIMER = 0x3F003000 
    ldr r2, [r1, #CL0_OFFSET] // time = systimer_clo
    add r2, r2, r0 // time = systimer_clo + delay_us
    str r2, [r1, #C1_OFFSET] // systimer_c1 = time
    ldr r0, [r1, #CS_OFFSET] // r0 = systimer_cs
    orr r0, r0, #0x00000002 // Set the C1 bit in systimer_cs
    str r0, [r1] // systimer_cs = r0 (resettiamo il C1 bit)

delay_loop:
    ldr r0, [r1] // r0 = systimer_cs
    tst r0, #0x00000002 
    beq delay_loop
    mov pc, lr  
    
