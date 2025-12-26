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
            // Bit 7 (MSB): R90 - x(7) = x(6) XOR x(0) (wraps around)
            CA_out[7] <= CA_seed[6] ^ CA_seed[0];
            
            // Bit 6: R90 - x(6) = x(7) XOR x(5)
            CA_out[6] <= CA_seed[7] ^ CA_seed[5];
            
            // Bit 5: R150 - x(5) = x(6) XOR x(5) XOR x(4)
            CA_out[5] <= CA_seed[6] ^ CA_seed[5] ^ CA_seed[4];
            
            // Bit 4: R90 - x(4) = x(5) XOR x(3)
            CA_out[4] <= CA_seed[5] ^ CA_seed[3];
            
            // Bit 3: R150 - x(3) = x(4) XOR x(3) XOR x(2)
            CA_out[3] <= CA_seed[4] ^ CA_seed[3] ^ CA_seed[2];
            
            // Bit 2: R90 - x(2) = x(3) XOR x(1)
            CA_out[2] <= CA_seed[3] ^ CA_seed[1];
            
            // Bit 1: R150 - x(1) = x(2) XOR x(1) XOR x(0)
            CA_out[1] <= CA_seed[2] ^ CA_seed[1] ^ CA_seed[0];
            
            // Bit 0 (LSB): R90 - x(0) = x(1) XOR x(7) (wraps around)
            CA_out[0] <= CA_seed[1] ^ CA_seed[7];
        end
    end
endmodule
