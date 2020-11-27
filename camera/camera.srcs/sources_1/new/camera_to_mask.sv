`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2020 10:45:40 PM
// Design Name: 
// Module Name: camera_to_mask
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

module camera_to_mask(
   input clk_100mhz,
   input clk_65mhz,
   
   input logic reset, 
   
   input logic [15:0] sw,
   
   input logic [7:0] ja_p, //pixel data from camera
   input logic [2:0] jb_p, //other data from camera (including clock return)
   input logic [2:0] jd_p,
   output logic  jbclk_p, //clock FPGA drives the camera with
   output logic  jdclk_p,

   input logic [10:0] hcount,    // pixel on current line
   input logic [9:0] vcount,    // line number
   input logic hsync, vsync, blank,

   output logic [11:0] data_to_vga, // either a red or blue pixel depending on the color mask being selected 

   input logic color, //desired color to chroma key
   
   output logic index_x,
   output logic index_y
   );
   
   parameter DISPLAY_WIDTH  = 1024;      // display width on vga
   parameter DISPLAY_HEIGHT = 768;       // number of lines
   
   parameter RED = 0;
   parameter BLUE = 1;
   
    //clock
    logic xclk;
    logic[1:0] xclk_count;
    
    logic pclk_buff, pclk_in;
    logic vsync_buff, vsync_in;
    logic href_buff, href_in;
    logic [7:0] pixel_buff, pixel_in;
    
    logic [11:0] frame_buff_out;
    logic [15:0] output_pixels;
    logic [15:0] old_output_pixels;
    logic [12:0] processed_pixels;
    logic [3:0] red_diff;
    logic [3:0] green_diff;
    logic [3:0] blue_diff;
    logic [7:0] h;
    logic [7:0] s;
    logic [7:0] v;
    
    logic valid_pixel;
    logic frame_done_out;
    
    logic [16:0] pixel_addr_in;
    logic [16:0] pixel_addr_out;
    
    assign xclk = (xclk_count >2'b01); // 25% speed of 65 mhz clock
    assign jbclk_p = xclk; // drives camera
    assign jdclk_p = xclk;
    
    //store processed pixels in frame buffer   
    blk_mem_gen_0 frame_bram(.addra(pixel_addr_in), 
                             .clka(pclk_in), //camera's clock signal 
                             .dina(processed_pixels),
                             .wea(valid_pixel),
                             .addrb(pixel_addr_out),
                             .clkb(clk_65mhz),
                             .doutb(frame_buff_out));
    
    
    always_ff @(posedge pclk_in)begin
        if (frame_done_out)begin
            pixel_addr_in <= 17'b0;  
            index_y <= 0;
            index_x <= 0;
        end else if (valid_pixel)begin
            pixel_addr_in <= pixel_addr_in + 1;  
            index_y <= (index_x == DISPLAY_WIDTH) ? index_y + 1 : index_y;
            index_x <= (index_x == DISPLAY_WIDTH) ? 0 : index_x + 1;
        end
    end
    
    always_ff @(posedge clk_65mhz) begin
        pclk_buff <= jb_p[0];//WAS JB
        vsync_buff <= jb_p[1]; //WAS JB
        href_buff <= jb_p[2]; //WAS JB
        pixel_buff <= ja_p;
        pclk_in <= pclk_buff;
        vsync_in <= vsync_buff;
        href_in <= href_buff;
        pixel_in <= pixel_buff;
        old_output_pixels <= output_pixels;
        xclk_count <= xclk_count + 2'b01;
        
        //TODO: optimize color thresholding; for now: switches for different settings
        //TODO: put the thresholding in a separate module to make camera_to_mask less bulky
        
        //Red thresholding options 
        if (color == RED) begin 
            //naive method with RGB:
            if (sw[4]) begin
                if ((output_pixels[15:12]>4'b1000)&&(output_pixels[10:7]<4'b1000)&&(output_pixels[4:1]<4'b1000))begin
                    processed_pixels <= 12'hF00;
                end else begin
                    processed_pixels <= 12'h000;
                end
            //sw7 is very noisy
            end else if (sw[7]) begin 
                if ((s >= 60) && (h <= 15 || h >= 330)) begin 
                    processed_pixels <= 12'hF00;
                end else begin
                    processed_pixels <= 12'h000;
                end 
            //less noisy
            end else if (sw[8]) begin 
                if ((s >= 60) && (h <= 15 || h >= 330) && (v >= 75)) begin 
                    processed_pixels <= 12'hF00;
                end else begin
                    processed_pixels <= 12'h000;
                end 
            //less noisy but sometimes picks up less        
            end else if (sw[9]) begin 
                if ((s >= 60) && (h <= 15 || h >= 330) && (v >= 90)) begin 
                    processed_pixels <= 12'hF00;
                end else begin
                    processed_pixels <= 12'h000;
                end
            //no saturation check - picks up a bit more noise and other colors    
            end else if (sw[10]) begin
                if ((h <= 15 || h >= 330) && (v >= 75)) begin 
                    processed_pixels <= 12'hF00;
                end else begin
                    processed_pixels <= 12'h000;
                end 
            end     
        
        //Blue thresholding options    
        end else if (color == BLUE) begin 
            
            //naive method with RGB
            if (sw[6]) begin
                if ((output_pixels[15:12]<4'b1000)&&(output_pixels[10:7]<4'b1000)&&(output_pixels[4:1]>4'b1000))begin
                    processed_pixels <= 12'h00F;
                end else begin
                    processed_pixels <= 12'h000;
                end
                
            //initial rough attempt
            end else if (sw[7]) begin
                if ((h >= 193 && h <= 236) && (v >= 75)) begin 
                    processed_pixels <= 12'h00F;
                end else begin
                    processed_pixels <= 12'h000;
                end
            end               
       
        end else begin //display unfiltered camera data, taking upper 4 bits of each of RGB
            processed_pixels = {output_pixels[15:12],output_pixels[10:7],output_pixels[4:1]}; //{h[7:0], s[7:0], v[7:0]};
        end
            
    end 
    assign pixel_addr_out = sw[2]?((hcount>>1)+(vcount>>1)*32'd320):hcount+vcount*32'd320;
    //send bram outputs to vga (sw2 controls display size)
    //data_to_vga is updated at the camera clock speed (pclk)
    assign data_to_vga = sw[2]&&((hcount<640) &&  (vcount<480))?frame_buff_out:~sw[2]&&((hcount<320) &&  (vcount<240))?frame_buff_out:12'h000;
    

   camera_read  my_camera(.p_clock_in(pclk_in),
                          .vsync_in(vsync_in),
                          .href_in(href_in),
                          .p_data_in(pixel_in),
                          .pixel_data_out(output_pixels),
                          .pixel_valid_out(valid_pixel),
                          .frame_done_out(frame_done_out));
   

   rgb2hsv converter(.clock(clk_65mhz), 
                        .reset(reset),
                        .r({output_pixels[15:12], 4'b0000}),
                        .g({output_pixels[10:7], 4'b0000}),
                        .b({output_pixels[4:1],4'b0000}),
                        .h(h),
                        .s(s),
                        .v(v));


    ila_0 my_ila(.clk(clk_65mhz),     
                                    .probe0(pclk_in), 
                                    .probe1(vsync_in),
                                    .probe2(href_in),
                                    .probe3(jbclk_p),
                                    .probe4(data_to_vga));

endmodule


