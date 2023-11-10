`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/09 14:07:01
// Design Name: 
// Module Name: buzzer
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


module buzzer 
        #(parameter sys_clk_freq = 100_000_000)
    (
        input wire clk, reset_p,
        input wire [12:0] pwm_freq,
        input wire enable,
        output reg buzzer_out    //100.0%
    );

    reg [26:0] r_cnt;

    always @(posedge clk, posedge reset_p) begin
        if (reset_p)  begin
            r_cnt <= 0;
            buzzer_out <= 0; 
        end
        else begin
            if(enable)begin
                if(r_cnt >= (sys_clk_freq/pwm_freq/2)) begin
                    r_cnt <= 0;
                    buzzer_out <= ~buzzer_out;
                end
                else r_cnt <= r_cnt + 1;
            end
            else buzzer_out <= 0;
        end
    end

endmodule