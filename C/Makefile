TARGET = bin/cn03
SOURCES = src/kernel.c src/delay.c src/peripherals.c src/spi_bb.c
OBJECTS = obj/kernel.o obj/delay.o obj/peripherals.o obj/spi_bb.o
CC = gcc
CFLAGS = -Wall -Iinclude -DSIMULAZIONE

all: $(TARGET)

$(TARGET): $(OBJECTS)
	@mkdir -p bin
	$(CC) $(OBJECTS) -o $(TARGET)

obj/kernel.o: src/kernel.c
	@mkdir -p obj
	$(CC) $(CFLAGS) -c src/kernel.c -o obj/kernel.o

obj/delay.o: src/delay.c
	@mkdir -p obj
	$(CC) $(CFLAGS) -c src/delay.c -o obj/delay.o

obj/peripherals.o: src/peripherals.c
	@mkdir -p obj
	$(CC) $(CFLAGS) -c src/peripherals.c -o obj/peripherals.o

obj/spi_bb.o: src/spi_bb.c
	@mkdir -p obj
	$(CC) $(CFLAGS) -c src/spi_bb.c -o obj/spi_bb.o

clean:
	rm -f obj/*.o $(TARGET)

.PHONY: all clean
