module camera_read(
	input  p_clock_in,
	input  vsync_in,
	input  href_in,
	input  [7:0] p_data_in,
	output logic [15:0] pixel_data_out,
	output logic pixel_valid_out,
	output logic frame_done_out,
	output logic [7:0] v_idx_out,
	output logic [8:0] h_idx_out,
	output logic [16:0] pixel_addr_out
    );
	 
	logic [1:0] FSM_state = 0;
    logic pixel_half = 0;
	
	localparam WAIT_FRAME_START = 0;
	localparam ROW_CAPTURE = 1;
	
	localparam DISPLAY_WIDTH  = 319; // width of camera frame
    localparam DISPLAY_HEIGHT = 239; // height of camera frame
    
	always_ff@(posedge p_clock_in) begin 
	
        case(FSM_state)
            WAIT_FRAME_START: begin //wait for VSYNC
               FSM_state <= (!vsync_in) ? ROW_CAPTURE : WAIT_FRAME_START;
               frame_done_out <= 0;
               pixel_half <= 0;
               v_idx_out <= 8'd0;
               h_idx_out <= 9'd0;
               pixel_addr_out <= 17'd0;
            end
            
            ROW_CAPTURE: begin 
               FSM_state <= vsync_in ? WAIT_FRAME_START : ROW_CAPTURE;
               frame_done_out <= vsync_in ? 1 : 0;
               
               //Every time we have a full pixel value
               if (href_in && pixel_half) begin
                pixel_valid_out <= 1;
                pixel_addr_out <= pixel_addr_out + 1;
                
                //Increment the horizontal and vertical index to match the location
                // of the current pixel in the frame  
                v_idx_out <= (h_idx_out == DISPLAY_WIDTH) ? v_idx_out + 1 : v_idx_out;
                h_idx_out <= (h_idx_out == DISPLAY_WIDTH) ? 0 : h_idx_out + 1;
               end
               else begin
                pixel_valid_out <= 0;
               end
               
               //collect pixel halves
               if (href_in) begin
                   pixel_half <= ~ pixel_half;
                   if (pixel_half) pixel_data_out[7:0] <= p_data_in;
                   else pixel_data_out[15:8] <= p_data_in;
               end
            end
            
        endcase
	
	end
	
endmodule