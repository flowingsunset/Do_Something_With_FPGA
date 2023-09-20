module VGA_controller(
	input sysclk,
	input btn,
	output [7:0] jb,
	output [7:0] jc);

	wire clk;
	wire [3:0] owR;
	wire [3:0] owG;
	wire [3:0] owB;
	wire owHsync;
	wire owVsync;
	wire rst;
	
	reg [3:0] rR = 4'b1111;
    reg [3:0] rG = 4'b1111;
    reg [3:0] rB = 4'b1111;

	assign owR = jb[3:0];
   	assign owB = jb[7:4];
   	assign owG = jc[3:0];
   	assign owHsync = jc[4];
   	assign owVsync = jc[5];
   	assign rst = btn;
   	
   	assign owR = rR;
    assign owG = rG;
    assign owB = rB;

	design_1_wrapper clk_gen (.btn(btn), .clk(clk), .sysclk(sysclk));
	
	reg	[9:0] H_cnt;
	reg [9:0] V_cnt;
	assign owHsync = (H_cnt >= 655 && H_cnt <=750) ? 0 : 1; 
	assign owVsync = (V_cnt >= 489 && V_cnt <= 490) ? 0 : 1;

	always@(posedge clk) begin
		if(rst) H_cnt <= 0;
		else if(H_cnt == 799) H_cnt <= 0;
		else H_cnt <= H_cnt + 1;
	end

	always@(posedge clk) begin
		if(rst) V_cnt <= 0;
		else if(H_cnt==799)begin
			if(V_cnt == 520) V_cnt <= 0;
			else V_cnt <= V_cnt+1;
		end
		else V_cnt <= V_cnt;
	end

	always@(posedge clk)
	begin
		if(rst) begin
			rR <= 4'b1111;
			rG <= 4'b1111;
			rB <= 4'b1111;
		end
		
		else begin
			if ((H_cnt>=0 ) && (H_cnt<= 90)) {rR, rG, rB} <= 12'hf00;
			else if ((H_cnt>=91 ) && (H_cnt<= 181)) {rR, rG, rB} <= 12'hf80;
			else if((H_cnt>=182 ) && (H_cnt<= 272)){rR, rG, rB} <= 12'hff0;
			else if((H_cnt>=273 ) && (H_cnt<= 363)){rR, rG, rB} <= 12'h080;
			else if((H_cnt>=364 ) && (H_cnt<= 454)){rR, rG, rB} <= 12'h00f;
			else if((H_cnt>=455 ) && (H_cnt<= 545)){rR, rG, rB} <= 12'h508;
			else if((H_cnt>=546 ) && (H_cnt<= 639)){rR, rG, rB} <= 12'h808;
			else {rR, rG, rB} <= 12'h000;
		end
	end

endmodule
