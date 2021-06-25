// Copyright (C) 1953-2020 NUDT
// Verilog module name - tsn_chip 
// Version: tsn_chip_V1.0
// Created:
//         by - bo.chen 
//         at - 07.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//		  top of tsn_chip of FPGA
//				 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tsn_chip
(
       i_clk,
       i_rst_n,
       
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
       ov_gmii_txd_host,
       o_gmii_tx_en_host,
       o_gmii_tx_er_host,
       o_gmii_tx_clk_host,

       i_gmii_rst_n_p0,     
       i_gmii_rst_n_p1,     
       i_gmii_rst_n_p2,     
       i_gmii_rst_n_p3,     
       i_gmii_rst_n_host, 
    
       port_type_tsnchip2adp,
       o_init_led,
       pluse_s,
       o_fifo_overflow_pulse_host_rx, 
       o_fifo_underflow_pulse_host_rx,
       o_fifo_underflow_pulse_p0_rx,
       o_fifo_overflow_pulse_p0_rx, 
       o_fifo_underflow_pulse_p1_rx,
       o_fifo_overflow_pulse_p1_rx, 
       o_fifo_underflow_pulse_p2_rx,
       o_fifo_overflow_pulse_p2_rx, 
       o_fifo_underflow_pulse_p3_rx,
       o_fifo_overflow_pulse_p3_rx, 


       o_fifo_overflow_pulse_host_tx,
       o_fifo_overflow_pulse_p0_tx,
       o_fifo_overflow_pulse_p1_tx,
       o_fifo_overflow_pulse_p2_tx,
       o_fifo_overflow_pulse_p3_tx
   
);

//I/O
input                  i_clk;                   //125Mhz
input                  i_rst_n;

input                  i_gmii_rst_n_p0;  
input                  i_gmii_rst_n_p1;  
input                  i_gmii_rst_n_p2;  
input                  i_gmii_rst_n_p3;  
input                  i_gmii_rst_n_host;
// network output
output     [7:0]       ov_gmii_txd_p0;
output                 o_gmii_tx_en_p0;
output                 o_gmii_tx_er_p0;
output                 o_gmii_tx_clk_p0;

output     [7:0]       ov_gmii_txd_p1;
output                 o_gmii_tx_en_p1;
output                 o_gmii_tx_er_p1;
output                 o_gmii_tx_clk_p1;    

output     [7:0]       ov_gmii_txd_p2;
output                 o_gmii_tx_en_p2;
output                 o_gmii_tx_er_p2;
output                 o_gmii_tx_clk_p2;    

output     [7:0]       ov_gmii_txd_p3;
output                 o_gmii_tx_en_p3;
output                 o_gmii_tx_er_p3;
output                 o_gmii_tx_clk_p3;


//network input
input                   i_gmii_rxclk_p0;
input                   i_gmii_dv_p0;
input      [7:0]        iv_gmii_rxd_p0;
input                   i_gmii_er_p0;

input                   i_gmii_rxclk_p1;
input                   i_gmii_dv_p1;
input      [7:0]        iv_gmii_rxd_p1;
input                   i_gmii_er_p1;

input                   i_gmii_rxclk_p2;
input                   i_gmii_dv_p2;
input      [7:0]        iv_gmii_rxd_p2;
input                   i_gmii_er_p2;

input                   i_gmii_rxclk_p3;
input                   i_gmii_dv_p3;
input      [7:0]        iv_gmii_rxd_p3;
input                   i_gmii_er_p3;

// host output
output     [7:0]       ov_gmii_txd_host;
output                 o_gmii_tx_en_host;
output                 o_gmii_tx_er_host;
output                 o_gmii_tx_clk_host;

//host input
input                   i_gmii_rxclk_host;
input                   i_gmii_dv_host;
input      [7:0]        iv_gmii_rxd_host;
input                   i_gmii_er_host;

output                  pluse_s;
output    reg           o_init_led;
output     [7:0]        port_type_tsnchip2adp;

output                  o_fifo_overflow_pulse_host_rx;
output                  o_fifo_underflow_pulse_host_rx;
output                  o_fifo_underflow_pulse_p0_rx;
output                  o_fifo_overflow_pulse_p0_rx; 
output                  o_fifo_underflow_pulse_p1_rx;
output                  o_fifo_overflow_pulse_p1_rx; 
output                  o_fifo_underflow_pulse_p2_rx;
output                  o_fifo_overflow_pulse_p2_rx; 
output                  o_fifo_underflow_pulse_p3_rx;
output                  o_fifo_overflow_pulse_p3_rx; 


output                  o_fifo_overflow_pulse_host_tx;
output                  o_fifo_overflow_pulse_p0_tx;
output                  o_fifo_overflow_pulse_p1_tx;
output                  o_fifo_overflow_pulse_p2_tx;
output                  o_fifo_overflow_pulse_p3_tx;

//wire 
//*******************************
//              hrp
//*******************************
wire       [8:0]        wv_nmac_data_hrp2csm;
wire                    wv_nmac_data_wr_hrp2csm;

wire                    w_timer_rst_gts2others;
wire       [47:0]       wv_syned_global_time_gts2hrp;

wire       [9:0]        wv_time_slot_hrp2others;
wire                    w_time_slot_switch_hrp2others;

wire       [8:0]        wv_bufid_pcb2hrp;
wire                    w_bufid_wr_pcb2hrp;
wire                    w_bufid_ack_hrp2pcb;

wire       [133:0]      wv_pkt_data_hrp2pcb;
wire                    w_pkt_data_wr_hrp2pcb;
wire       [15:0]       wv_pkt_addr_hrp2pcb;//11->15
wire                    w_pkt_ack_pcb2hrp;

wire       [45:0]       wv_ts_descriptor_hrp2flt;
wire                    w_ts_descriptor_wr_hrp2flt;
wire                    w_ts_descriptor_ack_flt2hrp;

wire       [45:0]       wv_nts_descriptor_hrp2flt;
wire                    w_nts_descriptor_wr_hrp2flt;
wire                    w_nts_descriptor_ack_flt2hrp;

//*******************************
//              nip
//*******************************
//port0
wire       [8:0]        wv_bufid_pcb2nip_0;
wire                    w_bufid_wr_pcb2nip_0;
wire                    w_bufid_ack_hrp2nip_0;

wire       [45:0]       wv_descriptor_pcb2nip_0;
wire                    w_descriptor_wr_pcb2nip_0;
wire                    w_descriptor_ack_pcb2nip_0;

wire       [133:0]      wv_pkt_data_pcb2nip_0;
wire                    w_pkt_data_wr_pcb2nip_0;
wire       [15:0]       wv_pkt_addr_pcb2nip_0;
wire                    w_pkt_ack_pcb2nip_0;

//port1
wire       [8:0]        wv_bufid_pcb2nip_1;
wire                    w_bufid_wr_pcb2nip_1;
wire                    w_bufid_ack_hrp2nip_1;

wire       [45:0]       wv_descriptor_pcb2nip_1;
wire                    w_descriptor_wr_pcb2nip_1;
wire                    w_descriptor_ack_pcb2nip_1;

wire       [133:0]      wv_pkt_data_pcb2nip_1;
wire                    w_pkt_data_wr_pcb2nip_1;
wire       [15:0]       wv_pkt_addr_pcb2nip_1;
wire                    w_pkt_ack_pcb2nip_1;

//port2
wire       [8:0]        wv_bufid_pcb2nip_2;
wire                    w_bufid_wr_pcb2nip_2;
wire                    w_bufid_ack_hrp2nip_2;

wire       [45:0]       wv_descriptor_pcb2nip_2;
wire                    w_descriptor_wr_pcb2nip_2;
wire                    w_descriptor_ack_pcb2nip_2;

wire       [133:0]      wv_pkt_data_pcb2nip_2;
wire                    w_pkt_data_wr_pcb2nip_2;
wire       [15:0]       wv_pkt_addr_pcb2nip_2;
wire                    w_pkt_ack_pcb2nip_2;

//port3
wire       [8:0]        wv_bufid_pcb2nip_3;
wire                    w_bufid_wr_pcb2nip_3;
wire                    w_bufid_ack_hrp2nip_3;

wire       [45:0]       wv_descriptor_pcb2nip_3;
wire                    w_descriptor_wr_pcb2nip_3;
wire                    w_descriptor_ack_pcb2nip_3;

wire       [133:0]      wv_pkt_data_pcb2nip_3;
wire                    w_pkt_data_wr_pcb2nip_3;
wire       [15:0]       wv_pkt_addr_pcb2nip_3;
wire                    w_pkt_ack_pcb2nip_3;


//*******************************
//              flt
//*******************************
wire       [8:0]        wv_pkt_bufid_flt2pcb;    
wire                    w_pkt_bufid_wr_flt2pcb;  
wire       [3:0]        wv_pkt_bufid_cnt_flt2pcb;
//port0
wire       [8:0]        wv_pkt_bufid_flt2nop_0;
wire       [2:0]        wv_pkt_type_flt2nop_0;
wire                    w_pkt_bufid_wr_flt2nop_0;

//port1
wire       [8:0]        wv_pkt_bufid_flt2nop_1;
wire       [2:0]        wv_pkt_type_flt2nop_1;
wire                    w_pkt_bufid_wr_flt2nop_1;

//port2
wire       [8:0]        wv_pkt_bufid_flt2nop_2;
wire       [2:0]        wv_pkt_type_flt2nop_2;
wire                    w_pkt_bufid_wr_flt2nop_2;

//port3
wire       [8:0]        wv_pkt_bufid_flt2nop_3;
wire       [2:0]        wv_pkt_type_flt2nop_3;
wire                    w_pkt_bufid_wr_flt2nop_3;

//host port
wire       [8:0]        wv_pkt_bufid_flt2ntp;
wire       [2:0]        wv_pkt_type_flt2ntp;
wire       [4:0]        wv_submit_addr_flt2ntp;
wire       [3:0]        wv_inport_flt2ntp;
wire                    w_pkt_bufid_wr_flt2ntp;

//*******************************
//            htp
//*******************************
wire       [8:0]        wv_pkt_bufid_htp2pcb;    
wire                    w_pkt_bufid_wr_htp2pcb;  
wire                    w_pkt_bufid_ack_pcb2htp; 

wire       [15:0]       wv_pkt_raddr_htp2pcb;    //11->15  
wire                    w_pkt_rd_htp2pcb;       
wire                    w_pkt_raddr_ack_pcb2htp;

wire       [133:0]      wv_pkt_data_pcb2htp;  
wire                    w_pkt_data_wr_pcb2htp;

//*******************************
//             nop
//*******************************
//port0
wire       [8:0]        wv_pkt_bufid_nop2pcb_0;    
wire                    w_pkt_bufid_wr_nop2pcb_0;  
wire                    w_pkt_bufid_ack_pcb2nop_0; 

wire       [15:0]       wv_pkt_raddr_nop2pcb_0; //11->15  
wire                    w_pkt_rd_nop2pcb_0;       
wire                    w_pkt_raddr_ack_pcb2nop_0;

wire       [133:0]      wv_pkt_data_pcb2nop_0;  
wire                    w_pkt_data_wr_pcb2nop_0;

//port1
wire       [8:0]        wv_pkt_bufid_nop2pcb_1;    
wire                    w_pkt_bufid_wr_nop2pcb_1;  
wire                    w_pkt_bufid_ack_pcb2nop_1; 

wire       [15:0]       wv_pkt_raddr_nop2pcb_1;    //11->15  
wire                    w_pkt_rd_nop2pcb_1;       
wire                    w_pkt_raddr_ack_pcb2nop_1;

wire       [133:0]      wv_pkt_data_pcb2nop_1;  
wire                    w_pkt_data_wr_pcb2nop_1;

//port2
wire       [8:0]        wv_pkt_bufid_nop2pcb_2;    
wire                    w_pkt_bufid_wr_nop2pcb_2;  
wire                    w_pkt_bufid_ack_pcb2nop_2; 

wire       [15:0]       wv_pkt_raddr_nop2pcb_2;    //11->15  
wire                    w_pkt_rd_nop2pcb_2;       
wire                    w_pkt_raddr_ack_pcb2nop_2;

wire       [133:0]      wv_pkt_data_pcb2nop_2;  
wire                    w_pkt_data_wr_pcb2nop_2;

//port3
wire       [8:0]        wv_pkt_bufid_nop2pcb_3;    
wire                    w_pkt_bufid_wr_nop2pcb_3;  
wire                    w_pkt_bufid_ack_pcb2nop_3; 

wire       [15:0]       wv_pkt_raddr_nop2pcb_3;    //11->15  
wire                    w_pkt_rd_nop2pcb_3;       
wire                    w_pkt_raddr_ack_pcb2nop_3;

wire       [133:0]      wv_pkt_data_pcb2nop_3;  
wire                    w_pkt_data_wr_pcb2nop_3;


//*******************************
//             csm
//*******************************
wire       [48:0]       wv_time_offset_csm2gts;   
wire                    w_time_offset_wr_csm2gts; 
wire       [23:0]       wv_offset_period_csm2gts; 
wire       [1:0]        wv_cfg_finish_csm2others;      
wire       [10:0]       wv_slot_len_csm2others;      
wire       [10:0]       wv_inject_slot_period_us_csm2hrp;  
wire       [10:0]       wv_submit_slot_period_us_csm2htp;    
wire                    w_qbv_or_qch_csm2nop;     
wire       [11:0]       wv_report_period_ms_csm2gts; 

wire                    w_host_inpkt_pulse_hrp2csm;        
wire                    w_host_discard_pkt_pulse_hrp2csm;  
wire                    w_port0_inpkt_pulse_nip2csm;       
wire                    w_port0_discard_pkt_pulse_nip2csm; 
wire                    w_port1_inpkt_pulse_nip2csm;       
wire                    w_port1_discard_pkt_pulse_nip2csm; 
wire                    w_port2_inpkt_pulse_nip2csm;       
wire                    w_port2_discard_pkt_pulse_nip2csm; 
wire                    w_port3_inpkt_pulse_nip2csm;       
wire                    w_port3_discard_pkt_pulse_nip2csm; 
wire                    w_port4_inpkt_pulse_nip2csm;       
wire                    w_port4_discard_pkt_pulse_nip2csm; 
wire                    w_port5_inpkt_pulse_nip2csm;       
wire                    w_port5_discard_pkt_pulse_nip2csm; 
wire                    w_port6_inpkt_pulse_nip2csm;       
wire                    w_port6_discard_pkt_pulse_nip2csm; 
wire                    w_port7_inpkt_pulse_nip2csm;       
wire                    w_port7_discard_pkt_pulse_nip2csm; 
                        
wire                    w_host_outpkt_pulse_htp2csm;       
wire                    w_host_in_queue_discard_pulse_htp2csm;
wire                    w_port0_outpkt_pulse_nop2csm;      
wire                    w_port1_outpkt_pulse_nop2csm;      
wire                    w_port2_outpkt_pulse_nop2csm;      
wire                    w_port3_outpkt_pulse_nop2csm;     
wire                    w_port4_outpkt_pulse_nop2csm;      
wire                    w_port5_outpkt_pulse_nop2csm;      
wire                    w_port6_outpkt_pulse_nop2csm;      
wire                    w_port7_outpkt_pulse_nop2csm;      

wire       [7:0]        wv_nmac_data_csm2htp;     
wire                    w_nmac_data_last_csm2htp;   
wire                    w_namc_report_req_csm2htp;
wire                    w_nmac_report_ack_htp2csm;

wire       [9:0]        wv_tss_ram_addr;   
wire       [15:0]       wv_tss_ram_wdata;  
wire                    w_tss_ram_wr;      
wire       [15:0]       wv_tss_ram_rdata;  
wire                    w_tss_ram_rd;      
                  
wire       [9:0]        wv_tis_ram_addr;   
wire       [15:0]       wv_tis_ram_wdata;  
wire                    w_tis_ram_wr;      
wire       [15:0]       wv_tis_ram_rdata;  
wire                    w_tis_ram_rd;      
                        
wire       [13:0]       wv_flt_ram_addr;   
wire       [8:0]        wv_flt_ram_wdata;  
wire                    w_flt_ram_wr;      
wire       [8:0]        wv_flt_ram_rdata;  
wire                    w_flt_ram_rd;      
                        
wire       [9:0]        wv_qgc0_ram_addr;  
wire       [7:0]        wv_qgc0_ram_wdata; 
wire                    w_qgc0_ram_wr;     
wire       [7:0]        wv_qgc0_ram_rdata; 
wire                    w_qgc0_ram_rd;     
                        
wire       [9:0]        wv_qgc1_ram_addr; 
wire       [7:0]        wv_qgc1_ram_wdata; 
wire                    w_qgc1_ram_wr;     
wire       [7:0]        wv_qgc1_ram_rdata; 
wire                    w_qgc1_ram_rd;     
                        
wire       [9:0]        wv_qgc2_ram_addr;  
wire       [7:0]        wv_qgc2_ram_wdata; 
wire                    w_qgc2_ram_wr;     
wire       [7:0]        wv_qgc2_ram_rdata; 
wire                    w_qgc2_ram_rd;     

wire       [9:0]        wv_qgc3_ram_addr;  
wire       [7:0]        wv_qgc3_ram_wdata; 
wire                    w_qgc3_ram_wr;     
wire       [7:0]        wv_qgc3_ram_rdata; 
wire                    w_qgc3_ram_rd;

wire       [9:0]        wv_qgc4_ram_addr;  
wire       [7:0]        wv_qgc4_ram_wdata; 
wire                    w_qgc4_ram_wr;     
wire       [7:0]        wv_qgc4_ram_rdata; 
wire                    w_qgc4_ram_rd;

wire       [9:0]        wv_qgc5_ram_addr;  
wire       [7:0]        wv_qgc5_ram_wdata; 
wire                    w_qgc5_ram_wr;     
wire       [7:0]        wv_qgc5_ram_rdata; 
wire                    w_qgc5_ram_rd;

wire       [9:0]        wv_qgc6_ram_addr;  
wire       [7:0]        wv_qgc6_ram_wdata; 
wire                    w_qgc6_ram_wr;     
wire       [7:0]        wv_qgc6_ram_rdata; 
wire                    w_qgc6_ram_rd;

wire       [9:0]        wv_qgc7_ram_addr;  
wire       [7:0]        wv_qgc7_ram_wdata; 
wire                    w_qgc7_ram_wr;     
wire       [7:0]        wv_qgc7_ram_rdata; 
wire                    w_qgc7_ram_rd;

wire                    w_ts_inj_underflow_error_pulse_hrp2csm;
wire                    w_ts_inj_overflow_error_pulse_hrp2csm; 
wire                    w_ts_sub_underflow_error_pulse_htp2csm;
wire                    w_ts_sub_overflow_error_pulse_htp2csm; 
   
wire       [1:0]        wv_prp_state_hrp2csm;    
wire       [2:0]        wv_pdi_state_hrp2csm;     
wire       [1:0]        wv_tom_state_hrp2csm;          
wire       [2:0]        wv_pkt_state_hrp2csm;          
wire       [2:0]        wv_transmission_state_hrp2csm; 
wire       [2:0]        wv_descriptor_state_hrp2csm;   
wire       [2:0]        wv_tim_state_hrp2csm;          
wire       [2:0]        wv_ism_state_hrp2csm;    
wire       [1:0]        wv_hos_state_htp2csm;          
wire       [3:0]        wv_hoi_state_htp2csm;          
wire       [2:0]        wv_pkt_read_state_htp2csm;  
wire       [1:0]        wv_bufid_state_htp2csm;   
wire       [2:0]        wv_tsm_state_htp2csm;          
wire       [2:0]        wv_ssm_state_htp2csm;   
            
wire       [3:0]        wv_tdm_state_flt2csm;                 

//port0
wire       [1:0]        wv_osc_state_p0_nop2csm;                 
wire       [1:0]        wv_prc_state_p0_nop2csm;                 
wire       [2:0]        wv_opc_state_p0_nop2csm; 
     
wire       [1:0]        wv_gmii_read_state_p0_nip2csm;           
wire                    w_gmii_fifo_full_p0_nip2csm;             
wire                    w_gmii_fifo_empty_p0_nip2csm;            
wire       [3:0]        wv_descriptor_extract_state_p0_nip2csm;  
wire       [1:0]        wv_descriptor_send_state_p0_nip2csm;     
wire       [1:0]        wv_data_splice_state_p0_nip2csm;         
wire       [1:0]        wv_input_buf_interface_state_p0_nip2csm; 

//port1
wire       [1:0]        wv_osc_state_p1_nop2csm;                 
wire       [1:0]        wv_prc_state_p1_nop2csm;                 
wire       [2:0]        wv_opc_state_p1_nop2csm; 
      
wire       [1:0]        wv_gmii_read_state_p1_nip2csm;           
wire                    w_gmii_fifo_full_p1_nip2csm;             
wire                    w_gmii_fifo_empty_p1_nip2csm;            
wire       [3:0]        wv_descriptor_extract_state_p1_nip2csm;  
wire       [1:0]        wv_descriptor_send_state_p1_nip2csm;     
wire       [1:0]        wv_data_splice_state_p1_nip2csm;         
wire       [1:0]        wv_input_buf_interface_state_p1_nip2csm; 

//port2
wire       [1:0]        wv_osc_state_p2_nop2csm;                 
wire       [1:0]        wv_prc_state_p2_nop2csm;                 
wire       [2:0]        wv_opc_state_p2_nop2csm; 
     
wire       [1:0]        wv_gmii_read_state_p2_nip2csm;           
wire                    w_gmii_fifo_full_p2_nip2csm;             
wire                    w_gmii_fifo_empty_p2_nip2csm;            
wire       [3:0]        wv_descriptor_extract_state_p2_nip2csm;  
wire       [1:0]        wv_descriptor_send_state_p2_nip2csm;     
wire       [1:0]        wv_data_splice_state_p2_nip2csm;         
wire       [1:0]        wv_input_buf_interface_state_p2_nip2csm; 

//port3
wire       [1:0]        wv_osc_state_p3_nop2csm;                 
wire       [1:0]        wv_prc_state_p3_nop2csm;                 
wire       [2:0]        wv_opc_state_p3_nop2csm; 
      
wire       [1:0]        wv_gmii_read_state_p3_nip2csm;           
wire                    w_gmii_fifo_full_p3_nip2csm;             
wire                    w_gmii_fifo_empty_p3_nip2csm;            
wire       [3:0]        wv_descriptor_extract_state_p3_nip2csm;  
wire       [1:0]        wv_descriptor_send_state_p3_nip2csm;     
wire       [1:0]        wv_data_splice_state_p3_nip2csm;         
wire       [1:0]        wv_input_buf_interface_state_p3_nip2csm; 


wire       [3:0]        wv_pkt_write_state_pcb2csm;      
wire       [3:0]        wv_pcb_pkt_read_state_pcb2csm;   
wire       [3:0]        wv_address_write_state_pcb2csm;  
wire       [3:0]        wv_address_read_state_pcb2csm;   
wire       [8:0]        wv_free_buf_fifo_rdusedw_pcb2csm;

wire     [8:0]          wv_rc_regulation_value;
wire     [8:0]          wv_be_regulation_value;
wire     [8:0]          wv_unmap_regulation_value;

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_init_led <= 1'h0;
    end
    else begin
        if(wv_cfg_finish_csm2others == 2'd1)begin
            o_init_led <= 1'h1;
        end
        else if(wv_cfg_finish_csm2others > 2'd1)begin
            o_init_led <= 1'h0;
        end
        else begin
            o_init_led <= 1'h0;
        end
    end
end

host_receive_process host_receive_process_inst(
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
.i_gmii_rst_n_host              (i_gmii_rst_n_host),
.iv_cfg_finish                  (wv_cfg_finish_csm2others),
            
.i_gmii_rx_clk                  (i_gmii_rxclk_host),
.i_gmii_rx_dv                   (i_gmii_dv_host),
.iv_gmii_rxd                    (iv_gmii_rxd_host),
.i_gmii_rx_er                   (i_gmii_er_host),

.iv_free_bufid_fifo_rdusedw     (wv_free_buf_fifo_rdusedw_pcb2csm),
.iv_rc_threshold_value          (wv_rc_regulation_value),
.iv_be_threshold_value          (wv_be_regulation_value),
    
.ov_nmac_data                   (wv_nmac_data_hrp2csm),
.o_nmac_data_wr                 (wv_nmac_data_wr_hrp2csm),
    
.i_timer_rst                    (w_timer_rst_gts2others),
.iv_syned_global_time           (wv_syned_global_time_gts2hrp),
            
.iv_time_slot_length            (wv_slot_len_csm2others),
.iv_time_slot_period            (wv_inject_slot_period_us_csm2hrp),
            
.ov_time_slot                   (wv_time_slot_hrp2others),
.o_time_slot_switch             (w_time_slot_switch_hrp2others),
            
.iv_bufid                       (wv_bufid_pcb2hrp),
.i_bufid_wr                     (w_bufid_wr_pcb2hrp),
.o_bufid_ack                    (w_bufid_ack_hrp2pcb),
            
.ov_wdata                       (wv_pkt_data_hrp2pcb),
.o_data_wr                      (w_pkt_data_wr_hrp2pcb),
.ov_data_waddr                  (wv_pkt_addr_hrp2pcb),
.i_wdata_ack                    (w_pkt_ack_pcb2hrp),
            
.ov_ts_descriptor               (wv_ts_descriptor_hrp2flt),
.o_ts_descriptor_wr             (w_ts_descriptor_wr_hrp2flt),
.i_ts_descriptor_ack            (w_ts_descriptor_ack_flt2hrp),
                                    
.ov_nts_descriptor              (wv_nts_descriptor_hrp2flt),
.o_nts_descriptor_wr            (w_nts_descriptor_wr_hrp2flt),
.i_nts_descriptor_ack           (w_nts_descriptor_ack_flt2hrp),
    
.o_ts_underflow_error_pulse     (w_ts_inj_underflow_error_pulse_hrp2csm),
.o_ts_overflow_error_pulse      (w_ts_inj_overflow_error_pulse_hrp2csm),
 
.pdi_state                      (wv_pdi_state_hrp2csm),
.prp_state                      (wv_prp_state_hrp2csm),
.tom_state                      (wv_tom_state_hrp2csm),
.pkt_state                      (wv_pkt_state_hrp2csm),
.transmission_state             (wv_transmission_state_hrp2csm),
.descriptor_state               (wv_descriptor_state_hrp2csm),
.tim_state                      (wv_tim_state_hrp2csm),
.ism_state                      (wv_ism_state_hrp2csm),
    
.o_pkt_cnt_pulse                (w_host_inpkt_pulse_hrp2csm),
.o_pkt_discard_cnt_pulse        (w_host_discard_pkt_pulse_hrp2csm),

.iv_injection_slot_table_addr   (wv_tis_ram_addr),
.iv_injection_slot_table_wdata  (wv_tis_ram_wdata),
.i_injection_slot_table_wr      (w_tis_ram_wr),
.ov_injection_slot_table_rdata  (wv_tis_ram_rdata),
.i_injection_slot_table_rd      (w_tis_ram_rd),

.o_fifo_overflow_pulse          (o_fifo_overflow_pulse_host_rx), 
.o_fifo_underflow_pulse         (o_fifo_underflow_pulse_host_rx)    
);


network_input_process_top network_input_top_inst(
.clk_sys                            (i_clk),
.reset_n                            (i_rst_n),

.iv_free_bufid_fifo_rdusedw         (wv_free_buf_fifo_rdusedw_pcb2csm),
.iv_be_threshold_value              (wv_be_regulation_value),
.iv_rc_threshold_value              (wv_rc_regulation_value),
.iv_map_req_threshold_value         (wv_unmap_regulation_value),
            
.i_gmii_rst_n_p0                    (i_gmii_rst_n_p0),
.i_gmii_rst_n_p1                    (i_gmii_rst_n_p1),
.i_gmii_rst_n_p2                    (i_gmii_rst_n_p2),
.i_gmii_rst_n_p3                    (i_gmii_rst_n_p3),
                                
.clk_gmii_rx_p0                     (i_gmii_rxclk_p0),
.i_gmii_dv_p0                       (i_gmii_dv_p0),
.iv_gmii_rxd_p0                     (iv_gmii_rxd_p0),
.i_gmii_er_p0                       (i_gmii_er_p0),
            
.clk_gmii_rx_p1                     (i_gmii_rxclk_p1),
.i_gmii_dv_p1                       (i_gmii_dv_p1),
.iv_gmii_rxd_p1                     (iv_gmii_rxd_p1),
.i_gmii_er_p1                       (i_gmii_er_p1),
            
.clk_gmii_rx_p2                     (i_gmii_rxclk_p2),
.i_gmii_dv_p2                       (i_gmii_dv_p2),
.iv_gmii_rxd_p2                     (iv_gmii_rxd_p2),
.i_gmii_er_p2                       (i_gmii_er_p2),
            
.clk_gmii_rx_p3                     (i_gmii_rxclk_p3),
.i_gmii_dv_p3                       (i_gmii_dv_p3),
.iv_gmii_rxd_p3                     (iv_gmii_rxd_p3),
.i_gmii_er_p3                       (i_gmii_er_p3),

            
.timer_rst                          (w_timer_rst_gts2others),
.port_type                          (port_type_tsnchip2adp),
.cfg_finish                         (wv_cfg_finish_csm2others),

.iv_pkt_bufid_p0                    (wv_bufid_pcb2nip_0),            
.i_pkt_bufid_wr_p0                  (w_bufid_wr_pcb2nip_0),
.o_pkt_bufid_ack_p0                 (w_bufid_ack_hrp2nip_0),

.iv_pkt_bufid_p1                    (wv_bufid_pcb2nip_1),
.i_pkt_bufid_wr_p1                  (w_bufid_wr_pcb2nip_1),                   
.o_pkt_bufid_ack_p1                 (w_bufid_ack_hrp2nip_1),
            
.iv_pkt_bufid_p2                    (wv_bufid_pcb2nip_2),            
.i_pkt_bufid_wr_p2                  (w_bufid_wr_pcb2nip_2),
.o_pkt_bufid_ack_p2                 (w_bufid_ack_hrp2nip_2),
            
.iv_pkt_bufid_p3                    (wv_bufid_pcb2nip_3),    
.i_pkt_bufid_wr_p3                  (w_bufid_wr_pcb2nip_3),
.o_pkt_bufid_ack_p3                 (w_bufid_ack_hrp2nip_3),

 
.ov_descriptor_p0                   (wv_descriptor_pcb2nip_0), 
.o_descriptor_wr_p0                 (w_descriptor_wr_pcb2nip_0),
.i_descriptor_ack_p0                (w_descriptor_ack_pcb2nip_0),
            
.ov_descriptor_p1                   (wv_descriptor_pcb2nip_1), 
.o_descriptor_wr_p1                 (w_descriptor_wr_pcb2nip_1),
.i_descriptor_ack_p1                (w_descriptor_ack_pcb2nip_1),
            
.ov_descriptor_p2                   (wv_descriptor_pcb2nip_2), 
.o_descriptor_wr_p2                 (w_descriptor_wr_pcb2nip_2),
.i_descriptor_ack_p2                (w_descriptor_ack_pcb2nip_2),
            
.ov_descriptor_p3                   (wv_descriptor_pcb2nip_3), 
.o_descriptor_wr_p3                 (w_descriptor_wr_pcb2nip_3),
.i_descriptor_ack_p3                (w_descriptor_ack_pcb2nip_3),
                

.ov_pkt_p0                          (wv_pkt_data_pcb2nip_0),
.o_pkt_wr_p0                        (w_pkt_data_wr_pcb2nip_0),
.ov_pkt_bufadd_p0                   (wv_pkt_addr_pcb2nip_0),
.i_pkt_ack_p0                       (w_pkt_ack_pcb2nip_0),
            
.ov_pkt_p1                          (wv_pkt_data_pcb2nip_1),
.o_pkt_wr_p1                        (w_pkt_data_wr_pcb2nip_1),
.ov_pkt_bufadd_p1                   (wv_pkt_addr_pcb2nip_1),
.i_pkt_ack_p1                       (w_pkt_ack_pcb2nip_1),
            
.ov_pkt_p2                          (wv_pkt_data_pcb2nip_2),
.o_pkt_wr_p2                        (w_pkt_data_wr_pcb2nip_2),
.ov_pkt_bufadd_p2                   (wv_pkt_addr_pcb2nip_2),
.i_pkt_ack_p2                       (w_pkt_ack_pcb2nip_2),
            
.ov_pkt_p3                          (wv_pkt_data_pcb2nip_3),
.o_pkt_wr_p3                        (w_pkt_data_wr_pcb2nip_3),
.ov_pkt_bufadd_p3                   (wv_pkt_addr_pcb2nip_3),
.i_pkt_ack_p3                       (w_pkt_ack_pcb2nip_3),


.o_port0_inpkt_pulse                (w_port0_inpkt_pulse_nip2csm),
.o_port0_discard_pkt_pulse          (w_port0_discard_pkt_pulse_nip2csm),
.o_port1_inpkt_pulse                (w_port1_inpkt_pulse_nip2csm),
.o_port1_discard_pkt_pulse          (w_port1_discard_pkt_pulse_nip2csm),
.o_port2_inpkt_pulse                (w_port2_inpkt_pulse_nip2csm),
.o_port2_discard_pkt_pulse          (w_port2_discard_pkt_pulse_nip2csm),
.o_port3_inpkt_pulse                (w_port3_inpkt_pulse_nip2csm),
.o_port3_discard_pkt_pulse          (w_port3_discard_pkt_pulse_nip2csm),


.o_fifo_underflow_pulse_p0          (o_fifo_underflow_pulse_p0_rx),
.o_fifo_overflow_pulse_p0           (o_fifo_overflow_pulse_p0_rx ),
.o_fifo_underflow_pulse_p1          (o_fifo_underflow_pulse_p1_rx),
.o_fifo_overflow_pulse_p1           (o_fifo_overflow_pulse_p1_rx ),
.o_fifo_underflow_pulse_p2          (o_fifo_underflow_pulse_p2_rx),
.o_fifo_overflow_pulse_p2           (o_fifo_overflow_pulse_p2_rx ),
.o_fifo_underflow_pulse_p3          (o_fifo_underflow_pulse_p3_rx),
.o_fifo_overflow_pulse_p3           (o_fifo_overflow_pulse_p3_rx ),


.ov_gmii_read_state_p0              (wv_gmii_read_state_p0_nip2csm),
.o_gmii_fifo_full_p0                (w_gmii_fifo_full_p0_nip2csm),
.o_gmii_fifo_empty_p0               (w_gmii_fifo_empty_p0_nip2csm),
.ov_descriptor_extract_state_p0     (wv_descriptor_extract_state_p0_nip2csm),
.ov_descriptor_send_state_p0        (wv_descriptor_send_state_p0_nip2csm),
.ov_data_splice_state_p0            (wv_data_splice_state_p0_nip2csm),
.ov_input_buf_interface_state_p0    (wv_input_buf_interface_state_p0_nip2csm),

.ov_gmii_read_state_p1              (wv_gmii_read_state_p1_nip2csm),
.o_gmii_fifo_full_p1                (w_gmii_fifo_full_p1_nip2csm),
.o_gmii_fifo_empty_p1               (w_gmii_fifo_empty_p1_nip2csm),
.ov_descriptor_extract_state_p1     (wv_descriptor_extract_state_p1_nip2csm),
.ov_descriptor_send_state_p1        (wv_descriptor_send_state_p1_nip2csm),
.ov_data_splice_state_p1            (wv_data_splice_state_p1_nip2csm),
.ov_input_buf_interface_state_p1    (wv_input_buf_interface_state_p1_nip2csm),

.ov_gmii_read_state_p2              (wv_gmii_read_state_p2_nip2csm),
.o_gmii_fifo_full_p2                (w_gmii_fifo_full_p2_nip2csm),
.o_gmii_fifo_empty_p2               (w_gmii_fifo_empty_p2_nip2csm),
.ov_descriptor_extract_state_p2     (wv_descriptor_extract_state_p2_nip2csm),
.ov_descriptor_send_state_p2        (wv_descriptor_send_state_p2_nip2csm),
.ov_data_splice_state_p2            (wv_data_splice_state_p2_nip2csm),
.ov_input_buf_interface_state_p2    (wv_input_buf_interface_state_p2_nip2csm),

.ov_gmii_read_state_p3              (wv_gmii_read_state_p3_nip2csm),
.o_gmii_fifo_full_p3                (w_gmii_fifo_full_p3_nip2csm),
.o_gmii_fifo_empty_p3               (w_gmii_fifo_empty_p3_nip2csm),
.ov_descriptor_extract_state_p3     (wv_descriptor_extract_state_p3_nip2csm),
.ov_descriptor_send_state_p3        (wv_descriptor_send_state_p3_nip2csm),
.ov_data_splice_state_p3            (wv_data_splice_state_p3_nip2csm),
.ov_input_buf_interface_state_p3    (wv_input_buf_interface_state_p3_nip2csm)
 
);


forward_lookup_table forward_lookup_table_inst(
.i_clk                      (i_clk),
.i_rst_n                    (i_rst_n),
    
.iv_descriptor_p0           (wv_descriptor_pcb2nip_0),
.i_descriptor_wr_p0         (w_descriptor_wr_pcb2nip_0),
.o_descriptor_ack_p0        (w_descriptor_ack_pcb2nip_0),
                            
.iv_descriptor_p1           (wv_descriptor_pcb2nip_1),
.i_descriptor_wr_p1         (w_descriptor_wr_pcb2nip_1),
.o_descriptor_ack_p1        (w_descriptor_ack_pcb2nip_1),
                            
.iv_descriptor_p2           (wv_descriptor_pcb2nip_2),
.i_descriptor_wr_p2         (w_descriptor_wr_pcb2nip_2),
.o_descriptor_ack_p2        (w_descriptor_ack_pcb2nip_2),
    
.iv_descriptor_p3           (wv_descriptor_pcb2nip_3),
.i_descriptor_wr_p3         (w_descriptor_wr_pcb2nip_3),
.o_descriptor_ack_p3        (w_descriptor_ack_pcb2nip_3),


.iv_descriptor_host_ts      (wv_ts_descriptor_hrp2flt),
.i_descriptor_wr_host_ts    (w_ts_descriptor_wr_hrp2flt),
.o_descriptor_ack_host_ts   (w_ts_descriptor_ack_flt2hrp),
                             
.iv_descriptor_host_rc_be   (wv_nts_descriptor_hrp2flt),
.i_descriptor_wr_host_rc_be (w_nts_descriptor_wr_hrp2flt),
.o_descriptor_ack_host_rc_be(w_nts_descriptor_ack_flt2hrp),
    
.ov_pkt_bufid_p0            (wv_pkt_bufid_flt2nop_0),
.ov_pkt_type_p0             (wv_pkt_type_flt2nop_0),
.o_pkt_bufid_wr_p0          (w_pkt_bufid_wr_flt2nop_0),
    
.ov_pkt_bufid_p1            (wv_pkt_bufid_flt2nop_1),
.ov_pkt_type_p1             (wv_pkt_type_flt2nop_1),
.o_pkt_bufid_wr_p1          (w_pkt_bufid_wr_flt2nop_1),
    
.ov_pkt_bufid_p2            (wv_pkt_bufid_flt2nop_2),
.ov_pkt_type_p2             (wv_pkt_type_flt2nop_2),
.o_pkt_bufid_wr_p2          (w_pkt_bufid_wr_flt2nop_2),
    
.ov_pkt_bufid_p3            (wv_pkt_bufid_flt2nop_3),
.ov_pkt_type_p3             (wv_pkt_type_flt2nop_3),
.o_pkt_bufid_wr_p3          (w_pkt_bufid_wr_flt2nop_3),

.ov_pkt_bufid_host          (wv_pkt_bufid_flt2ntp),
.ov_pkt_type_host           (wv_pkt_type_flt2ntp),
.ov_submit_addr_host        (wv_submit_addr_flt2ntp),
.ov_inport_host             (wv_inport_flt2ntp),
.o_pkt_bufid_wr_host        (w_pkt_bufid_wr_flt2ntp),
    
.ov_pkt_bufid               (wv_pkt_bufid_flt2pcb),
.o_pkt_bufid_wr             (w_pkt_bufid_wr_flt2pcb),
.ov_pkt_bufid_cnt           (wv_pkt_bufid_cnt_flt2pcb),

.ov_tdm_state               (wv_tdm_state_flt2csm),

.iv_flt_ram_addr            (wv_flt_ram_addr),
.iv_flt_ram_wdata           (wv_flt_ram_wdata),
.i_flt_ram_wr               (w_flt_ram_wr),
.ov_flt_ram_rdata           (wv_flt_ram_rdata),
.i_flt_ram_rd               (w_flt_ram_rd)
);


pkt_centralized_buffer pkt_centralized_buffer_inst(
.clk_sys                 (i_clk),
.reset_n                 (i_rst_n), 
    
.iv_pkt_p0               (wv_pkt_data_pcb2nip_0),
.i_pkt_wr_p0             (w_pkt_data_wr_pcb2nip_0),
.iv_pkt_wr_bufadd_p0     (wv_pkt_addr_pcb2nip_0),
.o_pkt_wr_ack_p0         (w_pkt_ack_pcb2nip_0),
                         
.iv_pkt_p1               (wv_pkt_data_pcb2nip_1),
.i_pkt_wr_p1             (w_pkt_data_wr_pcb2nip_1),
.iv_pkt_wr_bufadd_p1     (wv_pkt_addr_pcb2nip_1),
.o_pkt_wr_ack_p1         (w_pkt_ack_pcb2nip_1),
                         
.iv_pkt_p2               (wv_pkt_data_pcb2nip_2),
.i_pkt_wr_p2             (w_pkt_data_wr_pcb2nip_2),
.iv_pkt_wr_bufadd_p2     (wv_pkt_addr_pcb2nip_2),
.o_pkt_wr_ack_p2         (w_pkt_ack_pcb2nip_2),

.iv_pkt_p3               (wv_pkt_data_pcb2nip_3),
.i_pkt_wr_p3             (w_pkt_data_wr_pcb2nip_3),
.iv_pkt_wr_bufadd_p3     (wv_pkt_addr_pcb2nip_3),
.o_pkt_wr_ack_p3         (w_pkt_ack_pcb2nip_3), 


.iv_pkt_p8               (wv_pkt_data_hrp2pcb),
.i_pkt_wr_p8             (w_pkt_data_wr_hrp2pcb),
.iv_pkt_wr_bufadd_p8     (wv_pkt_addr_hrp2pcb),  
.o_pkt_wr_ack_p8         (w_pkt_ack_pcb2hrp),

.iv_pkt_rd_bufadd_p0     (wv_pkt_raddr_nop2pcb_0),
.i_pkt_rd_p0             (w_pkt_rd_nop2pcb_0),
.o_pkt_rd_ack_p0         (w_pkt_raddr_ack_pcb2nop_0),
.ov_pkt_p0               (wv_pkt_data_pcb2nop_0),
.o_pkt_wr_p0             (w_pkt_data_wr_pcb2nop_0),
                         
.iv_pkt_rd_bufadd_p1     (wv_pkt_raddr_nop2pcb_1),
.i_pkt_rd_p1             (w_pkt_rd_nop2pcb_1),
.o_pkt_rd_ack_p1         (w_pkt_raddr_ack_pcb2nop_1),
.ov_pkt_p1               (wv_pkt_data_pcb2nop_1),   
.o_pkt_wr_p1             (w_pkt_data_wr_pcb2nop_1),

.iv_pkt_rd_bufadd_p2     (wv_pkt_raddr_nop2pcb_2),
.i_pkt_rd_p2             (w_pkt_rd_nop2pcb_2),
.o_pkt_rd_ack_p2         (w_pkt_raddr_ack_pcb2nop_2),
.ov_pkt_p2               (wv_pkt_data_pcb2nop_2),   
.o_pkt_wr_p2             (w_pkt_data_wr_pcb2nop_2),

.iv_pkt_rd_bufadd_p3     (wv_pkt_raddr_nop2pcb_3),
.i_pkt_rd_p3             (w_pkt_rd_nop2pcb_3),
.o_pkt_rd_ack_p3         (w_pkt_raddr_ack_pcb2nop_3),
.ov_pkt_p3               (wv_pkt_data_pcb2nop_3),   
.o_pkt_wr_p3             (w_pkt_data_wr_pcb2nop_3),



.iv_pkt_rd_bufadd_p8     (wv_pkt_raddr_htp2pcb),
.i_pkt_rd_p8             (w_pkt_rd_htp2pcb),
.o_pkt_rd_ack_p8         (w_pkt_raddr_ack_pcb2htp),
.ov_pkt_p8               (wv_pkt_data_pcb2htp), 
.o_pkt_wr_p8             (w_pkt_data_wr_pcb2htp),

.ov_pkt_bufid_p0         (wv_bufid_pcb2nip_0),
.o_pkt_bufid_wr_p0       (w_bufid_wr_pcb2nip_0),
.i_pkt_bufid_ack_p0      (w_bufid_ack_hrp2nip_0),
                         
.ov_pkt_bufid_p1         (wv_bufid_pcb2nip_1),
.o_pkt_bufid_wr_p1       (w_bufid_wr_pcb2nip_1),
.i_pkt_bufid_ack_p1      (w_bufid_ack_hrp2nip_1),
                         
.ov_pkt_bufid_p2         (wv_bufid_pcb2nip_2),
.o_pkt_bufid_wr_p2       (w_bufid_wr_pcb2nip_2),
.i_pkt_bufid_ack_p2      (w_bufid_ack_hrp2nip_2),

.ov_pkt_bufid_p3         (wv_bufid_pcb2nip_3),
.o_pkt_bufid_wr_p3       (w_bufid_wr_pcb2nip_3),
.i_pkt_bufid_ack_p3      (w_bufid_ack_hrp2nip_3),



.ov_pkt_bufid_p8         (wv_bufid_pcb2hrp),
.o_pkt_bufid_wr_p8       (w_bufid_wr_pcb2hrp),
.i_pkt_bufid_ack_p8      (w_bufid_ack_hrp2pcb),

.i_pkt_bufid_wr_flt      (w_pkt_bufid_wr_flt2pcb),
.iv_pkt_bufid_flt        (wv_pkt_bufid_flt2pcb),
.iv_pkt_bufid_cnt_flt    (wv_pkt_bufid_cnt_flt2pcb),

.iv_pkt_bufid_p0         (wv_pkt_bufid_nop2pcb_0),
.i_pkt_bufid_wr_p0       (w_pkt_bufid_wr_nop2pcb_0),
.o_pkt_bufid_ack_p0      (w_pkt_bufid_ack_pcb2nop_0),

.iv_pkt_bufid_p1         (wv_pkt_bufid_nop2pcb_1),
.i_pkt_bufid_wr_p1       (w_pkt_bufid_wr_nop2pcb_1),
.o_pkt_bufid_ack_p1      (w_pkt_bufid_ack_pcb2nop_1),

.iv_pkt_bufid_p2         (wv_pkt_bufid_nop2pcb_2),
.i_pkt_bufid_wr_p2       (w_pkt_bufid_wr_nop2pcb_2),
.o_pkt_bufid_ack_p2      (w_pkt_bufid_ack_pcb2nop_2),

.iv_pkt_bufid_p3         (wv_pkt_bufid_nop2pcb_3),
.i_pkt_bufid_wr_p3       (w_pkt_bufid_wr_nop2pcb_3),
.o_pkt_bufid_ack_p3      (w_pkt_bufid_ack_pcb2nop_3),


.iv_pkt_bufid_p8         (wv_pkt_bufid_htp2pcb),
.i_pkt_bufid_wr_p8       (w_pkt_bufid_wr_htp2pcb),
.o_pkt_bufid_ack_p8      (w_pkt_bufid_ack_pcb2htp),

.ov_pkt_write_state      (wv_pkt_write_state_pcb2csm),
.ov_pcb_pkt_read_state   (wv_pcb_pkt_read_state_pcb2csm),
.ov_address_write_state  (wv_address_write_state_pcb2csm),
.ov_address_read_state   (wv_address_read_state_pcb2csm),
.ov_free_buf_fifo_rdusedw(wv_free_buf_fifo_rdusedw_pcb2csm)
);


host_transmit_process host_transmit_process_inst(
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
            
.i_host_gmii_tx_clk             (i_gmii_rxclk_host),
.i_gmii_rst_n_host              (i_gmii_rst_n_host),
            
.iv_bufid                       (wv_pkt_bufid_flt2ntp),
.iv_pkt_type                    (wv_pkt_type_flt2ntp),
.iv_ts_submit_addr              (wv_submit_addr_flt2ntp),
.iv_pkt_inport                  (wv_inport_flt2ntp),
.i_data_wr                      (w_pkt_bufid_wr_flt2ntp),
            
.iv_cfg_finish                  (wv_cfg_finish_csm2others),
            
.ov_pkt_bufid                   (wv_pkt_bufid_htp2pcb),
.o_pkt_bufid_wr                 (w_pkt_bufid_wr_htp2pcb),
.i_pkt_bufid_ack                (w_pkt_bufid_ack_pcb2htp),
            
.ov_pkt_raddr                   (wv_pkt_raddr_htp2pcb),
.o_pkt_rd                       (w_pkt_rd_htp2pcb),
.i_pkt_raddr_ack                (w_pkt_raddr_ack_pcb2htp),
            
.iv_pkt_data                    (wv_pkt_data_pcb2htp),
.i_pkt_data_wr                  (w_pkt_data_wr_pcb2htp),
    
.iv_nmac_data                   (wv_nmac_data_csm2htp),
.i_nmac_last                    (w_nmac_data_last_csm2htp),
.i_nmac_report_req              (w_namc_report_req_csm2htp),
.o_nmac_ready                   (w_nmac_report_ack_htp2csm),
            
.ov_gmii_txd                    (ov_gmii_txd_host),
.o_gmii_tx_en                   (o_gmii_tx_en_host),
.o_gmii_tx_er                   (o_gmii_tx_er_host),
.o_gmii_tx_clk                  (o_gmii_tx_clk_host),
    
.iv_syned_global_time           (wv_syned_global_time_gts2hrp),
.i_timer_rst                    (w_timer_rst_gts2others),
.iv_time_slot_length            (wv_slot_len_csm2others),
.iv_submit_slot_table_period    (wv_submit_slot_period_us_csm2htp),
    
.o_ts_underflow_error_pulse     (w_ts_sub_underflow_error_pulse_htp2csm),
.o_ts_overflow_error_pulse      (w_ts_sub_overflow_error_pulse_htp2csm),

.hos_state                      (wv_hos_state_htp2csm),
.hoi_state                      (wv_hoi_state_htp2csm),
.bufid_state                    (wv_bufid_state_htp2csm),
.pkt_read_state                 (wv_pkt_read_state_htp2csm),
.tsm_state                      (wv_tsm_state_htp2csm),
.ssm_state                      (wv_ssm_state_htp2csm),

.o_pkt_cnt_pulse                (w_host_outpkt_pulse_htp2csm),
.o_host_inqueue_discard_pulse   (w_host_in_queue_discard_pulse_htp2csm),
.o_fifo_overflow_pulse          (o_fifo_overflow_pulse_host_tx), 
 
.iv_submit_slot_table_addr      (wv_tss_ram_addr),
.iv_submit_slot_table_wdata     (wv_tss_ram_wdata),
.i_submit_slot_table_wr         (w_tss_ram_wr),
.ov_submit_slot_table_rdata     (wv_tss_ram_rdata),
.i_submit_slot_table_rd         (w_tss_ram_rd)
);


network_output_process network_output_process_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                        
.i_gmii_clk_p0          (i_gmii_rxclk_p0),
.i_gmii_clk_p1          (i_gmii_rxclk_p1),
.i_gmii_clk_p2          (i_gmii_rxclk_p2),
.i_gmii_clk_p3          (i_gmii_rxclk_p3),
.i_gmii_rst_n_p0        (i_gmii_rst_n_p0),
.i_gmii_rst_n_p1        (i_gmii_rst_n_p1),
.i_gmii_rst_n_p2        (i_gmii_rst_n_p2),
.i_gmii_rst_n_p3        (i_gmii_rst_n_p3),


.i_qbv_or_qch           (w_qbv_or_qch_csm2nop),
.iv_time_slot           (wv_time_slot_hrp2others),
.i_time_slot_switch     (w_time_slot_switch_hrp2others),

.i_timer_rst_p0         (w_timer_rst_gts2others),
.i_timer_rst_p1         (w_timer_rst_gts2others),
.i_timer_rst_p2         (w_timer_rst_gts2others),
.i_timer_rst_p3         (w_timer_rst_gts2others),


//port 0
.iv_pkt_bufid_p0        (wv_pkt_bufid_flt2nop_0),
.iv_pkt_type_p0         (wv_pkt_type_flt2nop_0),
.i_pkt_bufid_wr_p0      (w_pkt_bufid_wr_flt2nop_0),

.ov_pkt_bufid_p0        (wv_pkt_bufid_nop2pcb_0),
.o_pkt_bufid_wr_p0      (w_pkt_bufid_wr_nop2pcb_0),
.i_pkt_bufid_ack_p0     (w_pkt_bufid_ack_pcb2nop_0),

.ov_pkt_raddr_p0        (wv_pkt_raddr_nop2pcb_0),
.o_pkt_rd_p0            (w_pkt_rd_nop2pcb_0),
.i_pkt_raddr_ack_p0     (w_pkt_raddr_ack_pcb2nop_0),

.iv_pkt_data_p0         (wv_pkt_data_pcb2nop_0),
.i_pkt_data_wr_p0       (w_pkt_data_wr_pcb2nop_0),

.ov_gmii_txd_p0         (ov_gmii_txd_p0),
.o_gmii_tx_en_p0        (o_gmii_tx_en_p0),
.o_gmii_tx_er_p0        (o_gmii_tx_er_p0),
.o_gmii_tx_clk_p0       (o_gmii_tx_clk_p0),

.o_port0_outpkt_pulse   (w_port0_outpkt_pulse_nop2csm),

.iv_nop0_ram_addr       (wv_qgc0_ram_addr),
.iv_nop0_ram_wdata      (wv_qgc0_ram_wdata),
.i_nop0_ram_wr          (w_qgc0_ram_wr),
.ov_nop0_ram_rdata      (wv_qgc0_ram_rdata),
.i_nop0_ram_rd          (w_qgc0_ram_rd),

.ov_osc_state_p0        (wv_osc_state_p0_nop2csm),
.ov_prc_state_p0        (wv_prc_state_p0_nop2csm),
.ov_opc_state_p0        (wv_opc_state_p0_nop2csm),

//port 1
.iv_pkt_bufid_p1        (wv_pkt_bufid_flt2nop_1),
.iv_pkt_type_p1         (wv_pkt_type_flt2nop_1),
.i_pkt_bufid_wr_p1      (w_pkt_bufid_wr_flt2nop_1),

.ov_pkt_bufid_p1        (wv_pkt_bufid_nop2pcb_1),
.o_pkt_bufid_wr_p1      (w_pkt_bufid_wr_nop2pcb_1),
.i_pkt_bufid_ack_p1     (w_pkt_bufid_ack_pcb2nop_1),

.ov_pkt_raddr_p1        (wv_pkt_raddr_nop2pcb_1),
.o_pkt_rd_p1            (w_pkt_rd_nop2pcb_1),
.i_pkt_raddr_ack_p1     (w_pkt_raddr_ack_pcb2nop_1),

.iv_pkt_data_p1         (wv_pkt_data_pcb2nop_1),
.i_pkt_data_wr_p1       (w_pkt_data_wr_pcb2nop_1),

.ov_gmii_txd_p1         (ov_gmii_txd_p1),
.o_gmii_tx_en_p1        (o_gmii_tx_en_p1),
.o_gmii_tx_er_p1        (o_gmii_tx_er_p1),
.o_gmii_tx_clk_p1       (o_gmii_tx_clk_p1),

.o_port1_outpkt_pulse   (w_port1_outpkt_pulse_nop2csm),

.iv_nop1_ram_addr       (wv_qgc1_ram_addr),
.iv_nop1_ram_wdata      (wv_qgc1_ram_wdata),
.i_nop1_ram_wr          (w_qgc1_ram_wr),
.ov_nop1_ram_rdata      (wv_qgc1_ram_rdata),
.i_nop1_ram_rd          (w_qgc1_ram_rd),

.ov_osc_state_p1        (wv_osc_state_p1_nop2csm),
.ov_prc_state_p1        (wv_prc_state_p1_nop2csm),
.ov_opc_state_p1        (wv_opc_state_p1_nop2csm),

//port 2
.iv_pkt_bufid_p2        (wv_pkt_bufid_flt2nop_2),
.iv_pkt_type_p2         (wv_pkt_type_flt2nop_2),
.i_pkt_bufid_wr_p2      (w_pkt_bufid_wr_flt2nop_2),

.ov_pkt_bufid_p2        (wv_pkt_bufid_nop2pcb_2),
.o_pkt_bufid_wr_p2      (w_pkt_bufid_wr_nop2pcb_2),
.i_pkt_bufid_ack_p2     (w_pkt_bufid_ack_pcb2nop_2),

.ov_pkt_raddr_p2        (wv_pkt_raddr_nop2pcb_2),
.o_pkt_rd_p2            (w_pkt_rd_nop2pcb_2),
.i_pkt_raddr_ack_p2     (w_pkt_raddr_ack_pcb2nop_2),

.iv_pkt_data_p2         (wv_pkt_data_pcb2nop_2),
.i_pkt_data_wr_p2       (w_pkt_data_wr_pcb2nop_2),

.ov_gmii_txd_p2         (ov_gmii_txd_p2),
.o_gmii_tx_en_p2        (o_gmii_tx_en_p2),
.o_gmii_tx_er_p2        (o_gmii_tx_er_p2),
.o_gmii_tx_clk_p2       (o_gmii_tx_clk_p2),

.o_port2_outpkt_pulse   (w_port2_outpkt_pulse_nop2csm),

.ov_osc_state_p2        (wv_osc_state_p2_nop2csm),
.ov_prc_state_p2        (wv_prc_state_p2_nop2csm),
.ov_opc_state_p2        (wv_opc_state_p2_nop2csm),

.iv_nop2_ram_addr       (wv_qgc2_ram_addr),
.iv_nop2_ram_wdata      (wv_qgc2_ram_wdata),
.i_nop2_ram_wr          (w_qgc2_ram_wr),
.ov_nop2_ram_rdata      (wv_qgc2_ram_rdata),
.i_nop2_ram_rd          (w_qgc2_ram_rd),
//port 3
.iv_pkt_bufid_p3        (wv_pkt_bufid_flt2nop_3),
.iv_pkt_type_p3         (wv_pkt_type_flt2nop_3),
.i_pkt_bufid_wr_p3      (w_pkt_bufid_wr_flt2nop_3),
                        
.ov_pkt_bufid_p3        (wv_pkt_bufid_nop2pcb_3),
.o_pkt_bufid_wr_p3      (w_pkt_bufid_wr_nop2pcb_3),
.i_pkt_bufid_ack_p3     (w_pkt_bufid_ack_pcb2nop_3),
                        
.ov_pkt_raddr_p3        (wv_pkt_raddr_nop2pcb_3),
.o_pkt_rd_p3            (w_pkt_rd_nop2pcb_3),
.i_pkt_raddr_ack_p3     (w_pkt_raddr_ack_pcb2nop_3),
                        
.iv_pkt_data_p3         (wv_pkt_data_pcb2nop_3),
.i_pkt_data_wr_p3       (w_pkt_data_wr_pcb2nop_3),
                        
.o_port3_outpkt_pulse   (w_port3_outpkt_pulse_nop2csm),
                        
.ov_gmii_txd_p3         (ov_gmii_txd_p3),
.o_gmii_tx_en_p3        (o_gmii_tx_en_p3),
.o_gmii_tx_er_p3        (o_gmii_tx_er_p3),
.o_gmii_tx_clk_p3       (o_gmii_tx_clk_p3),
                        
.iv_nop3_ram_addr       (wv_qgc3_ram_addr),
.iv_nop3_ram_wdata      (wv_qgc3_ram_wdata),
.i_nop3_ram_wr          (w_qgc3_ram_wr),
.ov_nop3_ram_rdata      (wv_qgc3_ram_rdata),
.i_nop3_ram_rd          (w_qgc3_ram_rd),
                        
.ov_osc_state_p3        (wv_osc_state_p3_nop2csm),
.ov_prc_state_p3        (wv_prc_state_p3_nop2csm),
.ov_opc_state_p3        (wv_opc_state_p3_nop2csm),


.o_fifo_overflow_pulse_p0(o_fifo_overflow_pulse_p0_tx),    
.o_fifo_overflow_pulse_p1(o_fifo_overflow_pulse_p1_tx),    
.o_fifo_overflow_pulse_p2(o_fifo_overflow_pulse_p2_tx),    
.o_fifo_overflow_pulse_p3(o_fifo_overflow_pulse_p3_tx)   
);

configure_state_manage configure_state_manage_inst(
.i_clk                               (i_clk),
.i_rst_n                             (i_rst_n),
                                   
.iv_nmac_data                        (wv_nmac_data_hrp2csm),
.i_nmac_data_wr                      (wv_nmac_data_wr_hrp2csm),
                                   
.ov_time_offset                      (wv_time_offset_csm2gts),
.o_time_offset_wr                    (w_time_offset_wr_csm2gts),
.ov_offset_period                    (wv_offset_period_csm2gts),
.ov_cfg_finish                       (wv_cfg_finish_csm2others),
.ov_port_type                        (port_type_tsnchip2adp),
.ov_slot_len                         (wv_slot_len_csm2others),
.ov_inject_slot_period               (wv_inject_slot_period_us_csm2hrp),
.ov_submit_slot_period               (wv_submit_slot_period_us_csm2htp),

.ov_rc_regulation_value              (wv_rc_regulation_value),
.ov_be_regulation_value              (wv_be_regulation_value),
.ov_unmap_regulation_value           (wv_unmap_regulation_value),

.o_qbv_or_qch                        (w_qbv_or_qch_csm2nop),
.ov_report_period                    (wv_report_period_ms_csm2gts),
                                
.i_host_inpkt_pulse                  (w_host_inpkt_pulse_hrp2csm),
.i_host_discard_pkt_pulse            (w_host_discard_pkt_pulse_hrp2csm),
.i_port0_inpkt_pulse                 (w_port0_inpkt_pulse_nip2csm),
.i_port0_discard_pkt_pulse           (w_port0_discard_pkt_pulse_nip2csm),
.i_port1_inpkt_pulse                 (w_port1_inpkt_pulse_nip2csm),
.i_port1_discard_pkt_pulse           (w_port1_discard_pkt_pulse_nip2csm),
.i_port2_inpkt_pulse                 (w_port2_inpkt_pulse_nip2csm),
.i_port2_discard_pkt_pulse           (w_port2_discard_pkt_pulse_nip2csm),
.i_port3_inpkt_pulse                 (w_port3_inpkt_pulse_nip2csm),
.i_port3_discard_pkt_pulse           (w_port3_discard_pkt_pulse_nip2csm),

                                      
.i_host_outpkt_pulse                 (w_host_outpkt_pulse_htp2csm),
.i_host_in_queue_discard_pulse       (w_host_in_queue_discard_pulse_htp2csm),
.i_port0_outpkt_pulse                (w_port0_outpkt_pulse_nop2csm),
.i_port1_outpkt_pulse                (w_port1_outpkt_pulse_nop2csm),
.i_port2_outpkt_pulse                (w_port2_outpkt_pulse_nop2csm),
.i_port3_outpkt_pulse                (w_port3_outpkt_pulse_nop2csm),

                                   
.ov_nmac_data                        (wv_nmac_data_csm2htp),
.o_nmac_data_last                    (w_nmac_data_last_csm2htp),
.o_namc_report_req                   (w_namc_report_req_csm2htp),
.i_nmac_report_ack                   (w_nmac_report_ack_htp2csm),
.i_report_pulse                      (pluse_s),
                                         
.i_ts_inj_underflow_error_pulse      (w_ts_inj_underflow_error_pulse_hrp2csm),
.i_ts_inj_overflow_error_pulse       (w_ts_inj_overflow_error_pulse_hrp2csm),
.i_ts_sub_underflow_error_pulse      (w_ts_sub_underflow_error_pulse_htp2csm),
.i_ts_sub_overflow_error_pulse       (w_ts_sub_overflow_error_pulse_htp2csm),

.iv_prp_state                        (wv_prp_state_hrp2csm),
.iv_pdi_state                        (wv_pdi_state_hrp2csm),
.iv_tom_state                        (wv_tom_state_hrp2csm),
.iv_pkt_state                        (wv_pkt_state_hrp2csm),
.iv_transmission_state               (wv_transmission_state_hrp2csm),
.iv_descriptor_state                 (wv_descriptor_state_hrp2csm),
.iv_tim_state                        (wv_tim_state_hrp2csm),
.iv_ism_state                        (wv_ism_state_hrp2csm),

.iv_hos_state                        (wv_hos_state_htp2csm),
.iv_hoi_state                        (wv_hoi_state_htp2csm),
.iv_pkt_read_state                   (wv_pkt_read_state_htp2csm),
.iv_bufid_state                      (wv_bufid_state_htp2csm),
.iv_tsm_state                        (wv_tsm_state_htp2csm),
.iv_smm_state                        (wv_ssm_state_htp2csm),

.iv_tdm_state                        (wv_tdm_state_flt2csm),
                                      
.iv_osc_state_p0                     (wv_osc_state_p0_nop2csm),
.iv_prc_state_p0                     (wv_prc_state_p0_nop2csm),
.iv_opc_state_p0                     (wv_opc_state_p0_nop2csm),
.iv_gmii_read_state_p0               (wv_gmii_read_state_p0_nip2csm),
.i_gmii_fifo_full_p0                 (w_gmii_fifo_full_p0_nip2csm),
.i_gmii_fifo_empty_p0                (w_gmii_fifo_empty_p0_nip2csm),
.iv_descriptor_extract_state_p0      (wv_descriptor_extract_state_p0_nip2csm),
.iv_descriptor_send_state_p0         (wv_descriptor_send_state_p0_nip2csm),
.iv_data_splice_state_p0             (wv_data_splice_state_p0_nip2csm),
.iv_input_buf_interface_state_p0     (wv_input_buf_interface_state_p0_nip2csm),
                                      
.iv_osc_state_p1                     (wv_osc_state_p1_nop2csm),
.iv_prc_state_p1                     (wv_prc_state_p1_nop2csm),
.iv_opc_state_p1                     (wv_opc_state_p1_nop2csm),
.iv_gmii_read_state_p1               (wv_gmii_read_state_p1_nip2csm),
.i_gmii_fifo_full_p1                 (w_gmii_fifo_full_p1_nip2csm),
.i_gmii_fifo_empty_p1                (w_gmii_fifo_empty_p1_nip2csm),
.iv_descriptor_extract_state_p1      (wv_descriptor_extract_state_p1_nip2csm),
.iv_descriptor_send_state_p1         (wv_descriptor_send_state_p1_nip2csm),
.iv_data_splice_state_p1             (wv_data_splice_state_p1_nip2csm),
.iv_input_buf_interface_state_p1     (wv_input_buf_interface_state_p1_nip2csm),

.iv_osc_state_p2                     (wv_osc_state_p2_nop2csm),
.iv_prc_state_p2                     (wv_prc_state_p2_nop2csm),
.iv_opc_state_p2                     (wv_opc_state_p2_nop2csm),
.iv_gmii_read_state_p2               (wv_gmii_read_state_p2_nip2csm),
.i_gmii_fifo_full_p2                 (w_gmii_fifo_full_p2_nip2csm),
.i_gmii_fifo_empty_p2                (w_gmii_fifo_empty_p2_nip2csm),
.iv_descriptor_extract_state_p2      (wv_descriptor_extract_state_p2_nip2csm),
.iv_descriptor_send_state_p2         (wv_descriptor_send_state_p2_nip2csm),
.iv_data_splice_state_p2             (wv_data_splice_state_p2_nip2csm),
.iv_input_buf_interface_state_p2     (wv_input_buf_interface_state_p2_nip2csm),

.iv_osc_state_p3                     (wv_osc_state_p3_nop2csm),
.iv_prc_state_p3                     (wv_prc_state_p3_nop2csm),
.iv_opc_state_p3                     (wv_opc_state_p3_nop2csm),
.iv_gmii_read_state_p3               (wv_gmii_read_state_p3_nip2csm),
.i_gmii_fifo_full_p3                 (w_gmii_fifo_full_p3_nip2csm),
.i_gmii_fifo_empty_p3                (w_gmii_fifo_empty_p3_nip2csm),
.iv_descriptor_extract_state_p3      (wv_descriptor_extract_state_p3_nip2csm),
.iv_descriptor_send_state_p3         (wv_descriptor_send_state_p3_nip2csm),
.iv_data_splice_state_p3             (wv_data_splice_state_p3_nip2csm),
.iv_input_buf_interface_state_p3     (wv_input_buf_interface_state_p3_nip2csm),


.iv_pkt_write_state                  (wv_pkt_write_state_pcb2csm),
.iv_pcb_pkt_read_state               (wv_pcb_pkt_read_state_pcb2csm),
.iv_address_write_state              (wv_address_write_state_pcb2csm),
.iv_address_read_state               (wv_address_read_state_pcb2csm),
.iv_free_buf_fifo_rdusedw            (wv_free_buf_fifo_rdusedw_pcb2csm),
                                 
.ov_tss_ram_addr                     (wv_tss_ram_addr),
.ov_tss_ram_wdata                    (wv_tss_ram_wdata),
.o_tss_ram_wr                        (w_tss_ram_wr),
.iv_tss_ram_rdata                    (wv_tss_ram_rdata),
.o_tss_ram_rd                        (w_tss_ram_rd),
                                      
.ov_tis_ram_addr                     (wv_tis_ram_addr),
.ov_tis_ram_wdata                    (wv_tis_ram_wdata),
.o_tis_ram_wr                        (w_tis_ram_wr),
.iv_tis_ram_rdata                    (wv_tis_ram_rdata),
.o_tis_ram_rd                        (w_tis_ram_rd),
                                      
.ov_flt_ram_addr                     (wv_flt_ram_addr),
.ov_flt_ram_wdata                    (wv_flt_ram_wdata),
.o_flt_ram_wr                        (w_flt_ram_wr),
.iv_flt_ram_rdata                    (wv_flt_ram_rdata),
.o_flt_ram_rd                        (w_flt_ram_rd),
                                      
.ov_qgc0_ram_addr                    (wv_qgc0_ram_addr),
.ov_qgc0_ram_wdata                   (wv_qgc0_ram_wdata),
.o_qgc0_ram_wr                       (w_qgc0_ram_wr),
.iv_qgc0_ram_rdata                   (wv_qgc0_ram_rdata),
.o_qgc0_ram_rd                       (w_qgc0_ram_rd),
                                      
.ov_qgc1_ram_addr                    (wv_qgc1_ram_addr),
.ov_qgc1_ram_wdata                   (wv_qgc1_ram_wdata),
.o_qgc1_ram_wr                       (w_qgc1_ram_wr),
.iv_qgc1_ram_rdata                   (wv_qgc1_ram_rdata),
.o_qgc1_ram_rd                       (w_qgc1_ram_rd),
                                      
.ov_qgc2_ram_addr                    (wv_qgc2_ram_addr),
.ov_qgc2_ram_wdata                   (wv_qgc2_ram_wdata),
.o_qgc2_ram_wr                       (w_qgc2_ram_wr),
.iv_qgc2_ram_rdata                   (wv_qgc2_ram_rdata),
.o_qgc2_ram_rd                       (w_qgc2_ram_rd),
                                      
.ov_qgc3_ram_addr                    (wv_qgc3_ram_addr),
.ov_qgc3_ram_wdata                   (wv_qgc3_ram_wdata),
.o_qgc3_ram_wr                       (w_qgc3_ram_wr),
.iv_qgc3_ram_rdata                   (wv_qgc3_ram_rdata),
.o_qgc3_ram_rd                       (w_qgc3_ram_rd),
                                      
.ov_qgc4_ram_addr                    (wv_qgc4_ram_addr),
.ov_qgc4_ram_wdata                   (wv_qgc4_ram_wdata),
.o_qgc4_ram_wr                       (w_qgc4_ram_wr),
.iv_qgc4_ram_rdata                   (wv_qgc4_ram_rdata),
.o_qgc4_ram_rd                       (w_qgc4_ram_rd),
                                      
.ov_qgc5_ram_addr                    (wv_qgc5_ram_addr),
.ov_qgc5_ram_wdata                   (wv_qgc5_ram_wdata),
.o_qgc5_ram_wr                       (w_qgc5_ram_wr),
.iv_qgc5_ram_rdata                   (wv_qgc5_ram_rdata),
.o_qgc5_ram_rd                       (w_qgc5_ram_rd),
                                      
.ov_qgc6_ram_addr                    (wv_qgc6_ram_addr),
.ov_qgc6_ram_wdata                   (wv_qgc6_ram_wdata),
.o_qgc6_ram_wr                       (w_qgc6_ram_wr),
.iv_qgc6_ram_rdata                   (wv_qgc6_ram_rdata),
.o_qgc6_ram_rd                       (w_qgc6_ram_rd),
                                    
.ov_qgc7_ram_addr                    (wv_qgc7_ram_addr),
.ov_qgc7_ram_wdata                   (wv_qgc7_ram_wdata),
.o_qgc7_ram_wr                       (w_qgc7_ram_wr),
.iv_qgc7_ram_rdata                   (wv_qgc7_ram_rdata),
.o_qgc7_ram_rd                       (w_qgc7_ram_rd)
);


global_time_sync global_time_sync_inst(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),

.iv_time_offset        (wv_time_offset_csm2gts),
.i_time_offset_wr      (w_time_offset_wr_csm2gts),
.iv_offset_period      (wv_offset_period_csm2gts),
.iv_cfg_finish         (wv_cfg_finish_csm2others),

.iv_report_period      (wv_report_period_ms_csm2gts),
.pluse_s               (pluse_s),

.ov_syned_time         (wv_syned_global_time_gts2hrp),
.o_timer_reset_pluse   (w_timer_rst_gts2others)
);
endmodule


