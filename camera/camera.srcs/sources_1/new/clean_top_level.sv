`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2020 01:40:09 PM
// Design Name: 
// Module Name: clean_top_level
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


module clean_top_level(
       //FPGA controls and displays
       input clk_100mhz,
       input btnc, btnu, btnl, btnr, btnd,
       input[15:0] sw,
       output led16_b, led16_g, led16_r,
       output led17_b, led17_g, led17_r,
       output[15:0] led,
        
       //PMOD pins for camera
       input [7:0] ja, //pixel data from camera
       input [2:0] jb, //other data from camera (including clock return)
       input [2:0] jd,
       output   jbclk, //clock FPGA drives the camera with
       output   jdclk,
    
       //VGA circuit
       output[3:0] vga_r,
       output[3:0] vga_b,
       output[3:0] vga_g,
       output vga_hs,
       output vga_vs
    );
    
    //SETUP 
    
     logic clk_65mhz;
    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
    clk_wiz_lab3 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));
    
    //in case buttons are to be used
    assign led16_r = btnl;                  // left button -> red led
    assign led16_g = btnc;                  // center button -> green led
    assign led16_b = btnr;                  // right button -> blue led
    assign led17_r = btnl;
    assign led17_g = btnc;
    assign led17_b = btnr;
    assign led = sw;

    // btnc button is user reset
    logic reset;
    debounce db1(.reset_in(reset),.clock_in(clk_65mhz),.noisy_in(btnc),.clean_out(reset));
    
    
    //VGA display 
    logic [10:0] hcount;   // pixel on current line
    logic [9:0] vcount;   // line number
    logic hsync, vsync, blank;
    xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));

    // Currently only displaying red mask on VGA. TODO display both masks simultaneously, either in two displays or superimposed in diff colors
    logic [11:0] red_mask_pixel; 
    logic [11:0] blue_mask_pixel;
    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~blank ? red_mask_pixel[11:8]: 0;
    assign vga_g = ~blank ? red_mask_pixel[7:4] : 0;
    assign vga_b = ~blank ? red_mask_pixel[3:0] : 0;

    assign vga_hs = ~hsync;
    assign vga_vs = ~vsync;

   //indices of pixel from bram
   //TODO: try unifying these into x, y (independent of color) ??
   logic x_r, y_r; 
   logic x_b, y_b; 
  
   parameter RED = 0;
   parameter BLUE = 1;
   
   // EXTRACT PIXEL/INDEX PAIRS AND DISPLAY A PARTICULAR MASK ON VGA. Currently the red mask is being displayed
   camera_to_mask red_blob(
    .clk_100mhz(clk_100mhz),
    .clk_65mhz(clk_65mhz),
    .reset(reset), 
    .sw(sw),
    .ja_p(ja), 
    .jb_p(jb), 
    .jd_p(jd),
    .jbclk_p(jbclk), 
    .jdclk_p(jdclk),
    .hcount(hcount),    
    .vcount(vcount),    
    .hsync(hsync), .vsync(vsync), .blank(blank),
    .data_to_vga(red_mask_pixel),
    .color(RED),
    .index_x(x_r),
    .index_y(y_r)
   );
   
   logic fake_jbclk, fake_jdclk; //to avoid multi-driven pins
   //probably a better way to do this than creating a new instance for each color 
   camera_to_mask blue_blob(
    .clk_100mhz(clk_100mhz),
    .clk_65mhz(clk_65mhz),
    .reset(reset), 
    .sw(sw),
    .ja_p(ja), 
    .jb_p(jb), 
    .jd_p(jd),
    .jbclk_p(fake_jbclk), 
    .jdclk_p(fake_jdclk),
    .hcount(hcount),    
    .vcount(vcount),    
    .hsync(hsync), .vsync(vsync), .blank(blank),
    .data_to_vga(blue_mask_pixel),
    .color(BLUE),
    .index_x(x_b),
    .index_y(y_b)
   );
   
   logic red_pix, blue_pix; //stretch: add more colors for more limbs
   assign red_pix = (red_mask_pixel == 12'hF00);
   assign blue_pix = (blue_mask_pixel == 12'h00F);
   
   // FIND CENTROIDS OF COLOR MASKS
   // @Praj: "color"_pix is a boolean indicating whether the pixel is "color". x_.. and y_.. are the coordinates of the pixel on 1024x768 vga                                
endmodule

