//PWM generator for audio output. Compares the incoming audio sample to a 
// fast moving ramp function (in this case about 500kHz) to set the pwm pulsw width
// This is 'integrated' by the output lowpass filter to produce analog audio
module pwm (input clk_in, input rst_in, input [15:0] level_in, output logic pwm_out);
    logic [15:0] count;
    assign pwm_out = count<level_in;
    always_ff @(posedge clk_in)begin
        if (rst_in)begin
            count <= 16'b0;
        end else begin
            count <= count+16'd512;
        end
    end
endmodule