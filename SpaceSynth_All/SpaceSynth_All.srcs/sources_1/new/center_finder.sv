module center_finder(input clk_in, input rst_in, //clock and reset
                     input [7:0] v_index_in,
                     input [8:0] h_index_in, 
                     input pixel_in,
                     output logic valid_out,
                     output logic [16:0] area_out,
                     output logic [7:0] v_index_out,
                     output logic [8:0] h_index_out);
    
    parameter MAX_V_IDX = 8'd239; // height of camera frame
    parameter MAX_H_IDX = 9'd0; // width of camera frame
    
    logic [7:0] v_index_in_prev;
    logic [8:0] h_index_in_prev;

    //Vars to hold index sum for averaging
    // Size is determined by max size of sum of indices
    // which equals n(n+1) / 2 *m where n = 319 
    // and m = 239 
    logic [23:0] h_sum;
    logic [23:0] v_sum;
    
    logic [16:0] num_pixels;
    logic divide_enable;
    
    logic [1:0] frame_state;
    
    logic [47:0] h_quotient;
    logic [47:0] v_quotient;
     
    localparam INITIALIZE = 0;
    localparam IDLE = 1;
    localparam NEWPIXEL = 2;
    localparam DONE = 3;  
    always_ff @(posedge clk_in)begin
        case(frame_state)
            INITIALIZE: begin 
                h_sum <= 24'd0;
                v_sum <= 24'd0;
                num_pixels <= 17'd0;
                divide_enable <= 1'd0;
                valid_out <= 1'd0;
                frame_state <= NEWPIXEL;
               end
            
            IDLE: begin 
                //If we get a new pixel...
                if ((v_index_in != v_index_in_prev) || (h_index_in != h_index_in_prev))begin
                    if (pixel_in)begin //...and it's part of the tracked object, count it!
                        frame_state <= NEWPIXEL;
                    end
                    else begin //otherwise, do nothing
                        divide_enable <= 1'b0;
                        v_index_in_prev <= v_index_in;
                        h_index_in_prev <= h_index_in;
                        
                        //Unless we reached the end of the frame, in which case jump to delivering the result
                        if (v_index_in == MAX_V_IDX && h_index_in == MAX_H_IDX)begin
                            divide_enable <= 1'b1;
                            frame_state <= DONE;
                        end 
                    end
                end
               end
               
            NEWPIXEL: begin 
                h_sum <= h_sum+h_index_in;
                v_sum <= v_sum+v_index_in;
                num_pixels <= num_pixels+17'd1;
                
                v_index_in_prev <= v_index_in;
                h_index_in_prev <= h_index_in;
                
                if (v_index_in == MAX_V_IDX && h_index_in == MAX_H_IDX)begin
                    divide_enable <= 1'b1;
                    frame_state <= DONE;
                end
                else begin
                    divide_enable <= 1'b0;
                    frame_state <= IDLE;
                end
                
               end
               
            DONE: begin //Wait for dividing to finish
                if (v_index_in == 0 && h_index_in == 0)begin
                    h_index_out <= h_quotient[32:24]; 
                    v_index_out <= v_quotient[31:24];
                    area_out <= num_pixels;
                    divide_enable <= 1'b1;
                    valid_out <= 1'd1;
                    
                    frame_state <= INITIALIZE;
                end            
               end
               
            default: frame_state <= INITIALIZE;
        endcase     
    end
    

    //26 clock cycles to divide
    average_divider r_div(
		.aclk(clk_in),
		.s_axis_dividend_tdata(h_sum),
		.s_axis_dividend_tvalid(divide_enable),
		.s_axis_divisor_tdata(num_pixels),
		.s_axis_divisor_tvalid(divide_enable),
		.m_axis_dout_tdata(h_quotient)         
		);
    average_divider c_div(
		.aclk(clk_in),
		.s_axis_dividend_tdata(v_sum),
		.s_axis_dividend_tvalid(divide_enable),
		.s_axis_divisor_tdata(num_pixels),
		.s_axis_divisor_tvalid(divide_enable),
		.m_axis_dout_tdata(v_quotient)         
		);

endmodule
