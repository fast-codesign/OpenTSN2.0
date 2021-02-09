// Copyright (C) 1953-2020 NUDT
// Verilog module name - FMM
// Version: FMM_V1.0
// Created:
//         by - fenglin
//         at - 08.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         management of flow map-table.
//             - lookup flow map-table;key of lookup table is flowid and result is queue_id and queue_usedw; 
//             - update content of table;
//             - free queue id;
//             - judge whether queues cache all fragment of a packet;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module flow_table_management
(
       i_clk,
       i_rst_n,
	   
	   iv_flowid,
       iv_frag_id,
	   i_last_frag_flag,
	   i_flowid_wr,

	   ov_queue_id,
	   ov_queue_usedw,
	   o_queue_id_wr,
       o_all_queue_used,    

	   ov_fmt_ram_wdata,
	   o_fmt_ram_wr,
	   ov_fmt_ram_waddr,       
	   iv_fmt_ram_rdata,
	   o_fmt_ram_rd,
	   ov_fmt_ram_raddr,
       
       iv_queue_id_free,
	   i_queue_id_free_wr,
	   ov_queue_empty,
       
       o_lnp_no_last_frag_flag_pulse,      
       o_lnp_no_notlast_frag_flag_pulse         
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
//information of packet used to lookup table
input      [13:0]	   iv_flowid;
input      [3:0]       iv_frag_id;
input                  i_last_frag_flag;
input                  i_flowid_wr;
//result of lookup table
output     [4:0]	   ov_queue_id;
output     [3:0]       ov_queue_usedw;
output                 o_queue_id_wr;
output                 o_all_queue_used;
//ftl-ftu
wire       [18:0]	   wv_update_ram_wdata_ftl2ftu;
wire        	       w_update_ram_wr_ftl2ftu;
wire       [4:0]	   wv_update_ram_waddr_ftl2ftu;
//write/read valid & flowid & queue_usedw to RAM 
output     [18:0]	   ov_fmt_ram_wdata;
output      	       o_fmt_ram_wr;
output     [4:0]	   ov_fmt_ram_waddr;
input      [18:0]	   iv_fmt_ram_rdata;
output      	       o_fmt_ram_rd;
output     [4:0]	   ov_fmt_ram_raddr;
//free queue id
input      [4:0]	   iv_queue_id_free;
input                  i_queue_id_free_wr;
output     [31:0]      ov_queue_empty; 

output                 o_lnp_no_last_frag_flag_pulse;
output                 o_lnp_no_notlast_frag_flag_pulse;

wire w_last_frag_flag;
flow_table_lookup flow_table_lookup_inst(
       .i_clk(i_clk),
       .i_rst_n(i_rst_n),
	   
	   .iv_flowid(iv_flowid),
       .iv_frag_id(iv_frag_id),
	   .i_last_frag_flag(i_last_frag_flag),
	   .i_flowid_wr(i_flowid_wr),
       
	   .ov_queue_id(ov_queue_id),
	   .ov_queue_usedw(ov_queue_usedw),
	   .o_queue_id_wr(o_queue_id_wr),
       .o_all_queue_used(o_all_queue_used),
       
       .o_last_frag_flag(w_last_frag_flag),       
       
	   .ov_update_ram_wdata(wv_update_ram_wdata_ftl2ftu),
	   .o_update_ram_wr(w_update_ram_wr_ftl2ftu),
	   .ov_update_ram_waddr(wv_update_ram_waddr_ftl2ftu),       
	   .iv_fmt_ram_rdata(iv_fmt_ram_rdata),
	   .o_fmt_ram_rd(o_fmt_ram_rd),
	   .ov_fmt_ram_raddr(ov_fmt_ram_raddr),
       
	   .iv_queue_empty(ov_queue_empty),
       
       .o_lnp_no_last_frag_flag_pulse(o_lnp_no_last_frag_flag_pulse),      
       .o_lnp_no_notlast_frag_flag_pulse(o_lnp_no_notlast_frag_flag_pulse) 
);
flow_table_update flow_table_update_inst(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),   
        
        .iv_queue_id(ov_queue_id),
        .i_last_frag_flag(w_last_frag_flag),        
        .i_queue_wr(o_queue_id_wr),
        
        .iv_update_ram_wdata(wv_update_ram_wdata_ftl2ftu),
	    .i_update_ram_wr(w_update_ram_wr_ftl2ftu),
	    .iv_update_ram_waddr(wv_update_ram_waddr_ftl2ftu),
        
        .ov_fmt_ram_wdata(ov_fmt_ram_wdata),
	    .o_fmt_ram_wr(o_fmt_ram_wr),
	    .ov_fmt_ram_waddr(ov_fmt_ram_waddr),
        
	    .i_fmt_ram_rd(o_fmt_ram_rd),
	    .iv_fmt_ram_raddr(ov_fmt_ram_raddr),
        
	    .iv_queue_id_free(iv_queue_id_free),
	    .i_queue_id_free_wr(i_queue_id_free_wr),
	    .ov_queue_empty(ov_queue_empty)
);
endmodule 