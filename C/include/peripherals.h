#ifndef PERIPHERALS_H
#define PERIPHERALS_H

#ifndef SIMULAZIONE
#define PERIPHERALS_BASE 0x3F000000
#define SYSTIMER (PERIPHERALS_BASE + 0x00003000)
#define SYSTIMER_CS  (*(volatile uint32_t *)(SYSTIMER + 0x00))
#define SYSTIMER_CLO (*(volatile uint32_t *)(SYSTIMER + 0x04))
#define SYSTIMER_C1  (*(volatile uint32_t *)(SYSTIMER + 0x10))
#define GPIO (PERIPHERALS_BASE + 0x00200000)
#define GPFSEL ((volatile uint32_t *)(GPIO + 0x00))
#define GPSET  ((volatile uint32_t *)(GPIO + 0x1C))
#define GPCLR  ((volatile uint32_t *)(GPIO + 0x28))
#define GPLEV  ((volatile uint32_t *)(GPIO + 0x34))
#endif  // SIMULAZIONE

#define INPUT  0
#define OUTPUT 1

void pinMode(int pin, int function);
void digitalWrite(int pin, int val);
int digitalRead(int pin);

#endif
