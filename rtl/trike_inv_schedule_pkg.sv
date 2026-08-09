`timescale 1ns / 1ps

package trike_inv_schedule_pkg;

  function automatic int trike_inv_stage_count(input int r_bits);
    case (r_bits)
      13: trike_inv_stage_count = 4;
      12589: trike_inv_stage_count = 14;
      15581: trike_inv_stage_count = 14;
      35363: trike_inv_stage_count = 16;
      69691: trike_inv_stage_count = 17;
      114043: trike_inv_stage_count = 17;
      default: trike_inv_stage_count = 0;
    endcase
  endfunction

  function automatic int trike_inv_l0(input int r_bits, input int stage);
    trike_inv_l0 = 0;
    case (r_bits)
      13: begin
        case (stage)
          1: trike_inv_l0 = 7;
          2: trike_inv_l0 = 10;
          3: trike_inv_l0 = 9;
          default: trike_inv_l0 = 0;
        endcase
      end
      12589: begin
        case (stage)
          1: trike_inv_l0 = 6295;
          2: trike_inv_l0 = 9442;
          3: trike_inv_l0 = 8655;
          4: trike_inv_l0 = 4475;
          5: trike_inv_l0 = 9115;
          6: trike_inv_l0 = 8414;
          7: trike_inv_l0 = 7449;
          8: trike_inv_l0 = 7878;
          9: trike_inv_l0 = 11703;
          10: trike_inv_l0 = 4478;
          11: trike_inv_l0 = 10796;
          12: trike_inv_l0 = 4654;
          13: trike_inv_l0 = 6636;
          default: trike_inv_l0 = 0;
        endcase
      end
      15581: begin
        case (stage)
          1: trike_inv_l0 = 7791;
          2: trike_inv_l0 = 11686;
          3: trike_inv_l0 = 10712;
          4: trike_inv_l0 = 8460;
          5: trike_inv_l0 = 8067;
          6: trike_inv_l0 = 10233;
          7: trike_inv_l0 = 9969;
          8: trike_inv_l0 = 5343;
          9: trike_inv_l0 = 3257;
          10: trike_inv_l0 = 12969;
          11: trike_inv_l0 = 13647;
          12: trike_inv_l0 = 916;
          13: trike_inv_l0 = 13263;
          default: trike_inv_l0 = 0;
        endcase
      end
      35363: begin
        case (stage)
          1: trike_inv_l0 = 17682;
          2: trike_inv_l0 = 8841;
          3: trike_inv_l0 = 11051;
          4: trike_inv_l0 = 16162;
          5: trike_inv_l0 = 19126;
          6: trike_inv_l0 = 9004;
          7: trike_inv_l0 = 20020;
          8: trike_inv_l0 = 31521;
          9: trike_inv_l0 = 14593;
          10: trike_inv_l0 = 35026;
          11: trike_inv_l0 = 7480;
          12: trike_inv_l0 = 6134;
          13: trike_inv_l0 = 35087;
          14: trike_inv_l0 = 5450;
          15: trike_inv_l0 = 32943;
          default: trike_inv_l0 = 0;
        endcase
      end
      69691: begin
        case (stage)
          1: trike_inv_l0 = 34846;
          2: trike_inv_l0 = 17423;
          3: trike_inv_l0 = 56624;
          4: trike_inv_l0 = 3539;
          5: trike_inv_l0 = 49832;
          6: trike_inv_l0 = 68203;
          7: trike_inv_l0 = 53723;
          8: trike_inv_l0 = 47346;
          9: trike_inv_l0 = 32701;
          10: trike_inv_l0 = 16697;
          11: trike_inv_l0 = 25809;
          12: trike_inv_l0 = 67594;
          13: trike_inv_l0 = 6876;
          14: trike_inv_l0 = 28878;
          15: trike_inv_l0 = 16378;
          16: trike_inv_l0 = 67916;
          default: trike_inv_l0 = 0;
        endcase
      end
      114043: begin
        case (stage)
          1: trike_inv_l0 = 57022;
          2: trike_inv_l0 = 28511;
          3: trike_inv_l0 = 92660;
          4: trike_inv_l0 = 34302;
          5: trike_inv_l0 = 45573;
          6: trike_inv_l0 = 61256;
          7: trike_inv_l0 = 54750;
          8: trike_inv_l0 = 56288;
          9: trike_inv_l0 = 110361;
          10: trike_inv_l0 = 100050;
          11: trike_inv_l0 = 106261;
          12: trike_inv_l0 = 2691;
          13: trike_inv_l0 = 56772;
          14: trike_inv_l0 = 90761;
          15: trike_inv_l0 = 5145;
          16: trike_inv_l0 = 13049;
          default: trike_inv_l0 = 0;
        endcase
      end
      default: trike_inv_l0 = 0;
    endcase
  endfunction

  function automatic int trike_inv_l1(input int r_bits, input int stage);
    trike_inv_l1 = 0;
    case (r_bits)
      13: begin
        case (stage)
          1: trike_inv_l1 = 7;
          3: trike_inv_l1 = 5;
          default: trike_inv_l1 = 0;
        endcase
      end
      12589: begin
        case (stage)
          1: trike_inv_l1 = 6295;
          3: trike_inv_l1 = 4721;
          5: trike_inv_l1 = 2133;
          8: trike_inv_l1 = 7737;
          12: trike_inv_l1 = 6023;
          13: trike_inv_l1 = 11142;
          default: trike_inv_l1 = 0;
        endcase
      end
      15581: begin
        case (stage)
          1: trike_inv_l1 = 7791;
          3: trike_inv_l1 = 5843;
          4: trike_inv_l1 = 8848;
          6: trike_inv_l1 = 255;
          7: trike_inv_l1 = 2392;
          10: trike_inv_l1 = 4036;
          11: trike_inv_l1 = 457;
          12: trike_inv_l1 = 13506;
          13: trike_inv_l1 = 10902;
          default: trike_inv_l1 = 0;
        endcase
      end
      35363: begin
        case (stage)
          5: trike_inv_l1 = 17682;
          9: trike_inv_l1 = 4502;
          11: trike_inv_l1 = 3435;
          15: trike_inv_l1 = 29305;
          default: trike_inv_l1 = 0;
        endcase
      end
      69691: begin
        case (stage)
          3: trike_inv_l1 = 34846;
          4: trike_inv_l1 = 36615;
          5: trike_inv_l1 = 18609;
          12: trike_inv_l1 = 46826;
          16: trike_inv_l1 = 3156;
          default: trike_inv_l1 = 0;
        endcase
      end
      114043: begin
        case (stage)
          3: trike_inv_l1 = 57022;
          4: trike_inv_l1 = 17151;
          5: trike_inv_l1 = 85844;
          6: trike_inv_l1 = 51377;
          8: trike_inv_l1 = 20155;
          10: trike_inv_l1 = 31283;
          11: trike_inv_l1 = 37499;
          12: trike_inv_l1 = 95797;
          13: trike_inv_l1 = 104700;
          15: trike_inv_l1 = 43725;
          16: trike_inv_l1 = 10396;
          default: trike_inv_l1 = 0;
        endcase
      end
      default: trike_inv_l1 = 0;
    endcase
  endfunction

endpackage
