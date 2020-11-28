//2 Signal Mixer
module mixer (  input [7:0] wave1_in, input [7:0] wave2_in, 
                output logic [7:0] mixed_out);
        assign mixed_out = (wave1_in>>>1)+(wave2_in>>>1);
endmodule