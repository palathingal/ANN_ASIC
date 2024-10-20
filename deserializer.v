`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2024 09:35:18 AM
// Design Name: 
// Module Name: deserializer
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


module deserializer (
    input wire clk,             // Clock signal
    input wire reset_n,         // Active-low reset
    input wire ser_in,          // Serial input
    input wire data_ready,      // Signal indicating serial data ready
    output reg [7:0] data_out,  // 8-bit parallel output
    output reg valid            // Output valid signal
);

    reg [7:0] shift_reg;        // Shift register for deserializing data
    reg [2:0] bit_cnt;          // Counter for tracking bit position

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            shift_reg <= 8'b0;
            bit_cnt <= 3'b000;
            data_out <= 8'b0;
            valid <= 1'b0;
        end else begin
            if (data_ready) begin
                shift_reg <= {shift_reg[6:0], ser_in};  // Shift serial data into register
                bit_cnt <= bit_cnt + 1;

                if (bit_cnt == 3'b111) begin
                    data_out <= shift_reg;  // Parallel output
                    valid <= 1'b1;          // Data valid signal set
                end else begin
                    valid <= 1'b0;
                end
            end
        end
    end
endmodule

