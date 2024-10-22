module controller(
    input wire clk,
    input wire reset_n,
    input wire [1:0] mode,
    input wire [7:0] incoming_data,
    input wire incoming_data_valid,
    
    output reg [7:0] data_in,
    output reg we,
    output reg [18:0] addr,
    
    input  wire [7:0] data_out,
    
    output reg [3:0] result_data,
    output reg result_data_valid
    );
    
    integer i;
    
    reg [4:0]   state, next_state;
    reg [18:0]  data_counter, data_counter_next;
    reg [15:0]  acc, acc_next;
    reg [9:0]   mac_counter, mac_counter_next;
    reg [7:0]   node, node_next;
    reg [7:0]   weight, weight_next;
    
    
    reg [7:0] MAX_VALUE, MAX_VALUE_NEXT;
    reg [18:0] MAX_INDEX, MAX_INDEX_NEXT;
    
    parameter IDLE          = 5'b00000;
    parameter LOAD          = 5'b00001;
    
    parameter READ_L1       = 5'b00010;
    parameter BIAS_L1       = 5'b00011;
    parameter NODE_L1       = 5'b00100;
    parameter WEIGHT_L1     = 5'b00101;
    parameter MAC_L1        = 5'b00110;
    parameter WRITE_L1      = 5'b00111;
       
    parameter READ_L2       = 5'b01000;
    parameter BIAS_L2       = 5'b01001;
    parameter NODE_L2       = 5'b01010;
    parameter WEIGHT_L2     = 5'b01011;
    parameter MAC_L2	    = 5'b01100;
    parameter WRITE_L2      = 5'b01101;
    
    parameter READ_L3       = 5'b01110;
    parameter BIAS_L3       = 5'b01111;
    parameter NODE_L3       = 5'b10000;
    parameter WEIGHT_L3     = 5'b10001;
    parameter MAC_L3	    = 5'b10010;
    parameter WRITE_L3      = 5'b10011;
    
    parameter CHECK         = 5'b10100;
    parameter RESULT	    = 5'b10101;
    
    
    always @(posedge clk or negedge reset_n)begin
        if (!reset_n)begin
            state               <= IDLE;
            data_counter        <= 19'b0;
            acc                 <= 16'b0;
            mac_counter         <= 10'b0;
            node                <= 8'b0;
            weight              <= 8'b0;
            MAX_VALUE           <= 8'b0;
            MAX_INDEX           <= 19'b0;
            
        end else begin
            state               <= next_state;
            data_counter        <= data_counter_next;
            acc                 <= acc_next;
            mac_counter         <= mac_counter_next;
            node                <= node_next;
            weight              <= weight_next;
            MAX_VALUE           <= MAX_VALUE_NEXT;
            MAX_INDEX           <= MAX_INDEX_NEXT;
        end
    end
    
    always @(incoming_data_valid, state, mode, data_counter)begin
        next_state              = state;
        data_counter_next       = data_counter;
        acc_next                = acc;
        mac_counter_next        = mac_counter;
        node_next               = node;
        weight_next             = weight;
        MAX_VALUE_NEXT          = MAX_VALUE;
        MAX_INDEX_NEXT          = MAX_INDEX;
        we                      = 1'b0;
        data_in                 = 8'b0;
        addr                    = 19'b0;
        result_data             = 4'b0000;			
        result_data_valid       = 1'b0;
        
        
        case(state)

	    IDLE:	begin
	    			if (mode == 2'b01)begin			// Mode -1 for loading Weights and Biases for all layers.
	    				data_counter_next = 784;
	    				next_state = LOAD;
	    			end else if (mode == 2'b10)begin		// Mode -2 for MLP Operation, accepting inputs and producing output.
	    				data_counter_next = 0;
	    				next_state = READ_L1;
	    			end else
	    			    data_counter_next = 0;
	    		end
	    LOAD:	begin
	    			if(incoming_data_valid && data_counter >= 784 && data_counter < 235984)begin
                        		data_in = incoming_data;
                        		we = 1'b1;
                        		addr = data_counter;
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 235984 && data_counter < 236284)begin
                        		data_in = incoming_data;
                        		we = 1'b1;
                        		addr = data_counter;
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 236284 && data_counter <= 236583)begin
                        		data_in = incoming_data;
                        		we = 1'b1;
                        		addr = data_counter;
                        		data_counter_next = data_counter + 1;
                        	end else if(incoming_data_valid && data_counter >= 236584 && data_counter < 281584)begin
                        		data_in = incoming_data;
                        		we = 1'b1;
                        		addr = data_counter; 
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 281584 && data_counter < 281734)begin
                        		data_in = incoming_data;
                        		we = 1'b1;
                        		addr = data_counter;
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 281734 && data_counter <= 281883)begin
                        		data_in = incoming_data;
                        		we = 1'b1;
                        		addr = data_counter;
                        		data_counter_next = data_counter + 1;
                        	end else if(incoming_data_valid && data_counter >= 281884 && data_counter < 283384)begin
                        		data_in = incoming_data;
                        		we = 1'b1;
                        		addr = data_counter;
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 283384 && data_counter < 283394)begin
                        		data_in = incoming_data;
                        		we = 1'b1;
                        		addr = data_counter;
                        		data_counter_next = data_counter + 1;
                    		end else if (incoming_data_valid && data_counter >= 283394 && data_counter <= 283403)begin
                        		data_in = incoming_data;
                        		we = 1'b1;
                        		addr = data_counter;
                        		data_counter_next = data_counter + 1;
                            end else begin
                        		data_counter_next = 0;
                        		next_state = IDLE;
                        	end 
                         	
	    		end
            READ_L1:   begin
                    if(incoming_data_valid && data_counter < 784)begin
                        data_in = incoming_data;
                        we = 1'b1;
                        addr = data_counter;
                        data_counter_next = data_counter + 1;
                    end else begin
                        data_counter_next = 19'b0;
                        addr = data_counter + mac_counter + 235200;
                        next_state = BIAS_L1;
                    end
                    end
            BIAS_L1:    begin
                        acc_next = {8'b0, data_out};                        // From previous state address
                        addr = data_counter;
                        next_state = NODE_L1;
                        end
            NODE_L1:    begin
                        node = data_out;                                    // From previous state address
                        addr = (data_counter + 784) + (mac_counter*784);
                        next_state = WEIGHT_L1;                       
                        end
            WEIGHT_L1:  begin
                        weight = data_out;                                  // From previous state address
                        next_state = MAC_L1;
                        end
            
            MAC_L1:     begin
                    if (data_counter < 784)begin
                            acc_next = acc + (node*weight);
                            data_counter_next = data_counter + 1;
                            addr = data_counter + 1;
                            next_state = NODE_L1;
                    end else begin
                        next_state = WRITE_L1;
                        mac_counter_next = mac_counter + 1;
                    end
                    end
             WRITE_L1: begin
                    // Piecewise approximation of sigmoid function
                    if (acc < -6*1024) begin
//                        NODE_RAM_L2[(data_counter + 235800)] = 8'd0;  // Sigmoid saturates to 0 for very negative inputs
                        data_counter_next = 19'b0;
                        addr = data_counter + mac_counter + 235800;
                        data_in = 8'b0;
                        we = 1'b1;
                    end else if (acc < -3*1024) begin
                    // Linear approximation in range [-6, -3]
//                        NODE_RAM_L2[(data_counter + 235800)] = 8'd10 + ((acc + 6*1024) >> 8);  // Slope and intercept tuned for accuracy
                        data_counter_next = 19'b0;
                        addr = data_counter + mac_counter + 235800;
                        data_in = 8'd10 + ((acc + 6*1024) >> 8);
                        we = 1'b1;
                    end else if (acc < 3*1024) begin
                     // Linear approximation in range [-3, 3]
//                        NODE_RAM_L2[(data_counter + 235800)] = 8'd128 + (acc >> 9);  // Linear in the middle range
                        data_counter_next = 19'b0;
                        addr = data_counter + mac_counter + 235800;
                        data_in = 8'd128 + (acc >> 9);
                        we = 1'b1;
                    end else if (acc < 6*1024) begin
                     // Linear approximation in range [3, 6]
//                        NODE_RAM_L2[(data_counter + 235800)] = 8'd245 + ((acc - 3*1024) >> 8);
                        data_counter_next = 19'b0;
                        addr = data_counter + mac_counter + 235800;
                        data_in = 8'd245 + ((acc - 3*1024) >> 8);
                        we = 1'b1;
                    end else begin
//                        NODE_RAM_L2[(data_counter + 235800)]= 8'd255;  // Sigmoid saturates to 1 for very positive inputs
                        data_counter_next = 19'b0;
                        addr = data_counter + mac_counter + 235800;
                        data_in = 8'd255;
                        we = 1'b1;
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
//                    acc_next = {8'b0, BIAS_RAM_L2[(data_counter + 45300)]};
//                    next_state = MAC_L2;
                        addr = data_counter + mac_counter + 45300;
                        next_state = BIAS_L2;
                        end
             BIAS_L2:   begin
                        acc_next = {8'b0, data_out};                        // From previous state address
                        addr = data_counter;
                        next_state = NODE_L2;
                        end
            NODE_L2:    begin
                        node = data_out;                                    // From previous state address
                        addr = (data_counter + 300) + (mac_counter*300);
                        next_state = WEIGHT_L2;                       
                        end
            WEIGHT_L2:  begin
                        weight = data_out;                                  // From previous state address
                        next_state = MAC_L2;
                        end
	        MAC_L2:     begin
                        if (data_counter < 236884)begin
                            acc_next = acc + (node*weight);
                            data_counter_next = data_counter + 1;
                            addr = data_counter + 1;
                            next_state = NODE_L2;
                        end else begin
                            next_state = WRITE_L2;
                            mac_counter_next = mac_counter + 1;
                        end
                        end
	        WRITE_L2: begin
                    // Piecewise approximation of sigmoid function
                    if (acc < -6*1024) begin
//                        NODE_RAM_L3[(data_counter + 45600)] = 8'd0;  // Sigmoid saturates to 0 for very negative inputs
                        data_counter_next = 236584;
                        addr = data_counter + mac_counter + 45300;
                        data_in = 8'b0;
                        we = 1'b1;
                    end else if (acc < -3*1024) begin
                    // Linear approximation in range [-6, -3]
//                        NODE_RAM_L3[(data_counter + 45600)] = 8'd10 + ((acc + 6*1024) >> 8);  // Slope and intercept tuned for accuracy
                        data_counter_next = 236584;
                        addr = data_counter + mac_counter + 45300;
                        data_in = 8'd10 + ((acc + 6*1024) >> 8);
                        we = 1'b1;
                    end else if (acc < 3*1024) begin
                     // Linear approximation in range [-3, 3]
//                        NODE_RAM_L3[(data_counter + 45600)] = 8'd128 + (acc >> 9);  // Linear in the middle range
                        data_counter_next = 236584;
                        addr = data_counter + mac_counter + 45300;
                        data_in = 8'd128 + (acc >> 9);
                        we = 1'b1;
                    end else if (acc < 6*1024) begin
                     // Linear approximation in range [3, 6]
//                        NODE_RAM_L3[(data_counter + 45600)] = 8'd245 + ((acc - 3*1024) >> 8);
                        data_counter_next = 236584;
                        addr = data_counter + mac_counter + 45300;
                        data_in = 8'd245 + ((acc - 3*1024) >> 8);
                        we = 1'b1;
                    end else begin
//                        NODE_RAM_L3[(data_counter + 45600)]= 8'd255;  // Sigmoid saturates to 1 for very positive inputs
                        data_counter_next = 236584;
                        addr = data_counter + mac_counter + 45300;
                        data_in = 8'd255;
                        we = 1'b1;
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
                    	addr = data_counter + mac_counter + 1650;
                        next_state = BIAS_L3;
                    end
             BIAS_L3:   begin
                        acc_next = {8'b0, data_out};                        // From previous state address
                        addr = data_counter;
                        next_state = NODE_L3;
                        end
            NODE_L3:    begin
                        node = data_out;                                    // From previous state address
                        addr = (data_counter + 150) + (mac_counter*150);
                        next_state = WEIGHT_L3;                       
                        end
            WEIGHT_L3:  begin
                        weight = data_out;                                  // From previous state address
                        next_state = MAC_L3;
                        end
	        MAC_L3:     begin
                        if (data_counter < 282334)begin
                            acc_next = acc + (node*weight);
                            data_counter_next = data_counter + 1;
                            addr = data_counter + 1;
                            next_state = NODE_L3;
                        end else begin
                            next_state = WRITE_L3;
                            mac_counter_next = mac_counter + 1;
                        end
                        end
              WRITE_L3: begin
                    // Piecewise approximation of sigmoid function
                    if (acc < -6*1024) begin
//                        RESULT_NODE[(data_counter + 1670)] = 8'd0;  // Sigmoid saturates to 0 for very negative inputs
                        data_counter_next = 282184;
                        addr = data_counter + mac_counter + 1520;
                        data_in = 8'b0;
                        we = 1'b1;
                    end else if (acc < -3*1024) begin
                    // Linear approximation in range [-6, -3]
//                        RESULT_NODE[(data_counter + 1670)] = 8'd10 + ((acc + 6*1024) >> 8);  // Slope and intercept tuned for accuracy
                        data_counter_next = 282184;
                        addr = data_counter + mac_counter + 1520;
                        data_in = 8'd10 + ((acc + 6*1024) >> 8);
                        we = 1'b1;
                    end else if (acc < 3*1024) begin
                     // Linear approximation in range [-3, 3]
//                        RESULT_NODE[(data_counter + 1670)] = 8'd128 + (acc >> 9);  // Linear in the middle range
                        data_counter_next = 282184;
                        addr = data_counter + mac_counter + 1520;
                        data_in = 8'd128 + (acc >> 9);
                        we = 1'b1;
                    end else if (acc < 6*1024) begin
                     // Linear approximation in range [3, 6]
//                        RESULT_NODE[(data_counter + 1670)] = 8'd245 + ((acc - 3*1024) >> 8);
                        data_counter_next = 282184;
                        addr = data_counter + mac_counter + 1520;
                        data_in = 8'd245 + ((acc - 3*1024) >> 8);
                        we = 1'b1;
                    end else begin
//                        RESULT_NODE[(data_counter + 1670)]= 8'd255;  // Sigmoid saturates to 1 for very positive inputs
                        data_counter_next = 282184;
                        addr = data_counter + mac_counter + 1520;
                        data_in = 8'd255;
                        we = 1'b1;
                    end
                    
                    if (mac_counter < 10)begin
			            next_state = READ_L3;
                    end else begin
                        data_counter_next = 283854;
                        addr = data_counter + 1520;
                        next_state = RESULT;   
                        end
                    end
            CHECK:  begin
                    addr = data_counter;
                    next_state = RESULT;
                    end
        	RESULT: begin
        		// Loop through the memory array
        		if (data_counter < 283864)begin
            		if (data_out > MAX_VALUE) begin
                			MAX_VALUE_NEXT = data_out;
                			MAX_INDEX_NEXT = data_counter;  // Update max_index to current index
                			data_counter_next = data_counter + 1;
                			next_state = CHECK;
        			end
        		end else begin 
        		if (MAX_INDEX == 283854)begin
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
        		end else if (MAX_INDEX == 283863)begin
        			result_data = 4'b1001;			// Character recognized as NINE
        			result_data_valid = 1;
        			next_state = READ_L1;
        		end else begin
        		    result_data_valid = 0;
        		    result_data = 4'b0000;
        		    end        		
        		end
            end
        	default:
			next_state = IDLE;
        endcase 
        end
endmodule
