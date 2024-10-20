`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2024 10:14:56 AM
// Design Name: 
// Module Name: controller
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


module controller(
    input wire clk,
    input wire reset_n,
    input wire [1:0] mode,
    input wire [7:0] incoming_data,
    input wire incoming_data_valid,
    
    output reg [3:0] result_data,
    output reg result_data_valid
    );
    
    integer i;
    
    reg [3:0]   state, next_state;
    reg [18:0]   data_counter, data_counter_next;
    reg [9:0]	mul_counter, mul_counter_next;
    reg [15:0]  acc, acc_next;
    reg [9:0]   mac_counter, mac_counter_next;
    
    reg [7:0] NODE_RAM_L1      	[0     :783   ];
    reg [7:0] WEIGHT_RAM_L1	[784   :235983];
    reg [7:0] BIAS_RAM_L1       [235984:236283];
    reg [7:0] ACTIVATION_RAM_L1 [236284:236583];
    
    reg [7:0] NODE_RAM_L2      	[236584:236883];
    reg [7:0] WEIGHT_RAM_L2	[236884:281883];
    reg [7:0] BIAS_RAM_L2       [281884:282033];
    reg [7:0] ACTIVATION_RAM_L2 [282034:282183];
    
    reg [7:0] NODE_RAM_L3      	[282184:282333];
    reg [7:0] WEIGHT_RAM_L3	[282334:283833];
    reg [7:0] BIAS_RAM_L3       [283834:283843];
    reg [7:0] ACTIVATION_RAM_L3 [283844:283853];
    
    reg [7:0] RESULT_NODE	[283854:283863];
    
    reg [7:0] MAX_VALUE;
    reg [18:0] MAX_INDEX;
    
    parameter IDLE	   = 4'b0000;
    parameter LOAD	   = 4'b0001;
    parameter READ_L1      = 4'b0010;
    parameter MAC_L1       = 4'b0011;
    parameter WRITE_L1     = 4'b0100;
    parameter READ_L2      = 4'b0101;
    parameter MAC_L2	   = 4'b0110;
    parameter WRITE_L2     = 4'b0111;
    parameter READ_L3      = 4'b1000;
    parameter MAC_L3	   = 4'b1001;
    parameter WRITE_L3     = 4'b1010;
    parameter RESULT	   = 4'b1011;
    
    
    always @(posedge clk or negedge reset_n)begin
        if (!reset_n)begin
            state               <= IDLE;
            data_counter        <= 19'b0;
            mul_counter		<= 10'b0;
            acc                 <= 16'b0;
            mac_counter         <= 10'b0;
            MAX_VALUE		<= 8'b0;
            MAX_INDEX		<= 19'd283854;
            
        end else begin
            state               <= next_state;
            data_counter        <= data_counter_next;
            mul_counter		<= mul_counter_next;
            acc                 <= acc_next;
            mac_counter         <= mac_counter_next;

        end
    end
    
    always @(*)begin
        next_state              = state;
        data_counter_next       = data_counter;
        mul_counter_next	= mul_counter;
        acc_next                = acc;
        mac_counter_next        = mac_counter;
        
        case(state)

	    IDLE:	begin
	    			if (mode == 1)begin			// Mode -1 for loading Weights and Biases for all layers.
	    				data_counter_next = 784;
	    				next_state = LOAD;
	    			end else if (mode == 2)begin		// Mode -2 for MLP Operation, accepting inputs and producing output.
	    				data_counter_next = 0;
	    				next_state = READ_L1;
	    			end
	    		end
	    LOAD:	begin
	    			if(incoming_data_valid && data_counter >= 784 && data_counter < 235984)begin
                        		WEIGHT_RAM_L1 [data_counter] = incoming_data;
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 235984 && data_counter < 236284)begin
                        		BIAS_RAM_L1 [data_counter] = incoming_data;
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 236284 && data_counter <= 236583)begin
                        		ACTIVATION_RAM_L1 [data_counter] = incoming_data;
                        		data_counter_next = data_counter + 1;
                        	end else if(incoming_data_valid && data_counter >= 236584 && data_counter < 281584)begin
                        		WEIGHT_RAM_L2 [(data_counter + 300)] = incoming_data;
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 281584 && data_counter < 281734)begin
                        		BIAS_RAM_L2 [(data_counter + 300)] = incoming_data;
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 281734 && data_counter <= 281883)begin
                        		ACTIVATION_RAM_L2 [(data_counter + 300)] = incoming_data;
                        		data_counter_next = data_counter + 1;
                        	end else if(incoming_data_valid && data_counter >= 281884 && data_counter < 283384)begin
                        		WEIGHT_RAM_L3 [(data_counter + 450)] = incoming_data;
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 283384 && data_counter < 283394)begin
                        		BIAS_RAM_L3 [(data_counter + 450)] = incoming_data;
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 283394 && data_counter <= 283403)begin
                        		ACTIVATION_RAM_L3 [(data_counter + 450)] = incoming_data;
                        		data_counter_next = 0;
                        		next_state = IDLE;
                        	end
	    		end
            READ_L1:   begin
                    if(incoming_data_valid && data_counter < 784)begin
                        NODE_RAM_L1 [data_counter] = incoming_data;
                        data_counter_next = data_counter + 1;
                    end else begin
                        acc_next = {8'b0, BIAS_RAM_L1[(data_counter + 235200)]};
                        next_state = MAC_L1;
                    end
                    end
            MAC_L1:     begin
                    if (mul_counter < 784)begin
                        for (i = 0; i < 784; i = i+1)begin
                            acc_next = acc + (NODE_RAM_L1[i]*WEIGHT_RAM_L1[(i+784) + (mac_counter*784)]);
                            mul_counter_next = mul_counter + 1;
                        end
                    end else begin
                        next_state = WRITE_L1;
                        mul_counter_next = 10'b0;
                        mac_counter_next = mac_counter + 1;
                    end
                    end
             WRITE_L1: begin
                    // Piecewise approximation of sigmoid function
                    if (acc < -6*1024) begin
                        NODE_RAM_L2[(data_counter + 235800)] = 8'd0;  // Sigmoid saturates to 0 for very negative inputs
                        data_counter_next = data_counter + 1;
                    end else if (acc < -3*1024) begin
                    // Linear approximation in range [-6, -3]
                        NODE_RAM_L2[(data_counter + 235800)] = 8'd10 + ((acc + 6*1024) >> 8);  // Slope and intercept tuned for accuracy
                        data_counter_next = data_counter + 1;
                    end else if (acc < 3*1024) begin
                     // Linear approximation in range [-3, 3]
                        NODE_RAM_L2[(data_counter + 235800)] = 8'd128 + (acc >> 9);  // Linear in the middle range
                        data_counter_next = data_counter + 1;
                    end else if (acc < 6*1024) begin
                     // Linear approximation in range [3, 6]
                        NODE_RAM_L2[(data_counter + 235800)] = 8'd245 + ((acc - 3*1024) >> 8);
                        data_counter_next = data_counter + 1;
                    end else begin
                        NODE_RAM_L2[(data_counter + 235800)]= 8'd255;  // Sigmoid saturates to 1 for very positive inputs
                        data_counter_next = data_counter + 1;
                    end
                    
                    if (mac_counter < 300)begin
			next_state = READ_L1;
                    end else begin
                        mac_counter_next = 10'b0;
                        data_counter_next = 236584;
                        next_state = READ_L2;   
                        end
                    end
             READ_L2 : begin
                    acc_next = {8'b0, BIAS_RAM_L2[(data_counter + 45300)]};
                    next_state = MAC_L2;
                    end
	     MAC_L2:     begin
                    if (mul_counter < 300)begin
                        for (i = 236584; i < 236884; i = i+1)begin
                            acc_next = acc + (NODE_RAM_L2[i]*WEIGHT_RAM_L2[((i+300)+(mac_counter*300))]);
                            mul_counter_next = mul_counter + 1;
                        end
                    end else begin
                        next_state = WRITE_L2;
                        mul_counter_next = 10'b0;
                        mac_counter_next = mac_counter + 1;
                    end
                    end
	     WRITE_L2: begin
                    // Piecewise approximation of sigmoid function
                    if (acc < -6*1024) begin
                        NODE_RAM_L3[(data_counter + 45600)] = 8'd0;  // Sigmoid saturates to 0 for very negative inputs
                        data_counter_next = data_counter + 1;
                    end else if (acc < -3*1024) begin
                    // Linear approximation in range [-6, -3]
                        NODE_RAM_L3[(data_counter + 45600)] = 8'd10 + ((acc + 6*1024) >> 8);  // Slope and intercept tuned for accuracy
                        data_counter_next = data_counter + 1;
                    end else if (acc < 3*1024) begin
                     // Linear approximation in range [-3, 3]
                        NODE_RAM_L3[(data_counter + 45600)] = 8'd128 + (acc >> 9);  // Linear in the middle range
                        data_counter_next = data_counter + 1;
                    end else if (acc < 6*1024) begin
                     // Linear approximation in range [3, 6]
                        NODE_RAM_L3[(data_counter + 45600)] = 8'd245 + ((acc - 3*1024) >> 8);
                        data_counter_next = data_counter + 1;
                    end else begin
                        NODE_RAM_L3[(data_counter + 45600)]= 8'd255;  // Sigmoid saturates to 1 for very positive inputs
                        data_counter_next = data_counter + 1;
                    end
                    
                    if (mac_counter < 150)begin
			next_state = READ_L2;
                    end else begin
                        mac_counter_next = 10'b0;
                        data_counter_next = 282184;
                        next_state = READ_L3;   
                        end
                    end
             READ_L3 : begin
                    	acc_next = {8'b0, BIAS_RAM_L3[(data_counter + 1650)]};
                    	next_state = MAC_L3;
                    end
	     MAC_L3:     begin
                    if (mul_counter < 150)begin
                        for (i = 282184; i < 282334; i = i+1)begin
                            acc_next = acc + (NODE_RAM_L3[i]*WEIGHT_RAM_L3[((i+150)+(mac_counter*150))]);
                            mul_counter_next = mul_counter + 1;
                        end
                    end else begin
                        next_state = WRITE_L3;
                        mac_counter_next = mac_counter + 1;
                    end
                    end
             WRITE_L3: begin
                    // Piecewise approximation of sigmoid function
                    if (acc < -6*1024) begin
                        RESULT_NODE[(data_counter + 1670)] = 8'd0;  // Sigmoid saturates to 0 for very negative inputs
                        data_counter_next = data_counter + 1;
                    end else if (acc < -3*1024) begin
                    // Linear approximation in range [-6, -3]
                        RESULT_NODE[(data_counter + 1670)] = 8'd10 + ((acc + 6*1024) >> 8);  // Slope and intercept tuned for accuracy
                        data_counter_next = data_counter + 1;
                    end else if (acc < 3*1024) begin
                     // Linear approximation in range [-3, 3]
                        RESULT_NODE[(data_counter + 1670)] = 8'd128 + (acc >> 9);  // Linear in the middle range
                        data_counter_next = data_counter + 1;
                    end else if (acc < 6*1024) begin
                     // Linear approximation in range [3, 6]
                        RESULT_NODE[(data_counter + 1670)] = 8'd245 + ((acc - 3*1024) >> 8);
                        data_counter_next = data_counter + 1;
                    end else begin
                        RESULT_NODE[(data_counter + 1670)]= 8'd255;  // Sigmoid saturates to 1 for very positive inputs
                        data_counter_next = data_counter + 1;
                    end
                    
                    if (mac_counter < 10)begin
			next_state = READ_L3;
                    end else begin
                        mac_counter_next = 10'b0;
                        data_counter_next = 0;
                        next_state = RESULT;   
                        end
                    end
        	RESULT: begin
        		// Loop through the memory array
        		if (data_counter <= 9)begin
        			for (i = 283854; i <= 283863; i = i + 1) begin
            				if (RESULT_NODE[i] > MAX_VALUE) begin
                				MAX_VALUE = RESULT_NODE[i];
                				MAX_INDEX = i;  // Update max_index to current index
                				data_counter_next = data_counter + 1;
            				end
        			end
        		end else if (MAX_INDEX == 283854)begin
        			result_data = 4'b0000;			// Character recognized as ZERO
        			result_data_valid = 1;
        			next_state = READ_L1;
        		end else if (MAX_INDEX == 283855)begin
        			result_data = 4'b0001;			// Character recognized as ONE
        			result_data_valid = 1;
        			next_state = READ_L1;
        		end else if (MAX_INDEX == 283856)begin
        			result_data = 4'b00010;			// Character recognized as TWO
        			result_data_valid = 1;
        			next_state = READ_L1;
        		end else if (MAX_INDEX == 283857)begin
        			result_data = 4'b0011;			// Character recognized as THREE
        			result_data_valid = 1;
        			next_state = READ_L1;
        		end else if (MAX_INDEX == 283858)begin
        			result_data = 4'b0100;			// Character recognized as FOUR
        			result_data_valid = 1;
        			next_state = READ_L1;
        		end else if (MAX_INDEX == 283859)begin
        			result_data = 4'b0101;			// Character recognized as FIVE
        			result_data_valid = 1;
        			next_state = READ_L1;
        		end else if (MAX_INDEX == 283860)begin
        			result_data = 4'b0110;			// Character recognized as SIX
        			result_data_valid = 1;
        			next_state = READ_L1;
        		end else if (MAX_INDEX == 283861)begin
        			result_data = 4'b0111;			// Character recognized as SEVEN
        			result_data_valid = 1;
        			next_state = READ_L1;
        		end else if (MAX_INDEX == 283862)begin
        			result_data = 4'b1000;			// Character recognized as EIGHT
        			result_data_valid = 1;
        			next_state = READ_L1;
        		end else begin
        			result_data = 4'b1001;			// Character recognized as NINE
        			result_data_valid = 1;
        			next_state = READ_L1;
        		end
        		
        		end
        	default:
			next_state = IDLE;
        endcase 
        end
endmodule
