// Copyright (C) 1953-2020 NUDT
// Verilog module name - ts_submit_schedule 
// Version: TSS_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         submit schedule of time-sensitive packet
//             - parse command;
//             - use a true dual port ram to cache submit slot table; 
//             - schedule descriptor of time-sensitive packet according to submit slot table.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module ts_submit_schedule
(
       i_clk,
       i_rst_n,
       iv_cfg_finish,
       
       iv_syned_global_time,
       iv_time_slot_length,
       
       i_ts_submit_addr_ack,
       ov_ts_submit_addr,
       o_ts_submit_addr_wr,

       ssm_state,
       iv_submit_slot_table_wdata,
       i_submit_slot_table_wr,
       iv_submit_slot_table_addr,
       ov_submit_slot_table_rdata,
       i_submit_slot_table_rd,
       iv_submit_slot_table_period      
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;
//configuration finish and time synchronization finish
input      [1:0]       iv_cfg_finish;  
// calculation of time slot
input      [47:0]      iv_syned_global_time;      
input      [10:0]      iv_time_slot_length;    // measure:us
// result of schedule
output     [4:0]       ov_ts_submit_addr;
output                 o_ts_submit_addr_wr;
// FLM get ts_descriptor to look up table 
input                  i_ts_submit_addr_ack;  

output     [2:0]       ssm_state;  
input      [15:0]      iv_submit_slot_table_wdata;
input                  i_submit_slot_table_wr;
input      [9:0]       iv_submit_slot_table_addr;
output    [15:0]       ov_submit_slot_table_rdata;
input                  i_submit_slot_table_rd;
input      [10:0]      iv_submit_slot_table_period;
// internal reg&wire for schedule
wire       [9:0]       time_slot_itc2ism;
wire                   w_time_slot_switch;
time_slot_calculation submit_time_calculation_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_syned_global_time(iv_syned_global_time),
.iv_time_slot_length(iv_time_slot_length),

.iv_table_period(iv_submit_slot_table_period),

.ov_time_slot(time_slot_itc2ism),
.o_time_slot_switch(w_time_slot_switch) 
);

submit_schedule_module submit_schedule_module_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.iv_cfg_finish(iv_cfg_finish),
.iv_time_slot(time_slot_itc2ism),
.i_time_slot_switch(w_time_slot_switch),
.iv_submit_slot_table_wdata(iv_submit_slot_table_wdata),
.i_submit_slot_table_wr(i_submit_slot_table_wr),
.iv_submit_slot_table_addr(iv_submit_slot_table_addr),
.ov_submit_slot_table_rdata(ov_submit_slot_table_rdata),
.i_submit_slot_table_rd(i_submit_slot_table_rd),

.i_ts_submit_addr_ack(i_ts_submit_addr_ack),
.ov_ts_submit_addr(ov_ts_submit_addr),
.o_ts_submit_addr_wr(o_ts_submit_addr_wr),

.ssm_state(ssm_state)  
);
endmodule