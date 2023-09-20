`timescale 1ns/1ps
module top (
	input sysclk,
	input reset,
	input [3:0] col,
	output [3:0] row,
	output RW,
	output RS,
	output E,
	output [7:0] data
	);


wire [3:0]w_data_keypad;
wire w_cs_keypad;

wire [7:0] w_data_ctrl;
wire w_busy_LCD;

wire w_busy_trans;
wire [7:0]w_data_LCD;
wire w_RS;

Keypad keypad(
	.i_clk(sysclk),
	.i_reset(reset),
	.i_col(col),
	.o_row(row),
	.o_r_data(w_data_keypad),
	.o_cs(w_cs_keypad)
);

Control_LCD ctrl(
	.i_clk(sysclk),
	.i_reset(reset),
	.i_data(w_data_keypad),
	.i_cs(w_cs_keypad),
	.i_busy(w_busy_LCD),
	.o_data(w_data_ctrl)
);

LCD_1602 LCD(
	.i_clk(sysclk),
	.i_reset(reset),
	.i_busy(w_busy_trans),
	.i_data(w_data_ctrl),
	.o_r_cs(w_cs_LCD),
	.o_r_data(w_data_LCD),
	.o_r_RS(w_RS),
	.o_busy(w_busy_LCD)
);


LCD_Transmitter trans(
	.i_clk(sysclk),
	.i_reset(reset),
	.i_cs(w_cs_LCD),
	.i_RS(w_RS),
	.i_data(w_data_LCD),
	.o_busy(w_busy_trans),
	.o_r_RW(RW),
	.o_r_RS(RS),
	.o_r_E(E),
	.o_r_data(data)
);
	
endmodule
