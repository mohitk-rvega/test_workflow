`timescale 1ns/1ps
module rc5_enc_16bit (input clock,//Positive edge-triggered clock
                input reset,//Asynchronous active low reset
			          input enc_start, //When HIGH, encryption begins
			          input [15:0]p, //Plaintext input
			          output reg [15:0]c, //Ciphertext output
			          output reg enc_done); //When HIGH, indicates the stable ciphertext output
	// Internal signal declarations
	reg [2:0] state;
	reg [7:0] A, B;
	reg [7:0] S [0:5];
	reg [7:0] CA_seed;
	reg [7:0] CA_out;
	reg [2:0] key_count;
	
	// State definitions
	localparam IDLE = 3'b000;
	localparam KEY_GEN = 3'b001;
	localparam INIT = 3'b010;
	localparam ROUND1 = 3'b011;
	localparam ROUND2 = 3'b100;
	localparam DONE = 3'b101;
	
	// Instantiate the Key generation module based on cellular automata
	CA_8bit ca_inst (
		.clock(clock),
		.reset(reset),
		.CA_seed(CA_seed),
		.CA_out(CA_out)
	);
	
	// TODO: Insert FSM to handle two rounds of encryption 
	
endmodule