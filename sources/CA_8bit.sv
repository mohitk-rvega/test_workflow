`timescale 1ns/1ps
module CA_8bit (
    input clock,
    input reset,
    input [7:0] CA_seed,
    output reg [7:0] CA_out
);
    // CA rules: R90, R90, R150, R90, R150, R90, R150, R90 (from MSB to LSB)
    // Rule 90: x(i) = x(i-1) XOR x(i+1)
    // Rule 150: x(i) = x(i-1) XOR x(i) XOR x(i+1)
    
    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            CA_out <= 8'hFF;
        end else begin
            // Bit 7 (MSB): R90
            CA_out[7] <= (CA_seed[6] ^ CA_seed[0]); // Boundary: bit 6 is previous, bit 0 wraps as next
            
            // Bit 6: R90
            CA_out[6] <= (CA_seed[7] ^ CA_seed[5]);
            
            // Bit 5: R150
            CA_out[5] <= (CA_seed[6] ^ CA_seed[5] ^ CA_seed[4]);
            
            // Bit 4: R90
            CA_out[4] <= (CA_seed[5] ^ CA_seed[3]);
            
            // Bit 3: R150
            CA_out[3] <= (CA_seed[4] ^ CA_seed[3] ^ CA_seed[2]);
            
            // Bit 2: R90
            CA_out[2] <= (CA_seed[3] ^ CA_seed[1]);
            
            // Bit 1: R150
            CA_out[1] <= (CA_seed[2] ^ CA_seed[1] ^ CA_seed[0]);
            
            // Bit 0 (LSB): R90
            CA_out[0] <= (CA_seed[1] ^ CA_seed[7]); // Boundary: bit 1 is previous, bit 7 wraps as next
        end
    end
endmodule

