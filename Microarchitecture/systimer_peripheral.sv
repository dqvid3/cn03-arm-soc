module systimer_peripheral(
    input logic         cpu_clk,      // Clock per l'interfaccia del bus
    input logic         timer_clk,    // Clock da 1 MHz per il conteggio
    input logic         reset,
    input logic         we,
    input logic [31:0]  a,
    input logic [31:0]  wd,
    output logic [31:0] rd
);
    logic [63:0] systimer_counter; // 64-bit counter
    logic [31:0] systimer_cs; // CS
    logic [31:0] systimer_compare0; // C0
    logic [31:0] systimer_compare1; // C1

    logic        compare0_enabled, compare1_enabled;

    logic [31:0] systimer_counter31_0;
    assign systimer_counter31_0 = systimer_counter[31:0];    // Icarus Verilog doesn't support
    logic [31:0] systimer_counter63_32;                      // constant select in always_ blocks
    assign systimer_counter63_32 = systimer_counter[63:32]; 

    localparam CS = 32'h00;
    localparam CLO = 32'h04;
    localparam CHI = 32'h08;
    localparam C0 = 32'h0C;
    localparam C1 = 32'h10;

    // The higher is 32'h10 = 8'b00010000 -> 5 bits are enough
    logic [4:0] addr_offset;
    assign addr_offset = a[4:0]; 

    always_ff @(posedge timer_clk) begin
        systimer_counter <= systimer_counter + 1;
        // Match logic
        if ((systimer_counter31_0 == systimer_compare0) && compare0_enabled) begin
            systimer_cs[0] <= 1'b1;
            compare0_enabled <= 1'b0; 
        end
        if ((systimer_counter31_0 == systimer_compare1) && compare1_enabled) begin
            systimer_cs[1] <= 1'b1;
            compare1_enabled <= 1'b0;
        end        
    end

    always_ff @(posedge cpu_clk, posedge reset) begin
        if (reset) begin
            systimer_counter <= 0; 
            systimer_cs <= 0;
            systimer_compare0 <= 32'h00000000; 
            systimer_compare1 <= 32'h00000000; 
            compare0_enabled <= 1'b0;
            compare1_enabled <= 1'b0;
        end else begin
            if (we) begin
                case (addr_offset)
                    CS: systimer_cs <= systimer_cs & ~wd; // Clear status bits
                    C0: begin 
                        systimer_compare0 <= wd; 
                        compare0_enabled <= 1'b1; 
                    end
                    C1: begin
                        systimer_compare1 <= wd; 
                        compare1_enabled <= 1'b1;
                    end
                endcase
            end
        end
    end

    always_comb begin
        rd = 32'b0; 
        case (addr_offset)
            CS: rd = systimer_cs;
            CLO: rd = systimer_counter31_0;
            CHI: rd = systimer_counter63_32; 
            C0: rd = systimer_compare0;
            C1: rd = systimer_compare1;
        endcase
    end
endmodule
