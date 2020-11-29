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
    
    logic blue_valid;
    logic [16:0] blue_area;
    logic [7:0] blue_center_v_index;
    logic [8:0] blue_center_h_index;
    
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
    
    //Minimum amount of detected pixels before counting it as an object
    localparam detection_threshold = 17'd200;
    
    logic [11:0] current_pixel;
    always_comb begin
        if (sw[2]&&((hcount<320) &&  (vcount<240))) begin //If sw[2] show original image
            current_pixel = raw_image_buff;
            raw_image_output_pixel_addr = hcount+vcount*32'd320;
        end
        else if (~sw[2]&&((hcount<320) &&  (vcount<240))) begin //Otherwise show red mask image
            //Add green crosshair on center coordinates (if enough pixels are detected)
            current_pixel = ((hcount==red_center_h_index) || (vcount==red_center_v_index))?((red_area >= detection_threshold)?12'h0F0:red_buff):red_buff;
            red_buff_output_pixel_addr = hcount+vcount*32'd320;
        end
        else if (~sw[2]&&((hcount>=320) && (hcount<640) && (vcount<240))) begin //Show blue mask image next to it
            //Add green crosshair on center coordinates (if enough pixels are detected)
            current_pixel = ((hcount==blue_center_h_index+320) || (vcount==blue_center_v_index))?((blue_area >= detection_threshold)?12'h0F0:blue_buff):blue_buff;
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
    
    //Assign synthesizer controls
    logic signed[7:0] synth1_out;
    logic signed[7:0] synth2_out;
    logic signed[7:0] all_synth_out;
    
    logic [2:0] synth1_osc2_tune;
    assign synth1_osc2_tune = 3'd2;
    
    logic [1:0] synth1_osc1_shape;
    assign synth1_osc1_shape = 2'd2;
    logic [1:0] synth1_osc2_shape;
    assign synth1_osc2_shape = 2'd3;
    
    logic [2:0] synth2_osc2_tune;
    assign synth2_osc2_tune = 3'd3;
    
    logic [1:0] synth2_osc1_shape;
    assign synth2_osc1_shape = 2'd3;
    logic [1:0] synth2_osc2_shape;
    assign synth2_osc2_shape = 2'd2;
    
    logic [11:0] synth1_frequency;
    assign synth1_frequency = (red_area >= detection_threshold)?(12'd200+red_center_v_index<<2):12'd0;
    
    logic [11:0] synth2_frequency;
    assign synth2_frequency = (blue_area >= detection_threshold)?(12'd200+blue_center_v_index<<2):12'd0;
    
    logic [7:0] filter_cutoff;
    assign filter_cutoff = 8'd255;
    
    logic [2:0] synth_amplitude;
    assign synth_amplitude = 3'd7;
    
//    logic signed[7:0] lfo_out;
//    logic [11:0] lfo_frequency;
//    assign lfo_frequency = red_center_v_index>>3;  
            
//    oscillator lfo (
//        .clk_in(clk_100mhz),
//        .rst_in(reset),
//        .step_in(trigger_in),
//        .shape_in(2'd0),
//        .frequency_in(lfo_frequency),
//        .wave_out(lfo_out));
        
    synthesizer synth1(
        .frequency_in(synth1_frequency),
        .osc2_tune_in(synth1_osc2_tune),
        .osc1_shape_in(synth1_osc1_shape),
        .osc2_shape_in(synth1_osc2_shape),
        .amplitude_in(synth_amplitude),
        .filter_cutoff_in(filter_cutoff),
        .trigger_in(sample_trigger),
        .rst_in(reset), 
        .clk_in(clk_100mhz),
        .audio_out(synth1_out));
        
    synthesizer synth2(
        .frequency_in(synth2_frequency),
        .osc2_tune_in(synth2_osc2_tune),
        .osc1_shape_in(synth2_osc1_shape),
        .osc2_shape_in(synth2_osc2_shape),
        .amplitude_in(synth_amplitude),
        .filter_cutoff_in(filter_cutoff),
        .trigger_in(sample_trigger),
        .rst_in(reset),
        .clk_in(clk_100mhz),
        .audio_out(synth2_out));
        
    mixer synth_mixer(
        .wave1_in(synth1_out),
        .wave2_in(synth2_out),
        .mixed_out(all_synth_out));
        
    pwm pwm_out(
        .clk_in(clk_100mhz), 
        .rst_in(reset), 
        .level_in({~all_synth_out[7],all_synth_out[6:0]}),
        .pwm_out(pwm_val));
        
    assign aud_pwm = pwm_val?1'bZ:1'b0; 
   //
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
