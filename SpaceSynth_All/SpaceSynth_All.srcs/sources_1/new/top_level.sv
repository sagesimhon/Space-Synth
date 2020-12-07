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
       
    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
    logic clk_65mhz;
    clk_wiz_0 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));
    
    //Setup for audio out
    parameter SAMPLE_COUNT = 1354; //48 kHz sample rate.
    logic [15:0] sample_counter;
    logic sample_trigger;
    logic enable;
    logic pwm_val; 
    
    assign aud_sd = 1;
        
    parameter SINE = 2'd0;
    parameter SQUARE = 2'd1;
    parameter TRIANGLE = 2'd2;
    parameter SAW = 2'd3;
    
    //Generate trigger signal for audio samples
    assign sample_trigger = (sample_counter == SAMPLE_COUNT);
    always_ff @(posedge clk_65mhz)begin
        if (sample_counter == SAMPLE_COUNT)begin
            sample_counter <= 16'b0;
        end else begin
            sample_counter <= sample_counter + 16'b1;
        end
    end

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
    assign reset = sw[15];
    
    //Setup for parameter extraction
    logic red_valid;
    logic [16:0] red_area;
    logic [7:0] red_center_v_index;
    logic [8:0] red_center_h_index;
    
    logic blue_valid;
    logic [16:0] blue_area;
    logic [7:0] blue_center_v_index;
    logic [8:0] blue_center_h_index;
    
    logic green_valid;
    logic [16:0] green_area;
    logic [7:0] green_center_v_index;
    logic [8:0] green_center_h_index;
    
    //VGA display 
    logic [10:0] hcount;   
    logic [9:0] vcount;   
    logic hsync, vsync, blank;
    logic [3:0] hsync_buff, vsync_buff, blank_buff = 4'b0;
    xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank)); //768x1024 using clk_65mhz
    
    //Full color pixel value and index
    logic [11:0] raw_image_buff; 
    logic [16:0] raw_image_output_pixel_addr;
    
    //Red mask pixel value and index
    logic [11:0] red_buff;
    logic [16:0] red_buff_output_pixel_addr; 
    
    //Blue mask pixel value and index
    logic [11:0] blue_buff;
    logic [16:0] blue_buff_output_pixel_addr;
    
    //Blue mask pixel value and index
    logic [11:0] green_buff;
    logic [16:0] green_buff_output_pixel_addr;
    
    //Minimum amount of detected pixels before counting it as an object
    localparam detection_threshold = 17'd200;
    localparam lfo_threshold = 17'd350;
    //Current display pixel
    logic [11:0] current_pixel;
    
    //Synthesizer controls
    logic signed[7:0] synth1_out;
    logic signed[7:0] synth2_out;
    logic signed[7:0] all_synth_out;
    
    logic [2:0] synth1_osc2_tune;
    assign synth1_osc2_tune = 3'd1;
    
    logic [1:0] synth1_osc1_shape;
    logic [1:0] synth1_osc2_shape;
    
    logic [2:0] synth2_osc2_tune;
    assign synth2_osc2_tune = 3'd2;
    
    logic [1:0] synth2_osc1_shape;
    logic [1:0] synth2_osc2_shape;
    
    logic [11:0] synth1_frequency;
    
    logic [11:0] synth2_frequency;
    
    logic [7:0] filter_cutoff;
    //assign filter_cutoff = 8'd255;
    
    logic [2:0] synth1_amplitude;
    logic [2:0] synth2_amplitude;
    
    logic signed[7:0] lfo_out;
    logic signed[7:0] lfo_osc_out;
    logic [11:0] lfo_frequency;
    logic [2:0] lfo_amplitude;
    logic [1:0] lfo_shape;
    assign lfo_shape = sw[1:0];
    
    logic [1:0] region;
    logic [1:0][1:0] waveshape;
        logic r_bar_1_border, r_bar_2_border, r_bar_3_border, b_bar_1_border, b_bar_2_border, b_bar_3_border, 
    g_bar_1_border, g_bar_2_border, g_bar_3_border = 1'b0;
    
    logic [8:0] red_area_scaled, blue_area_scaled, green_area_scaled; //area right shifted by 8 (76800/256 normalizes to 300)
    //TODO remove magic numbers might get points off
    always_comb begin
        r_bar_1_border = (((hcount == 10 || hcount == 20) && (vcount <= 751 && vcount >= 510))
              || ((vcount==751 || vcount==510) && (hcount <= 20 && hcount >= 10)));
        r_bar_2_border = (((hcount == 110 || hcount == 120) && (vcount <= 751 && vcount >= 430))
              || ((vcount==751 || vcount==430) && (hcount >= 110 && hcount <= 120)));
        r_bar_3_border = (((hcount == 210 || hcount == 220) && (vcount<=751 && vcount >= 449)) 
              || ((vcount==751 || vcount==449) && (hcount >= 210 && hcount <= 220)));
        b_bar_1_border = (((hcount == 330 || hcount == 340) && (vcount <= 751 && vcount >= 510))
              || ((vcount==751 || vcount==510) && (hcount >= 330 && hcount <= 340)));
        b_bar_2_border = (((hcount == 430 || hcount == 440) && (vcount <= 751 && vcount >= 430))
              || ((vcount==751 || vcount==430) && (hcount >= 430 && hcount <= 440)));
        b_bar_3_border = (((hcount == 530 || hcount == 540) && (vcount<=751 && vcount >= 449)) 
              || ((vcount==751 || vcount==449) && (hcount >= 530 && hcount <= 540)));
        g_bar_1_border = (((hcount == 650 || hcount == 660) && (vcount <= 751 && vcount >= 510))
              || ((vcount==751 || vcount==510) && (hcount >= 650 && hcount <= 660)));
        g_bar_2_border = (((hcount == 750 || hcount == 760) && (vcount <= 751 && vcount >= 430))
              || ((vcount==751 || vcount==430) && (hcount >= 750 && hcount <= 760)));
        g_bar_3_border = (((hcount == 850 || hcount == 860) && (vcount<=751 && vcount >= 449)) 
              || ((vcount==751 || vcount==449) && (hcount >= 850 && hcount <= 860)));

        region = (blue_center_h_index < 426) ? 2'b0 : (blue_center_h_index < 533) ? 2'b1 : 2'b10;
        synth1_osc1_shape = waveshape[0];
        synth1_osc2_shape = waveshape[1];
        synth2_osc1_shape = waveshape[2];
        synth2_osc2_shape = waveshape[3];
        
    end
    
    always_ff @(posedge clk_65mhz) begin

        lfo_frequency <= (red_area < lfo_threshold) ? 12'd0 : red_area >= (red_area >= detection_threshold)?(red_area>>9):12'd0;
        lfo_amplitude <= (green_area < lfo_threshold) ? 3'd0 : (green_area >= detection_threshold)?(green_area>>10):3'd0; 
        synth1_frequency <= (red_area >= detection_threshold)?(12'd200+(red_center_h_index<<1)+lfo_out<<<3):12'd0;
        synth2_frequency <= (green_area >= detection_threshold)?(12'd200+(green_center_h_index<<1)+lfo_out<<<3):12'd0;        
        
        red_area_scaled <= red_area>>4;
        if (red_area_scaled > 9'd299) begin
            red_area_scaled <= 9'd299;
        end

        blue_area_scaled <= blue_area>>4;
        if (blue_area_scaled > 9'd299) begin
            blue_area_scaled <= 9'd299;
        end

        green_area_scaled <= green_area>>4;
        if (green_area_scaled > 9'd299) begin
            green_area_scaled <= 9'd299;
        end


        filter_cutoff <= (green_center_h_index - red_center_h_index) <= 255 ? (green_center_h_index - red_center_h_index) : 255; //abs value? currently only works if green is to the right of red
        
        if (red_center_v_index < 120)begin
            synth1_amplitude <= (red_area >= detection_threshold)?3'd7:3'd0;
        end else if (red_center_v_index >= 120 && red_center_v_index < 240)begin
            synth1_amplitude <= (red_area >= detection_threshold)?3'd6:3'd0;
        end
        if (green_center_v_index < 120)begin
            synth2_amplitude <= (green_area >= detection_threshold)?3'd7:3'd0;
        end else if (green_center_v_index >= 120 && green_center_v_index < 240)begin
            synth2_amplitude <= (green_area >= detection_threshold)?3'd6:3'd0;
        end
        
        case (region)
            2'b0: begin 
                waveshape[0] <= SAW;
                waveshape[1] <= SAW;
                waveshape[2] <= SQUARE;
                waveshape[3] <= SQUARE;
            end         
            2'b01: begin
                waveshape[0] <= SAW;
                waveshape[1] <= SINE;
                waveshape[2] <= TRIANGLE;
                waveshape[3] <= SQUARE;
            end         
            2'b10: begin
                waveshape[0] <= TRIANGLE;
                waveshape[1] <= SAW;
                waveshape[2] <= TRIANGLE;
                waveshape[3] <= SAW;
            end 
        endcase
        
        if (sw[2]&&((hcount<320) &&  (vcount<240))) begin //If sw[2] show original image
            current_pixel <= raw_image_buff;
            raw_image_output_pixel_addr <= hcount+vcount*32'd320;
        end
        else if (~sw[2]&&((hcount<320) &&  (vcount<240))) begin //Otherwise show red mask image
            //Add green crosshair on center coordinates (if enough pixels are detected)
            current_pixel <= ((hcount==red_center_h_index) || (vcount==red_center_v_index))?((red_area >= detection_threshold)?12'hF0F:red_buff):red_buff;
            red_buff_output_pixel_addr <= hcount+vcount*32'd320;
        end
        else if (~sw[2]&&((hcount>=320) && (hcount<640) && (vcount<240))) begin //Show blue mask image next to it
            if (hcount == 426 || hcount == 533) begin
                current_pixel <= 12'hFF0;
            end 
            else begin //Add green crosshair on center coordinates (if enough pixels are detected)
                current_pixel <= ((hcount==blue_center_h_index+320) || (vcount==blue_center_v_index))?((blue_area >= detection_threshold)?12'hF0F:blue_buff):blue_buff;
                blue_buff_output_pixel_addr <= (hcount-11'd320)+vcount*32'd320;
            end 
        end
        else if (~sw[2]&&((hcount>=640) && (hcount<960) && (vcount<240))) begin //Show green mask image next to it
            //Add green crosshair on center coordinates (if enough pixels are detected)
            if (hcount >= 951) begin
                current_pixel <= 12'hFF0;
            end else begin
            current_pixel <= ((hcount==green_center_h_index+640) || (vcount==green_center_v_index))?((green_area >= detection_threshold)?12'hF0F:green_buff):green_buff;
            green_buff_output_pixel_addr <= (hcount-11'd640)+vcount*32'd320;
            end
        end
        
        //Show controls as vertical bar graphs
        else if (~sw[2] && (vcount>=240)) begin 
            if (hcount<320) begin //Show Red (Left hand) bars at hcount = 10-20, 110-120, 210-220 from vcount = (750 - range(var)) to 750
                if ((hcount>=10 && hcount<=20) && (vcount>=510 && vcount<=751)) begin //y position of red blob; range = 0 to 239 
                     current_pixel <= r_bar_1_border?12'hFFF:(vcount-511>red_center_v_index) ? ((red_area >= detection_threshold)? ((red_center_v_index>8'd120)?12'hA00:12'hF00):12'h000): 12'h000;                
                end 
                else if ((hcount>=110 && hcount<=120) && (vcount>=430 && vcount<=751)) begin //x position of red blob; ranges = 0 to 319
                     current_pixel <= r_bar_2_border?12'hFFF:(vcount-431>(319-red_center_h_index)) ? ((red_area >= detection_threshold)? 12'hF00:12'h000): 12'h000;         
                end 
                else if ((hcount>=210 && hcount<=220) && (vcount>=449 && vcount<=751)) begin //area of red blob; ranges = 0 to 76800 --> 450-750 for 300 buckets
                     current_pixel <= r_bar_3_border?12'hFFF:(vcount-449>(300-red_area_scaled)) ? ((red_area >= detection_threshold)? 12'hF00:12'h000): 12'h000;    
                end
                else current_pixel <= 12'h000;
            end
            else if (hcount>=320 && hcount<640) begin //Show Blue (Left hand) bars at hcount = 330-340, 430-440, 530-540 from vcount = (750 - range(var)) to 750 
                if ((hcount>=330 && hcount<=340) && (vcount>=510 && vcount<=751)) begin
                    current_pixel <= b_bar_1_border?12'hFFF:(vcount-511>blue_center_v_index) ?((blue_area >= detection_threshold)? 12'h00F:12'h000): 12'h000;
                end
                else if ((hcount>=430 && hcount<=440) && (vcount>=430 && vcount<=751)) begin 
                    current_pixel <= b_bar_2_border?12'hFFF:(vcount-431>(319-blue_center_h_index)) ?((blue_area >= detection_threshold)? 12'h00F:12'h000): 12'h000;
                end
                else if ((hcount>=530 && hcount<=540) && (vcount>=449 && vcount<=751)) begin //area of blue blob; ranges = 0 to 76800 --> 450-750 for 300 buckets
                    current_pixel <= b_bar_3_border?12'hFFF:(vcount-449>(300-blue_area_scaled)) ? ((blue_area >= detection_threshold)? 12'h00F:12'h000): 12'h000;
                end
                else current_pixel <= 12'h000;

            end 
            else if (hcount>=640 && hcount<960) begin //Show green (third limb) bars at hcount = 650-660, 750-760, 850-860 from vcount = (750 - range(var)) to 750 
                if ((hcount>=650 && hcount<=660) && (vcount>=510 && vcount<=751)) begin
                    current_pixel <= g_bar_1_border?12'hFFF:(vcount-511>green_center_v_index) ? ((green_area >= detection_threshold)?  ((green_center_v_index>8'd120)?12'h0A0:12'h0F0):12'h000): 12'h000;
                end
                else if ((hcount>=750 && hcount<=760) && (vcount>=430 && vcount<=751)) begin 
                    current_pixel <= g_bar_2_border?12'hFFF:(vcount-431>(319-green_center_h_index)) ? ((green_area >= detection_threshold)? 12'h0F0:12'h000): 12'h000;
                end
                else if ((hcount>=850 && hcount<=860) && (vcount>=449 && vcount<=751)) begin //area of green blob; ranges = 0 to 76800 --> 450-750 for 300 buckets
                    current_pixel <= g_bar_3_border?12'hFFF:(vcount-449>(300-green_area_scaled)) ? ((green_area >= detection_threshold)? 12'h0F0:12'h000): 12'h000;
                end
                else current_pixel <= 12'h000;
            end  
        end 
        else begin
            current_pixel <= 12'h000;
        end  
    end
    
    always_ff @(posedge clk_65mhz) begin
        //right shift buffers and insert new value on left
        hsync_buff <= {hsync, hsync_buff[3:1]};
        vsync_buff <= {vsync, vsync_buff[3:1]};
        blank_buff <= {blank, blank_buff[3:1]};

    end 
    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~blank_buff[0] ? current_pixel[11:8]: 0;
    assign vga_g = ~blank_buff[0] ? current_pixel[7:4] : 0;
    assign vga_b = ~blank_buff[0] ? current_pixel[3:0] : 0;
    assign vga_hs = ~hsync_buff[0];
    assign vga_vs = ~vsync_buff[0];
         
    oscillator lfo (
        .clk_in(clk_65mhz),
        .rst_in(reset),
        .step_in(sample_trigger),
        .shape_in(lfo_shape),
        .frequency_in(lfo_frequency),
        .wave_out(lfo_osc_out));
    
    amplitude_control lfo_amp (
        .amplitude_in(lfo_amplitude), 
        .signal_in(lfo_osc_out), 
        .signal_out(lfo_out));  
             
    synthesizer synth1(
        .frequency_in(synth1_frequency),
        .osc2_tune_in(synth1_osc2_tune),
        .osc1_shape_in(synth1_osc1_shape),
        .osc2_shape_in(synth1_osc2_shape),
        .amplitude_in(synth1_amplitude),
        .filter_cutoff_in(filter_cutoff),
        .trigger_in(sample_trigger),
        .rst_in(reset), 
        .clk_in(clk_65mhz),
        .audio_out(synth1_out));
        
    synthesizer synth2(
        .frequency_in(synth2_frequency),
        .osc2_tune_in(synth2_osc2_tune),
        .osc1_shape_in(synth2_osc1_shape),
        .osc2_shape_in(synth2_osc2_shape),
        .amplitude_in(synth2_amplitude),
        .filter_cutoff_in(filter_cutoff),
        .trigger_in(sample_trigger),
        .rst_in(reset),
        .clk_in(clk_65mhz),
        .audio_out(synth2_out));
        
    mixer synth_mixer(
        .wave1_in(synth1_out),
        .wave2_in(synth2_out),
        .mixed_out(all_synth_out));
        
    pwm pwm_out(
        .clk_in(clk_65mhz), 
        .rst_in(reset), 
        .level_in({~all_synth_out[7],all_synth_out[6:0]}),
        .pwm_out(pwm_val));
    assign aud_pwm = pwm_val?1'bZ:1'b0; 
    
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
     
    .green_buff_out(green_buff),
    .green_buff_output_pixel_addr(green_buff_output_pixel_addr),  

    .red_center_valid(red_valid),
    .red_area_out(red_area),
    .red_center_v_index_out(red_center_v_index),
    .red_center_h_index_out(red_center_h_index),
   
    .blue_center_valid(blue_valid),
    .blue_area_out(blue_area),
    .blue_center_v_index_out(blue_center_v_index),
    .blue_center_h_index_out(blue_center_h_index),
    
    .green_center_valid(green_valid),
    .green_area_out(green_area),
    .green_center_v_index_out(green_center_v_index),
    .green_center_h_index_out(green_center_h_index)
   );
                   
                   ila_1 my_ila(.clk(clk_65mhz),
                                .probe0(red_area_scaled),
                                .probe1(vcount),
                                .probe2(hcount),
                                .probe3(vcount-450<=red_area_scaled));
endmodule
