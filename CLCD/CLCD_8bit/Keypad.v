module Keypad (
	input i_clk,
	input i_reset,
	input [3:0]i_col,
	output [3:0]o_row,
	output reg [3:0]o_r_data,
	output o_cs
);

parameter P_CNT_1MS = 125_004;

reg [16:0] r_cnt;
reg [3:0] r_row;
reg [4:0] r_detect_btn;
assign o_row = r_row;

always @(posedge i_clk ) begin
	if (i_reset) r_cnt <= 0;
	else if(r_cnt == P_CNT_1MS)	r_cnt <= 0;
	else r_cnt <= r_cnt+1;
end
always @(posedge i_clk ) begin
	if (i_reset) r_row <= 4'b1110;
	else if(r_cnt == P_CNT_1MS) r_row <= {r_row[2:0], r_row[3]};
	else r_row <= r_row;
end

always @(posedge i_clk) begin
	if(i_reset) begin
		r_detect_btn <= 0;
		r_detect_btn <= 0;
	end
	else if(r_cnt==P_CNT_1MS/2)begin
		if (i_col<4'hf) begin
			r_detect_btn <= {r_detect_btn[3:0], 1'b1};
			case (r_row)
				4'b0111: begin
					case (i_col)
						4'b0111:  o_r_data <= 4'h0;
						4'b1011:  o_r_data <= 4'h1;
						4'b1101:  o_r_data <= 4'h2;
						4'b1110:  o_r_data <= 4'h3;
						default: o_r_data <= o_r_data;
					endcase
				end 
				4'b1011: begin
					case (i_col)
						4'b0111:  o_r_data <= 4'h4;
						4'b1011:  o_r_data <= 4'h5;
						4'b1101:  o_r_data <= 4'h6;
						4'b1110:  o_r_data <= 4'h7;
						default: o_r_data <= o_r_data;
					endcase
				end 
				4'b1101: begin
					case (i_col)
						4'b0111:  o_r_data <= 4'h8;
						4'b1011:  o_r_data <= 4'h9;
						4'b1101:  o_r_data <= 4'ha;
						4'b1110:  o_r_data <= 4'hb;
						default: o_r_data <= o_r_data;
					endcase
				end 
				4'b1110: begin
					case (i_col)
						4'b0111:  o_r_data <= 4'hc;
						4'b1011:  o_r_data <= 4'hd;
						4'b1101:  o_r_data <= 4'he;
						4'b1110:  o_r_data <= 4'hf;
						default: o_r_data <= o_r_data;
					endcase
				end 
				default: o_r_data <= o_r_data;
			endcase
		end
		else begin
			r_detect_btn <= {r_detect_btn[3:0], 1'b0};
			o_r_data <= o_r_data;
		end
	end
	else begin
		o_r_data <= o_r_data;
		r_detect_btn <= r_detect_btn;
	end
end

assign o_cs = (r_detect_btn > 1) ? 1 : 0;
	
endmodule