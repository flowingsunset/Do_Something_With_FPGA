`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/11 19:41:36
// Design Name: 
// Module Name: system_control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module system_control(
    input clk,
    input reset_p,

    input empty,

    output addr_RTC,
    output valid_RTc,
    input busy_RTC,
    input receive_RTC,

    output addr_I2C,
    output data_I2C,
    output RW,
    input busy_I2C,
    input recieve_I2C
    );

    localparam S_IDLE = ;
    localparam S_READ_YEAR = ;
    localparam S_READ_MONTH = ;
    localparam S_READ_DAY = ;
    localparam S_READ_HOUR = ;
    localparam S_READ_MINUTE = ;
    localparam S_READ_SECOND = ;
    localparam S_WRITE_ALL = ;
    localparam S_RETURN_HOME = ;


    always @(negedge clk) begin
        if (reset_p) begin
            r_state <= 0;
        end else begin
            r_state <= r_next_state;
        end
    end

    always @(posedge clk) begin
        if(reset_p) begin
            r_next_state <= 0;
        end
        else begin
            case (param)
                S_IDLE: begin
                    if (empty) begin
                        r_next_state <= S_READ_YEAR;
                    end else begin
                        r_next_state <= S_IDLE;
                    end
                end
                S_READ_YEAR: begin
                    
                end

                default: 
            endcase
        end
    end


endmodule
