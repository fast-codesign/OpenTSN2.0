// Copyright (C) 1953-2020 NUDT
// Verilog module name - LNP
// Version: LNP_V1.0
// Created:
//         by - jintao peng
//         at - 08.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         last_node_process.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module last_node_process
(
       i_clk,
       i_rst_n,
       
       iv_pkt_data,
	   i_pkt_data_wr,
	   
	   iv_regroup_ram_wdata,
	   i_regroup_ram_wr,
	   iv_regroup_ram_addr,
       ov_regroup_ram_rdata,
       i_regroup_ram_rd,
	   
	   o_fifo_empty,
	   i_fifo_rd,
	   ov_fifo_rdata,     
       
       o_initial_finish,
       
       o_lnp_inpkt_pulse,
       o_lnp_outpkt_pulse,
       o_lnp_flow_table_overflow_pulse,

       o_lnp_no_last_frag_flag_pulse,      
       o_lnp_no_notlast_frag_flag_pulse,
       o_ibm_discard_pulse       
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input from PDM
input	   [133:0]	   iv_pkt_data;
input	         	   i_pkt_data_wr;
//ram write  
input      [70:0]	   iv_regroup_ram_wdata;
input       	       i_regroup_ram_wr;
input      [7:0]	   iv_regroup_ram_addr;
output     [70:0]      ov_regroup_ram_rdata;
input                  i_regroup_ram_rd;
//fifo read
output           	   o_fifo_empty;
input                  i_fifo_rd;
output     [133:0]     ov_fifo_rdata;

output                 o_initial_finish;

output reg             o_lnp_inpkt_pulse; 
output reg             o_lnp_outpkt_pulse; 
output                 o_lnp_flow_table_overflow_pulse; 

output                 o_lnp_no_last_frag_flag_pulse;
output                 o_lnp_no_notlast_frag_flag_pulse;

output                 o_ibm_discard_pulse;
//ibm-pcb
wire [8:0]	   wv_bufid_pcb2ibm;
wire       	   w_bufid_wr_pcb2ibm;
wire           w_bufid_ack_ibm2pcb;

wire [133:0]   wv_pkt_ram_wdata_ibm2pcb;
wire  	       w_pkt_ram_wr_ibm2pcb;
wire [11:0]	   wv_pkt_ram_waddr_ibm2pcb;
//ibm-ftm
wire [13:0]	   wv_flowid_ibm2ftm;
wire [3:0]     wv_frag_id_ibm2ftm;
wire           w_last_frag_flag_ibm2ftm;
wire           w_flowid_wr_ibm2ftm;

wire [4:0]	   wv_queue_id_ftm2ibm;
wire [3:0]     wv_queue_usedw_ftm2ibm;
wire     	   w_queue_id_wr_ftm2ibm;
//ibm-queue_ram
wire [9:0]	   wv_queue_ram_wdata_ibm2ram;
wire           w_queue_ram_wr_ibm2ram;
wire [8:0]     wv_queue_ram_waddr_ibm2ram; 
//ftm-ram
wire   [18:0]  wv_fmt_ram_wdata_ftm2ram;
wire    	   w_fmt_ram_wr_ftm2ram;
wire   [4:0]   wv_fmt_ram_waddr_ftm2ram;
wire   [18:0]  wv_fmt_ram_rdata_ram2ftm;
wire    	   w_fmt_ram_rd_ftm2ram;
wire   [4:0]   wv_fmt_ram_raddr_ftm2ram;
//ftm-fsm
wire   [4:0]   wv_queue_id_free_fsm2ftm;
wire           w_queue_id_free_wr_fsm2ftm;
wire   [31:0]  wv_queue_empty_ftm2fsm; 
//queue_ram - fsm
wire   [9:0]   wv_queue_ram_rdata_ram2fsm;
wire           w_queue_ram_rd_fsm2ram;
wire   [8:0]   wv_queue_ram_raddr_fsm2ram;
//fsm - pcb
wire   [8:0]   wv_bufid_fsm2pcb;
wire	       w_bufid_wr_fsm2pcb;
wire           w_bufid_ack_pcb2fsm;

wire   [133:0] wv_pkt_ram_rdata_pcb2fsm;
wire    	   w_pkt_ram_rd_fsm2pcb;
wire   [11:0]  wv_pkt_ram_raddr_fsm2pcb;
//fsm-rlt
wire   [133:0] wv_pkt_data_fsm2rlt;
wire           w_pkt_data_wr_fsm2rlt;
wire           w_pkt_data_ready_rlt2fsm;
//fsm - rlt
wire   [70:0]  wv_regroup_ram_rdata_ram2rlt;
wire   	       w_regroup_ram_rd_rlt2ram;
wire   [7:0]   wv_regroup_ram_addr_rlt2ram;
//rlt-fifo
wire   [133:0] wv_pkt_data_rlt2fifo;
wire           w_pkt_data_wr_rlt2fifo;
wire   [6:0]   wv_fifo_usedw_fifo2rlt;
//***************************************************
//            pkt count of lnp
//***************************************************      
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_lnp_inpkt_pulse <= 1'b0;
        o_lnp_outpkt_pulse <= 1'b0;
    end
    else begin
        if((i_pkt_data_wr == 1'b1) && (iv_pkt_data[133:132] == 2'b01))begin
            o_lnp_inpkt_pulse <= 1'b1;
        end
        else begin
            o_lnp_inpkt_pulse <= 1'b0;
        end
        
        if((i_fifo_rd == 1'b1) && (ov_fifo_rdata[133:132] == 2'b01))begin
            o_lnp_outpkt_pulse <= 1'b1;
        end
        else begin
            o_lnp_outpkt_pulse <= 1'b0;
        end     
    end
end
regroup_input_buffer regroup_input_buffer_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_pkt_data(iv_pkt_data),
.i_pkt_data_wr(i_pkt_data_wr),

.iv_bufid(wv_bufid_pcb2ibm),
.i_bufid_wr(w_bufid_wr_pcb2ibm),
.o_bufid_ack(w_bufid_ack_ibm2pcb),

.ov_pkt_ram_wdata(wv_pkt_ram_wdata_ibm2pcb),
.o_pkt_ram_wr(w_pkt_ram_wr_ibm2pcb),
.ov_pkt_ram_waddr(wv_pkt_ram_waddr_ibm2pcb),

.ov_flowid(wv_flowid_ibm2ftm),
.ov_frag_id(wv_frag_id_ibm2ftm),
.o_last_frag_flag(w_last_frag_flag_ibm2ftm),
.o_flowid_wr(w_flowid_wr_ibm2ftm),

.iv_queue_id(wv_queue_id_ftm2ibm),
.iv_queue_usedw(wv_queue_usedw_ftm2ibm),
.i_queue_id_wr(w_queue_id_wr_ftm2ibm),

.ov_queue_ram_wdata(wv_queue_ram_wdata_ibm2ram),
.o_queue_ram_wr(w_queue_ram_wr_ibm2ram),
.ov_queue_ram_waddr(wv_queue_ram_waddr_ibm2ram),

.o_ibm_discard_pulse(o_ibm_discard_pulse)
);
flow_table_management flow_table_management_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_flowid(wv_flowid_ibm2ftm),
.iv_frag_id(wv_frag_id_ibm2ftm),
.i_last_frag_flag(w_last_frag_flag_ibm2ftm),
.i_flowid_wr(w_flowid_wr_ibm2ftm),

.ov_queue_id(wv_queue_id_ftm2ibm),
.ov_queue_usedw(wv_queue_usedw_ftm2ibm),
.o_queue_id_wr(w_queue_id_wr_ftm2ibm),
.o_all_queue_used(o_lnp_flow_table_overflow_pulse),    

.ov_fmt_ram_wdata(wv_fmt_ram_wdata_ftm2ram),
.o_fmt_ram_wr(w_fmt_ram_wr_ftm2ram),
.ov_fmt_ram_waddr(wv_fmt_ram_waddr_ftm2ram),       
.iv_fmt_ram_rdata(wv_fmt_ram_rdata_ram2ftm),
.o_fmt_ram_rd(w_fmt_ram_rd_ftm2ram),
.ov_fmt_ram_raddr(wv_fmt_ram_raddr_ftm2ram),

.iv_queue_id_free(wv_queue_id_free_fsm2ftm),
.i_queue_id_free_wr(w_queue_id_free_wr_fsm2ftm),
.ov_queue_empty(wv_queue_empty_ftm2fsm),

.o_lnp_no_last_frag_flag_pulse(o_lnp_no_last_frag_flag_pulse),      
.o_lnp_no_notlast_frag_flag_pulse(o_lnp_no_notlast_frag_flag_pulse) 
);

ram_10_512 queue_buffer
(      
.clock(i_clk),
.data(wv_queue_ram_wdata_ibm2ram),
.wren(w_queue_ram_wr_ibm2ram),
.wraddress(wv_queue_ram_waddr_ibm2ram),

.rden(w_queue_ram_rd_fsm2ram),
.rdaddress(wv_queue_ram_raddr_fsm2ram),
.q(wv_queue_ram_rdata_ram2fsm)    
);	

ram_19_32 flow_map_table
(      
.clock(i_clk),
.data(wv_fmt_ram_wdata_ftm2ram),
.wren(w_fmt_ram_wr_ftm2ram),
.wraddress(wv_fmt_ram_waddr_ftm2ram),

.rden(w_fmt_ram_rd_ftm2ram),
.rdaddress(wv_fmt_ram_raddr_ftm2ram),
.q(wv_fmt_ram_rdata_ram2ftm)    
);	

packet_centralized_buffer packet_centralized_buffer_inst(
.clk_sys(i_clk),
.reset_n(i_rst_n),

.pkt_ram_wdata(wv_pkt_ram_wdata_ibm2pcb),
.pkt_ram_wr(w_pkt_ram_wr_ibm2pcb),
.pkt_ram_waddr(wv_pkt_ram_waddr_ibm2pcb),

.pkt_ram_rdata(wv_pkt_ram_rdata_pcb2fsm),
.pkt_ram_rd(w_pkt_ram_rd_fsm2pcb),
.pkt_ram_raddr(wv_pkt_ram_raddr_fsm2pcb),	

.bufid_free_req(wv_bufid_fsm2pcb),
.bufid_free_req_wr(w_bufid_wr_fsm2pcb),
.bufid_free_req_ack(w_bufid_ack_pcb2fsm),

.bufid_allocate(wv_bufid_pcb2ibm),
.bufid_allocate_wr(w_bufid_wr_pcb2ibm),
.bufid_allocate_ack(w_bufid_ack_ibm2pcb),
.initial_finish(o_initial_finish)

);

fragment_sorting fragment_sorting_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.ov_queue_id_free(wv_queue_id_free_fsm2ftm),
.o_queue_id_free_wr(w_queue_id_free_wr_fsm2ftm),
.iv_queue_empty(wv_queue_empty_ftm2fsm),

.iv_queue_ram_rdata(wv_queue_ram_rdata_ram2fsm),
.o_queue_ram_rd(w_queue_ram_rd_fsm2ram),
.ov_queue_ram_raddr(wv_queue_ram_raddr_fsm2ram),

.ov_bufid(wv_bufid_fsm2pcb),
.o_bufid_wr(w_bufid_wr_fsm2pcb),
.i_bufid_ack(w_bufid_ack_pcb2fsm),

.iv_pkt_ram_rdata(wv_pkt_ram_rdata_pcb2fsm),
.o_pkt_ram_rd(w_pkt_ram_rd_fsm2pcb),
.ov_pkt_ram_raddr(wv_pkt_ram_raddr_fsm2pcb),

.ov_pkt_data(wv_pkt_data_fsm2rlt),
.o_pkt_data_wr(w_pkt_data_wr_fsm2rlt),
.i_pkt_data_ready(w_pkt_data_ready_rlt2fsm)
);

regroup_lookup_table regroup_lookup_table_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_pkt_data(wv_pkt_data_fsm2rlt),
.i_pkt_data_wr(w_pkt_data_wr_fsm2rlt),
.o_pkt_data_ready(w_pkt_data_ready_rlt2fsm),

.iv_regroup_ram_rdata(wv_regroup_ram_rdata_ram2rlt),
.o_regroup_ram_rd(w_regroup_ram_rd_rlt2ram),
.ov_regroup_ram_raddr(wv_regroup_ram_addr_rlt2ram),

.ov_pkt_data(wv_pkt_data_rlt2fifo),
.o_pkt_data_wr(w_pkt_data_wr_rlt2fifo),
.iv_fifo_usedw(wv_fifo_usedw_fifo2rlt)
);

ram_71_256 regroup_map_table
(
.address_a(iv_regroup_ram_addr),
.address_b(wv_regroup_ram_addr_rlt2ram),
.clock(i_clk),
.data_a(iv_regroup_ram_wdata),
.data_b(71'b0),
.rden_a(i_regroup_ram_rd),
.rden_b(w_regroup_ram_rd_rlt2ram),
.wren_a(i_regroup_ram_wr),
.wren_b(1'b0),
.q_a(ov_regroup_ram_rdata),
.q_b(wv_regroup_ram_rdata_ram2rlt)
);

fifo_134_128 lnp_packet_buffer
(
.data(wv_pkt_data_rlt2fifo),  //  fifo_input.datain
.wrreq(w_pkt_data_wr_rlt2fifo), //            .wrreq
.rdreq(i_fifo_rd), //            .rdreq
.clock(i_clk), //            .clk
.q(ov_fifo_rdata),     // fifo_output.dataout
.usedw(wv_fifo_usedw_fifo2rlt), //            .usedw
.full(),  //            .full
.empty(o_fifo_empty)  //            .empty
);
endmodule 