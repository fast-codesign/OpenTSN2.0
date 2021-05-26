// Copyright (C) 1953-2020 NUDT
// Verilog module name - regroup_input_buffer
// Version: regroup_input_buffer_V1.0
// Created:
//         by - peng jintao
//         at - 08.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         management of input buffer.
//             - extract flowid to lookup table; 
//             - write packet to ram;
//             - write last_frag_flag & bufid to ram;
///////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "./rtl/hcp/hcp_macro_define.v"

module regroup_input_buffer
(
       i_clk,
       i_rst_n,
       
       iv_pkt_data,
	   i_pkt_data_wr,
	   
	   iv_bufid,
	   i_bufid_wr,
	   o_bufid_ack,
	   
	   ov_pkt_ram_wdata,
	   o_pkt_ram_wr,
	   ov_pkt_ram_waddr,
	   
	   ov_flowid,
       ov_frag_id,
	   o_last_frag_flag,
	   o_flowid_wr,

	   iv_queue_id,
	   iv_queue_usedw,
	   i_queue_id_wr,
	   
	   ov_queue_ram_wdata,
	   o_queue_ram_wr,
	   ov_queue_ram_waddr,
       
       o_ibm_discard_pulse
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input from PDM
input	   [133:0]	   iv_pkt_data;
input	         	   i_pkt_data_wr;
// bufid input from PBM
input	   [8:0]	   iv_bufid;
input	         	   i_bufid_wr;
output reg        	   o_bufid_ack;
//write pkt to PBM 
output reg [133:0]	   ov_pkt_ram_wdata;
output reg  	       o_pkt_ram_wr;
output reg [11:0]	   ov_pkt_ram_waddr;
//information of packet used to lookup table
output reg [13:0]	   ov_flowid;
output reg [3:0]       ov_frag_id;//the signal is only used to judge whether frag is losing and used in flow_table_update.
output reg             o_last_frag_flag;
output reg             o_flowid_wr;
//result of lookup table
input      [4:0]	   iv_queue_id;
input      [3:0]       iv_queue_usedw;
input          	       i_queue_id_wr;
//write bufid & last_frag_flag to queue_ram
output reg [9:0]	   ov_queue_ram_wdata;
output reg             o_queue_ram_wr;
output reg [8:0]       ov_queue_ram_waddr; 

output reg             o_ibm_discard_pulse;
//***************************************************
//          	write pkt to ram
//***************************************************
reg   [8:0]    rv_bufid; 
reg            r_last_frag_flag;  
reg   [2:0]    ibm_state;
localparam  IDLE_S = 3'd0,
            TRANS_S = 3'd1,
			DISC_S = 3'd2;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_pkt_ram_wdata <= 134'b0;
		o_pkt_ram_wr <= 1'b0;
		ov_pkt_ram_waddr <= 12'b0;
		
        o_bufid_ack <= 1'b0;
        rv_bufid <= 9'b0;
        r_last_frag_flag <= 1'b0;
        
        ov_flowid <= 14'h0;
        ov_frag_id <= 4'b0;
        o_last_frag_flag <= 1'b0;
        o_flowid_wr <= 1'b0;
        
        o_ibm_discard_pulse <= 1'b0;
        
		ibm_state <= IDLE_S;
    end
    else begin
		case(ibm_state)
			IDLE_S:begin
			    if(i_pkt_data_wr == 1'b1)begin
				    if(i_bufid_wr == 1'b1)begin //bufid isn't used up
						ov_pkt_ram_wdata <= iv_pkt_data;
						o_pkt_ram_wr <= 1'b1;
						`ifdef frame_frag_version
						    ov_pkt_ram_waddr <= {iv_bufid,3'b0};//base address
						`endif
                        `ifdef frame_notfrag_version
						    ov_pkt_ram_waddr <= {iv_bufid,7'b0};//base address
                        `endif						
                        o_bufid_ack <= 1'b1;
                        rv_bufid <= iv_bufid;
                        r_last_frag_flag <= iv_pkt_data[94];//0:middle fragment; 1:last fragment
                        
                        ov_flowid <= iv_pkt_data[124:111];//flowid
                        ov_frag_id <= iv_pkt_data[93:90];//frag id; //the signal is only used to judge whether frag is losing and used in flow_table_update.
                        o_last_frag_flag <= iv_pkt_data[94];//0:middle fragment; 1:last fragment
                        o_flowid_wr <= 1'b1;
                        
                        o_ibm_discard_pulse <= 1'b0;                        
						ibm_state <= TRANS_S;				
					end
					else begin//bufid is used up
						ov_pkt_ram_wdata <= 134'b0;
						o_pkt_ram_wr <= 1'b0;
						ov_pkt_ram_waddr <= 12'b0;
                        o_bufid_ack <= 1'b0;
                        
                        ov_flowid <= 14'b0;//flowid
                        ov_frag_id <= 4'b0;//frag id
                        o_last_frag_flag <= 1'b0;//0:middle fragment; 1:last fragment
                        o_flowid_wr <= 1'b0;

                        o_ibm_discard_pulse <= 1'b1;                             
						ibm_state <= DISC_S;				
					end
				end
				else begin
					ov_pkt_ram_wdata <= 134'b0;
					o_pkt_ram_wr <= 1'b0;
					ov_pkt_ram_waddr <= 12'b0;
                    o_bufid_ack <= 1'b0;

                    ov_flowid <= 14'b0;//flowid
                    ov_frag_id <= 4'b0;//frag id
                    o_last_frag_flag <= 1'b0;//0:middle fragment; 1:last fragment
                    o_flowid_wr <= 1'b0; 

                    o_ibm_discard_pulse <= 1'b0;                         
					ibm_state <= IDLE_S;					
				end
			end
            TRANS_S:begin 
                ov_pkt_ram_wdata <= iv_pkt_data;
                o_pkt_ram_wr <= 1'b1;
                ov_pkt_ram_waddr <= ov_pkt_ram_waddr + 1'b1;
                o_bufid_ack <= 1'b0;
                
                ov_flowid <= 14'b0;//flowid
                ov_frag_id <= 4'b0;//frag id
                o_last_frag_flag <= 1'b0;//0:middle fragment; 1:last fragment
                o_flowid_wr <= 1'b0; 

                o_ibm_discard_pulse <= 1'b0;                 
                if(iv_pkt_data[133:132] == 2'b10)begin
                    ibm_state <= IDLE_S;	
                end
                else begin
                    ibm_state <= TRANS_S;
                end
            end
            DISC_S:begin 
                ov_pkt_ram_wdata <= 134'b0;
                o_pkt_ram_wr <= 1'b0;
                ov_pkt_ram_waddr <= 12'b0;
                o_bufid_ack <= 1'b0;
                
                o_ibm_discard_pulse <= 1'b0;     
                if(iv_pkt_data[133:132] == 2'b10)begin
                    ibm_state <= IDLE_S;	
                end
                else begin
                    ibm_state <= DISC_S;
                end
            end
			default:begin				
				ibm_state <= IDLE_S;
			end
		endcase
    end
end	
//***************************************************
//         write result of lookup table to ram
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_queue_ram_wdata <= 10'b0;
		o_queue_ram_wr <= 1'b0;
		ov_queue_ram_waddr <= 9'b0;
    end
    else begin
        if(i_queue_id_wr)begin
            ov_queue_ram_wdata <= {r_last_frag_flag,rv_bufid};
		    o_queue_ram_wr <= 1'b1;
            ov_queue_ram_waddr <= {iv_queue_id,4'b0} + {5'b0,iv_queue_usedw};
        end
        else begin
            ov_queue_ram_wdata <= 10'b0;
		    o_queue_ram_wr <= 1'b0;
            ov_queue_ram_waddr <= 9'b0;
        end
    end
end	
endmodule 