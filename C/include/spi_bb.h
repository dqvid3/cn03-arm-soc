#ifndef SPI_BB_H
#define SPI_BB_H

#include <stdint.h>

#define SPI_PIN_CS   8
#define SPI_PIN_MISO 9
#define SPI_PIN_MOSI 10
#define SPI_PIN_CLK  11

#define CN03_CMD_INCREMENT 0x80            // [1000 0000] MSB = 1 -> INCREMENT.
#define CN03_CMD_SET(val)  ((val) & 0x7F)  // [0111 1111] MSB = 0 -> SET.

void spi_init();
uint8_t spi_transfer(uint8_t command);

#endif
