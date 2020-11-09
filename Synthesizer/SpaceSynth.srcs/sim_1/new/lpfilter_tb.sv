`default_nettype none    // catch typos!
`timescale 1ns / 1ps 

// test fir31 module
// input samples are read from fir31.samples
// output samples are written to fir31.output
module lpfilter_tb();
  logic [7:0] frequency_in;
  logic signed [7:0] waveform_in;
  logic signed [7:0] waveform_in_prev;
  logic step_in;
  logic ready;
  logic rst_in; 
  logic clk;
  logic signed [7:0] filtered_out; 
  logic [3:0] counter;
  logic [7:0] second_counter;
  
  filter filter1 (.frequency_in(frequency_in), .waveform_in(waveform_in), .step_in(step_in), .rst_in(rst_in), .clk_in(clk), .filtered_out(filtered_out), .ready_out(ready));
  
  always #5 clk = !clk;
  
  initial begin
    clk = 0;
    frequency_in = 8'd0;
    waveform_in = 8'sd0;
    waveform_in_prev = 8'sd0;
    step_in = 0;
    rst_in = 0;
    counter = 4'd0;
    second_counter = 8'd0;
    #100;
    
    rst_in = 1;
    #20;
    rst_in = 0;
    
  end
  
  always @(posedge clk) begin 
    counter = counter + 4'd1;
    if (counter == 4'd15)begin
        step_in = 1'b1;
        second_counter = second_counter+8'd1;
    end
    else begin
        step_in = 1'b0;
    end
    
    if (second_counter >= 8'd128) begin
        waveform_in = 8'sd127;
    end else begin
        waveform_in = -8'sd128;
    end
    
    if ((waveform_in==8'sd127) && (waveform_in_prev==-8'sd128)) begin
        frequency_in = frequency_in + 8'd10;
    end
    
    waveform_in_prev = waveform_in;
  end 
  
endmodule