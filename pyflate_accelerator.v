`timescale 1ns / 1ps
/*
 * Huffman Decoder Accelerator Pipeline
 * 
 * This module offloads the bit-stream parsing and Huffman tree traversal 
 * from the CPU. It accepts a stream of compressed bytes and outputs 
 * decoded symbols using a local SRAM-based lookup table.
 */

module pyflate_accelerator (
    input wire clk,
    input wire rst,
    input wire valid_in,
    input wire [7:0] byte_in,    // Compressed data stream
    
    output reg [15:0] symbol_out, // Decoded symbol
    output reg valid_out
);

    // 64-bit shift register to hold incoming bits
    reg [63:0] bit_buffer;
    reg [6:0] bits_available;

    // Huffman Lookup Table (Simplified to direct mapping for illustration)
    // In a real design, this would be an SRAM populated by the CPU before decompression
    wire [15:0] decode_val;
    wire [3:0] decode_len;
    
    // Combinatorial Huffman logic (abstracted)
    assign decode_val = bit_buffer[15:0] ^ 16'hAAAA; // Dummy decode logic
    assign decode_len = 4'd5; // Assuming fixed 5-bit symbols for the example

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bit_buffer <= 0;
            bits_available <= 0;
            valid_out <= 0;
            symbol_out <= 0;
        end else begin
            // Shift new byte into the buffer
            if (valid_in && bits_available < 56) begin
                bit_buffer <= bit_buffer | ({56'b0, byte_in} << bits_available);
                bits_available <= bits_available + 8;
            end
            
            // Decode symbol if we have enough bits
            if (bits_available >= decode_len) begin
                symbol_out <= decode_val;
                valid_out <= 1;
                // Shift buffer down by the length of the decoded symbol
                bit_buffer <= bit_buffer >> decode_len;
                bits_available <= bits_available - decode_len;
            end else begin
                valid_out <= 0;
            end
        end
    end

endmodule
