`timescale 1ns / 1ps

module from_keypad_to_i2c_master(
    input clk,
    input reset_p,
    //from keypad
    input [3:0] i_data,
    input i_btn_valid,
    //to i2c master
    input i_busy,
    output [6:0] o_addr,
    output [7:0] o_data,
    output o_RW,
    output reg o_valid,
    //from i2c master
    input [7:0] i_receive,
    //to fnd(for debug)
    output reg [7:0] o_char_addr
    );

    //F~0 charactor in CLCD
    parameter [8*16-1:0] P_HEX = {8'h46,8'h45,8'h44,8'h43,8'h42,8'h41, 8'h39,8'h38,8'h37,8'h36,8'h35,8'h34,8'h33,8'h32,8'h31,8'h30};
    
    //stan by for button input
    localparam S_IDLE = 0;

    //write 1 charactor
    //data is written at negative edge of EN
    //write high 4 bit first of 8 bit of charactor
    localparam S_NUMBER_HIGH_EN_HIGH = 1;
    localparam S_NUMBER_HIGH_EN_LOW = 2;
    localparam S_NUMBER_LOW_EN_HIGH = 3;
    localparam S_NUMBER_LOW_EN_LOW = 4;

    //read charactor address to control row
    //it can be easy count when you write
    //but for use I2C read
    //CLCD hold address data when RW and EN both high
    //it is 4-bit mode, check twice
    //i can't check right or left becasue msb of read address is used for busy
    //-> always 3rd bit is 0 even this is 4bit read
    //00 01 02 03 04 05 06 07 00 01 02 03 04 05 06 07 10 ...
    //40 41 42 43 44 45 46 47 40 41 42 43 44 45 46 47 50 ...
    //so i only can check clear which line am i write...
    localparam S_EN_LOW_READ_ON_1 = 5;
    localparam S_EN_HIGH_READ_ON = 6;
    localparam S_READ_CHAR_ADDR = 7;    //I2C read
    localparam S_OUTPUT_ADDR = 8;       //store address
    localparam S_EN_LOW_READ_ON_2 = 9;
    localparam S_EN_LOW_READ_OFF = 10;

    //if address is 8'h10 of 8'h50, change line 
    localparam S_CHANGE_LINE_1 = 11;
    localparam S_CHANGE_LINE_2 = 12;
    localparam S_CHANGE_LINE_3 = 13;
    localparam S_CHANGE_LINE_4 = 14;
    
    //this module for CLCD 16x2
    assign o_addr = 7'h27;

    //CLCD 4-bit mode : {d7 d6 d5 d4 backlight EN RW RS}
    //backlight should always 1
    //data is written at negative edge of EN
    //set RW 1 for Read, 0 for Write,
    //set RS 1 for charactor, 0 for control
    //-> use 8 bit {data, ctrl}
    reg [3:0] r_data;
    reg [3:0] r_ctrl;

    reg [5:0] r_state, r_next_state;    //FSM
    reg r_state_on; //for load I2C data to master once
    reg r_RW;   //I2C RW
    reg r_char_addr;    //flag for CLCD charactor address 4 bit high or low
    reg r_line;     //flag for change line
    
    assign o_data = {r_data, r_ctrl};
    assign o_RW = r_RW;

    //generate mili second for delay
    wire w_clk_usec, w_clk_msec;
    clock_usec clk_usec(.clk(clk), .reset_p(reset_p),.clk_usec(w_clk_usec));
    clock_div_1000 clk_msec(.clk(clk), .clk_source(w_clk_usec), .reset_p(reset_p),.clk_div_1000(w_clk_msec));

    //check edge condition of busy signal from I2C master
     wire w_busy_pedge, w_busy_nedge;
     edge_detector_n edn0(.clk(clk), .cp_in(i_busy),.reset_p(reset_p), .p_edge(w_busy_pedge), .n_edge(w_busy_nedge));

    //give enough delay for safety(maybe don't need this)
    reg r_count_msec_e;
    reg [6:0] r_count_msec;
    always@(negedge clk or posedge reset_p) begin
        if(reset_p) r_count_msec <= 0;
        else begin
            if(w_clk_msec && r_count_msec_e) r_count_msec <= r_count_msec + 1;
            else if(!r_count_msec_e) r_count_msec <= 0;
        end
    end

    //FSM
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) r_state <= 0;
        else r_state <= r_next_state;
    end

    //FSM
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            r_data <= 0;
            r_ctrl <= 0;
            o_valid <= 0;
            r_state_on <= 0;
            r_next_state <= 0;
            r_count_msec_e <= 0;
            r_RW <= 0;
            o_char_addr <= 0;
            r_char_addr <= 0;
            r_line <= 0;
        end
        else begin
            case(r_state)
                S_IDLE: begin
                    if(i_btn_valid) //when button input
                        r_next_state <= S_NUMBER_HIGH_EN_HIGH;
                end
                //////////////////////////////WRITE CHAR////////////////////////////////////
                S_NUMBER_HIGH_EN_HIGH : begin 
                    if(!r_state_on) begin
                        r_data <= P_HEX[8*i_data+4+:4];
                        r_ctrl <= 4'b1101;
                        o_valid <= 1;
                        r_state_on <= 1;
                        r_RW <= 0;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= S_NUMBER_HIGH_EN_LOW;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                S_NUMBER_HIGH_EN_LOW : begin
                    if(!r_state_on) begin
                        r_data <= P_HEX[8*i_data+4+:4];
                        r_ctrl <= 4'b1001;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= S_NUMBER_LOW_EN_HIGH;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                S_NUMBER_LOW_EN_HIGH : begin
                    if(!r_state_on) begin
                        r_data <= P_HEX[8*i_data+:4];
                        r_ctrl <= 4'b1101;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= S_NUMBER_LOW_EN_LOW;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                S_NUMBER_LOW_EN_LOW : begin
                    if(!r_state_on) begin
                        r_data <= P_HEX[8*i_data+:4];
                        r_ctrl <= 4'b1001;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= S_EN_LOW_READ_ON_1;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                //////////////////////////////////////READ_ADDRESS//////////////////////////////////////
                S_EN_LOW_READ_ON_1 : begin  
                    if(!r_state_on) begin
                        r_data <= 1111;
                        r_ctrl <= 4'b1010;
                        r_RW <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) begin
                        r_next_state <= S_EN_HIGH_READ_ON;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                S_EN_HIGH_READ_ON : begin  
                    if(!r_state_on) begin
                        r_data <= 1111;
                        r_ctrl <= 4'b1110;
                        r_RW <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) begin
                        r_next_state <= S_READ_CHAR_ADDR;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                S_READ_CHAR_ADDR : begin   
                    if(!r_state_on) begin
                        r_data <= 0;
                        r_ctrl <= 0;
                        r_RW <= 1;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) begin
                        r_next_state <= S_OUTPUT_ADDR;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                S_OUTPUT_ADDR: begin
                    if(r_char_addr == 0) begin  //READ HIGH 4 BIT
                        o_char_addr [7:4] <= i_receive[7:4];
                        r_char_addr <= 1;
                    end
                    else begin //READ LOW 4 BIT
                        o_char_addr[3:0] <= i_receive[7:4];
                        r_char_addr <= 0;
                    end
                    r_next_state <= S_EN_LOW_READ_ON_2;
                end
                S_EN_LOW_READ_ON_2 : begin  
                    if(!r_state_on) begin
                        r_data <= 1111;
                        r_ctrl <= 4'b1010;
                        r_RW <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) begin
                        r_next_state <= S_EN_LOW_READ_OFF;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                S_EN_LOW_READ_OFF : begin   
                    if(!r_state_on) begin
                        r_data <= 1111;
                        r_ctrl <= 4'b1000;
                        r_RW <= 0;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) begin
                        if(r_char_addr == 1) r_next_state <= S_EN_LOW_READ_ON_1;    //READ LOW 4 BIT
                        else if((r_char_addr == 0) && (o_char_addr == 8'h10)) begin //CHANGE LINE FROM 1 TO 2
                            r_next_state <= S_CHANGE_LINE_1;
                            r_line <= 0;
                        end
                        else if((r_char_addr == 0) &&  (o_char_addr == 8'h50)) begin //CHANGE LINE FROM 2 TO 1
                            r_next_state <= S_CHANGE_LINE_1;
                            r_line <= 1;
                        end
                        else r_next_state <= S_IDLE;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                /////////////////////////////CHANGE LINE/////////////////////////////////////////
                //change line from 1 to 2 : write 1100_0000 (change DDRAM address to 7'h40)
                //change line from 2 to 1 : write 0000_0010 (return home)
                S_CHANGE_LINE_1 : begin
                    if(!r_state_on) begin
                        if(r_line == 0) r_data <= 4'b1100;
                        if(r_line == 1) r_data <= 4'b0000;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                        r_RW <= 0;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= S_CHANGE_LINE_2;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                S_CHANGE_LINE_2 : begin
                    if(!r_state_on) begin
                        if(r_line == 0) r_data <= 4'b1100;
                        if(r_line == 1) r_data <= 4'b0000;
                        r_ctrl <= 4'b1000;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= S_CHANGE_LINE_3;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                S_CHANGE_LINE_3 : begin
                    if(!r_state_on) begin
                        if(r_line == 0) r_data <= 4'b0000;
                        if(r_line == 1) r_data <= 4'b0010;
                        r_ctrl <= 4'b1100;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= S_CHANGE_LINE_4;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
                S_CHANGE_LINE_4 : begin
                    if(!r_state_on) begin
                        if(r_line == 0) r_data <= 4'b0000;
                        if(r_line == 1) r_data <= 4'b0010;
                        r_ctrl <= 4'b1001;
                        o_valid <= 1;
                        r_state_on <= 1;
                    end
                    else if(w_busy_pedge)
                        o_valid <= 0;
                    else if(w_busy_nedge) 
                        r_count_msec_e <= 1;
                    else if(r_count_msec) begin
                        r_next_state <= S_EN_LOW_READ_ON_1;
                        r_count_msec_e <= 0;
                        r_state_on <= 0;
                    end
                end
        endcase
        end
    end

endmodule
