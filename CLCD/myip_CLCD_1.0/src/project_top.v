`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/07 09:07:49
// Design Name: 
// Module Name: project_top
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


`timescale 1ns / 1ps

module project_top(
    input clk,
    input reset_p,
    //from AXI4_register
    input [8*16-1:0] text_1, 
    input [8*16-1:0] text_2,
    //input output CLCD
    output o_sda,
    output o_scl
    );

    parameter sys_clk_freq = 100_000_000;
    parameter require_freq = 400_000;

    //clock_gen
    wire w_clk_400kHz;

    //i2c_init_reg
    wire w_RS_reg, w_RW_reg, w_valid_reg, w_empty_reg;
    wire [7:0] w_data_reg;

    //system_control
    wire [7:0] w_data_SYS2CLCD;
    wire w_RS_SYS2CLCD;
    wire w_RW_SYS2CLCD;
    wire w_valid_SYS2CLCD;

    //CLCD_signal_generator
    wire w_busy_CLCD, w_valid_CLCD;
    wire [6:0] w_addr_CLCD;
    wire [7:0] w_data_CLCD;
    //for bus
    wire [7:0] w_data_sys_reg;
    wire w_RS_sys_reg;
    wire w_RW_sys_reg;
    wire w_valid_sys_reg;

    //i2c_master
    wire w_busy_I2C;
    
    assign w_data_sys_reg = w_empty_reg ? w_data_SYS2CLCD : w_data_reg;
    assign w_RS_sys_reg = w_empty_reg ? w_RS_SYS2CLCD : w_RS_reg;
    assign w_RW_sys_reg = w_empty_reg ? w_RW_SYS2CLCD : w_RW_reg;
    assign w_valid_sys_reg = w_empty_reg ? w_valid_SYS2CLCD : w_valid_reg ;

    system_control system_control(
    .clk(clk), .reset_p(reset_p),
    //from i2c_reg
    .empty_reg(w_empty_reg),
    //from AXI4_register
    .text_1(text_1),
    .text_2(text_2),
    //btw CLCD_signal_generator
    .data_CLCD(w_data_SYS2CLCD),
    .RS_CLCD(w_RS_SYS2CLCD),
    .RW_CLCD(w_RW_SYS2CLCD),
    .valid_CLCD(w_valid_SYS2CLCD),
    .busy_CLCD(w_busy_CLCD)
    //input [7:0] receive_I2C,  //not use this time
    );

    clock_gen #(.sys_clk_freq(sys_clk_freq), .require_freq(require_freq)) clock_gen
               (.clk(clk), .reset_p(reset_p), .r_clk(w_clk_400kHz));

    CLCD_init_reg init_reg(.clk(clk), .reset_p(reset_p), .i_busy(w_busy_CLCD),
                   .o_data(w_data_reg), .o_RS(w_RS_reg), .o_RW(w_RW_reg), .o_valid(w_valid_reg), .o_empty(w_empty_reg));

    CLCD_signal_generator clcd_sig_gen(.clk(clk), .reset_p(reset_p), 
                          //input output with i2c_master
                          .i_busy(w_busy_I2C), .o_valid(w_valid_CLCD), .o_RW(w_RW_CLCD), .o_data(w_data_CLCD), .o_addr(w_addr_CLCD),
                          //input output with CLCD_init_reg and system_control
                          .i_data(w_data_sys_reg), .i_RS(w_RS_sys_reg), .i_RW(w_RW_sys_reg), .i_valid(w_valid_sys_reg), .o_busy(w_busy_CLCD));

    i2c_master master(.clk(w_clk_400kHz),.reset_p(reset_p),.i_addr(w_addr_CLCD),.i_data(w_data_CLCD),.i_RW(w_RW_CLCD),.i_valid(w_valid_CLCD),
                  .o_sda(o_sda),. o_scl(o_scl),. o_busy(w_busy_I2C), .r_receive());
endmodule
