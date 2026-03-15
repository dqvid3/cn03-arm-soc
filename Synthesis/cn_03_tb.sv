`timescale 1us/1us

module cn_03_tb();
    logic clk, reset, mosi, cs, miso;
    logic [7:0] received_counter;

    cn_03 dut(clk, reset, cs, mosi, miso);

    always begin
        clk = 0; #10; clk = 1; #10;
    end
    
    always_ff @(negedge clk) begin
        if (!cs) begin
            received_counter <= {received_counter[6:0], miso};
        end
    end

    initial begin 
        $dumpfile("waves/cn_03.vcd");
        $dumpvars(0, cn_03_tb);
        cs = 1;
        reset = 1; #1; reset=0;
    end

    initial begin
        #1;
        cs=0;
        mosi=0; #160; // Master invia 0x00, Slave invia 0 (reset)
        cs=1; #20;

        cs=0;
        mosi=1; #20; // Master invia 0x80, Slave invia 0x00 (ricevuto da prima)
        mosi=0; #140; 
        cs=1; #20;
        $display("Lettura dopo il reset: [d] %d", received_counter);

        cs=0;
        mosi=0; #20;  // Master invia 0x50, Slave invia 0x00+1 (da prima)
        mosi=1; #20;
        mosi=0; #20;
        mosi=1; #20;
        mosi=0; #80; 
        $display("Lettura dopo incremento: [d] %d", received_counter);
        cs=1; #20;

        cs=0;
        mosi=0; #160;  // Master invia 0x00, Slave invia 0x50 (da prima)
        $display("Lettura dopo invio 0x50: [hex] %h", received_counter);
        cs=1; #20;

        $finish;
    end

endmodule