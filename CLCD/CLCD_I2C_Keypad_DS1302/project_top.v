`timescale 1ns / 1ps

module project_top(
    input clk,
    input reset_p,
    //input output CLCD
    output o_sda,
    output o_scl,
    //input output RTC
    inout o_io,
    output o_ce,
    output o_sclk
    //input output Keypad
    // input [3:0]i_col,
	// output [3:0]o_row
    );

    reg r_clk_400khz;
    reg [6:0]r_cnt_400khz;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            r_cnt_400khz <= 0;
            r_clk_400khz <= 0;
        end
        else begin
            if(r_cnt_400khz > 120) begin
                r_cnt_400khz <= 0;
                r_clk_400khz <= ~r_clk_400khz;
            end
            else r_cnt_400khz <= r_cnt_400khz + 1;
        end
    end

    //i2c_init_reg
    wire w_RS_reg, w_RW_reg, w_valid_reg, w_empty_reg;
    wire [7:0] w_data_reg;

    //system_control
    //to DS1302
    wire [7:0] w_addr_SYS2RTC;
    wire w_valid_SYS2RTC;
    //to CLCD
    wire [7:0] w_data_SYS2CLCD;
    wire w_RS_SYS2CLCD;
    wire w_RW_SYS2CLCD;
    wire w_valid_SYS2CLCD;

    //DS1302
    wire w_busy_RTC;
    wire [7:0] w_receive_RTC;

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

    //keypad
    //wire [3:0] w_data_keypad;
    //wire w_valid_keypad;

    assign w_data_sys_reg = w_empty_reg ? w_data_SYS2CLCD : w_data_reg;
    assign w_RS_sys_reg = w_empty_reg ? w_RS_SYS2CLCD : w_RS_reg;
    assign w_RW_sys_reg = w_empty_reg ? w_RW_SYS2CLCD : w_RW_reg;
    assign w_valid_sys_reg = w_empty_reg ? w_valid_SYS2CLCD : w_valid_reg ;

    system_control system_control(
    .clk(clk), .reset_p(reset_p),
    //from i2c_reg
    .empty_reg(w_empty_reg),
    //btw DS1302
    .addr_RTC(w_addr_SYS2RTC),
    //output reg [7:0] data_RTC,    //not use this time
    .valid_RTC(w_valid_SYS2RTC),
    .busy_RTC(w_busy_RTC),
    .receive_RTC(w_receive_RTC),
    //btw CLCD_signal_generator
    .data_CLCD(w_data_SYS2CLCD),
    .RS_CLCD(w_RS_SYS2CLCD),
    .RW_CLCD(w_RW_SYS2CLCD),
    .valid_CLCD(w_valid_SYS2CLCD),
    .busy_CLCD(w_busy_CLCD)
    //input [7:0] receive_I2C,  //not use this time
    //btw Keypad    not use now
    //.data_Keypad(w_data_keypad),
    //.valid_Keypad(w_valid_keypad)
    );



    CLCD_init_reg init_reg(.clk(clk), .reset_p(reset_p), .i_busy(w_busy_CLCD),
                   .o_data(w_data_reg), .o_RS(w_RS_reg), .o_RW(w_RW_reg), .o_valid(w_valid_reg), .o_empty(w_empty_reg));

    CLCD_signal_generator clcd_sig_gen(.clk(clk), .reset_p(reset_p), 
                          //input output with i2c_master
                          .i_busy(w_busy_I2C), .o_valid(w_valid_CLCD), .o_RW(w_RW_CLCD), .o_data(w_data_CLCD), .o_addr(w_addr_CLCD),
                          //input output with CLCD_init_reg and system_control
                          .i_data(w_data_sys_reg), .i_RS(w_RS_sys_reg), .i_RW(w_RW_sys_reg), .i_valid(w_valid_sys_reg), .o_busy(w_busy_CLCD));

    i2c_master master(.clk(r_clk_400khz),.reset_p(reset_p),.i_addr(w_addr_CLCD),.i_data(w_data_CLCD),.i_RW(w_RW_CLCD),.i_valid(w_valid_CLCD),
                  .o_sda(o_sda),. o_scl(o_scl),. o_busy(w_busy_I2C), .r_receive());
    
    DS1302 ds1302(.clk(r_clk_400khz), .reset_p(reset_p), .i_addr(w_addr_SYS2RTC), .i_data(8'h0), .i_valid(w_valid_SYS2RTC),
                  .o_io(o_io), .o_sclk(o_sclk), .o_ce(o_ce), .o_busy(w_busy_RTC), .r_receive(w_receive_RTC));

    //Keypad kpd(.i_clk(clk),.i_reset(reset_p),.i_col(i_col),. o_row(o_row),. o_data(w_data_keypad),.o_btn_valid(w_valid_keypad));

endmodule
