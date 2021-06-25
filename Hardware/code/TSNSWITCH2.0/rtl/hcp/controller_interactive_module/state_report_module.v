// Copyright (C) 1953-2020 NUDT
// Verilog module name - state_report_module
// Version: state_report_module_V1.0
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         report state of hcp. 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module state_report_module 
(
       i_clk,
       i_rst_n,
       
       iv_dmac,
       iv_smac,
       //report registers
       iv_report_type,
       iv_chip_port_type,
       iv_hcp_state,
       //report count
       iv_port_inpkt_cnt,       
       iv_port_outpkt_cnt,
       iv_frc_discard_pkt_cnt,
       
       iv_pdm_first_node_notip_discard_pkt_cnt,
       
       iv_cim_inpkt_cnt,
       iv_cim_outpkt_cnt,
       iv_lcm_inpkt_cnt,
       iv_srm_outpkt_cnt,
       iv_cim_extfifo_overflow_cnt,
       iv_cim_intfifo_overflow_cnt,
       
       iv_fnp_fifo_overflow_cnt,
       iv_fnp_inpkt_cnt,
       iv_fnp_outpkt_cnt,
       iv_fnp_no_1st_frag_cnt,
       iv_fnp_no_not1st_frag_cnt,
       iv_lnp_inpkt_cnt,
       iv_lnp_outpkt_cnt,
       iv_lnp_no_notlast_frag_flag_cnt,
       iv_lnp_no_last_frag_flag_cnt,
       iv_lnp_ibm_pkt_discard_cnt,
       iv_lnp_flow_table_overflow_cnt,

       iv_port_rx_asynfifo_underflow_cnt,
       iv_port_rx_asynfifo_overflow_cnt ,
       iv_port_tx_asynfifo_underflow_cnt,
       iv_port_tx_asynfifo_overflow_cnt,	
       //count reset
       o_statistic_rst,
       //report table
       iv_5tuple_ram_rdata,
       ov_5tuple_ram_raddr,
       ov_5tuple_ram_rd,
       i_5tupleram_read_write_conflict,
       
       iv_regroup_ram_rdata,
       ov_regroup_ram_raddr,
       ov_regroup_ram_rd,
       i_regroupram_read_write_conflict,
       //report data output
       i_report_pulse,
       o_state_report_pulse,
       ov_data,
       o_data_wr
);

// clk & rst
input                 i_clk;
input                 i_rst_n;
// dmac and smac of tsmp frame from controller
input     [47:0]      iv_dmac;
input     [47:0]      iv_smac;

////////////report registers//////////////
// report registers or table
input     [15:0]       iv_report_type;
// type of 8 ports of tsn chip
input     [7:0]        iv_chip_port_type;
// type of 8 ports of tsn chip
input     [1:0]        iv_hcp_state;

////////////report count//////////////
input     [15:0]       iv_port_inpkt_cnt;       
input     [15:0]       iv_port_outpkt_cnt;
input     [15:0]       iv_frc_discard_pkt_cnt;
input     [15:0]       iv_pdm_first_node_notip_discard_pkt_cnt;
input     [15:0]       iv_fnp_fifo_overflow_cnt;
                       
input     [15:0]       iv_fnp_inpkt_cnt;
input     [15:0]       iv_fnp_outpkt_cnt;
input     [15:0]       iv_fnp_no_1st_frag_cnt;
input     [15:0]       iv_fnp_no_not1st_frag_cnt;
input     [15:0]       iv_lnp_inpkt_cnt;
input     [15:0]       iv_lnp_outpkt_cnt;
input     [15:0]       iv_lnp_no_notlast_frag_flag_cnt;
input     [15:0]       iv_lnp_no_last_frag_flag_cnt;
input     [15:0]       iv_lnp_ibm_pkt_discard_cnt;
input     [15:0]       iv_lnp_flow_table_overflow_cnt;

input     [15:0]       iv_cim_inpkt_cnt;
input     [15:0]       iv_cim_outpkt_cnt;                      
input     [15:0]       iv_lcm_inpkt_cnt;
input     [15:0]       iv_srm_outpkt_cnt;
input     [15:0]       iv_cim_extfifo_overflow_cnt;
input     [15:0]       iv_cim_intfifo_overflow_cnt;
                       
input     [15:0]       iv_port_rx_asynfifo_underflow_cnt;
input     [15:0]       iv_port_rx_asynfifo_overflow_cnt ;
input     [15:0]       iv_port_tx_asynfifo_underflow_cnt;
input     [15:0]       iv_port_tx_asynfifo_overflow_cnt;	
 
/////////////count reset//////////////      
output reg             o_statistic_rst;

////////////report table/////////////
// 5tuple mapping table & regroup mapping table
input      [151:0]     iv_5tuple_ram_rdata;
output reg [4:0]       ov_5tuple_ram_raddr;
output reg             ov_5tuple_ram_rd;
input                  i_5tupleram_read_write_conflict;

input      [70:0]      iv_regroup_ram_rdata;
output reg [7:0]       ov_regroup_ram_raddr;
output reg             ov_regroup_ram_rd;
input                  i_regroupram_read_write_conflict;
// report data output
input                  i_report_pulse;//trigger by nmac report frame of tsn chip.
output reg [133:0]     ov_data;
output reg             o_data_wr;

output reg             o_state_report_pulse;//for report cnt
//***************************************************
//               state report
//***************************************************
reg     [15:0]         rv_report_type;
reg     [127:0]        rv_5tuple_ram_rdata;
reg     [6:0]          rv_pkt_cycle_cnt;
reg     [2:0]          srm_state;
localparam             IDLE_S = 3'd0,
                       TRANS_METADATA_S = 3'd1,
                       TRANS_ETH_S = 3'd4,
                       REPORT_REGISTERS_S = 3'd5,
                       REPORT_5TUPLE_TABLE_S = 3'd6,
                       REPORT_REGROUP_TABLE_S = 3'd7;
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin 
        ov_5tuple_ram_raddr <= 5'b0;
        ov_5tuple_ram_rd <= 1'b0;
        rv_5tuple_ram_rdata <= 128'b0;
        
        ov_regroup_ram_raddr <= 8'b0;
        ov_regroup_ram_rd <= 1'b0;        
        
        ov_data <= 134'b0;
        o_data_wr  <= 1'b0;
        o_state_report_pulse <= 1'b0;
        o_statistic_rst <= 1'b0;
        
        rv_report_type <= 16'h0;
        rv_pkt_cycle_cnt <= 7'b0;
        
        srm_state       <= IDLE_S;
    end
    else begin
        case(srm_state)
            IDLE_S:begin 
                rv_5tuple_ram_rdata <= 128'b0;
                
                ov_data <= 134'b0;
                o_data_wr <= 1'b0;
                o_state_report_pulse <= 1'h0;
                o_statistic_rst <= 1'b0;
                
                rv_pkt_cycle_cnt <= 7'b0;                
                if(i_report_pulse == 1'b1)begin
                    rv_report_type <= iv_report_type;//cache value of iv_report_type to avoid error when the iv_report_type is changed.    
                    if(iv_report_type[15:12] == 4'h0)begin//report registers
                        ov_5tuple_ram_raddr <= 5'b0;
                        ov_5tuple_ram_rd <= 1'b0;
                        ov_regroup_ram_raddr <= 8'b0;
                        ov_regroup_ram_rd <= 1'b0; 
                        if(iv_report_type[11:0] == 12'h0)begin
                            srm_state <= TRANS_METADATA_S;        
                        end
                        else begin 
                            srm_state <= IDLE_S;    
                        end                                    
                    end
                    else if(iv_report_type[15:12] == 4'h1)begin//report 5tuple mapping table
                        ov_regroup_ram_raddr <= 8'b0;
                        ov_regroup_ram_rd <= 1'b0;                      
                        if(iv_report_type[11:0] <= 12'hf)begin//delay of reading ram is 2 cycles;and delay of ram_interface_arbitration is 1 cycle.
                            ov_5tuple_ram_raddr <= {iv_report_type[3:0],1'b0};
                            ov_5tuple_ram_rd <= 1'b1;
                            srm_state <= TRANS_METADATA_S; 
                        end
                        else begin
                            ov_5tuple_ram_raddr <= 5'b0;
                            ov_5tuple_ram_rd <= 1'b0;
                            srm_state <= IDLE_S; 
                        end                          
                    end
                    else if(iv_report_type[15:12] == 4'h2)begin//report regroup mapping table
                        ov_5tuple_ram_raddr <= 5'b0;
                        ov_5tuple_ram_rd <= 1'b0;                       
                        if(iv_report_type[11:0] <= 12'h7ff)begin//delay of reading ram is 2 cycles;and delay of ram_interface_arbitration is 1 cycle.
                            ov_regroup_ram_raddr <= {iv_report_type[5:0],2'b0};
                            ov_regroup_ram_rd <= 1'b1;                         
                            srm_state <= TRANS_METADATA_S; 
                        end
                        else begin
                            ov_regroup_ram_raddr <= 8'b0;
                            ov_regroup_ram_rd <= 1'b0;
                            srm_state <= IDLE_S; 
                        end                               
                    end
                    else begin
                        ov_regroup_ram_raddr <= 8'b0;
                        ov_regroup_ram_rd <= 1'b0; 
                        ov_5tuple_ram_raddr <= 5'b0;
                        ov_5tuple_ram_rd <= 1'b0;
                        srm_state <= IDLE_S;                         
                    end
                end
                else begin
                    ov_regroup_ram_raddr <= 8'b0;
                    ov_regroup_ram_rd <= 1'b0; 
                    ov_5tuple_ram_raddr <= 5'b0;
                    ov_5tuple_ram_rd <= 1'b0;
                    srm_state <= IDLE_S;                 
                end
            end
            TRANS_METADATA_S:begin               
                rv_pkt_cycle_cnt <= 7'b0;
                rv_5tuple_ram_rdata <= 128'b0;
                
                ov_data[133:128] <= 6'b010000;
                ov_data[127:125] <= 3'b110;//pkt type:BE frame
                ov_data[124:111] <= 14'b0;//5bit injection address and 9bit outport.
                ov_data[110] <= 1'b1;//lookup_en
                ov_data[109] <= 1'b1;//frag_last
                ov_data[108:0] <= 109'b0;                
                o_data_wr <= 1'b1;
                
                o_state_report_pulse <= 1'h1;
                srm_state <= TRANS_ETH_S;                 
                if(rv_report_type[15:12] == 4'h0)begin//report registers
                    ov_5tuple_ram_raddr <= 5'b0;
                    ov_5tuple_ram_rd <= 1'b0;
                    ov_regroup_ram_raddr <= 8'b0;
                    ov_regroup_ram_rd <= 1'b0; 
                    
                    o_statistic_rst <= 1'b1;                                         
                end
                else if(iv_report_type[15:12] == 4'h1)begin//report 5tuple mapping table
                    ov_regroup_ram_raddr <= 8'b0;
                    ov_regroup_ram_rd <= 1'b0; 
                    o_statistic_rst <= 1'b0; 
                    
                    ov_5tuple_ram_raddr <= ov_5tuple_ram_raddr;
                    ov_5tuple_ram_rd <= 1'b0;                         
                end
                else if(iv_report_type[15:12] == 4'h2)begin//report regroup mapping table
                    ov_5tuple_ram_raddr <= 5'b0;
                    ov_5tuple_ram_rd <= 1'b0;
                    o_statistic_rst <= 1'b0;                        

                    ov_regroup_ram_raddr <= ov_regroup_ram_raddr + 1'b1;
                    ov_regroup_ram_rd <= 1'b1;                                               
                end
                else begin
                    ov_regroup_ram_raddr <= 8'b0;
                    ov_regroup_ram_rd <= 1'b0; 
                    o_statistic_rst <= 1'b0; 
                    ov_5tuple_ram_raddr <= 5'b0;
                    ov_5tuple_ram_rd <= 1'b0;                    
                end
            end         
            TRANS_ETH_S:begin
                o_statistic_rst <= 1'b0;
                o_state_report_pulse <= 1'h0;
                rv_pkt_cycle_cnt <= 7'b0;
                rv_5tuple_ram_rdata <= 128'b0;
                
                ov_data[133:128] <= 6'b110000;
                //ov_data[127:80] <= iv_smac; 
                ov_data[127:80] <= {iv_smac[47:24],8'h04,iv_smac[15:0]};//exchange the dmac and smac of  tsmp frame from controller;iv_smac[23:16] is revised to store subtype to recognize conveniently.                
                ov_data[79:32] <= iv_dmac; 
                ov_data[31:16] <= 16'hff01; //eth type
                ov_data[15:8] <= 8'h04;//state of hcp report frame 
                ov_data[7:0] <= 8'h00;
                o_data_wr <= 1'b1;
                if(rv_report_type[15:12] == 4'h0)begin//report registers
                    ov_regroup_ram_raddr <= 8'b0;
                    ov_regroup_ram_rd <= 1'b0; 
                    ov_5tuple_ram_raddr <= 5'b0;
                    ov_5tuple_ram_rd <= 1'b0;                    
                    srm_state <= REPORT_REGISTERS_S;                  
                end
                else if(rv_report_type[15:12] == 4'h1)begin//report 5tuple mapping table
                    ov_regroup_ram_raddr <= 8'b0;
                    ov_regroup_ram_rd <= 1'b0; 
                    ov_5tuple_ram_raddr <= ov_5tuple_ram_raddr + 1'b1;
                    ov_5tuple_ram_rd <= 1'b1;                       
                    srm_state <= REPORT_5TUPLE_TABLE_S;       
                end
                else if(rv_report_type[15:12] == 4'h2)begin//report 5tuple mapping table
                    ov_regroup_ram_raddr <= ov_regroup_ram_raddr + 1'b1;
                    ov_regroup_ram_rd <= 1'b1; 
                    ov_5tuple_ram_raddr <= 5'b0;
                    ov_5tuple_ram_rd <= 1'b0;                       
                    srm_state <= REPORT_REGROUP_TABLE_S;                   
                end
                else begin
                    srm_state <= IDLE_S; 
                end
            end
            REPORT_REGISTERS_S:begin
                o_statistic_rst   <= 1'b0;
                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 1'b1;
                o_state_report_pulse <= 1'h0;
                o_data_wr <= 1'b1;
                case(rv_pkt_cycle_cnt)
                    7'h0:begin
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:112] <= rv_report_type; 
                        ov_data[111:104] <= iv_chip_port_type; 
                        ov_data[103:96] <= {6'b0,iv_hcp_state};
                        ov_data[95:0] <= 96'b0;//reserve
                        srm_state <= REPORT_REGISTERS_S;  
                    end
                    7'h1:begin//registers of iip
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:112] <= iv_port_inpkt_cnt; 
                        ov_data[111:96] <= iv_port_rx_asynfifo_overflow_cnt; 
                        ov_data[95:80] <= iv_port_rx_asynfifo_underflow_cnt;
                        ov_data[79:64] <= iv_frc_discard_pkt_cnt;
                        ov_data[63:0] <= 64'b0;//reserve
                        srm_state <= REPORT_REGISTERS_S;  
                    end 
                    7'h2:begin//registers of pdm
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:112] <= iv_pdm_first_node_notip_discard_pkt_cnt; 
                        ov_data[111:0] <= 112'b0;//reserve
                        srm_state <= REPORT_REGISTERS_S;  
                    end 
                    7'h3:begin//registers of cim
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:112] <= iv_cim_inpkt_cnt; 
                        ov_data[111:96] <= iv_cim_outpkt_cnt; 
                        ov_data[95:80] <= iv_lcm_inpkt_cnt; 
                        ov_data[79:64] <= iv_srm_outpkt_cnt; 
                        ov_data[63:48] <= iv_cim_extfifo_overflow_cnt; 
                        ov_data[47:32] <= iv_cim_intfifo_overflow_cnt; 
                        ov_data[31:0] <= 32'b0;//reserve
                        srm_state <= REPORT_REGISTERS_S;  
                    end
                    7'h4:begin//registers of fnp
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:112] <= iv_fnp_inpkt_cnt; 
                        ov_data[111:96] <= iv_fnp_outpkt_cnt; 
                        ov_data[95:80] <= iv_fnp_fifo_overflow_cnt; 
                        ov_data[79:64] <= iv_fnp_no_1st_frag_cnt; 
                        ov_data[63:48] <= iv_fnp_no_not1st_frag_cnt; 
                        ov_data[47:0] <= 48'b0;//reserve
                        srm_state <= REPORT_REGISTERS_S;  
                    end 
                    7'h5:begin//registers of lnp
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:112] <= iv_lnp_inpkt_cnt; 
                        ov_data[111:96] <= iv_lnp_outpkt_cnt; 
                        ov_data[95:80] <= iv_lnp_no_notlast_frag_flag_cnt;                       
                        ov_data[79:64] <= iv_lnp_no_last_frag_flag_cnt; 
                        ov_data[63:48] <= iv_lnp_ibm_pkt_discard_cnt; 
                        ov_data[47:32] <= iv_lnp_flow_table_overflow_cnt; 
                        ov_data[31:0] <= 32'b0;//reserve
                        srm_state <= REPORT_REGISTERS_S;  
                    end 
                    7'h6:begin//registers of iop
                        ov_data[133:128] <= 6'b100000;
                        ov_data[127:112] <= iv_port_outpkt_cnt; 
                        ov_data[111:96] <= iv_port_tx_asynfifo_overflow_cnt; 
                        ov_data[95:80] <= iv_port_tx_asynfifo_underflow_cnt;                       
                        ov_data[79:0] <= 80'b0;//reserve
                        srm_state <= IDLE_S;  
                    end
                    default:begin
                        srm_state <= IDLE_S;  
                    end
                endcase                    
            end
            REPORT_5TUPLE_TABLE_S:begin
                ov_regroup_ram_raddr <= 8'b0;
                ov_regroup_ram_rd <= 1'b0; 

                ov_5tuple_ram_raddr <= 5'b0;
                ov_5tuple_ram_rd <= 1'b0;                  
                
                o_statistic_rst <= 1'b0;
                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 1'b1;
                o_state_report_pulse <= 1'h0;
                o_data_wr <= 1'b1;
                case(rv_pkt_cycle_cnt)                
                    7'h0:begin
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:112] <= rv_report_type; 
                        ov_data[111:0] <= 112'b0;              

                        rv_5tuple_ram_rdata <= 128'b0;
                        srm_state <= REPORT_5TUPLE_TABLE_S;       
                    end
                    7'h1:begin
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:25] <= 103'b0;
                        ov_data[24] <= i_5tupleram_read_write_conflict;                        
                        ov_data[23:0] <= iv_5tuple_ram_rdata[151:128]; 
                        rv_5tuple_ram_rdata <= iv_5tuple_ram_rdata[127:0];
                        
                        srm_state <= REPORT_5TUPLE_TABLE_S;       
                    end
                    7'h2:begin
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:0] <= rv_5tuple_ram_rdata; 
                        rv_5tuple_ram_rdata <= 128'b0;
                        
                        srm_state <= REPORT_5TUPLE_TABLE_S;       
                    end
                    7'h3:begin
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:25] <= 103'b0;
                        ov_data[24] <= i_5tupleram_read_write_conflict;                             
                        ov_data[23:0] <= iv_5tuple_ram_rdata[151:128]; 
                        rv_5tuple_ram_rdata <= iv_5tuple_ram_rdata[127:0];
                        
                        srm_state <= REPORT_5TUPLE_TABLE_S;       
                    end
                    7'h4:begin
                        ov_data[133:128] <= 6'b100000;
                        ov_data[127:0] <= rv_5tuple_ram_rdata; 
                        rv_5tuple_ram_rdata <= 128'b0;
                        
                        srm_state <= IDLE_S;       
                    end                      
                    default:srm_state <= IDLE_S;    
                endcase
            end                     
            REPORT_REGROUP_TABLE_S:begin    
                ov_5tuple_ram_raddr <= 5'b0;
                ov_5tuple_ram_rd <= 1'b0;  
                
                o_statistic_rst <= 1'b0;
                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 1'b1;
                o_state_report_pulse <= 1'h0;
                o_data_wr <= 1'b1;
                case(rv_pkt_cycle_cnt)                
                    7'h0:begin
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:112] <= rv_report_type; 
                        ov_data[111:0] <= 112'b0; 
                        
                        ov_regroup_ram_raddr <= ov_regroup_ram_raddr + 1'b1;
                        ov_regroup_ram_rd <= 1'b1; 
                        
                        srm_state <= REPORT_REGROUP_TABLE_S;       
                    end
                    7'h1:begin
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:78] <= 50'b0; 
                        ov_data[77:0] <= {iv_regroup_ram_rdata[70:57],iv_regroup_ram_rdata[56:9],6'b0,i_regroupram_read_write_conflict,iv_regroup_ram_rdata[8:0]}; 
                        
                        ov_regroup_ram_raddr <= 8'b0;
                        ov_regroup_ram_rd <= 1'b0; 
                        
                        srm_state <= REPORT_REGROUP_TABLE_S;       
                    end
                    7'h2:begin
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:78] <= 50'b0; 
                        ov_data[77:0] <= {iv_regroup_ram_rdata[70:57],iv_regroup_ram_rdata[56:9],6'b0,i_regroupram_read_write_conflict,iv_regroup_ram_rdata[8:0]}; 
                        
                        ov_regroup_ram_raddr <= 8'b0;
                        ov_regroup_ram_rd <= 1'b0; 
                        
                        srm_state <= REPORT_REGROUP_TABLE_S;      
                    end
                    7'h3:begin
                        ov_data[133:128] <= 6'b110000;
                        ov_data[127:78] <= 50'b0; 
                        ov_data[77:0] <= {iv_regroup_ram_rdata[70:57],iv_regroup_ram_rdata[56:9],6'b0,i_regroupram_read_write_conflict,iv_regroup_ram_rdata[8:0]}; 
                        
                        ov_regroup_ram_raddr <= 8'b0;
                        ov_regroup_ram_rd <= 1'b0; 
                        
                        srm_state <= REPORT_REGROUP_TABLE_S;         
                    end
                    7'h4:begin
                        ov_data[133:128] <= 6'b100000;
                        ov_data[127:78] <= 50'b0; 
                        ov_data[77:0] <= {iv_regroup_ram_rdata[70:57],iv_regroup_ram_rdata[56:9],6'b0,i_regroupram_read_write_conflict,iv_regroup_ram_rdata[8:0]}; 
                        
                        ov_regroup_ram_raddr <= 8'b0;
                        ov_regroup_ram_rd <= 1'b0; 
                        
                        srm_state <= IDLE_S;         
                    end           
                    default:srm_state <= IDLE_S;    
                endcase
            end                
            default:begin
                ov_5tuple_ram_raddr <= 5'b0;
                ov_5tuple_ram_rd <= 1'b0;
                
                ov_regroup_ram_raddr <= 8'b0;
                ov_regroup_ram_rd <= 1'b0;        
                
                ov_data <= 134'b0;
                o_data_wr  <= 1'b0;
                o_state_report_pulse <= 1'b0;
                o_statistic_rst <= 1'b0;
                
                rv_report_type <= 16'h0;
                rv_pkt_cycle_cnt <= 7'b0;
                
                srm_state <= IDLE_S;
            end
        endcase
    end
end
endmodule