// Copyright (C) 1953-2020 NUDT
// Verilog module name - tsn_chip_top 
// Version: tsn_chip_top_V1.0
// Created:
//         by - junshuai li (1145331404@qq.com)
//         at - 07.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//		  top of tsn_chip_top of chip
//				 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps



module tsn_chip_top #(parameter tsn_chip_version = 32'h20200905)
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

	   pluse_s,
	   
       o_init_led
     /*   
	   pin_rxd_p0,
       pin_rxd_p1,
       pin_rxd_p2,
	   pin_rxd_p3,
       pin_rxd_host,
       
       pin_txd_p0,
       pin_txd_p1,
       pin_txd_p2,
	   pin_txd_p3,
       pin_txd_host */
);
    
input                   i_clk;					//125Mhz

input                   i_hard_rst_n;
input                   i_button_rst_n;
input                   i_et_resetc_rst_n;
wire					w_rst_n;
assign w_rst_n = i_hard_rst_n & i_button_rst_n & i_et_resetc_rst_n;

output      		 	pluse_s;
output      		 	o_init_led;

//input
input					i_gmii_rxclk_p0;
input					i_gmii_dv_p0;
input		[7:0]		iv_gmii_rxd_p0;
input					i_gmii_er_p0;

input					i_gmii_rxclk_p1;
input					i_gmii_dv_p1;
input		[7:0]		iv_gmii_rxd_p1;
input					i_gmii_er_p1;

input					i_gmii_rxclk_p2;
input					i_gmii_dv_p2;
input		[7:0]		iv_gmii_rxd_p2;
input					i_gmii_er_p2;

input					i_gmii_rxclk_p3;
input					i_gmii_dv_p3;
input		[7:0]		iv_gmii_rxd_p3;
input					i_gmii_er_p3;


input					i_gmii_rxclk_host;
input	  				i_gmii_dv_host;
input		[7:0]	 	iv_gmii_rxd_host;
input					i_gmii_er_host;

//output
output      [7:0] 	  	   ov_gmii_txd_p0;
output      		 	   o_gmii_tx_en_p0;
output      		 	   o_gmii_tx_er_p0;
output      		 	   o_gmii_tx_clk_p0;

output      [7:0] 	  	   ov_gmii_txd_p1;
output      		 	   o_gmii_tx_en_p1;
output      		 	   o_gmii_tx_er_p1;
output      		 	   o_gmii_tx_clk_p1;

output      [7:0] 	  	   ov_gmii_txd_p2;
output      		 	   o_gmii_tx_en_p2;
output      		 	   o_gmii_tx_er_p2;
output      		 	   o_gmii_tx_clk_p2;

output      [7:0] 	  	   ov_gmii_txd_p3;
output      		 	   o_gmii_tx_en_p3;
output      		 	   o_gmii_tx_er_p3;
output      		 	   o_gmii_tx_clk_p3;

output      [7:0] 	  	   ov_gmii_txd_host;
output      		 	   o_gmii_tx_en_host;
output      		 	   o_gmii_tx_er_host;
output      		 	   o_gmii_tx_clk_host;

//adp2tsnchip 
wire					w_gmii_dv_p0_adp2tsnchip;
wire		[7:0]		wv_gmii_rxd_p0_adp2tsnchip;
wire					w_gmii_er_p0_adp2tsnchip;

wire					w_gmii_dv_p1_adp2tsnchip;
wire		[7:0]		wv_gmii_rxd_p1_adp2tsnchip;
wire					w_gmii_er_p1_adp2tsnchip;

wire					w_gmii_dv_p2_adp2tsnchip;
wire		[7:0]		wv_gmii_rxd_p2_adp2tsnchip;
wire					w_gmii_er_p2_adp2tsnchip;

wire					w_gmii_dv_p3_adp2tsnchip;
wire		[7:0]		wv_gmii_rxd_p3_adp2tsnchip;
wire					w_gmii_er_p3_adp2tsnchip;

wire	  				w_gmii_dv_host_adp2tsnchip;
wire		[7:0]	 	wv_gmii_rxd_host_adp2tsnchip;
wire					w_gmii_er_host_adp2tsnchip;

//tsnchip2adp
wire      [7:0] 	   wv_gmii_txd_p0_tsnchip2adp;
wire      		 	   w_gmii_tx_en_p0_tsnchip2adp;
wire      		 	   w_gmii_tx_er_p0_tsnchip2adp;
wire      		 	   w_gmii_tx_clk_p0_tsnchip2adp;

wire      [7:0] 	   wv_gmii_txd_p1_tsnchip2adp;
wire      		 	   w_gmii_tx_en_p1_tsnchip2adp;
wire      		 	   w_gmii_tx_er_p1_tsnchip2adp;
wire      		 	   w_gmii_tx_clk_p1_tsnchip2adp;

wire      [7:0] 	   wv_gmii_txd_p2_tsnchip2adp;
wire      		 	   w_gmii_tx_en_p2_tsnchip2adp;
wire      		 	   w_gmii_tx_er_p2_tsnchip2adp;
wire      		 	   w_gmii_tx_clk_p2_tsnchip2adp;

wire      [7:0] 	   wv_gmii_txd_p3_tsnchip2adp;
wire      		 	   w_gmii_tx_en_p3_tsnchip2adp;
wire      		 	   w_gmii_tx_er_p3_tsnchip2adp;
wire      		 	   w_gmii_tx_clk_p3_tsnchip2adp;

wire      [7:0] 	   wv_gmii_txd_host_tsnchip2adp;
wire      		 	   w_gmii_tx_en_host_tsnchip2adp;
wire      		 	   w_gmii_tx_er_host_tsnchip2adp;
wire      		 	   w_gmii_tx_clk_host_tsnchip2adp;

wire     [7:0] 		   wv_port_type_tsnchip2adp;
wire     [7:0] 		   wv_port_type_sync_tsnchip2adp;

/* output wire            pin_rxd_p0;
output wire            pin_rxd_p1;
output wire            pin_rxd_p2;
output wire            pin_rxd_p3;
output wire            pin_rxd_host;
       
output wire            pin_txd_p0;
output wire            pin_txd_p1;
output wire            pin_txd_p2;
output wire            pin_txd_p3;
output wire            pin_txd_host; */

//reset sync
wire				   w_core_rst_n;
wire				   w_gmii_rst_n_p0;
wire				   w_gmii_rst_n_p1;
wire				   w_gmii_rst_n_p2;
wire				   w_gmii_rst_n_p3;
wire				   w_gmii_rst_n_host;

reg        [31:0]       rv_tsn_chip_version/*synthesis noprune*/;
always @(posedge i_clk or negedge w_core_rst_n) begin
    if(!w_core_rst_n) begin
        rv_tsn_chip_version <= 32'h0;
    end
    else begin
        rv_tsn_chip_version <= tsn_chip_version;
    end
end

reset_sync core_reset_sync(
.i_clk(i_clk),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_core_rst_n)   
);

reset_sync gmii_p0_reset_sync(
.i_clk(i_gmii_rxclk_p0),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_gmii_rst_n_p0)   
);
signal_sync p0_type_sync(
.i_clk(i_gmii_rxclk_p0),
.i_rst_n(w_gmii_rst_n_p0),
       
.i_signal_async(wv_port_type_tsnchip2adp[0]),
.o_signal_sync(wv_port_type_sync_tsnchip2adp[0])   
);

reset_sync gmii_p1_reset_sync(
.i_clk(i_gmii_rxclk_p1),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_gmii_rst_n_p1)   
);
signal_sync p1_type_sync(
.i_clk(i_gmii_rxclk_p1),
.i_rst_n(w_gmii_rst_n_p1),
       
.i_signal_async(wv_port_type_tsnchip2adp[1]),
.o_signal_sync(wv_port_type_sync_tsnchip2adp[1])   
);

reset_sync gmii_p2_reset_sync(
.i_clk(i_gmii_rxclk_p2),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_gmii_rst_n_p2)   
);
signal_sync p2_type_sync(
.i_clk(i_gmii_rxclk_p2),
.i_rst_n(w_gmii_rst_n_p2),
       
.i_signal_async(wv_port_type_tsnchip2adp[2]),
.o_signal_sync(wv_port_type_sync_tsnchip2adp[2])   
);


reset_sync gmii_p3_reset_sync(
.i_clk(i_gmii_rxclk_p3),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_gmii_rst_n_p3)   
);
signal_sync p3_type_sync(
.i_clk(i_gmii_rxclk_p3),
.i_rst_n(w_gmii_rst_n_p3),
       
.i_signal_async(wv_port_type_tsnchip2adp[3]),
.o_signal_sync(wv_port_type_sync_tsnchip2adp[3])   
);

reset_sync gmii_host_reset_sync(
.i_clk(i_gmii_rxclk_host),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_gmii_rst_n_host)   
);

tsn_chip tsn_chip_inst(

.i_clk(i_clk),
.i_rst_n(w_core_rst_n),

.port_type_tsnchip2adp(wv_port_type_tsnchip2adp),
.pluse_s(pluse_s),
.o_init_led(o_init_led),

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


//Network input top module
.i_gmii_rxclk_p0   (i_gmii_rxclk_p0),
.i_gmii_dv_p0      (w_gmii_dv_p0_adp2tsnchip),
.iv_gmii_rxd_p0    (wv_gmii_rxd_p0_adp2tsnchip), 
.i_gmii_er_p0      (w_gmii_er_p0_adp2tsnchip),
.i_gmii_rst_n_p0   (w_gmii_rst_n_p0),
                    
.i_gmii_rxclk_p1   (i_gmii_rxclk_p1),
.i_gmii_dv_p1      (w_gmii_dv_p1_adp2tsnchip),
.iv_gmii_rxd_p1    (wv_gmii_rxd_p1_adp2tsnchip),
.i_gmii_er_p1      (w_gmii_er_p1_adp2tsnchip),
.i_gmii_rst_n_p1   (w_gmii_rst_n_p1),
                  
.i_gmii_rxclk_p2   (i_gmii_rxclk_p2),
.i_gmii_dv_p2      (w_gmii_dv_p2_adp2tsnchip),
.iv_gmii_rxd_p2    (wv_gmii_rxd_p2_adp2tsnchip),
.i_gmii_er_p2      (w_gmii_er_p2_adp2tsnchip),
.i_gmii_rst_n_p2   (w_gmii_rst_n_p2), 

.i_gmii_rxclk_p3   (i_gmii_rxclk_p3),
.i_gmii_dv_p3      (w_gmii_dv_p3_adp2tsnchip),
.iv_gmii_rxd_p3    (wv_gmii_rxd_p3_adp2tsnchip),
.i_gmii_er_p3      (w_gmii_er_p3_adp2tsnchip),
.i_gmii_rst_n_p3   (w_gmii_rst_n_p3),                                     
//hrp               
.i_gmii_rxclk_host (i_gmii_rxclk_host),
.i_gmii_dv_host    (w_gmii_dv_host_adp2tsnchip),
.iv_gmii_rxd_host  (wv_gmii_rxd_host_adp2tsnchip),
.i_gmii_er_host    (w_gmii_er_host_adp2tsnchip),
.i_gmii_rst_n_host (w_gmii_rst_n_host),

//htp
.ov_gmii_txd_host  (wv_gmii_txd_host_tsnchip2adp),//ov_gmii_txd_p3
.o_gmii_tx_en_host (w_gmii_tx_en_host_tsnchip2adp),
.o_gmii_tx_er_host (w_gmii_tx_er_host_tsnchip2adp),
.o_gmii_tx_clk_host(o_gmii_tx_clk_host) 
);



gmii_adapter gmii_adapter_p0(


.gmii_rxclk(i_gmii_rxclk_p0),
.gmii_txclk(o_gmii_tx_clk_p0),

.rst_n(w_gmii_rst_n_p0),

.port_type(wv_port_type_sync_tsnchip2adp[0]),

.gmii_rx_dv(i_gmii_dv_p0),
.gmii_rx_er(i_gmii_er_p0),
.gmii_rxd  (iv_gmii_rxd_p0),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_p0_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_p0_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (wv_gmii_rxd_p0_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p0),
.gmii_tx_er(o_gmii_tx_er_p0),
.gmii_txd  (ov_gmii_txd_p0),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_p0_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_p0_tsnchip2adp),
.gmii_txd_tsnchip2adp  (wv_gmii_txd_p0_tsnchip2adp)

/* .pin_rxd(pin_rxd_p0),
.pin_txd(pin_txd_p0) */

);

gmii_adapter gmii_adapter_p1(


.gmii_rxclk(i_gmii_rxclk_p1),
.gmii_txclk(o_gmii_tx_clk_p1),

.rst_n(w_gmii_rst_n_p1),

.port_type(wv_port_type_sync_tsnchip2adp[1]),

.gmii_rx_dv(i_gmii_dv_p1),
.gmii_rx_er(i_gmii_er_p1),
.gmii_rxd  (iv_gmii_rxd_p1),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_p1_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_p1_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (wv_gmii_rxd_p1_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p1),
.gmii_tx_er(o_gmii_tx_er_p1),
.gmii_txd  (ov_gmii_txd_p1),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_p1_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_p1_tsnchip2adp),
.gmii_txd_tsnchip2adp  (wv_gmii_txd_p1_tsnchip2adp)

/* .pin_rxd(pin_rxd_p1),
.pin_txd(pin_txd_p1) */

);

gmii_adapter gmii_adapter_p2(


.gmii_rxclk(i_gmii_rxclk_p2),
.gmii_txclk(o_gmii_tx_clk_p2),

.rst_n(w_gmii_rst_n_p2),

.port_type(wv_port_type_sync_tsnchip2adp[2]),

.gmii_rx_dv(i_gmii_dv_p2),
.gmii_rx_er(i_gmii_er_p2),
.gmii_rxd  (iv_gmii_rxd_p2),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_p2_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_p2_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (wv_gmii_rxd_p2_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p2),
.gmii_tx_er(o_gmii_tx_er_p2),
.gmii_txd  (ov_gmii_txd_p2),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_p2_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_p2_tsnchip2adp),
.gmii_txd_tsnchip2adp  (wv_gmii_txd_p2_tsnchip2adp)

/* .pin_rxd(pin_rxd_p2),
.pin_txd(pin_txd_p2) */

);

gmii_adapter gmii_adapter_p3(


.gmii_rxclk(i_gmii_rxclk_p3),
.gmii_txclk(o_gmii_tx_clk_p3),

.rst_n(w_gmii_rst_n_p3),

.port_type(wv_port_type_sync_tsnchip2adp[3]),

.gmii_rx_dv(i_gmii_dv_p3),
.gmii_rx_er(i_gmii_er_p3),
.gmii_rxd  (iv_gmii_rxd_p3),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_p3_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_p3_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (wv_gmii_rxd_p3_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p3),
.gmii_tx_er(o_gmii_tx_er_p3),
.gmii_txd  (ov_gmii_txd_p3),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_p3_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_p3_tsnchip2adp),
.gmii_txd_tsnchip2adp  (wv_gmii_txd_p3_tsnchip2adp)
/* 
.pin_rxd(pin_rxd_p3),
.pin_txd(pin_txd_p3)
 */
);

 gmii_adapter_host gmii_adapter_host(


.gmii_rxclk(i_gmii_rxclk_host),
.gmii_txclk(o_gmii_tx_clk_host),

.rst_n(w_gmii_rst_n_host),

.port_type(1'b0),

.gmii_rx_dv(i_gmii_dv_host),
.gmii_rx_er(i_gmii_er_host),
.gmii_rxd  (iv_gmii_rxd_host),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_host_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_host_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (wv_gmii_rxd_host_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_host),
.gmii_tx_er(o_gmii_tx_er_host),
.gmii_txd  (ov_gmii_txd_host),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_host_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_host_tsnchip2adp),
.gmii_txd_tsnchip2adp  (wv_gmii_txd_host_tsnchip2adp)
); 
 
endmodule



