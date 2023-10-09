module i2c_top (
    input wire clk,
    input wire reset_p,
    inout wire o_sda,
    output wire o_scl,
    input wire [3:0] i_col,
    output wire [3:0] o_row,
    output [3:0] an,
    output [6:0] seg
);
    wire [6:0] w_addr;
    wire [7:0] w_data;
    wire w_busy, w_RW, w_valid;
    wire [7:0] w_receive;

    wire [6:0] w_addr_key;
    wire [7:0] w_data_key;
    wire w_RW_key, w_valid_key;

    wire [6:0] w_addr_reg;
    wire [7:0] w_data_reg;
    wire w_RW_reg, w_valid_reg;

    wire [3:0] w_data_k2k;

    wire [7:0] w_value;

    
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
    
    //i2c reg for initialize CLCD
    //After initialization, keypad input is major
    assign w_addr = (w_empty) ? w_addr_key : w_addr_reg;
    assign w_data = (w_empty) ? w_data_key : w_data_reg;
    assign w_RW = (w_empty) ? w_RW_key : w_RW_reg;
    assign w_valid = (w_empty) ? w_valid_key : w_valid_reg;
    
    i2c_master master(.clk(r_clk_400khz),.reset_p(reset_p),.i_addr(w_addr),.i_data(w_data),.i_RW(w_RW),.i_valid(w_valid),.o_sda(o_sda),. o_scl(o_scl),. o_busy(w_busy), .r_receive(w_receive));

    i2c_reg regi(.clk(clk),.reset_p(reset_p),.i_busy(w_busy),.o_addr(w_addr_reg),.o_data(w_data_reg),.o_RW(w_RW_reg),.o_valid(w_valid_reg),.o_empty(w_empty));

    Keypad kpd(.i_clk(clk),.i_reset(reset_p),.i_col(i_col),. o_row(o_row),. o_data(w_data_k2k),.o_btn_valid(w_btn_valid));
    from_keypad_to_i2c_master k2i(.clk(clk), .reset_p(reset_p), .i_data(w_data_k2k), .i_btn_valid(w_btn_valid),
                                  .i_busy(w_busy), .o_addr(w_addr_key), .o_data(w_data_key), .o_RW(w_RW_key), .o_valid(w_valid_key), .i_receive(w_receive), .o_char_addr(w_value));

    FND_4digit_ctrl fnd(.clk(clk), .reset_p(reset_p), .value({8'b0, w_value}), .com(an), .seg_7(seg));
    
endmodule