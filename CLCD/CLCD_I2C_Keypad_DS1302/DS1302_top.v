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
    input [6:0] sw,

    inout o_io,
    output o_sclk,
    output o_ce,

    output [3:0] an,
    output [6:0] seg
    );


    wire [7:0] w_addr;
    wire [7:0] w_data;
    wire w_RW, w_valid, w_busy;
    wire [7:0] w_receive;

    wire w_busy_pedge, w_busy_nedge;

    reg [7:0] r_addr;
    reg r_state_on;
    reg r_valid;

    assign w_valid = r_valid;
    assign w_addr = r_addr;
    assign w_RW = 1'b1;

   

    reg [17:0]r_cnt_400khz;
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            r_cnt_400khz <= 0;
        end
        else begin
            r_cnt_400khz <= r_cnt_400khz + 1;
        end
    end


    DS1302 ds1302(.clk(r_cnt_400khz[14]), .reset_p(reset_p), .i_addr(w_addr), .i_data(8'h0), .i_valid(w_valid),
                  .o_io(o_io), .o_sclk(o_sclk), .o_ce(o_ce), .o_busy(w_busy), .r_receive(w_receive));
    edge_detector_n edn0(.clk(clk), .cp_in(w_busy),.reset_p(reset_p), .p_edge(w_busy_pedge), .n_edge(w_busy_nedge));
    
    FND_4digit_ctrl fnd(.clk(clk), .reset_p(reset_p), .value({1'b0, sw, w_receive}), .com(an), .seg_7(seg));

    always @(posedge clk ) begin
        if (reset_p) begin
            r_addr <= 0;
            r_state_on <= 0;
            r_valid <= 0;
        end else begin
            if(r_state_on == 0 && sw>0) begin
                case (sw)
                    7'h01: r_addr <= 8'h81;
                    7'h02: r_addr <= 8'h83;
                    7'h04: r_addr <= 8'h85;
                    7'h08: r_addr <= 8'h87;
                    7'h10: r_addr <= 8'h89;
                    7'h20: r_addr <= 8'h8b;
                    7'h40: r_addr <= 8'h8d;
                endcase
                r_state_on <= 1;
                r_valid <= 1;
            end
            else if(w_busy_pedge) begin
                r_valid <= 0;
            end
            else if (w_busy_nedge) begin
                r_state_on <= 0;
            end
        end
    end

endmodule
