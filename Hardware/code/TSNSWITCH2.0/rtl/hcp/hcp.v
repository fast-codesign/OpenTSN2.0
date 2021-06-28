// Copyright (C) 1953-2020 NUDT
// Verilog module name - HCP
// Version: HCP_V1.0
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         hardware control point
///////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module hcp
(
       i_clk,
       i_rst_n,

	   i_gmii_rxclk,
	   i_gmii_dv,
	   iv_gmii_rxd,
	   i_gmii_er,       
       
	   ov_gmii_txd,
	   o_gmii_tx_en,
	   o_gmii_tx_er,
	   o_gmii_tx_clk       
);

// I/O
// clk & rst
input               i_clk;
input               i_rst_n;  
input				i_gmii_rxclk;
input	  		    i_gmii_dv;
input	[7:0]	 	iv_gmii_rxd;
input			    i_gmii_er;

output  [7:0] 	  	ov_gmii_txd;
output      		o_gmii_tx_en;
output      		o_gmii_tx_er;
output      	    o_gmii_tx_clk;

wire                w_gmii_rst_n;
//gmii_adapter-iip
wire                w_gmii_dv_gad2iip;
wire                w_gmii_er_gad2iip;
wire    [7:0]       wv_gmii_rxd_gad2iip;

//iip-pdm
wire    [133:0]     wv_data_iip2pdm;
wire    	      	w_data_wr_iip2pdm;
wire    [3:0]       wv_chip_pkt_inport_iip2pdm;
//pdm-cim,fnp,lnp
wire   [133:0]      wv_pkt_data_pdm2fnp;
wire                w_pkt_data_wr_pdm2fnp;
wire   [3:0]        wv_pkt_inport_pdm2fnp;
    
wire   [133:0]      wv_pkt_data_pdm2cim;
wire                w_pkt_data_wr_pdm2cim;
wire   [7:0]        wv_chip_port_type_cim2pdm;
wire                w_first_frag_pdm2cim;

wire   [133:0]      wv_pkt_data_pdm2lnp;
wire                w_pkt_data_wr_pdm2lnp;
wire                w_first_frag_pdm2lnp;
wire                w_first_node_notip_discard_pkt_pulse_pdm2cim;
//iip-cim
wire                w_fifo_overflow_pulse_gwr2cim;
wire                w_fifo_underflow_pulse_grd2cim;
wire                w_frc_discard_pkt_pulse;
//cim-lnp  
wire    [70:0]	    wv_regroup_ram_wdata_cim2lnp;
wire       	        w_regroup_ram_wr_cim2lnp;
wire    [7:0]	    wv_regroup_ram_addr_cim2lnp;
wire    [70:0]      wv_regroup_ram_rdata;
wire                w_regroup_ram_rd;

wire                w_initial_finish_lnp2cim;
wire                w_lnp_inpkt_pulse_lnp2cim;
wire                w_lnp_outpkt_pulse_lnp2cim;
wire                w_lnp_flow_table_overflow_pulse_lnp2cim;
//cim-fnp 
wire    [4:0]       wv_frag_ram_addr;
wire    [151:0]     wv_frag_ram_wdata;
wire                w_frag_ram_wr;
wire    [151:0]     wv_frag_ram_rdata;
wire                w_frag_ram_rd;

wire                w_fnp_inpkt_pulse_fnp2cim;
wire                w_fnp_outpkt_pulse_fnp2cim;
wire                w_fnp_fifo_overflow_pulse_fnp2cim;
wire                w_fnp_no_1st_frag_pulse_fnp2cim;
wire                w_fnp_no_not1st_frag_pulse_fnp2cim;
wire                w_fnp_frag_discard_pulse_fnp2cim;

wire                w_fnp_p0_no_1st_frag_pulse_fnp2cim;
wire                w_fnp_p0_no_not1st_frag_pulse_fnp2cim;
wire                w_fnp_p1_no_1st_frag_pulse_fnp2cim;
wire                w_fnp_p1_no_not1st_frag_pulse_fnp2cim;
wire                w_fnp_p2_no_1st_frag_pulse_fnp2cim;
wire                w_fnp_p2_no_not1st_frag_pulse_fnp2cim;
wire                w_fnp_p3_no_1st_frag_pulse_fnp2cim;
wire                w_fnp_p3_no_not1st_frag_pulse_fnp2cim;
wire                w_fnp_p4_no_1st_frag_pulse_fnp2cim;
wire                w_fnp_p4_no_not1st_frag_pulse_fnp2cim;
wire                w_fnp_p5_no_1st_frag_pulse_fnp2cim;
wire                w_fnp_p5_no_not1st_frag_pulse_fnp2cim;
wire                w_fnp_p6_no_1st_frag_pulse_fnp2cim;
wire                w_fnp_p6_no_not1st_frag_pulse_fnp2cim;
wire                w_fnp_p7_no_1st_frag_pulse_fnp2cim;
wire                w_fnp_p7_no_not1st_frag_pulse_fnp2cim;
assign  w_fnp_no_1st_frag_pulse_fnp2cim = w_fnp_p0_no_1st_frag_pulse_fnp2cim | w_fnp_p1_no_1st_frag_pulse_fnp2cim | w_fnp_p2_no_1st_frag_pulse_fnp2cim | w_fnp_p3_no_1st_frag_pulse_fnp2cim | w_fnp_p4_no_1st_frag_pulse_fnp2cim | w_fnp_p5_no_1st_frag_pulse_fnp2cim | w_fnp_p6_no_1st_frag_pulse_fnp2cim | w_fnp_p7_no_1st_frag_pulse_fnp2cim;
assign  w_fnp_no_not1st_frag_pulse_fnp2cim = w_fnp_p0_no_not1st_frag_pulse_fnp2cim | w_fnp_p1_no_not1st_frag_pulse_fnp2cim | w_fnp_p2_no_not1st_frag_pulse_fnp2cim | w_fnp_p3_no_not1st_frag_pulse_fnp2cim | w_fnp_p4_no_not1st_frag_pulse_fnp2cim | w_fnp_p5_no_not1st_frag_pulse_fnp2cim | w_fnp_p6_no_not1st_frag_pulse_fnp2cim | w_fnp_p7_no_not1st_frag_pulse_fnp2cim; 
// state of hcp
wire    [1:0]       wv_hcp_state_cim2iip;
//cim-osm
wire    [133:0]     wv_data_ext_cim2osm;
wire                w_fifo_empty_ext_cim2osm;
wire                w_fifo_rd_ext_osm2cim;

wire    [133:0]     wv_data_int_cim2osm;
wire                w_fifo_empty_int_cim2osm;
wire                w_fifo_rd_int_osm2cim;
//fnp-osm
wire    [133:0]     wv_data_fnp2osm;
wire                w_fifo_empty_fnp2osm;
wire                w_fifo_rd_osm2fnp;
//lnp-osm
wire    [133:0]     wv_data_lnp2osm;
wire                w_fifo_empty_lnp2osm;
wire                w_fifo_rd_osm2lnp;
//iop-gmii_adapter
wire    [7:0] 	  	wv_gmii_txd_iop2gad;
wire        		w_gmii_tx_en_iop2gad;
wire        		w_gmii_tx_er_iop2gad;
//iop-cim
wire                w_txfifo_overflow_pulse;
wire                w_txfifo_underflow_pulse_async;
//hcp-cim
wire                w_port_inpkt_pulse_sync;
wire                w_port_outport_pulse_sync;
//lnp-cim
wire                w_lnp_no_last_frag_flag_pulse_lnp2cim;
wire                w_lnp_no_notlast_frag_flag_pulse_lnp2cim;
wire                w_ibm_discard_pulse_lnp2cim;
//iop-osm
wire    [6:0]       wv_fifo_usedw_iop2osm;
wire    [133:0]     wv_data_osm2iop;
wire                wv_data_wr_osm2iop;
//***************************************************
//            pkt count of gmii rx
//***************************************************
reg             r_gmii_dv;
reg   [7:0]     rv_gmii_rxd;
//gmii_rxd and gmii_rx_dv delay 2 cycles.
always @(posedge i_gmii_rxclk or negedge w_gmii_rst_n) begin
    if(w_gmii_rst_n == 1'b0)begin
        r_gmii_dv <= 1'b0;
        rv_gmii_rxd <= 8'b0;
    end
    else begin
        r_gmii_dv <= i_gmii_dv;
        rv_gmii_rxd <= iv_gmii_rxd;
    end
end
//pkt count
reg             r_port_inpkt_pulse;
reg             port_inpkt_count_state;
localparam      GMII_RX_IDLE_S = 1'd0,
                GMII_RX_TRANS_S = 1'd1;
always @(posedge i_gmii_rxclk or negedge w_gmii_rst_n) begin
    if(w_gmii_rst_n == 1'b0)begin
        r_port_inpkt_pulse <=  1'b0;
        
        port_inpkt_count_state <= GMII_RX_IDLE_S;
    end
    else begin
        case(port_inpkt_count_state)
            GMII_RX_IDLE_S:begin
                if(((r_gmii_dv == 1'b1) && (rv_gmii_rxd == 8'h55)) && ((i_gmii_dv == 1'b1) && (iv_gmii_rxd == 8'hd5)))begin
                    r_port_inpkt_pulse <= 1'b1;
                    port_inpkt_count_state <= GMII_RX_TRANS_S;
                end
                else begin
                    r_port_inpkt_pulse <= 1'b0;
                    port_inpkt_count_state <= GMII_RX_IDLE_S;
                end
            end
            GMII_RX_TRANS_S:begin
                r_port_inpkt_pulse <= 1'b0;            
                if(i_gmii_dv == 1'b0)begin
                    port_inpkt_count_state <= GMII_RX_IDLE_S; 
                end
                else begin
                    port_inpkt_count_state <= GMII_RX_TRANS_S; 
                end                
            end
            default:begin
                r_port_inpkt_pulse <= 1'b0; 
                port_inpkt_count_state <= GMII_RX_IDLE_S;                 
            end
        endcase
    end
end
//***************************************************
//            pkt count of gmii tx
//***************************************************
reg             r_gmii_tx_en;
reg   [7:0]     rv_gmii_txd;
//gmii_rxd and gmii_rx_dv delay 2 cycles.
always @(posedge i_gmii_rxclk or negedge w_gmii_rst_n) begin
    if(w_gmii_rst_n == 1'b0)begin
        r_gmii_tx_en <= 1'b0;
        rv_gmii_txd <= 8'b0;
    end
    else begin
        r_gmii_tx_en <= o_gmii_tx_en;
        rv_gmii_txd <= ov_gmii_txd;
    end
end
//pkt count
reg             r_port_outpkt_pulse;
reg             port_outpkt_count_state;
localparam      GMII_TX_IDLE_S = 1'd0,
                GMII_TX_TRANS_S = 1'd1;
always @(posedge i_gmii_rxclk or negedge w_gmii_rst_n) begin
    if(w_gmii_rst_n == 1'b0)begin
        r_port_outpkt_pulse <= 1'b0;
        
        port_outpkt_count_state <= GMII_TX_IDLE_S;
    end
    else begin
        case(port_outpkt_count_state)
            GMII_TX_IDLE_S:begin
                if(((r_gmii_tx_en == 1'b1) && (rv_gmii_txd == 8'h55)) && ((o_gmii_tx_en == 1'b1) && (ov_gmii_txd == 8'hd5)))begin
                    r_port_outpkt_pulse <= 1'b1;
                    port_outpkt_count_state <= GMII_TX_TRANS_S;
                end
                else begin
                    r_port_outpkt_pulse <= 1'b0;
                    port_outpkt_count_state <= GMII_TX_IDLE_S;
                end
            end
            GMII_TX_TRANS_S:begin
                r_port_outpkt_pulse <= 1'b0;            
                if(i_gmii_dv == 1'b0)begin
                    port_outpkt_count_state <= GMII_TX_IDLE_S; 
                end
                else begin
                    port_outpkt_count_state <= GMII_TX_TRANS_S; 
                end                
            end
            default:begin
                r_port_outpkt_pulse <= 1'b0; 
                port_outpkt_count_state <= GMII_TX_IDLE_S;                 
            end
        endcase
    end
end
reset_sync gmii_host_reset_sync(
.i_clk(i_gmii_rxclk),
.i_rst_n(i_rst_n),

.o_rst_n_sync(w_gmii_rst_n)   
);
signal_sync port_inpkt_pulse_sync_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.i_signal_async(r_port_inpkt_pulse),
.o_signal_sync(w_port_inpkt_pulse_sync)   
);
signal_sync port_outpkt_pulse_sync_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.i_signal_async(r_port_outpkt_pulse),
.o_signal_sync(w_port_outport_pulse_sync)   
);

signal_sync txfifo_underflow_pulse_sync_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.i_signal_async(w_txfifo_underflow_pulse_async),
.o_signal_sync(w_txfifo_underflow_pulse_sync)   
);
gmii_adapter_hcp gmii_adapter_hcp_inst(
.gmii_rxclk(i_gmii_rxclk),
.gmii_txclk(o_gmii_tx_clk),

.rst_n(w_gmii_rst_n),

.port_type(1'b0),

.gmii_rx_dv(i_gmii_dv),
.gmii_rx_er(i_gmii_er),
.gmii_rxd(iv_gmii_rxd),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_gad2iip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_gad2iip),
.gmii_rxd_adp2tsnchip(wv_gmii_rxd_gad2iip),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_iop2gad),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_iop2gad),
.gmii_txd_tsnchip2adp(wv_gmii_txd_iop2gad),

.gmii_tx_en(o_gmii_tx_en),
.gmii_tx_er(o_gmii_tx_er),
.gmii_txd(ov_gmii_txd)

//.i_loopback_en(1'b0),
//.o_host_gmii_in_monitor()
);
interface_input_process interface_input_process_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_gmii_rst_n(w_gmii_rst_n), 

.clk_gmii_rx(i_gmii_rxclk),
.i_gmii_dv(w_gmii_dv_gad2iip),
.iv_gmii_rxd(wv_gmii_rxd_gad2iip),
.i_gmii_er(w_gmii_er_gad2iip),	   

.ov_data(wv_data_iip2pdm),
.o_data_wr(w_data_wr_iip2pdm),
.ov_chip_pkt_inport(wv_chip_pkt_inport_iip2pdm),

.iv_hcp_state(wv_hcp_state_cim2iip),
.o_fifo_overflow_pulse(w_fifo_overflow_pulse_gwr2cim),
.o_fifo_underflow_pulse(w_fifo_underflow_pulse_grd2cim),
.o_frc_discard_pkt_pulse(w_frc_discard_pkt_pulse)   
);   
packet_dispatch_module packet_dispatch_module_inst(
.clk(i_clk),
.rst_n(i_rst_n),

.iv_pkt_data(wv_data_iip2pdm),
.i_pkt_data_wr(w_data_wr_iip2pdm),
.iv_pkt_inport(wv_chip_pkt_inport_iip2pdm),
    
.ov_pkt_data_fnp(wv_pkt_data_pdm2fnp),
.o_pkt_data_wr_fnp(w_pkt_data_wr_pdm2fnp),
.ov_pkt_inport_fnp(wv_pkt_inport_pdm2fnp),
    
.ov_pkt_data_cim(wv_pkt_data_pdm2cim),
.o_pkt_data_wr_cim(w_pkt_data_wr_pdm2cim),
.iv_chip_port_type_cim2pdm(wv_chip_port_type_cim2pdm),

.ov_pkt_data_lnp(wv_pkt_data_pdm2lnp),
.o_pkt_data_wr_lnp(w_pkt_data_wr_pdm2lnp),


.o_pkt_lost_pulse(w_first_node_notip_discard_pkt_pulse_pdm2cim)
);
controller_interactive_module controller_interactive_module_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
 
.iv_data(wv_pkt_data_pdm2cim),
.i_data_wr(w_pkt_data_wr_pdm2cim),
.iv_inport(wv_pkt_inport_pdm2fnp),

.ov_chip_port_type(wv_chip_port_type_cim2pdm),
.ov_hcp_state(wv_hcp_state_cim2iip),
.i_initial_finish(w_initial_finish_lnp2cim),

.ov_5tuple_ram_addr(wv_frag_ram_addr),
.ov_5tuple_ram_wdata(wv_frag_ram_wdata),
.o_5tuple_ram_wr(w_frag_ram_wr),
.iv_5tuple_ram_rdata(wv_frag_ram_rdata),
.o_5tuple_ram_rd(w_frag_ram_rd),

.ov_regroup_ram_addr(wv_regroup_ram_addr_cim2lnp),
.ov_regroup_ram_wdata(wv_regroup_ram_wdata_cim2lnp),
.o_regroup_ram_wr(w_regroup_ram_wr_cim2lnp),
.iv_regroup_ram_rdata(wv_regroup_ram_rdata),
.o_regroup_ram_rd(w_regroup_ram_rd),

.ov_fifo_data_out_ext(wv_data_ext_cim2osm),
.o_fifo_empty_ext(w_fifo_empty_ext_cim2osm),
.i_fifo_rd_ext(w_fifo_rd_ext_osm2cim),

.ov_fifo_data_out_int(wv_data_int_cim2osm),
.o_fifo_empty_int(w_fifo_empty_int_cim2osm),
.i_fifo_rd_int(w_fifo_rd_int_osm2cim),

.i_port_inpkt_pulse(w_port_inpkt_pulse_sync),
.i_port_outpkt_pulse(w_port_outport_pulse_sync),
.i_port_rx_asynfifo_overflow_pulse(w_fifo_overflow_pulse_gwr2cim),
.i_port_rx_asynfifo_underflow_pulse(w_fifo_underflow_pulse_grd2cim),
.i_port_tx_asynfifo_overflow_pulse(w_txfifo_overflow_pulse),
.i_port_tx_asynfifo_underflow_pulse(w_txfifo_underflow_pulse_sync),
.i_frc_discard_pkt_pulse(w_frc_discard_pkt_pulse),
.i_first_node_notip_discard_pkt_pulse(w_first_node_notip_discard_pkt_pulse_pdm2cim),

.i_fnp_inpkt_pulse(w_fnp_inpkt_pulse_fnp2cim),
.i_fnp_outpkt_pulse(w_fnp_outpkt_pulse_fnp2cim),
.i_fnp_no_1st_frag_pulse(w_fnp_no_1st_frag_pulse_fnp2cim),
.i_fnp_no_not1st_frag_pulse(w_fnp_no_not1st_frag_pulse_fnp2cim),
.i_fnp_fifo_overflow_pulse(w_fnp_fifo_overflow_pulse_fnp2cim),
.i_fnp_frag_discard_pulse(),

.i_lnp_inpkt_pulse(w_lnp_inpkt_pulse_lnp2cim),
.i_lnp_outpkt_pulse(w_lnp_outpkt_pulse_lnp2cim),
.i_lnp_no_last_frag_flag_pulse(w_lnp_no_last_frag_flag_pulse_lnp2cim),
.i_lnp_no_notlast_frag_flag_pulse(w_lnp_no_notlast_frag_flag_pulse_lnp2cim),
.i_lnp_ibm_pkt_discard_pulse(w_ibm_discard_pulse_lnp2cim),
.i_lnp_flow_table_overflow_pulse(w_lnp_flow_table_overflow_pulse_lnp2cim)
);
first_node_process first_node_process_inst(
.clk(i_clk),
.rst_n(i_rst_n),

.iv_fnp_pkt_data(wv_pkt_data_pdm2fnp),
.i_fnp_pkt_data_wr(w_pkt_data_wr_pdm2fnp),
.iv_fnp_pkt_inport(wv_pkt_inport_pdm2fnp),

.iv_fnp_fmt_ram_addr(wv_frag_ram_addr),
.i_fnp_fmt_ram_wr(w_frag_ram_wr),
.iv_fnp_fmt_ram_wdata(wv_frag_ram_wdata),
.ov_fnp_fmt_ram_rdata(wv_frag_ram_rdata),
.i_fnp_fmt_ram_rd(w_frag_ram_rd),

.i_fnp_fifo_rd(w_fifo_rd_osm2fnp),
.o_fnp_fifo_empty(w_fifo_empty_fnp2osm),
.ov_fnp_fifo_data(wv_data_fnp2osm),

.o_fnp_inport_0_lost_head(w_fnp_p0_no_1st_frag_pulse_fnp2cim), 
.o_fnp_inport_1_lost_head(w_fnp_p1_no_1st_frag_pulse_fnp2cim),
.o_fnp_inport_2_lost_head(w_fnp_p2_no_1st_frag_pulse_fnp2cim),
.o_fnp_inport_3_lost_head(w_fnp_p3_no_1st_frag_pulse_fnp2cim),
.o_fnp_inport_4_lost_head(w_fnp_p4_no_1st_frag_pulse_fnp2cim),
.o_fnp_inport_5_lost_head(w_fnp_p5_no_1st_frag_pulse_fnp2cim),
.o_fnp_inport_6_lost_head(w_fnp_p6_no_1st_frag_pulse_fnp2cim),
.o_fnp_inport_7_lost_head(w_fnp_p7_no_1st_frag_pulse_fnp2cim),

.o_fnp_inport_0_lost_nothead(w_fnp_p0_no_not1st_frag_pulse_fnp2cim), 
.o_fnp_inport_1_lost_nothead(w_fnp_p1_no_not1st_frag_pulse_fnp2cim),
.o_fnp_inport_2_lost_nothead(w_fnp_p2_no_not1st_frag_pulse_fnp2cim),
.o_fnp_inport_3_lost_nothead(w_fnp_p3_no_not1st_frag_pulse_fnp2cim),
.o_fnp_inport_4_lost_nothead(w_fnp_p4_no_not1st_frag_pulse_fnp2cim),
.o_fnp_inport_5_lost_nothead(w_fnp_p5_no_not1st_frag_pulse_fnp2cim),
.o_fnp_inport_6_lost_nothead(w_fnp_p6_no_not1st_frag_pulse_fnp2cim),
.o_fnp_inport_7_lost_nothead(w_fnp_p7_no_not1st_frag_pulse_fnp2cim),

.o_fnp_fifo_overflow(w_fnp_fifo_overflow_pulse_fnp2cim),

.o_fnp_inpkt_pulse(w_fnp_inpkt_pulse_fnp2cim),
.o_fnp_outpkt_pulse(w_fnp_outpkt_pulse_fnp2cim)
);
last_node_process last_node_process_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_pkt_data(wv_pkt_data_pdm2lnp),
.i_pkt_data_wr(w_pkt_data_wr_pdm2lnp),

.iv_regroup_ram_wdata(wv_regroup_ram_wdata_cim2lnp),
.i_regroup_ram_wr(w_regroup_ram_wr_cim2lnp),
.iv_regroup_ram_addr(wv_regroup_ram_addr_cim2lnp),
.ov_regroup_ram_rdata(wv_regroup_ram_rdata),
.i_regroup_ram_rd(w_regroup_ram_rd),

.o_fifo_empty(w_fifo_empty_lnp2osm),
.i_fifo_rd(w_fifo_rd_osm2lnp),
.ov_fifo_rdata(wv_data_lnp2osm),

.o_initial_finish(w_initial_finish_lnp2cim),

.o_lnp_inpkt_pulse(w_lnp_inpkt_pulse_lnp2cim),
.o_lnp_outpkt_pulse(w_lnp_outpkt_pulse_lnp2cim),
.o_lnp_flow_table_overflow_pulse(w_lnp_flow_table_overflow_pulse_lnp2cim),

.o_lnp_no_last_frag_flag_pulse(w_lnp_no_last_frag_flag_pulse_lnp2cim),      
.o_lnp_no_notlast_frag_flag_pulse(w_lnp_no_notlast_frag_flag_pulse_lnp2cim),
.o_ibm_discard_pulse(w_ibm_discard_pulse_lnp2cim)  
);
output_schedule_module output_schedule_module_inst(
.clk(i_clk),
.rst_n(i_rst_n),

.iv_fifo_usedw (wv_fifo_usedw_iop2osm),

.o_fnp_fifo_rd(w_fifo_rd_osm2fnp),
.i_fnp_fifo_empty(w_fifo_empty_fnp2osm),
.iv_fnp_fifo_data(wv_data_fnp2osm),

.o_lnp_fifo_rd(w_fifo_rd_osm2lnp),
.i_lnp_fifo_empty(w_fifo_empty_lnp2osm),
.iv_lnp_fifo_data(wv_data_lnp2osm),

.o_mux2fifo_rd(w_fifo_rd_ext_osm2cim),
.i_mux2fifo_empty(w_fifo_empty_ext_cim2osm),
.iv_mux2fifo_data(wv_data_ext_cim2osm),

.o_srm2fifo_rd(w_fifo_rd_int_osm2cim),
.i_srm2fifo_empty(w_fifo_empty_int_cim2osm),
.iv_srm2fifo_data(wv_data_int_cim2osm),

.ov_pkt_data(wv_data_osm2iop),
.o_pkt_data_wr(wv_data_wr_osm2iop)
);

interface_output_process interface_output_process_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.i_gmii_clk(i_gmii_rxclk),
.i_gmii_rst_n(w_gmii_rst_n), 

.iv_data(wv_data_osm2iop),
.i_data_wr(wv_data_wr_osm2iop),
.ov_fifo_usedw(wv_fifo_usedw_iop2osm),        

.ov_gmii_txd(wv_gmii_txd_iop2gad),
.o_gmii_tx_en(w_gmii_tx_en_iop2gad),
.o_gmii_tx_er(w_gmii_tx_er_iop2gad),
.o_gmii_tx_clk(o_gmii_tx_clk),

.o_fifo_overflow_pulse(w_txfifo_overflow_pulse),
.o_fifo_underflow_pulse(w_txfifo_underflow_pulse_async)
);
endmodule 