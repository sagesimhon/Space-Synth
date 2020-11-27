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
       input clk_100mhz,
       input btnc, btnu, btnl, btnr, btnd,
       input[15:0] sw,
       output led16_b, led16_g, led16_r,
       output[15:0] led,
        
       //PMOD pins  
       input [7:0] ja, //pixel data from camera
       input [2:0] jb, //other data from camera (including clock return)
       input [2:0] jd,
       output   jbclk, //clock FPGA drives the camera with
       output   jdclk
    );
    
     logic clk_65mhz;
    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
    clk_wiz_lab3 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));
    
    assign led16_r = btnl;                  // left button -> red led
    assign led16_g = btnc;                  // center button -> green led
    assign led16_b = btnr;                  // right button -> blue led
    assign led17_r = btnl;
    assign led17_g = btnc;
    assign led17_b = btnr;
    assign led = sw;
    //assign data = {28'h0123456, sw[3:0]};   // display 0123456 + sw[3:0]

    // btnc button is user reset
    logic reset;
    debounce db1(.reset_in(reset),.clock_in(clk_65mhz),.noisy_in(btnc),.clean_out(reset));
    
    
    //VGA display 
    logic [10:0] hcount;   // pixel on current line
    logic [9:0] vcount;   // line number
    logic hsync, vsync, blank;
    xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));

    logic [3:0] vga_r, vga_g, vga_b;
    logic vga_hs, vga_vs;
    logic [11:0] vga_data;
     // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~blank ? vga_data[11:8]: 0;
    assign vga_g = ~blank ? vga_data[7:4] : 0;
    assign vga_b = ~blank ? vga_data[3:0] : 0;

    assign vga_hs = ~hsync;
    assign vga_vs = ~vsync;

   camera_to_mask red_blob(
    .clk_100mhz(clk_100mhz),
    .clk_65mhz(clk_65mhz),
    .reset(reset), 
    .sw(sw),
    .ja(ja), //pixel data from camera *********************** name of ja in inner module
    .jb(jb), //other data from camera (including clock return)
    .jd(jd),
    .jbclk(jbclk), //clock FPGA drives the camera with
    .jdclk(jdclk),
    .hcount(hcount),    // pixel on current line
    .vcount(vcount),    // line number
    .hsync(hsync), .vsync(vsync), .blank(blank),
    .data_to_vga(vga_data)
   );
   
   ila_0 my_ila(.clk(clk_65mhz),     
                                    .probe0(pclk_in), 
                                    .probe1(vsync_in),
                                    .probe2(href_in),
                                    .probe3(jbclk),
                                    .probe4(vga_data));
                                        
endmodule

