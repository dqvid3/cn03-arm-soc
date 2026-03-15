arm-none-eabi-as memfile.s -o memfile.o
arm-none-eabi-objdump -d memfile.o
arm-none-eabi-objcopy memfile.o -O binary memfile.bin
hexdump -C memfile.bin
hexdump -e '1/4 "%02x" "\n"' memfile.bin > memfile.dat
rm memfile.o memfile.bin 
iverilog -g2012 *.sv 
vvp a.out
rm a.out single_cycle_cpu.vcd