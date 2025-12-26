`timescale 1ns/1ps
module rc5_enc_16bit (
    input clock,
    input reset,
    input enc_start,
    input [15:0] p,
    output reg [15:0] c,
    output reg enc_done
);
    // Internal signal declarations
    reg [2:0] state;
    reg [7:0] A, B;
    reg [7:0] S [0:5];  // S-box keys: S[0], S[1], S[2], S[3], S[4], S[5] for 2 rounds
    reg [7:0] CA_seed;
    reg [7:0] CA_out;
    reg [2:0] key_count;
    reg key_gen_done;
    
    // State definitions
    localparam IDLE = 3'b000;
    localparam KEY_GEN = 3'b001;
    localparam INIT = 3'b010;
    localparam ROUND1 = 3'b011;
    localparam ROUND2 = 3'b100;
    localparam DONE = 3'b101;
    
    // Instantiate CA_8bit module
    CA_8bit ca_inst (
        .clock(clock),
        .reset(reset),
        .CA_seed(CA_seed),
        .CA_out(CA_out)
    );
    
    // FSM for RC5 encryption
    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            state <= IDLE;
            c <= 16'h0000;
            enc_done <= 1'b0;
            A <= 8'h00;
            B <= 8'h00;
            CA_seed <= 8'hFF;
            key_count <= 3'b000;
            key_gen_done <= 1'b0;
            S[0] <= 8'h00;
            S[1] <= 8'h00;
            S[2] <= 8'h00;
            S[3] <= 8'h00;
            S[4] <= 8'h00;
            S[5] <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    enc_done <= 1'b0;
                    if (enc_start) begin
                        state <= KEY_GEN;
                        CA_seed <= 8'hFF;
                        key_count <= 3'b000;
                        key_gen_done <= 1'b0;
                    end
                end
                
                KEY_GEN: begin
                    // Generate 6 keys using CA
                    if (key_count < 3'b110) begin
                        // Wait for CA to update
                        S[key_count] <= CA_out;
                        CA_seed <= CA_out;
                        key_count <= key_count + 1;
                    end else begin
                        key_gen_done <= 1'b1;
                        state <= INIT;
                    end
                end
                
                INIT: begin
                    // Initialize A and B from plaintext
                    A <= p[15:8];  // MSB 8 bits
                    B <= p[7:0];   // LSB 8 bits
                    // A = A + S[0], B = B + S[1]
                    A <= (p[15:8] + S[0]);
                    B <= (p[7:0] + S[1]);
                    state <= ROUND1;
                end
                
                ROUND1: begin
                    // Round 1: A = ((A XOR B) <<< B) + S[2], B = ((B XOR A) <<< A) + S[3]
                    // Left rotation function
                    A <= (((A ^ B) << B[2:0]) | ((A ^ B) >> (8 - B[2:0]))) + S[2];
                    B <= (((B ^ A) << A[2:0]) | ((B ^ A) >> (8 - A[2:0]))) + S[3];
                    state <= ROUND2;
                end
                
                ROUND2: begin
                    // Round 2: A = ((A XOR B) <<< B) + S[4], B = ((B XOR A) <<< A) + S[5]
                    A <= (((A ^ B) << B[2:0]) | ((A ^ B) >> (8 - B[2:0]))) + S[4];
                    B <= (((B ^ A) << A[2:0]) | ((B ^ A) >> (8 - A[2:0]))) + S[5];
                    state <= DONE;
                end
                
                DONE: begin
                    c <= {A, B};
                    enc_done <= 1'b1;
                    if (!enc_start) begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule

