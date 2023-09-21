`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/20 19:48:48
// Design Name: 
// Module Name: from_keypad_to_i2c_master
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


module from_keypad_to_i2c_master(
    input clk,
    input reset_p,
    //from keypad
    input [3:0] i_data,
    input i_btn_valid,
    //to i2c master
    input i_busy,
    output [6:0] o_addr,
    output [7:0] o_data,
    output o_RW,
    output reg o_valid
    );
    parameter [8*16-1:0] P_HEX = {8'h46,8'h45,8'h44,8'h43,8'h42,8'h41, 8'h39,8'h38,8'h37,8'h36,8'h35,8'h34,8'h33,8'h32,8'h31,8'h30};
    
    //this module for CLCD 16x2 and write only
    assign o_addr = 7'h27;
    assign o_RW = 0;

    reg [3:0] r_data;
    reg [3:0] r_ctrl;
    reg [5:0] r_state, r_next_state;
    reg r_state_on;
    
    assign o_data = {r_data, r_ctrl};

    wire w_clk_usec, w_clk_msec;
    clock_usec clk_usec(.clk(clk), .reset_p(reset_p),.clk_usec(w_clk_usec));
    clock_div_1000 clk_msec(.clk(clk), .clk_source(w_clk_usec), .reset_p(reset_p),.clk_div_1000(w_clk_msec));

     wire w_busy_pedge, w_busy_nedge;
     edge_detector_n edn0(.clk(clk), .cp_in(i_busy),.reset_p(reset_p), .p_edge(w_busy_pedge), .n_edge(w_busy_nedge));

    reg r_count_msec_e;
    reg [6:0] r_count_msec;
    always@(negedge clk or posedge reset_p) begin
        if(reset_p) r_count_msec <= 0;
        else begin
            if(w_clk_msec && r_count_msec_e) r_count_msec <= r_count_msec + 1;
            else if(!r_count_msec_e) r_count_msec <= 0;
        end
    end

    always @(negedge clk, posedge reset_p) begin
        if(reset_p) r_state <= 0;
        else r_state <= r_next_state;
    end

    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            r_data <= 0;
            r_ctrl <= 0;
            o_valid <= 0;
            r_state_on <= 0;
            r_next_state <= 0;
            r_count_msec_e <= 0;
        end
        else begin
            case(r_state)
                0: begin
                    if(i_btn_valid) 
                        r_next_state <= 1;
                end
                1 : begin
                    if(!r_state_on) begin
                        r_data <= P_HEX[8*i_data+4+:4];
                        r_ctrl <= 4'b1101;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 2;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                2 : begin
                    if(!r_state_on) begin
                        r_data <= P_HEX[8*i_data+4+:4];
                        r_ctrl <= 4'b1001;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 3;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                3 : begin
                    if(!r_state_on) begin
                        r_data <= P_HEX[8*i_data+:4];
                        r_ctrl <= 4'b1101;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 4;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                4 : begin
                    if(!r_state_on) begin
                        r_data <= P_HEX[8*i_data+:4];
                        r_ctrl <= 4'b1001;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 0;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
        endcase
        end
    end

endmodule
