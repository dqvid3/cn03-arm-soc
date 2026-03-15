module bus_decoder (
    input  logic [31:0] a,
    input  logic        we,
    output logic        MemoryEnable,
    output logic        GPIOEnable,
    output logic        SystemTimerEnable
);
    localparam PERIPHERALS_BASE = 32'h3F000000;
    localparam GPIO             = PERIPHERALS_BASE | 32'h00200000;
    localparam SYSTIMER         = PERIPHERALS_BASE | 32'h00003000;

    always_comb begin
        MemoryEnable      = 1'b0;
        GPIOEnable        = 1'b0;
        SystemTimerEnable = 1'b0;

        // Check if the address is within the GPIO range
        if ((a & 32'hFFF00000) == GPIO) begin
            GPIOEnable = 1'b1;
        end
        // Check if the address is within the System Timer range
        else if ((a & 32'hFFFFF000) == SYSTIMER) begin
            SystemTimerEnable = 1'b1;
        end
        // If not in any peripheral range, enable memory access
        else begin
            MemoryEnable = 1'b1;
        end
    end

endmodule
