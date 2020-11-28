//Amplitude Control
module amplitude_control (input [2:0] amplitude_in, input signed [7:0] signal_in, output logic signed[7:0] signal_out);
    logic [2:0] shift;
    assign shift = 3'd7 - amplitude_in;
    assign signal_out = signal_in>>>shift;
endmodule