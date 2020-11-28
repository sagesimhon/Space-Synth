`timescale 1ns / 1ps

module top_level(
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
       output vga_vs,
       
       //Audio circuit
       output logic aud_pwm,
       output logic aud_sd
    );

    //Setup for audio out
    parameter SAMPLE_COUNT = 2082; //48 kHz sample rate.
    logic [15:0] sample_counter;
    logic sample_trigger;
    logic enable;
    logic pwm_val; 
    
    assign aud_sd = 1;

    //Generate trigger signal for audio samples
    assign sample_trigger = (sample_counter == SAMPLE_COUNT);
    always_ff @(posedge clk_100mhz)begin
        if (sample_counter == SAMPLE_COUNT)begin
            sample_counter <= 16'b0;
        end else begin
            sample_counter <= sample_counter + 16'b1;
        end
    end
   
    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
    logic clk_65mhz;
    clk_wiz_0 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));
    
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
    
    //Setup for parameter extraction
    logic red_valid;
    logic [16:0] red_area;
    logic [7:0] red_center_v_index;
    logic [8:0] red_center_h_index;
    
    logic [16:0] red_area_valid;
    assign red_area_valid = red_valid?red_area:red_area_valid;
    
    logic blue_valid;
    logic [16:0] blue_area;
    logic [7:0] blue_center_v_index;
    logic [8:0] blue_center_h_index;
    
    logic [16:0] blue_area_valid;
    assign blue_area_valid = blue_valid?blue_area:blue_area_valid;
    
    //VGA display 
    logic [10:0] hcount;   
    logic [9:0] vcount;   
    logic hsync, vsync, blank;
    xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));
    
    //Full color pixel value and index
    logic [11:0] raw_image_buff; 
    logic [16:0] raw_image_output_pixel_addr;
    
    //Red mask pixel value and index
    logic [11:0] red_buff;
    logic [16:0] red_buff_output_pixel_addr; 
    
    //Blue mask pixel value and index
    logic [11:0] blue_buff;
    logic [16:0] blue_buff_output_pixel_addr;
    
    logic [11:0] current_pixel;
    always_comb begin
        if (sw[2]&&((hcount<320) &&  (vcount<240))) begin //If sw[2] show original image
            current_pixel = raw_image_buff;
            raw_image_output_pixel_addr = hcount+vcount*32'd320;
        end
        else if (~sw[2]&&((hcount<320) &&  (vcount<240))) begin //Otherwise show red mask image
            //Add green crosshair on center coordinates
            current_pixel = ((hcount==red_center_h_index) || (vcount==red_center_v_index))?12'h0F0:red_buff;
            red_buff_output_pixel_addr = hcount+vcount*32'd320;
        end
        else if (~sw[2]&&((hcount>=320) && (hcount<640) && (vcount<240))) begin //Show blue mask image next to it
            //Add green crosshair on center coordinates
            current_pixel = ((hcount==blue_center_h_index+320) || (vcount==blue_center_v_index))?12'h0F0:blue_buff;
            blue_buff_output_pixel_addr = (hcount-11'd320)+vcount*32'd320;
        end
        else begin
            current_pixel = 12'h000;
        end     
    end
    
    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~blank ? current_pixel[11:8]: 0;
    assign vga_g = ~blank ? current_pixel[7:4] : 0;
    assign vga_b = ~blank ? current_pixel[3:0] : 0;
    assign vga_hs = ~hsync;
    assign vga_vs = ~vsync;
   
   //All of the image processing is done inside this big module
   camera_to_mask color_blobs(
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
  
    .raw_image_buff_out(raw_image_buff),
    .raw_image_output_pixel_addr(raw_image_output_pixel_addr),
    .red_buff_out(red_buff),
    .red_buff_output_pixel_addr(red_buff_output_pixel_addr), 
    .blue_buff_out(blue_buff),
    .blue_buff_output_pixel_addr(blue_buff_output_pixel_addr), 

    .red_center_valid(red_valid),
    .red_area_out(red_area),
    .red_center_v_index_out(red_center_v_index),
    .red_center_h_index_out(red_center_h_index),
   
    .blue_center_valid(blue_valid),
    .blue_area_out(blue_area),
    .blue_center_v_index_out(blue_center_v_index),
    .blue_center_h_index_out(blue_center_h_index)
   );
                               
endmodule
