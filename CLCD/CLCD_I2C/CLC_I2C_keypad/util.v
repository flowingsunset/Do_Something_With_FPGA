module edge_detector_n(
    input clk,
    input cp_in,
    input reset_p,
    output p_edge,
    output n_edge
);
    reg cp_in_old, cp_in_cur;
    
    always@(negedge clk)begin
        if(reset_p) begin
            cp_in_old <= 0;
            cp_in_cur <= 0;
        end
        else begin
            cp_in_old <= cp_in_cur;
            cp_in_cur <= cp_in;
        end
    end
    
    assign p_edge = ~cp_in_old & cp_in_cur;
    assign n_edge = cp_in_old & ~cp_in_cur;
    

endmodule

module clock_usec(
    input clk, reset_p,
    output clk_usec
    );
    reg [6:0] cnt_10nsec;
    wire cp_usec;
    always@(posedge clk) begin
        if(reset_p) cnt_10nsec <= 0;
        else if(cnt_10nsec >= 99) cnt_10nsec <= 0;
        //else if(cnt_10nsec >= 9) cnt_10nsec <= 0;
        else cnt_10nsec <= cnt_10nsec+1;
    end
    
    assign cp_usec = cnt_10nsec < 49 ? 0 : 1;
    //assign cp_usec = cnt_10nsec < 4 ? 0 : 1;
    
    edge_detector_n edp0(.clk(clk), .cp_in(cp_usec),.reset_p(reset_p), .p_edge(), .n_edge(clk_usec));
    
endmodule

module clock_div_1000(
    input clk, clk_source, reset_p,
    output clk_div_1000
    );
    reg [8:0] cnt_clk;
    reg cp_div_1000;
    always@(posedge clk) begin
        if(reset_p) begin
            cnt_clk <= 0;
            cp_div_1000 <= 0;
        end
        else if(clk_source) begin
            if(cnt_clk >= 499) begin
            //if(cnt_clk >= 4) begin
                cnt_clk <= 0;
                cp_div_1000 <= ~cp_div_1000;
            end
            else cnt_clk <= cnt_clk+1;
        end
    end
    
    edge_detector_n edp1(clk, cp_div_1000,reset_p, ,clk_div_1000);
    
endmodule

module clock_sec(
    input clk, clk_msec, reset_p,
    output clk_sec
    );
    reg [8:0] cnt_msec;
    reg cp_sec;
    always@(posedge clk) begin
        if(reset_p) begin
            cnt_msec <= 0;
            cp_sec <= 0;
        end
        else if(clk_msec) begin
            if(cnt_msec >= 499) begin
            //if(cnt_msec >= 4) begin
                cnt_msec <= 0;
                cp_sec <= ~cp_sec;
            end
            else cnt_msec <= cnt_msec+1;
        end
    end
    
    edge_detector_n edp2(clk, cp_sec,reset_p, , clk_sec);
    
endmodule

module clock_min(
    input clk, clk_sec, reset_p,
    output clk_min
    );
    reg [5:0] cnt_sec;
    reg cp_min;
    always@(posedge clk) begin
        if(reset_p) begin
            cnt_sec <= 0;
            cp_min <= 0;
        end
        else if(clk_sec) begin
            if(cnt_sec >= 29) begin
                cnt_sec <= 0;
                cp_min <= ~cp_min;
            end
            else cnt_sec <= cnt_sec+1;
        end
    end
    
    edge_detector_n edp3(clk, cp_min,reset_p, , clk_min);
    
endmodule

module counter_dec_60(
    input clk, reset_p,
    input clk_time,
    output reg[3:0] dec1, dec10
);

    always@(posedge clk) begin
        if(reset_p) begin
            dec1 <= 0;
            dec10 <= 0;
        end
        else if(clk_time) begin
            if(dec1 >= 9) begin
                dec1 <= 0;
                if(dec10 >= 5) dec10 <= 0;
                else dec10 <= dec10+1;
            end
            else dec1 = dec1 + 1;
        end
    end

endmodule

module BCD_7_Segment(
	input [3:0] num,
	output [6:0] BCD
	);
//	assign BCD = (num == 0) ? 7'h01 :
//				 (num == 1) ? 7'h4f :
//				 (num == 2) ? 7'h12 :
//				 (num == 3) ? 7'h06 :
//				 (num == 4) ? 7'h4c :
//				 (num == 5) ? 7'h24 :
//				 (num == 6) ? 7'h20 :
//				 (num == 7) ? 7'h0f :
//				 (num == 8) ? 7'h00 :
//				 (num == 9) ? 7'h0c :
//				 (num == 10) ? 7'h08 :
//				 (num == 11) ? 7'h60 :
//				 (num == 12) ? 7'h72 :
//				 (num == 13) ? 7'h42 :
//				 (num == 14) ? 7'h30 :
//				 (num == 15) ? 7'h38 : 7'h8f;
assign BCD =     (num == 0) ? 7'b1000000 :
				 (num == 1) ? 7'b1111001 :
				 (num == 2) ? 7'b0100100 :
				 (num == 3) ? 7'b0110000 :
				 (num == 4) ? 7'b0011001 :
				 (num == 5) ? 7'b0010010 :
				 (num == 6) ? 7'b0000010 :
				 (num == 7) ? 7'b1111000 :
				 (num == 8) ? 7'b0000000 :
				 (num == 9) ? 7'b0011000 :
				 (num == 10) ? 7'b0001000 :
				 (num == 11) ? 7'b0000011 :
				 (num == 12) ? 7'b0100111 :
				 (num == 13) ? 7'b0100001 :
				 (num == 14) ? 7'b0000110 :
				 (num == 15) ? 7'b0001110 : 7'b1111111;
endmodule

module ring_counter_fnd(
    input clk,
    input reset_p,
    output [3:0] com
    );

    reg[3:0] temp;
    always@(posedge clk, posedge reset_p) begin
        if(reset_p) temp <= 0;
        else begin
            if(!((temp ==4'b1110) | (temp == 4'b1011) | (temp == 4'b1101) | (temp == 4'b0111)) ) temp <= 4'b1110;
            else temp <= {temp[2:0], temp[3]};
        end
    end
    assign com = temp;
endmodule

module FND_4digit_ctrl(
    input clk,
    input reset_p,
    input [15:0] value,
    output [3:0] com,
    output [6:0] seg_7
);

    reg [16:0] clk_1ms;
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) clk_1ms <= 0;
        else clk_1ms = clk_1ms+1;
    end
    ring_counter_fnd ring_ctrl(.clk(clk_1ms[16]), .reset_p(reset_p), .com(com));
    
    reg [3:0] hex_value;
    BCD_7_Segment BCD(hex_value, seg_7);
    
    always@(posedge clk or posedge reset_p) begin
        if(reset_p) hex_value = 7'h01;
        case(com)
            4'b1110: hex_value = value[3:0];
            4'b1101: hex_value = value[7:4];
            4'b1011: hex_value = value[11:8];
            4'b0111: hex_value = value[15:12];
            //default hex_value = hex_value;
        endcase
    end

endmodule