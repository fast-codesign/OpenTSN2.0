// Copyright (C) 1953-2020 NUDT
// Verilog module name - host_input_queue 
// Version: HIQ_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         control bufid of pkt transmitted to host to input queue
//             - write bufid of ts packet to ram of TIM; 
//             - write bufid of not ts packet to queue.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module host_input_queue
(
       i_clk,
       i_rst_n,
       
       iv_bufid,
       iv_pkt_type,
       iv_pkt_inport,
       iv_ts_submit_addr,
       i_data_wr,
       
       ov_ts_descriptor_wdata,
       o_ts_descriptor_wr,
       ov_ts_descriptor_waddr,
       
       ov_nts_descriptor_wdata,
       o_nts_descriptor_wr,
       
       i_fifo_full,
       o_host_inqueue_discard_pulse,

       iv_ts_cnt,
       o_ts_overflow_error_pulse,
       
       ov_debug_ts_cnt,
       ov_debug_cnt
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// information of pkt input
input      [8:0]       iv_bufid;
input      [2:0]       iv_pkt_type;
input      [3:0]       iv_pkt_inport;
input      [4:0]       iv_ts_submit_addr;
input                  i_data_wr;
// write bufid of ts pkt to ram
output reg [12:0]      ov_ts_descriptor_wdata;
output reg             o_ts_descriptor_wr;
output reg [4:0]       ov_ts_descriptor_waddr;
// write bufid of nts pkt to queue
output reg [12:0]      ov_nts_descriptor_wdata;
output reg             o_nts_descriptor_wr;
input                  i_fifo_full;

output reg             o_host_inqueue_discard_pulse;
input      [31:0]      iv_ts_cnt;  
//count overflow error of 32 TS flow 
output reg             o_ts_overflow_error_pulse;    

//***************************************************
//          control bufid to input queue 
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_ts_descriptor_wdata <= 13'b0;
        o_ts_descriptor_wr <= 1'b0;
        ov_ts_descriptor_waddr <= 5'b0;        
        
        ov_nts_descriptor_wdata <= 13'b0;
        o_nts_descriptor_wr <= 1'b0;
    end
    else begin
        if(i_data_wr == 1'b1)begin
            if((iv_pkt_type == 3'b000) || (iv_pkt_type == 3'b001) || (iv_pkt_type == 3'b010))begin  //TS packet
                if(|((32'h1 << iv_ts_submit_addr) & iv_ts_cnt)==1'b0)begin //not overflow
                    ov_ts_descriptor_wdata <= {iv_pkt_inport,iv_bufid};
                    o_ts_descriptor_wr <= 1'b1;
                    ov_ts_descriptor_waddr <= iv_ts_submit_addr;
                    
                    ov_nts_descriptor_wdata <= 13'b0;  
                    o_nts_descriptor_wr <= 1'b0;                  
                end
                else begin//overflow                    
                    ov_ts_descriptor_wdata <= 13'b0;
                    o_ts_descriptor_wr <= 1'b0;
                    ov_ts_descriptor_waddr <= 5'b0; 
                                       
                    ov_nts_descriptor_wdata <= {4'hf,iv_bufid}; //bufid will be free in "HOI".
                    o_nts_descriptor_wr <= 1'b1;               
                end
            end
            else begin//not ts packet
                ov_ts_descriptor_wdata <= 13'b0;
                o_ts_descriptor_wr <= 1'b0;
                ov_ts_descriptor_waddr <= 5'b0;            

                ov_nts_descriptor_wdata <= {iv_pkt_inport,iv_bufid}; 
                o_nts_descriptor_wr <= 1'b1;                                   
            end
        end
        else begin
            ov_ts_descriptor_wdata <= 13'b0;
            o_ts_descriptor_wr <= 1'b0;
            ov_ts_descriptor_waddr <= 5'b0;
            
            ov_nts_descriptor_wdata <= 13'b0;
            o_nts_descriptor_wr <= 1'b0;
        end
    end
end 
//***************************************************
//      count overflow error of 32 TS flow 
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_ts_overflow_error_pulse <= 1'b0;
    end
    else begin
        if(i_data_wr == 1'b1)begin
            if(((iv_pkt_type == 3'b000) || (iv_pkt_type == 3'b001) || (iv_pkt_type == 3'b010)) && (|((32'h1 << iv_ts_submit_addr) & iv_ts_cnt)==1'b1))begin//overflow error
                o_ts_overflow_error_pulse <= 1'b1;
            end 
            else begin
                o_ts_overflow_error_pulse <= 1'b0;
            end
        end
        else begin
            o_ts_overflow_error_pulse <= 1'b0;
        end
    end
end 
//***************************************************
//           fifo overflow error 
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_host_inqueue_discard_pulse <= 1'b0;
    end
    else begin
        if((o_nts_descriptor_wr == 1'b1) && (i_fifo_full == 1'b1))begin
            o_host_inqueue_discard_pulse <= 1'b1;
        end
        else begin
            o_host_inqueue_discard_pulse <= 1'b0;
        end
    end
end 


output reg [15:0] ov_debug_ts_cnt; 
output reg [15:0] ov_debug_cnt; 
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_debug_ts_cnt <= 16'b0;
    end
    else begin
        if(i_data_wr && ((iv_pkt_type == 3'h0)||(iv_pkt_type == 3'h1)||(iv_pkt_type == 3'h2)))begin
            ov_debug_ts_cnt <= ov_debug_ts_cnt + 1'b1;
        end
        else begin
            ov_debug_ts_cnt <= ov_debug_ts_cnt;
        end
    end
end	
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_debug_cnt <= 16'b0;
    end
    else begin
        if(i_data_wr)begin
            ov_debug_cnt <= ov_debug_cnt + 1'b1;
        end
        else begin
            ov_debug_cnt <= ov_debug_cnt;
        end
    end
end	
endmodule