// Copyright (C) 1953-2020 NUDT
// Verilog module name - statistic_module
// Version: statistic_module_V1.0
// Created:
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         statistic pkt according to pulse from each module.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module pulse_statistic_module
(
       i_clk,
       i_rst_n,

       i_port_inpkt_pulse,       
       i_port_outpkt_pulse,
       i_first_node_notip_discard_pkt_pulse,
       i_fnp_fifo_overflow_pulse,

       i_fnp_inpkt_pulse,
       i_fnp_outpkt_pulse,
       i_fnp_no_1st_frag_pulse,
       i_fnp_no_not1st_frag_pulse,
       i_lnp_inpkt_pulse,
       i_lnp_outpkt_pulse,
       i_lnp_no_last_frag_flag_pulse,
       i_lnp_no_notlast_frag_flag_pulse,
       i_lnp_ibm_pkt_discard_pulse,
       i_lnp_flow_table_overflow_pulse,
 
	   i_lcm_inpkt_pulse,
       i_srm_outpkt_pulse,
       
       i_frc_discard_pkt_pulse,
       i_cim_inpkt_pulse,
       i_cim_outpkt_pulse,
       i_cim_extfifo_overflow_pulse,
       i_cim_intfifo_overflow_pulse,
       
	   i_port_rx_asynfifo_underflow_pulse,
	   i_port_rx_asynfifo_overflow_pulse ,
	   i_port_tx_asynfifo_underflow_pulse,
	   i_port_tx_asynfifo_overflow_pulse ,
	   
       i_statistic_rst,
       
       ov_port_inpkt_cnt,       
       ov_port_outpkt_cnt,
       ov_first_node_notip_discard_pkt_cnt,
       ov_fnp_fifo_overflow_cnt,

       ov_fnp_inpkt_cnt,
       ov_fnp_outpkt_cnt,
       ov_fnp_no_1st_frag_cnt,
       ov_fnp_no_not1st_frag_cnt,
       ov_lnp_inpkt_cnt,
       ov_lnp_outpkt_cnt,
       ov_lnp_no_last_frag_flag_cnt,
       ov_lnp_no_notlast_frag_flag_cnt,
       ov_lnp_ibm_pkt_discard_cnt,
       ov_lnp_flow_table_overflow_cnt,

       ov_frc_discard_pkt_cnt,
       ov_cim_inpkt_cnt,
       ov_cim_outpkt_cnt,
       ov_cim_extfifo_overflow_cnt,
       ov_cim_intfifo_overflow_cnt,

	   ov_lcm_inpkt_cnt,
       ov_srm_outpkt_cnt,

	   ov_port_rx_asynfifo_underflow_cnt,
	   ov_port_rx_asynfifo_overflow_cnt ,
	   ov_port_tx_asynfifo_underflow_cnt,
	   ov_port_tx_asynfifo_overflow_cnt	   
);
// I/O
// i_clk & rst
input                  i_clk;
input                  i_rst_n;
// pkt count pulse     
input                  i_port_inpkt_pulse;
input                  i_port_outpkt_pulse;
input                  i_first_node_notip_discard_pkt_pulse;
input                  i_fnp_fifo_overflow_pulse;
input                  i_fnp_inpkt_pulse;
input                  i_fnp_outpkt_pulse;
input                  i_fnp_no_1st_frag_pulse;
input                  i_fnp_no_not1st_frag_pulse;
input                  i_lnp_inpkt_pulse;
input                  i_lnp_outpkt_pulse;
input                  i_lnp_no_last_frag_flag_pulse;
input                  i_lnp_no_notlast_frag_flag_pulse;
input                  i_lnp_ibm_pkt_discard_pulse;
input                  i_lnp_flow_table_overflow_pulse;

input                  i_lcm_inpkt_pulse;
input                  i_srm_outpkt_pulse;

input                  i_frc_discard_pkt_pulse;
input                  i_cim_inpkt_pulse;
input                  i_cim_outpkt_pulse;
input                  i_cim_extfifo_overflow_pulse;
input                  i_cim_intfifo_overflow_pulse;

input                  i_port_rx_asynfifo_underflow_pulse;
input                  i_port_rx_asynfifo_overflow_pulse ;
input                  i_port_tx_asynfifo_underflow_pulse;
input                  i_port_tx_asynfifo_overflow_pulse ;

input                  i_statistic_rst;
// pkt Statistic
output reg[15:0]       ov_port_inpkt_cnt;       
output reg[15:0]       ov_port_outpkt_cnt;
output reg[15:0]       ov_first_node_notip_discard_pkt_cnt;
output reg[15:0]       ov_fnp_fifo_overflow_cnt;

output reg[15:0]       ov_fnp_inpkt_cnt;
output reg[15:0]       ov_fnp_outpkt_cnt;
output reg[15:0]       ov_fnp_no_1st_frag_cnt;
output reg[15:0]       ov_fnp_no_not1st_frag_cnt;
output reg[15:0]       ov_lnp_inpkt_cnt;
output reg[15:0]       ov_lnp_outpkt_cnt;
output reg[15:0]       ov_lnp_no_last_frag_flag_cnt;
output reg[15:0]       ov_lnp_no_notlast_frag_flag_cnt;
output reg[15:0]       ov_lnp_ibm_pkt_discard_cnt;
output reg[15:0]       ov_lnp_flow_table_overflow_cnt;

output reg[15:0]       ov_lcm_inpkt_cnt;
output reg[15:0]       ov_srm_outpkt_cnt;

output reg[15:0]       ov_frc_discard_pkt_cnt;
output reg[15:0]       ov_cim_inpkt_cnt;
output reg[15:0]       ov_cim_outpkt_cnt;
output reg[15:0]       ov_cim_extfifo_overflow_cnt;
output reg[15:0]       ov_cim_intfifo_overflow_cnt;

output reg[15:0]       ov_port_rx_asynfifo_underflow_cnt;
output reg[15:0]       ov_port_rx_asynfifo_overflow_cnt ;
output reg[15:0]       ov_port_tx_asynfifo_underflow_cnt;
output reg[15:0]       ov_port_tx_asynfifo_overflow_cnt;	  
//internel pkt statistic
reg       [15:0]       rv_port_inpkt_cnt;       
reg       [15:0]       rv_port_outpkt_cnt;
reg       [15:0]       rv_first_node_notip_discard_pkt_cnt;
reg       [15:0]       rv_fnp_fifo_overflow_cnt;

reg       [15:0]       rv_fnp_inpkt_cnt;
reg       [15:0]       rv_fnp_outpkt_cnt;
reg       [15:0]       rv_fnp_no_1st_frag_cnt;
reg       [15:0]       rv_fnp_no_not1st_frag_cnt;
reg       [15:0]       rv_lnp_inpkt_cnt;
reg       [15:0]       rv_lnp_outpkt_cnt;
reg       [15:0]       rv_lnp_no_last_frag_flag_cnt;
reg       [15:0]       rv_lnp_no_notlast_frag_flag_cnt;
reg       [15:0]       rv_lnp_ibm_pkt_discard_cnt;
reg       [15:0]       rv_lnp_flow_table_overflow_cnt;

reg       [15:0]       rv_lcm_inpkt_cnt;
reg       [15:0]       rv_srm_outpkt_cnt;

reg       [15:0]       rv_frc_discard_pkt_cnt;
reg       [15:0]       rv_cim_inpkt_cnt;
reg       [15:0]       rv_cim_outpkt_cnt;
reg       [15:0]       rv_cim_extfifo_overflow_cnt;
reg       [15:0]       rv_cim_intfifo_overflow_cnt;

reg       [15:0]       rv_port_rx_asynfifo_underflow_cnt;
reg       [15:0]       rv_port_rx_asynfifo_overflow_cnt ;
reg       [15:0]       rv_port_tx_asynfifo_underflow_cnt;
reg       [15:0]       rv_port_tx_asynfifo_overflow_cnt;	  
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        ov_port_inpkt_cnt<= 16'h0;       
        ov_port_outpkt_cnt<= 16'h0;
        ov_first_node_notip_discard_pkt_cnt<= 16'h0;
        ov_fnp_fifo_overflow_cnt<= 16'h0;
        
        ov_fnp_inpkt_cnt<= 16'h0;
        ov_fnp_outpkt_cnt<= 16'h0;
        ov_fnp_no_1st_frag_cnt<= 16'h0;
        ov_fnp_no_not1st_frag_cnt<= 16'h0;
        ov_lnp_inpkt_cnt<= 16'h0;
        ov_lnp_outpkt_cnt<= 16'h0;
        ov_lnp_no_last_frag_flag_cnt<= 16'h0;
        ov_lnp_no_notlast_frag_flag_cnt<= 16'h0;        
        ov_lnp_ibm_pkt_discard_cnt<= 16'h0;
        ov_lnp_flow_table_overflow_cnt<= 16'h0;
        
        ov_lcm_inpkt_cnt<= 16'h0;
        ov_srm_outpkt_cnt<= 16'h0;
        
        ov_frc_discard_pkt_cnt<= 16'h0;
        ov_cim_inpkt_cnt<= 16'h0;
        ov_cim_outpkt_cnt<= 16'h0;
        ov_cim_extfifo_overflow_cnt<= 16'h0;
        ov_cim_intfifo_overflow_cnt<= 16'h0;
        
        ov_port_rx_asynfifo_underflow_cnt<= 16'h0;
        ov_port_rx_asynfifo_overflow_cnt <= 16'h0;
        ov_port_tx_asynfifo_underflow_cnt<= 16'h0;
        ov_port_tx_asynfifo_overflow_cnt<= 16'h0;	
        
        rv_port_inpkt_cnt<= 16'h0;       
        rv_port_outpkt_cnt<= 16'h0;
        rv_frc_discard_pkt_cnt <= 16'h0;
        rv_first_node_notip_discard_pkt_cnt<= 16'h0;
        rv_fnp_fifo_overflow_cnt<= 16'h0;
        
        rv_fnp_inpkt_cnt<= 16'h0;
        rv_fnp_outpkt_cnt<= 16'h0;
        rv_fnp_no_1st_frag_cnt<= 16'h0;
        rv_fnp_no_not1st_frag_cnt<= 16'h0;
        rv_lnp_inpkt_cnt<= 16'h0;
        rv_lnp_outpkt_cnt<= 16'h0;
        rv_lnp_no_last_frag_flag_cnt<= 16'h0;
        rv_lnp_no_notlast_frag_flag_cnt<= 16'h0;
        rv_lnp_ibm_pkt_discard_cnt<= 16'h0;
        rv_lnp_flow_table_overflow_cnt<= 16'h0;
        
        rv_cim_inpkt_cnt <= 16'h0;
        rv_cim_outpkt_cnt <= 16'h0;
        rv_lcm_inpkt_cnt<= 16'h0;
        rv_srm_outpkt_cnt<= 16'h0;
        rv_cim_extfifo_overflow_cnt <= 16'h0;
        rv_cim_intfifo_overflow_cnt <= 16'h0;
        
        rv_port_rx_asynfifo_underflow_cnt<= 16'h0;
        rv_port_rx_asynfifo_overflow_cnt <= 16'h0;
        rv_port_tx_asynfifo_underflow_cnt<= 16'h0;
        rv_port_tx_asynfifo_overflow_cnt<= 16'h0;	
    end
    else begin
        if(i_statistic_rst == 1'b1)begin//reset all count 
            ov_port_inpkt_cnt <= rv_port_inpkt_cnt;       
            ov_port_outpkt_cnt <= rv_port_outpkt_cnt;
            ov_first_node_notip_discard_pkt_cnt <= rv_first_node_notip_discard_pkt_cnt;
            ov_fnp_fifo_overflow_cnt <= rv_fnp_fifo_overflow_cnt;
                                                   
            ov_fnp_inpkt_cnt <= rv_fnp_inpkt_cnt;
            ov_fnp_outpkt_cnt <= rv_fnp_outpkt_cnt;
            ov_fnp_no_1st_frag_cnt <= rv_fnp_no_1st_frag_cnt;
            ov_fnp_no_not1st_frag_cnt <= rv_fnp_no_not1st_frag_cnt;
            ov_lnp_inpkt_cnt <= rv_lnp_inpkt_cnt;
            ov_lnp_outpkt_cnt <= rv_lnp_outpkt_cnt;
            ov_lnp_no_last_frag_flag_cnt <= rv_lnp_no_last_frag_flag_cnt;
            ov_lnp_no_notlast_frag_flag_cnt <= rv_lnp_no_notlast_frag_flag_cnt;
            ov_lnp_ibm_pkt_discard_cnt <= rv_lnp_ibm_pkt_discard_cnt;
            ov_lnp_flow_table_overflow_cnt <= rv_lnp_flow_table_overflow_cnt;
                                                   
            ov_lcm_inpkt_cnt <= rv_lcm_inpkt_cnt;
            ov_srm_outpkt_cnt <= rv_srm_outpkt_cnt;
            
            ov_frc_discard_pkt_cnt <= rv_frc_discard_pkt_cnt;
            ov_cim_inpkt_cnt <= rv_cim_inpkt_cnt;
            ov_cim_outpkt_cnt <= rv_cim_outpkt_cnt;
            ov_cim_extfifo_overflow_cnt <= rv_cim_extfifo_overflow_cnt;
            ov_cim_intfifo_overflow_cnt <= rv_cim_intfifo_overflow_cnt;
                                                   
            ov_port_rx_asynfifo_underflow_cnt <= rv_port_rx_asynfifo_underflow_cnt;
            ov_port_rx_asynfifo_overflow_cnt <= rv_port_rx_asynfifo_overflow_cnt ;
            ov_port_tx_asynfifo_underflow_cnt <= rv_port_tx_asynfifo_underflow_cnt;
            ov_port_tx_asynfifo_overflow_cnt <= rv_port_tx_asynfifo_overflow_cnt;	  

			if(i_port_inpkt_pulse == 1'b1)begin
                rv_port_inpkt_cnt   <= 16'h1;
            end
            else begin
                rv_port_inpkt_cnt   <= 16'h0;
            end
            
            if(i_port_outpkt_pulse == 1'b1)begin
                rv_port_outpkt_cnt   <= 16'h1;
            end                              
            else begin                       
                rv_port_outpkt_cnt   <= 16'h0;
            end
            
            if(i_first_node_notip_discard_pkt_pulse == 1'b1)begin
                rv_first_node_notip_discard_pkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_first_node_notip_discard_pkt_cnt   <= 16'h0;
            end
            
            if(i_fnp_fifo_overflow_pulse == 1'b1)begin
                rv_fnp_fifo_overflow_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_fnp_fifo_overflow_cnt   <= 16'h0;
            end
            
            if(i_fnp_inpkt_pulse == 1'b1)begin
                rv_fnp_inpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_fnp_inpkt_cnt   <= 16'h0;
            end
            
            if(i_fnp_outpkt_pulse == 1'b1)begin
                rv_fnp_outpkt_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_fnp_outpkt_cnt   <= 16'h0;
            end
            
            if(i_fnp_no_1st_frag_pulse == 1'b1)begin
                rv_fnp_no_1st_frag_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_fnp_no_1st_frag_cnt   <= 16'h0;
            end
            
            if(i_fnp_no_not1st_frag_pulse == 1'b1)begin
                rv_fnp_no_not1st_frag_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_fnp_no_not1st_frag_cnt   <= 16'h0;
            end          
            if(i_lnp_inpkt_pulse == 1'b1)begin
                rv_lnp_inpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_lnp_inpkt_cnt   <= 16'h0;
            end
            
            if(i_lnp_outpkt_pulse == 1'b1)begin
                rv_lnp_outpkt_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_lnp_outpkt_cnt   <= 16'h0;
            end
            
            if(i_lnp_no_last_frag_flag_pulse == 1'b1)begin
                rv_lnp_no_last_frag_flag_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_lnp_no_last_frag_flag_cnt   <= 16'h0;
            end
            
            if(i_lnp_no_notlast_frag_flag_pulse == 1'b1)begin
                rv_lnp_no_notlast_frag_flag_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_lnp_no_notlast_frag_flag_cnt   <= 16'h0;
            end            
            
            if(i_lnp_ibm_pkt_discard_pulse == 1'b1)begin
                rv_lnp_ibm_pkt_discard_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_lnp_ibm_pkt_discard_cnt   <= 16'h0;
            end
            
            if(i_lnp_flow_table_overflow_pulse == 1'b1)begin
                rv_lnp_flow_table_overflow_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_lnp_flow_table_overflow_cnt   <= 16'h0;
            end
            
            if(i_lcm_inpkt_pulse == 1'b1)begin
                rv_lcm_inpkt_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_lcm_inpkt_cnt   <= 16'h0;
            end
            
            if(i_srm_outpkt_pulse == 1'b1)begin
                rv_srm_outpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_srm_outpkt_cnt   <= 16'h0;
            end

            if(i_frc_discard_pkt_pulse == 1'b1)begin
                rv_frc_discard_pkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_frc_discard_pkt_cnt   <= 16'h0;
            end            

            if(i_cim_inpkt_pulse == 1'b1)begin
                rv_cim_inpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_cim_inpkt_cnt   <= 16'h0;
            end  

            if(i_cim_outpkt_pulse == 1'b1)begin
                rv_cim_outpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_cim_outpkt_cnt   <= 16'h0;
            end  

            if(i_cim_extfifo_overflow_pulse == 1'b1)begin
                rv_cim_extfifo_overflow_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_cim_extfifo_overflow_cnt   <= 16'h0;
            end 

            if(i_cim_intfifo_overflow_pulse == 1'b1)begin
                rv_cim_intfifo_overflow_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_cim_intfifo_overflow_cnt   <= 16'h0;
            end                             
            
            if(i_port_rx_asynfifo_underflow_pulse == 1'b1)begin
                rv_port_rx_asynfifo_underflow_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_port_rx_asynfifo_underflow_cnt   <= 16'h0;
            end
            
            if(i_port_rx_asynfifo_overflow_pulse == 1'b1)begin
                rv_port_rx_asynfifo_overflow_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_port_rx_asynfifo_overflow_cnt   <= 16'h0;
            end
            
            if(i_port_tx_asynfifo_underflow_pulse == 1'b1)begin
                rv_port_tx_asynfifo_underflow_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_port_tx_asynfifo_underflow_cnt   <= 16'h0;
            end
            
            if(i_port_tx_asynfifo_overflow_pulse == 1'b1)begin
                rv_port_tx_asynfifo_overflow_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_port_tx_asynfifo_overflow_cnt   <= 16'h0;
            end
        end
        else begin//count according to pulse
            if(i_port_inpkt_pulse == 1'b1)begin
                rv_port_inpkt_cnt   <= rv_port_inpkt_cnt + 16'h1;
            end
            else begin
                rv_port_inpkt_cnt   <= rv_port_inpkt_cnt;
            end
            
            if(i_port_outpkt_pulse == 1'b1)begin
                rv_port_outpkt_cnt   <= rv_port_outpkt_cnt + 16'h1;
            end                              
            else begin                       
                rv_port_outpkt_cnt   <= rv_port_outpkt_cnt;
            end
            
            if(i_first_node_notip_discard_pkt_pulse == 1'b1)begin
                rv_first_node_notip_discard_pkt_cnt   <= rv_first_node_notip_discard_pkt_cnt + 16'h1;
            end                         
            else begin                  
                rv_first_node_notip_discard_pkt_cnt   <= rv_first_node_notip_discard_pkt_cnt;
            end
            
            if(i_fnp_fifo_overflow_pulse == 1'b1)begin
                rv_fnp_fifo_overflow_cnt   <= rv_fnp_fifo_overflow_cnt + 16'h1;
            end                               
            else begin                        
                rv_fnp_fifo_overflow_cnt   <= rv_fnp_fifo_overflow_cnt;
            end
            
            if(i_fnp_inpkt_pulse == 1'b1)begin
                rv_fnp_inpkt_cnt   <= rv_fnp_inpkt_cnt + 16'h1;
            end                         
            else begin                  
                rv_fnp_inpkt_cnt   <= rv_fnp_inpkt_cnt;
            end
            
            if(i_fnp_outpkt_pulse == 1'b1)begin
                rv_fnp_outpkt_cnt   <= rv_fnp_outpkt_cnt + 16'h1;
            end                               
            else begin                        
                rv_fnp_outpkt_cnt   <= rv_fnp_outpkt_cnt;
            end
            
            if(i_fnp_no_1st_frag_pulse == 1'b1)begin
                rv_fnp_no_1st_frag_cnt   <= rv_fnp_no_1st_frag_cnt + 16'h1;
            end                         
            else begin                  
                rv_fnp_no_1st_frag_cnt   <= rv_fnp_no_1st_frag_cnt;
            end
            
            if(i_fnp_no_not1st_frag_pulse == 1'b1)begin
                rv_fnp_no_not1st_frag_cnt   <= rv_fnp_no_not1st_frag_cnt + 16'h1;
            end                               
            else begin                        
                rv_fnp_no_not1st_frag_cnt   <= rv_fnp_no_not1st_frag_cnt;
            end          
            if(i_lnp_inpkt_pulse == 1'b1)begin
                rv_lnp_inpkt_cnt   <= rv_lnp_inpkt_cnt + 16'h1;
            end                         
            else begin                  
                rv_lnp_inpkt_cnt   <= rv_lnp_inpkt_cnt;
            end
            
            if(i_lnp_outpkt_pulse == 1'b1)begin
                rv_lnp_outpkt_cnt   <= rv_lnp_outpkt_cnt + 16'h1;
            end                               
            else begin                        
                rv_lnp_outpkt_cnt   <= rv_lnp_outpkt_cnt;
            end
            
            if(i_lnp_no_last_frag_flag_pulse == 1'b1)begin
                rv_lnp_no_last_frag_flag_cnt   <= rv_lnp_no_last_frag_flag_cnt + 16'h1;
            end                         
            else begin                  
                rv_lnp_no_last_frag_flag_cnt   <= rv_lnp_no_last_frag_flag_cnt;
            end
            
            if(i_lnp_no_notlast_frag_flag_pulse == 1'b1)begin
                rv_lnp_no_notlast_frag_flag_cnt   <= rv_lnp_no_notlast_frag_flag_cnt + 16'h1;
            end                         
            else begin                  
                rv_lnp_no_notlast_frag_flag_cnt   <= rv_lnp_no_notlast_frag_flag_cnt;
            end            
            
            if(i_lnp_ibm_pkt_discard_pulse == 1'b1)begin
                rv_lnp_ibm_pkt_discard_cnt   <= rv_lnp_ibm_pkt_discard_cnt + 16'h1;
            end                               
            else begin                        
                rv_lnp_ibm_pkt_discard_cnt   <= rv_lnp_ibm_pkt_discard_cnt;
            end
            
            if(i_lnp_flow_table_overflow_pulse == 1'b1)begin
                rv_lnp_flow_table_overflow_cnt   <= rv_lnp_flow_table_overflow_cnt + 16'h1;
            end                         
            else begin                  
                rv_lnp_flow_table_overflow_cnt   <= rv_lnp_flow_table_overflow_cnt;
            end
            
            if(i_lcm_inpkt_pulse == 1'b1)begin
                rv_lcm_inpkt_cnt   <= rv_lcm_inpkt_cnt + 16'h1;
            end                               
            else begin                        
                rv_lcm_inpkt_cnt   <= rv_lcm_inpkt_cnt;
            end
            
            if(i_srm_outpkt_pulse == 1'b1)begin
                rv_srm_outpkt_cnt   <= rv_srm_outpkt_cnt + 16'h1;
            end                         
            else begin                  
                rv_srm_outpkt_cnt   <= rv_srm_outpkt_cnt;
            end

            if(i_frc_discard_pkt_pulse == 1'b1)begin
                rv_frc_discard_pkt_cnt   <= rv_frc_discard_pkt_cnt + 16'h1;
            end                         
            else begin                  
                rv_frc_discard_pkt_cnt   <= rv_frc_discard_pkt_cnt;
            end            

            if(i_cim_inpkt_pulse == 1'b1)begin
                rv_cim_inpkt_cnt   <= rv_cim_inpkt_cnt + 16'h1;
            end                         
            else begin                  
                rv_cim_inpkt_cnt   <= rv_cim_inpkt_cnt;
            end  

            if(i_cim_outpkt_pulse == 1'b1)begin
                rv_cim_outpkt_cnt   <= rv_cim_outpkt_cnt + 16'h1;
            end                         
            else begin                  
                rv_cim_outpkt_cnt   <= rv_cim_outpkt_cnt;
            end  

            if(i_cim_extfifo_overflow_pulse == 1'b1)begin
                rv_cim_extfifo_overflow_cnt   <= rv_cim_extfifo_overflow_cnt + 16'h1;
            end                         
            else begin                  
                rv_cim_extfifo_overflow_cnt   <= rv_cim_extfifo_overflow_cnt;
            end 

            if(i_cim_intfifo_overflow_pulse == 1'b1)begin
                rv_cim_intfifo_overflow_cnt   <= rv_cim_intfifo_overflow_cnt + 16'h1;
            end                         
            else begin                  
                rv_cim_intfifo_overflow_cnt   <= rv_cim_intfifo_overflow_cnt;
            end  
            
            if(i_port_rx_asynfifo_underflow_pulse == 1'b1)begin
                rv_port_rx_asynfifo_underflow_cnt   <= rv_port_rx_asynfifo_underflow_cnt + 16'h1;
            end                               
            else begin                        
                rv_port_rx_asynfifo_underflow_cnt   <= rv_port_rx_asynfifo_underflow_cnt;
            end
            
            if(i_port_rx_asynfifo_overflow_pulse == 1'b1)begin
                rv_port_rx_asynfifo_overflow_cnt   <= rv_port_rx_asynfifo_overflow_cnt + 16'h1;
            end                         
            else begin                  
                rv_port_rx_asynfifo_overflow_cnt   <= rv_port_rx_asynfifo_overflow_cnt;
            end
            
            if(i_port_tx_asynfifo_underflow_pulse == 1'b1)begin
                rv_port_tx_asynfifo_underflow_cnt   <= rv_port_tx_asynfifo_underflow_cnt + 16'h1;
            end                               
            else begin                        
                rv_port_tx_asynfifo_underflow_cnt   <= rv_port_tx_asynfifo_underflow_cnt;
            end
            
            if(i_port_tx_asynfifo_overflow_pulse == 1'b1)begin
                rv_port_tx_asynfifo_overflow_cnt   <= rv_port_tx_asynfifo_overflow_cnt + 16'h1;
            end                         
            else begin                  
                rv_port_tx_asynfifo_overflow_cnt   <= rv_port_tx_asynfifo_overflow_cnt;
            end
        end
    end
end
endmodule

