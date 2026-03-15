#include <stdint.h>
#include <stdio.h>

#include "delay.h"
#include "peripherals.h"
#include "spi_bb.h"

#ifdef SIMULAZIONE
uint8_t gpio_level[40] = {0};
uint8_t gpio_mode[40] = {0};
uint8_t cn03_counter = 0;
#endif // SIMULAZIONE

uint8_t cn03_communicate(uint8_t command) {
    digitalWrite(SPI_PIN_CS, 0);
    uint8_t received_value = spi_transfer(command);
    digitalWrite(SPI_PIN_CS, 1);
    delay_us(1);
    return received_value;
}

void display_8bit_value(uint8_t value) {
    printf("value = %u\n", value);
}

int main() {
    spi_init();
    while (1) {
        uint8_t received_val;
        received_val = cn03_communicate(CN03_CMD_SET(0));
        display_8bit_value(received_val);
        for (size_t i = 0; i < 100; i++) {
            received_val = cn03_communicate(CN03_CMD_INCREMENT);
            display_8bit_value(received_val);
        }
        received_val = cn03_communicate(CN03_CMD_SET(127));
        display_8bit_value(received_val);
        received_val = cn03_communicate(CN03_CMD_INCREMENT);
        display_8bit_value(received_val);
        delay_us(2e6);
        break;
    }
    return 0;
}
