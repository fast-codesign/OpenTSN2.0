// Copyright (C) 1953-2020 NUDT
// Verilog module name - frame_regroup_modify
// Version: frame_regroup_modify_V1.0
// Created:
//         by - fenglin
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         modify frame according to result of lookup table.
//             - replace tsntag of first frag with dmac;
//             - discard the first 16B of middle frag or last frag;
//             - add 16B metadata;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module frame_regroup_modify
(
        i_clk,
        i_rst_n,
       
	    i_fifo_empty,
        o_fifo_rd,
        iv_fifo_data,
	   
	    iv_dmac_outport,
	    i_lookup_table_match_flag,
	    i_dmac_outport_wr,
	   
        iv_fifo_usedw,
	    ov_pkt_data,
	    o_pkt_data_wr
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// read fifo
input	               i_fifo_empty;
output reg             o_fifo_rd;
input       [133:0]    iv_fifo_data;
// result of lookup table.
input       [56:0]	   iv_dmac_outport;
input                  i_lookup_table_match_flag;
input                  i_dmac_outport_wr;
//fifo state
input       [6:0]      iv_fifo_usedw;
//packet output
output reg  [133:0]	   ov_pkt_data;
output reg             o_pkt_data_wr;
//***************************************************
// modify frame according to result of lookup table
//***************************************************
reg        [56:0]	    rv_dmac_outport;
reg		   [2:0]		frm_state;
localparam			    IDLE_S = 3'd0,
                        WAIT_S = 3'd1,
					    TRANS_FIRST_CYCLE_S = 3'd2,
                        TRANS_NFIRST_FRAG_S = 3'd3,
                        TRANS_PKT_S = 3'd4,
						DISC_PKT_S = 3'd5;
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n == 1'b0)begin
	    o_fifo_rd <= 1'b0;

        ov_pkt_data <= 134'b0;
        o_pkt_data_wr <= 1'b0;
        rv_dmac_outport <= 57'b0;
		frm_state <= IDLE_S;
	end
	else begin
		case(frm_state)
			IDLE_S:begin 
				if((i_dmac_outport_wr == 1'b1) && (i_lookup_table_match_flag == 1'b1))begin//match entry
                    if(iv_fifo_usedw <= 7'd20)begin
                        if(i_fifo_empty == 1'b0)begin
						    ov_pkt_data[133:128] <= 6'b01_0000;//transmit 16B metadata
							ov_pkt_data[124:0] <= {iv_fifo_data[89:85],iv_dmac_outport[8:0],1'b0,iv_fifo_data[94],109'b0};
						    if((iv_fifo_data[127:125] == 3'h0) || (iv_fifo_data[127:125] == 3'h1) || (iv_fifo_data[127:125] == 3'h2))begin
                                ov_pkt_data[127:125] <= 3'h3;
                            end
							else begin
							    ov_pkt_data[127:125] <= iv_fifo_data[127:125];
							end
							o_fifo_rd <= 1'b1;
                            rv_dmac_outport <= iv_dmac_outport;
                            if(iv_fifo_data[79:0] == 80'h0)begin//not first frag
                                o_pkt_data_wr <= 1'b0;
                                frm_state <= TRANS_NFIRST_FRAG_S;  
                            end
                            else begin//first frag
                                o_pkt_data_wr <= 1'b1;
                                frm_state <= TRANS_FIRST_CYCLE_S;  
                            end                    
                        end
                        else begin
                            ov_pkt_data <= 134'b0;
                            o_pkt_data_wr <= 1'b0;
                            o_fifo_rd <= 1'b0;
                            rv_dmac_outport <= 57'b0;
                            frm_state <= IDLE_S;  	
                        end
                    end
                    else begin
                        ov_pkt_data <= 134'b0;
                        o_pkt_data_wr <= 1'b0;
                        o_fifo_rd <= 1'b0;                    
                        if(i_fifo_empty == 1'b0)begin
                            rv_dmac_outport <= iv_dmac_outport;                       
                            frm_state <= WAIT_S;
                        end
                        else begin
                            rv_dmac_outport <= 57'b0;     
                            frm_state <= IDLE_S;
                        end
                    end
                end                    
				else if((i_dmac_outport_wr == 1'b1) && (i_lookup_table_match_flag == 1'b0))begin//not match entry
                    rv_dmac_outport <= 57'b0;
                    if(i_fifo_empty == 1'b0)begin
                        ov_pkt_data <= 134'b0; 
                        o_pkt_data_wr <= 1'b0;
                        o_fifo_rd <= 1'b1;
                       
                        frm_state <= DISC_PKT_S;                         
                    end
                    else begin
                        ov_pkt_data <= 134'b0; 
                        o_pkt_data_wr <= 1'b0;                        
                        o_fifo_rd <= 1'b0;
                        
                        frm_state <= IDLE_S;  
                    end 
				end
                else begin
                    ov_pkt_data <= 134'b0; 
                    o_pkt_data_wr <= 1'b0;  
                    
                    o_fifo_rd <= 1'b0;
                    rv_dmac_outport <= 57'b0;
                    frm_state <= IDLE_S;                  
                end
			end
            WAIT_S:begin
                if(iv_fifo_usedw <= 7'd20)begin
					ov_pkt_data[133:128] <= 6'b01_0000;//transmit 16B metadata
					ov_pkt_data[124:0] <= {iv_fifo_data[89:85],rv_dmac_outport[8:0],1'b0,iv_fifo_data[94],109'b0};
					if((iv_fifo_data[127:125] == 3'h0) || (iv_fifo_data[127:125] == 3'h1) || (iv_fifo_data[127:125] == 3'h2))begin
						ov_pkt_data[127:125] <= 3'h3;
					end
					else begin
						ov_pkt_data[127:125] <= iv_fifo_data[127:125];
					end				
                    o_fifo_rd <= 1'b1;
                    rv_dmac_outport <= rv_dmac_outport;
                    if(iv_fifo_data[79:0] == 80'h0)begin//not first frag
                        o_pkt_data_wr <= 1'b0;
                        frm_state <= TRANS_NFIRST_FRAG_S;  
                    end
                    else begin//first frag
                        o_pkt_data_wr <= 1'b1;
                        frm_state <= TRANS_FIRST_CYCLE_S;  
                    end                    
                end
                else begin
                    ov_pkt_data <= 134'b0;
                    o_pkt_data_wr <= 1'b0;
                    o_fifo_rd <= 1'b0;                    
                    rv_dmac_outport <= rv_dmac_outport;                          
                    frm_state <= WAIT_S;
                end
            end                
			TRANS_FIRST_CYCLE_S:begin//first cycle of first frag
                ov_pkt_data <= {2'b11,iv_fifo_data[131:128],rv_dmac_outport[56:9],iv_fifo_data[79:32],16'h0800,iv_fifo_data[15:0]};//replace dmac with tsntag,replace 0x1800 with 0x0800.
                o_pkt_data_wr <= 1'b1;
                o_fifo_rd <= 1'b1;
                frm_state <= TRANS_PKT_S;                
			end	
            TRANS_NFIRST_FRAG_S:begin//transmit not first frag
                if(iv_fifo_data[133:132] == 2'b10)begin
                    ov_pkt_data <= iv_fifo_data;
                    o_pkt_data_wr <= 1'b1;                
                    o_fifo_rd <= 1'b0;
                    frm_state <= IDLE_S; 
                end
                else if(iv_fifo_data[133:132] == 2'b01)begin//transmit metadata and discard first cycle.
                    ov_pkt_data <= ov_pkt_data;
                    o_pkt_data_wr <= 1'b1;
                    o_fifo_rd <= 1'b1;
                    frm_state <= TRANS_NFIRST_FRAG_S;                 
                end
                else begin
                    ov_pkt_data <= iv_fifo_data;
                    o_pkt_data_wr <= 1'b1;
                    o_fifo_rd <= 1'b1;
                    frm_state <= TRANS_NFIRST_FRAG_S; 
                end               
            end
            TRANS_PKT_S:begin//transmit first frag
                ov_pkt_data <= iv_fifo_data;
                o_pkt_data_wr <= 1'b1;
                if(iv_fifo_data[133:132] == 2'b10)begin
                    o_fifo_rd <= 1'b0;
                    frm_state <= IDLE_S; 
                end
                else begin
                    o_fifo_rd <= 1'b1;
                    frm_state <= TRANS_PKT_S; 
                end                
			end
            DISC_PKT_S:begin
                ov_pkt_data <= 134'b0;
                o_pkt_data_wr <= 1'b0;
                if(iv_fifo_data[133:132] == 2'b10)begin
                    o_fifo_rd <= 1'b0;
                    frm_state <= IDLE_S; 
                end
                else begin
                    o_fifo_rd <= 1'b1;
                    frm_state <= DISC_PKT_S; 
                end  
            end            
			default:begin		
				frm_state <= IDLE_S;		
			end
		endcase
	end
end
endmodule