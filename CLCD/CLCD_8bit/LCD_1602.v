module LCD_1602 (
	input i_clk,
	input i_reset,
	input i_busy,
	input [7:0] i_data,
	output reg o_r_cs,
	output reg [7:0] o_r_data,
	output reg o_r_RS,
	output o_busy
);



//r_state parameter
parameter S_IDLE = 0;
parameter S_8_BIT_MODE = 1;
parameter S_DISPALY_ON = 2;
parameter S_CLEAR = 3;
parameter S_ENTRY_MODE = 4;
parameter S_WRITE_INPUT = 5;

//Instruction {o_r_RS, o_r_data[7:0]}
//RW is always 0, E is controlled by LCD transmitter
parameter I_IDLE = 8'b0000_0000;
parameter I_8_BIT_MODE	= 8'b0011_1000;
parameter I_DISPALY_ON = 8'b0000_1100;
parameter I_CLEAR = 8'b0000_0001;
parameter I_ENTRY_MODE = 8'b0000_0110;

//other parameter
parameter P_CNT4MS = 500_000;
//parameter P_CNT4MS = 125_000;

reg[26:0] r_cnt;
reg	r_startCnt;
reg r_wait4ms;
reg [3:0] r_state;
reg [3:0] r_next;


//r_state
always @(posedge i_clk ) begin
		r_state <= r_next;
end

//r_next
always@* begin
	if(i_reset) r_next = S_IDLE;
	else begin
		case (r_state)
			S_IDLE: r_next = S_8_BIT_MODE;
			S_8_BIT_MODE : begin
				if(r_wait4ms) r_next = S_DISPALY_ON;
				else r_next = S_8_BIT_MODE;
			end
			S_DISPALY_ON : begin
				if(r_wait4ms) r_next = S_CLEAR;
				else r_next = S_DISPALY_ON;
			end
			S_CLEAR : begin 
				if(r_wait4ms) r_next = S_ENTRY_MODE;
				else r_next = S_CLEAR;
			end
			S_ENTRY_MODE : begin 
				if(r_wait4ms) r_next = S_WRITE_INPUT;
				else r_next = S_ENTRY_MODE;
			end
			S_WRITE_INPUT : r_next = S_WRITE_INPUT;
			default : r_next = S_IDLE;
		endcase
	end
end

// o_r_cs, {o_r_RS, o_r_data[7:0]}
always @* begin
	if(i_reset) begin
		o_r_cs = 0;
		o_r_RS = 0;
		o_r_data[7:0] = I_IDLE;
	end
	else begin
		o_r_cs = 0;
		o_r_RS = 0;
		o_r_data[7:0] = 0;
		case (r_state)
			S_IDLE: begin
				o_r_cs = 0;
				o_r_RS = 0;
				o_r_data[7:0] = I_IDLE;
			end
			S_8_BIT_MODE: begin
				if (!i_busy&!r_wait4ms&!r_startCnt) begin
					o_r_cs = 1;
					o_r_RS = 0;
					o_r_data[7:0] = I_8_BIT_MODE;
				end
			end
			S_DISPALY_ON: begin
				if (!i_busy&!r_wait4ms&!r_startCnt) begin
					o_r_cs = 1;
					o_r_RS = 0;
					o_r_data[7:0] = I_DISPALY_ON;
				end
			end
			S_CLEAR: begin
				if (!i_busy&!r_wait4ms&!r_startCnt) begin
					o_r_cs = 1;
					o_r_RS = 0;
					o_r_data[7:0] = I_CLEAR;
				end
			end
			S_ENTRY_MODE: begin
				if (!i_busy&!r_wait4ms&!r_startCnt) begin
					o_r_cs = 1;
					o_r_RS = 0;
					o_r_data[7:0] = I_ENTRY_MODE;
				end
			end
			S_WRITE_INPUT: begin
				if (!i_busy&!r_wait4ms&!r_startCnt&(i_data>0)) begin
					o_r_cs = 1;
					o_r_RS = 1;
					o_r_data[7:0] = i_data;
				end
			end
		endcase
	end
end

always @(posedge i_clk ) begin
	if (i_reset) begin
		r_cnt <= 0;
		r_wait4ms <= 0;
		r_startCnt<=0;
	end
	else begin
		case ({i_busy, r_wait4ms, r_startCnt})
			3'b100: begin
				r_cnt <= r_cnt;
				r_wait4ms <= r_wait4ms;
				r_startCnt <= 1;
			end
			3'b101: begin
				r_cnt <= r_cnt + 1;
				r_wait4ms <= r_wait4ms;
				r_startCnt <= r_startCnt;
			end
			3'b001: begin
				if(r_cnt>=P_CNT4MS) begin
					r_cnt <= r_cnt;
					r_startCnt <= 0;
					r_wait4ms <= 1;
				end
				else begin
					r_cnt <= r_cnt + 1;
					r_wait4ms <= r_wait4ms;
					r_startCnt <= r_startCnt;
				end
			end
			3'b010: begin
				r_cnt <= r_cnt;
				r_wait4ms <= 0;
				r_startCnt <= r_startCnt;
			end
			default: begin
				r_cnt <= 0;
				r_wait4ms <= 0;
				r_startCnt<=0;
			end
		endcase
	end
end

assign o_busy = (i_busy|r_wait4ms|r_startCnt) ? 1 : 0;


endmodule

