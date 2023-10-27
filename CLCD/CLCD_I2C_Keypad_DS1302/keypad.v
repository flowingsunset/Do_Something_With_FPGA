module Keypad (
	//system signal
	input i_clk,
	input i_reset,
	//btw keypad hardware
	input [3:0]i_col,
	output [3:0]o_row,
	//btw control module
	output reg [3:0] o_data,
	output o_btn_valid
);


//count number for generate 1ms (sys_frequency / 1000)
parameter P_CNT_1MS = 100_000;
reg [16:0] r_cnt;
always @(posedge i_clk ) begin
	if (i_reset) r_cnt <= 0;
	else if(r_cnt >= P_CNT_1MS)	r_cnt <= 0;
	else r_cnt <= r_cnt+1;
end

//output for detect col
reg [3:0] r_row;
assign o_row = r_row;

//4x4 keypad -> use 5 bit ring count to keep notice button is pushed ex) 01000 -> 10001
//			   if use 4 bit ring counter ex) 1000 -> 0001 may occur edge condition
reg [4:0] r_detect_btn;
wire w_btn_on;
assign w_btn_on = (r_detect_btn > 1);  //  hold 1 if button is keep pushed


edge_detector_n edp0(.clk(i_clk), .cp_in(w_btn_on),.reset_p(i_reset), .p_edge(o_btn_valid), .n_edge());

//change row 0 for every 1ms for detect col and debounce
always @(posedge i_clk ) begin
	if (i_reset) r_row <= 4'b1110;
	else if(r_cnt == P_CNT_1MS) r_row <= {r_row[2:0], r_row[3]};
	else r_row <= r_row;
end


//detect col to find pushed button
always @(posedge i_clk) begin
	if(i_reset) begin
		r_detect_btn <= 0;
		o_data <= 0;
	end
	else if(r_cnt==P_CNT_1MS/2)begin  // detect col at half count of P_CNT_1MS to avoid edge condition
		if (i_col<4'hf) begin  // if button is detected(col is pull-up -> if pushed, pushed line changed to zero)
			r_detect_btn <= {r_detect_btn[3:0], 1'b1}; //update detect_btn that some button has pushed
			case (r_row)  //4 bit register, only 1 bit is zero -> 4 cases
				4'b0111: begin //row4 is zero
					case (i_col)
						4'b0111:  o_data <= 4'hf;  //col0 is zero  S16
						4'b1011:  o_data <= 4'he;  //col1 is zero  S15
						4'b1101:  o_data <= 4'hd;  //col2 is zero  S14  
						4'b1110:  o_data <= 4'hc;  //col3 is zero  S13
						default: o_data <= o_data;
					endcase
				end 
				4'b1011: begin  
					case (i_col) //row3 is zero
						4'b0111:  o_data <= 4'hb;  //col0 is zero  S12
						4'b1011:  o_data <= 4'ha;  //col1 is zero  S11
						4'b1101:  o_data <= 4'h9;  //col2 is zero  S10
						4'b1110:  o_data <= 4'h8;  //col3 is zero  S09
						default: o_data <= o_data;
					endcase
				end 
				4'b1101: begin
					case (i_col) //row2 is zero
						4'b0111:  o_data <= 4'h7;  //col0 is zero  S08
						4'b1011:  o_data <= 4'h6;  //col1 is zero  S07
						4'b1101:  o_data <= 4'h5;  //col2 is zero  S06
						4'b1110:  o_data <= 4'h4;  //col3 is zero  S05
						default: o_data <= o_data;
					endcase
				end 
				4'b1110: begin
					case (i_col) //row1 is zero
						4'b0111:  o_data <= 4'h3;  //col0 is zero  S04
						4'b1011:  o_data <= 4'h2;  //col1 is zero  S03
						4'b1101:  o_data <= 4'h1;  //col2 is zero  S02
						4'b1110:  o_data <= 4'h0;  //col3 is zero  S01
						default: o_data <= o_data;
					endcase
				end 
				default: o_data <= o_data;
			endcase
		end
		else begin
			r_detect_btn <= {r_detect_btn[3:0], 1'b0};  // update register that button has not pushed
			o_data <= o_data;
		end
	end
	else begin  //do nothing condition
		o_data <= o_data;
		r_detect_btn <= r_detect_btn;
	end
end




endmodule
