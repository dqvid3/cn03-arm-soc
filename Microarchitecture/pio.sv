module pio (
    input  logic        clk, reset, we,
    input  logic [31:0] wd,
    output logic [31:0] pins
);
    flopenr#(32) pin_states(clk, reset, we, wd, pins);
endmodule
