`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2024 09:29:56 AM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input   wire clk,
    input   wire reset_n,
    input   wire ser_data,
    inout   wire data_ready,
    input   wire [1:0] mode,
    output  wire [3:0] result_data
    );
    
    
    wire [7:0]  incoming_data;
    wire        incoming_data_valid;
    
    
    // module instantiations
    
    
    deserializer u_des (
        .clk(clk),
        .reset_n(reset_n),
        .ser_in(ser_data),
        .data_ready(data_ready),
        .data_out(incoming_data),
        .valid(incoming_data_valid)
    );
    
    controller u_controller (
        .clk(clk),
        .reset_n(reset_n),
        .mode(mode),
        .incoming_data(incoming_data),
        .incoming_data_valid(incoming_data_valid),
        .result_data(result_data),  
        .result_data_valid(data_ready)
    );
endmodule
