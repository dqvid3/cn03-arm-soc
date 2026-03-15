#include <stdint.h>

#include "delay.h"
#include "peripherals.h"
#include "simulation.h"
#include "spi_bb.h"

void spi_init() {
    pinMode(SPI_PIN_MOSI, OUTPUT);
    pinMode(SPI_PIN_CLK, OUTPUT);
    pinMode(SPI_PIN_CS, OUTPUT);
    pinMode(SPI_PIN_MISO, INPUT);
    digitalWrite(SPI_PIN_MOSI, 0);
    digitalWrite(SPI_PIN_CLK, 0);
    digitalWrite(SPI_PIN_CS, 1);
}

uint8_t spi_transfer(uint8_t data_out) {
#ifndef SIMULAZIONE
    uint8_t data_in = 0;
    uint32_t half_period_us = 5;
    for (uint8_t mask = 0x80; mask; mask = (mask >> 1)) {
        digitalWrite(SPI_PIN_MOSI, data_out & mask);
        if (digitalRead(SPI_PIN_MISO)) {
            data_in |= mask;
        }
        digitalWrite(SPI_PIN_CLK, 1);
        delay_us(half_period_us);
        digitalWrite(SPI_PIN_CLK, 0);
        delay_us(half_period_us);
    }
    return data_in;
#else
    if (data_out & CN03_CMD_INCREMENT) {
        cn03_counter++;
    } else {
        cn03_counter = CN03_CMD_SET(data_out);
    }
    return cn03_counter;
#endif  // SIMULAZIONE
}
