`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/10 17:18:37
// Design Name: 
// Module Name: DS1302
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


module DS1302(
    //btw system
    input wire clk,
    input wire reset_p,
    //btw control module
    input wire [7:0] i_addr,
    input wire [7:0] i_data,
    input wire i_valid,
    output wire o_busy,
    output reg [7:0] r_receive,
    //to DS1302
    inout wire o_io,
    output wire o_sclk,
    output wire o_ce
    
    
);

//assume clk = 400kHz  ->  scl = 100kHz

//Idle state. move to I_START if addr, data is valid(i_valid == 1)
localparam S_IDLE = 0;
localparam S_CE_ON = 1;

localparam S_ADDR0 = 2;
localparam S_ADDR1 = 3;
localparam S_ADDR2 = 4;
localparam S_ADDR3 = 5;
localparam S_ADDR4 = 6;
localparam S_ADDR5 = 7;
localparam S_ADDR6 = 8;
localparam S_ADDR7 = 9;

//sending 8 bit data
localparam S_WRITE0 = 10;
localparam S_WRITE1 = 11;
localparam S_WRITE2 = 12;
localparam S_WRITE3 = 13;
localparam S_WRITE4 = 14;
localparam S_WRITE5 = 15;
localparam S_WRITE6 = 16;
localparam S_WRITE7 = 17;

//reading 8 bit data
localparam S_READ0 = 18;
localparam S_READ1 = 19;
localparam S_READ2 = 20;
localparam S_READ3 = 21;
localparam S_READ4 = 22;
localparam S_READ5 = 23;
localparam S_READ6 = 24;
localparam S_READ7 = 25;

localparam S_CE_OFF = 26;

//state register
reg [6:0]r_state, r_next_state;

//
reg [7:0] r_addr;
reg [7:0] r_data;
reg r_sda, r_scl;
reg [1:0] r_cnt_i2c;
reg r_RW;
reg r_CE;

assign o_io = (r_state == S_READ0) || (r_state == S_READ1) || (r_state == S_READ2) || (r_state == S_READ3) || 
               (r_state == S_READ4) || (r_state == S_READ5) || (r_state == S_READ6) || (r_state == S_READ7) ? 'hz : r_sda;
assign o_sclk = r_scl;
assign o_busy = (r_state == S_IDLE) || (r_state == S_CE_OFF) ? 0 : 1;
assign o_ce = r_CE;

always @(negedge clk, posedge reset_p ) begin
    if(reset_p) r_state <= 0;
    else r_state <= r_next_state;
end

always @(posedge clk, posedge reset_p) begin
    if (reset_p) begin
        r_next_state <= S_IDLE;
        r_addr <= 0;
        r_data <= 0;
        r_scl <= 0;
        r_sda <= 0;
        r_cnt_i2c <= 0;
        r_receive <= 0;
        r_CE <= 0;
    end else begin
        case (r_state)
            S_IDLE: begin
                if (i_valid) begin
                    r_next_state <= S_CE_ON;
                    r_addr <= i_addr;
                    r_data <= i_data;
                end
                else begin
                    r_next_state <= S_IDLE;
                    r_addr <= 0;
                    r_data <= 0;
                    r_scl <= 0;
                    r_sda <= 0;
                    r_cnt_i2c <= 0;
                end
            end
            S_CE_ON: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR0;
                else r_next_state <= S_CE_ON;
                r_CE <= 1;
            end
            S_ADDR0: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR1;
                else r_next_state <= S_ADDR0;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[0];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_addr[0];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_addr[0];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_addr[0];
                    end
                endcase
            end
            S_ADDR1: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR2;
                else r_next_state <= S_ADDR1;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[1];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_addr[1];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_addr[1];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_addr[1];
                    end
                endcase
            end
            S_ADDR2: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR3;
                else r_next_state <= S_ADDR2;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[2];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_addr[2];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_addr[2];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_addr[2];
                    end
                endcase
            end
            S_ADDR3: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR4;
                else r_next_state <= S_ADDR3;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[3];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_addr[3];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_addr[3];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_addr[3];
                    end
                endcase
            end
            S_ADDR4: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR5;
                else r_next_state <= S_ADDR4;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[4];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_addr[4];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_addr[4];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_addr[4];
                    end
                endcase
            end
            S_ADDR5: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR6;
                else r_next_state <= S_ADDR5;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[5];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_addr[5];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_addr[5];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_addr[5];
                    end
                endcase
            end
            S_ADDR6: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR7;
                else r_next_state <= S_ADDR6;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[6];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_addr[6];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_addr[6];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_addr[6];
                    end
                endcase
            end
            S_ADDR7: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3) begin
                    if(r_addr[0] == 0) r_next_state <= S_WRITE0;
                    else if(r_addr[0] == 1) r_next_state <= S_READ0;
                end
                else r_next_state <= S_ADDR7;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[7];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_addr[7];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_addr[7];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_addr[7];
                    end
                endcase
            end
            S_WRITE0: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE1;
                else r_next_state <= S_WRITE0;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[0];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_data[0];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_data[0];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_data[0];
                    end
                endcase
            end
            S_WRITE1: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE2;
                else r_next_state <= S_WRITE1;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[1];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_data[1];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_data[1];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_data[1];
                    end
                endcase
            end
            S_WRITE2: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE3;
                else r_next_state <= S_WRITE2;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[2];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_data[2];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_data[2];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_data[2];
                    end
                endcase
            end
            S_WRITE3: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE4;
                else r_next_state <= S_WRITE3;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[3];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_data[3];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_data[3];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_data[3];
                    end
                endcase
            end
            S_WRITE4: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE5;
                else r_next_state <= S_WRITE4;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[4];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_data[4];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_data[4];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_data[4];
                    end
                endcase
            end
            S_WRITE5: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE6;
                else r_next_state <= S_WRITE5;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[5];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_data[5];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_data[5];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_data[5];
                    end
                endcase
            end
            S_WRITE6: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE7;
                else r_next_state <= S_WRITE6;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[6];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_data[6];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_data[6];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_data[6];
                    end
                endcase
            end
            S_WRITE7: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_IDLE;
                else r_next_state <= S_WRITE7;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[7];
                    end
                    1: begin
                        r_scl <= 0;
                        r_sda <= r_data[7];
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_data[7];
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_data[7];
                    end
                endcase
            end
            S_READ0: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ1;
                else r_next_state <= S_READ0;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                    1: begin
                        r_scl <= 0;
                        r_receive[0] <= o_io;
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= 0;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                endcase
            end
            S_READ1: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ2;
                else r_next_state <= S_READ1;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                    1: begin
                        r_scl <= 0;
                        r_receive[1] <= o_io;
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= 0;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                endcase
            end
            S_READ2: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ3;
                else r_next_state <= S_READ2;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                    1: begin
                        r_scl <= 0;
                        r_receive[2] <= o_io;
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= 0;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                endcase
            end
            S_READ3: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ4;
                else r_next_state <= S_READ3;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                    1: begin
                        r_scl <= 0;
                        r_receive[3] <= o_io;
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= 0;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                endcase
            end
            S_READ4: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ5;
                else r_next_state <= S_READ4;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                    1: begin
                        r_scl <= 0;
                        r_receive[4] <= o_io;
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= 0;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                endcase
            end
            S_READ5: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ6;
                else r_next_state <= S_READ5;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                    1: begin
                        r_scl <= 0;
                        r_receive[5] <= o_io;
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= 0;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                endcase
            end
            S_READ6: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ7;
                else r_next_state <= S_READ6;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                    1: begin
                        r_scl <= 0;
                        r_receive[6] <= o_io;
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= 0;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                endcase
            end
            S_READ7: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_CE_OFF;
                else r_next_state <= S_READ7;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                    1: begin
                        r_scl <= 0;
                        r_receive[7] <= o_io;
                    end
                    2: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                endcase
            end
            S_CE_OFF: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_IDLE;
                else r_next_state <= S_CE_OFF;
                r_CE <= 0;
            end
        endcase
    end
end
    
endmodule
