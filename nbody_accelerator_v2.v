`timescale 1ns / 1ps
/*
 * N-Body SIMD / Systolic Array Hardware Accelerator (V2)
 * 
 * In a 5-body simulation, there are exactly 10 unique pairwise interactions.
 * This V2 accelerator accepts the coordinates of all 5 bodies simultaneously
 * and utilizes 10 parallel distance pipelines to calculate all gravitational
 * force magnitudes (1 / dist^3) in a single hardware execution cycle.
 *
 * This represents a massive SIMD (Single Instruction, Multiple Data) speedup 
 * over the V1 scalar pipeline.
 */

module nbody_accelerator_v2 (
    input wire clk,
    input wire rst,
    input wire start,
    
    // Inputs: Coordinates for all 5 planets (3 axes * 32-bit floats each)
    input wire [31:0] p0_x, input wire [31:0] p0_y, input wire [31:0] p0_z,
    input wire [31:0] p1_x, input wire [31:0] p1_y, input wire [31:0] p1_z,
    input wire [31:0] p2_x, input wire [31:0] p2_y, input wire [31:0] p2_z,
    input wire [31:0] p3_x, input wire [31:0] p3_y, input wire [31:0] p3_z,
    input wire [31:0] p4_x, input wire [31:0] p4_y, input wire [31:0] p4_z,
    
    // Outputs: 10 parallel force magnitudes for the 10 unique pairs
    output wire [31:0] mag_0_1, output wire [31:0] mag_0_2,
    output wire [31:0] mag_0_3, output wire [31:0] mag_0_4,
    output wire [31:0] mag_1_2, output wire [31:0] mag_1_3,
    output wire [31:0] mag_1_4, output wire [31:0] mag_2_3,
    output wire [31:0] mag_2_4, output wire [31:0] mag_3_4,
    
    output wire done
);

    // Internal ready signals from the 10 pipelines
    wire [9:0] pipeline_done;
    
    // The master 'done' signal is high only when ALL 10 pipelines have finished
    assign done = &pipeline_done;

    // ---------------------------------------------------------
    // Instantiate 10 parallel scalar pipelines (from V1)
    // ---------------------------------------------------------
    
    // Pair 0-1
    nbody_pipeline_core pair_0_1 (
        .clk(clk), .rst(rst), .start(start),
        .dx(p0_x - p1_x), .dy(p0_y - p1_y), .dz(p0_z - p1_z),
        .mag_out(mag_0_1), .done(pipeline_done[0])
    );
    
    // Pair 0-2
    nbody_pipeline_core pair_0_2 (
        .clk(clk), .rst(rst), .start(start),
        .dx(p0_x - p2_x), .dy(p0_y - p2_y), .dz(p0_z - p2_z),
        .mag_out(mag_0_2), .done(pipeline_done[1])
    );
    
    // Pair 0-3
    nbody_pipeline_core pair_0_3 (
        .clk(clk), .rst(rst), .start(start),
        .dx(p0_x - p3_x), .dy(p0_y - p3_y), .dz(p0_z - p3_z),
        .mag_out(mag_0_3), .done(pipeline_done[2])
    );
    
    // Pair 0-4
    nbody_pipeline_core pair_0_4 (
        .clk(clk), .rst(rst), .start(start),
        .dx(p0_x - p4_x), .dy(p0_y - p4_y), .dz(p0_z - p4_z),
        .mag_out(mag_0_4), .done(pipeline_done[3])
    );
    
    // Pair 1-2
    nbody_pipeline_core pair_1_2 (
        .clk(clk), .rst(rst), .start(start),
        .dx(p1_x - p2_x), .dy(p1_y - p2_y), .dz(p1_z - p2_z),
        .mag_out(mag_1_2), .done(pipeline_done[4])
    );

    // Pair 1-3
    nbody_pipeline_core pair_1_3 (
        .clk(clk), .rst(rst), .start(start),
        .dx(p1_x - p3_x), .dy(p1_y - p3_y), .dz(p1_z - p3_z),
        .mag_out(mag_1_3), .done(pipeline_done[5])
    );

    // Pair 1-4
    nbody_pipeline_core pair_1_4 (
        .clk(clk), .rst(rst), .start(start),
        .dx(p1_x - p4_x), .dy(p1_y - p4_y), .dz(p1_z - p4_z),
        .mag_out(mag_1_4), .done(pipeline_done[6])
    );

    // Pair 2-3
    nbody_pipeline_core pair_2_3 (
        .clk(clk), .rst(rst), .start(start),
        .dx(p2_x - p3_x), .dy(p2_y - p3_y), .dz(p2_z - p3_z),
        .mag_out(mag_2_3), .done(pipeline_done[7])
    );

    // Pair 2-4
    nbody_pipeline_core pair_2_4 (
        .clk(clk), .rst(rst), .start(start),
        .dx(p2_x - p4_x), .dy(p2_y - p4_y), .dz(p2_z - p4_z),
        .mag_out(mag_2_4), .done(pipeline_done[8])
    );

    // Pair 3-4
    nbody_pipeline_core pair_3_4 (
        .clk(clk), .rst(rst), .start(start),
        .dx(p3_x - p4_x), .dy(p3_y - p4_y), .dz(p3_z - p4_z),
        .mag_out(mag_3_4), .done(pipeline_done[9])
    );

endmodule
