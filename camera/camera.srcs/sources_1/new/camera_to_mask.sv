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
   
   input reset, 
   
   input [15:0] sw,
   
   input [7:0] ja, //pixel data from camera
   input [2:0] jb, //other data from camera (including clock return)
   input [2:0] jd,
   output   jbclk, //clock FPGA drives the camera with
   output   jdclk,

   input [10:0] hcount,    // pixel on current line
   input [9:0] vcount,    // line number
   input hsync, vsync, blank,
   output[3:0] vga_r,
   output[3:0] vga_b,
   output[3:0] vga_g,
   output vga_hs,
   output vga_vs,
   output [11:0] data_to_vga
   
   );
   
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
    assign jbclk = xclk;
    assign jdclk = xclk;
    
    //store processed pixels in frame buffer   
    blk_mem_gen_0 frame_bram(.addra(pixel_addr_in), 
                             .clka(pclk_in),
                             .dina(processed_pixels),
                             .wea(valid_pixel),
                             .addrb(pixel_addr_out),
                             .clkb(clk_65mhz),
                             .doutb(frame_buff_out));
    
    always_ff @(posedge pclk_in)begin
        if (frame_done_out)begin
            pixel_addr_in <= 17'b0;  
        end else if (valid_pixel)begin
            pixel_addr_in <= pixel_addr_in +1;  
        end
    end
    
    always_ff @(posedge clk_65mhz) begin
        pclk_buff <= jb[0];//WAS JB
        vsync_buff <= jb[1]; //WAS JB
        href_buff <= jb[2]; //WAS JB
        pixel_buff <= ja;
        pclk_in <= pclk_buff;
        vsync_in <= vsync_buff;
        href_in <= href_buff;
        pixel_in <= pixel_buff;
        old_output_pixels <= output_pixels;
        xclk_count <= xclk_count + 2'b01;
        if (sw[3])begin
            //processed_pixels <= {red_diff<<2, green_diff<<2, blue_diff<<2};
            processed_pixels <= output_pixels - old_output_pixels;
         
        end else if (sw[4]) begin
            if ((output_pixels[15:12]>4'b1000)&&(output_pixels[10:7]<4'b1000)&&(output_pixels[4:1]<4'b1000))begin
                processed_pixels <= 12'hF00;
            end else begin
                processed_pixels <= 12'h000;
            end
        end else if (sw[5]) begin
            if ((output_pixels[15:12]<4'b1000)&&(output_pixels[10:7]>4'b1000)&&(output_pixels[4:1]<4'b1000))begin
                processed_pixels <= 12'h0F0;
            end else begin
                processed_pixels <= 12'h000;
            end
        end else if (sw[6]) begin
            if ((output_pixels[15:12]<4'b1000)&&(output_pixels[10:7]<4'b1000)&&(output_pixels[4:1]>4'b1000))begin
                processed_pixels <= 12'h00F;
            end else begin
                processed_pixels <= 12'h000;
            end
        end else if (sw[7]) begin 
            if ((s >= 60) && (h <= 15 || h >= 330)) begin 
                processed_pixels <= 12'hF00;
            end else begin
                processed_pixels <= 12'h000;
            end 
        end else if (sw[8]) begin 
            if ((s >= 60) && (h <= 15 || h >= 330) && (v >= 75)) begin 
                processed_pixels <= 12'hF00;
            end else begin
                processed_pixels <= 12'h000;
            end     
        end else if (sw[9]) begin 
            if ((s >= 60) && (h <= 15 || h >= 330) && (v >= 90)) begin 
                processed_pixels <= 12'hF00;
            end else begin
                processed_pixels <= 12'h000;
            end
        end else if (sw[10]) begin
            if ((h <= 15 || h >= 330) && (v >= 75)) begin 
                processed_pixels <= 12'hF00;
            end else begin
                processed_pixels <= 12'h000;
            end      
        end else if (sw[11]) begin
            if ((h >= 193 && h <= 236) && (v >= 75)) begin 
                processed_pixels <= 12'h00F;
            end else begin
                processed_pixels <= 12'h000;
            end           
        end else begin
            processed_pixels = {output_pixels[15:12],output_pixels[10:7],output_pixels[4:1]}; //{h[7:0], s[7:0], v[7:0]};
        end
            
    end
    assign pixel_addr_out = sw[2]?((hcount>>1)+(vcount>>1)*32'd320):hcount+vcount*32'd320;
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


//    assign rgb = sw[0] ? {12{border}} : pixel ; //{{4{hcount[7]}}, {4{hcount[6]}}, {4{hcount[5]}}};


endmodule


