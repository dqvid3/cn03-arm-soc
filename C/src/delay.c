#ifdef SIMULAZIONE
#include <unistd.h>
#endif  // SIMULAZIONE

#include <stdint.h>

#include "peripherals.h"

/*
 * delay_us
 * args: delay (~ microseconds)
 */
void delay_us(uint32_t delay) {
#ifndef SIMULAZIONE
    SYSTIMER_C1 = SYSTIMER_CLO + delay;
    SYSTIMER_CS |= 0x2;
    while (!(SYSTIMER_CS & 0x2));
#else
    usleep(delay);
#endif
}
