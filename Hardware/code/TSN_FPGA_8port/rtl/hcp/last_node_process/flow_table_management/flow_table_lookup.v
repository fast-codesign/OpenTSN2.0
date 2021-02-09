// Copyright (C) 1953-2020 NUDT
// Verilog module name - flow_table_lookup
// Version: flow_table_lookup_V1.0
// Created:
//         by - fenglin
//         at - 08.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         management of flow map-table.
//             - lookup flow map-table;key of lookup table is flowid and result is queue_id and queue_usedw; 
//             - update content of table;
//             - free queue id;
//             - judge whether queues cache all fragment of a packet;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module flow_table_lookup
(
       i_clk,
       i_rst_n,
	   
	   iv_flowid,
       iv_frag_id,
	   i_last_frag_flag,
	   i_flowid_wr,

	   ov_queue_id,
	   ov_queue_usedw,
	   o_queue_id_wr,
       o_all_queue_used,

       o_last_frag_flag,       

	   ov_update_ram_wdata,
	   o_update_ram_wr,
	   ov_update_ram_waddr,       
	   iv_fmt_ram_rdata,
	   o_fmt_ram_rd,
	   ov_fmt_ram_raddr,
       
	   iv_queue_empty,
       
       o_lnp_no_last_frag_flag_pulse,      
       o_lnp_no_notlast_frag_flag_pulse      
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
//information of packet used to lookup table
input      [13:0]	   iv_flowid;
input      [3:0]       iv_frag_id;//the signal is only used to judge whether frag is losing and used in flow_table_update.
input                  i_last_frag_flag;
input                  i_flowid_wr;
//result of lookup table
output reg [4:0]	   ov_queue_id;
output reg [3:0]       ov_queue_usedw;
output reg             o_queue_id_wr;
output reg             o_all_queue_used;
//last frag flag
output reg             o_last_frag_flag;
//write/read valid & flowid & queue_usedw to RAM 
output reg [18:0]	   ov_update_ram_wdata;
output reg  	       o_update_ram_wr;
output reg [4:0]	   ov_update_ram_waddr;
input      [18:0]	   iv_fmt_ram_rdata;
output reg  	       o_fmt_ram_rd;
output reg [4:0]	   ov_fmt_ram_raddr;

input      [31:0]      iv_queue_empty; 

output reg             o_lnp_no_last_frag_flag_pulse;
output reg             o_lnp_no_notlast_frag_flag_pulse;
//***************************************************
//          	   lookup table
//***************************************************
reg   [4:0]    rv_first_invalid_table;
reg            r_first_invalid_table_valid;
reg   [4:0]    rv_queue_id;
reg   [13:0]   rv_flowid;
reg   [2:0]    fmm_state;
localparam  IDLE_S = 3'd0,
            READ_1ST_S = 3'd1,
			READ_2ND_S = 3'd2,
            LOOKUP_TABLE_S = 3'd3;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_queue_id <= 5'b0;
		ov_queue_usedw <= 4'b0;
		o_queue_id_wr <= 1'b0;
        o_all_queue_used <= 1'b0;
        
        rv_flowid <= 14'b0;
        o_last_frag_flag <= 1'b0;
        
        rv_first_invalid_table <= 5'b0;
        r_first_invalid_table_valid <= 1'b0;
        rv_queue_id <= 5'b0;
		
        o_fmt_ram_rd <= 1'b0;
        ov_fmt_ram_raddr <= 5'b0;
        
        ov_update_ram_wdata <= 19'b0;
        o_update_ram_wr <= 1'b0;
        ov_update_ram_waddr <= 5'b0;

		fmm_state <= IDLE_S;
    end
    else begin
		case(fmm_state)
			IDLE_S:begin
                ov_queue_id <= 5'b0;
                ov_queue_usedw <= 4'b0;
                o_queue_id_wr <= 1'b0;
                o_all_queue_used <= 1'b0;

                ov_update_ram_wdata <= 19'b0;
                o_update_ram_wr <= 1'b0;
                ov_update_ram_waddr <= 5'b0;  

                rv_first_invalid_table <= 5'b0;
                r_first_invalid_table_valid <= 1'b0;  
                rv_queue_id <= 5'b0;                
			    if(i_flowid_wr)begin
                    rv_flowid <= iv_flowid;
                    o_last_frag_flag <= i_last_frag_flag;
                    
                    o_fmt_ram_rd <= 1'b1; 
                    ov_fmt_ram_raddr <= 5'd0;   //read table0
                    fmm_state <= READ_1ST_S;                    
				end
				else begin
                    rv_flowid <= 14'd0;
                    o_last_frag_flag <= 1'b0;
                    
                    o_fmt_ram_rd <= 1'b0;
                    ov_fmt_ram_raddr <= 5'd0;                       
					fmm_state <= IDLE_S;					
				end
			end
            READ_1ST_S:begin 
                o_fmt_ram_rd <= 1'b1; 
                ov_fmt_ram_raddr <= ov_fmt_ram_raddr + 1'd1;   //read 1st table
                
                fmm_state <= READ_2ND_S;                    
            end
            READ_2ND_S:begin 
                o_fmt_ram_rd <= 1'b1; 
                ov_fmt_ram_raddr <= ov_fmt_ram_raddr + 1'd1;   //read 2ND table
                
                fmm_state <= LOOKUP_TABLE_S;                    
            end 
            LOOKUP_TABLE_S:begin 
                o_fmt_ram_rd <= 1'b1; 
                ov_fmt_ram_raddr <= ov_fmt_ram_raddr + 1'd1;   
                rv_queue_id <= rv_queue_id + 1'b1;   
                ///////receive table////////
                if(iv_queue_empty[rv_queue_id])begin//empty
                    if(iv_fmt_ram_rdata[18])begin//queue valid
                        if(iv_fmt_ram_rdata[17:4] == rv_flowid)begin    
                            ov_queue_id <= rv_queue_id;
                            ov_queue_usedw <= iv_fmt_ram_rdata[3:0];
                            o_queue_id_wr <= 1'b1; 
                            ///////update table////////
                            ov_update_ram_wdata <= {iv_fmt_ram_rdata[18:4],iv_fmt_ram_rdata[3:0]+1'b1};
                            o_update_ram_wr <= 1'b1;
                            ov_update_ram_waddr <= rv_queue_id;  
                            fmm_state <= IDLE_S;  
                        end
                        else begin
                            if(rv_queue_id == 5'd31)begin
                                if(r_first_invalid_table_valid)begin
                                    ov_queue_id <= rv_first_invalid_table;
                                    ov_queue_usedw <= 4'd0;
                                    o_queue_id_wr <= 1'b1; 

                                    ov_update_ram_wdata <= {1'b1,rv_flowid,4'd1};
                                    o_update_ram_wr <= 1'b1;
                                    ov_update_ram_waddr <= rv_first_invalid_table; 
                                    fmm_state <= IDLE_S; 
                                end
                                else begin//not invalid queue;
                                    ov_queue_id <= 5'd0;
                                    ov_queue_usedw <= 4'd0;
                                    o_queue_id_wr <= 1'b0;
                                    o_all_queue_used <= 1'b1;                                    

                                    ov_update_ram_wdata <= 19'b0;
                                    o_update_ram_wr <= 1'b0;
                                    ov_update_ram_waddr <= 5'b0; 
                                    fmm_state <= IDLE_S;                                 
                                end
                            end
                            else begin
                                ov_queue_id <= 5'd0;
                                ov_queue_usedw <= 4'd0;
                                o_queue_id_wr <= 1'b0; 

                                ov_update_ram_wdata <= 19'b0;
                                o_update_ram_wr <= 1'b0;
                                ov_update_ram_waddr <= 5'b0; 
                                fmm_state <= LOOKUP_TABLE_S; 
                            end                            
                        end                        
                    end
                    else begin
                        if(rv_queue_id == 5'd31)begin
                            if(r_first_invalid_table_valid)begin
                                ov_queue_id <= rv_first_invalid_table;
                                ov_queue_usedw <= 4'd0;
                                o_queue_id_wr <= 1'b1; 

                                ov_update_ram_wdata <= {1'b1,rv_flowid,4'd1};
                                o_update_ram_wr <= 1'b1;
                                ov_update_ram_waddr <= rv_first_invalid_table; 
                                fmm_state <= IDLE_S; 
                            end
                            else begin//last queue isn't used.
                                ov_queue_id <= 5'd31;
                                ov_queue_usedw <= 4'd0;
                                o_queue_id_wr <= 1'b1; 

                                ov_update_ram_wdata <= {1'b1,rv_flowid,4'd1};
                                o_update_ram_wr <= 1'b1;
                                ov_update_ram_waddr <= 5'd31;
                                fmm_state <= IDLE_S;                                
                            end                            
                        end
                        else begin
                            if(r_first_invalid_table_valid)begin
                                rv_first_invalid_table <= rv_first_invalid_table;
                                r_first_invalid_table_valid <= 1'b1; 
                            end
                            else begin//record first invalid queue.
                                rv_first_invalid_table <= rv_queue_id;
                                r_first_invalid_table_valid <= 1'b1;                            
                            end
                            fmm_state <= LOOKUP_TABLE_S; 
                        end                        
                    end
                end
                else begin
                    if(rv_queue_id == 5'd31)begin
                        if(r_first_invalid_table_valid)begin
                            ov_queue_id <= rv_first_invalid_table;
                            ov_queue_usedw <= 4'd0;
                            o_queue_id_wr <= 1'b1; 

                            ov_update_ram_wdata <= {1'b1,rv_flowid,4'd1};
                            o_update_ram_wr <= 1'b1;
                            ov_update_ram_waddr <= rv_first_invalid_table; 
                            fmm_state <= IDLE_S; 
                        end
                        else begin//all queue are used.
                            ov_queue_id <= 5'd0;
                            ov_queue_usedw <= 4'd0;
                            o_queue_id_wr <= 1'b0;
                            o_all_queue_used <= 1'b1;                                    

                            ov_update_ram_wdata <= 19'b0;
                            o_update_ram_wr <= 1'b0;
                            ov_update_ram_waddr <= 5'b0; 
                            fmm_state <= IDLE_S;                                
                        end                            
                    end
                    else begin
                        //rv_first_invalid_table <= rv_first_invalid_table;
                        //r_first_invalid_table_valid <= r_first_invalid_table_valid; 
                        fmm_state <= LOOKUP_TABLE_S; 
                    end        
                end                
            end           
			default:begin				
				fmm_state <= IDLE_S;
			end
		endcase
    end
end	
//***************************************************
//       judge whether frag is losing 
//***************************************************
reg            [18:0]        rv_lastflag_flowid_fragid;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_lnp_no_last_frag_flag_pulse <= 1'b0;
		o_lnp_no_notlast_frag_flag_pulse <= 1'b0;
        
        rv_lastflag_flowid_fragid <= 19'b0;
    end
    else begin
        if(i_flowid_wr)begin
            rv_lastflag_flowid_fragid <= {i_last_frag_flag,iv_flowid,iv_frag_id + 1'b1};//frag_id starts from 0, but queue_usedw(ov_update_ram_waddr[3:0]) starts from 1.
        end
        else begin
            rv_lastflag_flowid_fragid <= rv_lastflag_flowid_fragid;
        end

        if(o_update_ram_wr)begin             
            if((rv_lastflag_flowid_fragid[18] == 1'b1) && (ov_update_ram_waddr[3:0] == rv_lastflag_flowid_fragid[3:0]))begin//losing first frag or middle frag.
                o_lnp_no_notlast_frag_flag_pulse <= 1'b1;
            end
            else begin
                o_lnp_no_notlast_frag_flag_pulse <= 1'b0;         
            end
        end
        else begin
            o_lnp_no_notlast_frag_flag_pulse <= 1'b0;      
        end

        
        if(o_update_ram_wr)begin             
            if((ov_update_ram_waddr[3:0] >= 4'h2) && (rv_lastflag_flowid_fragid[3:0] == 4'h1))begin//losing last frag.
                o_lnp_no_last_frag_flag_pulse <= 1'b1;   
            end
            else begin
                o_lnp_no_last_frag_flag_pulse <= 1'b0;           
            end
        end
        else begin
            o_lnp_no_last_frag_flag_pulse <= 1'b0;          
        end
    end
end
endmodule 