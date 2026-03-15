module srcb_shifter (
    input  logic        ALUSrc,
    input  logic  [1:0] ImmSrc,
    input  logic  [7:0] Instr11_4,
    input  logic [31:0] SrcB,
    input  logic [31:0] SrcS, // Rs
    output logic [31:0] ShiftedSrcB
);
    logic [1:0] InstrSh, sh;
    logic [5:0] InstrShamt5, shamnt5;
    logic [3:0] InstrShamt4;

    assign InstrSh     = Instr11_4[2:1]; // Instr[6:5]
    assign InstrShamt5 = Instr11_4[7:3]; // Instr[11:7]
    assign InstrShamt4 = Instr11_4[7:4]; // Instr[11:8]
    assign ShiftByReg = Instr11_4[0];
    logic [4:0] SrcS4_0; 
    assign SrcS4_0 = SrcS[4:0]; 

    always_comb // begin
        case (sh)
            2'b00: ShiftedSrcB = SrcB  << shamnt5;           // logico sx
            2'b01: ShiftedSrcB = SrcB  >> shamnt5;           // logico dx
            2'b10: ShiftedSrcB = signed'(SrcB) >>> shamnt5;  // aritmetico dx
            2'b11: ShiftedSrcB = { SrcB, SrcB } >> shamnt5;  // rotazione
        endcase

    always_comb begin
        if (ALUSrc == 1'b0) begin // I = 0
            // SrcB is from register
            sh      = InstrSh;
            if (ShiftByReg) begin
                shamnt5 = SrcS4_0; // Rs[4:0] for shift amount
            end else begin
                // SrcB is shifted by immediate value
                shamnt5 = InstrShamt5; 
            end
        end else if (ImmSrc == 2'b00) begin // I = 1, Imm8
            // SrcB is 8-bit immediate (Data Processing)
            sh      = 2'b11;
            shamnt5 = {InstrShamt4, 1'b0};
        end else begin
            // Other immediates (Imm12, Imm24) are not shifted
            sh      = 2'b00;
            shamnt5 = 5'b00000;
        end
    end
endmodule
