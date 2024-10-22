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
    wire [7:0]  data_in;
    wire        we;
    wire [18:0] addr;
    wire [7:0]  data_out;
    
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
        .data_in(data_in),
        .we(we),
        .addr(addr),
        .data_out(data_out),
        .result_data(result_data),  
        .result_data_valid(data_ready)
    );
    
    memory_controller sram (
        .clk(clk),
        .we(we),
        .addr(addr),
        .data_in(data_in),
        .data_out(data_out)
        
    );
    
endmodule
