`timescale 1ns / 1ps
module system_control(
    input clk,
    input reset_p,
    //debug
    output reg [9:0] led,
    //from i2c_reg
    input empty_reg,
    //btw DS1302
    output reg [7:0] addr_RTC,
    //output reg [7:0] data_RTC,    //not use this time
    output reg valid_RTC,
    input busy_RTC,
    input [7:0] receive_RTC,
    //btw CLCD_signal_generator
    output reg [7:0] data_CLCD,
    output reg RS_CLCD,
    output reg RW_CLCD,
    output reg valid_CLCD,
    input busy_CLCD
    //input [7:0] receive_I2C,  //not use this time
    //btw Keypad
    // input [3:0] data_Keypad,
    // input valid_Keypad
    );

    

    localparam S_INITIAL =      00;
    localparam S_IDLE =         01;
    localparam S_READ_YEAR =    02;
    localparam S_READ_MONTH =   03;
    localparam S_READ_DAY =     04;
    localparam S_READ_HOUR =    05;
    localparam S_READ_MINUTE =  06;
    localparam S_READ_SECOND =  07;
    localparam S_WRITE_ALL =    08;
    localparam S_RETURN_HOME =  09;

    //signal regsiter for FSM
    reg [3:0] r_state, r_next_state;
    reg r_end_read_year, r_end_read_month, r_end_read_day, r_end_read_hour, r_end_read_minute, r_end_read_second;
    reg [13:0] r_end_write;
    reg r_end_return;

    //signal register for RTC
    reg r_flag_RTC;
    reg r_flag_CLCD;

    //date register
    reg [3:0] r_date [13:0];



    function [7:0] f_hex2ascii;
        input [3:0] hex;
        case (hex)
            4'h0: f_hex2ascii = 8'h30;
            4'h1: f_hex2ascii = 8'h31;
            4'h2: f_hex2ascii = 8'h32;
            4'h3: f_hex2ascii = 8'h33;
            4'h4: f_hex2ascii = 8'h34;
            4'h5: f_hex2ascii = 8'h35;
            4'h6: f_hex2ascii = 8'h36;
            4'h7: f_hex2ascii = 8'h37;
            4'h8: f_hex2ascii = 8'h38;
            4'h9: f_hex2ascii = 8'h39;
            default: f_hex2ascii = 8'h21; //'!'
        endcase
        
    endfunction

    //edge detector
    wire w_busy_RTC_pedge, w_busy_RTC_nedge;
    edge_detector_n edp0(.clk(clk), .cp_in(busy_RTC),.reset_p(reset_p), .p_edge(w_busy_RTC_pedge), .n_edge(w_busy_RTC_nedge));
    wire w_busy_CLCD_pedge, w_busy_CLCD_nedge;
    edge_detector_n edp1(.clk(clk), .cp_in(busy_CLCD),.reset_p(reset_p), .p_edge(w_busy_CLCD_pedge), .n_edge(w_busy_CLCD_nedge));

    always @(*) begin
        case (r_state)
            S_INITIAL: led = 10'h001;
            S_IDLE: led = 10'h002;
            S_READ_YEAR: led = 10'h004;
            S_READ_MONTH: led = 10'h008;
            S_READ_DAY: led = 10'h010;
            S_READ_HOUR: led = 10'h020;
            S_READ_MINUTE: led = 10'h040;
            S_READ_SECOND: led = 10'h080;
            S_WRITE_ALL: led = 10'h100;
            S_RETURN_HOME: led = 10'h200;
            default: led = 10'h0;
        endcase
    end


    //state
    always @(posedge clk) begin
        if (reset_p) begin
            r_state <= 0;
        end else begin
            r_state <= r_next_state;
        end
    end
    //next state
    always @(*) begin
        if(reset_p) begin
            r_next_state = S_INITIAL;
        end
        else begin
            r_next_state = S_INITIAL;
            case (r_state)
                S_INITIAL: begin
                    if(empty_reg) r_next_state = S_IDLE;
                    else r_next_state = S_INITIAL;
                end
                S_IDLE: begin
                    r_next_state = S_READ_YEAR;
                end
                S_READ_YEAR: begin
                    if(r_end_read_year) r_next_state = S_READ_MONTH;
                    else r_next_state = S_READ_YEAR;
                end
                S_READ_MONTH: begin
                    if(r_end_read_month) r_next_state = S_READ_DAY;
                    else r_next_state = S_READ_MONTH;
                end
                S_READ_DAY: begin
                    if(r_end_read_day) r_next_state = S_READ_HOUR;
                    else r_next_state = S_READ_DAY;
                end
                S_READ_HOUR: begin
                    if(r_end_read_hour) r_next_state = S_READ_MINUTE;
                    else r_next_state = S_READ_HOUR;
                end
                S_READ_MINUTE: begin
                    if(r_end_read_minute) r_next_state = S_READ_SECOND;
                    else r_next_state = S_READ_MINUTE;
                end
                S_READ_SECOND: begin
                    if(r_end_read_second) r_next_state = S_WRITE_ALL;
                    else r_next_state = S_READ_SECOND;
                end
                S_WRITE_ALL: begin
                    if(r_end_write == 14'h3fff) r_next_state = S_RETURN_HOME;
                    else r_next_state = S_WRITE_ALL;
                end
                S_RETURN_HOME: begin
                    if(r_end_return) r_next_state = S_IDLE;
                    else r_next_state = S_RETURN_HOME;
                end
            endcase
        end
    end

    //control DS1302
    always @(posedge clk ) begin
        if (reset_p) begin
            r_end_read_year <= 0;
            r_end_read_month <= 0;
            r_end_read_day <= 0;
            r_end_read_hour <= 0;
            r_end_read_minute <= 0;
            r_end_read_second <= 0;
            r_flag_RTC <= 0;
            r_date[0] <= 2;
            r_date[1] <= 0;
        end else begin
            case (r_state)
                S_INITIAL: begin
                    r_end_read_year <= 0;
                    r_end_read_month <= 0;
                    r_end_read_day <= 0;
                    r_end_read_hour <= 0;
                    r_end_read_minute <= 0;
                    r_end_read_second <= 0;
                end 
                S_IDLE: begin
                    r_end_read_year <= 0;
                    r_end_read_month <= 0;
                    r_end_read_day <= 0;
                    r_end_read_hour <= 0;
                    r_end_read_minute <= 0;
                    r_end_read_second <= 0;
                end 
                S_READ_YEAR: begin
                    if(!r_flag_RTC && !r_end_read_year) begin
                        addr_RTC <= 8'h8d;
                        valid_RTC <= 1;
                        r_flag_RTC <= 1;
                    end
                    else if(w_busy_RTC_pedge) begin
                        valid_RTC <= 0;
                    end
                    else if(w_busy_RTC_nedge) begin
                        r_date[2] <= receive_RTC[7:4];
                        r_date[3] <= receive_RTC[3:0];
                        r_end_read_year <= 1;
                        r_flag_RTC <= 0;
                    end
                end
                S_READ_MONTH: begin
                    if(!r_flag_RTC && !r_end_read_month) begin
                        addr_RTC <= 8'h89;
                        valid_RTC <= 1;
                        r_flag_RTC <= 1;
                    end
                    else if(w_busy_RTC_pedge) begin
                        valid_RTC <= 0;
                    end
                    else if(w_busy_RTC_nedge) begin
                        r_date[4] <= receive_RTC[7:4];
                        r_date[5] <= receive_RTC[3:0];
                        r_end_read_month <= 1;
                        r_flag_RTC <= 0;
                    end
                end
                S_READ_DAY: begin
                    if(!r_flag_RTC && !r_end_read_day) begin
                        addr_RTC <= 8'h87;
                        valid_RTC <= 1;
                        r_flag_RTC <= 1;
                    end
                    else if(w_busy_RTC_pedge) begin
                        valid_RTC <= 0;
                    end
                    else if(w_busy_RTC_nedge) begin
                        r_date[6] <= receive_RTC[7:4];
                        r_date[7] <= receive_RTC[3:0];
                        r_end_read_day <= 1;
                        r_flag_RTC <= 0;
                    end
                end
                S_READ_HOUR: begin
                    if(!r_flag_RTC && !r_end_read_hour) begin
                        addr_RTC <= 8'h85;
                        valid_RTC <= 1;
                        r_flag_RTC <= 1;
                    end
                    else if(w_busy_RTC_pedge) begin
                        valid_RTC <= 0;
                    end
                    else if(w_busy_RTC_nedge) begin
                        r_date[8] <= receive_RTC[7:4];
                        r_date[9] <= receive_RTC[3:0];
                        r_end_read_hour <= 1;
                        r_flag_RTC <= 0;
                    end
                end
                S_READ_MINUTE: begin
                    if(!r_flag_RTC && !r_end_read_minute) begin
                        addr_RTC <= 8'h83;
                        valid_RTC <= 1;
                        r_flag_RTC <= 1;
                    end
                    else if(w_busy_RTC_pedge) begin
                        valid_RTC <= 0;
                    end
                    else if(w_busy_RTC_nedge) begin
                        r_date[10] <= receive_RTC[7:4];
                        r_date[11] <= receive_RTC[3:0];
                        r_end_read_minute <= 1;
                        r_flag_RTC <= 0;
                    end
                end
                S_READ_SECOND: begin
                    if(!r_flag_RTC && !r_end_read_second) begin
                        addr_RTC <= 8'h81;
                        valid_RTC <= 1;
                        r_flag_RTC <= 1;
                    end
                    else if(w_busy_RTC_pedge) begin
                        valid_RTC <= 0;
                    end
                    else if(w_busy_RTC_nedge) begin
                        r_date[12] <= receive_RTC[7:4];
                        r_date[13] <= receive_RTC[3:0];
                        r_end_read_second <= 1;
                        r_flag_RTC <= 0;
                    end
                end
            endcase
        end
    end

    //control CLCD
    always @(posedge clk ) begin
        if (reset_p) begin
            data_CLCD <= 0;
            RS_CLCD <= 0;
            RW_CLCD <= 0;
            valid_CLCD <= 0;
            r_flag_CLCD <= 0;
            r_end_write <= 14'h0;
            r_end_return <= 0;
        end else begin
            case (r_state)
                S_INITIAL: begin
                    valid_CLCD <= 0;
                    r_flag_CLCD <= 0;
                    r_end_write <= 14'h0;
                    r_end_return <= 0;
                end 
                S_IDLE: begin
                    valid_CLCD <= 0;
                    r_flag_CLCD <= 0;
                    r_end_write <= 14'h0;
                    r_end_return <= 0;
                end 
                S_WRITE_ALL: begin
                    case (r_end_write)
                        14'b00_0000_0000_0000: begin
                            if(!r_flag_CLCD && !r_end_write[0])begin
                                data_CLCD <= f_hex2ascii(r_date[0]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[0] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end 
                        14'b00_0000_0000_0001: begin
                            if(!r_flag_CLCD && !r_end_write[1])begin
                                data_CLCD <= f_hex2ascii(r_date[1]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[1] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b00_0000_0000_0011: begin
                            if(!r_flag_CLCD && !r_end_write[2])begin
                                data_CLCD <= f_hex2ascii(r_date[2]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[2] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b00_0000_0000_0111: begin
                            if(!r_flag_CLCD && !r_end_write[3])begin
                                data_CLCD <= f_hex2ascii(r_date[3]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[3] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b00_0000_0000_1111: begin
                            if(!r_flag_CLCD && !r_end_write[4])begin
                                data_CLCD <= f_hex2ascii(r_date[4]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[4] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b00_0000_0001_1111: begin
                            if(!r_flag_CLCD && !r_end_write[5])begin
                                data_CLCD <= f_hex2ascii(r_date[5]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[5] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b00_0000_0011_1111: begin
                            if(!r_flag_CLCD && !r_end_write[6])begin
                                data_CLCD <= f_hex2ascii(r_date[6]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[6] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b00_0000_0111_1111: begin
                            if(!r_flag_CLCD && !r_end_write[7])begin
                                data_CLCD <= f_hex2ascii(r_date[7]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[7] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b00_0000_1111_1111: begin
                            if(!r_flag_CLCD && !r_end_write[8])begin
                                data_CLCD <= f_hex2ascii(r_date[8]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[8] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b00_0001_1111_1111: begin
                            if(!r_flag_CLCD && !r_end_write[9])begin
                                data_CLCD <= f_hex2ascii(r_date[9]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[9] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b00_0011_1111_1111: begin
                            if(!r_flag_CLCD && !r_end_write[10])begin
                                data_CLCD <= f_hex2ascii(r_date[10]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[10] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b00_0111_1111_1111: begin
                            if(!r_flag_CLCD && !r_end_write[11])begin
                                data_CLCD <= f_hex2ascii(r_date[11]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[11] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b00_1111_1111_1111: begin
                            if(!r_flag_CLCD && !r_end_write[12])begin
                                data_CLCD <= f_hex2ascii(r_date[12]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[12] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                        14'b01_1111_1111_1111: begin
                            if(!r_flag_CLCD && !r_end_write[13])begin
                                data_CLCD <= f_hex2ascii(r_date[13]);
                                RS_CLCD <= 1;
                                RW_CLCD <= 0;
                                valid_CLCD <= 1;
                                r_flag_CLCD <= 1;
                            end
                            else if(w_busy_CLCD_pedge)begin
                                valid_CLCD <= 0;
                            end
                            else if (w_busy_CLCD_nedge) begin
                                r_end_write[13] <= 1;
                                r_flag_CLCD <= 0;
                            end
                        end
                    endcase
                end
                S_RETURN_HOME: begin
                    if(!r_flag_CLCD && !r_end_return) begin
                        data_CLCD <= 8'b1000_0000;
                        RS_CLCD <= 0;
                        RW_CLCD <= 0;
                        valid_CLCD <= 1;
                        r_flag_CLCD <= 1;
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
