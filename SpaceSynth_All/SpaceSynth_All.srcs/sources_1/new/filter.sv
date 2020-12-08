//First Order IIR
module filter ( input logic [7:0] frequency_in,
                input logic signed [15:0] waveform_in,
                input step_in, input rst_in, input clk_in,
                output logic signed [15:0] filtered_out);
        
        parameter DO_NOTHING = 3'd0;
        parameter B0_TERM = 3'd1;
        parameter B1_TERM = 3'd2;
        parameter A1_TERM = 3'd3;
        parameter DONE = 3'd4;
        
        logic signed [15:0] a1;
        logic signed [15:0] b0;
        filter_coeffs fc(.clk_in(clk_in), .cutoff_value_in(frequency_in), .a1_out(a1), .b0_out(b0));
        
        logic signed [31:0] sum;
        
        //Single multiplier
        logic signed [16:0] mult2;
        logic signed [15:0] mult1;
        logic signed [31:0] mult_out;
        assign mult_out = mult1*mult2;
        
        logic signed [15:0] previous_input;
        logic signed [31:0] previous_output;
        
        logic [2:0] state;
        
        always_ff @(posedge clk_in)begin
            if (rst_in)begin
                previous_input <= 8'b0;
                previous_output <= 8'b0;
                state <= DO_NOTHING;
            end else begin
                if (step_in) begin
                    state <= B0_TERM;
                    mult1 <= b0;
                    mult2 <= waveform_in;
                    sum <= 0;
                end
                
                case(state)
                    DO_NOTHING: begin
                          end
                    B0_TERM: begin
                            sum <= sum + (mult_out>>>15);
                            mult1 <= b0;
                            mult2 <= previous_input;
                            state <= B1_TERM;
                          end
                    B1_TERM: begin
                            sum <= sum + (mult_out>>>15);
                            mult1 <= a1;
                            mult2 <= previous_output;
                            state <= A1_TERM;
                          end
                    A1_TERM: begin
                            sum <= sum + (mult_out>>>15);
                            state <= DONE;
                          end
                    DONE: begin
                            filtered_out <= {sum[31],sum[15:1]};
                            previous_input <= waveform_in;
                            previous_output <= sum;
                            state <= DO_NOTHING;
                          end
                    default: state <= DO_NOTHING;
                endcase
            end
        end
endmodule