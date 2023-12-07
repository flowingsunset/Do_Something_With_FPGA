module i2c_master (
    //system signal
    input wire clk,
    input wire reset_p,
    //btw control module
    input wire [6:0] i_addr,
    input wire [7:0] i_data,
    input wire i_RW,
    input wire i_valid,
    output wire o_busy,
    output reg [7:0] r_receive,
    //btw i2c wire
    output wire o_sda,
    output wire o_scl
);

//assume clk = 400kHz  ->  scl = 100kHz

//Idle state. move to I_START if addr, data is valid(i_valid == 1)
localparam S_IDLE = 0;
//clear sda low to start i2c communication
localparam S_START = 1;
//sending 7bit i2c address
localparam S_ADDR7 = 2;
localparam S_ADDR6 = 3;
localparam S_ADDR5 = 4;
localparam S_ADDR4 = 5;
localparam S_ADDR3 = 6;
localparam S_ADDR2 = 7;
localparam S_ADDR1 = 8;
//send Read(1) or Write(0)
localparam S_RW = 9;
//if slave understand sda == 0 else restart communicatinon
localparam S_ACK1 = 10;
//sending 8 bit i2c data
localparam S_WRITE7 = 11;
localparam S_WRITE6 = 12;
localparam S_WRITE5 = 13;
localparam S_WRITE4 = 14;
localparam S_WRITE3 = 15;
localparam S_WRITE2 = 16;
localparam S_WRITE1 = 17;
localparam S_WRITE0 = 18;
//reading 8 bit i2c data
localparam S_READ7 = 19;
localparam S_READ6 = 20;
localparam S_READ5 = 21;
localparam S_READ4 = 22;
localparam S_READ3 = 23;
localparam S_READ2 = 24;
localparam S_READ1 = 25;
localparam S_READ0 = 26;
//if slave understand write, sda == 0 else restart communication
//if master understand read, sda == 1 else restart communication
localparam S_ACK2 = 27;
//set SDA low to high to end i2c communication
localparam S_STOP = 28;

//state register
reg [6:0]r_state, r_next_state;

//
reg [6:0] r_addr;
reg [7:0] r_data;
reg r_sda, r_scl;
reg [1:0] r_cnt_i2c;
reg r_RW;

assign o_sda = r_sda ? 1'hz : 0;
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
        r_receive <= 0;
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
                        r_sda <= 1;
                    end
                    1: begin
                        r_scl <= 1;
                        r_sda <= 1;
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
                if (r_cnt_i2c >=3) begin
                    if(r_RW == 0)r_next_state <= S_WRITE7;
                    if(r_RW == 1)r_next_state <= S_READ7;
                end
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
            S_WRITE7: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE6;
                else r_next_state <= S_WRITE7;
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
            S_WRITE6: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE5;
                else r_next_state <= S_WRITE6;
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
            S_WRITE5: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE4;
                else r_next_state <= S_WRITE5;
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
            S_WRITE4: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE3;
                else r_next_state <= S_WRITE4;
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
            S_WRITE3: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE2;
                else r_next_state <= S_WRITE3;
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
            S_WRITE2: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE1;
                else r_next_state <= S_WRITE2;
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
            S_WRITE1: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_WRITE0;
                else r_next_state <= S_WRITE1;
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
            S_WRITE0: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ACK2;
                else r_next_state <= S_WRITE0;
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
            S_READ7: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ6;
                else r_next_state <= S_READ7;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                    1: begin
                        r_scl <= 1;
                        r_receive[7] <= o_sda;
                    end
                    2: begin
                        r_scl <= 1;
                        r_receive[7] <= o_sda;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                endcase
            end
            S_READ6: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ5;
                else r_next_state <= S_READ6;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                    1: begin
                        r_scl <= 1;
                        r_receive[6] <= o_sda;
                    end
                    2: begin
                        r_scl <= 1;
                        r_receive[6] <= o_sda;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                endcase
            end
            S_READ5: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ4;
                else r_next_state <= S_READ5;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                    1: begin
                        r_scl <= 1;
                        r_receive[5] <= o_sda;
                    end
                    2: begin
                        r_scl <= 1;
                        r_receive[5] <= o_sda;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                endcase
            end
            S_READ4: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ3;
                else r_next_state <= S_READ4;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                    1: begin
                        r_scl <= 1;
                        r_receive[4] <= o_sda;
                    end
                    2: begin
                        r_scl <= 1;
                        r_receive[4] <= o_sda;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                endcase
            end
            S_READ3: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ2;
                else r_next_state <= S_READ3;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                    1: begin
                        r_scl <= 1;
                        r_receive[3] <= o_sda;
                    end
                    2: begin
                        r_scl <= 1;
                        r_receive[3] <= o_sda;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                endcase
            end
            S_READ2: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ1;
                else r_next_state <= S_READ2;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                    1: begin
                        r_scl <= 1;
                        r_receive[2] <= o_sda;
                    end
                    2: begin
                        r_scl <= 1;
                        r_receive[2] <= o_sda;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                endcase
            end
            S_READ1: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_READ0;
                else r_next_state <= S_READ1;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                    1: begin
                        r_scl <= 1;
                        r_receive[1] <= o_sda;
                    end
                    2: begin
                        r_scl <= 1;
                        r_receive[1] <= o_sda;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                endcase
            end
            S_READ0: begin
                r_cnt_i2c <= r_cnt_i2c + 1;
                if (r_cnt_i2c >=3)r_next_state <= S_ACK2;
                else r_next_state <= S_READ0;
                case (r_cnt_i2c)
                    0: begin
                        r_scl <= 0;
                        r_sda <= 1;
                    end
                    1: begin
                        r_scl <= 1;
                        r_receive[0] <= o_sda;
                    end
                    2: begin
                        r_scl <= 1;
                        r_receive[0] <= o_sda;
                    end
                    3: begin
                        r_scl <= 0;
                        r_sda <= 1;
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
