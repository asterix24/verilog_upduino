# =========================================
# Makefile: usa files.f per SIM + iCE40
# =========================================
# files.f: elenco dei sorgenti (uno per riga). Esempio:
#   src/counter.v
#   src/comparator.v
#   src/top.v
#   sim/tb_top.v
#
# Variabili FPGA (sovrascrivibili da CLI)
PROJ    ?= uno
PIN_DEF ?= ice.pcf
DEVICE  ?= up5k
PACKAGE ?= sg48

# ---- Toolchain SIM ----
IVL ?= iverilog
VVP ?= vvp
GTK ?= gtkwave
STD ?= -g2005          # usa -g2012 se passi a SystemVerilog

# ---- Toolchain FPGA (Ice40) ----
YOSYS   ?= yosys
NEXTPNR ?= nextpnr-ice40
ICEPACK ?= icepack
ICETIME ?= icetime
ICEBURN ?= iceprog

# ---- Dir e nomi ----
BUILD  := build
FPGA_B := $(BUILD)/fpga

TOP ?= top       # nome modulo top per sintesi
TB  ?= tb_top    # nome del modulo di testbench per Icarus
VCD := $(BUILD)/$(TB).vcd

# ---- Sorgenti da files.f ----
FILES_F := files.f

# Tutti i file elencati (ignora vuoti e commenti)
ALL_SRCS := $(shell sed -E 's/#.*$$//;/^\s*$$/d' $(FILES_F))

# File RTL per la sintesi: escludi 'sim/' e file stile testbench
RTL_SRCS := $(shell sed -E 's/#.*$$//;/^\s*$$/d' $(FILES_F) \
            | grep -Ev '(^|/)(sim/|tb_.*\.sv?$$|.*_tb\.sv?$$)' 2>/dev/null || true)

# File TB (facoltativo): differenza insiemistica (può essere vuota)
TB_SRCS := $(filter-out $(RTL_SRCS),$(ALL_SRCS))

# ---- Flag Icarus ----
IVL_FLAGS := $(STD) -Wall -Wimplicit -o $(BUILD)/$(TB) -s $(TB)

# =====================
#    Target principali
# =====================
.PHONY: all sim fpga run wave lint bit rpt prog sudo-prog clean help

# Costruisce simulazione + bitstream + report
all: run bit rpt

# -------- Simulazione (Icarus) --------
sim: $(BUILD)/$(TB)

$(BUILD)/$(TB): $(FILES_F) $(ALL_SRCS)
	@mkdir -p $(BUILD)
	$(IVL) $(IVL_FLAGS) -f $(FILES_F)

run: sim
	@echo "==> Running simulation..."
	@cd $(BUILD) && $(VVP) ./$(TB)
	@if test -f "$(VCD)"; then \
			echo "==> VCD (se generata) in: $(VCD)" \
		else \
			echo "Use $dumpfile(\"tb_top.vcd\") the VCD file goes in $(BUILD)/"; \
		fi;

wave: run
	@if test -f "$(VCD)"; then \
	  $(GTK) "$(VCD)" & \
	else \
	  echo "VCD mancante: $(VCD) — esegui 'make run' e verifica $$dumpfile"; \
	fi

lint:
	@which verilator >/dev/null 2>&1 && \
	  verilator --lint-only -Wall $(ALL_SRCS) || \
	  echo "Verilator non trovato: salto il lint."

# -------- Flusso FPGA iCE40 --------
# Json (sintesi Yosys): usa solo RTL_SRCS
$(FPGA_B)/$(PROJ).json: $(FILES_F) $(RTL_SRCS)
	@mkdir -p $(FPGA_B)
	$(YOSYS) -p 'read_verilog $(RTL_SRCS); synth_ice40 -top $(TOP) -json $@'

# Place & Route (nextpnr) -> asc
$(FPGA_B)/$(PROJ).asc: $(PIN_DEF) $(FPGA_B)/$(PROJ).json
	$(NEXTPNR) --$(DEVICE) --package $(PACKAGE) \
	  --json $(FPGA_B)/$(PROJ).json --pcf $(PIN_DEF) --asc $@

# Bitstream (icepack) -> bin
$(FPGA_B)/$(PROJ).bin: $(FPGA_B)/$(PROJ).asc
	$(ICEPACK) $< $@

# Timing report (icetime) -> rpt
$(FPGA_B)/$(PROJ).rpt: $(FPGA_B)/$(PROJ).asc
	$(ICETIME) -d $(DEVICE) -mtr $@ $<

# Alias comodi
fpga: bit rpt
bit:  $(FPGA_B)/$(PROJ).bin
rpt:  $(FPGA_B)/$(PROJ).rpt

# Programmazione
prog: $(FPGA_B)/$(PROJ).bin
	$(ICEBURN) $<

sudo-prog: $(FPGA_B)/$(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEBURN) $<

# -------- Utility --------
clean:
	@rm -rf $(BUILD) *.vcd

help:
	@echo "Target:"
	@echo "  make run       - compila e lancia la simulazione (Icarus)"
	@echo "  make wave      - apre la VCD con GTKWave"
	@echo "  make lint      - lint con Verilator (se presente)"
	@echo "  make fpga      - genera bitstream (.bin) e report timing (.rpt)"
	@echo "  make bit       - solo bitstream"
	@echo "  make rpt       - solo timing report"
	@echo "  make prog      - programma con iCEburn.py"
	@echo "  make sudo-prog - programma con sudo"
	@echo "  Variabili: PROJ, PIN_DEF, DEVICE, PACKAGE, TOP, TB"

