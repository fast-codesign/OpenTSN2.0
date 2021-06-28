// Copyright (C) 1953-2020 NUDT
// Verilog module name - host_rx_timer 
// Version: HRT_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         timer
//             - reset timer to 0 every 4ms or when signal of timer_rst is high.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module host_rx_timer
(
        i_clk,
        i_rst_n,
        i_timer_rst,
        ov_timer     
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;
input                  i_timer_rst;
// output
output reg [18:0]      ov_timer;
// internal reg&wire for inport fifo
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n) begin
        ov_timer    <= 19'b0;
    end
    else begin
        if(i_timer_rst == 1'b1)begin
            ov_timer <= 19'b0;
        end
        else begin
            if(ov_timer == 19'd499999) begin //4ms
                ov_timer <= 19'b0;
            end
            else begin
                ov_timer <= ov_timer + 1'b1;
            end            
        end
    end
end

endmodule