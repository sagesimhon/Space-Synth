`default_nettype none    // catch typos!
`timescale 1ns / 1ps 

// test fir31 module
// input samples are read from fir31.samples
// output samples are written to fir31.output
module oscillator_tb();
  logic signed [31:0] frq; 
  logic clk;  //clock and reset
  logic signed [31:0] out;  
    
  filter filter1 (.frequency_in(frq),.filter_out(out));
  
  always #5 clk = !clk;
  
  initial begin
    frq = 32'sd2000;
    #100; 
  end

endmodule
