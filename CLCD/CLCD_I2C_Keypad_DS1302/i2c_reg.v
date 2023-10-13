module i2c_reg (
    input wire clk,
    input wire reset_p,
    input wire i_busy,
    output wire [6:0] o_addr,
    output wire [7:0] o_data,
    output reg o_RW,
    output reg o_valid,
    output reg o_empty
);

    reg [6:0] r_addr;
    reg [3:0] r_data;
    reg [3:0] r_ctrl;
    reg [5:0] r_state, r_next_state;
    reg r_state_on;

    assign o_addr = r_addr;
    assign o_data = {r_data, r_ctrl};

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
            r_addr <= 7'h27;
            r_data <= 0;
            r_ctrl <= 0;
            r_next_state <= 0;
            o_empty <= 0;
            o_RW <= 0;
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
                        r_data <= 4'b0011;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 1) begin
                        r_next_state <= 2;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                2 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0011;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 5) begin
                        r_next_state <= 3;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //input initial state 2 0011 0011 / 1100 1000
                3: begin
                    if(!r_state_on) begin
                        r_data <= 4'b0011;
                        r_ctrl <= 4'b1100;
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
                4 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0011;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec >= 5) begin
                        r_next_state <= 5;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //input initial state 3 0011 0011 / 1100 1000
                5 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0011;
                        r_ctrl <= 4'b1100;
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
                6: begin
                    if(!r_state_on) begin
                        r_data <= 4'b0011;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 7;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //4-bit mode 0010 0010 / 1100 1000
                7 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0010;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 8;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                8 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0010;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 9;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //Function set 0010 0010 1000 1000 /  1100 1000 1100 1000
                9 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0010;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 10;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                10 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0010;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 11;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                11 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b1000;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 12;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                12 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b1000;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 13;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //Display off 0000 0000 1000 1000 / 1100 1000 1100 1000
                13 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0000;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 14;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                14 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0000;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 15;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                15 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b1000;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 16;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                16 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b1000;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 17;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //Display clear 0000 0000 0001 0001 / 1100 1000 1100 1000
                17 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0000;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 18;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                18 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0000;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 19;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                19 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0001;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 20;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                20 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0001;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 21;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //Entry mode set 0000 0000 0110 0110 / 1100 1000 1100 1000
                21 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0000;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 22;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                22 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0000;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 23;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                23 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0110;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 24;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                24 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0110;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 25;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //Display on 0000 0000 1111 1111 / 1100 1000 1100 1000
                25 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0000;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 26;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                26 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b0000;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 27;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                27 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b1111;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 28;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                28 : begin
                    if(!r_state_on) begin
                        r_data <= 4'b1111;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= 29;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                29: begin
                    o_empty <= 1;
                end
            endcase
        end
    end
    
endmodule



