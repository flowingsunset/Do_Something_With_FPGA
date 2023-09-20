`include "i2c_master_write.v"
`include "i2c_reg.v"
module i2c_top (
    input wire clk,
    input wire reset_p,
    inout wire o_sda,
    output wire o_scl,
    output wire o_empty
);
    wire [6:0] w_addr;
    wire [7:0] w_data;
    wire w_busy, w_RW, w_vallid, w_empty;

    assign o_empty = w_empty;
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

    i2c_master_write master(.clk(r_clk_400khz),.reset_p(reset_p),.i_addr(w_addr),.i_data(w_data),.i_RW(w_RW),.i_valid(w_vallid),.o_sda(o_sda),. o_scl(o_scl),. o_busy(w_busy));
    i2c_reg regi(.clk(clk),.reset_p(reset_p),.i_busy(w_busy),.o_addr(w_addr),.o_data(w_data),.o_RW(w_RW),.o_valid(w_vallid),.o_empty(w_empty));
    
endmodule