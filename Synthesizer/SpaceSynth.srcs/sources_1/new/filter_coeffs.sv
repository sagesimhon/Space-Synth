`timescale 1ns / 1ps

module filter_coeffs(input clk_in,
                     input[7:0] cutoff_value_in, 
                     output logic signed[15:0] b0_out, 
                     output logic signed[15:0] a1_out
                     );
  always_ff @(posedge clk_in)begin
    case(cutoff_value_in)
8'd0: begin
        b0_out <= 16'sd213;
        a1_out <= 16'sd32342;
      end

8'd1: begin
        b0_out <= 16'sd254;
        a1_out <= 16'sd32261;
      end

8'd2: begin
        b0_out <= 16'sd294;
        a1_out <= 16'sd32180;
      end

8'd3: begin
        b0_out <= 16'sd334;
        a1_out <= 16'sd32100;
      end

8'd4: begin
        b0_out <= 16'sd374;
        a1_out <= 16'sd32019;
      end

8'd5: begin
        b0_out <= 16'sd414;
        a1_out <= 16'sd31939;
      end

8'd6: begin
        b0_out <= 16'sd454;
        a1_out <= 16'sd31859;
      end

8'd7: begin
        b0_out <= 16'sd494;
        a1_out <= 16'sd31779;
      end

8'd8: begin
        b0_out <= 16'sd534;
        a1_out <= 16'sd31700;
      end

8'd9: begin
        b0_out <= 16'sd574;
        a1_out <= 16'sd31620;
      end

8'd10: begin
        b0_out <= 16'sd613;
        a1_out <= 16'sd31541;
      end

8'd11: begin
        b0_out <= 16'sd653;
        a1_out <= 16'sd31462;
      end

8'd12: begin
        b0_out <= 16'sd692;
        a1_out <= 16'sd31384;
      end

8'd13: begin
        b0_out <= 16'sd732;
        a1_out <= 16'sd31305;
      end

8'd14: begin
        b0_out <= 16'sd771;
        a1_out <= 16'sd31226;
      end

8'd15: begin
        b0_out <= 16'sd810;
        a1_out <= 16'sd31148;
      end

8'd16: begin
        b0_out <= 16'sd849;
        a1_out <= 16'sd31070;
      end

8'd17: begin
        b0_out <= 16'sd888;
        a1_out <= 16'sd30992;
      end

8'd18: begin
        b0_out <= 16'sd927;
        a1_out <= 16'sd30915;
      end

8'd19: begin
        b0_out <= 16'sd965;
        a1_out <= 16'sd30837;
      end

8'd20: begin
        b0_out <= 16'sd1004;
        a1_out <= 16'sd30760;
      end

8'd21: begin
        b0_out <= 16'sd1043;
        a1_out <= 16'sd30683;
      end

8'd22: begin
        b0_out <= 16'sd1081;
        a1_out <= 16'sd30606;
      end

8'd23: begin
        b0_out <= 16'sd1120;
        a1_out <= 16'sd30529;
      end

8'd24: begin
        b0_out <= 16'sd1158;
        a1_out <= 16'sd30452;
      end

8'd25: begin
        b0_out <= 16'sd1196;
        a1_out <= 16'sd30376;
      end

8'd26: begin
        b0_out <= 16'sd1234;
        a1_out <= 16'sd30300;
      end

8'd27: begin
        b0_out <= 16'sd1272;
        a1_out <= 16'sd30224;
      end

8'd28: begin
        b0_out <= 16'sd1310;
        a1_out <= 16'sd30148;
      end

8'd29: begin
        b0_out <= 16'sd1348;
        a1_out <= 16'sd30072;
      end

8'd30: begin
        b0_out <= 16'sd1386;
        a1_out <= 16'sd29997;
      end

8'd31: begin
        b0_out <= 16'sd1423;
        a1_out <= 16'sd29921;
      end

8'd32: begin
        b0_out <= 16'sd1461;
        a1_out <= 16'sd29846;
      end

8'd33: begin
        b0_out <= 16'sd1499;
        a1_out <= 16'sd29771;
      end

8'd34: begin
        b0_out <= 16'sd1536;
        a1_out <= 16'sd29696;
      end

8'd35: begin
        b0_out <= 16'sd1573;
        a1_out <= 16'sd29621;
      end

8'd36: begin
        b0_out <= 16'sd1611;
        a1_out <= 16'sd29547;
      end

8'd37: begin
        b0_out <= 16'sd1648;
        a1_out <= 16'sd29473;
      end

8'd38: begin
        b0_out <= 16'sd1685;
        a1_out <= 16'sd29398;
      end

8'd39: begin
        b0_out <= 16'sd1722;
        a1_out <= 16'sd29324;
      end

8'd40: begin
        b0_out <= 16'sd1759;
        a1_out <= 16'sd29251;
      end

8'd41: begin
        b0_out <= 16'sd1796;
        a1_out <= 16'sd29177;
      end

8'd42: begin
        b0_out <= 16'sd1832;
        a1_out <= 16'sd29103;
      end

8'd43: begin
        b0_out <= 16'sd1869;
        a1_out <= 16'sd29030;
      end

8'd44: begin
        b0_out <= 16'sd1906;
        a1_out <= 16'sd28957;
      end

8'd45: begin
        b0_out <= 16'sd1942;
        a1_out <= 16'sd28884;
      end

8'd46: begin
        b0_out <= 16'sd1979;
        a1_out <= 16'sd28811;
      end

8'd47: begin
        b0_out <= 16'sd2015;
        a1_out <= 16'sd28738;
      end

8'd48: begin
        b0_out <= 16'sd2051;
        a1_out <= 16'sd28666;
      end

8'd49: begin
        b0_out <= 16'sd2087;
        a1_out <= 16'sd28593;
      end

8'd50: begin
        b0_out <= 16'sd2123;
        a1_out <= 16'sd28521;
      end

8'd51: begin
        b0_out <= 16'sd2159;
        a1_out <= 16'sd28449;
      end

8'd52: begin
        b0_out <= 16'sd2195;
        a1_out <= 16'sd28377;
      end

8'd53: begin
        b0_out <= 16'sd2231;
        a1_out <= 16'sd28305;
      end

8'd54: begin
        b0_out <= 16'sd2267;
        a1_out <= 16'sd28234;
      end

8'd55: begin
        b0_out <= 16'sd2303;
        a1_out <= 16'sd28162;
      end

8'd56: begin
        b0_out <= 16'sd2339;
        a1_out <= 16'sd28091;
      end

8'd57: begin
        b0_out <= 16'sd2374;
        a1_out <= 16'sd28020;
      end

8'd58: begin
        b0_out <= 16'sd2410;
        a1_out <= 16'sd27949;
      end

8'd59: begin
        b0_out <= 16'sd2445;
        a1_out <= 16'sd27878;
      end

8'd60: begin
        b0_out <= 16'sd2480;
        a1_out <= 16'sd27807;
      end

8'd61: begin
        b0_out <= 16'sd2516;
        a1_out <= 16'sd27737;
      end

8'd62: begin
        b0_out <= 16'sd2551;
        a1_out <= 16'sd27666;
      end

8'd63: begin
        b0_out <= 16'sd2586;
        a1_out <= 16'sd27596;
      end

8'd64: begin
        b0_out <= 16'sd2621;
        a1_out <= 16'sd27526;
      end

8'd65: begin
        b0_out <= 16'sd2656;
        a1_out <= 16'sd27456;
      end

8'd66: begin
        b0_out <= 16'sd2691;
        a1_out <= 16'sd27386;
      end

8'd67: begin
        b0_out <= 16'sd2726;
        a1_out <= 16'sd27317;
      end

8'd68: begin
        b0_out <= 16'sd2760;
        a1_out <= 16'sd27247;
      end

8'd69: begin
        b0_out <= 16'sd2795;
        a1_out <= 16'sd27178;
      end

8'd70: begin
        b0_out <= 16'sd2830;
        a1_out <= 16'sd27109;
      end

8'd71: begin
        b0_out <= 16'sd2864;
        a1_out <= 16'sd27040;
      end

8'd72: begin
        b0_out <= 16'sd2899;
        a1_out <= 16'sd26971;
      end

8'd73: begin
        b0_out <= 16'sd2933;
        a1_out <= 16'sd26902;
      end

8'd74: begin
        b0_out <= 16'sd2967;
        a1_out <= 16'sd26833;
      end

8'd75: begin
        b0_out <= 16'sd3002;
        a1_out <= 16'sd26765;
      end

8'd76: begin
        b0_out <= 16'sd3036;
        a1_out <= 16'sd26696;
      end

8'd77: begin
        b0_out <= 16'sd3070;
        a1_out <= 16'sd26628;
      end

8'd78: begin
        b0_out <= 16'sd3104;
        a1_out <= 16'sd26560;
      end

8'd79: begin
        b0_out <= 16'sd3138;
        a1_out <= 16'sd26492;
      end

8'd80: begin
        b0_out <= 16'sd3172;
        a1_out <= 16'sd26424;
      end

8'd81: begin
        b0_out <= 16'sd3206;
        a1_out <= 16'sd26357;
      end

8'd82: begin
        b0_out <= 16'sd3239;
        a1_out <= 16'sd26289;
      end

8'd83: begin
        b0_out <= 16'sd3273;
        a1_out <= 16'sd26222;
      end

8'd84: begin
        b0_out <= 16'sd3307;
        a1_out <= 16'sd26154;
      end

8'd85: begin
        b0_out <= 16'sd3340;
        a1_out <= 16'sd26087;
      end

8'd86: begin
        b0_out <= 16'sd3374;
        a1_out <= 16'sd26020;
      end

8'd87: begin
        b0_out <= 16'sd3407;
        a1_out <= 16'sd25953;
      end

8'd88: begin
        b0_out <= 16'sd3441;
        a1_out <= 16'sd25887;
      end

8'd89: begin
        b0_out <= 16'sd3474;
        a1_out <= 16'sd25820;
      end

8'd90: begin
        b0_out <= 16'sd3507;
        a1_out <= 16'sd25754;
      end

8'd91: begin
        b0_out <= 16'sd3540;
        a1_out <= 16'sd25687;
      end

8'd92: begin
        b0_out <= 16'sd3574;
        a1_out <= 16'sd25621;
      end

8'd93: begin
        b0_out <= 16'sd3607;
        a1_out <= 16'sd25555;
      end

8'd94: begin
        b0_out <= 16'sd3640;
        a1_out <= 16'sd25489;
      end

8'd95: begin
        b0_out <= 16'sd3672;
        a1_out <= 16'sd25423;
      end

8'd96: begin
        b0_out <= 16'sd3705;
        a1_out <= 16'sd25357;
      end

8'd97: begin
        b0_out <= 16'sd3738;
        a1_out <= 16'sd25292;
      end

8'd98: begin
        b0_out <= 16'sd3771;
        a1_out <= 16'sd25226;
      end

8'd99: begin
        b0_out <= 16'sd3803;
        a1_out <= 16'sd25161;
      end

8'd100: begin
        b0_out <= 16'sd3836;
        a1_out <= 16'sd25096;
      end

8'd101: begin
        b0_out <= 16'sd3869;
        a1_out <= 16'sd25031;
      end

8'd102: begin
        b0_out <= 16'sd3901;
        a1_out <= 16'sd24966;
      end

8'd103: begin
        b0_out <= 16'sd3933;
        a1_out <= 16'sd24901;
      end

8'd104: begin
        b0_out <= 16'sd3966;
        a1_out <= 16'sd24836;
      end

8'd105: begin
        b0_out <= 16'sd3998;
        a1_out <= 16'sd24772;
      end

8'd106: begin
        b0_out <= 16'sd4030;
        a1_out <= 16'sd24707;
      end

8'd107: begin
        b0_out <= 16'sd4062;
        a1_out <= 16'sd24643;
      end

8'd108: begin
        b0_out <= 16'sd4095;
        a1_out <= 16'sd24579;
      end

8'd109: begin
        b0_out <= 16'sd4127;
        a1_out <= 16'sd24515;
      end

8'd110: begin
        b0_out <= 16'sd4159;
        a1_out <= 16'sd24451;
      end

8'd111: begin
        b0_out <= 16'sd4191;
        a1_out <= 16'sd24387;
      end

8'd112: begin
        b0_out <= 16'sd4222;
        a1_out <= 16'sd24323;
      end

8'd113: begin
        b0_out <= 16'sd4254;
        a1_out <= 16'sd24260;
      end

8'd114: begin
        b0_out <= 16'sd4286;
        a1_out <= 16'sd24196;
      end

8'd115: begin
        b0_out <= 16'sd4318;
        a1_out <= 16'sd24133;
      end

8'd116: begin
        b0_out <= 16'sd4349;
        a1_out <= 16'sd24069;
      end

8'd117: begin
        b0_out <= 16'sd4381;
        a1_out <= 16'sd24006;
      end

8'd118: begin
        b0_out <= 16'sd4412;
        a1_out <= 16'sd23943;
      end

8'd119: begin
        b0_out <= 16'sd4444;
        a1_out <= 16'sd23880;
      end

8'd120: begin
        b0_out <= 16'sd4475;
        a1_out <= 16'sd23818;
      end

8'd121: begin
        b0_out <= 16'sd4507;
        a1_out <= 16'sd23755;
      end

8'd122: begin
        b0_out <= 16'sd4538;
        a1_out <= 16'sd23692;
      end

8'd123: begin
        b0_out <= 16'sd4569;
        a1_out <= 16'sd23630;
      end

8'd124: begin
        b0_out <= 16'sd4600;
        a1_out <= 16'sd23568;
      end

8'd125: begin
        b0_out <= 16'sd4631;
        a1_out <= 16'sd23505;
      end

8'd126: begin
        b0_out <= 16'sd4662;
        a1_out <= 16'sd23443;
      end

8'd127: begin
        b0_out <= 16'sd4693;
        a1_out <= 16'sd23381;
      end

8'd128: begin
        b0_out <= 16'sd4724;
        a1_out <= 16'sd23319;
      end

8'd129: begin
        b0_out <= 16'sd4755;
        a1_out <= 16'sd23258;
      end

8'd130: begin
        b0_out <= 16'sd4786;
        a1_out <= 16'sd23196;
      end

8'd131: begin
        b0_out <= 16'sd4817;
        a1_out <= 16'sd23134;
      end

8'd132: begin
        b0_out <= 16'sd4848;
        a1_out <= 16'sd23073;
      end

8'd133: begin
        b0_out <= 16'sd4878;
        a1_out <= 16'sd23011;
      end

8'd134: begin
        b0_out <= 16'sd4909;
        a1_out <= 16'sd22950;
      end

8'd135: begin
        b0_out <= 16'sd4939;
        a1_out <= 16'sd22889;
      end

8'd136: begin
        b0_out <= 16'sd4970;
        a1_out <= 16'sd22828;
      end

8'd137: begin
        b0_out <= 16'sd5000;
        a1_out <= 16'sd22767;
      end

8'd138: begin
        b0_out <= 16'sd5031;
        a1_out <= 16'sd22706;
      end

8'd139: begin
        b0_out <= 16'sd5061;
        a1_out <= 16'sd22646;
      end

8'd140: begin
        b0_out <= 16'sd5091;
        a1_out <= 16'sd22585;
      end

8'd141: begin
        b0_out <= 16'sd5122;
        a1_out <= 16'sd22525;
      end

8'd142: begin
        b0_out <= 16'sd5152;
        a1_out <= 16'sd22464;
      end

8'd143: begin
        b0_out <= 16'sd5182;
        a1_out <= 16'sd22404;
      end

8'd144: begin
        b0_out <= 16'sd5212;
        a1_out <= 16'sd22344;
      end

8'd145: begin
        b0_out <= 16'sd5242;
        a1_out <= 16'sd22284;
      end

8'd146: begin
        b0_out <= 16'sd5272;
        a1_out <= 16'sd22224;
      end

8'd147: begin
        b0_out <= 16'sd5302;
        a1_out <= 16'sd22164;
      end

8'd148: begin
        b0_out <= 16'sd5332;
        a1_out <= 16'sd22104;
      end

8'd149: begin
        b0_out <= 16'sd5362;
        a1_out <= 16'sd22044;
      end

8'd150: begin
        b0_out <= 16'sd5392;
        a1_out <= 16'sd21985;
      end

8'd151: begin
        b0_out <= 16'sd5421;
        a1_out <= 16'sd21925;
      end

8'd152: begin
        b0_out <= 16'sd5451;
        a1_out <= 16'sd21866;
      end

8'd153: begin
        b0_out <= 16'sd5481;
        a1_out <= 16'sd21807;
      end

8'd154: begin
        b0_out <= 16'sd5510;
        a1_out <= 16'sd21747;
      end

8'd155: begin
        b0_out <= 16'sd5540;
        a1_out <= 16'sd21688;
      end

8'd156: begin
        b0_out <= 16'sd5569;
        a1_out <= 16'sd21629;
      end

8'd157: begin
        b0_out <= 16'sd5599;
        a1_out <= 16'sd21570;
      end

8'd158: begin
        b0_out <= 16'sd5628;
        a1_out <= 16'sd21512;
      end

8'd159: begin
        b0_out <= 16'sd5658;
        a1_out <= 16'sd21453;
      end

8'd160: begin
        b0_out <= 16'sd5687;
        a1_out <= 16'sd21394;
      end

8'd161: begin
        b0_out <= 16'sd5716;
        a1_out <= 16'sd21336;
      end

8'd162: begin
        b0_out <= 16'sd5745;
        a1_out <= 16'sd21277;
      end

8'd163: begin
        b0_out <= 16'sd5774;
        a1_out <= 16'sd21219;
      end

8'd164: begin
        b0_out <= 16'sd5804;
        a1_out <= 16'sd21161;
      end

8'd165: begin
        b0_out <= 16'sd5833;
        a1_out <= 16'sd21103;
      end

8'd166: begin
        b0_out <= 16'sd5862;
        a1_out <= 16'sd21045;
      end

8'd167: begin
        b0_out <= 16'sd5891;
        a1_out <= 16'sd20987;
      end

8'd168: begin
        b0_out <= 16'sd5920;
        a1_out <= 16'sd20929;
      end

8'd169: begin
        b0_out <= 16'sd5948;
        a1_out <= 16'sd20871;
      end

8'd170: begin
        b0_out <= 16'sd5977;
        a1_out <= 16'sd20814;
      end

8'd171: begin
        b0_out <= 16'sd6006;
        a1_out <= 16'sd20756;
      end

8'd172: begin
        b0_out <= 16'sd6035;
        a1_out <= 16'sd20699;
      end

8'd173: begin
        b0_out <= 16'sd6063;
        a1_out <= 16'sd20641;
      end

8'd174: begin
        b0_out <= 16'sd6092;
        a1_out <= 16'sd20584;
      end

8'd175: begin
        b0_out <= 16'sd6121;
        a1_out <= 16'sd20527;
      end

8'd176: begin
        b0_out <= 16'sd6149;
        a1_out <= 16'sd20470;
      end

8'd177: begin
        b0_out <= 16'sd6178;
        a1_out <= 16'sd20412;
      end

8'd178: begin
        b0_out <= 16'sd6206;
        a1_out <= 16'sd20356;
      end

8'd179: begin
        b0_out <= 16'sd6235;
        a1_out <= 16'sd20299;
      end

8'd180: begin
        b0_out <= 16'sd6263;
        a1_out <= 16'sd20242;
      end

8'd181: begin
        b0_out <= 16'sd6291;
        a1_out <= 16'sd20185;
      end

8'd182: begin
        b0_out <= 16'sd6320;
        a1_out <= 16'sd20129;
      end

8'd183: begin
        b0_out <= 16'sd6348;
        a1_out <= 16'sd20072;
      end

8'd184: begin
        b0_out <= 16'sd6376;
        a1_out <= 16'sd20016;
      end

8'd185: begin
        b0_out <= 16'sd6404;
        a1_out <= 16'sd19959;
      end

8'd186: begin
        b0_out <= 16'sd6432;
        a1_out <= 16'sd19903;
      end

8'd187: begin
        b0_out <= 16'sd6460;
        a1_out <= 16'sd19847;
      end

8'd188: begin
        b0_out <= 16'sd6488;
        a1_out <= 16'sd19791;
      end

8'd189: begin
        b0_out <= 16'sd6516;
        a1_out <= 16'sd19735;
      end

8'd190: begin
        b0_out <= 16'sd6544;
        a1_out <= 16'sd19679;
      end

8'd191: begin
        b0_out <= 16'sd6572;
        a1_out <= 16'sd19623;
      end

8'd192: begin
        b0_out <= 16'sd6600;
        a1_out <= 16'sd19568;
      end

8'd193: begin
        b0_out <= 16'sd6628;
        a1_out <= 16'sd19512;
      end

8'd194: begin
        b0_out <= 16'sd6656;
        a1_out <= 16'sd19456;
      end

8'd195: begin
        b0_out <= 16'sd6684;
        a1_out <= 16'sd19401;
      end

8'd196: begin
        b0_out <= 16'sd6711;
        a1_out <= 16'sd19345;
      end

8'd197: begin
        b0_out <= 16'sd6739;
        a1_out <= 16'sd19290;
      end

8'd198: begin
        b0_out <= 16'sd6767;
        a1_out <= 16'sd19235;
      end

8'd199: begin
        b0_out <= 16'sd6794;
        a1_out <= 16'sd19180;
      end

8'd200: begin
        b0_out <= 16'sd6822;
        a1_out <= 16'sd19125;
      end

8'd201: begin
        b0_out <= 16'sd6849;
        a1_out <= 16'sd19070;
      end

8'd202: begin
        b0_out <= 16'sd6877;
        a1_out <= 16'sd19015;
      end

8'd203: begin
        b0_out <= 16'sd6904;
        a1_out <= 16'sd18960;
      end

8'd204: begin
        b0_out <= 16'sd6931;
        a1_out <= 16'sd18905;
      end

8'd205: begin
        b0_out <= 16'sd6959;
        a1_out <= 16'sd18851;
      end

8'd206: begin
        b0_out <= 16'sd6986;
        a1_out <= 16'sd18796;
      end

8'd207: begin
        b0_out <= 16'sd7013;
        a1_out <= 16'sd18741;
      end

8'd208: begin
        b0_out <= 16'sd7041;
        a1_out <= 16'sd18687;
      end

8'd209: begin
        b0_out <= 16'sd7068;
        a1_out <= 16'sd18633;
      end

8'd210: begin
        b0_out <= 16'sd7095;
        a1_out <= 16'sd18578;
      end

8'd211: begin
        b0_out <= 16'sd7122;
        a1_out <= 16'sd18524;
      end

8'd212: begin
        b0_out <= 16'sd7149;
        a1_out <= 16'sd18470;
      end

8'd213: begin
        b0_out <= 16'sd7176;
        a1_out <= 16'sd18416;
      end

8'd214: begin
        b0_out <= 16'sd7203;
        a1_out <= 16'sd18362;
      end

8'd215: begin
        b0_out <= 16'sd7230;
        a1_out <= 16'sd18308;
      end

8'd216: begin
        b0_out <= 16'sd7257;
        a1_out <= 16'sd18254;
      end

8'd217: begin
        b0_out <= 16'sd7284;
        a1_out <= 16'sd18200;
      end

8'd218: begin
        b0_out <= 16'sd7311;
        a1_out <= 16'sd18147;
      end

8'd219: begin
        b0_out <= 16'sd7337;
        a1_out <= 16'sd18093;
      end

8'd220: begin
        b0_out <= 16'sd7364;
        a1_out <= 16'sd18040;
      end

8'd221: begin
        b0_out <= 16'sd7391;
        a1_out <= 16'sd17986;
      end

8'd222: begin
        b0_out <= 16'sd7418;
        a1_out <= 16'sd17933;
      end

8'd223: begin
        b0_out <= 16'sd7444;
        a1_out <= 16'sd17880;
      end

8'd224: begin
        b0_out <= 16'sd7471;
        a1_out <= 16'sd17826;
      end

8'd225: begin
        b0_out <= 16'sd7497;
        a1_out <= 16'sd17773;
      end

8'd226: begin
        b0_out <= 16'sd7524;
        a1_out <= 16'sd17720;
      end

8'd227: begin
        b0_out <= 16'sd7550;
        a1_out <= 16'sd17667;
      end

8'd228: begin
        b0_out <= 16'sd7577;
        a1_out <= 16'sd17614;
      end

8'd229: begin
        b0_out <= 16'sd7603;
        a1_out <= 16'sd17561;
      end

8'd230: begin
        b0_out <= 16'sd7630;
        a1_out <= 16'sd17508;
      end

8'd231: begin
        b0_out <= 16'sd7656;
        a1_out <= 16'sd17456;
      end

8'd232: begin
        b0_out <= 16'sd7682;
        a1_out <= 16'sd17403;
      end

8'd233: begin
        b0_out <= 16'sd7709;
        a1_out <= 16'sd17350;
      end

8'd234: begin
        b0_out <= 16'sd7735;
        a1_out <= 16'sd17298;
      end

8'd235: begin
        b0_out <= 16'sd7761;
        a1_out <= 16'sd17245;
      end

8'd236: begin
        b0_out <= 16'sd7787;
        a1_out <= 16'sd17193;
      end

8'd237: begin
        b0_out <= 16'sd7814;
        a1_out <= 16'sd17141;
      end

8'd238: begin
        b0_out <= 16'sd7840;
        a1_out <= 16'sd17088;
      end

8'd239: begin
        b0_out <= 16'sd7866;
        a1_out <= 16'sd17036;
      end

8'd240: begin
        b0_out <= 16'sd7892;
        a1_out <= 16'sd16984;
      end

8'd241: begin
        b0_out <= 16'sd7918;
        a1_out <= 16'sd16932;
      end

8'd242: begin
        b0_out <= 16'sd7944;
        a1_out <= 16'sd16880;
      end

8'd243: begin
        b0_out <= 16'sd7970;
        a1_out <= 16'sd16828;
      end

8'd244: begin
        b0_out <= 16'sd7996;
        a1_out <= 16'sd16776;
      end

8'd245: begin
        b0_out <= 16'sd8022;
        a1_out <= 16'sd16725;
      end

8'd246: begin
        b0_out <= 16'sd8048;
        a1_out <= 16'sd16673;
      end

8'd247: begin
        b0_out <= 16'sd8073;
        a1_out <= 16'sd16621;
      end

8'd248: begin
        b0_out <= 16'sd8099;
        a1_out <= 16'sd16570;
      end

8'd249: begin
        b0_out <= 16'sd8125;
        a1_out <= 16'sd16518;
      end

8'd250: begin
        b0_out <= 16'sd8151;
        a1_out <= 16'sd16467;
      end

8'd251: begin
        b0_out <= 16'sd8176;
        a1_out <= 16'sd16415;
      end

8'd252: begin
        b0_out <= 16'sd8202;
        a1_out <= 16'sd16364;
      end

8'd253: begin
        b0_out <= 16'sd8228;
        a1_out <= 16'sd16313;
      end

8'd254: begin
        b0_out <= 16'sd8253;
        a1_out <= 16'sd16262;
      end

8'd255: begin
        b0_out <= 16'sd8279;
        a1_out <= 16'sd16210;
      end


    endcase
  end
endmodule