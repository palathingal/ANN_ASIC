module top(
    input   wire clk,
    input   wire reset_n,
    input   wire ser_data,
    input   wire data_ready,
    input   wire [1:0] mode,
    output  wire [3:0] result_data
    );
    
    
    wire [7:0]  incoming_data;
    wire        incoming_data_valid;
    wire [7:0]  data_in_w, data_in_n, data_in_b, data_in_p1, data_in_p2;
    wire        we_w, we_n, we_b, we_p1, we_p2;
    wire [18:0] addr_w;
    wire [9:0]  addr_n, addr_b, addr_p1, addr_p2;
    wire [7:0]  data_out_w, data_out_n, data_out_b, data_out_p1, data_out_p2;
    
    // module instantiations
    
    
    deserializer u_des (
        .clk(clk),
        .reset_n(reset_n),
        .ser_in(ser_data),
        .data_ready(data_ready),
        .data_out(incoming_data),
        .valid(incoming_data_valid)
    );
    
    controller mlp (
        .clk(clk),
        .reset_n(reset_n),
        .mode(mode),
        .incoming_data(incoming_data),
        .incoming_data_valid(incoming_data_valid),
        .data_in_w(data_in_w),
        .data_in_n(data_in_n),
        .data_in_p1(data_in_p1),
        .data_in_p2(data_in_p2),
        .data_in_b(data_in_b),
        .we_w(we_w),
        .we_n(we_n),
        .we_b(we_b),
        .we_p1(we_p1),
        .we_p2(we_p2),
        .addr_w(addr_w),
        .addr_n(addr_n),
        .addr_b(addr_b),
        .addr_p1(addr_p1),
        .addr_p2(addr_p2),
        .data_out_w(data_out_w),
        .data_out_n(data_out_n),
        .data_out_b(data_out_b),
        .data_out_p1(data_out_p1),
        .data_out_p2(data_out_p2),
        .result_data(result_data) 

    );
    
    memory_controller sram (                    // Weight SRAM 
        .clk(clk),
        .we(we_w),
        .addr(addr_w),
        .data_in(data_in_w),
        .data_out(data_out_w)
        
    );
    
    // Instantiate SRAM block
    sky130_sram_1kbyte_1rw1r_8x1024_8 sram_inst_n (
        .clk0(clk),
        .csb0(1'b0),                    // Active low
        .web0(~we_n),                  // Write enable only for selected block
        .wmask0(1'b1),
        .addr0(addr_n),                     // Address within the block
        .din0(data_in_n),                     // Data to write
        .dout0(data_out_n)            // Data from the SRAM
           
     );
    
    sky130_sram_1kbyte_1rw1r_8x1024_8 sram_inst_b (
        .clk0(clk),
        .csb0(1'b0),                    // Active low
        .web0(~we_b),                  // Write enable only for selected block
        .wmask0(1'b1),
        .addr0(addr_b),                     // Address within the block
        .din0(data_in_b),                     // Data to write
        .dout0(data_out_b)            // Data from the SRAM
           
     );
    
    sky130_sram_1kbyte_1rw1r_8x1024_8 sram_inst_p1 (
        .clk0(clk),
        .csb0(1'b0),                    // Active low
        .web0(~we_p1),                  // Write enable only for selected block
        .wmask0(1'b1),
        .addr0(addr_p1),                     // Address within the block
        .din0(data_in_p1),                     // Data to write
        .dout0(data_out_p1)            // Data from the SRAM
           
     );
    
    sky130_sram_1kbyte_1rw1r_8x1024_8 sram_inst_p2 (
        .clk0(clk),
        .csb0(1'b0),                    // Active low
        .web0(~we_p2),                  // Write enable only for selected block
        .wmask0(1'b1),
        .addr0(addr_p2),                     // Address within the block
        .din0(data_in_p2),                     // Data to write
        .dout0(data_out_p2)            // Data from the SRAM
           
     );
    
endmodule
