`timescale 1ns / 1ps

module top_level(
       //FPGA controls and displays
       input clk_100mhz,
       input[15:0] sw,
       output[15:0] led,
        
       //PMOD pins for camera
       input [7:0] ja, 
       input [2:0] jb,
       input [2:0] jd,
       output   jbclk, 
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
        
    localparam SINE = 2'd0;
    localparam SQUARE = 2'd1;
    localparam TRIANGLE = 2'd2;
    localparam SAW = 2'd3;
    
    //Generate trigger signal for audio samples
    assign sample_trigger = (sample_counter == SAMPLE_COUNT);
    always_ff @(posedge clk_65mhz)begin
        if (sample_counter == SAMPLE_COUNT)begin
            sample_counter <= 16'b0;
        end else begin
            sample_counter <= sample_counter + 16'b1;
        end
    end

    assign led = sw;
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
    logic [4:0] hsync_buff, vsync_buff, blank_buff = 5'b0;
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
    
    //Synthesizer outputs
    logic signed[15:0] synth1_out;
    logic signed[15:0] synth2_out;
    logic signed[15:0] all_synth_out;
    
    //Synth oscillator waveform shapes
    logic [1:0] synth1_osc1_shape;
    logic [1:0] synth1_osc2_shape;
    
    logic [1:0] synth2_osc1_shape;
    logic [1:0] synth2_osc2_shape;
    
    //Synth oscillator tuning. Tune synth 1 one octave down
    // and synth 2 two octaves down. Other combos work, but aren't
    // as pleasing as this. So we'll keep em constant for now
    logic [2:0] synth1_osc2_tune;
    assign synth1_osc2_tune = 3'd2;
    
    logic [2:0] synth2_osc2_tune;
    assign synth2_osc2_tune = 3'd3;
    
    
    //Frequency variables. The synths have a max input frequency
    // of 2^12 or 4096Hz
    logic [11:0] synth1_frequency;
    logic [11:0] synth2_frequency;
    
    //Filter cutoff frequency. A '0' is a cutoff frequency of 100hz
    // and '255' is a cutoff frequency of 5000Hz. It's good enough
    logic [7:0] filter_cutoff;
    
    //Synth amplitude. Since we're using 16bit (signed) audio signals,
    // we can shift for 16 different volume levels 
    logic [3:0] synth1_amplitude;
    logic [3:0] synth2_amplitude;
    
    //Switch to enable/disable LFO
    logic lfo_enabled;
    assign lfo_enabled = sw[14];
    
    //Complentary variables for LFO. Works the same way as the synth oscillators.
    logic signed[15:0] lfo_out;
    logic signed[15:0] lfo_osc_out;
    logic [11:0] lfo_frequency;
    logic [3:0] lfo_amplitude;
    logic [1:0] lfo_shape;
    assign lfo_shape = sw[1:0]; //LFO shape is assignable via switches.
    
    //Variables for changing waveshape presets 
    logic [1:0] region;
    logic [3:0] waveshape;
    logic [11:0] waveshape_bar_color;
    localparam preset1 = 2'd0;
    localparam preset2 = 2'd1;
    localparam preset3 = 2'd2;
    
    //'Boolean' values for knowing when to draw borders for bar graphs
    logic r_bar_1_border, r_bar_2_border, r_bar_3_border, b_bar_1_border, b_bar_2_border, b_bar_3_border, 
        g_bar_1_border, g_bar_2_border, g_bar_3_border = 1'b0;
    
    //pixel area scaled by right shifting by 8 (76800/256 normalizes to 300)
    logic [8:0] red_area_scaled, blue_area_scaled, green_area_scaled; 
    
    //Image of Synth
    logic [10:0] x_in = 0;
    logic [9:0] y_in = 240;
    logic [11:0] synth_pix;
    
    always_comb begin
        //Figure out when to draw border for the bar graphs 
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
        
        //Switch waveshape preset based on what region we're in (but only if we're above the detection threshold!)
        if(blue_area >= detection_threshold) begin
            region = (blue_center_h_index < 106) ? 2'b0 : (blue_center_h_index < 213) ? 2'b1 : 2'b10;
        end
        synth1_osc1_shape = waveshape[0];
        synth1_osc2_shape = waveshape[1];
        synth2_osc1_shape = waveshape[2];
        synth2_osc2_shape = waveshape[3];   
    end
    
    assign blue_buff_output_pixel_addr = (hcount-11'd320)+vcount*32'd320;
    assign red_buff_output_pixel_addr = hcount+vcount*32'd320;
    assign green_buff_output_pixel_addr = (hcount-11'd640)+vcount*32'd320;
    
    always_ff @(posedge clk_65mhz) begin
        
        /*
        *LFO frequency and depth are proportional to area of both hands(red and green)
        */
        lfo_frequency <= (lfo_enabled)? (red_area >= detection_threshold)?(red_area>>9):12'd0:12'd0;//(red_area < lfo_threshold) 
        lfo_amplitude <= (lfo_enabled)? (green_area >= detection_threshold)?(green_area>>10):4'd0:4'd0 ;//(green_area < lfo_threshold)
        
        /*
        *Synth frequencies is proportional to vertical positions of each hand(red and green) and influenced by LFO
        * Frequency for both senthesizers is determined by taking a base frequency of 100Hz and adding the 
        * horizontal position of the hand as well as the signal from the LFO. If the frequency drops below zero, 
        * (which it will, since we're working with low frequencies here) give 0 frequency rather than letting
        * it rollover
        */
        synth1_frequency <= (red_area >= detection_threshold)?(lfo_enabled?(($signed(lfo_out+12'd200+red_center_h_index) >= 12'sd0)?(12'd200+red_center_h_index+lfo_out):12'd0):(12'd200+red_center_h_index)):12'd0;
        synth2_frequency <= (green_area >= detection_threshold)?(lfo_enabled?(($signed(lfo_out+12'd200+green_center_h_index) >= 12'sd0)?(12'd200+green_center_h_index+lfo_out):12'd0):(12'd200+green_center_h_index)):12'd0;        
        
        /*
        *Filter cutoff frequency is proportional to horizontal distance between two hands(red and green)
        * Filter is only active when both hands are on screen, otherwise it defaults to 255 (practically no filter)
        */
        filter_cutoff <= (((green_center_h_index - red_center_h_index) <= 255) && (red_area >= detection_threshold) && (green_area >= detection_threshold)) ? (green_center_h_index - red_center_h_index) : 255; //abs value? currently only works if green is to the right of red
        
        /*
        *Create two vertical amplitude zones for both synthesizers
        * Sound is full-amplitude when hands are on top half of screen,
        * and hald amplitude when hands are on bottom half
        */
        if (red_center_v_index < 120)begin
            synth1_amplitude <= (red_area >= detection_threshold)?4'd15:4'd0;
        end else if (red_center_v_index >= 120 && red_center_v_index < 240)begin
            synth1_amplitude <= (red_area >= detection_threshold)?4'd14:4'd0;
        end
        if (green_center_v_index < 120)begin
            synth2_amplitude <= (green_area >= detection_threshold)?4'd15:4'd0;
        end else if (green_center_v_index >= 120 && green_center_v_index < 240)begin
            synth2_amplitude <= (green_area >= detection_threshold)?4'd14:4'd0;
        end
        
        
        /*
        *Switch between three waveshape zones (controlled by x-position of blue)
        */
        case (region)
            preset1: begin 
                waveshape[0] <= SAW;
                waveshape[1] <= SAW;
                waveshape[2] <= SQUARE;
                waveshape[3] <= SQUARE;
                waveshape_bar_color <= 12'h00A;
            end         
            preset2: begin
                waveshape[0] <= SAW;
                waveshape[1] <= SINE;
                waveshape[2] <= TRIANGLE;
                waveshape[3] <= SQUARE;
                waveshape_bar_color <= 12'h00F;
            end         
            preset3: begin
                waveshape[0] <= TRIANGLE;
                waveshape[1] <= SAW;
                waveshape[2] <= TRIANGLE;
                waveshape[3] <= SAW;
                waveshape_bar_color <= 12'hBBF;
            end 
            default: begin 
                waveshape[0] <= TRIANGLE;
                waveshape[1] <= SAW;
                waveshape[2] <= TRIANGLE;
                waveshape[3] <= SAW;
                waveshape_bar_color <= 12'h00F;
            end    
        endcase
        
        /*
        *Scale pixel area down to 300 so we can show it on the graph
        */
        red_area_scaled <= ((red_area>>4)<= 9'd300)?(red_area>>4):9'd300;
        green_area_scaled <= ((green_area>>4)<= 9'd300)?(green_area>>4):9'd300;
        blue_area_scaled <= ((blue_area>>4)<= 9'd300)?(blue_area>>4):9'd300;
        
        /*
        *Draw camera image frames with crosshairs (if applicable)
        */
        if (sw[2]&&((hcount<320) &&  (vcount<240))) begin //If sw[2] show original image
            current_pixel <= raw_image_buff;
            raw_image_output_pixel_addr <= hcount+vcount*32'd320;
        end
        else if (~sw[2]&&((hcount<320) &&  (vcount<240))) begin //Otherwise show red mask image
            //Add magenta crosshair on center coordinates (if enough pixels are detected)
            current_pixel <= ((hcount==red_center_h_index) || (vcount==red_center_v_index))?((red_area >= detection_threshold)?12'hF0F:red_buff):red_buff;
            //red_buff_output_pixel_addr <= hcount+vcount*32'd320;
        end
        else if (~sw[2]&&((hcount>=320) && (hcount<640) && (vcount<240))) begin //Show blue mask image next to it
            if (hcount == 426 || hcount == 533) begin
                current_pixel <= 12'hFF0;
            end 
            else begin //Add magenta crosshair on center coordinates (if enough pixels are detected)
                current_pixel <= ((hcount==blue_center_h_index+320) || (vcount==blue_center_v_index))?((blue_area >= detection_threshold)?12'hF0F:blue_buff):blue_buff;
                //blue_buff_output_pixel_addr <= (hcount-11'd320)+vcount*32'd320;
            end 
        end
        else if (~sw[2]&&((hcount>=640) && (hcount<960) && (vcount<240))) begin //Show green mask image next to it
            //Add magenta crosshair on center coordinates (if enough pixels are detected)
            current_pixel <= ((hcount==green_center_h_index+640) || (vcount==green_center_v_index))?((green_area >= detection_threshold)?12'hF0F:green_buff):green_buff;
            //green_buff_output_pixel_addr <= (hcount-11'd640)+vcount*32'd320;
        end
        
        //Show labels in middle
        else if ((vcount>=240)&& (vcount< 430)) begin
            current_pixel <= synth_pix; 
        end 
        
        /*
        *Show controls as vertical bar graphs on the bottom of the screen
        */
        else if (~sw[2] && (vcount>=430)) begin 
            if (hcount<320) begin //Show Red (Left hand) bars at hcount = 10-20, 110-120, 210-220 from vcount = (750 - range(var)) to 750
                if ((hcount>=10 && hcount<=20) && (vcount>=510 && vcount<=751)) begin //y position of red blob; range = 0 to 239 
                     current_pixel <= r_bar_1_border?12'hFFF:(vcount-511>red_center_v_index) ? ((red_area >= detection_threshold)? ((red_center_v_index>8'd120)?12'hA00:12'hF99):12'h000): 12'h000;              
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
                    current_pixel <= b_bar_2_border?12'hFFF:(vcount-431>(319-blue_center_h_index)) ?((blue_area >= detection_threshold)? waveshape_bar_color:12'h000): 12'h000;
                end
                else if ((hcount>=530 && hcount<=540) && (vcount>=449 && vcount<=751)) begin //area of blue blob; ranges = 0 to 76800 --> 450-750 for 300 buckets
                    current_pixel <= b_bar_3_border?12'hFFF:(vcount-449>(300-blue_area_scaled)) ? ((blue_area >= detection_threshold)? 12'h00F:12'h000): 12'h000;
                end
                else current_pixel <= 12'h000;
            end 
            else if (hcount>=640 && hcount<960) begin //Show green (third limb) bars at hcount = 650-660, 750-760, 850-860 from vcount = (750 - range(var)) to 750 
                if ((hcount>=650 && hcount<=660) && (vcount>=510 && vcount<=751)) begin
                    current_pixel <= g_bar_1_border?12'hFFF:(vcount-511>green_center_v_index) ? ((green_area >= detection_threshold)?  ((green_center_v_index>8'd120)?12'h0A0:12'h9F9):12'h000): 12'h000;
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
        hsync_buff <= {hsync, hsync_buff[4:1]};
        vsync_buff <= {vsync, vsync_buff[4:1]};
        blank_buff <= {blank, blank_buff[4:1]};
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
        .level_in({~all_synth_out[15],all_synth_out[14:0]}),
        .pwm_out(pwm_val));
    assign aud_pwm = pwm_val?1'bZ:1'b0; 
    
   //All of the image processing is done inside this big module
   camera_to_mask color_blobs(
    .clk_65mhz(clk_65mhz),
    .reset(reset), 
    .thresh_on(sw[10:7]),
    .ja_p(ja), 
    .jb_p(jb), 
    .jd_p(jd),
    .jbclk_p(jbclk), 
    .jdclk_p(jdclk),   
  
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
   
   image_ROM_synth synth_blob(
    .pixel_clk_in(clk_65mhz),
    .x_in(x_in),
    .hcount_in(hcount),
    .y_in(y_in),
    .vcount_in(vcount),
    .pixel_out(synth_pix)
    );
             
endmodule
