`timescale 1ns / 1ps
/*
 * N-Body Distance & Force Accelerator Pipeline
 * 
 * This module accepts coordinates of two bodies and calculates the magnitude 
 * of the gravitational force factor: F_mag = 1 / (distance^3).
 * It uses pipelined floating-point multipliers and adders (abstracted here as 
 * standard operators for structural representation) to offload the most expensive
 * mathematical operation in the nbody simulation.
 */

module nbody_accelerator (
    input wire clk,
    input wire rst,
    input wire start,
    // 32-bit floating point inputs for delta coordinates (dx, dy, dz)
    input wire [31:0] dx,
    input wire [31:0] dy,
    input wire [31:0] dz,
    
    output reg [31:0] mag_out, // 1 / (dist^3)
    output reg done
);

    // Internal pipeline registers
    reg [31:0] dx_sq, dy_sq, dz_sq;
    reg [31:0] sum_sq;
    reg [31:0] dist;
    reg [31:0] dist_cubed;
    
    // State machine for pipeline (Simplified 4-stage pipeline for illustration)
    reg [2:0] state;
    
    localparam IDLE = 0, STAGE1_SQ = 1, STAGE2_SUM = 2, STAGE3_SQRT = 3, STAGE4_CUBE_INV = 4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            mag_out <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) state <= STAGE1_SQ;
                end
                
                STAGE1_SQ: begin
                    // Floating point multiplications (Assuming combinatorial FP modules in real synthesis)
                    dx_sq <= dx * dx; 
                    dy_sq <= dy * dy;
                    dz_sq <= dz * dz;
                    state <= STAGE2_SUM;
                end
                
                STAGE2_SUM: begin
                    sum_sq <= dx_sq + dy_sq + dz_sq;
                    state <= STAGE3_SQRT;
                end
                
                STAGE3_SQRT: begin
                    // Floating point square root (e.g., using fast inverse square root or FP IP block)
                    // For logic representation, we assume an abstract sqrt function
                    dist <= $sqrt(sum_sq); // Pseudo-code for IP block instantiation
                    state <= STAGE4_CUBE_INV;
                end
                
                STAGE4_CUBE_INV: begin
                    dist_cubed <= dist * dist * dist;
                    mag_out <= 32'h3F800000 / dist_cubed; // 1.0 (in FP) / dist_cubed
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
