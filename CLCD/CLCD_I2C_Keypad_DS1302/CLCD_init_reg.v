module CLCD_init_reg (
    input wire clk,
    input wire reset_p,
    input wire i_busy,
    output wire [7:0] o_data,
    output reg o_RS,
    output reg o_RW,  
    output reg o_valid,
    output reg o_empty
);

    reg [7:0] r_data;
    reg [5:0] r_state, r_next_state;
    reg r_state_on;

    assign o_data = r_data;

    wire w_busy_pedge, w_busy_nedge;
    edge_detector_n edn0(.clk(clk), .cp_in(i_busy),.reset_p(reset_p), .p_edge(w_busy_pedge), .n_edge(w_busy_nedge));

    wire w_clk_usec, w_clk_msec;
    clock_usec clk_usec(.clk(clk), .reset_p(reset_p),.clk_usec(w_clk_usec));
    clock_div_1000 clk_msec(.clk(clk), .clk_source(w_clk_usec), .reset_p(reset_p),.clk_div_1000(w_clk_msec));

    reg r_count_msec_e;
    reg [6:0] r_count_msec;
    always@(negedge clk or posedge reset_p) begin
        if(reset_p) r_count_msec <= 0;
        else begin
            if(w_clk_msec && r_count_msec_e) r_count_msec <= r_count_msec + 1;
            else if(!r_count_msec_e) r_count_msec <= 0;
        end
    end

    
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) r_state <= 0;
        else r_state <= r_next_state;
    end

    //r_next_state
    always @(posedge clk, posedge reset_p) begin
        if (reset_p) begin
            r_data <= 0;
            r_next_state <= 0;
            o_empty <= 0;
            o_RW <= 0;
            o_RS <= 0;
            r_state_on <= 0;
            r_count_msec_e <= 0;
            o_valid <= 0;
        end
        else begin
            case (r_state)
                //delay 20ms
                0: begin
                    if(!r_state_on) begin
                        r_count_msec_e <= 1;
                        r_state_on <= 1;
                    end
                    else if(r_count_msec >= 20) begin
                        r_next_state <= 1;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //input initial state 1 0011 0011 / 1100 1000 delay 5ms
                1: begin
                    if(!r_state_on) begin
                        r_data <= 8'b0000_0011;
                        o_RW <= 0;
                        o_RS <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 5) begin
                        r_next_state <= 2;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //input initial state 2 0011 0011 / 1100 1000
                2 : begin
                    if(!r_state_on) begin
                        r_data <= 8'b0000_0011;
                        o_RW <= 0;
                        o_RS <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 1) begin
                        r_next_state <= 3;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //input initial state 3 0011 0011 / 1100 1000
                3: begin
                    if(!r_state_on) begin
                        r_data <= 8'b0000_0011;
                        o_RW <= 0;
                        o_RS <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 1) begin
                        r_next_state <= 4;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //4-bit mode 0000 0010
                4: begin
                    if(!r_state_on) begin
                        r_data <= 8'b0000_0010;
                        o_RW <= 0;
                        o_RS <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 1) begin
                        r_next_state <= 5;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //Function set 0010_1000
                5: begin
                    if(!r_state_on) begin
                        r_data <= 8'b0010_1000;
                        o_RW <= 0;
                        o_RS <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 1) begin
                        r_next_state <= 6;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //Display off 0000 1000
                6: begin
                    if(!r_state_on) begin
                        r_data <= 8'b0000_1000;
                        o_RW <= 0;
                        o_RS <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 1) begin
                        r_next_state <= 7;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //Display clear 0000_0001
                7: begin
                    if(!r_state_on) begin
                        r_data <= 8'b0000_0001;
                        o_RW <= 0;
                        o_RS <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 1) begin
                        r_next_state <= 8;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //Entry mode set 0000_0110
                8: begin
                    if(!r_state_on) begin
                        r_data <= 8'b0000_0110;
                        o_RW <= 0;
                        o_RS <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 1) begin
                        r_next_state <= 9;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //Display on 0000_1111
                9: begin
                    if(!r_state_on) begin
                        r_data <= 8'b0000_1111;
                        o_RW <= 0;
                        o_RS <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 1) begin
                        r_next_state <= 10;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                10: begin
                    o_empty <= 1;
                end
            endcase
        end
    end
    
endmodule



