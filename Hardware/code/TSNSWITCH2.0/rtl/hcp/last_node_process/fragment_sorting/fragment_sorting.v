// Copyright (C) 1953-2020 NUDT
// Verilog module name - FSM
// Version: FSM_V1.0
// Created:
//         by - peng jintao
//         at - 08.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         read all fragement of a packet.
//             - read flowid to lookup table; 
//             - write packet to ram;
//             - write last_frag_flag & bufid to ram;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module fragment_sorting
(
       i_clk,
       i_rst_n,
       
       ov_queue_id_free,
	   o_queue_id_free_wr,
       iv_queue_empty,
       
       iv_queue_ram_rdata,
       o_queue_ram_rd,
       ov_queue_ram_raddr,
       
	   ov_bufid,
	   o_bufid_wr,
	   i_bufid_ack,
	   
	   iv_pkt_ram_rdata,
	   o_pkt_ram_rd,
	   ov_pkt_ram_raddr,
	   
	   ov_pkt_data,
	   o_pkt_data_wr,
	   i_pkt_data_ready
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// free queue id
output     [4:0]	   ov_queue_id_free;
output  	           o_queue_id_free_wr;

input      [31:0]      iv_queue_empty;
// read bufid & last_frag_flag
input      [9:0]      iv_queue_ram_rdata;
output          	  o_queue_ram_rd;
output     [8:0]      ov_queue_ram_raddr;
//free bufid
output     [8:0]	   ov_bufid;
output  	     	   o_bufid_wr;
input            	   i_bufid_ack;
//read pkt
input      [133:0]	   iv_pkt_ram_rdata;
output      	       o_pkt_ram_rd;
output     [11:0]	   ov_pkt_ram_raddr;
//packet output
output     [133:0]	   ov_pkt_data;
output                 o_pkt_data_wr;
input                  i_pkt_data_ready;

wire     [8:0]	   wv_bufid;
wire  	     	   w_bufid_wr;
wire           	   w_pkt_last_cycle_valid;
queue_read queue_read_inst(
       .i_clk(i_clk),
       .i_rst_n(i_rst_n),
       
       .ov_queue_id_free(ov_queue_id_free),
	   .o_queue_id_free_wr(o_queue_id_free_wr),
       .iv_queue_empty(iv_queue_empty),
       
       .iv_queue_ram_rdata(iv_queue_ram_rdata),
       .o_queue_ram_rd(o_queue_ram_rd),
       .ov_queue_ram_raddr(ov_queue_ram_raddr),
	   
	   .ov_bufid(wv_bufid),
	   .o_bufid_wr(w_bufid_wr),
       .i_pkt_last_cycle_valid(w_pkt_last_cycle_valid)
);

regroup_frag_read regroup_frag_read_inst(
       .i_clk(i_clk),
       .i_rst_n(i_rst_n),
       
	   .iv_bufid(wv_bufid),
	   .i_bufid_wr(w_bufid_wr),
       .o_pkt_last_cycle_valid(w_pkt_last_cycle_valid),
       
	   .ov_bufid(ov_bufid),
	   .o_bufid_wr(o_bufid_wr),
	   .i_bufid_ack(i_bufid_ack),
	   
	   .iv_pkt_ram_rdata(iv_pkt_ram_rdata),
	   .o_pkt_ram_rd(o_pkt_ram_rd),
	   .ov_pkt_ram_raddr(ov_pkt_ram_raddr),
	   
	   .ov_pkt_data(ov_pkt_data),
	   .o_pkt_data_wr(o_pkt_data_wr),
	   .i_pkt_data_ready(i_pkt_data_ready)
);
endmodule