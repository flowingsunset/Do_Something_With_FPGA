`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/11 19:28:38
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


module project_top(
    input clk,
    input reset_p,
    //input output CLCD
    output o_sda,
    output o_scl
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

    wire [6:0] w_addr_gen;
    wire [7:0] w_data_gen, w_data_reg;
    wire w_RS, w_RW_reg, w_RW_gen, w_valid_reg, w_valid_gen, w_busy_I2C, w_busy_gen;

    CLCD_init_reg init_reg(.clk(clk), .reset_p(reset_p), .i_busy(w_busy_gen),
                   .o_data(w_data_reg), .o_RS(w_RS), .o_RW(w_RW_reg), .o_valid(w_valid_reg), .o_empty());

    CLCD_signal_generator sig_gen(.clk(clk), .reset_p(reset_p), 
                          //input output with i2c_master
                          .i_busy(w_busy_I2C), .o_valid(w_valid_gen), .o_RW(w_RW_gen), .o_data(w_data_gen), .o_addr(w_addr_gen),
                          //input output with CLCD_init_reg
                          .i_data(w_data_reg), .i_RS(w_RS), .i_RW(w_RW_reg), .i_valid(w_valid_reg), .o_busy(w_busy_gen));

    i2c_master master(.clk(r_clk_400khz),.reset_p(reset_p),.i_addr(w_addr_gen),.i_data(w_data_gen),.i_RW(w_RW_gen),.i_valid(w_valid_gen),
                  .o_sda(o_sda),. o_scl(o_scl),. o_busy(w_busy_I2C), .r_receive());

endmodule
