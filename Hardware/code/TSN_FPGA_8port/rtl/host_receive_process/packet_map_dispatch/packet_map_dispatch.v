// Copyright (C) 1953-2020 NUDT
// Verilog module name - packet_map_dispatch
// Version: PMD_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         map traffic transmitted by user into traffic identificated by network.
//             - monitor whether TS packet is overflow, 
//             - generate descriptor of packet, 
//             - write packet to ram,
//             - write descriptor of TS packet to ram,
//             - transmit descriptor of not TS packet to FLT to look up table;
//             - top module.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module packet_map_dispatch
(
       i_clk,
       i_rst_n,
       
       iv_data,
       i_data_wr,
       iv_ctrl_data,
       
       iv_ts_cnt,
       
       ov_nmac_data,
       o_nmac_data_wr,
       
       iv_bufid,
       i_bufid_wr,
       o_bufid_ack,
       
       ov_wdata,
       o_data_wr,
       ov_data_waddr,
       i_wdata_ack,
       
       o_pkt_cnt_pulse,
       o_pkt_discard_cnt_pulse,
       
       tom_state,
       descriptor_state,
       pkt_state,
       transmission_state, 
       
       ov_ts_descriptor,
       o_ts_descriptor_wr,
       ov_ts_descriptor_waddr,
       
       ov_nts_descriptor,
       o_nts_descriptor_wr,
       i_nts_descriptor_ack,
       
       iv_free_bufid_fifo_rdusedw,
       iv_rc_threshold_value,
       iv_be_threshold_value,  

       o_ts_overflow_error_pulse,
       ov_debug_cnt       
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input      [8:0]       iv_data;
input                  i_data_wr;
input      [18:0]      iv_ctrl_data;
//TS traffic state
input      [31:0]      iv_ts_cnt;
// nmac pkt output
output     [8:0]       ov_nmac_data;
output                 o_nmac_data_wr;
// bufid input
input      [8:0]       iv_bufid;
input                  i_bufid_wr;
output                 o_bufid_ack;
// pkt output
output    [133:0]      ov_wdata;
output                 o_data_wr;
output    [15:0]       ov_data_waddr;
input                  i_wdata_ack;

output                 o_pkt_cnt_pulse;
output     [1:0]       tom_state;
output     [2:0]       descriptor_state;
output     [2:0]       pkt_state;
output     [2:0]       transmission_state;
// descriptor of ts pkt output
output    [35:0]       ov_ts_descriptor;
output                 o_ts_descriptor_wr;
output    [4:0]        ov_ts_descriptor_waddr;
// descriptor of not ts pkt output
output    [45:0]       ov_nts_descriptor;
output                 o_nts_descriptor_wr;
input                  i_nts_descriptor_ack; 
//threshold of discard
input      [8:0]       iv_free_bufid_fifo_rdusedw;
input      [8:0]       iv_rc_threshold_value;
input      [8:0]       iv_be_threshold_value;

output                 o_pkt_discard_cnt_pulse;
//count overflow error of 32 TS flow 
output                 o_ts_overflow_error_pulse; 
// internal reg&wire   
wire      [8:0]        wv_data_tom2ibm;
wire                   w_data_wr_tom2ibm;
wire      [18:0]       wv_ctrl_data_tom2ibm;

ts_overflow_monitor ts_overflow_monitor_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(iv_data),
.i_data_wr(i_data_wr),
.iv_ctrl_data(iv_ctrl_data),

.iv_ts_cnt(iv_ts_cnt),
.o_pkt_cnt_pulse(o_pkt_cnt_pulse),

.ov_nmac_data(ov_nmac_data),
.o_nmac_data_wr(o_nmac_data_wr),

.ov_data(wv_data_tom2ibm),
.o_data_wr(w_data_wr_tom2ibm),
.ov_ctrl_data(wv_ctrl_data_tom2ibm),

.tom_state(tom_state),
.o_ts_overflow_error_pulse(o_ts_overflow_error_pulse)
);
input_buffer_management input_buffer_management_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(wv_data_tom2ibm),
.i_data_wr(w_data_wr_tom2ibm),
.iv_ctrl_data(wv_ctrl_data_tom2ibm),

.iv_bufid(iv_bufid),
.i_bufid_wr(i_bufid_wr),
.o_bufid_ack(o_bufid_ack),

.ov_wdata(ov_wdata),
.o_data_wr(o_data_wr),
.ov_data_waddr(ov_data_waddr),
.i_wdata_ack(i_wdata_ack),

.o_pkt_discard_cnt_pulse(o_pkt_discard_cnt_pulse),

.ov_ts_descriptor(ov_ts_descriptor),
.o_ts_descriptor_wr(o_ts_descriptor_wr),
.ov_ts_descriptor_waddr(ov_ts_descriptor_waddr),

.ov_nts_descriptor(ov_nts_descriptor),
.o_nts_descriptor_wr(o_nts_descriptor_wr),
.i_nts_descriptor_ack(i_nts_descriptor_ack),

.iv_free_bufid_fifo_rdusedw(iv_free_bufid_fifo_rdusedw),
.iv_rc_threshold_value(iv_rc_threshold_value),
.iv_be_threshold_value(iv_be_threshold_value),  

.descriptor_state(descriptor_state),  
.pkt_state(pkt_state),
.transmission_state(transmission_state)
); 
output reg [15:0] ov_debug_cnt;  
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_debug_cnt <= 16'b0;
    end
    else begin
        if(o_bufid_ack)begin
            ov_debug_cnt <= ov_debug_cnt + 1'b1;
        end
        else begin
            ov_debug_cnt <= ov_debug_cnt;
        end
    end
end	 
endmodule