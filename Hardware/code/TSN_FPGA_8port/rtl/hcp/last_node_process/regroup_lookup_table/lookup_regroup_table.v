// Copyright (C) 1953-2020 NUDT
// Verilog module name - lookup_regroup_table
// Version: lookup_regroup_table_V1.0
// Created:
//         by - fenglin
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         look up regroup mapping table
//             - sequential search
//             - get dmac and outport of packet; 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module lookup_regroup_table
(
       i_clk,
       i_rst_n,
       
	   iv_pkt_data,
	   //i_pkt_data_wr,
       i_fifo_empty,
	   
	   iv_regroup_ram_rdata,
	   o_regroup_ram_rd,
	   ov_regroup_ram_raddr,
	   
       ov_dmac_outport,
       o_lookup_table_match_flag,       
       o_dmac_outport_wr
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input       [133:0]    iv_pkt_data;
//input           	   i_pkt_data_wr;
input                  i_fifo_empty;
//read ram 
input       [70:0]	   iv_regroup_ram_rdata;
output reg  	       o_regroup_ram_rd;
output reg  [7:0]	   ov_regroup_ram_raddr;
//result of look up table
output reg   [56:0]	   ov_dmac_outport;
output reg             o_lookup_table_match_flag;
output reg             o_dmac_outport_wr;
//***************************************************
//           lookup table-sequential search
//***************************************************
reg        [13:0]       rv_flowid;

reg		   [2:0]		lrt_state;
localparam			    IDLE_S = 3'd0,
					    WAIT_FIRST_S = 3'd1,
						WAIT_SECOND_S = 3'd2,
						GET_DATA_S = 3'd3,
                        WAIT_TRANS_FINISH_S = 3'd4;
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n == 1'b0)begin
	    o_regroup_ram_rd <= 1'b0;
	    ov_regroup_ram_raddr <= 8'b0;

        rv_flowid <= 14'b0;
        ov_dmac_outport <= 57'b0;
        o_lookup_table_match_flag <= 1'b0;
        o_dmac_outport_wr <= 1'b0;
        
		lrt_state <= IDLE_S;
	end
	else begin
		case(lrt_state)
			IDLE_S:begin 
                ov_dmac_outport <= 57'b0;
                o_lookup_table_match_flag <= 1'b0;                
                o_dmac_outport_wr <= 1'b0;
				if((i_fifo_empty == 1'b0) && (iv_pkt_data[133:132] == 2'b01))begin
                    o_regroup_ram_rd <= 1'b1;
                    ov_regroup_ram_raddr <= 8'b0;

                    rv_flowid <= iv_pkt_data[124:111];                    
                    lrt_state <= WAIT_FIRST_S;                    
				end
				else begin
                    o_regroup_ram_rd <= 1'b0;
                    ov_regroup_ram_raddr <= 8'b0;

                    rv_flowid <= 14'b0;                           
                    lrt_state <= IDLE_S;  	
				end
			end
			WAIT_FIRST_S:begin//get data of reading ram after 2 cycles. 
                o_regroup_ram_rd <= 1'b1;
                ov_regroup_ram_raddr <= ov_regroup_ram_raddr + 1'b1;
                lrt_state <= WAIT_SECOND_S;
			end
			WAIT_SECOND_S:begin 
                o_regroup_ram_rd <= 1'b1;
                ov_regroup_ram_raddr <= ov_regroup_ram_raddr + 1'b1;
                lrt_state <= GET_DATA_S;
			end
			GET_DATA_S:begin
				if(iv_regroup_ram_rdata != 71'b0)begin//table entry is valid
					if(iv_regroup_ram_rdata[70:57] == rv_flowid)begin//match entry
						o_regroup_ram_rd <= 1'b0;
						ov_regroup_ram_raddr <= 8'b0;
						
						ov_dmac_outport <= iv_regroup_ram_rdata[56:0];
						o_lookup_table_match_flag <= 1'b1;                     
						o_dmac_outport_wr <= 1'b1;
						lrt_state <= WAIT_TRANS_FINISH_S;	                    
					end
					else begin//not match entry
						if(ov_regroup_ram_raddr == 8'h01)begin//not match all entries.
							o_regroup_ram_rd <= 1'b0;
							ov_regroup_ram_raddr <= 8'b0;
							
							ov_dmac_outport <= 57'b0; 
							o_lookup_table_match_flag <= 1'b0;                     
							o_dmac_outport_wr <= 1'b1;
							lrt_state <= WAIT_TRANS_FINISH_S;                          
						end
						else begin
							o_regroup_ram_rd <= 1'b1;
							ov_regroup_ram_raddr <= ov_regroup_ram_raddr + 1'b1;
							
							ov_dmac_outport <= 57'b0;
							o_lookup_table_match_flag <= 1'b0;                          
							o_dmac_outport_wr <= 1'b0;
							lrt_state <= GET_DATA_S;                      
						end        
					end
                end
                else begin//table entry is invalid
					o_regroup_ram_rd <= 1'b0;
					ov_regroup_ram_raddr <= 8'b0;
					
					ov_dmac_outport <= 57'b0; 
					o_lookup_table_match_flag <= 1'b0;                     
					o_dmac_outport_wr <= 1'b1;
					lrt_state <= WAIT_TRANS_FINISH_S;  
                end				
			end
            WAIT_TRANS_FINISH_S:begin
                o_regroup_ram_rd <= 1'b0;
                ov_regroup_ram_raddr <= 8'b0;

                ov_dmac_outport <= 57'b0;
                o_lookup_table_match_flag <= 1'b0;                          
                o_dmac_outport_wr <= 1'b0;             
				if(iv_pkt_data[133:132] == 2'b10)begin                  
                    lrt_state <= IDLE_S;                      
				end
                else begin
                    lrt_state <= WAIT_TRANS_FINISH_S;       
                end
            end            
			default:begin		
				lrt_state <= IDLE_S;		
			end
		endcase
	end
end
endmodule