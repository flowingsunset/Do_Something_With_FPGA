`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/09 14:21:59
// Design Name: 
// Module Name: buzzer_doremi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module buzzer_doremi
    #(parameter sys_clk_freq = 100_000_000)
    (
        input clk,
        input reset_p,
        input[6:0] sw,
        output buzzer_out
    );
    localparam do_4 = 262;
    localparam re_4 = 294;
    localparam mi_4 = 330;
    localparam fa_4 = 349;
    localparam sol_4 = 392;
    localparam la_4 = 440;
    localparam si_4= 494;

    reg [12:0] pwm_freq;
    reg enable;
    buzzer #(.sys_clk_freq(sys_clk_freq)) buzzer(.clk(clk), .reset_p(reset_p), .pwm_freq(pwm_freq), .enable(enable), .buzzer_out(buzzer_out));

    always @(*) begin
        pwm_freq = 0;
        enable = 0;
        case (sw)
            7'b000_0001: begin pwm_freq = do_4;  enable = 1; end
            7'b000_0010: begin pwm_freq = re_4;  enable = 1; end
            7'b000_0100: begin pwm_freq = mi_4;  enable = 1; end
            7'b000_1000: begin pwm_freq = fa_4;  enable = 1; end
            7'b001_0000: begin pwm_freq = sol_4; enable = 1; end
            7'b010_0000: begin pwm_freq = la_4;  enable = 1; end
            7'b100_0000: begin pwm_freq = si_4;  enable = 1; end
        endcase
    end

endmodule
