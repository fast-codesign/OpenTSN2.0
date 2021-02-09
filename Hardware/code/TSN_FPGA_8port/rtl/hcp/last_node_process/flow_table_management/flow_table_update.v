// Copyright (C) 1953-2020 NUDT
// Verilog module name - flow_table_update
// Version: flow_table_update_V1.0
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

module flow_table_update
(
        i_clk,
        i_rst_n,   
        
        iv_queue_id,
        i_last_frag_flag,        
        i_queue_wr,
        
        iv_update_ram_wdata,
	    i_update_ram_wr,
	    iv_update_ram_waddr,
        
        ov_fmt_ram_wdata,
	    o_fmt_ram_wr,
	    ov_fmt_ram_waddr,
       
	    i_fmt_ram_rd,
	    iv_fmt_ram_raddr,
       
	    iv_queue_id_free,
	    i_queue_id_free_wr,
	    ov_queue_empty
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
//information of packet used to lookup table
input     [4:0]        iv_queue_id;
input                  i_last_frag_flag;
input                  i_queue_wr;
//update flow table 
input     [18:0]	   iv_update_ram_wdata;
input     	           i_update_ram_wr;
input     [4:0]	       iv_update_ram_waddr;
//read flow table 
input       	       i_fmt_ram_rd;
input     [4:0]	       iv_fmt_ram_raddr;
//write flow table
output reg [18:0]	   ov_fmt_ram_wdata;
output reg  	       o_fmt_ram_wr;
output reg [4:0]	   ov_fmt_ram_waddr;
//free queue id
input      [4:0]	   iv_queue_id_free;
input                  i_queue_id_free_wr;
output reg [31:0]      ov_queue_empty; 
//***************************************************
//              free queue
//***************************************************
reg  	       r_free_ram_wr;
reg [4:0]	   rv_free_ram_waddr;

reg  free_finish;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin        
        r_free_ram_wr <= 1'b0;
        rv_free_ram_waddr <= 5'b0;
    end
    else begin
        if(!free_finish)begin
            if(i_queue_id_free_wr)begin
                r_free_ram_wr <= 1'b1;
                rv_free_ram_waddr <= iv_queue_id_free;        
            end
            else begin
                r_free_ram_wr <= r_free_ram_wr;
                rv_free_ram_waddr <= rv_free_ram_waddr;              
            end
        end
        else begin
            r_free_ram_wr <= 1'b0;
            rv_free_ram_waddr <= 5'b0;        
        end
    end
end
//***************************************************
//         read & write arbitration
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin        
        ov_fmt_ram_wdata <= 19'b0;
        o_fmt_ram_wr <= 1'b0;
        ov_fmt_ram_waddr <= 5'b0;
        
        free_finish <= 1'b0;
    end
    else begin
        if(i_update_ram_wr)begin
            ov_fmt_ram_wdata <= iv_update_ram_wdata;
            o_fmt_ram_wr <= 1'b1;
            ov_fmt_ram_waddr <= iv_update_ram_waddr;  

            free_finish <= 1'b0;            
        end
        else if(r_free_ram_wr && (!free_finish))begin//only using "r_free_ram_wr" causes that o_fmt_ram_wr is high for 2 cycles.
            if(i_fmt_ram_rd)begin
                if(iv_fmt_ram_raddr == rv_free_ram_waddr)begin
                    ov_fmt_ram_wdata <= 19'b0;
                    o_fmt_ram_wr <= 1'b0;
                    ov_fmt_ram_waddr <= 5'b0;         
                    
                    free_finish <= 1'b0;
                end
                else begin
                    ov_fmt_ram_wdata <= 19'b0;
                    o_fmt_ram_wr <= 1'b1;
                    ov_fmt_ram_waddr <= rv_free_ram_waddr; 
  
                    free_finish <= 1'b1;  
                end
            end
            else begin
                ov_fmt_ram_wdata <= 19'b0;
                o_fmt_ram_wr <= 1'b1;
                ov_fmt_ram_waddr <= rv_free_ram_waddr;  
 
                free_finish <= 1'b1; 
            end                    
        end
        else begin
            ov_fmt_ram_wdata <= 19'b0;
            o_fmt_ram_wr <= 1'b0;
            ov_fmt_ram_waddr <= 5'b0;
            
            free_finish <= 1'b0;        
        end
    end
end	
//***************************************************
//       judge whether 32 queues are empty
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin        
        ov_queue_empty <= 32'hff_ff_ff_ff;
    end
    else begin
        if(i_queue_wr && i_last_frag_flag)begin             
            case(iv_queue_id)
                5'h00:ov_queue_empty[0]  <= 1'b0;
                5'h01:ov_queue_empty[1]  <= 1'b0;
                5'h02:ov_queue_empty[2]  <= 1'b0;
                5'h03:ov_queue_empty[3]  <= 1'b0;
                5'h04:ov_queue_empty[4]  <= 1'b0;
                5'h05:ov_queue_empty[5]  <= 1'b0;
                5'h06:ov_queue_empty[6]  <= 1'b0;
                5'h07:ov_queue_empty[7]  <= 1'b0;
                5'h08:ov_queue_empty[8]  <= 1'b0;
                5'h09:ov_queue_empty[9]  <= 1'b0;
                5'h0a:ov_queue_empty[10] <= 1'b0;
                5'h0b:ov_queue_empty[11] <= 1'b0;
                5'h0c:ov_queue_empty[12] <= 1'b0;
                5'h0d:ov_queue_empty[13] <= 1'b0;
                5'h0e:ov_queue_empty[14] <= 1'b0;
                5'h0f:ov_queue_empty[15] <= 1'b0;
                5'h10:ov_queue_empty[16] <= 1'b0;
                5'h11:ov_queue_empty[17] <= 1'b0;
                5'h12:ov_queue_empty[18] <= 1'b0;
                5'h13:ov_queue_empty[19] <= 1'b0;
                5'h14:ov_queue_empty[20] <= 1'b0;
                5'h15:ov_queue_empty[21] <= 1'b0;
                5'h16:ov_queue_empty[22] <= 1'b0;
                5'h17:ov_queue_empty[23] <= 1'b0;
                5'h18:ov_queue_empty[24] <= 1'b0;
                5'h19:ov_queue_empty[25] <= 1'b0;
                5'h1a:ov_queue_empty[26] <= 1'b0;
                5'h1b:ov_queue_empty[27] <= 1'b0;
                5'h1c:ov_queue_empty[28] <= 1'b0;
                5'h1d:ov_queue_empty[29] <= 1'b0;
                5'h1e:ov_queue_empty[30] <= 1'b0;
                5'h1f:ov_queue_empty[31] <= 1'b0;
                default:ov_queue_empty <= ov_queue_empty;
            endcase
        end
        else if(free_finish)begin
            case(ov_fmt_ram_waddr)
                5'h00:ov_queue_empty[0]  <= 1'b1;
                5'h01:ov_queue_empty[1]  <= 1'b1;
                5'h02:ov_queue_empty[2]  <= 1'b1;
                5'h03:ov_queue_empty[3]  <= 1'b1;
                5'h04:ov_queue_empty[4]  <= 1'b1;
                5'h05:ov_queue_empty[5]  <= 1'b1;
                5'h06:ov_queue_empty[6]  <= 1'b1;
                5'h07:ov_queue_empty[7]  <= 1'b1;
                5'h08:ov_queue_empty[8]  <= 1'b1;
                5'h09:ov_queue_empty[9]  <= 1'b1;
                5'h0a:ov_queue_empty[10] <= 1'b1;
                5'h0b:ov_queue_empty[11] <= 1'b1;
                5'h0c:ov_queue_empty[12] <= 1'b1;
                5'h0d:ov_queue_empty[13] <= 1'b1;
                5'h0e:ov_queue_empty[14] <= 1'b1;
                5'h0f:ov_queue_empty[15] <= 1'b1;
                5'h10:ov_queue_empty[16] <= 1'b1;
                5'h11:ov_queue_empty[17] <= 1'b1;
                5'h12:ov_queue_empty[18] <= 1'b1;
                5'h13:ov_queue_empty[19] <= 1'b1;
                5'h14:ov_queue_empty[20] <= 1'b1;
                5'h15:ov_queue_empty[21] <= 1'b1;
                5'h16:ov_queue_empty[22] <= 1'b1;
                5'h17:ov_queue_empty[23] <= 1'b1;
                5'h18:ov_queue_empty[24] <= 1'b1;
                5'h19:ov_queue_empty[25] <= 1'b1;
                5'h1a:ov_queue_empty[26] <= 1'b1;
                5'h1b:ov_queue_empty[27] <= 1'b1;
                5'h1c:ov_queue_empty[28] <= 1'b1;
                5'h1d:ov_queue_empty[29] <= 1'b1;
                5'h1e:ov_queue_empty[30] <= 1'b1;
                5'h1f:ov_queue_empty[31] <= 1'b1;
                default:ov_queue_empty <= ov_queue_empty;
            endcase                        
        end
        else begin
            ov_queue_empty <= ov_queue_empty;
        end
    end
end	
endmodule 