(* blackbox *)
module sram_8x1024 (
    input wire clk,
    input wire we,                   // Write enable
    input wire [9:0] addr,           // 10-bit address (1024 depth)
    input wire [7:0] data_in,        // 8-bit data input
    output reg [7:0] data_out        // 8-bit data output
);

endmodule
