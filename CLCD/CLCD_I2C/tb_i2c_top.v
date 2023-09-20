`timescale 1ns/1ns
`include "i2c_top.v"

module tb_i2c_top ();
    
    reg clk, reset_p;
    tri1 o_sda;
    wire o_scl, o_empty;

    i2c_top dut(clk,reset_p,o_sda,o_scl, o_empty);

    initial begin
        clk = 0;
        forever #5clk =~ clk;
    end

    initial begin
        $dumpfile("tb_i2c_top.vcd");
		$dumpvars(-1, dut);
        reset_p = 1;
        #50 reset_p = 0;
        wait(o_empty);
        #100 $finish;
    end
endmodule