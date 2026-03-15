SOURCES						:= $(shell find . -name '*.sv' -not -name '*_tb.sv')
TB_SOURCES 				:= $(shell find . -name '*_tb.sv')
TB_VVP_FILES			:= $(TB_SOURCES:%.sv=%.vvp)
TB_VVP_FILES_RES	:= $(TB_SOURCES:%.sv=%.vvp.result)
TB_VCD_FILES			:= $(shell find . -name '*.vcd')
PWD								:=	$(shell pwd)

RED    := \033[31m
GREEN  := \033[32m
ORANGE := \033[38;5;208m
RESET  := \033[0m

DOCKER=docker
DOCKERARGS=run --rm -v $(PWD):/src -w /src

DEVICE_GOWINPACK=GW1N-9C

DEVICE_NEXTPNR=GW1NR-LV9QN88PC6/I5
FAMILY_NEXTPNR=GW1N-9C
CONSTRAINTS=tangnano9k.cst

MACRO_YOSYS 	= -D LEDS_NR=6 -D OSC_TYPE_OSC
IVERILOGARGS 	= -D LEDS_NR=6


YOSYS     = $(DOCKER) $(DOCKERARGS) hdlc/yosys yosys
NEXTPNR   = $(DOCKER) $(DOCKERARGS) alfredosavi/nextpnr-gowin nextpnr-gowin
GOWINPACK = $(DOCKER) $(DOCKERARGS) alfredosavi/nextpnr-gowin gowin_pack
IVERILOG  = $(DOCKER) $(DOCKERARGS) alfredosavi/icarus iverilog
VVP				=	$(DOCKER) $(DOCKERARGS) alfredosavi/icarus vvp

all: cn_03.fs

%.vvp.result: %.vvp
	@echo "${ORANGE}Simulating $(@:%.vvp.result=%.vvp) -> $@${RESET}"
	@$(VVP) $(@:%.vvp.result=%.vvp) | tee $@
	@!(cat $@ | grep -q -E 'ERROR|Error|Err') || (echo "${RED}Test $@ failed $$?${RESET}"; exit 1)

%.vvp: %.sv
	@echo "${ORANGE}Compiling $< to $@${RESET}"
	$(IVERILOG) -o $@ $< $(filter-out ./cn_03.sv, $(SOURCES)) $(IVERILOGARGS)

test: $(TB_VVP_FILES) $(TB_VVP_FILES_RES)
	@echo "Tests completed!"

cn_03.fs: cn_03.pack
	$(GOWINPACK) -d $(DEVICE_GOWINPACK) -o $@ $^

cn_03.pack: cn_03.json
	$(NEXTPNR) --json $^ --write $@ --device $(DEVICE_NEXTPNR) --family $(FAMILY_NEXTPNR) --cst $(CONSTRAINTS)

cn_03.json:
	$(YOSYS) $(MACRO_YOSYS) -p "synth_gowin -json cn_03.json -top cn_03" $(SOURCES)

prog: cn_03.fs
	@echo "${ORANGE}Programming FPGA with cn_03.fs using openFPGALoader${RESET}"
	openFPGALoader -b tangnano $^

flash: cn_03.fs
	@echo "${ORANGE}Flashing FPGA with cn_03.fs using openFPGALoader${RESET}"
	openFPGALoader -b tangnano -f $^

reset:
	@echo "${ORANGE}Resetting FPGA using openFPGALoader${RESET}"
	openFPGALoader --reset

clean:
	@echo "Cleaning up temporary and compilation files"
	rm -f *.json *.fs *.pack $(TB_VVP_FILES) $(TB_VVP_FILES_RES) $(TB_VCD_FILES)

.PHONY: clean prog
.PRECIOUS: cn_03.json
