module LCD_Transmitter (
	input i_clk,
	input i_reset,
	input i_cs,
	input i_RS,
	input [7:0] i_data,
	output o_busy,
	output reg o_r_RW,
	output reg o_r_RS,
	output reg o_r_E,
	output reg [7:0] o_r_data
);

//r_state parameter
parameter P_IDLE = 0;
parameter P_DATA_IN = 1;
parameter P_WAIT_DATA = 2;
parameter P_DATA_WRITE = 3;
parameter P_WAIT_WRITE = 4;

//other parameter
//parameter P_CNT_1MS = 125_000;
parameter P_CNT_1MS = 12_500;

reg [23:0] r_cnt;
reg [2:0] r_state;
reg r_waitData;
reg r_waitWrite;
reg [2:0] r_next;

always @(posedge i_clk ) begin
	if (i_reset) r_state <= P_IDLE;
	else begin
		r_state <= r_next;	
	end
end

always @* begin
	if(i_reset) r_next = P_IDLE;
	else begin
		case (r_state)
			P_IDLE: begin
				if(i_cs) r_next = P_DATA_IN;
				else r_next = P_IDLE;
			end
			P_DATA_IN : r_next = P_WAIT_DATA;
			P_WAIT_DATA : begin
				if(r_waitData) r_next = P_DATA_WRITE;
				else r_next = P_WAIT_DATA;
			end
			P_DATA_WRITE : r_next = P_WAIT_WRITE;
			P_WAIT_WRITE : begin
				if(r_waitWrite) r_next = P_IDLE;
				else r_next = P_WAIT_WRITE;
			end
			default: r_next = P_IDLE;
		endcase
	end
end

always @(posedge i_clk) begin
	if(i_reset) begin
		o_r_RW <= 0;
		o_r_RS <= 0;
		o_r_E <= 0;
		o_r_data <= 0;
	end
	else begin
		case (r_state)
			P_IDLE: begin
				if(i_cs) begin
					o_r_RW <= 0;
					o_r_RS <= i_RS;
					o_r_E <= 0;
					o_r_data <= i_data;
				end
				else begin
					o_r_RW <= 0;
					o_r_RS <= 0;
					o_r_E <= 0;
					o_r_data <= 0;
				end
			end
			P_DATA_IN:begin
				o_r_RW <= 0;
				o_r_RS <= o_r_RS;
				o_r_E <= 1;
				o_r_data <= o_r_data;
			end
			P_DATA_WRITE : begin
				o_r_RW <= 0;
				o_r_RS <= o_r_RS;
				o_r_E <= 0;
				o_r_data <= o_r_data;
			end	
			default: begin
				o_r_RW <= o_r_RW;
				o_r_RS <= o_r_RS;
				o_r_E <= o_r_E;
				o_r_data <= o_r_data;
			end	
		endcase
	end
end

always @(posedge i_clk ) begin
	if (i_reset) begin
		r_cnt <= 0;
		r_waitData <=0;
		r_waitWrite <= 0;
	end
	else begin
		case (r_state)
			P_IDLE:begin
				r_cnt <= 0;
				r_waitData <=0;
				r_waitWrite <= 0;
			end
			P_DATA_IN: begin
				r_cnt <= 0;
				r_waitData <=0;
				r_waitWrite <= 0;
			end
			P_WAIT_DATA:begin
				if(r_cnt>=P_CNT_1MS) begin
					r_cnt <= r_cnt;
					r_waitData <= 1;
					r_waitWrite <= 0;
				end
				else begin
					r_cnt <= r_cnt+1;
					r_waitData <= 0;
					r_waitWrite <= 0;
				end
			end
			P_DATA_WRITE: begin
				r_cnt <= 0;
				r_waitData <=0;
				r_waitWrite <= 0;
			end
			P_WAIT_WRITE : begin
				if (r_cnt>=P_CNT_1MS) begin
					r_cnt <= r_cnt;
					r_waitData <=0;
					r_waitWrite <= 1;
				end
				else begin
					r_cnt <= r_cnt+1;
					r_waitData <=0;
					r_waitWrite <= 0;
				end
			end
			default: begin
				r_cnt <= 0;
				r_waitData <=0;
				r_waitWrite <= 0;
			end
		endcase
	end
end


assign o_busy = (r_state != P_IDLE) ? 1 : 0;
	
endmodule