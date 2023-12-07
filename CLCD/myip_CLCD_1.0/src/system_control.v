`timescale 1ns / 1ps
module system_control(
    input clk,
    input reset_p,
    //from AXI4_register
    input [8*16-1:0] text_1, 
    input [8*16-1:0] text_2,
    //from i2c_reg
    input empty_reg,
    //btw CLCD_signal_generator
    output reg [7:0] data_CLCD,
    output reg RS_CLCD,
    output reg RW_CLCD,
    output reg valid_CLCD,
    input busy_CLCD
    //input [7:0] receive_I2C,  //not use this time
    );

    localparam S_INITIAL =          00;
    localparam S_IDLE =             01;
    localparam S_WRITE_1 =          02;
    localparam S_CHANGE_LINE =      03;
    localparam S_WRITE_2 =          04;
    localparam S_RETURN_HOME =      05;

    //signal regsiter for FSM
    reg [3:0] r_state, r_next_state;

    //display register
    reg [4:0] r_write;
    reg r_end_write;
    reg r_flag_CLCD, r_end_change_line, r_end_return;

    //edge detector
    wire w_busy_CLCD_pedge, w_busy_CLCD_nedge;
    edge_detector_n edp1(.clk(clk), .cp_in(busy_CLCD),.reset_p(reset_p), .p_edge(w_busy_CLCD_pedge), .n_edge(w_busy_CLCD_nedge));

    //FSM
    always @(posedge clk) begin
        if (reset_p) begin
            r_state <= S_INITIAL;
        end else begin
            r_state <= r_next_state;
        end
    end

    always @(*) begin
        case (r_state)
            S_INITIAL: begin
                if(empty_reg) r_next_state = S_IDLE;
                else r_next_state = S_INITIAL;
            end
            S_IDLE: begin
                r_next_state = S_WRITE_1;
            end
            S_WRITE_1: begin 
                if (r_end_write) r_next_state = S_CHANGE_LINE;
                else r_next_state = S_WRITE_1;
            end
            S_CHANGE_LINE: begin
                if(r_end_change_line) r_next_state = S_WRITE_2;
                else r_next_state = S_CHANGE_LINE;
            end
            S_WRITE_2: begin
                if(r_end_write) r_next_state = S_RETURN_HOME;
                else r_next_state = S_WRITE_2;
            end
            S_RETURN_HOME: begin
                if(r_end_return) r_next_state = S_IDLE;
                else r_next_state = S_RETURN_HOME;
            end
            default: r_next_state = S_IDLE;
        endcase
    end

    //control CLCD
    always @(posedge clk ) begin
        if (reset_p) begin
            data_CLCD <= 0;
            RS_CLCD <= 0;
            RW_CLCD <= 0;
            valid_CLCD <= 0;
            r_flag_CLCD <= 0;
            r_write <= 0;
            r_end_write <= 0;
            r_end_change_line <= 0;
            r_end_return <= 0;
        end else begin
            case (r_state)
                S_INITIAL: begin
                    valid_CLCD <= 0;
                    r_flag_CLCD <= 0;
                    r_end_change_line <= 0;
                    r_end_return <= 0;
                    r_write <= 0;
                    r_end_write <= 0;
                end 
                S_IDLE: begin
                    valid_CLCD <= 0;
                    r_flag_CLCD <= 0;
                    r_end_change_line <= 0;
                    r_end_return <= 0;
                    r_write <= 0;
                    r_end_write <= 0;
                end 
                S_WRITE_1: begin
                    if(r_write<16) begin
                        if(!r_flag_CLCD)begin
                            data_CLCD <= text_1[8*(16-r_write)-1-:8];
                            // data_CLCD <= 8'b0011_0000;
                            RS_CLCD <= 1;
                            RW_CLCD <= 0;
                            valid_CLCD <= 1;
                            r_flag_CLCD <= 1;
                        end
                        else if(w_busy_CLCD_pedge)begin
                            valid_CLCD <= 0;
                        end
                        else if (w_busy_CLCD_nedge) begin
                            r_write <= r_write+1;
                            r_flag_CLCD <= 0;
                        end
                    end
                    else r_end_write <= 1;
                end
                S_CHANGE_LINE: begin
                    if(!r_flag_CLCD && !r_end_change_line) begin
                        data_CLCD <= 8'b1100_0000;
                        RS_CLCD <= 0;
                        RW_CLCD <= 0;
                        valid_CLCD <= 1;
                        r_flag_CLCD <= 1;
                        r_write <= 0;
                        r_end_write <= 0;
                    end
                    else if (w_busy_CLCD_pedge) begin
                        valid_CLCD <= 0;
                    end
                    else if(w_busy_CLCD_nedge) begin
                        r_flag_CLCD <= 0;
                        r_end_change_line <= 1;
                    end
                end
                S_WRITE_2: begin
                    if(r_write<16) begin
                        if(!r_flag_CLCD)begin
                            data_CLCD <= text_2[8*(16-r_write)-1-:8];
                            // data_CLCD <= 8'b0011_0001;
                            RS_CLCD <= 1;
                            RW_CLCD <= 0;
                            valid_CLCD <= 1;
                            r_flag_CLCD <= 1;
                        end
                        else if(w_busy_CLCD_pedge)begin
                            valid_CLCD <= 0;
                        end
                        else if (w_busy_CLCD_nedge) begin
                            r_write <= r_write+1;
                            r_flag_CLCD <= 0;
                        end
                    end
                    else r_end_write <= 1;
                end
                S_RETURN_HOME: begin
                    if(!r_flag_CLCD && !r_end_return) begin
                        data_CLCD <= 8'b1000_0000;
                        RS_CLCD <= 0;
                        RW_CLCD <= 0;
                        valid_CLCD <= 1;
                        r_flag_CLCD <= 1;
                        r_write <= 0;
                        r_end_write <= 0;
                    end
                    else if (w_busy_CLCD_pedge) begin
                        valid_CLCD <= 0;
                    end
                    else if(w_busy_CLCD_nedge) begin
                        r_flag_CLCD <= 0;
                        r_end_return <= 1;
                    end
                end
            endcase
        end
    end

endmodule
