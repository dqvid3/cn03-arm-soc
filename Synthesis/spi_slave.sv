module spi_slave(
    input logic clk, reset, mosi, cs,
    input logic [7:0] d,
    output logic [7:0] q,
    output logic miso
);

    logic [2:0] cnt;
    logic q_delayed;

    always_ff @(negedge clk) begin
        if (reset)
            cnt <= 0;
        else if (!cs) begin
            cnt <= cnt + 1;
            q_delayed <= q[7];
        end 
    end
    always_ff @(posedge clk) begin
        if (!cs) begin
            q <= (cnt == 0) ? {d[6:0], mosi} : {q[6:0], mosi};
        end
    end
    
    assign miso = (cnt == 0) ? d[7] : q_delayed;

endmodule