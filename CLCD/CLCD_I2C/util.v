module edge_detector_n(
    input clk,
    input cp_in,
    input rst_p,
    output p_edge,
    output n_edge
);
    reg cp_in_old, cp_in_cur;
    
    always@(negedge clk)begin
        if(rst_p) begin
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
    
    edge_detector_n edp0(.clk(clk), .cp_in(cp_usec),.rst_p(reset_p), .p_edge(), .n_edge(clk_usec));
    
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