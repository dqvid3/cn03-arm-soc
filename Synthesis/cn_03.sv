module cn_03(
    input logic sck, reset, cs, mosi,
    output logic miso
);
    logic [7:0] value_to_master, q;
    logic [7:0] counter;
    logic [2:0] bit_count;

    spi_slave io(sck, reset, mosi, cs, value_to_master, q, miso);

    always_ff @(posedge reset) begin
        value_to_master <= 0;
        counter <= 0;
    end

    always_ff @(negedge cs) begin // Inizio trasmissione
        value_to_master <= counter; // Invio il counter corrente
        bit_count <= 0; 
    end

    always_ff @(posedge sck) begin
        if (!cs)
            bit_count <= bit_count + 1; 
    end

    always_ff @(negedge sck) begin 
        /*
            Se il bit più significativo del valore ricevuto dal master è:
            - 1 il dispositivo CN-03 incrementa il contatore
            - 0 lo imposta al valore dato dai restanti 7 bit (con zero-extension a 8-bit).
        */
        if (!cs) begin
            if (bit_count == 3'd0) begin 
                if (q[7]) 
                    counter <= counter + 1;
                else 
                    counter <= {1'b0, q[6:0]};
            end
        end
    end
endmodule