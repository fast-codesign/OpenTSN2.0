// Copyright (C) 1953-2020 NUDT
// Verilog module name - regroup_lookup_table
// Version: regroup_lookup_table_V1.0
// Created:
//         by - peng jintao 
//         at - 08.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         lookup regroup table.
//             - lookup table and get dmac and outport of packet; 
//             - replace tsntag of first frag with dmac;
//             - discard the first 16B of middle frag or last frag;
//             - add 16B metadata;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module regroup_lookup_table
(
       i_clk,
       i_rst_n,
       
	   iv_pkt_data,
	   i_pkt_data_wr,
       o_pkt_data_ready,
	   
	   iv_regroup_ram_rdata,
	   o_regroup_ram_rd,
	   ov_regroup_ram_raddr,
	   
	   ov_pkt_data,
	   o_pkt_data_wr,

	   iv_fifo_usedw
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input       [133:0]    iv_pkt_data;
input           	   i_pkt_data_wr;
output  	           o_pkt_data_ready;
//read ram 
input       [70:0]	   iv_regroup_ram_rdata;
output       	       o_regroup_ram_rd;
output      [7:0]	   ov_regroup_ram_raddr;
//packet output
output      [133:0]	   ov_pkt_data;
output                 o_pkt_data_wr;

input       [6:0]      iv_fifo_usedw;

//fifo-frm
wire                   w_fifo_rd_frm2fifo;
wire    [133:0]        wv_fifo_rdata_fifo2frm;
wire                   w_fifo_empty_fifo2frm;
//fifo usedw
wire    [6:0]          wv_fifo_usedw;
//lrt-frm
wire    [56:0]	       wv_dmac_outport_lrt2frm;
wire                   w_dmac_outport_wr_lrt2frm;
wire                   w_lookup_table_match_flag_lrt2frm;

assign o_pkt_data_ready = (wv_fifo_usedw <= 7'd20) ? 1:0;
lookup_regroup_table lookup_regroup_table_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

//.iv_pkt_data(iv_pkt_data),
//.i_pkt_data_wr(i_pkt_data_wr),
.i_fifo_empty(w_fifo_empty_fifo2frm),
.iv_pkt_data(wv_fifo_rdata_fifo2frm),

.iv_regroup_ram_rdata(iv_regroup_ram_rdata),
.o_regroup_ram_rd(o_regroup_ram_rd),
.ov_regroup_ram_raddr(ov_regroup_ram_raddr),

.ov_dmac_outport(wv_dmac_outport_lrt2frm),
.o_dmac_outport_wr(w_dmac_outport_wr_lrt2frm),
.o_lookup_table_match_flag(w_lookup_table_match_flag_lrt2frm)
);

fifo_134_128 rlt_packet_buffer
(
.data(iv_pkt_data),  //  fifo_input.datain
.wrreq(i_pkt_data_wr), //            .wrreq
.rdreq(w_fifo_rd_frm2fifo), //            .rdreq
.clock(i_clk), //            .clk
.q(wv_fifo_rdata_fifo2frm),     // fifo_output.dataout
.usedw(wv_fifo_usedw), //            .usedw
.full(),  //            .full
.empty(w_fifo_empty_fifo2frm)  //            .empty
);

frame_regroup_modify frame_regroup_modify_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.i_fifo_empty(w_fifo_empty_fifo2frm),
.o_fifo_rd(w_fifo_rd_frm2fifo),
.iv_fifo_data(wv_fifo_rdata_fifo2frm),

.iv_dmac_outport(wv_dmac_outport_lrt2frm),
.i_lookup_table_match_flag(w_lookup_table_match_flag_lrt2frm),
.i_dmac_outport_wr(w_dmac_outport_wr_lrt2frm),

.iv_fifo_usedw(iv_fifo_usedw),
.ov_pkt_data(ov_pkt_data),
.o_pkt_data_wr(o_pkt_data_wr)
);
endmodule