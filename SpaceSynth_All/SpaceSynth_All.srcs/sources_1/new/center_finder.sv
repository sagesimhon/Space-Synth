module center_finder(input clk_in, input rst_in, //clock and reset
                     input [7:0] v_index_in,
                     input [8:0] h_index_in, 
                     input pixel_in,
                     output logic valid_out,
                     output logic [16:0] area_out,
                     output logic [7:0] v_index_out,
                     output logic [8:0] h_index_out);
    
    parameter MAX_V_IDX = 8'd239; // height of camera frame
    parameter MAX_H_IDX = 9'd319; // width of camera frame
    
    logic [7:0] v_index_in_prev;
    logic [8:0] h_index_in_prev;

    logic [1:0] frame_state;
    
    logic [16:0] array_count;
    logic [16:0] pixel_index_data;
    logic [16:0] center_indeces;
    
    //Setup BRAM for storing pixel indices
    logic write_enable;
    blk_mem_gen_0 index_bram(.addra(array_count), 
                             .clka(clk_in), //camera's clock signal 
                             .dina(pixel_index_data),
                             .wea(write_enable),
                             .douta(center_indeces));
     
    localparam INITIALIZE = 0;
    localparam IDLE = 1;
    localparam NEWPIXEL = 2;
    localparam DONE = 3;  
    always_ff @(posedge clk_in)begin
        case(frame_state)
            INITIALIZE: begin //Zero everything at beginning of frame
                valid_out <= 1'b0;
                area_out <= 17'd0;
                array_count <= 17'd0;
                write_enable <= 1'b1;
                frame_state <= NEWPIXEL;
               end
            
            IDLE: begin //Sit around until something interesting happens
                //If we get a new pixel...
                if ((v_index_in != v_index_in_prev) || (h_index_in != h_index_in_prev))begin
                    if (pixel_in)begin //...and it's part of the mask, count it!
                        write_enable <= 1'b1; //Enable writing to BRAM
                        frame_state <= NEWPIXEL;
                    end
                    else begin //otherwise, do nothing
                        write_enable <= 1'b0;
                        v_index_in_prev <= v_index_in;
                        h_index_in_prev <= h_index_in;
                        
                        //Unless we reached the end of the frame, in which case jump to delivering the result
                        frame_state <= (v_index_in == MAX_V_IDX && h_index_in == MAX_H_IDX)?DONE:IDLE;
                    end
                end
                //If we dont get a new pixel, don't do anything
                else begin
                    frame_state <= IDLE;
                    write_enable <= 1'b0;
                end
               end
               
            NEWPIXEL: begin //Runs just once every time we have a new pixel
                area_out <= area_out + pixel_in; //Add pixel to area count
                
                //Put vertical and horizontal indices into BRAM
                pixel_index_data <= {v_index_in,h_index_in}; 
               
                v_index_in_prev <= v_index_in;
                h_index_in_prev <= h_index_in;
                write_enable <= 1'b0; //Disable writing to BRAM
                
                //If we reached the end of the frame, jump to delivering the result
                if (v_index_in == MAX_V_IDX && h_index_in == MAX_H_IDX)begin
                    array_count <= array_count>>1; //Set BRAM index to median
                    frame_state <= DONE;
                end
                //Otherwise go back to idle
                else begin
                    array_count <= array_count + 17'd1; //Keep track of how many entries in BRAM
                    frame_state <= IDLE;
                end 
               end
               
            DONE: begin //Delivers the result of the center
                //Pull horizontal and verical index of median pixel out of BRAM
                v_index_out <= center_indeces[16:9];
                h_index_out <= center_indeces[8:0];
                
                //Signal calculation is done
                valid_out <= 1'b1;
                
                //Reset the FSM when the new frame begins
                frame_state <= (v_index_in == 0 && h_index_in == 0)?INITIALIZE:DONE;                       
               end
               
            default: frame_state <= INITIALIZE;
        endcase     
    end
    
//    ila_0 my_ila(.clk(clk_in),     
//                                .probe0(v_index_in), 
//                                .probe1(h_index_in),
//                                .probe2(frame_state),
//                                .probe3(write_enable),
//                                .probe4(v_index_out));
        
endmodule
