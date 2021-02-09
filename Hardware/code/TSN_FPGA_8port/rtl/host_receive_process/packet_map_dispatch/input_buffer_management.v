// Copyright (C) 1953-2020 NUDT
// Verilog module name - input_buffer_management
// Version: IBM_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         management of input buffer.
//             - generate descriptor of packet; 
//             - write packet to ram;
//             - write descriptor of TS packet to ram;
//             - transmit descriptor of not TS packet to FLT to look up table;
//             - top module.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module input_buffer_management
(
       i_clk,
       i_rst_n,
       
       iv_data,
       i_data_wr,
       iv_ctrl_data,
       
       iv_bufid,
       i_bufid_wr,
       o_bufid_ack,
       
       ov_wdata,
       o_data_wr,
       ov_data_waddr,
       i_wdata_ack,
       
       o_pkt_discard_cnt_pulse,
       
       ov_ts_descriptor,
       o_ts_descriptor_wr,
       ov_ts_descriptor_waddr,
       
       ov_nts_descriptor,
       o_nts_descriptor_wr,
       i_nts_descriptor_ack,
       
       iv_free_bufid_fifo_rdusedw,
       iv_rc_threshold_value,
       iv_be_threshold_value,    

       descriptor_state,
       pkt_state,
       transmission_state      
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input      [8:0]       iv_data;
input                  i_data_wr;
input      [18:0]      iv_ctrl_data;
// bufid input
input      [8:0]       iv_bufid;
input                  i_bufid_wr;
output                 o_bufid_ack;
// pkt output
output     [133:0]     ov_wdata;
output                 o_data_wr;
output     [15:0]      ov_data_waddr;
input                  i_wdata_ack;
// descriptor of ts pkt output
output     [35:0]      ov_ts_descriptor;
output                 o_ts_descriptor_wr;
output     [4:0]       ov_ts_descriptor_waddr;
// descriptor of not ts pkt output
output     [45:0]      ov_nts_descriptor;
output                 o_nts_descriptor_wr;
input                  i_nts_descriptor_ack; 
//threshold of discard
input      [8:0]       iv_free_bufid_fifo_rdusedw;
input      [8:0]       iv_rc_threshold_value;
input      [8:0]       iv_be_threshold_value;

output     [2:0]       descriptor_state;
output     [2:0]       pkt_state;
output     [2:0]       transmission_state;

output                 o_pkt_discard_cnt_pulse;

wire       [8:0]       wv_bufid_abm2trr;
wire                   w_bufid_empty_abm2trr;
wire                   w_get_new_bufid_req;

wire       [133:0]     wv_data1_trw2trr;
wire                   w_data1_write_flag_trw2trr;
wire       [133:0]     wv_data2_trw2trr;
wire                   w_data2_write_flag_trw2trr;

two_regs_write two_regs_write_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(iv_data),
.i_data_wr(i_data_wr),
.iv_ctrl_data(iv_ctrl_data),

.i_bufid_empty(~i_bufid_wr),

.o_pkt_discard_cnt_pulse(o_pkt_discard_cnt_pulse),

.ov_data1(wv_data1_trw2trr),
.o_data1_write_flag(w_data1_write_flag_trw2trr),
.ov_data2(wv_data2_trw2trr),
.o_data2_write_flag(w_data2_write_flag_trw2trr),

.iv_free_bufid_fifo_rdusedw(iv_free_bufid_fifo_rdusedw),
.iv_rc_threshold_value(iv_rc_threshold_value),
.iv_be_threshold_value(iv_be_threshold_value),    

.pkt_state(pkt_state)
);  
two_regs_read two_regs_read_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data1(wv_data1_trw2trr),
.iv_data2(wv_data2_trw2trr),

.i_data1_write_flag(w_data1_write_flag_trw2trr),
.i_data2_write_flag(w_data2_write_flag_trw2trr),

.o_bufid_ack    (o_bufid_ack),

.i_bufid_empty(~i_bufid_wr),
.iv_bufid(iv_bufid),

.ov_wdata(ov_wdata),
.o_data_wr(o_data_wr),
.ov_data_waddr(ov_data_waddr),
.i_wdata_ack(i_wdata_ack),
.transmission_state(transmission_state)
);
pkt_descriptor_generation pkt_descriptor_generation_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(iv_data),
.i_data_wr(i_data_wr),
.iv_ctrl_data(iv_ctrl_data),

.i_bufid_empty(~i_bufid_wr),
.iv_bufid(iv_bufid),

.ov_ts_descriptor(ov_ts_descriptor),
.o_ts_descriptor_wr(o_ts_descriptor_wr),
.ov_ts_descriptor_waddr(ov_ts_descriptor_waddr),

.iv_free_bufid_fifo_rdusedw(iv_free_bufid_fifo_rdusedw),
.iv_rc_threshold_value(iv_rc_threshold_value),
.iv_be_threshold_value(iv_be_threshold_value),  

.ov_nts_descriptor(ov_nts_descriptor),
.o_nts_descriptor_wr(o_nts_descriptor_wr),
.i_nts_descriptor_ack(i_nts_descriptor_ack),
.descriptor_state(descriptor_state)  
);   
endmodule 