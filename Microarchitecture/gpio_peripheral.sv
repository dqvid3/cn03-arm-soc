module gpio_peripheral(
    input logic         clk, reset,
    input logic         we,
    input logic [31:0]  a,
    input logic [31:0]  wd,
    output logic [31:0] rd,
    output logic [31:0]  pins_out,
    input  logic [31:0]  pins_in
);
    logic [31:0] gpfsel0, gpfsel1; // GPIO Function Select registers

    localparam GPFSEL0 = 32'h00;
    localparam GPFSEL1 = 32'h04;
    localparam GPSET0 = 32'h1C;
    localparam GPCLR0 = 32'h28;
    localparam GPLEV0 = 32'h34;

    localparam FSEL_INPUT  = 3'b000;
    localparam FSEL_OUTPUT = 3'b001;

    // The higher is 32'h34 = 8'b00110100 -> 6 bits are enough
    logic [5:0] addr_offset;
    assign addr_offset = a[5:0]; 

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            gpfsel0 <= 0; 
            gpfsel1 <= 0;
            pins_out <= 0; 
        end else if (we) begin
            case (addr_offset)
                GPFSEL0: gpfsel0 <= wd; // select function pin 0-9
                GPFSEL1: gpfsel1 <= wd; // select function pin 10-19
                GPSET0:  pins_out <= pins_out | wd; // Set to 1 specified pins
                GPCLR0:  pins_out <= pins_out & ~wd; // Set to 0 specified pins
            endcase
        end
    end

    always_comb begin
        case (addr_offset)
            GPFSEL0: rd = gpfsel0;
            GPFSEL1: rd = gpfsel1;
            GPLEV0: begin
                for (int i = 0; i < 20; i++) begin // Solo per i pin 0-19 coperti da GPFSEL0/1
                    logic [2:0] function_select;

                    if (i < 10) begin
                        function_select = gpfsel0 >> (i * 3);
                    end else begin
                        function_select = gpfsel1 >> ((i - 10) * 3);
                    end

                    // Se il pin è configurato come INPUT, leggi dal pin fisico (pins_in)
                    // Altrimenti (es. OUTPUT), leggi il valore che il processore ha impostato (pins_out)
                    if (function_select == FSEL_INPUT) begin
                        rd[i] = pins_in[i];
                    end else begin
                        rd[i] = pins_out[i];
                    end
                end
            end
        endcase
    end
endmodule