// Copyright (C) 1953-2020 NUDT
// Verilog module name - controller_interactive_module
// Version: controller_interactive_module_V1.0
// Created:
//         by - fenglin
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - top module of controller_interactive_module;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module controller_interactive_module
(
    i_clk,
    i_rst_n,
       
    iv_data,
	i_data_wr,
    iv_inport,
	   
    ov_chip_port_type,
    ov_hcp_state,
    i_initial_finish,

    ov_5tuple_ram_addr,
    ov_5tuple_ram_wdata,
    o_5tuple_ram_wr,
    iv_5tuple_ram_rdata,
    o_5tuple_ram_rd,
 
    ov_regroup_ram_addr,
    ov_regroup_ram_wdata,
    o_regroup_ram_wr,
    iv_regroup_ram_rdata,
    o_regroup_ram_rd,

    ov_fifo_data_out_ext,
    o_fifo_empty_ext,
    i_fifo_rd_ext,
    
    ov_fifo_data_out_int,
    o_fifo_empty_int,
    i_fifo_rd_int,

    i_port_inpkt_pulse,
    i_port_outpkt_pulse,
    i_frc_discard_pkt_pulse,
    i_first_node_notip_discard_pkt_pulse,
    i_port_rx_asynfifo_overflow_pulse,
    i_port_rx_asynfifo_underflow_pulse,
    i_port_tx_asynfifo_overflow_pulse,
    i_port_tx_asynfifo_underflow_pulse,
    
    i_fnp_inpkt_pulse,
    i_fnp_outpkt_pulse,
    i_fnp_fifo_overflow_pulse,
    i_fnp_no_1st_frag_pulse,
    i_fnp_no_not1st_frag_pulse,
    i_fnp_frag_discard_pulse,
    
    i_lnp_inpkt_pulse,
    i_lnp_outpkt_pulse,
    i_lnp_no_last_frag_flag_pulse,
    i_lnp_no_notlast_frag_flag_pulse,
    i_lnp_ibm_pkt_discard_pulse,    
    i_lnp_flow_table_overflow_pulse
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input	   [133:0]	   iv_data;
input	         	   i_data_wr;
input	   [3:0]       iv_inport;
// type of 8 ports of tsn chip
output     [7:0]       ov_chip_port_type;
//initial 512 bufid
input                  i_initial_finish;
// state of HCP
output     [1:0]       ov_hcp_state;
// 5tuple mapping table
output     [4:0]       ov_5tuple_ram_addr;
output     [151:0]     ov_5tuple_ram_wdata;
output                 o_5tuple_ram_wr;
input      [151:0]     iv_5tuple_ram_rdata;
output                 o_5tuple_ram_rd;
// regroup mapping table
output     [7:0]       ov_regroup_ram_addr;
output     [70:0]      ov_regroup_ram_wdata;
output                 o_regroup_ram_wr;
input      [70:0]      iv_regroup_ram_rdata;
output                 o_regroup_ram_rd;
// fifo outport
output     [133:0]     ov_fifo_data_out_ext;
output                 o_fifo_empty_ext;
input                  i_fifo_rd_ext;

output     [133:0]     ov_fifo_data_out_int;
output                 o_fifo_empty_int;
input                  i_fifo_rd_int;
// ptk count
input                  i_port_inpkt_pulse;
input                  i_port_rx_asynfifo_overflow_pulse;
input                  i_port_rx_asynfifo_underflow_pulse;
input                  i_frc_discard_pkt_pulse;
input                  i_first_node_notip_discard_pkt_pulse;
input                  i_port_outpkt_pulse;
input                  i_port_tx_asynfifo_overflow_pulse;
input                  i_port_tx_asynfifo_underflow_pulse;
   
input                  i_fnp_inpkt_pulse;
input                  i_fnp_outpkt_pulse;
input                  i_fnp_fifo_overflow_pulse;
input                  i_fnp_no_1st_frag_pulse;
input                  i_fnp_no_not1st_frag_pulse;
input                  i_fnp_frag_discard_pulse;
    
input                  i_lnp_inpkt_pulse;
input                  i_lnp_outpkt_pulse;
input                  i_lnp_no_last_frag_flag_pulse;
input                  i_lnp_no_notlast_frag_flag_pulse;
input                  i_lnp_ibm_pkt_discard_pulse;   
input                  i_lnp_flow_table_overflow_pulse;


//dmux-lcm
wire       [133:0]    wv_data_dmux2lcm;
wire                  w_data_wr_dmux2lcm;
//dmux-fem
wire      [133:0]     wv_data_dmux2fem;
wire                  w_data_wr_dmux2fem;
wire      [3:0]       wv_inport_dmux2fem;
//dmux-fdm
wire      [133:0]     wv_data_dmux2fdm;
wire                  w_data_wr_dmux2fdm;
//fem-mux
wire      [133:0]     wv_data_fem2mux;
wire                  w_data_wr_fem2mux;
//fdm-mux
wire      [133:0]     wv_data_fdm2mux;
wire                  w_data_wr_fdm2mux;
//fdm-fem
wire      [47:0]      wv_dmac_lcm2femsrm;
wire      [47:0]      wv_smac_lcm2femsrm;
//mux-stm
wire                  w_fifo_overflow_pulse_mux2stm;
//mux-fifo
wire      [8:0]	      wv_fifo_usedw_fifo2mux;
wire      [133:0]     wv_data_mux2fifo;
wire                  w_data_wr_mux2fifo;
// lcm-srm //configurate 5tuple mapping table & regroup mapping table
wire      [151:0]     wv_5tuple_ram_wdata_lcm2srm;
wire      [4:0]       wv_5tuple_ram_waddr_lcm2srm;
wire                  w_5tuple_ram_wr_lcm2srm;

wire      [70:0]      wv_regroup_ram_wdata_lcm2srm;
wire      [7:0]       wv_regroup_ram_waddr_lcm2srm;
wire                  w_regroup_ram_wr_lcm2srm;
// ria-srm //report 5tuple mapping table & regroup mapping table
//wire      [151:0]     wv_5tuple_ram_rdata_srm2ria;
wire      [4:0]       wv_5tuple_ram_raddr_srm2ria;
wire                  w_5tuple_ram_rd_srm2ria;
wire                  w_5tupleram_read_write_conflict_ria2srm;                
//wire      [56:0]      wv_regroup_ram_rdata_srm2ria;
wire      [7:0]       wv_regroup_ram_raddr_srm2ria;
wire                  w_regroup_ram_rd_srm2ria;
wire                  w_regroupram_read_write_conflict_ria2srm;
//stm-srm
wire      [15:0]      wv_port_inpkt_cnt_stm2srm;       
wire      [15:0]      wv_port_outpkt_cnt_stm2srm;
wire      [15:0]      wv_first_node_notip_discard_pkt_cnt_stm2srm;
wire      [15:0]      wv_fnp_fifo_overflow_cnt_stm2srm;
                      
wire      [15:0]      wv_fnp_inpkt_cnt_stm2srm;
wire      [15:0]      wv_fnp_outpkt_cnt_stm2srm;
wire      [15:0]      wv_fnp_no_1st_frag_cnt_stm2srm;
wire      [15:0]      wv_fnp_no_not1st_frag_cnt_stm2srm;
wire      [15:0]      wv_lnp_inpkt_cnt_stm2srm;
wire      [15:0]      wv_lnp_outpkt_cnt_stm2srm;
wire      [15:0]      wv_lnp_no_last_frag_flag_cnt_stm2srm;
wire      [15:0]      wv_lnp_ibm_pkt_discard_cnt_stm2srm;
wire      [15:0]      wv_lnp_flow_table_overflow_cnt_stm2srm;
                      
wire      [15:0]      wv_lcm_inpkt_cnt_stm2srm;
wire      [15:0]      wv_srm_outpkt_cnt_stm2srm;
                     
wire      [15:0]      wv_frc_discard_pkt_cnt_stm2srm;
wire      [15:0]      wv_cim_inpkt_cnt_stm2srm;
wire      [15:0]      wv_cim_outpkt_cnt_stm2srm;
wire      [15:0]      wv_cim_extfifo_overflow_cnt_stm2srm;
wire      [15:0]      wv_cim_intfifo_overflow_cnt_stm2srm;
wire      [15:0]      wv_lnp_no_notlast_frag_flag_cnt_stm2srm;
                      
wire      [15:0]      wv_port_rx_asynfifo_underflow_cnt_stm2srm;
wire      [15:0]      wv_port_rx_asynfifo_overflow_cnt_stm2srm ;
wire      [15:0]      wv_port_tx_asynfifo_underflow_cnt_stm2srm;
wire      [15:0]      wv_port_tx_asynfifo_overflow_cnt_stm2srm;

wire                  w_statistic_rst_srm2stm;
//srm-fifo
wire      [6:0]	      wv_fifo_usedw_fifo2srm;
wire      [133:0]     wv_data_srm2fifo;
wire                  w_data_wr_srm2fifo;	  
          
wire                  w_state_report_pulse;
wire                  w_lcm_inpkt_pulse;
          
wire      [15:0]      wv_report_type;
wire                  w_report_pulse_fem2srm;

//***************************************************
//            pkt count of cim
//***************************************************           
reg                   r_cim_inpkt_pulse;
reg                   r_cim_outpkt_pulse;        
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        r_cim_inpkt_pulse <= 1'b0;
        r_cim_outpkt_pulse <= 1'b0;
    end
    else begin
        if((i_data_wr == 1'b1) && (iv_data[133:132] == 2'b01))begin
            r_cim_inpkt_pulse <= 1'b1;
        end
        else begin
            r_cim_inpkt_pulse <= 1'b0;
        end
        
        if((i_fifo_rd_ext == 1'b1) && (ov_fifo_data_out_ext[133:132] == 2'b01))begin
            r_cim_outpkt_pulse <= 1'b1;
        end
        else if((i_fifo_rd_int == 1'b1) && (ov_fifo_data_out_int[133:132] == 2'b01))begin
            r_cim_outpkt_pulse <= 1'b1;
        end
        else begin
            r_cim_outpkt_pulse <= 1'b0;
        end     
    end
end
//***************************************************
//            overflow of extfifo
//*************************************************** 
wire                  w_intfifo_full;
wire                  w_extfifo_full;  
reg                   r_cim_extfifo_overflow_pulse;
reg                   r_cim_intfifo_overflow_pulse;         
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        r_cim_extfifo_overflow_pulse <= 1'b0;
        r_cim_intfifo_overflow_pulse <= 1'b0;
    end
    else begin
        if((w_data_wr_mux2fifo == 1'b1) && (w_extfifo_full == 1'b1))begin
            r_cim_extfifo_overflow_pulse <= 1'b1;
        end
        else begin
            r_cim_extfifo_overflow_pulse <= 1'b0;
        end  
        
        if((w_data_wr_srm2fifo == 1'b1) && (w_intfifo_full == 1'b1))begin
            r_cim_intfifo_overflow_pulse <= 1'b1;
        end
        else begin
            r_cim_intfifo_overflow_pulse <= 1'b0;
        end  
    end
end
dmux dmux_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
  
.iv_data(iv_data),
.i_data_wr(i_data_wr),
.iv_inport(iv_inport),

.ov_data_lcm(wv_data_dmux2lcm),
.o_data_wr_lcm(w_data_wr_dmux2lcm), 

.ov_data_fem(wv_data_dmux2fem),
.o_data_wr_fem(w_data_wr_dmux2fem),
.ov_inport_fem(wv_inport_dmux2fem),
  
.ov_data_fdm(wv_data_dmux2fdm),
.o_data_wr_fdm(w_data_wr_dmux2fdm) 
);
local_configuration_management local_configuration_management_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(wv_data_dmux2lcm),
.i_data_wr(w_data_wr_dmux2lcm),
.o_lcm_inpkt_pulse(w_lcm_inpkt_pulse),

.ov_dmac(wv_dmac_lcm2femsrm),
.ov_smac(wv_smac_lcm2femsrm),

.i_initial_finish(i_initial_finish),
.ov_report_type(wv_report_type),
.ov_chip_port_type(ov_chip_port_type),
.ov_hcp_state(ov_hcp_state),

.ov_frag_ram_wdata(wv_5tuple_ram_wdata_lcm2srm),
.ov_frag_ram_waddr(wv_5tuple_ram_waddr_lcm2srm),
.o_frag_ram_wr(w_5tuple_ram_wr_lcm2srm),

.ov_regroup_ram_wdata(wv_regroup_ram_wdata_lcm2srm),
.ov_regroup_ram_waddr(wv_regroup_ram_waddr_lcm2srm),
.o_regroup_ram_wr(w_regroup_ram_wr_lcm2srm)
);
frame_encapsulation_module frame_encapsulation_module_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_dmac(wv_dmac_lcm2femsrm),
.iv_smac(wv_smac_lcm2femsrm),
.o_report_pulse(w_report_pulse_fem2srm),
.iv_data(wv_data_dmux2fem),
.i_data_wr(w_data_wr_dmux2fem),
.iv_inport(wv_inport_dmux2fem),

.ov_data(wv_data_fem2mux),
.o_data_wr(w_data_wr_fem2mux)   
);
frame_decapsulation_module frame_decapsulation_module_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(wv_data_dmux2fdm),
.i_data_wr(w_data_wr_dmux2fdm),

.ov_data(wv_data_fdm2mux),
.o_data_wr(w_data_wr_fdm2mux)
);
mux mux_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data_fem(wv_data_fem2mux),
.i_data_wr_fem(w_data_wr_fem2mux),

.iv_data_fdm(wv_data_fdm2mux),
.i_data_wr_fdm(w_data_wr_fdm2mux),

.iv_fifo_usedw(wv_fifo_usedw_fifo2mux),
.o_fifo_overflow_pulse(w_fifo_overflow_pulse_mux2stm),

.ov_data(wv_data_mux2fifo),
.o_data_wr(w_data_wr_mux2fifo)
);
fifo_134_512 cim_ext_buffer(
.data(wv_data_mux2fifo),  //  fifo_input.datain
.wrreq(w_data_wr_mux2fifo), //            .wrreq
.rdreq(i_fifo_rd_ext), //            .rdreq(ack)
.clock(i_clk), //            .clk
.q(ov_fifo_data_out_ext),     // fifo_output.dataout
.usedw(wv_fifo_usedw_fifo2mux), //            .usedw
.full(w_extfifo_full),  //            .full
.empty(o_fifo_empty_ext)  //            .empty
);
pulse_statistic_module pulse_statistic_module_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_port_inpkt_pulse(i_port_inpkt_pulse),
.i_port_rx_asynfifo_overflow_pulse(i_port_rx_asynfifo_overflow_pulse),
.i_port_rx_asynfifo_underflow_pulse(i_port_rx_asynfifo_underflow_pulse),
.i_first_node_notip_discard_pkt_pulse(i_first_node_notip_discard_pkt_pulse),
.i_frc_discard_pkt_pulse(i_frc_discard_pkt_pulse),
.i_port_outpkt_pulse(i_port_outpkt_pulse),
.i_port_tx_asynfifo_overflow_pulse(i_port_tx_asynfifo_overflow_pulse),
.i_port_tx_asynfifo_underflow_pulse(i_port_tx_asynfifo_underflow_pulse),

.i_cim_inpkt_pulse(r_cim_inpkt_pulse),
.i_cim_outpkt_pulse(r_cim_outpkt_pulse),
.i_lcm_inpkt_pulse(w_lcm_inpkt_pulse),
.i_srm_outpkt_pulse(w_state_report_pulse),
.i_cim_extfifo_overflow_pulse(r_cim_extfifo_overflow_pulse),
.i_cim_intfifo_overflow_pulse(r_cim_intfifo_overflow_pulse),

.i_fnp_inpkt_pulse(i_fnp_inpkt_pulse),
.i_fnp_outpkt_pulse(i_fnp_outpkt_pulse),
.i_fnp_no_1st_frag_pulse(i_fnp_no_1st_frag_pulse),
.i_fnp_no_not1st_frag_pulse(i_fnp_no_not1st_frag_pulse),
.i_fnp_fifo_overflow_pulse(i_fnp_fifo_overflow_pulse),

.i_lnp_inpkt_pulse(i_lnp_inpkt_pulse),
.i_lnp_outpkt_pulse(i_lnp_outpkt_pulse),
.i_lnp_no_last_frag_flag_pulse(i_lnp_no_last_frag_flag_pulse),
.i_lnp_no_notlast_frag_flag_pulse(i_lnp_no_notlast_frag_flag_pulse),
.i_lnp_ibm_pkt_discard_pulse(i_lnp_ibm_pkt_discard_pulse),
.i_lnp_flow_table_overflow_pulse(i_lnp_flow_table_overflow_pulse),

.i_statistic_rst(w_statistic_rst_srm2stm),

.ov_port_inpkt_cnt(wv_port_inpkt_cnt_stm2srm),       
.ov_port_outpkt_cnt(wv_port_outpkt_cnt_stm2srm),
.ov_first_node_notip_discard_pkt_cnt(wv_first_node_notip_discard_pkt_cnt_stm2srm),
.ov_frc_discard_pkt_cnt(wv_frc_discard_pkt_cnt_stm2srm),

.ov_fnp_fifo_overflow_cnt(wv_fnp_fifo_overflow_cnt_stm2srm),
.ov_fnp_inpkt_cnt(wv_fnp_inpkt_cnt_stm2srm),
.ov_fnp_outpkt_cnt(wv_fnp_outpkt_cnt_stm2srm),
.ov_fnp_no_1st_frag_cnt(wv_fnp_no_1st_frag_cnt_stm2srm),
.ov_fnp_no_not1st_frag_cnt(wv_fnp_no_not1st_frag_cnt_stm2srm),
.ov_lnp_inpkt_cnt(wv_lnp_inpkt_cnt_stm2srm),
.ov_lnp_outpkt_cnt(wv_lnp_outpkt_cnt_stm2srm),
.ov_lnp_no_last_frag_flag_cnt(wv_lnp_no_last_frag_flag_cnt_stm2srm),
.ov_lnp_no_notlast_frag_flag_cnt(wv_lnp_no_notlast_frag_flag_cnt_stm2srm),
.ov_lnp_ibm_pkt_discard_cnt(wv_lnp_ibm_pkt_discard_cnt_stm2srm),
.ov_lnp_flow_table_overflow_cnt(wv_lnp_flow_table_overflow_cnt_stm2srm),

.ov_cim_inpkt_cnt(wv_cim_inpkt_cnt_stm2srm),
.ov_cim_outpkt_cnt(wv_cim_outpkt_cnt_stm2srm),
.ov_lcm_inpkt_cnt(wv_lcm_inpkt_cnt_stm2srm),
.ov_srm_outpkt_cnt(wv_srm_outpkt_cnt_stm2srm),
.ov_cim_extfifo_overflow_cnt(wv_cim_extfifo_overflow_cnt_stm2srm),
.ov_cim_intfifo_overflow_cnt(wv_cim_intfifo_overflow_cnt_stm2srm),

.ov_port_rx_asynfifo_underflow_cnt(wv_port_rx_asynfifo_underflow_cnt_stm2srm),
.ov_port_rx_asynfifo_overflow_cnt (wv_port_rx_asynfifo_overflow_cnt_stm2srm),
.ov_port_tx_asynfifo_underflow_cnt(wv_port_tx_asynfifo_underflow_cnt_stm2srm),
.ov_port_tx_asynfifo_overflow_cnt(wv_port_tx_asynfifo_overflow_cnt_stm2srm)
);
state_report_module state_report_module_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_dmac(wv_dmac_lcm2femsrm),
.iv_smac(wv_smac_lcm2femsrm),
//report registers
.iv_report_type(wv_report_type),
.iv_chip_port_type(ov_chip_port_type),
.iv_hcp_state(ov_hcp_state),
//report count
.iv_port_inpkt_cnt(wv_port_inpkt_cnt_stm2srm),       
.iv_port_outpkt_cnt(wv_port_outpkt_cnt_stm2srm),
.iv_frc_discard_pkt_cnt(wv_frc_discard_pkt_cnt_stm2srm),

.iv_pdm_first_node_notip_discard_pkt_cnt(wv_first_node_notip_discard_pkt_cnt_stm2srm),

.iv_cim_inpkt_cnt(wv_cim_inpkt_cnt_stm2srm),
.iv_cim_outpkt_cnt(wv_cim_outpkt_cnt_stm2srm),
.iv_lcm_inpkt_cnt(wv_lcm_inpkt_cnt_stm2srm),
.iv_srm_outpkt_cnt(wv_srm_outpkt_cnt_stm2srm),
.iv_cim_extfifo_overflow_cnt(wv_cim_extfifo_overflow_cnt_stm2srm),
.iv_cim_intfifo_overflow_cnt(wv_cim_intfifo_overflow_cnt_stm2srm),

.iv_fnp_fifo_overflow_cnt(wv_fnp_fifo_overflow_cnt_stm2srm),
.iv_fnp_inpkt_cnt(wv_fnp_inpkt_cnt_stm2srm),
.iv_fnp_outpkt_cnt(wv_fnp_outpkt_cnt_stm2srm),
.iv_fnp_no_1st_frag_cnt(wv_fnp_no_1st_frag_cnt_stm2srm),
.iv_fnp_no_not1st_frag_cnt(wv_fnp_no_not1st_frag_cnt_stm2srm),
.iv_lnp_inpkt_cnt(wv_lnp_inpkt_cnt_stm2srm),
.iv_lnp_outpkt_cnt(wv_lnp_outpkt_cnt_stm2srm),
.iv_lnp_no_notlast_frag_flag_cnt(wv_lnp_no_notlast_frag_flag_cnt_stm2srm),
.iv_lnp_no_last_frag_flag_cnt(wv_lnp_no_last_frag_flag_cnt_stm2srm),
.iv_lnp_ibm_pkt_discard_cnt(wv_lnp_ibm_pkt_discard_cnt_stm2srm),
.iv_lnp_flow_table_overflow_cnt(wv_lnp_flow_table_overflow_cnt_stm2srm),

.iv_port_rx_asynfifo_underflow_cnt(wv_port_rx_asynfifo_underflow_cnt_stm2srm),
.iv_port_rx_asynfifo_overflow_cnt (wv_port_rx_asynfifo_overflow_cnt_stm2srm),
.iv_port_tx_asynfifo_underflow_cnt(wv_port_tx_asynfifo_underflow_cnt_stm2srm),
.iv_port_tx_asynfifo_overflow_cnt(wv_port_tx_asynfifo_overflow_cnt_stm2srm),	
//count reset
.o_statistic_rst(w_statistic_rst_srm2stm),
//report table
.iv_5tuple_ram_rdata(iv_5tuple_ram_rdata),
.ov_5tuple_ram_raddr(wv_5tuple_ram_raddr_srm2ria),
.ov_5tuple_ram_rd(w_5tuple_ram_rd_srm2ria),
.i_5tupleram_read_write_conflict(w_5tupleram_read_write_conflict_ria2srm),
.iv_regroup_ram_rdata(iv_regroup_ram_rdata),
.ov_regroup_ram_raddr(wv_regroup_ram_raddr_srm2ria),
.ov_regroup_ram_rd(w_regroup_ram_rd_srm2ria),
.i_regroupram_read_write_conflict(w_regroupram_read_write_conflict_ria2srm),
//report data output
.i_report_pulse(w_report_pulse_fem2srm),
.o_state_report_pulse(w_state_report_pulse),
.ov_data(wv_data_srm2fifo),
.o_data_wr(w_data_wr_srm2fifo)
);

ram_interface_arbitration ram_interface_arbitration_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_5tuple_ram_wdata(wv_5tuple_ram_wdata_lcm2srm),
.iv_5tuple_ram_waddr(wv_5tuple_ram_waddr_lcm2srm),
.i_5tuple_ram_wr(w_5tuple_ram_wr_lcm2srm),

.iv_regroup_ram_wdata(wv_regroup_ram_wdata_lcm2srm),
.iv_regroup_ram_waddr(wv_regroup_ram_waddr_lcm2srm),
.i_regroup_ram_wr(w_regroup_ram_wr_lcm2srm),

//.ov_5tuple_ram_rdata(),
.iv_5tuple_ram_raddr(wv_5tuple_ram_raddr_srm2ria),
.i_5tuple_ram_rd(w_5tuple_ram_rd_srm2ria),

//.ov_regroup_ram_rdata(),
.iv_regroup_ram_raddr(wv_regroup_ram_raddr_srm2ria),
.i_regroup_ram_rd(w_regroup_ram_rd_srm2ria),

.ov_5tuple_ram_addr(ov_5tuple_ram_addr),
.ov_5tuple_ram_wdata(ov_5tuple_ram_wdata),
.o_5tuple_ram_wr(o_5tuple_ram_wr),       
//.iv_5tuple_ram_rdata(iv_5tuple_ram_rdata),
.o_5tuple_ram_rd(o_5tuple_ram_rd),

.ov_regroup_ram_addr(ov_regroup_ram_addr),
.ov_regroup_ram_wdata(ov_regroup_ram_wdata),
.o_regroup_ram_wr(o_regroup_ram_wr),
//.iv_regroup_ram_rdata(iv_regroup_ram_rdata),
.o_regroup_ram_rd(o_regroup_ram_rd),

.o_5tupleram_read_write_conflict(w_5tupleram_read_write_conflict_ria2srm),
.o_regroupram_read_write_conflict(w_regroupram_read_write_conflict_ria2srm)
);
fifo_134_128 cim_int_buffer(
.data(wv_data_srm2fifo),  //  fifo_input.datain
.wrreq(w_data_wr_srm2fifo), //            .wrreq
.rdreq(i_fifo_rd_int), //            .rdreq(ack)
.clock(i_clk), //            .clk
.q(ov_fifo_data_out_int),     // fifo_output.dataout
.usedw(wv_fifo_usedw_fifo2srm), //            .usedw
.full(w_intfifo_full),  //            .full
.empty(o_fifo_empty_int)  //            .empty
);
endmodule