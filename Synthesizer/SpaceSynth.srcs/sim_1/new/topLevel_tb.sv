`default_nettype none    // catch typos!
`timescale 1ns / 1ps 

// test fir31 module
// input samples are read from fir31.samples
// output samples are written to fir31.output
module oscillator_tb();
  logic clk; 
  logic rst;  //clock and reset
  logic step;  //trigger a phase step (rate at which you run sine generator)
  logic [1:0] shape; 
  logic [11:0] frequency; 
  
  logic [7:0] wave_out; 
    
  oscillator osc1 (.clk_in(clk),.rst_in(rst),.step_in(step),.shape_in(shape),.frequency_in(frequency),.wave_out(wave_out));
  
  always #5 clk = !clk;
  
  initial begin
    clk = 0;
    shape = 2;
    step = 0;
    frequency = 1000;
    #100; 
    
    rst = 1;
    #20
    rst = 0;
    
  end
  
  always @(posedge clk) begin 
    step = !step;
  end 

 
    

  

endmodule
