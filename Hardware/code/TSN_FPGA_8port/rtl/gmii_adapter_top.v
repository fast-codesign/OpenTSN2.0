// Copyright (C) 1953-2020 NUDT
// Verilog module name - gmii_adapter_top 
// Version: GAD_TOP_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//        top of gmii_adapter
//               
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module gmii_adapter_top
(
    i_gmii_rxclk_p0,
    i_gmii_rxclk_p1,
    i_gmii_rxclk_p2,
    i_gmii_rxclk_p3,
    i_gmii_rxclk_p4,
    i_gmii_rxclk_p5,
    i_gmii_rxclk_p6,
    i_gmii_rxclk_p7,
    i_gmii_rxclk_host,
    
    i_gmii_rst_n_p0,
    i_gmii_rst_n_p1,
    i_gmii_rst_n_p2,
    i_gmii_rst_n_p3,
    i_gmii_rst_n_p4,
    i_gmii_rst_n_p5,
    i_gmii_rst_n_p6,
    i_gmii_rst_n_p7,
    i_gmii_rst_n_host,

    i_port0_type_sync_tsnchip2adp,
    i_port1_type_sync_tsnchip2adp,
    i_port2_type_sync_tsnchip2adp,
    i_port3_type_sync_tsnchip2adp,
    i_port4_type_sync_tsnchip2adp,
    i_port5_type_sync_tsnchip2adp,
    i_port6_type_sync_tsnchip2adp,
    i_port7_type_sync_tsnchip2adp,

//port0    
    i_gmii_dv_p0,
    i_gmii_er_p0,
    iv_gmii_rxd_p0,
    o_gmii_tx_en_p0,
    o_gmii_tx_er_p0,
    ov_gmii_txd_p0,
    
    i_gmii_tx_en_p0_tsnchip2adp,
    i_gmii_tx_er_p0_tsnchip2adp,
    iv_gmii_txd_p0_tsnchip2adp,
    o_gmii_dv_p0_adp2tsnchip,
    o_gmii_er_p0_adp2tsnchip,
    ov_gmii_rxd_p0_adp2tsnchip,
    
//port1    
    i_gmii_dv_p1,
    i_gmii_er_p1,
    iv_gmii_rxd_p1,
    o_gmii_tx_en_p1,
    o_gmii_tx_er_p1,
    ov_gmii_txd_p1,
        
    i_gmii_tx_en_p1_tsnchip2adp,
    i_gmii_tx_er_p1_tsnchip2adp,
    iv_gmii_txd_p1_tsnchip2adp,
    o_gmii_dv_p1_adp2tsnchip,
    o_gmii_er_p1_adp2tsnchip,
    ov_gmii_rxd_p1_adp2tsnchip,

//port2   
    i_gmii_dv_p2,
    i_gmii_er_p2,
    iv_gmii_rxd_p2,
    o_gmii_tx_en_p2,
    o_gmii_tx_er_p2,
    ov_gmii_txd_p2,
        
    i_gmii_tx_en_p2_tsnchip2adp,
    i_gmii_tx_er_p2_tsnchip2adp,
    iv_gmii_txd_p2_tsnchip2adp,
    o_gmii_dv_p2_adp2tsnchip,
    o_gmii_er_p2_adp2tsnchip,
    ov_gmii_rxd_p2_adp2tsnchip,
 
//port3   
    i_gmii_dv_p3,
    i_gmii_er_p3,
    iv_gmii_rxd_p3,
    o_gmii_tx_en_p3,
    o_gmii_tx_er_p3,
    ov_gmii_txd_p3,
        
    i_gmii_tx_en_p3_tsnchip2adp,
    i_gmii_tx_er_p3_tsnchip2adp,
    iv_gmii_txd_p3_tsnchip2adp,
    o_gmii_dv_p3_adp2tsnchip,
    o_gmii_er_p3_adp2tsnchip,
    ov_gmii_rxd_p3_adp2tsnchip,

//port4   
    i_gmii_dv_p4,
    i_gmii_er_p4,
    iv_gmii_rxd_p4,
    o_gmii_tx_en_p4,
    o_gmii_tx_er_p4,
    ov_gmii_txd_p4,
        
    i_gmii_tx_en_p4_tsnchip2adp,
    i_gmii_tx_er_p4_tsnchip2adp,
    iv_gmii_txd_p4_tsnchip2adp,
    o_gmii_dv_p4_adp2tsnchip,
    o_gmii_er_p4_adp2tsnchip,
    ov_gmii_rxd_p4_adp2tsnchip,

//port5   
    i_gmii_dv_p5,
    i_gmii_er_p5,
    iv_gmii_rxd_p5,
    o_gmii_tx_en_p5,
    o_gmii_tx_er_p5,
    ov_gmii_txd_p5,
        
    i_gmii_tx_en_p5_tsnchip2adp,
    i_gmii_tx_er_p5_tsnchip2adp,
    iv_gmii_txd_p5_tsnchip2adp,
    o_gmii_dv_p5_adp2tsnchip,
    o_gmii_er_p5_adp2tsnchip,
    ov_gmii_rxd_p5_adp2tsnchip,

//port6  
    i_gmii_dv_p6,
    i_gmii_er_p6,
    iv_gmii_rxd_p6,
    o_gmii_tx_en_p6,
    o_gmii_tx_er_p6,
    ov_gmii_txd_p6,
        
    i_gmii_tx_en_p6_tsnchip2adp,
    i_gmii_tx_er_p6_tsnchip2adp,
    iv_gmii_txd_p6_tsnchip2adp,
    o_gmii_dv_p6_adp2tsnchip,
    o_gmii_er_p6_adp2tsnchip,
    ov_gmii_rxd_p6_adp2tsnchip,

//port7   
    i_gmii_dv_p7,
    i_gmii_er_p7,
    iv_gmii_rxd_p7,
    o_gmii_tx_en_p7,
    o_gmii_tx_er_p7,
    ov_gmii_txd_p7,
        
    i_gmii_tx_en_p7_tsnchip2adp,
    i_gmii_tx_er_p7_tsnchip2adp,
    iv_gmii_txd_p7_tsnchip2adp,
    o_gmii_dv_p7_adp2tsnchip,
    o_gmii_er_p7_adp2tsnchip,
    ov_gmii_rxd_p7_adp2tsnchip,    
    
    
//port host  
    i_gmii_dv_host,
    i_gmii_er_host,
    iv_gmii_rxd_host,
    o_gmii_tx_en_host,
    o_gmii_tx_er_host,
    ov_gmii_txd_host,
        
    i_gmii_tx_en_host_tsnchip2adp,
    i_gmii_tx_er_host_tsnchip2adp,
    iv_gmii_txd_host_tsnchip2adp,
    o_gmii_dv_host_adp2tsnchip,
    o_gmii_er_host_adp2tsnchip,
    ov_gmii_rxd_host_adp2tsnchip 
   
);

//I/O
input                   i_gmii_rxclk_p0;
input                   i_gmii_rxclk_p1;
input                   i_gmii_rxclk_p2;
input                   i_gmii_rxclk_p3;
input                   i_gmii_rxclk_p4;
input                   i_gmii_rxclk_p5;
input                   i_gmii_rxclk_p6;
input                   i_gmii_rxclk_p7;
input                   i_gmii_rxclk_host;

input                   i_gmii_rst_n_p0;
input                   i_gmii_rst_n_p1;
input                   i_gmii_rst_n_p2;
input                   i_gmii_rst_n_p3;
input                   i_gmii_rst_n_p4;
input                   i_gmii_rst_n_p5;
input                   i_gmii_rst_n_p6;
input                   i_gmii_rst_n_p7;
input                   i_gmii_rst_n_host;

input                   i_port0_type_sync_tsnchip2adp;
input                   i_port1_type_sync_tsnchip2adp;
input                   i_port2_type_sync_tsnchip2adp;
input                   i_port3_type_sync_tsnchip2adp;
input                   i_port4_type_sync_tsnchip2adp;
input                   i_port5_type_sync_tsnchip2adp;
input                   i_port6_type_sync_tsnchip2adp;
input                   i_port7_type_sync_tsnchip2adp;
                                                     
//port0    
input                   i_gmii_dv_p0;
input                   i_gmii_er_p0;
input      [7:0]        iv_gmii_rxd_p0;
output                  o_gmii_tx_en_p0;
output                  o_gmii_tx_er_p0;
output     [7:0]        ov_gmii_txd_p0;
    
input                   i_gmii_tx_en_p0_tsnchip2adp;
input                   i_gmii_tx_er_p0_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p0_tsnchip2adp;
output                  o_gmii_dv_p0_adp2tsnchip;
output                  o_gmii_er_p0_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p0_adp2tsnchip;
    
//port1    
input                   i_gmii_dv_p1;
input                   i_gmii_er_p1;
input      [7:0]        iv_gmii_rxd_p1;
output                  o_gmii_tx_en_p1;
output                  o_gmii_tx_er_p1;
output     [7:0]        ov_gmii_txd_p1;
        
input                   i_gmii_tx_en_p1_tsnchip2adp;
input                   i_gmii_tx_er_p1_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p1_tsnchip2adp;
output                  o_gmii_dv_p1_adp2tsnchip;
output                  o_gmii_er_p1_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p1_adp2tsnchip;

//port2   
input                   i_gmii_dv_p2;
input                   i_gmii_er_p2;
input      [7:0]        iv_gmii_rxd_p2;
output                  o_gmii_tx_en_p2;
output                  o_gmii_tx_er_p2;
output     [7:0]        ov_gmii_txd_p2;
        
input                   i_gmii_tx_en_p2_tsnchip2adp;
input                   i_gmii_tx_er_p2_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p2_tsnchip2adp;
output                  o_gmii_dv_p2_adp2tsnchip;
output                  o_gmii_er_p2_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p2_adp2tsnchip;
 
//port3   
input                   i_gmii_dv_p3;
input                   i_gmii_er_p3;
input      [7:0]        iv_gmii_rxd_p3;
output                  o_gmii_tx_en_p3;
output                  o_gmii_tx_er_p3;
output     [7:0]        ov_gmii_txd_p3;
        
input                   i_gmii_tx_en_p3_tsnchip2adp;
input                   i_gmii_tx_er_p3_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p3_tsnchip2adp;
output                  o_gmii_dv_p3_adp2tsnchip;
output                  o_gmii_er_p3_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p3_adp2tsnchip;

//port4   
input                   i_gmii_dv_p4;
input                   i_gmii_er_p4;
input      [7:0]        iv_gmii_rxd_p4;
output                  o_gmii_tx_en_p4;
output                  o_gmii_tx_er_p4;
output     [7:0]        ov_gmii_txd_p4;
        
input                   i_gmii_tx_en_p4_tsnchip2adp;
input                   i_gmii_tx_er_p4_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p4_tsnchip2adp;
output                  o_gmii_dv_p4_adp2tsnchip;
output                  o_gmii_er_p4_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p4_adp2tsnchip;

//port5   
input                   i_gmii_dv_p5;
input                   i_gmii_er_p5;
input      [7:0]        iv_gmii_rxd_p5;
output                  o_gmii_tx_en_p5;
output                  o_gmii_tx_er_p5;
output     [7:0]        ov_gmii_txd_p5;
        
input                   i_gmii_tx_en_p5_tsnchip2adp;
input                   i_gmii_tx_er_p5_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p5_tsnchip2adp;
output                  o_gmii_dv_p5_adp2tsnchip;
output                  o_gmii_er_p5_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p5_adp2tsnchip;

//port6  
input                   i_gmii_dv_p6;
input                   i_gmii_er_p6;
input      [7:0]        iv_gmii_rxd_p6;
output                  o_gmii_tx_en_p6;
output                  o_gmii_tx_er_p6;
output     [7:0]        ov_gmii_txd_p6;
        
input                   i_gmii_tx_en_p6_tsnchip2adp;
input                   i_gmii_tx_er_p6_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p6_tsnchip2adp;
output                  o_gmii_dv_p6_adp2tsnchip;
output                  o_gmii_er_p6_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p6_adp2tsnchip;

//port7   
input                   i_gmii_dv_p7;
input                   i_gmii_er_p7;
input      [7:0]        iv_gmii_rxd_p7;
output                  o_gmii_tx_en_p7;
output                  o_gmii_tx_er_p7;
output     [7:0]        ov_gmii_txd_p7;
        
input                   i_gmii_tx_en_p7_tsnchip2adp;
input                   i_gmii_tx_er_p7_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p7_tsnchip2adp;
output                  o_gmii_dv_p7_adp2tsnchip;
output                  o_gmii_er_p7_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p7_adp2tsnchip;    
    
    
//port host  
input                   i_gmii_dv_host;
input                   i_gmii_er_host;
input      [7:0]        iv_gmii_rxd_host;
output                  o_gmii_tx_en_host;
output                  o_gmii_tx_er_host;
output     [7:0]        ov_gmii_txd_host;
        
input                   i_gmii_tx_en_host_tsnchip2adp;
input                   i_gmii_tx_er_host_tsnchip2adp;
input      [7:0]        iv_gmii_txd_host_tsnchip2adp;
output                  o_gmii_dv_host_adp2tsnchip;
output                  o_gmii_er_host_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_host_adp2tsnchip;


gmii_adapter gmii_adapter_p0(

.gmii_rxclk(i_gmii_rxclk_p0),
.gmii_txclk(i_gmii_rxclk_p0),

.rst_n(i_gmii_rst_n_p0),

.port_type(i_port0_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p0),
.gmii_rx_er(i_gmii_er_p0),
.gmii_rxd  (iv_gmii_rxd_p0),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p0_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p0_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p0_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p0),
.gmii_tx_er(o_gmii_tx_er_p0),
.gmii_txd  (ov_gmii_txd_p0),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p0_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p0_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p0_tsnchip2adp)

);

gmii_adapter gmii_adapter_p1(

.gmii_rxclk(i_gmii_rxclk_p1),
.gmii_txclk(i_gmii_rxclk_p1),

.rst_n(i_gmii_rst_n_p1),

.port_type(i_port1_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p1),
.gmii_rx_er(i_gmii_er_p1),
.gmii_rxd  (iv_gmii_rxd_p1),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p1_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p1_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p1_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p1),
.gmii_tx_er(o_gmii_tx_er_p1),
.gmii_txd  (ov_gmii_txd_p1),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p1_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p1_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p1_tsnchip2adp)

);

gmii_adapter gmii_adapter_p2(

.gmii_rxclk(i_gmii_rxclk_p2),
.gmii_txclk(i_gmii_rxclk_p2),

.rst_n(i_gmii_rst_n_p2),

.port_type(i_port2_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p2),
.gmii_rx_er(i_gmii_er_p2),
.gmii_rxd  (iv_gmii_rxd_p2),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p2_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p2_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p2_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p2),
.gmii_tx_er(o_gmii_tx_er_p2),
.gmii_txd  (ov_gmii_txd_p2),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p2_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p2_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p2_tsnchip2adp)

);

gmii_adapter gmii_adapter_p3(

.gmii_rxclk(i_gmii_rxclk_p3),
.gmii_txclk(i_gmii_rxclk_p3),

.rst_n(i_gmii_rst_n_p3),

.port_type(i_port3_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p3),
.gmii_rx_er(i_gmii_er_p3),
.gmii_rxd  (iv_gmii_rxd_p3),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p3_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p3_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p3_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p3),
.gmii_tx_er(o_gmii_tx_er_p3),
.gmii_txd  (ov_gmii_txd_p3),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p3_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p3_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p3_tsnchip2adp)

);

gmii_adapter gmii_adapter_p4(

.gmii_rxclk(i_gmii_rxclk_p4),
.gmii_txclk(i_gmii_rxclk_p4),

.rst_n(i_gmii_rst_n_p4),

.port_type(i_port4_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p4),
.gmii_rx_er(i_gmii_er_p4),
.gmii_rxd  (iv_gmii_rxd_p4),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p4_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p4_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p4_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p4),
.gmii_tx_er(o_gmii_tx_er_p4),
.gmii_txd  (ov_gmii_txd_p4),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p4_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p4_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p4_tsnchip2adp)

);

gmii_adapter gmii_adapter_p5(

.gmii_rxclk(i_gmii_rxclk_p5),
.gmii_txclk(i_gmii_rxclk_p5),

.rst_n(i_gmii_rst_n_p5),

.port_type(i_port5_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p5),
.gmii_rx_er(i_gmii_er_p5),
.gmii_rxd  (iv_gmii_rxd_p5),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p5_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p5_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p5_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p5),
.gmii_tx_er(o_gmii_tx_er_p5),
.gmii_txd  (ov_gmii_txd_p5),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p5_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p5_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p5_tsnchip2adp)

);

gmii_adapter gmii_adapter_p6(

.gmii_rxclk(i_gmii_rxclk_p6),
.gmii_txclk(i_gmii_rxclk_p6),

.rst_n(i_gmii_rst_n_p6),

.port_type(i_port6_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p6),
.gmii_rx_er(i_gmii_er_p6),
.gmii_rxd  (iv_gmii_rxd_p6),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p6_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p6_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p6_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p6),
.gmii_tx_er(o_gmii_tx_er_p6),
.gmii_txd  (ov_gmii_txd_p6),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p6_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p6_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p6_tsnchip2adp)

);

gmii_adapter gmii_adapter_p7(

.gmii_rxclk(i_gmii_rxclk_p7),
.gmii_txclk(i_gmii_rxclk_p7),

.rst_n(i_gmii_rst_n_p7),

.port_type(i_port7_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p7),
.gmii_rx_er(i_gmii_er_p7),
.gmii_rxd  (iv_gmii_rxd_p7),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p7_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p7_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p7_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p7),
.gmii_tx_er(o_gmii_tx_er_p7),
.gmii_txd  (ov_gmii_txd_p7),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p7_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p7_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p7_tsnchip2adp)

);

gmii_adapter_host gmii_adapter_host(

.gmii_rxclk(i_gmii_rxclk_host),
.gmii_txclk(i_gmii_rxclk_host),

.rst_n(i_gmii_rst_n_host),

.port_type(1'b0),

.gmii_rx_dv(i_gmii_dv_host),
.gmii_rx_er(i_gmii_er_host),
.gmii_rxd  (iv_gmii_rxd_host),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_host_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_host_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_host_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_host),
.gmii_tx_er(o_gmii_tx_er_host),
.gmii_txd  (ov_gmii_txd_host),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_host_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_host_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_host_tsnchip2adp)

);
endmodule