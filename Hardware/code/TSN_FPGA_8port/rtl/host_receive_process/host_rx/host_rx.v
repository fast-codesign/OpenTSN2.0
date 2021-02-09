// Copyright (C) 1953-2020 NUDT
// Verilog module name - host_rx 
// Version: HRI_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         receive pkt from host
//             - top module
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module host_rx
(
        clk_sys,
        reset_n,
        i_gmii_rst_n_host,
        
        iv_cfg_finish,

        clk_gmii_rx,
        i_gmii_dv,
        iv_gmii_rxd,
        i_gmii_er,     
        timer_rst,
        iv_syned_global_time,

        ov_data,
        o_data_wr,
        ov_ctrl_data,
        
        prp_state,
        pdi_state,

        o_fifo_overflow_pulse, 
        o_fifo_underflow_pulse        
);

// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;
input                   i_gmii_rst_n_host;
//configuration finish and time synchronization finish
input      [1:0]        iv_cfg_finish;  
//GMII input
input                   clk_gmii_rx;
input                   i_gmii_dv;
input       [7:0]       iv_gmii_rxd;
input                   i_gmii_er;
//timer reset pusle
input       [47:0]      iv_syned_global_time;
input                   timer_rst;
//user data output
output      [8:0]       ov_data;
output                  o_data_wr;
output      [18:0]      ov_ctrl_data;
output      [2:0]       pdi_state;
output      [1:0]       prp_state;
   
output                  o_fifo_overflow_pulse;
output                  o_fifo_underflow_pulse;
// internal wire
wire        [8:0]       data_gwr2fifo;
wire                    data_wr_gwr2fifo;
wire                    data_full_fifo2gwr;
wire        [8:0]       data_fifo2grd;
wire                    data_rd_grd2fifo;
wire                    data_empty_fifo2grd;
wire        [18:0]      timer;

wire        [8:0]       data_prp2pdi;
wire                    data_wr_prp2pdi;

gmii_write gmii_write_inst
(
.clk_gmii_rx(clk_gmii_rx),
.reset_n(i_gmii_rst_n_host),

.i_gmii_dv(i_gmii_dv),
.iv_gmii_rxd(iv_gmii_rxd),
.i_gmii_er(i_gmii_er),

.ov_data(data_gwr2fifo),
.o_data_wr(data_wr_gwr2fifo),
.i_data_full(data_full_fifo2gwr),
.o_gmii_er(),
.o_fifo_overflow_pulse(o_fifo_overflow_pulse)
);
    
ptp_receive_process ptp_receive_process_inst
(
.clk_sys(clk_sys),
.reset_n(reset_n),

.iv_cfg_finish(iv_cfg_finish), 
.iv_data(data_fifo2grd),
.o_data_rd(data_rd_grd2fifo),
.i_data_empty(data_empty_fifo2grd),
.timer(timer),
.iv_syned_global_time(iv_syned_global_time),
.ov_data(data_prp2pdi),
.o_data_wr(data_wr_prp2pdi),
.report_prp_state(prp_state),
.o_fifo_underflow_pulse(o_fifo_underflow_pulse)
);
packet_distinguish_module packet_distinguish_module_inst
(
.i_clk(clk_sys),
.i_rst_n(reset_n),

.iv_data(data_prp2pdi),
.i_data_wr(data_wr_prp2pdi),    

.ov_data(ov_data),
.o_data_wr(o_data_wr),
.ov_ctrl_data(ov_ctrl_data),
.pdi_state(pdi_state) 
);

ASFIFO_9_16  ASFIFO_9_16_inst
    (        
    .wr_aclr(~i_gmii_rst_n_host),                 //Reset the all signal
    .rd_aclr(~reset_n),
    .data(data_gwr2fifo),                         //The Inport of data
    .rdreq(data_rd_grd2fifo),                     //active-high
    .wrclk(clk_gmii_rx),                          //ASYNC WriteClk(), SYNC use wrclk
    .rdclk(clk_sys),                              //ASYNC WriteClk(), SYNC use wrclk  
    .wrreq(data_wr_gwr2fifo),                     //active-high
    .q(data_fifo2grd),                            //The output of data
    .wrfull(data_full_fifo2gwr),                  //Write domain full 
    .wralfull(),                                  //Write domain almost-full
    .wrempty(),                                   //Write domain empty
    .wralempty(),                                 //Write domain almost-full  
    .rdfull(),                                    //Read domain full
    .rdalfull(),                                  //Read domain almost-full   
    .rdempty(data_empty_fifo2grd),                //Read domain empty
    .rdalempty(),                                 //Read domain almost-empty
    .wrusedw(),                                   //Write-usedword
    .rdusedw()          
    );
    
host_rx_timer host_rx_timer_inst
(
.i_clk(clk_sys),
.i_rst_n(reset_n),
.i_timer_rst(timer_rst),
.ov_timer(timer)
);
endmodule