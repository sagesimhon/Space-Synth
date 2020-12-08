//Amplitude Control
module amplitude_control (input [3:0] amplitude_in, input signed [15:0] signal_in, output logic signed[15:0] signal_out);
    logic [2:0] shift;
    assign shift = 4'd15 - amplitude_in;
    assign signal_out = signal_in>>>shift;
endmodule