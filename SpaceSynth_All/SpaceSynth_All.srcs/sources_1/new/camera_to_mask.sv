`timescale 1ns / 1ps

module camera_to_mask(
   input clk_65mhz,
   
   input logic reset, 
   
   input logic [15:0] sw,
   
   input logic [7:0] ja_p, //pixel data from camera
   input logic [2:0] jb_p, //other data from camera (including clock return)
   input logic [2:0] jd_p,
   output logic  jbclk_p, //clock FPGA drives the camera with
   output logic  jdclk_p,

   input logic [10:0] hcount,//vga pixel on current line
   input logic [9:0] vcount, //vga line number

   output logic [11:0] raw_image_buff_out, 
   input logic [16:0] raw_image_output_pixel_addr,
   output logic [11:0] red_buff_out,
   input logic [16:0] red_buff_output_pixel_addr, 
   output logic [11:0] blue_buff_out, 
   input logic [16:0] blue_buff_output_pixel_addr,
   
   output logic red_center_valid,
   output logic [16:0] red_area_out,
   output logic [7:0] red_center_v_index_out,
   output logic [8:0] red_center_h_index_out,
   
   output logic blue_center_valid,
   output logic [16:0] blue_area_out,
   output logic [7:0] blue_center_v_index_out,
   output logic [8:0] blue_center_h_index_out
   );
 
    logic xclk;
    logic[1:0] xclk_count;
    
    logic pclk_buff, pclk_in;
    logic vsync_buff, vsync_in;
    logic href_buff, href_in;
    logic [7:0] pixel_buff, pixel_in;
    
    logic red_mask_buff_out; 
    logic blue_mask_buff_out;
    logic [15:0] output_pixels;
    logic red_processed_pixels;
    logic blue_processed_pixels;
    logic [11:0] raw_image_pixels;
    logic [3:0] red_diff;
    logic [3:0] green_diff;
    logic [3:0] blue_diff;
    logic [7:0] h;
    logic [7:0] s;
    logic [7:0] v;
    
    logic valid_pixel;
    logic frame_done_out;
    logic [7:0] v_idx_out;
    logic [8:0] h_idx_out;
    
    logic [16:0] bram_input_pixel_addr;
    
    //clock signal from FPGA to camera module
    assign xclk = (xclk_count >2'b01); // 25% speed of 65 mhz clock
    assign jbclk_p = xclk; // drives camera
    assign jdclk_p = xclk;
    
    
    always_ff @(posedge clk_65mhz) begin
        //Recieve pixels from camera and synchronize w/ buffers
        pclk_buff <= jb_p[0];
        vsync_buff <= jb_p[1]; 
        href_buff <= jb_p[2]; 
        pixel_buff <= ja_p;
        pclk_in <= pclk_buff;
        vsync_in <= vsync_buff;
        href_in <= href_buff;
        pixel_in <= pixel_buff;
        xclk_count <= xclk_count + 2'b01;
        
        //Just raw image from camera truncated to 12 bits
        raw_image_pixels <= {output_pixels[15:12],output_pixels[10:7],output_pixels[4:1]}; //{h[7:0], s[7:0], v[7:0]};
        
        //TODO: put the thresholding in a separate module to make camera_to_mask less bulky
        //Thresholding Red
        if (sw[4]) begin //naive method with RGB
            if ((output_pixels[15:12]>4'b1000)&&(output_pixels[10:7]<4'b1000)&&(output_pixels[4:1]<4'b1000))begin
                red_processed_pixels <= 1'b1;
            end else begin
                red_processed_pixels <= 1'b0;
            end
        
        end else if (sw[7]) begin //sw7 is very noisy
            if ((s >= 60) && (h <= 15 || h >= 330)) begin 
                red_processed_pixels <= 1'b1;
            end else begin
                red_processed_pixels <= 1'b0;
            end 
        
        end else if (sw[8]) begin //less noisy
            if ((s >= 60) && (h <= 15 || h >= 330) && (v >= 75)) begin 
                red_processed_pixels <= 1'b1;
            end else begin
                red_processed_pixels <= 1'b0;
            end 
        
        end else if (sw[9]) begin //less noisy but sometimes picks up less
            if ((s >= 60) && (h <= 15 || h >= 330) && (v >= 90)) begin 
                red_processed_pixels <= 1'b1;
            end else begin
                red_processed_pixels <= 1'b0;
            end
        
        end else if (sw[10]) begin//no saturation check - picks up a bit more noise and other colors    
            if ((h <= 15 || h >= 330) && (v >= 75)) begin 
                red_processed_pixels <= 1'b1;
            end else begin
                red_processed_pixels <= 1'b0;
            end 
        end     
        

        //Thresholding Blue
        if (sw[6]) begin //naive method with RGB
            if ((output_pixels[15:12]<4'b1000)&&(output_pixels[10:7]<4'b1000)&&(output_pixels[4:1]>4'b1000))begin
                blue_processed_pixels <= 1'b1;
            end else begin
                blue_processed_pixels <= 1'b0;
            end

        end else if (sw[7]) begin //initial rough attempt 
            if ((h >= 193 && h <= 236) && (v >= 75)) begin 
                blue_processed_pixels <= 1'b1;
            end else begin
                blue_processed_pixels <= 1'b0;
            end
        end 
                                  
    end 
    
    //Turn binary masks into colored pixels
    assign red_buff_out = red_mask_buff_out?12'hF00:12'h000;
    assign blue_buff_out = blue_mask_buff_out?12'h00F:12'h000;
    
   //Read pixels for the camera
   camera_read  my_camera(.p_clock_in(pclk_in),
                          .vsync_in(vsync_in),
                          .href_in(href_in),
                          .p_data_in(pixel_in),
                          .pixel_data_out(output_pixels),
                          .pixel_valid_out(valid_pixel),
                          .frame_done_out(frame_done_out),
                          .v_idx_out(v_idx_out),
                          .h_idx_out(h_idx_out),
                          .pixel_addr_out(bram_input_pixel_addr));
   
   //Convert RGB pixels to HSV color space
   rgb2hsv converter(.clock(clk_65mhz), 
                        .reset(reset),
                        .r({output_pixels[15:11], 3'b000}),
                        .g({output_pixels[10:5], 2'b00}),
                        .b({output_pixels[4:0],3'b000}),
                        .h(h),
                        .s(s),
                        .v(v));
   
   //Find center and area of red pixel mask
   center_finder red_cf(.clk_in(clk_65mhz),
                         .v_index_in(v_idx_out),
                         .h_index_in(h_idx_out), 
                         .pixel_in(red_processed_pixels),
                         .valid_out(red_center_valid),
                         .area_out(red_area_out),
                         .v_index_out(red_center_v_index_out),
                         .h_index_out(red_center_h_index_out));
   
   //Find center and area of blue pixel mask
   center_finder blue_cf(.clk_in(clk_65mhz),
                     .v_index_in(v_idx_out),
                     .h_index_in(h_idx_out), 
                     .pixel_in(blue_processed_pixels),
                     .valid_out(blue_center_valid),
                     .area_out(blue_area_out),
                     .v_index_out(blue_center_v_index_out),
                     .h_index_out(blue_center_h_index_out));
         
    //store processed pixels in frame buffers  
    image_bram frame_bram(.addra(bram_input_pixel_addr), 
                             .clka(pclk_in), //camera's clock signal 
                             .dina(raw_image_pixels),
                             .wea(valid_pixel),
                             .addrb(raw_image_output_pixel_addr),
                             .clkb(clk_65mhz),
                             .doutb(raw_image_buff_out));
    
    red_mask_bram r_mask_bram(.addra(bram_input_pixel_addr), 
                             .clka(pclk_in), //camera's clock signal 
                             .dina(red_processed_pixels),
                             .wea(valid_pixel),
                             .addrb(red_buff_output_pixel_addr),
                             .clkb(clk_65mhz),
                             .doutb(red_mask_buff_out));
    
    blue_mask_bram b_mask_bram(.addra(bram_input_pixel_addr), 
                             .clka(pclk_in), //camera's clock signal 
                             .dina(blue_processed_pixels),
                             .wea(valid_pixel),
                             .addrb(blue_buff_output_pixel_addr),
                             .clkb(clk_65mhz),
                             .doutb(blue_mask_buff_out));
                             
                             
endmodule