// Copyright (C) 1953-2020 NUDT
// Verilog module name - host_queue_management 
// Version: HQM_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         cache bufid of not ts packet with fifo.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module host_queue_management
(
       i_clk,
       i_rst_n,
       
       iv_nts_descriptor_wdata,
       i_nts_descriptor_wr,
       
       ov_nts_descriptor_rdata,
       i_nts_descriptor_rd,
       
       o_fifo_full,
       o_fifo_empty,
       ov_debug_nts_cnt
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// write bufid of nts pkt to queue
input      [12:0]      iv_nts_descriptor_wdata;
input                  i_nts_descriptor_wr;
output                 o_fifo_full;
output                 o_fifo_empty;
output     [12:0]      ov_nts_descriptor_rdata;
input                  i_nts_descriptor_rd;

SFIFO_13_256 SFIFO_13_256_inst(
    .aclr(!i_rst_n),                   //Reset the all signal
    .data(iv_nts_descriptor_wdata),    //The Inport of data 
    .rdreq(i_nts_descriptor_rd),       //active-high
    .clk(i_clk),                       //ASYNC WriteClk(), SYNC use wrclk
    .wrreq(i_nts_descriptor_wr),       //active-high
    .q(ov_nts_descriptor_rdata),       //The output of data
    .wrfull(o_fifo_full),              //Write domain full 
    .wralfull(),                       //Write domain almost-full
    .wrempty(),                        //Write domain empty
    .wralempty(),                      //Write domain almost-full  
    .rdfull(),                         //Read domain full
    .rdalfull(),                       //Read domain almost-full   
    .rdempty(o_fifo_empty),            //Read domain empty
    .rdalempty(),                      //Read domain almost-empty
    .wrusedw(),                        //Write-usedword
    .rdusedw()                         //Read-usedword
);
output reg [15:0] ov_debug_nts_cnt; 
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_debug_nts_cnt <= 16'b0;
    end
    else begin
        if(i_nts_descriptor_wr)begin
            ov_debug_nts_cnt <= ov_debug_nts_cnt + 1'b1;
        end
        else begin
            ov_debug_nts_cnt <= ov_debug_nts_cnt;
        end
    end
end	
endmodule