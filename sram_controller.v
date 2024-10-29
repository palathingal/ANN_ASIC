module memory_controller (
    input wire clk,
    input wire we,                        // Write enable
    input wire [18:0] addr,               // 18-bit address for 283,863 locations
    input wire [7:0] data_in,             // 8-bit data input
    output reg [7:0] data_out             // 8-bit data output
);

    // Wire to connect data output from each SRAM block
    wire [7:0] sram_data_out [277:0];     // Output data from each SRAM block

    // Wire to generate chip enable for each SRAM block
    wire sram_ce [277:0];                 // Chip enable signal for each SRAM block

    // Split address into block select and internal address
    wire [9:0] block_select;              // Higher 9 bits for block selection
    wire [9:0] block_addr;                // Lower 10 bits for address within block

    assign block_select = addr[18:10];
    assign block_addr = addr[9:0];

    // Generate chip enable signals for SRAM blocks
    genvar i;
    generate
        for (i = 0; i < 278; i = i + 1) begin : sram_blocks
            assign sram_ce[i] = (block_select == i);   // Enable only the selected block

            // Instantiate SRAM block
            sky130_sram_1kbyte_1rw1r_8x1024_8 sram_inst0 (
                .clk0(clk),
                .csb0(~sram_ce[i]),
                .web0(~we),                  // Write enable only for selected block
                .wmask0(1'b1),
                .addr0(block_addr),                     // Address within the block
                .din0(data_in),                     // Data to write
                .dout0(sram_data_out[i])            // Data from the SRAM
           
            );
        end
    endgenerate

    // Read data from the selected block
    always @(posedge clk) begin
        data_out <= sram_data_out[block_select];        // Output data from the selected block
    end
endmodule
