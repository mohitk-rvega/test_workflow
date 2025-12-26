`timescale 1ns/1ps
module CA_8bit (
    input clock,
    input reset,
    input [7:0] CA_seed,
    output reg [7:0] CA_out
);
    // TODO: Implement CA with rules R90, R90, R150, R90, R150, R90, R150, R90 (from MSB to LSB)
    // Rule 90: x(i) = x(i-1) XOR x(i+1)
    // Rule 150: x(i) = x(i-1) XOR x(i) XOR x(i+1)
    // On reset LOW, initialize CA_out to 8'hFF
    // On rising clock edge, update CA_out based on CA rules
endmodule

