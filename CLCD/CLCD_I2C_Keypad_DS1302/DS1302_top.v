`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/10 18:45:06
// Design Name: 
// Module Name: DS1302_top
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


module DS1302_top(
    input clk,
    input reset_p,
    input [6:0] sw

    inout o_sda,
    output o_scl,

    output [3:0] an,
    output [6:0] seg
    );


    wire [4:0] w_addr;
    wire [7:0] w_data;
    wire w_RW, w_valid, w_busy;
    wire [7:0] w_receive;

    DS1302 ds1302(.clk(clk), .reset_p(reset_p), .i_addr(w_addr), .i_data(w_data), .i_RW(w_RW), .i_valid(w_valid),
                  .o_sda(o_sda), .o_scl(o_scl), .o_busy(w_busy), .r_receive(w_receive));

endmodule
