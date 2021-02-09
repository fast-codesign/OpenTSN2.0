// Copyright (C) 1953-2020 NUDT
// Verilog module name - host_output_schedule 
// Version: HOS_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         schedule bufid of pkt transmitted to host.
//             - schedule bufid of ts packet first and can't schedule bufid of not ts packet until bufid of ts packet doesn't have request of schedule; 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module host_output_schedule
(
       i_clk,
       i_rst_n,
       
       iv_ts_descriptor,
       i_ts_descriptor_wr,
       o_ts_descriptor_scheduled,
       
       o_nts_descriptor_rd, 
       iv_nts_descriptor, 
       i_fifo_empty,

       i_host_outport_free,
       ov_descriptor,
       o_descriptor_wr,
       hos_state,
       ov_debug_ts_cnt,
       ov_debug_nts_cnt
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// bufid of ts packet
input      [12:0]      iv_ts_descriptor;
input                  i_ts_descriptor_wr;
output reg             o_ts_descriptor_scheduled;
// receive bufid of not ts pkt from queue
input      [12:0]      iv_nts_descriptor;
output reg             o_nts_descriptor_rd;
input                 i_fifo_empty;
// output bufid 
input                  i_host_outport_free;
output reg [12:0]     ov_descriptor;  
output reg            o_descriptor_wr;
//***************************************************
//               schedule bufid  
//***************************************************
// internal reg&wire for state machine
output reg        [1:0]       hos_state;
reg                    init_flag;
localparam  IDLE_S = 2'd0,
            PRIORITY_SCHEDULE_S = 2'd1,
            GET_BUFID_S = 2'd2;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_ts_descriptor_scheduled <= 1'b1;
        
        ov_descriptor <= 13'b0;
        o_descriptor_wr <= 1'b0;
        
        o_nts_descriptor_rd <= 1'b0;
        
        init_flag <= 1'b1;
        hos_state <= IDLE_S;
    end
    else begin
        case(hos_state)
            IDLE_S:begin
                o_ts_descriptor_scheduled <= 1'b0;
                
                ov_descriptor <= 13'b0;
                o_descriptor_wr <= 1'b0;    
                
                o_nts_descriptor_rd <= 1'b0;
                if(i_host_outport_free == 1'b1 || init_flag == 1'b1)begin
                    init_flag <= 1'b0;
                    hos_state <= PRIORITY_SCHEDULE_S;
                end
                else begin
                    init_flag <= 1'b0;
                    hos_state <= IDLE_S;
                end
            end
            PRIORITY_SCHEDULE_S:begin
                if(i_ts_descriptor_wr == 1'b1)begin//schedule bufid of TS packet firstly.
                    ov_descriptor <= iv_ts_descriptor;
                    o_descriptor_wr <= 1'b1;
                    o_ts_descriptor_scheduled <= 1'b1;
                    hos_state <= IDLE_S;
                end
                else if(i_fifo_empty == 1'b0)begin//schedule bufid of not TS packet.
                    o_nts_descriptor_rd <= 1'b1;
                    hos_state <= GET_BUFID_S;                   
                end
                else begin
                    ov_descriptor <= 13'b0;
                    o_descriptor_wr <= 1'b0;    
                    o_ts_descriptor_scheduled <= 1'b0;
                    hos_state <= PRIORITY_SCHEDULE_S;                   
                end
            end
            GET_BUFID_S:begin 
                o_nts_descriptor_rd <= 1'b0;
                ov_descriptor <= iv_nts_descriptor;
                o_descriptor_wr <= 1'b1;    
                hos_state <= IDLE_S;                    
            end
            default:begin
                o_ts_descriptor_scheduled <= 1'b0;
                o_nts_descriptor_rd <= 1'b0;
                ov_descriptor <= 13'b0;
                o_descriptor_wr <= 1'b0;
                
                hos_state <= IDLE_S;
            end
        endcase
   end
end
output reg [15:0] ov_debug_ts_cnt; 
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_debug_ts_cnt <= 16'b0;
    end
    else begin
        if(o_ts_descriptor_scheduled)begin
            ov_debug_ts_cnt <= ov_debug_ts_cnt + 1'b1;
        end
        else begin
            ov_debug_ts_cnt <= ov_debug_ts_cnt;
        end
    end
end	
output reg [15:0] ov_debug_nts_cnt; 
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_debug_nts_cnt <= 16'b0;
    end
    else begin
        if(o_nts_descriptor_rd)begin
            ov_debug_nts_cnt <= ov_debug_nts_cnt + 1'b1;
        end
        else begin
            ov_debug_nts_cnt <= ov_debug_nts_cnt;
        end
    end
end	   
endmodule