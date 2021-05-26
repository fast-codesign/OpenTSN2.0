// Copyright (C) 1953-2020 NUDT
// Verilog module name - regroup_frag_read
// Version: regroup_frag_read_V1.0
// Created:
//         by - peng jintao 
//         at - 08.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         read all fragement of a packet.
//             - read flowid to lookup table; 
//             - write packet to ram;
//             - write last_frag_flag & bufid to ram;
///////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "./rtl/hcp/hcp_macro_define.v"

module regroup_frag_read
(
       i_clk,
       i_rst_n,
       
	   iv_bufid,
	   i_bufid_wr,
       o_pkt_last_cycle_valid,
       
	   ov_bufid,
	   o_bufid_wr,
	   i_bufid_ack,
	   
	   iv_pkt_ram_rdata,
	   o_pkt_ram_rd,
	   ov_pkt_ram_raddr,
	   
	   ov_pkt_data,
	   o_pkt_data_wr,
	   i_pkt_data_ready
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// bufid input
input       [8:0]      iv_bufid;
input           	   i_bufid_wr;
output reg	           o_pkt_last_cycle_valid;
//free bufid
output reg	[8:0]	   ov_bufid;
output reg	     	   o_bufid_wr;
input            	   i_bufid_ack;
//read pkt
input       [133:0]	   iv_pkt_ram_rdata;
output reg  	       o_pkt_ram_rd;
output reg  [11:0]	   ov_pkt_ram_raddr;
//packet output
output reg  [133:0]	   ov_pkt_data;
output reg             o_pkt_data_wr;
input                  i_pkt_data_ready;
//***************************************************
//                 read pkt 
//***************************************************
reg        [8:0]        rv_pkt_bufid;    
reg		   [2:0]		pkt_read_state;
localparam			    PKT_READ_IDLE_S = 3'd0,
                        WAIT_READY_S = 3'd1,
					    WAIT_FIRST_S = 3'd2,
						WAIT_SECOND_S   = 3'd3,
						READ_PKT_S = 3'd4;
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n == 1'b0)begin
		ov_pkt_ram_raddr <= 12'h0;
		o_pkt_ram_rd	 <= 1'b0;
        ov_pkt_data <= 134'b0;
        o_pkt_data_wr <= 1'b0;
		rv_pkt_bufid <= 9'd0;
        o_pkt_last_cycle_valid <= 1'b0;
		pkt_read_state <= PKT_READ_IDLE_S;
	end
	else begin
		case(pkt_read_state)
			PKT_READ_IDLE_S:begin 
                ov_pkt_data <= 134'b0;
                o_pkt_data_wr <= 1'b0;
                o_pkt_last_cycle_valid <= 1'b0;
				if(i_pkt_data_ready)begin
					if(i_bufid_wr)begin
						`ifdef frame_frag_version
                            ov_pkt_ram_raddr <= {iv_bufid,3'b0};
						`endif
                        `ifdef frame_notfrag_version
                            ov_pkt_ram_raddr <= {iv_bufid,7'b0};						
                        `endif	
                        o_pkt_ram_rd <= 1'b1;
                        rv_pkt_bufid <= iv_bufid;
                        pkt_read_state <= WAIT_FIRST_S;
                    end
                    else begin
                        ov_pkt_ram_raddr <= 12'b0;
                        o_pkt_ram_rd <= 1'b0;
                        rv_pkt_bufid <= 9'd0;
                        pkt_read_state <= PKT_READ_IDLE_S;                    
                    end		
				end
				else begin
                    ov_pkt_ram_raddr <= 12'b0;
                    o_pkt_ram_rd <= 1'b0;
					if(i_bufid_wr)begin
                        rv_pkt_bufid <= iv_bufid;
                        pkt_read_state <= WAIT_READY_S;
                    end
                    else begin
                        pkt_read_state <= PKT_READ_IDLE_S;                    
                    end	
				end
			end
            WAIT_READY_S:begin
				if(i_pkt_data_ready)begin
				    `ifdef frame_frag_version
                        ov_pkt_ram_raddr <= {rv_pkt_bufid,3'b0};
				    `endif
                    `ifdef frame_notfrag_version
                        ov_pkt_ram_raddr <= {rv_pkt_bufid,7'b0};
                    `endif					
                    o_pkt_ram_rd <= 1'b1;
                    pkt_read_state <= WAIT_FIRST_S;
				end
				else begin
                    ov_pkt_ram_raddr <= 12'b0;
                    o_pkt_ram_rd <= 1'b0;
                    pkt_read_state <= WAIT_READY_S;
				end            
            end
			WAIT_FIRST_S:begin 
                ov_pkt_ram_raddr <= ov_pkt_ram_raddr + 1'b1;
                o_pkt_ram_rd <= 1'b1;
                pkt_read_state <= WAIT_SECOND_S;
			end
			WAIT_SECOND_S:begin 
                ov_pkt_ram_raddr <= ov_pkt_ram_raddr + 1'b1;
                o_pkt_ram_rd <= 1'b1;
                pkt_read_state <= READ_PKT_S;
			end
			READ_PKT_S:begin
                ov_pkt_data <= iv_pkt_ram_rdata;
                o_pkt_data_wr <= 1'b1; 
                ov_pkt_ram_raddr <= ov_pkt_ram_raddr + 1'b1;                
				if(iv_pkt_ram_rdata[133:132] == 2'b10)begin
                    o_pkt_last_cycle_valid <= 1'b1;
					pkt_read_state <= PKT_READ_IDLE_S;
				end
				else begin
                    o_pkt_last_cycle_valid <= 1'b0;
                    pkt_read_state <= READ_PKT_S;
				end
			end	
			default:begin
                ov_pkt_data <= 134'b0;
                o_pkt_data_wr <= 1'b0;
		
				pkt_read_state <= PKT_READ_IDLE_S;		
			end
		endcase
	end
end
//***************************************************
//                 free pkt bufid 
//***************************************************  
reg		   [1:0]		bufid_free_state;
localparam			    BUFID_IDLE_S = 2'd0,
						WAIT_BUFID_ACK_S = 2'd1;
always @(posedge i_clk or negedge i_rst_n)begin
	if(i_rst_n == 1'b0)begin
		ov_bufid <= 9'd0;
		o_bufid_wr <= 1'b0;
        bufid_free_state <= BUFID_IDLE_S;		
	end
	else begin
	    case(bufid_free_state)
			BUFID_IDLE_S:begin
				if((o_pkt_data_wr == 1'b1) && (ov_pkt_data[133:132] == 2'b01))begin 
					ov_bufid <= rv_pkt_bufid;
					o_bufid_wr <= 1'b1;
					bufid_free_state <= WAIT_BUFID_ACK_S;
				end
				else begin
					ov_bufid <= 9'd0;
					o_bufid_wr <= 1'b0;
					bufid_free_state <= BUFID_IDLE_S;				
				end
			end
			WAIT_BUFID_ACK_S:begin
				if(i_bufid_ack == 1'b1)begin  
					o_bufid_wr	<= 1'b0;
					bufid_free_state <= BUFID_IDLE_S;	
				end
				else begin
					o_bufid_wr	<= 1'b1;
					bufid_free_state <= WAIT_BUFID_ACK_S;	
				end		
			end
			default:begin
				ov_bufid <= 9'd0;
				o_bufid_wr <= 1'b0;
				bufid_free_state <= BUFID_IDLE_S;			
			end
		endcase
	end
end
endmodule