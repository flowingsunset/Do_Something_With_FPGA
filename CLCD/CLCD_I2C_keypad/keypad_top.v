`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/21 17:32:13
// Design Name: 
// Module Name: keypad_top
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


module keypad_top(
    input clk, reset_p,
    input [3:0]i_col,
	output [3:0]o_row,
    output [3:0] an,
    output [6:0] seg,
    output [3:0] led
    );

    wire [3:0] w_data;
    wire w_btn_valid;
    reg [3:0] r_data;

    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            r_data <= 0;
        end else begin
            if (w_btn_valid) begin
                r_data <= w_data;
            end
        end
    end
    assign led = r_data;
    Keypad kpd(.i_clk(clk),.i_reset(reset_p),.i_col(i_col),. o_row(o_row),. o_data(w_data),.o_btn_valid(w_btn_valid));
    FND_4digit_ctrl fnd_cntr( .clk(clk), .reset_p(reset_p),.value({12'b0, r_data}), .com(an), .seg_7(seg));
endmodule
