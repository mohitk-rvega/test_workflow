`timescale 1ns/1ps
module rc5_enc_16bit (input clock,//Positive edge-triggered clock
                input reset,//Asynchronous active low reset
			          input enc_start, //When HIGH, encryption begins
			          input [15:0]p, //Plaintext input
			          output reg [15:0]c, //Ciphertext output
			          output reg enc_done); //When HIGH, indicates the stable ciphertext output
	//Insert internal signal declarations
	
	//Instantiate the Key generation module based on cellular automata
	
	//Insert FSM to handle two rounds of encryption. 
	
endmodule