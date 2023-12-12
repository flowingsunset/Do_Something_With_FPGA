`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/12 09:46:31
// Design Name: 
// Module Name: UART_clk_gen
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


module UART_clk_gen #(
    parameter sys_freq = 100_000_000,
    parameter BAUD_rate = 9600)(
    input clk, reset_p,
    output reg UART_clk
    );

    reg [27:0] r_cnt;

    always @(posedge clk ) begin
        if (reset_p) begin
            UART_clk <= 0;
            r_cnt <= 0;
        end else begin
            if (r_cnt >= sys_freq/(BAUD_rate*2*2)) begin
                UART_clk <= ~UART_clk;
                r_cnt <= 0;
            end else begin
                r_cnt <= r_cnt + 1;
            end
        end
    end

endmodule
