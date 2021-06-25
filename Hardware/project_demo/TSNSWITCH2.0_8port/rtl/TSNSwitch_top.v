// Copyright (C) 1953-2020 NUDT
// Verilog module name - TSNSwitch_top 
// Version: TSNSwitch_top_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//        top of chip
//               
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module TSNSwitch_top #(parameter tsn_chip_version = 32'h20200922)
(
       i_clk,
       
       i_hard_rst_n,
       i_button_rst_n,
       i_et_resetc_rst_n,  
       
       ov_gmii_txd_p0,
       o_gmii_tx_en_p0,
       o_gmii_tx_er_p0,
       o_gmii_tx_clk_p0,

       ov_gmii_txd_p1,
       o_gmii_tx_en_p1,
       o_gmii_tx_er_p1,
       o_gmii_tx_clk_p1,
       
       ov_gmii_txd_p2,
       o_gmii_tx_en_p2,
       o_gmii_tx_er_p2,
       o_gmii_tx_clk_p2,
       
       ov_gmii_txd_p3,
       o_gmii_tx_en_p3,
       o_gmii_tx_er_p3,
       o_gmii_tx_clk_p3,

       ov_gmii_txd_p4,
       o_gmii_tx_en_p4,
       o_gmii_tx_er_p4,
       o_gmii_tx_clk_p4,
       
       ov_gmii_txd_p5,
       o_gmii_tx_en_p5,
       o_gmii_tx_er_p5,
       o_gmii_tx_clk_p5,
       
       ov_gmii_txd_p6,
       o_gmii_tx_en_p6,
       o_gmii_tx_er_p6,
       o_gmii_tx_clk_p6,

       ov_gmii_txd_p7,
       o_gmii_tx_en_p7,
       o_gmii_tx_er_p7,
       o_gmii_tx_clk_p7,
       

       
       //Network input top module
       i_gmii_rxclk_p0,
       i_gmii_dv_p0,
       iv_gmii_rxd_p0,
       i_gmii_er_p0,
       
       i_gmii_rxclk_p1,
       i_gmii_dv_p1,
       iv_gmii_rxd_p1,
       i_gmii_er_p1,
       
       i_gmii_rxclk_p2,
       i_gmii_dv_p2,
       iv_gmii_rxd_p2,
       i_gmii_er_p2,

       i_gmii_rxclk_p3,
       i_gmii_dv_p3,
       iv_gmii_rxd_p3,
       i_gmii_er_p3,
       
       i_gmii_rxclk_p4,
       i_gmii_dv_p4,
       iv_gmii_rxd_p4,
       i_gmii_er_p4,
       
       i_gmii_rxclk_p5,
       i_gmii_dv_p5,
       iv_gmii_rxd_p5,
       i_gmii_er_p5,

       i_gmii_rxclk_p6,
       i_gmii_dv_p6,
       iv_gmii_rxd_p6,
       i_gmii_er_p6,
       
       i_gmii_rxclk_p7,
       i_gmii_dv_p7,
       iv_gmii_rxd_p7,
       i_gmii_er_p7,
       
       
       //hrp
       i_gmii_rxclk_host,
       i_gmii_dv_host,
       iv_gmii_rxd_host,
       i_gmii_er_host,
       
       //htp
       ov_gmii_txd_host,//ov_gmii_txd_p3
       o_gmii_tx_en_host,
       o_gmii_tx_er_host,
       o_gmii_tx_clk_host,

       //o_init_led,
       pluse_s,
       reset_clk_pulse,
       asynfifo_rx_overflow_pulse, 
       asynfifo_rx_underflow_pulse,
       asynfifo_tx_overflow_pulse   
);

input                   i_clk;                  //125Mhz

input                   i_hard_rst_n;
input                   i_button_rst_n;
input                   i_et_resetc_rst_n;

output                  pluse_s;
//output                o_init_led;
output                  reset_clk_pulse;
output                  asynfifo_rx_overflow_pulse;
output                  asynfifo_rx_underflow_pulse;
output                  asynfifo_tx_overflow_pulse;  

//input
input                   i_gmii_rxclk_p0;
input                   i_gmii_dv_p0;
input       [7:0]       iv_gmii_rxd_p0;
input                   i_gmii_er_p0;

input                   i_gmii_rxclk_p1;
input                   i_gmii_dv_p1;
input       [7:0]       iv_gmii_rxd_p1;
input                   i_gmii_er_p1;

input                   i_gmii_rxclk_p2;
input                   i_gmii_dv_p2;
input       [7:0]       iv_gmii_rxd_p2;
input                   i_gmii_er_p2;


input                   i_gmii_rxclk_p3;
input                   i_gmii_dv_p3;
input       [7:0]       iv_gmii_rxd_p3;
input                   i_gmii_er_p3;

input                   i_gmii_rxclk_p4;
input                   i_gmii_dv_p4;
input       [7:0]       iv_gmii_rxd_p4;
input                   i_gmii_er_p4;

input                   i_gmii_rxclk_p5;
input                   i_gmii_dv_p5;
input       [7:0]       iv_gmii_rxd_p5;
input                   i_gmii_er_p5;

input                   i_gmii_rxclk_p6;
input                   i_gmii_dv_p6;
input       [7:0]       iv_gmii_rxd_p6;
input                   i_gmii_er_p6;

input                   i_gmii_rxclk_p7;
input                   i_gmii_dv_p7;
input       [7:0]       iv_gmii_rxd_p7;
input                   i_gmii_er_p7;

input                   i_gmii_rxclk_host;
input                   i_gmii_dv_host;
input       [7:0]       iv_gmii_rxd_host;
input                   i_gmii_er_host;

//output
output      [7:0]       ov_gmii_txd_p0;
output                  o_gmii_tx_en_p0;
output                  o_gmii_tx_er_p0;
output                  o_gmii_tx_clk_p0;

output      [7:0]       ov_gmii_txd_p1;
output                  o_gmii_tx_en_p1;
output                  o_gmii_tx_er_p1;
output                  o_gmii_tx_clk_p1;

output      [7:0]       ov_gmii_txd_p2;
output                  o_gmii_tx_en_p2;
output                  o_gmii_tx_er_p2;
output                  o_gmii_tx_clk_p2;

output      [7:0]       ov_gmii_txd_p3;
output                  o_gmii_tx_en_p3;
output                  o_gmii_tx_er_p3;
output                  o_gmii_tx_clk_p3;

output      [7:0]       ov_gmii_txd_p4;
output                  o_gmii_tx_en_p4;
output                  o_gmii_tx_er_p4;
output                  o_gmii_tx_clk_p4;

output      [7:0]       ov_gmii_txd_p5;
output                  o_gmii_tx_en_p5;
output                  o_gmii_tx_er_p5;
output                  o_gmii_tx_clk_p5;

output      [7:0]       ov_gmii_txd_p6;
output                  o_gmii_tx_en_p6;
output                  o_gmii_tx_er_p6;
output                  o_gmii_tx_clk_p6;

output      [7:0]       ov_gmii_txd_p7;
output                  o_gmii_tx_en_p7;
output                  o_gmii_tx_er_p7;
output                  o_gmii_tx_clk_p7;

output      [7:0]       ov_gmii_txd_host;
output                  o_gmii_tx_en_host;
output                  o_gmii_tx_er_host;
output                  o_gmii_tx_clk_host;

//adp2tsnchip 
wire                    w_gmii_dv_p0_adp2tsnchip;
wire        [7:0]       wv_gmii_rxd_p0_adp2tsnchip;
wire                    w_gmii_er_p0_adp2tsnchip;

wire                    w_gmii_dv_p1_adp2tsnchip;
wire        [7:0]       wv_gmii_rxd_p1_adp2tsnchip;
wire                    w_gmii_er_p1_adp2tsnchip;

wire                    w_gmii_dv_p2_adp2tsnchip;
wire        [7:0]       wv_gmii_rxd_p2_adp2tsnchip;
wire                    w_gmii_er_p2_adp2tsnchip;

wire                    w_gmii_dv_p3_adp2tsnchip;
wire        [7:0]       wv_gmii_rxd_p3_adp2tsnchip;
wire                    w_gmii_er_p3_adp2tsnchip;

wire                    w_gmii_dv_p4_adp2tsnchip;
wire        [7:0]       wv_gmii_rxd_p4_adp2tsnchip;
wire                    w_gmii_er_p4_adp2tsnchip;

wire                    w_gmii_dv_p5_adp2tsnchip;
wire        [7:0]       wv_gmii_rxd_p5_adp2tsnchip;
wire                    w_gmii_er_p5_adp2tsnchip;

wire                    w_gmii_dv_p6_adp2tsnchip;
wire        [7:0]       wv_gmii_rxd_p6_adp2tsnchip;
wire                    w_gmii_er_p6_adp2tsnchip;

wire                    w_gmii_dv_p7_adp2tsnchip;
wire        [7:0]       wv_gmii_rxd_p7_adp2tsnchip;
wire                    w_gmii_er_p7_adp2tsnchip;

wire                    w_gmii_dv_host_adp2tsnchip;
wire        [7:0]       wv_gmii_rxd_host_adp2tsnchip;
wire                    w_gmii_er_host_adp2tsnchip;

//tsnchip2adp
wire      [7:0]         wv_gmii_txd_p0_tsnchip2adp;
wire                    w_gmii_tx_en_p0_tsnchip2adp;
wire                    w_gmii_tx_er_p0_tsnchip2adp;
    
wire      [7:0]         wv_gmii_txd_p1_tsnchip2adp;
wire                    w_gmii_tx_en_p1_tsnchip2adp;
wire                    w_gmii_tx_er_p1_tsnchip2adp;
    
wire      [7:0]         wv_gmii_txd_p2_tsnchip2adp;
wire                    w_gmii_tx_en_p2_tsnchip2adp;
wire                    w_gmii_tx_er_p2_tsnchip2adp;
    
wire      [7:0]         wv_gmii_txd_p3_tsnchip2adp;
wire                    w_gmii_tx_en_p3_tsnchip2adp;
wire                    w_gmii_tx_er_p3_tsnchip2adp;
    
wire      [7:0]         wv_gmii_txd_p4_tsnchip2adp;
wire                    w_gmii_tx_en_p4_tsnchip2adp;
wire                    w_gmii_tx_er_p4_tsnchip2adp;
    
wire      [7:0]         wv_gmii_txd_p5_tsnchip2adp;
wire                    w_gmii_tx_en_p5_tsnchip2adp;
wire                    w_gmii_tx_er_p5_tsnchip2adp;
    
wire      [7:0]         wv_gmii_txd_p6_tsnchip2adp;
wire                    w_gmii_tx_en_p6_tsnchip2adp;
wire                    w_gmii_tx_er_p6_tsnchip2adp;

wire      [7:0]         wv_gmii_txd_p7_tsnchip2adp;
wire                    w_gmii_tx_en_p7_tsnchip2adp;
wire                    w_gmii_tx_er_p7_tsnchip2adp;

wire      [7:0]         wv_gmii_txd_host_tsnchip2adp;
wire                    w_gmii_tx_en_host_tsnchip2adp;
wire                    w_gmii_tx_er_host_tsnchip2adp;

wire                    w_fifo_overflow_pulse_host_rx;
wire                    w_fifo_underflow_pulse_host_rx;
wire                    w_fifo_underflow_pulse_p0_rx;
wire                    w_fifo_overflow_pulse_p0_rx; 
wire                    w_fifo_underflow_pulse_p1_rx;
wire                    w_fifo_overflow_pulse_p1_rx; 
wire                    w_fifo_underflow_pulse_p2_rx;
wire                    w_fifo_overflow_pulse_p2_rx; 
wire                    w_fifo_underflow_pulse_p3_rx;
wire                    w_fifo_overflow_pulse_p3_rx; 
wire                    w_fifo_underflow_pulse_p4_rx;
wire                    w_fifo_overflow_pulse_p4_rx; 
wire                    w_fifo_underflow_pulse_p5_rx;
wire                    w_fifo_overflow_pulse_p5_rx; 
wire                    w_fifo_underflow_pulse_p6_rx;
wire                    w_fifo_overflow_pulse_p6_rx; 
wire                    w_fifo_underflow_pulse_p7_rx;
wire                    w_fifo_overflow_pulse_p7_rx; 

wire                    w_fifo_overflow_pulse_host_tx;
wire                    w_fifo_overflow_pulse_p0_tx;
wire                    w_fifo_overflow_pulse_p1_tx;
wire                    w_fifo_overflow_pulse_p2_tx;
wire                    w_fifo_overflow_pulse_p3_tx;
wire                    w_fifo_overflow_pulse_p4_tx;
wire                    w_fifo_overflow_pulse_p5_tx;
wire                    w_fifo_overflow_pulse_p6_tx;
wire                    w_fifo_overflow_pulse_p7_tx;
 
wire     [7:0]          wv_port_type_tsnchip2adp;
wire                    w_port0_type_sync_tsnchip2adp;
wire                    w_port1_type_sync_tsnchip2adp;
wire                    w_port2_type_sync_tsnchip2adp;
wire                    w_port3_type_sync_tsnchip2adp;
wire                    w_port4_type_sync_tsnchip2adp;
wire                    w_port5_type_sync_tsnchip2adp;
wire                    w_port6_type_sync_tsnchip2adp;
wire                    w_port7_type_sync_tsnchip2adp;

//reset sync
wire                   w_core_rst_n;
wire                   w_gmii_rst_n_p0;
wire                   w_gmii_rst_n_p1;
wire                   w_gmii_rst_n_p2;
wire                   w_gmii_rst_n_p3;
wire                   w_gmii_rst_n_p4;
wire                   w_gmii_rst_n_p5;
wire                   w_gmii_rst_n_p6;
wire                   w_gmii_rst_n_p7;
wire                   w_gmii_rst_n_host;

wire                   w_rst_n;
assign w_rst_n = i_hard_rst_n & i_button_rst_n & i_et_resetc_rst_n;
reg        [31:0]       rv_tsn_chip_version/*synthesis noprune*/;
always @(posedge i_clk or negedge w_rst_n) begin
    if(!w_rst_n) begin
        rv_tsn_chip_version <= 32'h0;
    end
    else begin
        rv_tsn_chip_version <= tsn_chip_version;
    end
end
signal_sync p0_type_sync(
.i_clk(i_gmii_rxclk_p0),
.i_rst_n(w_gmii_rst_n_p0),
       
.i_signal_async(wv_port_type_tsnchip2adp[0]),
.o_signal_sync(w_port0_type_sync_tsnchip2adp)   
);

signal_sync p1_type_sync(
.i_clk(i_gmii_rxclk_p1),
.i_rst_n(w_gmii_rst_n_p1),
       
.i_signal_async(wv_port_type_tsnchip2adp[1]),
.o_signal_sync(w_port1_type_sync_tsnchip2adp)   
);

signal_sync p2_type_sync(
.i_clk(i_gmii_rxclk_p2),
.i_rst_n(w_gmii_rst_n_p2),
       
.i_signal_async(wv_port_type_tsnchip2adp[2]),
.o_signal_sync(w_port2_type_sync_tsnchip2adp)   
);

signal_sync p3_type_sync(
.i_clk(i_gmii_rxclk_p3),
.i_rst_n(w_gmii_rst_n_p3),
       
.i_signal_async(wv_port_type_tsnchip2adp[3]),
.o_signal_sync(w_port3_type_sync_tsnchip2adp)   
);

signal_sync p4_type_sync(
.i_clk(i_gmii_rxclk_p4),
.i_rst_n(w_gmii_rst_n_p4),
       
.i_signal_async(wv_port_type_tsnchip2adp[4]),
.o_signal_sync(w_port4_type_sync_tsnchip2adp)   
);

signal_sync p5_type_sync(
.i_clk(i_gmii_rxclk_p5),
.i_rst_n(w_gmii_rst_n_p5),
       
.i_signal_async(wv_port_type_tsnchip2adp[5]),
.o_signal_sync(w_port5_type_sync_tsnchip2adp)   
);

signal_sync p6_type_sync(
.i_clk(i_gmii_rxclk_p6),
.i_rst_n(w_gmii_rst_n_p6),
       
.i_signal_async(wv_port_type_tsnchip2adp[6]),
.o_signal_sync(w_port6_type_sync_tsnchip2adp)   
);

signal_sync p7_type_sync(
.i_clk(i_gmii_rxclk_p7),
.i_rst_n(w_gmii_rst_n_p7),
       
.i_signal_async(wv_port_type_tsnchip2adp[7]),
.o_signal_sync(w_port7_type_sync_tsnchip2adp)   
);

reset_top reset_top_inst(
.i_clk                (i_clk),
.i_rst_n              (w_rst_n),
                      
.i_gmii_rxclk_p0      (i_gmii_rxclk_p0),
.i_gmii_rxclk_p1      (i_gmii_rxclk_p1),
.i_gmii_rxclk_p2      (i_gmii_rxclk_p2),
.i_gmii_rxclk_p3      (i_gmii_rxclk_p3),
.i_gmii_rxclk_p4      (i_gmii_rxclk_p4),
.i_gmii_rxclk_p5      (i_gmii_rxclk_p5),
.i_gmii_rxclk_p6      (i_gmii_rxclk_p6),
.i_gmii_rxclk_p7      (i_gmii_rxclk_p7),
.i_gmii_rxclk_host    (i_gmii_rxclk_host),
                     
.o_core_rst_n         (w_core_rst_n),
.o_gmii_rst_n_p0      (w_gmii_rst_n_p0),
.o_gmii_rst_n_p1      (w_gmii_rst_n_p1),
.o_gmii_rst_n_p2      (w_gmii_rst_n_p2),
.o_gmii_rst_n_p3      (w_gmii_rst_n_p3),
.o_gmii_rst_n_p4      (w_gmii_rst_n_p4),
.o_gmii_rst_n_p5      (w_gmii_rst_n_p5),
.o_gmii_rst_n_p6      (w_gmii_rst_n_p6),
.o_gmii_rst_n_p7      (w_gmii_rst_n_p7),
.o_gmii_rst_n_host    (w_gmii_rst_n_host)
);

reset_clock_check reset_clock_check_inst(
.i_clk(i_clk),
.i_rst_n(w_core_rst_n),

.o_reset_clk_pulse(reset_clk_pulse)  
);

asynfifo_overflow_underflow_output asynfifo_overflow_underflow_output_inst(
.i_clk(i_clk),
.i_rst_n(w_core_rst_n),

.i_fifo_overflow_pulse_host_rx (w_fifo_overflow_pulse_host_rx),
.i_fifo_underflow_pulse_host_rx(w_fifo_underflow_pulse_host_rx),
.i_fifo_underflow_pulse_p0_rx  (w_fifo_underflow_pulse_p0_rx),
.i_fifo_overflow_pulse_p0_rx   (w_fifo_overflow_pulse_p0_rx ),
.i_fifo_underflow_pulse_p1_rx  (w_fifo_underflow_pulse_p1_rx),
.i_fifo_overflow_pulse_p1_rx   (w_fifo_overflow_pulse_p1_rx ), 
.i_fifo_underflow_pulse_p2_rx  (w_fifo_underflow_pulse_p2_rx),
.i_fifo_overflow_pulse_p2_rx   (w_fifo_overflow_pulse_p2_rx ), 
.i_fifo_underflow_pulse_p3_rx  (w_fifo_underflow_pulse_p3_rx),
.i_fifo_overflow_pulse_p3_rx   (w_fifo_overflow_pulse_p3_rx ), 
.i_fifo_underflow_pulse_p4_rx  (w_fifo_underflow_pulse_p4_rx),
.i_fifo_overflow_pulse_p4_rx   (w_fifo_overflow_pulse_p4_rx ), 
.i_fifo_underflow_pulse_p5_rx  (w_fifo_underflow_pulse_p5_rx),
.i_fifo_overflow_pulse_p5_rx   (w_fifo_overflow_pulse_p5_rx ), 
.i_fifo_underflow_pulse_p6_rx  (w_fifo_underflow_pulse_p6_rx),
.i_fifo_overflow_pulse_p6_rx   (w_fifo_overflow_pulse_p6_rx ), 
.i_fifo_underflow_pulse_p7_rx  (w_fifo_underflow_pulse_p7_rx),
.i_fifo_overflow_pulse_p7_rx   (w_fifo_overflow_pulse_p7_rx ), 

.i_fifo_overflow_pulse_host_tx(w_fifo_overflow_pulse_host_tx),
.i_fifo_overflow_pulse_p0_tx  (w_fifo_overflow_pulse_p0_tx),
.i_fifo_overflow_pulse_p1_tx  (w_fifo_overflow_pulse_p1_tx),
.i_fifo_overflow_pulse_p2_tx  (w_fifo_overflow_pulse_p2_tx),
.i_fifo_overflow_pulse_p3_tx  (w_fifo_overflow_pulse_p3_tx),
.i_fifo_overflow_pulse_p4_tx  (w_fifo_overflow_pulse_p4_tx),
.i_fifo_overflow_pulse_p5_tx  (w_fifo_overflow_pulse_p5_tx),
.i_fifo_overflow_pulse_p6_tx  (w_fifo_overflow_pulse_p6_tx),
.i_fifo_overflow_pulse_p7_tx  (w_fifo_overflow_pulse_p7_tx),

.o_asynfifo_rx_overflow_pulse (asynfifo_rx_overflow_pulse), 
.o_asynfifo_rx_underflow_pulse(asynfifo_rx_underflow_pulse),
.o_asynfifo_tx_overflow_pulse (asynfifo_tx_overflow_pulse )
);

gmii_adapter_top gmii_adapter_top_inst
(                    
.i_gmii_rxclk_p0       (i_gmii_rxclk_p0),
.i_gmii_rxclk_p1       (i_gmii_rxclk_p1),
.i_gmii_rxclk_p2       (i_gmii_rxclk_p2),
.i_gmii_rxclk_p3       (i_gmii_rxclk_p3),
.i_gmii_rxclk_p4       (i_gmii_rxclk_p4),
.i_gmii_rxclk_p5       (i_gmii_rxclk_p5),
.i_gmii_rxclk_p6       (i_gmii_rxclk_p6),
.i_gmii_rxclk_p7       (i_gmii_rxclk_p7),
.i_gmii_rxclk_host     (i_gmii_rxclk_host),
                     
.i_gmii_rst_n_p0       (w_gmii_rst_n_p0),
.i_gmii_rst_n_p1       (w_gmii_rst_n_p1),
.i_gmii_rst_n_p2       (w_gmii_rst_n_p2),
.i_gmii_rst_n_p3       (w_gmii_rst_n_p3),
.i_gmii_rst_n_p4       (w_gmii_rst_n_p4),
.i_gmii_rst_n_p5       (w_gmii_rst_n_p5),
.i_gmii_rst_n_p6       (w_gmii_rst_n_p6),
.i_gmii_rst_n_p7       (w_gmii_rst_n_p7),
.i_gmii_rst_n_host     (w_gmii_rst_n_host),

.i_port0_type_sync_tsnchip2adp  (w_port0_type_sync_tsnchip2adp),
.i_port1_type_sync_tsnchip2adp  (w_port1_type_sync_tsnchip2adp),
.i_port2_type_sync_tsnchip2adp  (w_port2_type_sync_tsnchip2adp),
.i_port3_type_sync_tsnchip2adp  (w_port3_type_sync_tsnchip2adp),
.i_port4_type_sync_tsnchip2adp  (w_port4_type_sync_tsnchip2adp),
.i_port5_type_sync_tsnchip2adp  (w_port5_type_sync_tsnchip2adp),
.i_port6_type_sync_tsnchip2adp  (w_port6_type_sync_tsnchip2adp),
.i_port7_type_sync_tsnchip2adp  (w_port7_type_sync_tsnchip2adp),

//port0               
.i_gmii_dv_p0                   (i_gmii_dv_p0   ),
.i_gmii_er_p0                   (i_gmii_er_p0   ),
.iv_gmii_rxd_p0                 (iv_gmii_rxd_p0 ),
.o_gmii_tx_en_p0                (o_gmii_tx_en_p0),
.o_gmii_tx_er_p0                (o_gmii_tx_er_p0),
.ov_gmii_txd_p0                 (ov_gmii_txd_p0 ),
    
.i_gmii_tx_en_p0_tsnchip2adp    (w_gmii_tx_en_p0_tsnchip2adp),
.i_gmii_tx_er_p0_tsnchip2adp    (w_gmii_tx_er_p0_tsnchip2adp),
.iv_gmii_txd_p0_tsnchip2adp     (wv_gmii_txd_p0_tsnchip2adp ),
.o_gmii_dv_p0_adp2tsnchip       (w_gmii_dv_p0_adp2tsnchip   ),
.o_gmii_er_p0_adp2tsnchip       (w_gmii_er_p0_adp2tsnchip   ),
.ov_gmii_rxd_p0_adp2tsnchip     (wv_gmii_rxd_p0_adp2tsnchip ),
    
//port1                         
.i_gmii_dv_p1                   (i_gmii_dv_p1   ),
.i_gmii_er_p1                   (i_gmii_er_p1   ),
.iv_gmii_rxd_p1                 (iv_gmii_rxd_p1 ),
.o_gmii_tx_en_p1                (o_gmii_tx_en_p1),
.o_gmii_tx_er_p1                (o_gmii_tx_er_p1),
.ov_gmii_txd_p1                 (ov_gmii_txd_p1 ),
                                
.i_gmii_tx_en_p1_tsnchip2adp    (w_gmii_tx_en_p1_tsnchip2adp),
.i_gmii_tx_er_p1_tsnchip2adp    (w_gmii_tx_er_p1_tsnchip2adp),
.iv_gmii_txd_p1_tsnchip2adp     (wv_gmii_txd_p1_tsnchip2adp ),
.o_gmii_dv_p1_adp2tsnchip       (w_gmii_dv_p1_adp2tsnchip   ),
.o_gmii_er_p1_adp2tsnchip       (w_gmii_er_p1_adp2tsnchip   ),
.ov_gmii_rxd_p1_adp2tsnchip     (wv_gmii_rxd_p1_adp2tsnchip ),

//port2             
.i_gmii_dv_p2                   (i_gmii_dv_p2   ),
.i_gmii_er_p2                   (i_gmii_er_p2   ),
.iv_gmii_rxd_p2                 (iv_gmii_rxd_p2 ),
.o_gmii_tx_en_p2                (o_gmii_tx_en_p2),
.o_gmii_tx_er_p2                (o_gmii_tx_er_p2),
.ov_gmii_txd_p2                 (ov_gmii_txd_p2 ),
                                
.i_gmii_tx_en_p2_tsnchip2adp    (w_gmii_tx_en_p2_tsnchip2adp),
.i_gmii_tx_er_p2_tsnchip2adp    (w_gmii_tx_er_p2_tsnchip2adp),
.iv_gmii_txd_p2_tsnchip2adp     (wv_gmii_txd_p2_tsnchip2adp ),
.o_gmii_dv_p2_adp2tsnchip       (w_gmii_dv_p2_adp2tsnchip   ),
.o_gmii_er_p2_adp2tsnchip       (w_gmii_er_p2_adp2tsnchip   ),
.ov_gmii_rxd_p2_adp2tsnchip     (wv_gmii_rxd_p2_adp2tsnchip ),
 
//port3   
.i_gmii_dv_p3                   (i_gmii_dv_p3   ),
.i_gmii_er_p3                   (i_gmii_er_p3   ),
.iv_gmii_rxd_p3                 (iv_gmii_rxd_p3 ),
.o_gmii_tx_en_p3                (o_gmii_tx_en_p3),
.o_gmii_tx_er_p3                (o_gmii_tx_er_p3),
.ov_gmii_txd_p3                 (ov_gmii_txd_p3 ),
                                
.i_gmii_tx_en_p3_tsnchip2adp    (w_gmii_tx_en_p3_tsnchip2adp),
.i_gmii_tx_er_p3_tsnchip2adp    (w_gmii_tx_er_p3_tsnchip2adp),
.iv_gmii_txd_p3_tsnchip2adp     (wv_gmii_txd_p3_tsnchip2adp ),
.o_gmii_dv_p3_adp2tsnchip       (w_gmii_dv_p3_adp2tsnchip   ),
.o_gmii_er_p3_adp2tsnchip       (w_gmii_er_p3_adp2tsnchip   ),
.ov_gmii_rxd_p3_adp2tsnchip     (wv_gmii_rxd_p3_adp2tsnchip ),

//port4   
.i_gmii_dv_p4                   (i_gmii_dv_p4   ),
.i_gmii_er_p4                   (i_gmii_er_p4   ),
.iv_gmii_rxd_p4                 (iv_gmii_rxd_p4 ),
.o_gmii_tx_en_p4                (o_gmii_tx_en_p4),
.o_gmii_tx_er_p4                (o_gmii_tx_er_p4),
.ov_gmii_txd_p4                 (ov_gmii_txd_p4 ),
                                
.i_gmii_tx_en_p4_tsnchip2adp    (w_gmii_tx_en_p4_tsnchip2adp),
.i_gmii_tx_er_p4_tsnchip2adp    (w_gmii_tx_er_p4_tsnchip2adp),
.iv_gmii_txd_p4_tsnchip2adp     (wv_gmii_txd_p4_tsnchip2adp ),
.o_gmii_dv_p4_adp2tsnchip       (w_gmii_dv_p4_adp2tsnchip   ),
.o_gmii_er_p4_adp2tsnchip       (w_gmii_er_p4_adp2tsnchip   ),
.ov_gmii_rxd_p4_adp2tsnchip     (wv_gmii_rxd_p4_adp2tsnchip ),

//port5   
.i_gmii_dv_p5                   (i_gmii_dv_p5   ),
.i_gmii_er_p5                   (i_gmii_er_p5   ),
.iv_gmii_rxd_p5                 (iv_gmii_rxd_p5 ),
.o_gmii_tx_en_p5                (o_gmii_tx_en_p5),
.o_gmii_tx_er_p5                (o_gmii_tx_er_p5),
.ov_gmii_txd_p5                 (ov_gmii_txd_p5 ),
                                
.i_gmii_tx_en_p5_tsnchip2adp    (w_gmii_tx_en_p5_tsnchip2adp),
.i_gmii_tx_er_p5_tsnchip2adp    (w_gmii_tx_er_p5_tsnchip2adp),
.iv_gmii_txd_p5_tsnchip2adp     (wv_gmii_txd_p5_tsnchip2adp ),
.o_gmii_dv_p5_adp2tsnchip       (w_gmii_dv_p5_adp2tsnchip   ),
.o_gmii_er_p5_adp2tsnchip       (w_gmii_er_p5_adp2tsnchip   ),
.ov_gmii_rxd_p5_adp2tsnchip     (wv_gmii_rxd_p5_adp2tsnchip ),

//port6  
.i_gmii_dv_p6                   (i_gmii_dv_p6   ),
.i_gmii_er_p6                   (i_gmii_er_p6   ),
.iv_gmii_rxd_p6                 (iv_gmii_rxd_p6 ),
.o_gmii_tx_en_p6                (o_gmii_tx_en_p6),
.o_gmii_tx_er_p6                (o_gmii_tx_er_p6),
.ov_gmii_txd_p6                 (ov_gmii_txd_p6 ),
                                
.i_gmii_tx_en_p6_tsnchip2adp    (w_gmii_tx_en_p6_tsnchip2adp),
.i_gmii_tx_er_p6_tsnchip2adp    (w_gmii_tx_er_p6_tsnchip2adp),
.iv_gmii_txd_p6_tsnchip2adp     (wv_gmii_txd_p6_tsnchip2adp ),
.o_gmii_dv_p6_adp2tsnchip       (w_gmii_dv_p6_adp2tsnchip   ),
.o_gmii_er_p6_adp2tsnchip       (w_gmii_er_p6_adp2tsnchip   ),
.ov_gmii_rxd_p6_adp2tsnchip     (wv_gmii_rxd_p6_adp2tsnchip ),

//port7   
.i_gmii_dv_p7                   (i_gmii_dv_p7   ),
.i_gmii_er_p7                   (i_gmii_er_p7   ),
.iv_gmii_rxd_p7                 (iv_gmii_rxd_p7 ),
.o_gmii_tx_en_p7                (o_gmii_tx_en_p7),
.o_gmii_tx_er_p7                (o_gmii_tx_er_p7),
.ov_gmii_txd_p7                 (ov_gmii_txd_p7 ),
                                
.i_gmii_tx_en_p7_tsnchip2adp    (w_gmii_tx_en_p7_tsnchip2adp),
.i_gmii_tx_er_p7_tsnchip2adp    (w_gmii_tx_er_p7_tsnchip2adp),
.iv_gmii_txd_p7_tsnchip2adp     (wv_gmii_txd_p7_tsnchip2adp ),
.o_gmii_dv_p7_adp2tsnchip       (w_gmii_dv_p7_adp2tsnchip   ),
.o_gmii_er_p7_adp2tsnchip       (w_gmii_er_p7_adp2tsnchip   ),
.ov_gmii_rxd_p7_adp2tsnchip     (wv_gmii_rxd_p7_adp2tsnchip ),
   
//port host     
.i_gmii_dv_host                 (i_gmii_dv_host   ),
.i_gmii_er_host                 (i_gmii_er_host   ),
.iv_gmii_rxd_host               (iv_gmii_rxd_host ),
.o_gmii_tx_en_host              (o_gmii_tx_en_host),
.o_gmii_tx_er_host              (o_gmii_tx_er_host),
.ov_gmii_txd_host               (ov_gmii_txd_host ),
                                
.i_gmii_tx_en_host_tsnchip2adp  (w_gmii_tx_en_host_tsnchip2adp),
.i_gmii_tx_er_host_tsnchip2adp  (w_gmii_tx_er_host_tsnchip2adp),
.iv_gmii_txd_host_tsnchip2adp   (wv_gmii_txd_host_tsnchip2adp ),
.o_gmii_dv_host_adp2tsnchip     (w_gmii_dv_host_adp2tsnchip   ),
.o_gmii_er_host_adp2tsnchip     (w_gmii_er_host_adp2tsnchip   ),
.ov_gmii_rxd_host_adp2tsnchip   (wv_gmii_rxd_host_adp2tsnchip ) 
);

TSNSwitch TSNSwitch_inst(

.i_clk(i_clk),
.i_rst_n(w_core_rst_n),

.port_type_tsnchip2adp(wv_port_type_tsnchip2adp),
.pluse_s(pluse_s),
//.o_init_led(o_init_led),
.o_fifo_overflow_pulse_host_rx         (w_fifo_overflow_pulse_host_rx ), 
.o_fifo_underflow_pulse_host_rx        (w_fifo_underflow_pulse_host_rx),    
.o_fifo_underflow_pulse_p0_rx          (w_fifo_underflow_pulse_p0_rx),
.o_fifo_overflow_pulse_p0_rx           (w_fifo_overflow_pulse_p0_rx ),
.o_fifo_underflow_pulse_p1_rx          (w_fifo_underflow_pulse_p1_rx),
.o_fifo_overflow_pulse_p1_rx           (w_fifo_overflow_pulse_p1_rx ),
.o_fifo_underflow_pulse_p2_rx          (w_fifo_underflow_pulse_p2_rx),
.o_fifo_overflow_pulse_p2_rx           (w_fifo_overflow_pulse_p2_rx ),
.o_fifo_underflow_pulse_p3_rx          (w_fifo_underflow_pulse_p3_rx),
.o_fifo_overflow_pulse_p3_rx           (w_fifo_overflow_pulse_p3_rx ),
.o_fifo_underflow_pulse_p4_rx          (w_fifo_underflow_pulse_p4_rx),
.o_fifo_overflow_pulse_p4_rx           (w_fifo_overflow_pulse_p4_rx ),
.o_fifo_underflow_pulse_p5_rx          (w_fifo_underflow_pulse_p5_rx),
.o_fifo_overflow_pulse_p5_rx           (w_fifo_overflow_pulse_p5_rx ),
.o_fifo_underflow_pulse_p6_rx          (w_fifo_underflow_pulse_p6_rx),
.o_fifo_overflow_pulse_p6_rx           (w_fifo_overflow_pulse_p6_rx ),
.o_fifo_underflow_pulse_p7_rx          (w_fifo_underflow_pulse_p7_rx),
.o_fifo_overflow_pulse_p7_rx           (w_fifo_overflow_pulse_p7_rx ),

.o_fifo_overflow_pulse_host_tx         (w_fifo_overflow_pulse_host_tx),
.o_fifo_overflow_pulse_p0_tx           (w_fifo_overflow_pulse_p0_tx  ),
.o_fifo_overflow_pulse_p1_tx           (w_fifo_overflow_pulse_p1_tx  ),
.o_fifo_overflow_pulse_p2_tx           (w_fifo_overflow_pulse_p2_tx  ),
.o_fifo_overflow_pulse_p3_tx           (w_fifo_overflow_pulse_p3_tx  ),
.o_fifo_overflow_pulse_p4_tx           (w_fifo_overflow_pulse_p4_tx  ),
.o_fifo_overflow_pulse_p5_tx           (w_fifo_overflow_pulse_p5_tx  ),
.o_fifo_overflow_pulse_p6_tx           (w_fifo_overflow_pulse_p6_tx  ),
.o_fifo_overflow_pulse_p7_tx           (w_fifo_overflow_pulse_p7_tx  ),

.ov_gmii_txd_p0  (wv_gmii_txd_p0_tsnchip2adp),
.o_gmii_tx_en_p0 (w_gmii_tx_en_p0_tsnchip2adp),
.o_gmii_tx_er_p0 (w_gmii_tx_er_p0_tsnchip2adp),
.o_gmii_tx_clk_p0(o_gmii_tx_clk_p0),

.ov_gmii_txd_p1    (wv_gmii_txd_p1_tsnchip2adp),
.o_gmii_tx_en_p1   (w_gmii_tx_en_p1_tsnchip2adp),
.o_gmii_tx_er_p1   (w_gmii_tx_er_p1_tsnchip2adp),
.o_gmii_tx_clk_p1  (o_gmii_tx_clk_p1),

.ov_gmii_txd_p2    (wv_gmii_txd_p2_tsnchip2adp),
.o_gmii_tx_en_p2   (w_gmii_tx_en_p2_tsnchip2adp),
.o_gmii_tx_er_p2   (w_gmii_tx_er_p2_tsnchip2adp),
.o_gmii_tx_clk_p2  (o_gmii_tx_clk_p2),

.ov_gmii_txd_p3    (wv_gmii_txd_p3_tsnchip2adp),
.o_gmii_tx_en_p3   (w_gmii_tx_en_p3_tsnchip2adp),
.o_gmii_tx_er_p3   (w_gmii_tx_er_p3_tsnchip2adp),
.o_gmii_tx_clk_p3  (o_gmii_tx_clk_p3),

.ov_gmii_txd_p4    (wv_gmii_txd_p4_tsnchip2adp),
.o_gmii_tx_en_p4   (w_gmii_tx_en_p4_tsnchip2adp),
.o_gmii_tx_er_p4   (w_gmii_tx_er_p4_tsnchip2adp),
.o_gmii_tx_clk_p4  (o_gmii_tx_clk_p4),

.ov_gmii_txd_p5    (wv_gmii_txd_p5_tsnchip2adp),  
.o_gmii_tx_en_p5   (w_gmii_tx_en_p5_tsnchip2adp),
.o_gmii_tx_er_p5   (w_gmii_tx_er_p5_tsnchip2adp),
.o_gmii_tx_clk_p5  (o_gmii_tx_clk_p5),

.ov_gmii_txd_p6    (wv_gmii_txd_p6_tsnchip2adp),
.o_gmii_tx_en_p6   (w_gmii_tx_en_p6_tsnchip2adp),
.o_gmii_tx_er_p6   (w_gmii_tx_er_p6_tsnchip2adp),
.o_gmii_tx_clk_p6  (o_gmii_tx_clk_p6),

.ov_gmii_txd_p7    (wv_gmii_txd_p7_tsnchip2adp),
.o_gmii_tx_en_p7   (w_gmii_tx_en_p7_tsnchip2adp),
.o_gmii_tx_er_p7   (w_gmii_tx_er_p7_tsnchip2adp),
.o_gmii_tx_clk_p7  (o_gmii_tx_clk_p7),

//Network input top module
.i_gmii_rst_n_p0   (w_gmii_rst_n_p0),
.i_gmii_rst_n_p1   (w_gmii_rst_n_p1),
.i_gmii_rst_n_p2   (w_gmii_rst_n_p2),
.i_gmii_rst_n_p3   (w_gmii_rst_n_p3),
.i_gmii_rst_n_p4   (w_gmii_rst_n_p4),
.i_gmii_rst_n_p5   (w_gmii_rst_n_p5),
.i_gmii_rst_n_p6   (w_gmii_rst_n_p6),
.i_gmii_rst_n_p7   (w_gmii_rst_n_p7),
.i_gmii_rst_n_host (w_gmii_rst_n_host),

.i_gmii_rxclk_p0   (i_gmii_rxclk_p0),
.i_gmii_dv_p0      (w_gmii_dv_p0_adp2tsnchip),
.iv_gmii_rxd_p0    (wv_gmii_rxd_p0_adp2tsnchip), 
.i_gmii_er_p0      (w_gmii_er_p0_adp2tsnchip),
                    
.i_gmii_rxclk_p1   (i_gmii_rxclk_p1),
.i_gmii_dv_p1      (w_gmii_dv_p1_adp2tsnchip),
.iv_gmii_rxd_p1    (wv_gmii_rxd_p1_adp2tsnchip),
.i_gmii_er_p1      (w_gmii_er_p1_adp2tsnchip),
                    
.i_gmii_rxclk_p2   (i_gmii_rxclk_p2),
.i_gmii_dv_p2      (w_gmii_dv_p2_adp2tsnchip),
.iv_gmii_rxd_p2    (wv_gmii_rxd_p2_adp2tsnchip),
.i_gmii_er_p2      (w_gmii_er_p2_adp2tsnchip),
                    
.i_gmii_rxclk_p3   (i_gmii_rxclk_p3),
.i_gmii_dv_p3      (w_gmii_dv_p3_adp2tsnchip),
.iv_gmii_rxd_p3    (wv_gmii_rxd_p3_adp2tsnchip),
.i_gmii_er_p3      (w_gmii_er_p3_adp2tsnchip),
                    
.i_gmii_rxclk_p4   (i_gmii_rxclk_p4),
.i_gmii_dv_p4      (w_gmii_dv_p4_adp2tsnchip),
.iv_gmii_rxd_p4    (wv_gmii_rxd_p4_adp2tsnchip),
.i_gmii_er_p4      (w_gmii_er_p4_adp2tsnchip),
                    
.i_gmii_rxclk_p5   (i_gmii_rxclk_p5),
.i_gmii_dv_p5      (w_gmii_dv_p5_adp2tsnchip),
.iv_gmii_rxd_p5    (wv_gmii_rxd_p5_adp2tsnchip),
.i_gmii_er_p5      (w_gmii_er_p5_adp2tsnchip),
                    
.i_gmii_rxclk_p6   (i_gmii_rxclk_p6),
.i_gmii_dv_p6      (w_gmii_dv_p6_adp2tsnchip),
.iv_gmii_rxd_p6    (wv_gmii_rxd_p6_adp2tsnchip),
.i_gmii_er_p6      (w_gmii_er_p6_adp2tsnchip),
                    
.i_gmii_rxclk_p7   (i_gmii_rxclk_p7),
.i_gmii_dv_p7      (w_gmii_dv_p7_adp2tsnchip),
.iv_gmii_rxd_p7    (wv_gmii_rxd_p7_adp2tsnchip),
.i_gmii_er_p7      (w_gmii_er_p7_adp2tsnchip),
                    
                    
//hrp               
.i_gmii_rxclk_host (i_gmii_rxclk_host),
.i_gmii_dv_host    (w_gmii_dv_host_adp2tsnchip),
.iv_gmii_rxd_host  (wv_gmii_rxd_host_adp2tsnchip),
.i_gmii_er_host    (w_gmii_er_host_adp2tsnchip),

//htp
.ov_gmii_txd_host  (wv_gmii_txd_host_tsnchip2adp),//ov_gmii_txd_p3
.o_gmii_tx_en_host (w_gmii_tx_en_host_tsnchip2adp),
.o_gmii_tx_er_host (w_gmii_tx_er_host_tsnchip2adp),
.o_gmii_tx_clk_host(o_gmii_tx_clk_host) 

);


endmodule



