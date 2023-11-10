`timescale 1ns / 1ps
module alarm
    #(parameter sys_clk_freq = 100_000_000)
    (input clk,
     input reset_p,
     input alarm,
     output reg [3:0] led,
     output buzzer_out);

    reg [6:0] r_doremi;
    reg [26:0] r_cnt_buzzer, r_cnt_led;

    buzzer_doremi #(.sys_clk_freq(sys_clk_freq)) buzzer_doremi
    (.clk(clk), .reset_p(reset_p), .sw(r_doremi), .buzzer_out(buzzer_out));

    //buzzer
    always @(posedge clk ) begin
        if (reset_p) begin
            r_doremi <= 0;
            r_cnt_buzzer <= 0;
        end else begin
            if (alarm) begin
                if (r_cnt_buzzer >= sys_clk_freq/4) begin
                    r_cnt_buzzer <= 0;
                    if(!r_doremi)r_doremi <= 7'b100_0000;
                    else r_doremi <= 7'b0;
                end
                else r_cnt_buzzer <= r_cnt_buzzer+1;
            end
            else begin
                r_doremi <= 0;
                r_cnt_buzzer <= 0;
            end
        end
    end

    //led
    always @(posedge clk ) begin
        if (reset_p) begin
            r_cnt_led <= 0;
            led <= 0;
        end else begin
            if(alarm) begin
                if(r_cnt_led >= sys_clk_freq)begin
                    r_cnt_led <= 0;
                    led <= ~led;
                end
                else r_cnt_led <= r_cnt_led + 1;
            end
            else begin
                r_cnt_led <= 0;
                led <= 0;
            end
        end
    end
endmodule
