module Control_LCD (
	input i_clk,
	input i_reset,
	input [3:0]i_data,
	input i_cs,
	input i_busy,
	output reg [7:0] o_data
);

parameter [8*16-1:0] P_HEX = {8'h46,8'h45,8'h44,8'h43,8'h42,8'h41, 8'h39,8'h38,8'h37,8'h36,8'h35,8'h34,8'h33,8'h32,8'h31,8'h30};
parameter P_CNT_1MS = 125_000;
//parameter P_CNT_1MS = 125;

reg [16:0] r_cnt;
reg [1:0] r_cs_edge;

wire w_edgeDetected;

always @(posedge i_clk ) begin
	if (i_reset) begin
		r_cnt <= 0;
		r_cs_edge <= 0;
	end
	else if (r_cnt == P_CNT_1MS) begin
		r_cnt <= 0;
		r_cs_edge <= {r_cs_edge[0], i_cs};
	end
	else begin
		r_cnt <= r_cnt + 1;
		r_cs_edge <= r_cs_edge;
	end
end


always @(posedge i_clk ) begin
	if (i_reset) begin
		o_data <= 0;
	end
	else if(w_edgeDetected)begin
		if (!i_busy) begin
			o_data <= P_HEX[8*i_data[3:0] +: 8];
		end
		else begin
			o_data <= 0;
		end
	end
	else begin
		o_data <= 0;
	end
end

assign w_edgeDetected = (r_cs_edge[0]&!r_cs_edge[1]) ? 1 : 0;

	
endmodule