module synthesizer (input logic [11:0] frequency_in,
                    input logic [2:0] osc2_tune_in,
                    input logic [1:0] osc1_shape_in,
                    input logic [1:0] osc2_shape_in,
                    input logic [3:0] amplitude_in,
                    input logic [7:0] filter_cutoff_in,
                    input trigger_in, input rst_in, input clk_in,
                    output logic signed [15:0] audio_out
                    );
    
    //Intermediates
    logic signed [15:0] oscillator1_output;
    logic signed [15:0] oscillator2_output;
    logic signed [15:0] mixer_out;
    logic signed [15:0] filter_out;             
    
    //Osc 2 Tuning
    parameter OCTAVEp3 = 3'd6;
    parameter OCTAVEp2 = 3'd5;
    parameter OCTAVEp1 = 3'd4;
    parameter OCTAVEp0 = 3'd3;
    parameter OCTAVEm1 = 3'd2;
    parameter OCTAVEm2 = 3'd1;
    parameter OCTAVEm3 = 3'd0;
    
    logic [11:0] osc2_frequency;
    always_comb begin
        case (osc2_tune_in)
            OCTAVEp3: osc2_frequency = frequency_in<<3;
            OCTAVEp2: osc2_frequency = frequency_in<<2;
            OCTAVEp1: osc2_frequency = frequency_in<<1;
            OCTAVEp0: osc2_frequency = frequency_in;
            OCTAVEm1: osc2_frequency = frequency_in>>1;
            OCTAVEm2: osc2_frequency = frequency_in>>2;
            OCTAVEm3: osc2_frequency = frequency_in>>3;
            default:  osc2_frequency = frequency_in;
        endcase
    end
    
    oscillator osc1 (.clk_in(clk_in),.rst_in(rst_in),.step_in(trigger_in),.shape_in(osc1_shape_in),.frequency_in(frequency_in),.wave_out(oscillator1_output));
    oscillator osc2 (.clk_in(clk_in),.rst_in(rst_in),.step_in(trigger_in),.shape_in(osc2_shape_in),.frequency_in(osc2_frequency),.wave_out(oscillator2_output));
    mixer oscmixer  (.wave1_in(oscillator1_output),.wave2_in(oscillator2_output),.mixed_out(mixer_out));
    filter lpfilter (.clk_in(clk_in),.rst_in(rst_in),.step_in(trigger_in),.frequency_in(filter_cutoff_in),.waveform_in(mixer_out),.filtered_out(filter_out));                                                                                       
    amplitude_control amp (.amplitude_in(amplitude_in), .signal_in(filter_out), .signal_out(audio_out));   
endmodule
