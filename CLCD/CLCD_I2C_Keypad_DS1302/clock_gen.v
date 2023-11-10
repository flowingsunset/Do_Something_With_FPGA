module clock_gen 
#(parameter sys_clk_freq = 100_000_000,
  parameter require_freq = 400_000)
(input clk,
 input reset_p,
 output reg r_clk);

reg [6:0]r_cnt;
always @(posedge clk, posedge reset_p) begin
    if(reset_p) begin
        r_cnt <= 0;
        r_clk <= 0;
    end
    else begin
        if(r_cnt >= sys_clk_freq/require_freq/2) begin
            r_cnt <= 0;
            r_clk <= ~r_clk;
        end
        else r_cnt <= r_cnt + 1;
    end
end
endmodule


