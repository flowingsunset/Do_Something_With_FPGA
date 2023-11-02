`timescale 1ns / 1ps
module system_control(
    input clk,
    input reset_p,
    //from i2c_reg
    input empty_reg,
    //btw DS1302
    output reg [7:0] addr_RTC,
    output reg [7:0] data_RTC,
    output reg valid_RTC,
    input busy_RTC,
    input [7:0] receive_RTC,
    //btw CLCD_signal_generator
    output reg [7:0] data_CLCD,
    output reg RS_CLCD,
    output reg RW_CLCD,
    output reg valid_CLCD,
    input busy_CLCD,
    //input [7:0] receive_I2C,  //not use this time
    //btw Keypad
    input [3:0] data_Keypad,
    input valid_Keypad
    );

    localparam TIME_YEAR =  01;
    localparam TIME_MONTH = 02;
    localparam TIME_DAY =   03;
    localparam TIME_HOUR =  04;
    localparam TIME_MIN =   05;
    localparam TIME_SEC =   06;

    localparam ASCII_A =        00;
    localparam ASCII_C =        01;
    localparam ASCII_D =        02;
    localparam ASCII_E =        03;
    localparam ASCII_H =        04;
    localparam ASCII_I =        05;
    localparam ASCII_M =        06;
    localparam ASCII_N =        07;
    localparam ASCII_O =        08;
    localparam ASCII_R =        09;
    localparam ASCII_S =        10;
    localparam ASCII_T =        11;
    localparam ASCII_U =        12;
    localparam ASCII_Y =        13;
    localparam ASCII_EMPTY =    14;

    localparam S_INITIAL =          00;
    localparam S_IDLE =             01;
    localparam S_READ_YEAR =        02;
    localparam S_READ_MONTH =       03;
    localparam S_READ_DAY =         04;
    localparam S_READ_HOUR =        05;
    localparam S_READ_MINUTE =      06;
    localparam S_READ_SECOND =      07;
    localparam S_WRITE_TIME =       08;
    localparam S_CHANGE_LINE =      09;
    localparam S_WRITE_SETTING =    10;
    localparam S_RETURN_HOME =      11;
    localparam S_CHANGE_TIME =      12;

    //signal regsiter for FSM
    reg [3:0] r_state, r_next_state;
    reg r_end_read_year, r_end_read_month, r_end_read_day, r_end_read_hour, r_end_read_minute, r_end_read_second;
    reg [13:0] r_end_write;
    reg r_end_change_line;
    reg r_end_change_time;
    reg r_end_return;

    //signal register for RTC
    reg r_flag_RTC;
    reg r_flag_CLCD;

    //date register
    reg [3:0] r_date [13:0];

    //keypad register
    reg [3:0] r_data_keypad [1:0];
    reg [2:0] r_setting;
    reg r_change_time;


    function [7:0] f_num2ascii;
        input [3:0] num;
        case (num)
            4'h0: f_num2ascii = 8'h30;  //'0'
            4'h1: f_num2ascii = 8'h31;
            4'h2: f_num2ascii = 8'h32;
            4'h3: f_num2ascii = 8'h33;
            4'h4: f_num2ascii = 8'h34;
            4'h5: f_num2ascii = 8'h35;
            4'h6: f_num2ascii = 8'h36;
            4'h7: f_num2ascii = 8'h37;
            4'h8: f_num2ascii = 8'h38;
            4'h9: f_num2ascii = 8'h39;  //'9'
            default: f_num2ascii = 8'h21; //'!'
        endcase
    endfunction

    function [7:0] f_alphabet2ascii;
        input [3:0] alphabet;
        case (alphabet)
            ASCII_A: f_alphabet2ascii = 8'h41;
            ASCII_C: f_alphabet2ascii = 8'h43;
            ASCII_D: f_alphabet2ascii = 8'h44;
            ASCII_E: f_alphabet2ascii = 8'h45;
            ASCII_H: f_alphabet2ascii = 8'h48;
            ASCII_I: f_alphabet2ascii = 8'h49;
            ASCII_M: f_alphabet2ascii = 8'h4d;
            ASCII_N: f_alphabet2ascii = 8'h4e;
            ASCII_O: f_alphabet2ascii = 8'h4f;
            ASCII_R: f_alphabet2ascii = 8'h52;
            ASCII_S: f_alphabet2ascii = 8'h53;
            ASCII_T: f_alphabet2ascii = 8'h54;
            ASCII_U: f_alphabet2ascii = 8'h55;
            ASCII_Y: f_alphabet2ascii = 8'h59;
            ASCII_EMPTY: f_alphabet2ascii = 8'h20;
            default: f_alphabet2ascii = 8'h21;
        endcase
    endfunction

    function [7:0] f_time2ascii;
        input [2:0] tim;
        input [2:0] order;
        case ({tim, order})
            {TIME_YEAR, 3'd1}: f_time2ascii = f_alphabet2ascii(ASCII_Y);
            {TIME_YEAR, 3'd2}: f_time2ascii = f_alphabet2ascii(ASCII_E);
            {TIME_YEAR, 3'd3}: f_time2ascii = f_alphabet2ascii(ASCII_A);
            {TIME_YEAR, 3'd4}: f_time2ascii = f_alphabet2ascii(ASCII_R);
            {TIME_YEAR, 3'd5}: f_time2ascii = f_alphabet2ascii(ASCII_EMPTY);
            {TIME_MONTH, 3'd1}: f_time2ascii = f_alphabet2ascii(ASCII_M);
            {TIME_MONTH, 3'd2}: f_time2ascii = f_alphabet2ascii(ASCII_O);
            {TIME_MONTH, 3'd3}: f_time2ascii = f_alphabet2ascii(ASCII_N);
            {TIME_MONTH, 3'd4}: f_time2ascii = f_alphabet2ascii(ASCII_T);
            {TIME_MONTH, 3'd5}: f_time2ascii = f_alphabet2ascii(ASCII_H);
            {TIME_DAY, 3'd1}: f_time2ascii = f_alphabet2ascii(ASCII_D);
            {TIME_DAY, 3'd2}: f_time2ascii = f_alphabet2ascii(ASCII_A);
            {TIME_DAY, 3'd3}: f_time2ascii = f_alphabet2ascii(ASCII_Y);
            {TIME_DAY, 3'd4}: f_time2ascii = f_alphabet2ascii(ASCII_EMPTY);
            {TIME_DAY, 3'd5}: f_time2ascii = f_alphabet2ascii(ASCII_EMPTY);
            {TIME_HOUR, 3'd1}: f_time2ascii = f_alphabet2ascii(ASCII_H);
            {TIME_HOUR, 3'd2}: f_time2ascii = f_alphabet2ascii(ASCII_O);
            {TIME_HOUR, 3'd3}: f_time2ascii = f_alphabet2ascii(ASCII_U);
            {TIME_HOUR, 3'd4}: f_time2ascii = f_alphabet2ascii(ASCII_R);
            {TIME_HOUR, 3'd5}: f_time2ascii = f_alphabet2ascii(ASCII_EMPTY);
            {TIME_MIN, 3'd1}: f_time2ascii = f_alphabet2ascii(ASCII_M);
            {TIME_MIN, 3'd2}: f_time2ascii = f_alphabet2ascii(ASCII_I);
            {TIME_MIN, 3'd3}: f_time2ascii = f_alphabet2ascii(ASCII_N);
            {TIME_MIN, 3'd4}: f_time2ascii = f_alphabet2ascii(ASCII_EMPTY);
            {TIME_MIN, 3'd5}: f_time2ascii = f_alphabet2ascii(ASCII_EMPTY);
            {TIME_SEC, 3'd1}: f_time2ascii = f_alphabet2ascii(ASCII_S);
            {TIME_SEC, 3'd2}: f_time2ascii = f_alphabet2ascii(ASCII_E);
            {TIME_SEC, 3'd3}: f_time2ascii = f_alphabet2ascii(ASCII_C);
            {TIME_SEC, 3'd4}: f_time2ascii = f_alphabet2ascii(ASCII_EMPTY);
            {TIME_SEC, 3'd5}: f_time2ascii = f_alphabet2ascii(ASCII_EMPTY);
            default: f_time2ascii = f_alphabet2ascii(ASCII_EMPTY);
        endcase
    endfunction

    function [7:0] f_time2RTCaddr;
        input [2:0] tim;
        case (tim)
            TIME_YEAR: f_time2RTCaddr = 8'h8c;
            TIME_MONTH: f_time2RTCaddr = 8'h88;
            TIME_DAY: f_time2RTCaddr = 8'h86;
            TIME_HOUR: f_time2RTCaddr = 8'h84;
            TIME_MIN: f_time2RTCaddr = 8'h82;
            TIME_SEC: f_time2RTCaddr = 8'h80;
            default: f_time2RTCaddr = 8'h00;
        endcase
    endfunction



    //edge detector
    wire w_busy_RTC_pedge, w_busy_RTC_nedge;
    edge_detector_n edp0(.clk(clk), .cp_in(busy_RTC),.reset_p(reset_p), .p_edge(w_busy_RTC_pedge), .n_edge(w_busy_RTC_nedge));
    wire w_busy_CLCD_pedge, w_busy_CLCD_nedge;
    edge_detector_n edp1(.clk(clk), .cp_in(busy_CLCD),.reset_p(reset_p), .p_edge(w_busy_CLCD_pedge), .n_edge(w_busy_CLCD_nedge));
    wire w_valid_Keypad_pedge;
    edge_detector_n edp2(.clk(clk), .cp_in(valid_Keypad),.reset_p(reset_p), .p_edge(w_valid_Keypad_pedge), .n_edge());

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
                    if(r_change_time) r_next_state = S_CHANGE_TIME;
                    else r_next_state = S_READ_YEAR;
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
                    if(r_end_read_second) r_next_state = S_WRITE_TIME;
                    else r_next_state = S_READ_SECOND;
                end
                S_WRITE_TIME: begin
                    if(r_end_write == 14'h3fff) r_next_state = S_CHANGE_LINE;
                    else r_next_state = S_WRITE_TIME;
                end
                S_CHANGE_LINE: begin
                    if(r_end_change_line) r_next_state = S_WRITE_SETTING;
                    else r_next_state = S_CHANGE_LINE;
                end
                S_WRITE_SETTING: begin
                    if(r_end_write == 14'h3fff) r_next_state = S_RETURN_HOME;
                    else r_next_state = S_WRITE_SETTING;
                end
                S_RETURN_HOME: begin
                    if(r_end_return) r_next_state = S_IDLE;
                    else r_next_state = S_RETURN_HOME;
                end
                S_CHANGE_TIME: begin
                    if(r_end_change_time) r_next_state = S_IDLE;
                    else r_next_state = S_CHANGE_TIME;
                end
            endcase
        end
    end

    //control DS1302
    always @(posedge clk ) begin
        if (reset_p) begin
            addr_RTC <= 0;
            data_RTC <= 0;
            r_end_read_year <= 0;
            r_end_read_month <= 0;
            r_end_read_day <= 0;
            r_end_read_hour <= 0;
            r_end_read_minute <= 0;
            r_end_read_second <= 0;
            r_end_change_time <= 0;
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
                    r_end_change_time <= 0;
                end 
                S_IDLE: begin
                    r_end_read_year <= 0;
                    r_end_read_month <= 0;
                    r_end_read_day <= 0;
                    r_end_read_hour <= 0;
                    r_end_read_minute <= 0;
                    r_end_read_second <= 0;
                    r_end_change_time <= 0;
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
                S_CHANGE_TIME: begin
                    if (!r_flag_RTC && !r_end_change_time) begin
                        addr_RTC <= f_time2RTCaddr(r_setting);
                        data_RTC <= {r_data_keypad[1], r_data_keypad[0]};
                        valid_RTC <= 1;
                        r_flag_RTC <= 1;
                    end else if(w_busy_RTC_pedge)begin
                        valid_RTC <= 0;
                    end
                    else if(w_busy_RTC_nedge)begin
                        r_end_change_time <= 1;
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
            r_end_change_line <= 0;
            r_end_return <= 0;
        end else begin
            case (r_state)
                S_INITIAL: begin
                    valid_CLCD <= 0;
                    r_flag_CLCD <= 0;
                    r_end_write <= 14'h0;
                    r_end_change_line <= 0;
                    r_end_return <= 0;
                end 
                S_IDLE: begin
                    valid_CLCD <= 0;
                    r_flag_CLCD <= 0;
                    r_end_write <= 14'h0;
                    r_end_change_line <= 0;
                    r_end_return <= 0;
                end 
                S_WRITE_TIME: begin
                    case (r_end_write)
                        14'b00_0000_0000_0000: begin
                            if(!r_flag_CLCD && !r_end_write[0])begin
                                data_CLCD <= f_num2ascii(r_date[0]);
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
                                data_CLCD <= f_num2ascii(r_date[1]);
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
                                data_CLCD <= f_num2ascii(r_date[2]);
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
                                data_CLCD <= f_num2ascii(r_date[3]);
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
                                data_CLCD <= f_num2ascii(r_date[4]);
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
                                data_CLCD <= f_num2ascii(r_date[5]);
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
                                data_CLCD <= f_num2ascii(r_date[6]);
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
                                data_CLCD <= f_num2ascii(r_date[7]);
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
                                data_CLCD <= f_num2ascii(r_date[8]);
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
                                data_CLCD <= f_num2ascii(r_date[9]);
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
                                data_CLCD <= f_num2ascii(r_date[10]);
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
                                data_CLCD <= f_num2ascii(r_date[11]);
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
                                data_CLCD <= f_num2ascii(r_date[12]);
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
                                data_CLCD <= f_num2ascii(r_date[13]);
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
                S_CHANGE_LINE: begin
                    if(!r_flag_CLCD && !r_end_change_line) begin
                        data_CLCD <= 8'b1100_0000;
                        RS_CLCD <= 0;
                        RW_CLCD <= 0;
                        valid_CLCD <= 1;
                        r_flag_CLCD <= 1;
                        r_end_write <= 14'h0;
                    end
                    else if (w_busy_CLCD_pedge) begin
                        valid_CLCD <= 0;
                    end
                    else if(w_busy_CLCD_nedge) begin
                        r_flag_CLCD <= 0;
                        r_end_change_line <= 1;
                    end
                end
                S_WRITE_SETTING: begin
                    case (r_end_write)
                        14'b00_0000_0000_0000: begin
                            if(!r_flag_CLCD && !r_end_write[0])begin
                                data_CLCD <= f_time2ascii(r_setting, 1);
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
                                data_CLCD <= f_time2ascii(r_setting, 2);
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
                                data_CLCD <= f_time2ascii(r_setting, 3);
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
                                data_CLCD <= f_time2ascii(r_setting, 4);
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
                                data_CLCD <= f_time2ascii(r_setting, 5);
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
                                data_CLCD <= f_alphabet2ascii(ASCII_EMPTY);
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
                                data_CLCD <= f_alphabet2ascii(ASCII_EMPTY);
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
                                data_CLCD <= f_alphabet2ascii(ASCII_EMPTY);
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
                                data_CLCD <= f_alphabet2ascii(ASCII_EMPTY);
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
                                data_CLCD <= f_alphabet2ascii(ASCII_EMPTY);
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
                                data_CLCD <= f_alphabet2ascii(ASCII_EMPTY);
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
                                data_CLCD <= f_alphabet2ascii(ASCII_EMPTY);
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
                                data_CLCD <= f_num2ascii(r_data_keypad[1]);
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
                                data_CLCD <= f_num2ascii(r_data_keypad[0]);
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

    //control Keypad
    always @(posedge clk) begin
        if (reset_p) begin
            r_data_keypad[0] <= 0;
            r_data_keypad[1] <= 0;
            r_setting <= 0;
            r_change_time <= 0;
        end else begin
            if (r_state == S_CHANGE_TIME) begin
                r_change_time <= 0;
            end
            if(w_valid_Keypad_pedge) begin
                case (data_Keypad)
                    4'h0: begin
                        r_data_keypad[0] <= 4'h7;
                        r_data_keypad[1] <= r_data_keypad[0];
                    end 
                    4'h1: begin
                        r_data_keypad[0] <= 4'h8;
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'h2: begin
                        r_data_keypad[0] <= 4'h9;
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'h3: begin
                        if(r_setting>=6) r_setting <= 0;
                        else r_setting <= r_setting + 1;
                    end
                    4'h4: begin
                        r_data_keypad[0] <= 4'h4;
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'h5: begin
                        r_data_keypad[0] <= 4'h5;
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'h6: begin
                        r_data_keypad[0] <= 4'h6;
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'h7: begin
                        if(r_setting) r_change_time <= 1;
                        //r_setting <= 0;
                    end
                    4'h8: begin
                        r_data_keypad[0] <= 4'h1;
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'h9: begin
                        r_data_keypad[0] <= 4'h2;
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'ha: begin
                        r_data_keypad[0] <= 4'h3;
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'hb: begin
                        r_data_keypad[0] <= 4'hc;   //c
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'hc: begin
                        r_data_keypad[0] <= 4'hf;   //f
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'hd: begin
                        r_data_keypad[0] <= 4'h0;   //real 0
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'he: begin
                        r_data_keypad[0] <= 4'he;   //e
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                    4'hf: begin
                        r_data_keypad[0] <= 4'hd;   //d
                        r_data_keypad[1] <= r_data_keypad[0];
                    end
                endcase
            end
        end
    end

endmodule
