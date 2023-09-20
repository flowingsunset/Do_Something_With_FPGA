`default_nettype none
module i2c_master_write (
    input wire clk,
    input wire reset_p,
    input wire [6:0] i_addr,
    input wire [7:0] i_data,
    input wire i_RW,
    input wire i_valid,
    output wire o_sda,
    output wire o_scl,
    output wire o_busy
);

//no ack and no read
//assume clk = 400kHz  ->  scl = 100kHz
//i_RW = 0 for only write mode

localparam S_IDLE = 0;
localparam S_START = 1;
localparam S_ADDR7 = 2;
localparam S_ADDR6 = 3;
localparam S_ADDR5 = 4;
localparam S_ADDR4 = 5;
localparam S_ADDR3 = 6;
localparam S_ADDR2 = 7;
localparam S_ADDR1 = 8;
localparam S_RW = 9;
localparam S_ACK1 = 10;
localparam S_DATA7 = 11;
localparam S_DATA6 = 12;
localparam S_DATA5 = 13;
localparam S_DATA4 = 14;
localparam S_DATA3 = 15;
localparam S_DATA2 = 16;
localparam S_DATA1 = 17;
localparam S_DATA0 = 18;
localparam S_ACK2 = 19;
localparam S_STOP = 20;

reg [6:0]r_state, r_next_state;
reg [6:0] r_addr;
reg [7:0] r_data;
reg r_sda, r_scl;
reg [1:0] r_cnt_i2c;
reg r_RW;

assign o_sda = r_sda;
assign o_scl = r_scl;
assign o_busy = (r_state == S_IDLE) ? 0 : 1;
always @(negedge clk, posedge reset_p ) begin
    if(reset_p) r_state <= 0;
    else r_state <= r_next_state;
end

always @(posedge clk, posedge reset_p) begin
    if (reset_p) begin
        r_next_state <= 0;
        r_addr <= 0;
        r_data <= 0;
        r_scl <= 1;
        r_sda <= 1;
        r_cnt_i2c <= 0;
        r_RW <= 0;
    end else begin
        case (r_state)
            S_IDLE: begin
                if (i_valid) begin
                    r_next_state <= S_START;
                    r_addr <= i_addr;
                    r_data <= i_data;
                    r_RW <= i_RW;
                end
            end
            S_START: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR7;
                else r_next_state <= S_START;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 1'hz;
                    end
                    1: begin
                        r_scl <= 1;
                        r_sda <= 1'hz;
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
            S_ADDR7: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR6;
                else r_next_state <= S_ADDR7;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[6];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_ADDR6: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR5;
                else r_next_state <= S_ADDR6;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[5];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_ADDR5: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR4;
                else r_next_state <= S_ADDR5;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[4];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_ADDR4: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR3;
                else r_next_state <= S_ADDR4;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[3];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_ADDR3: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR2;
                else r_next_state <= S_ADDR3;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[2];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_ADDR2: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ADDR1;
                else r_next_state <= S_ADDR2;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[1];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_ADDR1: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_RW;
                else r_next_state <= S_ADDR1;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_addr[0];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_RW: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ACK1;
                else r_next_state <= S_RW;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_RW;
                    end
                    1: begin
                        r_scl <= 1;
                        r_sda <= r_RW;
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= r_RW;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= r_RW;
                    end
                endcase
            end
            S_ACK1: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_DATA7;
                else r_next_state <= S_ACK1;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                    1: begin
                        r_scl <= 1;
                        r_sda <= 1;
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= 1;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                endcase
            end
            S_DATA7: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_DATA6;
                else r_next_state <= S_DATA7;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[7];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_DATA6: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_DATA5;
                else r_next_state <= S_DATA6;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[6];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_DATA5: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_DATA4;
                else r_next_state <= S_DATA5;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[5];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_DATA4: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_DATA3;
                else r_next_state <= S_DATA4;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[4];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_DATA3: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_DATA2;
                else r_next_state <= S_DATA3;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[3];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_DATA2: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_DATA1;
                else r_next_state <= S_DATA2;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[2];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_DATA1: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_DATA0;
                else r_next_state <= S_DATA1;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[1];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_DATA0: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ACK2;
                else r_next_state <= S_DATA0;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= r_data[0];
                    end
                    1: begin
                        r_scl <= 1;
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
            S_ACK2: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_STOP;
                else r_next_state <= S_ACK2;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                    1: begin
                        r_scl <= 1;
                        r_sda <= 1;
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= 1;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                endcase
            end
            S_STOP: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_IDLE;
                else r_next_state <= S_STOP;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 0;
                    end
                    1: begin
                        r_scl <= 1;
                        r_sda <= 0;
                    end
                    2: begin
                        r_scl <= 1;
                        r_sda <= 1;
                    end
                    3: begin
                        r_scl <= 1;
                        r_sda <= 1;
                    end
                endcase
            end
        endcase
    end
end
    
endmodule