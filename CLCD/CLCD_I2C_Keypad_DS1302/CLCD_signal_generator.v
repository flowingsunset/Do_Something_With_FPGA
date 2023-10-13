module CLCD_signal_generator(
    input clk,
    input reset_p,
    //input output with i2c_master
    input i_busy,
    output reg o_valid,
    output reg o_RW,
    output reg [7:0] o_data,
    output reg [6:0] o_addr,
    //input output with system_control
    input [7:0] i_data,
    input i_RS,
    input i_RW,
    input i_valid,
    output o_busy
    );

    localparam S_IDLE = 0;
    localparam S_WRITE_1 = 1;
    localparam S_WRITE_2 = 2;
    localparam S_WRITE_3 = 3;
    localparam S_WRITE_4 = 4;


    reg [3:0] r_state, r_next_state;
    reg [7:0] r_data;
    reg r_RW, r_RS, r_state_on;

    //check edge condition of busy signal from I2C master
     wire w_busy_pedge, w_busy_nedge;
     edge_detector_n edn0(.clk(clk), .cp_in(i_busy),.reset_p(reset_p),
                          .p_edge(w_busy_pedge), .n_edge(w_busy_nedge));

    assign o_busy = (r_state != S_IDLE);

    always @(negedge clk ) begin
        if (reset_p) begin
            r_state <= S_IDLE;
        end else begin
            r_state <= r_next_state;
        end
    end

    always @(posedge clk) begin
        if(reset_p)begin
            r_next_state <= S_IDLE;
            o_data <= 0;
            o_RW <= 0;
            r_RS <= 0;
            o_addr <= 7'h27;
            r_state_on <= 0;
            o_valid <= 0;
        end
        else begin
            case (r_state)
                S_IDLE: begin
                    if (i_valid) begin
                        r_next_state <= S_WRITE_1;
                        r_data <= i_data;
                        r_RW <= i_RW;
                        r_RS <= r_RS;
                    end else begin
                        r_next_state <= S_IDLE;
                    end
                end 
                S_WRITE_1: begin
                    if (!r_state_on) begin
                        o_data <= {r_data[7:4], 1'b1, 1'b1, r_RW, r_RS};
                        r_state_on <= 1;
                        o_valid <= 1;
                    end
                    else if(w_busy_pedge) begin
                        o_valid <= 0;
                    end
                    else if(w_busy_nedge) begin
                        r_next_state <= S_WRITE_2;
                        r_state_on <= 0;
                    end
                end
                S_WRITE_2: begin
                    if (!r_state_on) begin
                        o_data <= {r_data[7:4], 1'b1, 1'b0, r_RW, r_RS};
                        r_state_on <= 1;
                        o_valid <= 1;
                    end
                    else if(w_busy_pedge) begin
                        o_valid <= 0;
                    end
                    else if(w_busy_nedge) begin
                        r_next_state <= S_WRITE_3;
                        r_state_on <= 0;
                    end
                end
                S_WRITE_3: begin
                    if (!r_state_on) begin
                        o_data <= {r_data[3:0], 1'b1, 1'b1, r_RW, r_RS};
                        r_state_on <= 1;
                        o_valid <= 1;
                    end
                    else if(w_busy_pedge) begin
                        o_valid <= 0;
                    end
                    else if(w_busy_nedge) begin
                        r_next_state <= S_WRITE_4;
                        r_state_on <= 0;
                    end
                end
                S_WRITE_4: begin
                    if (!r_state_on) begin
                        o_data <= {r_data[3:0], 1'b1, 1'b0, r_RW, r_RS};
                        r_state_on <= 1;
                        o_valid <= 1;
                    end
                    else if(w_busy_pedge) begin
                        o_valid <= 0;
                    end
                    else if(w_busy_nedge) begin
                        r_next_state <= S_IDLE;
                        r_state_on <= 0;
                    end
                end
            endcase
        end
    end
endmodule
