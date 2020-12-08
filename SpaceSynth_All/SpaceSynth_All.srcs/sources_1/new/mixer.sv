//2 Signal Mixer. halves the amplitude of both incoming signals before adding them together
module mixer (  input logic signed[15:0] wave1_in, input logic signed [15:0] wave2_in, 
                output logic signed [15:0] mixed_out);
        assign mixed_out = (wave1_in>>>1)+(wave2_in>>>1);
endmodule