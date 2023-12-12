`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/12 09:04:44
// Design Name: 
// Module Name: UART_tx
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


module UART_tx(
    input wire clk, reset_p,
    input wire [7:0] data_i,
    input wire valid,
    output reg tx,
    output busy
    );

    localparam S_IDLE = 0;
    localparam S_START = 1;
    localparam S_TRANSMIT = 2;
    localparam S_END = 3;

    reg [2:0] r_state;
    reg [7:0] r_buffer;
    reg r_cnt;
    reg [2:0] r_cnt_trans;

    assign busy = (r_state == S_IDLE) ? 0 : 1;

    always @(posedge clk, negedge reset_p ) begin
        if (reset_p) begin
            r_state <= S_IDLE;
            tx <= 1;
            r_buffer <= 0;
            r_cnt <= 0;
            r_cnt_trans <= 0;
        end else begin
            case (r_state)
                S_IDLE: begin
                    if (valid) begin
                        r_buffer <= data_i;
                        r_state <= S_START;
                        tx <= 1;
                        r_cnt <= 0;
                        r_cnt_trans <= 0;
                    end
                    else begin
                        tx <= 1;
                        r_buffer <= 0;
                        r_cnt <= 0;
                        r_cnt_trans <= 0;
                    end
                end
                S_START: begin
                    r_cnt <= r_cnt + 1;
                    if (r_cnt == 1) r_state <= S_TRANSMIT;
                    tx <= 0;
                end
                S_TRANSMIT: begin
                    r_cnt <= r_cnt + 1;
                    if(r_cnt == 1) begin
                        if (r_cnt_trans == 7) begin
                            r_state <= S_END;
                        end
                        else begin
                            r_cnt_trans <= r_cnt_trans + 1;
                        end 
                    end
                    tx <= r_buffer[r_cnt_trans];
                end
                S_END: begin
                    r_cnt <= r_cnt + 1;
                    tx <= 1;
                    if(r_cnt == 1) r_state <= S_IDLE;
                end
                default: r_state <= S_IDLE;
            endcase
        end
    end

endmodule
