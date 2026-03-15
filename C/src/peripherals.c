#include "peripherals.h"
#include "simulation.h"

void pinMode(int pin, int function) {
#ifndef SIMULAZIONE
    int reg = pin / 10, offset = (pin % 10) * 3;
    GPFSEL[reg] &= ~(0b111 << offset);
    GPFSEL[reg] |= ((0b111 & function) << offset);
#else
    gpio_mode[pin] = function;
    // printf("pinMode(pin=%d, mode=%sPUT)\n", pin, function ? "OUT" : "IN");
#endif  // SIMULAZIONE
}

void digitalWrite(int pin, int val) {
#ifndef SIMULAZIONE
    int reg = pin / 32, offset = pin % 32;
    val ? (GPSET[reg] = 1 << offset) : (GPCLR[reg] = 1 << offset);
#else
    if (pin < 0 || pin >= 40) return;
    gpio_level[pin] = val;
    // printf("digitalWrite(pin=%d, val=%d)\n", pin, val);
#endif  // SIMULAZIONE
}

int digitalRead(int pin) {
#ifndef SIMULAZIONE
    int reg = pin / 32, offset = pin % 32;
    return (GPLEV[reg] >> offset) & 0x1;
#else
    if (pin < 0 || pin >= 40) return -1;
    // printf("digitalRead(pin=%d) -> %d\n", pin, gpio_level[pin]);
    return gpio_level[pin];
#endif  // SIMULAZIONE
}
