//Waveform Generator
module oscillator ( input clk_in, input rst_in, //clock and reset
                    input step_in, //trigger a phase step (rate at which you run sine generator)
                    input [1:0] shape_in,
                    input [11:0] frequency_in,
                    output logic signed [7:0] wave_out); //output wave   
    
    parameter SINE = 2'd0;
    parameter SQUARE = 2'd1;
    parameter TRIANGLE = 2'd2;
    parameter SAW = 2'd3;
    
    logic [31:0] phase_step;
    logic [31:0] phase;
    logic [7:0] amp;
    
    logic [7:0] sine_wave;
    sine_lut lut_1(.clk_in(clk_in), .phase_in(phase[31:24]), .amp_out(sine_wave));
    logic [7:0] square_wave;
    logic [7:0] triangle_wave;
    logic dir_flag;
    
    always_ff @(posedge clk_in)begin
        if (rst_in)begin
            phase_step <= 32'b0;
            phase <= 32'b0;
            dir_flag <= 0;
        end else if (step_in)begin
            phase <= phase+phase_step;
        end
        phase_step <= frequency_in * 32'd89478;
        
        case(shape_in)
            SINE: wave_out <= {~sine_wave[7],sine_wave[6:0]};
            SQUARE: begin
                        square_wave <= phase[31]?8'd0:8'd255;
                        wave_out <= {~square_wave[7],square_wave[6:0]};
                    end
            TRIANGLE: begin
                        if (phase[31]) begin
                            triangle_wave <= phase[30:23];
                            wave_out <= {~triangle_wave[7],triangle_wave[6:0]};
                        end
                        else begin
                            triangle_wave <= 8'd255 - phase[30:23];
                            wave_out <= {~triangle_wave[7],triangle_wave[6:0]};
                        end
                      end
            SAW : wave_out <= phase[31:24];
        endcase
    end
    
endmodule

//8bit sine lookup, 8bit depth
module sine_lut(input[7:0] phase_in, input clk_in, output logic[7:0] amp_out);
  always_ff @(posedge clk_in)begin
    case(phase_in)
        8'd0: amp_out<=8'd127;
        8'd1: amp_out<=8'd130;
        8'd2: amp_out<=8'd133;
        8'd3: amp_out<=8'd136;
        8'd4: amp_out<=8'd139;
        8'd5: amp_out<=8'd143;
        8'd6: amp_out<=8'd146;
        8'd7: amp_out<=8'd149;
        8'd8: amp_out<=8'd152;
        8'd9: amp_out<=8'd155;
        8'd10: amp_out<=8'd158;
        8'd11: amp_out<=8'd161;
        8'd12: amp_out<=8'd164;
        8'd13: amp_out<=8'd167;
        8'd14: amp_out<=8'd170;
        8'd15: amp_out<=8'd173;
        8'd16: amp_out<=8'd176;
        8'd17: amp_out<=8'd178;
        8'd18: amp_out<=8'd181;
        8'd19: amp_out<=8'd184;
        8'd20: amp_out<=8'd187;
        8'd21: amp_out<=8'd190;
        8'd22: amp_out<=8'd192;
        8'd23: amp_out<=8'd195;
        8'd24: amp_out<=8'd198;
        8'd25: amp_out<=8'd200;
        8'd26: amp_out<=8'd203;
        8'd27: amp_out<=8'd205;
        8'd28: amp_out<=8'd208;
        8'd29: amp_out<=8'd210;
        8'd30: amp_out<=8'd212;
        8'd31: amp_out<=8'd215;
        8'd32: amp_out<=8'd217;
        8'd33: amp_out<=8'd219;
        8'd34: amp_out<=8'd221;
        8'd35: amp_out<=8'd223;
        8'd36: amp_out<=8'd225;
        8'd37: amp_out<=8'd227;
        8'd38: amp_out<=8'd229;
        8'd39: amp_out<=8'd231;
        8'd40: amp_out<=8'd233;
        8'd41: amp_out<=8'd234;
        8'd42: amp_out<=8'd236;
        8'd43: amp_out<=8'd238;
        8'd44: amp_out<=8'd239;
        8'd45: amp_out<=8'd240;
        8'd46: amp_out<=8'd242;
        8'd47: amp_out<=8'd243;
        8'd48: amp_out<=8'd244;
        8'd49: amp_out<=8'd245;
        8'd50: amp_out<=8'd247;
        8'd51: amp_out<=8'd248;
        8'd52: amp_out<=8'd249;
        8'd53: amp_out<=8'd249;
        8'd54: amp_out<=8'd250;
        8'd55: amp_out<=8'd251;
        8'd56: amp_out<=8'd252;
        8'd57: amp_out<=8'd252;
        8'd58: amp_out<=8'd253;
        8'd59: amp_out<=8'd253;
        8'd60: amp_out<=8'd253;
        8'd61: amp_out<=8'd254;
        8'd62: amp_out<=8'd254;
        8'd63: amp_out<=8'd254;
        8'd64: amp_out<=8'd254;
        8'd65: amp_out<=8'd254;
        8'd66: amp_out<=8'd254;
        8'd67: amp_out<=8'd254;
        8'd68: amp_out<=8'd253;
        8'd69: amp_out<=8'd253;
        8'd70: amp_out<=8'd253;
        8'd71: amp_out<=8'd252;
        8'd72: amp_out<=8'd252;
        8'd73: amp_out<=8'd251;
        8'd74: amp_out<=8'd250;
        8'd75: amp_out<=8'd249;
        8'd76: amp_out<=8'd249;
        8'd77: amp_out<=8'd248;
        8'd78: amp_out<=8'd247;
        8'd79: amp_out<=8'd245;
        8'd80: amp_out<=8'd244;
        8'd81: amp_out<=8'd243;
        8'd82: amp_out<=8'd242;
        8'd83: amp_out<=8'd240;
        8'd84: amp_out<=8'd239;
        8'd85: amp_out<=8'd238;
        8'd86: amp_out<=8'd236;
        8'd87: amp_out<=8'd234;
        8'd88: amp_out<=8'd233;
        8'd89: amp_out<=8'd231;
        8'd90: amp_out<=8'd229;
        8'd91: amp_out<=8'd227;
        8'd92: amp_out<=8'd225;
        8'd93: amp_out<=8'd223;
        8'd94: amp_out<=8'd221;
        8'd95: amp_out<=8'd219;
        8'd96: amp_out<=8'd217;
        8'd97: amp_out<=8'd215;
        8'd98: amp_out<=8'd212;
        8'd99: amp_out<=8'd210;
        8'd100: amp_out<=8'd208;
        8'd101: amp_out<=8'd205;
        8'd102: amp_out<=8'd203;
        8'd103: amp_out<=8'd200;
        8'd104: amp_out<=8'd198;
        8'd105: amp_out<=8'd195;
        8'd106: amp_out<=8'd192;
        8'd107: amp_out<=8'd190;
        8'd108: amp_out<=8'd187;
        8'd109: amp_out<=8'd184;
        8'd110: amp_out<=8'd181;
        8'd111: amp_out<=8'd178;
        8'd112: amp_out<=8'd176;
        8'd113: amp_out<=8'd173;
        8'd114: amp_out<=8'd170;
        8'd115: amp_out<=8'd167;
        8'd116: amp_out<=8'd164;
        8'd117: amp_out<=8'd161;
        8'd118: amp_out<=8'd158;
        8'd119: amp_out<=8'd155;
        8'd120: amp_out<=8'd152;
        8'd121: amp_out<=8'd149;
        8'd122: amp_out<=8'd146;
        8'd123: amp_out<=8'd143;
        8'd124: amp_out<=8'd139;
        8'd125: amp_out<=8'd136;
        8'd126: amp_out<=8'd133;
        8'd127: amp_out<=8'd130;
        8'd128: amp_out<=8'd127;
        8'd129: amp_out<=8'd124;
        8'd130: amp_out<=8'd121;
        8'd131: amp_out<=8'd118;
        8'd132: amp_out<=8'd115;
        8'd133: amp_out<=8'd111;
        8'd134: amp_out<=8'd108;
        8'd135: amp_out<=8'd105;
        8'd136: amp_out<=8'd102;
        8'd137: amp_out<=8'd99;
        8'd138: amp_out<=8'd96;
        8'd139: amp_out<=8'd93;
        8'd140: amp_out<=8'd90;
        8'd141: amp_out<=8'd87;
        8'd142: amp_out<=8'd84;
        8'd143: amp_out<=8'd81;
        8'd144: amp_out<=8'd78;
        8'd145: amp_out<=8'd76;
        8'd146: amp_out<=8'd73;
        8'd147: amp_out<=8'd70;
        8'd148: amp_out<=8'd67;
        8'd149: amp_out<=8'd64;
        8'd150: amp_out<=8'd62;
        8'd151: amp_out<=8'd59;
        8'd152: amp_out<=8'd56;
        8'd153: amp_out<=8'd54;
        8'd154: amp_out<=8'd51;
        8'd155: amp_out<=8'd49;
        8'd156: amp_out<=8'd46;
        8'd157: amp_out<=8'd44;
        8'd158: amp_out<=8'd42;
        8'd159: amp_out<=8'd39;
        8'd160: amp_out<=8'd37;
        8'd161: amp_out<=8'd35;
        8'd162: amp_out<=8'd33;
        8'd163: amp_out<=8'd31;
        8'd164: amp_out<=8'd29;
        8'd165: amp_out<=8'd27;
        8'd166: amp_out<=8'd25;
        8'd167: amp_out<=8'd23;
        8'd168: amp_out<=8'd21;
        8'd169: amp_out<=8'd20;
        8'd170: amp_out<=8'd18;
        8'd171: amp_out<=8'd16;
        8'd172: amp_out<=8'd15;
        8'd173: amp_out<=8'd14;
        8'd174: amp_out<=8'd12;
        8'd175: amp_out<=8'd11;
        8'd176: amp_out<=8'd10;
        8'd177: amp_out<=8'd9;
        8'd178: amp_out<=8'd7;
        8'd179: amp_out<=8'd6;
        8'd180: amp_out<=8'd5;
        8'd181: amp_out<=8'd5;
        8'd182: amp_out<=8'd4;
        8'd183: amp_out<=8'd3;
        8'd184: amp_out<=8'd2;
        8'd185: amp_out<=8'd2;
        8'd186: amp_out<=8'd1;
        8'd187: amp_out<=8'd1;
        8'd188: amp_out<=8'd1;
        8'd189: amp_out<=8'd0;
        8'd190: amp_out<=8'd0;
        8'd191: amp_out<=8'd0;
        8'd192: amp_out<=8'd0;
        8'd193: amp_out<=8'd0;
        8'd194: amp_out<=8'd0;
        8'd195: amp_out<=8'd0;
        8'd196: amp_out<=8'd1;
        8'd197: amp_out<=8'd1;
        8'd198: amp_out<=8'd1;
        8'd199: amp_out<=8'd2;
        8'd200: amp_out<=8'd2;
        8'd201: amp_out<=8'd3;
        8'd202: amp_out<=8'd4;
        8'd203: amp_out<=8'd5;
        8'd204: amp_out<=8'd5;
        8'd205: amp_out<=8'd6;
        8'd206: amp_out<=8'd7;
        8'd207: amp_out<=8'd9;
        8'd208: amp_out<=8'd10;
        8'd209: amp_out<=8'd11;
        8'd210: amp_out<=8'd12;
        8'd211: amp_out<=8'd14;
        8'd212: amp_out<=8'd15;
        8'd213: amp_out<=8'd16;
        8'd214: amp_out<=8'd18;
        8'd215: amp_out<=8'd20;
        8'd216: amp_out<=8'd21;
        8'd217: amp_out<=8'd23;
        8'd218: amp_out<=8'd25;
        8'd219: amp_out<=8'd27;
        8'd220: amp_out<=8'd29;
        8'd221: amp_out<=8'd31;
        8'd222: amp_out<=8'd33;
        8'd223: amp_out<=8'd35;
        8'd224: amp_out<=8'd37;
        8'd225: amp_out<=8'd39;
        8'd226: amp_out<=8'd42;
        8'd227: amp_out<=8'd44;
        8'd228: amp_out<=8'd46;
        8'd229: amp_out<=8'd49;
        8'd230: amp_out<=8'd51;
        8'd231: amp_out<=8'd54;
        8'd232: amp_out<=8'd56;
        8'd233: amp_out<=8'd59;
        8'd234: amp_out<=8'd62;
        8'd235: amp_out<=8'd64;
        8'd236: amp_out<=8'd67;
        8'd237: amp_out<=8'd70;
        8'd238: amp_out<=8'd73;
        8'd239: amp_out<=8'd76;
        8'd240: amp_out<=8'd78;
        8'd241: amp_out<=8'd81;
        8'd242: amp_out<=8'd84;
        8'd243: amp_out<=8'd87;
        8'd244: amp_out<=8'd90;
        8'd245: amp_out<=8'd93;
        8'd246: amp_out<=8'd96;
        8'd247: amp_out<=8'd99;
        8'd248: amp_out<=8'd102;
        8'd249: amp_out<=8'd105;
        8'd250: amp_out<=8'd108;
        8'd251: amp_out<=8'd111;
        8'd252: amp_out<=8'd115;
        8'd253: amp_out<=8'd118;
        8'd254: amp_out<=8'd121;
        8'd255: amp_out<=8'd124;
    endcase
  end
endmodule