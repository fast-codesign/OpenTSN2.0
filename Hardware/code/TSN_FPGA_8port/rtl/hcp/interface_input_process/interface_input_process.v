// Copyright (C) 1953-2020 NUDT
// Verilog module name - HRI 
// Version: HRI_V1.0
// Created:
//         by - fenglin
//         at - 06.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         receive pkt from host
//             - top module
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module interface_input_process
(
		i_clk,
		i_rst_n,
        i_gmii_rst_n, 

		clk_gmii_rx,
		i_gmii_dv,
		iv_gmii_rxd,
		i_gmii_er,	   

		ov_data,
		o_data_wr,
        ov_chip_pkt_inport,
        iv_hcp_state,
        o_fifo_overflow_pulse,
        o_fifo_underflow_pulse,
        o_frc_discard_pkt_pulse        
);

// I/O
// clk & rst
input                  	i_clk;
input                  	i_rst_n;
input                   i_gmii_rst_n;
//GMII input
input					clk_gmii_rx;
input					i_gmii_dv;
input		[7:0]		iv_gmii_rxd;
input					i_gmii_er;

input       [1:0]       iv_hcp_state;
//data output
output		[133:0]     ov_data;
output			      	o_data_wr;
output		[3:0]       ov_chip_pkt_inport;
//fifo overflow/underflow
output	                o_fifo_overflow_pulse;
output	                o_fifo_underflow_pulse;

output                  o_frc_discard_pkt_pulse;
// internal wire
wire		[8:0]		data_gwr2fifo;
wire					data_wr_gwr2fifo;
wire					data_full_fifo2gwr;
wire		[8:0]		data_fifo2grd;
wire					data_rd_grd2fifo;
wire					data_empty_fifo2grd;
//grd-iwt
wire		[8:0]		data_grd2iwt;
wire					data_wr_grd2iwt;
//iwt-fifo
wire        [133:0]     wv_data_iwt2fifo;
wire                    w_data_wr_iwt2fifo;     
wire        [63:0]      wv_metadata_iwt2fifo;
wire                    w_metadata_wr_iwt2fifo;

wire        [63:0]      wv_metadata_fifo2frc;
wire                    w_metadata_fifo_rd_frc2fifo;
wire                    w_metadata_fifo_empty_fifo2frc;
//fifo-frc
wire		[133:0]		data_fifo2frc;
wire					data_rd_frc2fifo;
wire					data_empty_fifo2frc;
hcp_gmii_write hcp_gmii_write_inst
(
.clk_gmii_rx(clk_gmii_rx),
.reset_n(i_gmii_rst_n),

.i_gmii_dv(i_gmii_dv),
.iv_gmii_rxd(iv_gmii_rxd),
.i_gmii_er(i_gmii_er),

.ov_data(data_gwr2fifo),
.o_data_wr(data_wr_gwr2fifo),
.i_data_full(data_full_fifo2gwr),
.o_gmii_er(),
.o_fifo_overflow_pulse(o_fifo_overflow_pulse)
);

fifo_9_16  asynfifo_9_16_inst
(
.data    (data_gwr2fifo),    //  fifo_input.datain
.wrreq   (data_wr_gwr2fifo),   //            .wrreq
.rdreq   (data_rd_grd2fifo),   //            .rdreq
.wrclk   (clk_gmii_rx),   //            .wrclk
.rdclk   (i_clk),   //            .rdclk
.aclr    (~i_rst_n),    //            .aclr
.q       (data_fifo2grd),       // fifo_output.dataout
.rdusedw (), //            .rdusedw
.wrusedw (), //            .wrusedw
.rdfull  (),  //            .rdfull
.rdempty (data_empty_fifo2grd), //            .rdempty
.wrfull  (data_full_fifo2gwr),  //            .wrfull
.wrempty ()  //            .wrempty
);	

hcp_gmii_read hcp_gmii_read_inst
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(data_fifo2grd),
.o_data_rd(data_rd_grd2fifo),
.i_data_empty(data_empty_fifo2grd),
.ov_data(data_grd2iwt),
.o_data_wr(data_wr_grd2iwt),
.o_fifo_underflow_pulse(o_fifo_underflow_pulse)
);

input_width_transform input_width_transform_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(data_grd2iwt),
.i_data_wr(data_wr_grd2iwt),

.ov_data(wv_data_iwt2fifo),
.o_data_wr(w_data_wr_iwt2fifo),

.ov_metadata(wv_metadata_iwt2fifo),
.o_metadata_wr(w_metadata_wr_iwt2fifo)
);

fifo_134_128 pkt_fifo_inst(
.data(wv_data_iwt2fifo),  //  fifo_input.datain
.wrreq(w_data_wr_iwt2fifo), //            .wrreq
.rdreq(data_rd_frc2fifo), //            .rdreq
.clock(i_clk), //            .clk
.q(data_fifo2frc),     // fifo_output.dataout
.usedw(), //            .usedw
.full(),  //            .full
.empty(data_empty_fifo2frc)  //            .empty
);

fifo_64_4 cache_metadata_inst(
.data(wv_metadata_iwt2fifo),  //  fifo_input.datain
.wrreq(w_metadata_wr_iwt2fifo), //            .wrreq
.rdreq(w_metadata_fifo_rd_frc2fifo), //            .rdreq
.clock(i_clk), //            .clk
.q(wv_metadata_fifo2frc),     // fifo_output.dataout
.usedw(), //            .usedw
.full(),  //            .full
.empty(w_metadata_fifo_empty_fifo2frc)  //            .empty
);
frame_receive_control frame_receive_control_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_hcp_state(iv_hcp_state),

.iv_pkt_data(data_fifo2frc),
.o_pkt_data_rd(data_rd_frc2fifo),
.i_pkt_data_empty(data_empty_fifo2frc),

.iv_metadata(wv_metadata_fifo2frc),
.o_metadata_rd(w_metadata_fifo_rd_frc2fifo),
.i_metadata_fifo_empty(w_metadata_fifo_empty_fifo2frc),

.ov_data(ov_data),
.o_data_wr(o_data_wr),
.ov_chip_pkt_inport(ov_chip_pkt_inport),

.o_frc_discard_pkt_pulse(o_frc_discard_pkt_pulse)   
);
endmodule