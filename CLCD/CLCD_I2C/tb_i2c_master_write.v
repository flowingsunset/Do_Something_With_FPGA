`include "i2c_top.v"
`timescale 1ns / 1ps
module tb_i2c_master_write ();
    
    reg clk, reset_p, i_RW, i_valid;
    reg [6:0] i_addr;
    reg [7:0] i_data;

    wire o_scl, o_busy;
    tri o_sda;

    i2c_master_write dut(clk, reset_p, i_addr, i_data,i_RW, i_valid, o_sda, o_scl, o_busy);

    initial begin
        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        $dumpfile("tb_i2c_master_write.vcd");
		$dumpvars(-1, dut);
        reset_p = 1;
        i_RW = 0;
        i_valid = 0;
        i_addr = 0;
        i_data = 0;

        #10 reset_p = 0;

        i_addr = 7'h57;
        i_data = 8'h34;

        #3 i_valid = 1;
        wait(o_busy);
        @(posedge clk) i_valid = 0;

        i_addr = 7'h26;
        i_data = 8'h91;

        wait(!o_busy);
        i_valid = 1;

        wait(o_busy);
        i_valid = 0;

        wait(!o_busy);
        #100 $finish;
    end

    
endmodule