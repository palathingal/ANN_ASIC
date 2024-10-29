module controller(
    input wire clk,
    input wire reset_n,
    input wire [1:0] mode,
    input wire [7:0] incoming_data,
    input wire incoming_data_valid,
    
    output reg [7:0] data_in_w,
    output reg [7:0] data_in_n,
    output reg [7:0] data_in_b,
    output reg [7:0] data_in_p1,
    output reg [7:0] data_in_p2,
    output reg we_w,
    output reg we_n,
    output reg we_b,
    output reg we_p1,
    output reg we_p2,
    output wire [18:0] addr_w,
    output wire [9:0] addr_n,
    output wire [9:0] addr_b,
    output wire [9:0] addr_p1,
    output wire [9:0] addr_p2,
    
    input  wire [7:0] data_out_w,
    input  wire [7:0] data_out_n,
    input  wire [7:0] data_out_b,
    input  wire [7:0] data_out_p1,
    input  wire [7:0] data_out_p2,
    
    output reg [3:0] result_data
    );
    
    integer i;
    
    reg [4:0]   state, next_state;
    reg [18:0]  w_counter, w_counter_next;
    reg [9:0]   b_counter, b_counter_next;
    reg [9:0]   n_counter, n_counter_next;  
    reg [9:0]   p1_counter, p1_counter_next;
    reg [9:0]   p2_counter, p2_counter_next;
    reg [9:0]   r_counter, r_counter_next;
    reg [15:0]  acc, acc_next;
    reg [9:0]   mac_counter, mac_counter_next;
    reg [7:0]   node, node_next;
    reg [7:0]   weight, weight_next;
    
    
    reg [7:0] result_reg, result_reg_next;
    
    reg [7:0] MAX_VALUE, MAX_VALUE_NEXT;
    reg [9:0] MAX_INDEX, MAX_INDEX_NEXT;
    
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
    
    parameter WAIT1         = 5'b10110;
    parameter WAIT2         = 5'b10111;
    parameter WAIT3         = 5'b11000;
    parameter WAIT4         = 5'b11001;
    parameter WAIT5         = 5'b11010;
    parameter WAIT6         = 5'b11011;
    
    
    assign addr_n = n_counter;
    assign addr_w = w_counter;
    assign addr_b = b_counter;
    assign addr_p1 = p1_counter;
    assign addr_p2 = p2_counter;
    
    
    always @(posedge clk or negedge reset_n)begin
        if (!reset_n)begin
            state               <= IDLE;
            w_counter           <= 19'b0;
            b_counter           <= 10'b0;
            n_counter           <= 10'b0;
            p1_counter          <= 10'b0;
            p2_counter          <= 10'b0;
            r_counter           <= 10'b0;
            acc                 <= 16'b0;
            mac_counter         <= 10'b0;
            node                <= 8'b0;
            weight              <= 8'b0;
            MAX_VALUE           <= 8'b0;
            MAX_INDEX           <= 10'b0;
            result_reg          <= 8'b0;
            
        end else begin
            state               <= next_state;
            w_counter           <= w_counter_next;
            b_counter           <= b_counter_next;
            n_counter           <= n_counter_next;
            p1_counter          <= p1_counter_next;
            p2_counter          <= p2_counter_next;
            r_counter           <= r_counter_next;
            acc                 <= acc_next;
            mac_counter         <= mac_counter_next;
            node                <= node_next;
            weight              <= weight_next;
            MAX_VALUE           <= MAX_VALUE_NEXT;
            MAX_INDEX           <= MAX_INDEX_NEXT;
            result_reg          <= result_reg_next;
        end
    end
    
    always @(incoming_data_valid, state, mode, n_counter)begin
        next_state              = state;
        w_counter_next          = w_counter;
        b_counter_next          = b_counter;
        n_counter_next          = n_counter;
        p1_counter_next          = p1_counter;
        p2_counter_next         = p2_counter;
        r_counter_next          = r_counter;
        acc_next                = acc;
        mac_counter_next        = mac_counter;
        node_next               = node;
        weight_next             = weight;
        MAX_VALUE_NEXT          = MAX_VALUE;
        MAX_INDEX_NEXT          = MAX_INDEX;
        result_reg_next         = result_reg;
        we_w                    = 1'b0;
        we_n                    = 1'b0;
        we_b                    = 1'b0;
        we_p1                   = 1'b0;
        we_p2                   = 1'b0;
        data_in_w               = 8'b0;
        data_in_n               = 8'b0;
        data_in_b               = 8'b0;
        data_in_p1              = 8'b0;
        data_in_p2              = 8'b0;
//        addr                    = 19'b0;
//        result_data             = 4'b0000;			
        
        
        case(state)

	    IDLE:	begin
	    			if (mode == 2'b01)begin			        // Mode -1 for loading Weights.
	    				w_counter_next = 0;
	    				next_state = LOAD;
	    			end else if (mode == 2'b10)begin		// Mode -2 for loading Biases.
	    				b_counter_next = 0;
	    				next_state = LOAD;
	    			end else if (mode == 2'b11)begin        // Mode -2 for MLP Operation.
	    			    n_counter_next = 0;
	    			    b_counter_next = 0;
	    			    w_counter_next = 0;
	    			    p1_counter_next = 0;
	    			    p2_counter_next = 0;
	    				next_state = READ_L1;
	    			end 
	    		end
	    LOAD:	begin
	    			if(w_counter < 281700 && mode == 2'b01)begin
                        	if(incoming_data_valid)begin
                        		data_in_w = incoming_data;
                        		we_w = 1'b1;
                        		w_counter_next = w_counter + 1;
                    		end 
                    end else if (b_counter < 460 && mode == 2'b10)begin
                            if(incoming_data_valid)begin
                        		data_in_b = incoming_data;
                        		we_b = 1'b1;
                        		b_counter_next = b_counter + 1;
                    		end 
                    end else begin
                        next_state = IDLE;
                    end
                         	
	    		end
            READ_L1:   begin
                    if(n_counter < 784)begin
                        if(incoming_data_valid)begin
                            data_in_n = incoming_data;
                            we_n = 1'b1;
                            n_counter_next = n_counter + 1;
                        end
                    end else begin
                        n_counter_next = 0;
                        next_state = BIAS_L1;
                    end
                    end
                    
            WAIT1:  begin
                    next_state = BIAS_L1;
                    
                    end 
            BIAS_L1 : begin
                    acc_next = {8'b0, data_out_b};
                    next_state = WAIT2;
                    end
       
            WAIT2:  begin
                    next_state = NODE_L1;
                    
                    end        
            
                        
            NODE_L1: begin
//                   addr = (data_counter + 784) + (mac_counter*784); 
                   weight_next = data_out_w;
                   node_next = data_out_n;
                   next_state = MAC_L1;
                   w_counter_next = w_counter + 1;
                   end            
                        
          
                        
            
            MAC_L1:     begin
                    if (n_counter < 784)begin
                            acc_next = acc + (node*weight);
                            
                            n_counter_next = n_counter + 1;
                            next_state = WEIGHT_L1;
                    end else begin
                        next_state = WRITE_L1;
                        mac_counter_next = mac_counter + 1;
                        n_counter_next = 0;
			            b_counter_next = b_counter + 1;
			            w_counter_next = w_counter - 1;
                    end
                    end
                    
            WEIGHT_L1: begin
                        next_state = WAIT2;
                        
                        end
                    
             WRITE_L1: begin
                    // Piecewise approximation of sigmoid function
                    if (acc < -6*1024) begin
                    // Sigmoid saturates to 0 for very negative inputs
                        data_in_p1 = 8'b0;
                        we_p1 = 1'b1;
                    end else if (acc < -3*1024) begin
                    // Linear approximation in range [-6, -3] // Slope and intercept tuned for accuracy
                        
                        data_in_p1 = 8'd10 + ((acc + 6*1024) >> 8);
                        we_p1 = 1'b1;
                    end else if (acc < 3*1024) begin
                     // Linear approximation in range [-3, 3]// Linear in the middle range
                        
                        data_in_p1 = 8'd128 + (acc >> 9);
                        we_p1 = 1'b1;
                    end else if (acc < 6*1024) begin
                     // Linear approximation in range [3, 6]
                        data_in_p1 = 8'd245 + ((acc - 3*1024) >> 8);
                        we_p1 = 1'b1;
                    end else begin
                     // Sigmoid saturates to 1 for very positive inputs
                        
                        data_in_p1 = 8'd255;
                        we_p1 = 1'b1;
                    end
                    
                    if (mac_counter < 300)begin
			             next_state = WAIT1;
			             
			             p1_counter_next = p1_counter + 1;
                    end else begin
                        mac_counter_next = 10'b0;
                        b_counter_next = 300;
                        p1_counter_next = 0;
                        w_counter_next = 235200;
                        next_state = WAIT3;   
                        end
                    end
             WAIT3 : begin             
                        next_state = BIAS_L2;
                        end
             BIAS_L2:   begin
                        acc_next = {8'b0, data_out_b};                        // From previous state address
                        next_state = WAIT4;
                        end
            WAIT4 : begin
                    next_state = NODE_L2;
                     
                    end
            
            
            NODE_L2:    begin
                        node_next = data_out_p1;                                    // From previous state address
                        weight_next = data_out_w;                                 // From previous state address
                        w_counter_next = w_counter + 1;
                        next_state = MAC_L2;                       
                        end
            
	        MAC_L2:     begin
                        if (p1_counter < 300)begin
                            acc_next = acc + (node*weight);

                            p1_counter_next = p1_counter + 1;
                            next_state = WEIGHT_L2;
                        end else begin
                            next_state = WRITE_L2;
                            mac_counter_next = mac_counter + 1;
                            p1_counter_next = 0;
			                b_counter_next = b_counter + 1;
			                w_counter_next = w_counter - 1;
                        end
                        end
                        
            WEIGHT_L2: begin            
                        next_state = WAIT4;
                       end 
	        WRITE_L2: begin
                    // Piecewise approximation of sigmoid function
                    if (acc < -6*1024) begin
                        data_in_p2 = 8'b0;
                        we_p2 = 1'b1;
                    end else if (acc < -3*1024) begin
                    // Linear approximation in range [-6, -3]
                        data_in_p2 = 8'd10 + ((acc + 6*1024) >> 8);
                        we_p2 = 1'b1;
                    end else if (acc < 3*1024) begin
                     // Linear approximation in range [-3, 3]
                        data_in_p2 = 8'd128 + (acc >> 9);
                        we_p2 = 1'b1;
                    end else if (acc < 6*1024) begin
                     // Linear approximation in range [3, 6]
                        data_in_p2 = 8'd245 + ((acc - 3*1024) >> 8);
                        we_p2 = 1'b1;
                    end else begin
                        data_in_p2 = 8'd255;
                        we_p2 = 1'b1;
                    end
                    
                    if (mac_counter < 150)begin
			            next_state = WAIT3;
			            
			            p2_counter_next = p2_counter + 1;
			            
                    end else begin
                        mac_counter_next = 10'b0;
                        b_counter_next = 450;
                        p2_counter_next = 0;
                        w_counter_next = 280200;
                        next_state = WAIT5;   
                        end
                    end
             WAIT5 : begin
                        next_state = BIAS_L3;
                    end
             BIAS_L3:   begin
                        acc_next = {8'b0, data_out_b};                        // From previous state address
                        next_state = WAIT6;
                        end
            WAIT6:    begin
                        
                        next_state = NODE_L3;                       
                        end
            NODE_L3:  begin
                        node_next = data_out_p2;                                    // From previous state address
                        weight_next = data_out_w;                                  // From previous state address
                        next_state = MAC_L3;
                        w_counter_next = w_counter + 1;
                        end
	        MAC_L3:     begin
                        if (p2_counter < 150)begin
                            acc_next = acc + (node*weight);
                            
                            p2_counter_next = p2_counter + 1;
                            next_state = WEIGHT_L3;
                        end else begin
                            next_state = WRITE_L3;
                            mac_counter_next = mac_counter + 1;
                            b_counter_next = b_counter + 1;
                            p2_counter_next = 0;
                            w_counter_next = w_counter - 1;
                        end
                        end
              WEIGHT_L3: begin
                         next_state = WAIT6;
                         
                         end
              WRITE_L3: begin
                    // Piecewise approximation of sigmoid function
                    if (acc < -6*1024) begin
                        result_reg_next = 8'b0;
                    end else if (acc < -3*1024) begin
                        result_reg_next = 8'd10 + ((acc + 6*1024) >> 8);
                    end else if (acc < 3*1024) begin
                        result_reg_next = 8'd128 + (acc >> 9);
                    end else if (acc < 6*1024) begin
                        result_reg_next = 8'd245 + ((acc - 3*1024) >> 8);
                    end else begin
                        result_reg_next = 8'd255;
                    end
                    
                    next_state = RESULT;
                    r_counter_next = r_counter + 1;
                    end
            
        	RESULT: begin
        		// Loop through the memory array
        		if (r_counter < 10)begin
            		if (result_reg > MAX_VALUE) begin
                			MAX_VALUE_NEXT = result_reg;
                			MAX_INDEX_NEXT = r_counter;  // Update max_index to current index	
        			end
        			next_state = WAIT5;
        		end else begin 
        		r_counter_next = 0;
        		if (MAX_INDEX == 0)begin
        			result_data = 4'b1111;			// Character recognized as ZERO

        			next_state = READ_L1;
        		end else if (MAX_INDEX == 1)begin
        			result_data = 4'b0001;			// Character recognized as ONE

        			next_state = READ_L1;
        		end else if (MAX_INDEX == 2)begin
        			result_data = 4'b00010;			// Character recognized as TWO

        			next_state = READ_L1;
        		end else if (MAX_INDEX == 3)begin
        			result_data = 4'b0011;			// Character recognized as THREE

        			next_state = READ_L1;
        		end else if (MAX_INDEX == 4)begin
        			result_data = 4'b0100;			// Character recognized as FOUR

        			next_state = READ_L1;
        		end else if (MAX_INDEX == 5)begin
        			result_data = 4'b0101;			// Character recognized as FIVE

        			next_state = READ_L1;
        		end else if (MAX_INDEX == 6)begin
        			result_data = 4'b0110;			// Character recognized as SIX

        			next_state = READ_L1;
        		end else if (MAX_INDEX == 7)begin
        			result_data = 4'b0111;			// Character recognized as SEVEN

        			next_state = READ_L1;
        		end else if (MAX_INDEX == 8)begin
        			result_data = 4'b1000;			// Character recognized as EIGHT

        			next_state = READ_L1;
        		end else if (MAX_INDEX == 9)begin
        			result_data = 4'b1001;			// Character recognized as NINE

        			next_state = READ_L1;
        		end else begin
                    next_state = READ_L1;
        		    result_data = 4'b0000;
        		    end        		
        		end
            end
        	default:
			next_state = IDLE;
        endcase 
        end
endmodule
