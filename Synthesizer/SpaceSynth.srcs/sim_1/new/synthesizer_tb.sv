`default_nettype none    // catch typos!
`timescale 1ns / 1ps 

// test fir31 module
// input samples are read from fir31.samples
// output samples are written to fir31.output
module synthesizer_tb();
  logic [11:0] frequency;
  logic [2:0] osc2_tune;
  logic [1:0] osc1_shape;
  logic [1:0] osc2_shape;
  logic [2:0] amplitude;
  logic [7:0] filter_cutoff;
  logic trigger; 
  logic rst; 
  logic clk;
  logic signed [7:0] audio_out;
  
  logic [3:0] counter;
  logic [7:0] second_counter;
  logic cutoff_change_clock;
  logic cutoff_change_clock_prev;
  
  synthesizer synth1(.frequency_in(frequency),.osc2_tune_in(osc2_tune),.osc1_shape_in(osc1_shape),.osc2_shape_in(osc2_shape),.amplitude_in(amplitude),.filter_cutoff_in(filter_cutoff),.trigger_in(trigger), .rst_in(rst), .clk_in(clk),.audio_out(audio_out));
  
  always #5 clk = !clk;
  
  initial begin
    clk = 0;
    rst = 0;
    frequency = 12'd200;
    osc2_tune = 3'd0;
    osc1_shape = 2'd0;
    osc2_shape = 2'd1;
    amplitude = 3'd7;
    filter_cutoff = 8'd0;
    trigger = 1'd0;
    
    counter = 4'd0;
    second_counter = 8'd0;
    cutoff_change_clock = 8'd0;
    cutoff_change_clock = 1'b0;
    cutoff_change_clock_prev = 1'b0;
    #100;
    
    rst = 1;
    #20;
    rst = 0;
    
  end
  
  always @(posedge clk) begin 
    counter = counter + 4'd1;
    if (counter == 4'd15)begin
        trigger = 1'b1;
        second_counter = second_counter+8'd1;
    end
    else begin
        trigger = 1'b0;
    end
    
    if (second_counter >= 8'd128) begin
        cutoff_change_clock = 1'b1;
    end else begin
        cutoff_change_clock = 1'b0;
    end
    
    if ((cutoff_change_clock) && (~cutoff_change_clock_prev)) begin
        filter_cutoff = filter_cutoff + 8'd10;
    end
    
    cutoff_change_clock_prev = cutoff_change_clock;
  end 
  
endmodule

