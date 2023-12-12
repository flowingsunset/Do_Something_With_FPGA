`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/12 09:46:07
// Design Name: 
// Module Name: UART_tx_top
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


module UART_tx_top#(parameter sys_freq = 100_000_000,
                    parameter BAUD_rate = 9600)(
    input clk, reset_p,
    input [7:0]sw,
    output RsTx
    );
    wire UART_clk;
    wire w_valid, w_busy;
    UART_tx uart_tx(
    .clk(UART_clk), .reset_p(reset_p),
    .data_i(sw),
    .valid(w_valid),
    .tx(RsTx),
    .busy(w_busy)
    );

    UART_clk_gen #(
    .sys_freq(sys_freq),
    .BAUD_rate(BAUD_rate)) uart_clk(
    .clk(clk), .reset_p(reset_p),
    .UART_clk(UART_clk)
    );

    assign w_valid = (w_busy) ? 0 : 1;
endmodule
