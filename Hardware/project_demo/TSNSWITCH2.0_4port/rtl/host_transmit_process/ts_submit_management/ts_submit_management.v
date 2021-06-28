// Copyright (C) 1953-2020 NUDT
// Verilog module name - ts_submit_management 
// Version: TSM_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         submit management of time-sensitive packet
//             - use a simple dual port ram to cache bufid of time-sensitive packet; 
//             - judge whether bufid of each TS traffic is underflow;
//             - read bufid of time-sensitive packet according to submit addr.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module ts_submit_management
(
       i_clk,
       i_rst_n,  
       
       iv_pkt_type_hiq,
       iv_ts_submit_addr_hiq,
       i_descriptor_wr_hiq,
       
       iv_ts_descriptor,
       i_ts_descriptor_wr,
       iv_ts_descriptor_waddr,
       
       iv_ts_submit_addr,
       i_ts_submit_addr_wr,
       o_ts_submit_addr_ack,
       
       ov_ts_descriptor,
       o_ts_descriptor_wr,
       i_ts_descriptor_ack,
       
       //ov_ts_rd_ack,
       ov_ts_cnt,
       o_ts_underflow_error_pulse,
       tsm_state,
       ov_debug_ts_cnt       
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n; 
//signal of input HIQ
//input    [8:0]       iv_bufid;
input      [2:0]       iv_pkt_type_hiq;
//input    [3:0]       iv_pkt_inport;
input      [4:0]       iv_ts_submit_addr_hiq;
input                  i_descriptor_wr_hiq; 
// writting ts bufid to ram
input      [12:0]      iv_ts_descriptor;
input                  i_ts_descriptor_wr;
input      [4:0]       iv_ts_descriptor_waddr;
//ts submit addr
input      [4:0]       iv_ts_submit_addr;
input                  i_ts_submit_addr_wr;
output reg             o_ts_submit_addr_ack;
// output ts bufid
output reg [12:0]      ov_ts_descriptor;
output reg             o_ts_descriptor_wr;
// FLM get ts bufid to look up table 
input                  i_ts_descriptor_ack; 
//count ts bufid
output reg [31:0]      ov_ts_cnt; 
//count underflow error of 32 TS flow 
output reg             o_ts_underflow_error_pulse;
//***************************************************
//   read bufid of time-sensitive packet
//***************************************************
// internal reg&wire for reading data from ram
wire       [12:0]      ts_descriptor_rdata;
reg                    ts_descriptor_rd;
reg        [4:0]       ts_descriptor_raddr;
// internal reg&wire for state machine
output reg        [2:0]       tsm_state;
localparam  IDLE_S = 3'd0,
            WAIT_FIRST_S = 3'd1,
            WAIT_SECOND_S = 3'd2, 
            GET_bufid_S = 3'd3,
            WAIT_ACK_S = 3'd4;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_ts_submit_addr_ack <= 1'b0;
        
        ov_ts_descriptor <= 13'b0;
        o_ts_descriptor_wr <= 1'b0;
        
        ts_descriptor_rd <= 1'b0;
        ts_descriptor_raddr <= 5'b0;
        
        tsm_state <= IDLE_S;
    end
    else begin
        case(tsm_state)        
            IDLE_S:begin
                ov_ts_descriptor <= 13'b0;
                o_ts_descriptor_wr <= 1'b0;
                if(i_ts_submit_addr_wr == 1'b1)begin
                    o_ts_submit_addr_ack <= 1'b1;
                    if(|((32'h1 << iv_ts_submit_addr) & ov_ts_cnt)==1'b1)begin//read ts bufid from ram
                        ts_descriptor_rd <= 1'b1;
                        ts_descriptor_raddr <= iv_ts_submit_addr;
                        tsm_state <= WAIT_FIRST_S;
                    end
                    else begin //not read ts bufid from ram
                        ts_descriptor_rd <= 1'b0;
                        ts_descriptor_raddr <= 5'b0;
                        tsm_state <= IDLE_S;                    
                    end
                end
                else begin
                    o_ts_submit_addr_ack <= 1'b0;
                    ts_descriptor_rd <= 1'b0;
                    ts_descriptor_raddr <= 5'b0;
                    tsm_state <= IDLE_S;
                end
            end
            WAIT_FIRST_S:begin 
                o_ts_submit_addr_ack <= 1'b0;
                
                ts_descriptor_rd <= 1'b1;
                ts_descriptor_raddr <= ts_descriptor_raddr;
                
                tsm_state <= WAIT_SECOND_S;
            end
            WAIT_SECOND_S:begin
                ts_descriptor_rd <= 1'b1;
                ts_descriptor_raddr <= ts_descriptor_raddr;
                
                tsm_state <= GET_bufid_S;
            end
            GET_bufid_S:begin
                ts_descriptor_rd <= 1'b0;
                ov_ts_descriptor <= ts_descriptor_rdata;
                o_ts_descriptor_wr <= 1'b1; 
                
                tsm_state <= WAIT_ACK_S;                
            end
            WAIT_ACK_S:begin
                //ov_ts_rd_ack <= 32'h0;
                if(i_ts_descriptor_ack == 1'b1)begin
                    ov_ts_descriptor <= 13'b0;
                    o_ts_descriptor_wr <= 1'b0; 
                    tsm_state <= IDLE_S;
                end
                else begin
                    tsm_state <= WAIT_ACK_S;                    
                end
            end     
            default:begin
                    ov_ts_descriptor <= 13'b0;
                    o_ts_descriptor_wr <= 1'b0;
                    
                    ts_descriptor_rd <= 1'b0;
                    ts_descriptor_raddr <= 5'b0;
                    
                    tsm_state <= IDLE_S;
            end
        endcase
   end
end 

//***************************************************
//judge whether bufid of each TS traffic is underflow
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_ts_cnt <= 32'b0;
    end
    else begin
    //////////////submit_addr == 5'd0//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd0))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[0] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd0)begin
                ov_ts_cnt[0] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[0] <= ov_ts_cnt[0]; 
            end        
        end
        else begin
            ov_ts_cnt[0] <= ov_ts_cnt[0];         
        end
    //////////////submit_addr == 5'd1//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd1))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[1] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd1)begin
                ov_ts_cnt[1] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[1] <= ov_ts_cnt[1]; 
            end        
        end 
        else begin
            ov_ts_cnt[1] <= ov_ts_cnt[1];         
        end
    //////////////submit_addr == 5'd2//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd2))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[2] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd2)begin
                ov_ts_cnt[2] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[2] <= ov_ts_cnt[2]; 
            end        
        end
        else begin
            ov_ts_cnt[2] <= ov_ts_cnt[2];         
        end
    //////////////submit_addr == 5'd3//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd3))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[3] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd3)begin
                ov_ts_cnt[3] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[3] <= ov_ts_cnt[3]; 
            end        
        end
        else begin
            ov_ts_cnt[3] <= ov_ts_cnt[3];         
        end        
    //////////////submit_addr == 5'd4//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd4))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[4] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd4)begin
                ov_ts_cnt[4] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[4] <= ov_ts_cnt[4]; 
            end        
        end 
        else begin
            ov_ts_cnt[4] <= ov_ts_cnt[4];         
        end        
    //////////////submit_addr == 5'd5//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd5))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[5] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd5)begin
                ov_ts_cnt[5] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[5] <= ov_ts_cnt[5]; 
            end        
        end
        else begin
            ov_ts_cnt[5] <= ov_ts_cnt[5];         
        end        
    //////////////submit_addr == 5'd6//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd6))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[6] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd6)begin
                ov_ts_cnt[6] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[6] <= ov_ts_cnt[6]; 
            end        
        end
        else begin
            ov_ts_cnt[6] <= ov_ts_cnt[6];         
        end        
    //////////////submit_addr == 5'd7//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd7))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[7] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd7)begin
                ov_ts_cnt[7] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[7] <= ov_ts_cnt[7]; 
            end        
        end
        else begin
            ov_ts_cnt[7] <= ov_ts_cnt[7];         
        end        
    //////////////submit_addr == 5'd8//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd8))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[8] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd8)begin
                ov_ts_cnt[8] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[8] <= ov_ts_cnt[8]; 
            end        
        end
        else begin
            ov_ts_cnt[8] <= ov_ts_cnt[8];         
        end        
    //////////////submit_addr == 5'd9//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd9))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[9] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd9)begin
                ov_ts_cnt[9] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[9] <= ov_ts_cnt[9]; 
            end        
        end
        else begin
            ov_ts_cnt[9] <= ov_ts_cnt[9];         
        end        
    //////////////submit_addr == 5'd10//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd10))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[10] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd10)begin
                ov_ts_cnt[10] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[10] <= ov_ts_cnt[10]; 
            end        
        end
        else begin
            ov_ts_cnt[10] <= ov_ts_cnt[10];         
        end      
    //////////////submit_addr == 5'd11//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd11))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[11] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd11)begin
                ov_ts_cnt[11] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[11] <= ov_ts_cnt[11]; 
            end        
        end
        else begin
            ov_ts_cnt[11] <= ov_ts_cnt[11];         
        end        
    //////////////submit_addr == 5'd12//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd12))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[12] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd12)begin
                ov_ts_cnt[12] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[12] <= ov_ts_cnt[12]; 
            end        
        end
        else begin
            ov_ts_cnt[12] <= ov_ts_cnt[12];         
        end        
    //////////////submit_addr == 5'd13//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd13))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[13] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd13)begin
                ov_ts_cnt[13] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[13] <= ov_ts_cnt[13]; 
            end        
        end
        else begin
            ov_ts_cnt[13] <= ov_ts_cnt[13];         
        end        
    //////////////submit_addr == 5'd14//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd14))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[14] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd14)begin
                ov_ts_cnt[14] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[14] <= ov_ts_cnt[14]; 
            end        
        end
        else begin
            ov_ts_cnt[14] <= ov_ts_cnt[14];         
        end        
    //////////////submit_addr == 5'd15//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd15))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[15] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd15)begin
                ov_ts_cnt[15] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[15] <= ov_ts_cnt[15]; 
            end        
        end
        else begin
            ov_ts_cnt[15] <= ov_ts_cnt[15];         
        end        
    //////////////submit_addr == 5'd16//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd16))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[16] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd16)begin
                ov_ts_cnt[16] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[16] <= ov_ts_cnt[16]; 
            end        
        end
        else begin
            ov_ts_cnt[16] <= ov_ts_cnt[16];         
        end        
    //////////////submit_addr == 5'd17//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd17))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[17] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd17)begin
                ov_ts_cnt[17] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[17] <= ov_ts_cnt[17]; 
            end        
        end
        else begin
            ov_ts_cnt[17] <= ov_ts_cnt[17];         
        end
    //////////////submit_addr == 5'd18//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd18))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[18] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd18)begin
                ov_ts_cnt[18] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[18] <= ov_ts_cnt[18]; 
            end        
        end
        else begin
            ov_ts_cnt[18] <= ov_ts_cnt[18];         
        end        
    //////////////submit_addr == 5'd19//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd19))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[19] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd19)begin
                ov_ts_cnt[19] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[19] <= ov_ts_cnt[19]; 
            end        
        end
        else begin
            ov_ts_cnt[19] <= ov_ts_cnt[19];         
        end        
    //////////////submit_addr == 5'd20//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd20))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[20] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd20)begin
                ov_ts_cnt[20] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[20] <= ov_ts_cnt[20]; 
            end        
        end
        else begin
            ov_ts_cnt[20] <= ov_ts_cnt[20];         
        end
    //////////////submit_addr == 5'd21//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd21))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[21] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd21)begin
                ov_ts_cnt[21] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[21] <= ov_ts_cnt[21]; 
            end        
        end
        else begin
            ov_ts_cnt[21] <= ov_ts_cnt[21];         
        end        
    //////////////submit_addr == 5'd22//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd22))begin //else if(o_ts_descriptor_wr == 1'b1)begin 
            ov_ts_cnt[22] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd22)begin
                ov_ts_cnt[22] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[22] <= ov_ts_cnt[22]; 
            end        
        end 
        else begin
            ov_ts_cnt[22] <= ov_ts_cnt[22];         
        end        
    //////////////submit_addr == 5'd23//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd23))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[23] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd23)begin
                ov_ts_cnt[23] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[23] <= ov_ts_cnt[23]; 
            end        
        end
        else begin
            ov_ts_cnt[23] <= ov_ts_cnt[23];         
        end        
    //////////////submit_addr == 5'd24//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd24))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[24] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd24)begin
                ov_ts_cnt[24] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[24] <= ov_ts_cnt[24]; 
            end        
        end
        else begin
            ov_ts_cnt[24] <= ov_ts_cnt[24];         
        end        
    //////////////submit_addr == 5'd25//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd25))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[25] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd25)begin
                ov_ts_cnt[25] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[25] <= ov_ts_cnt[25]; 
            end        
        end
        else begin
            ov_ts_cnt[25] <= ov_ts_cnt[25];         
        end        
    //////////////submit_addr == 5'd26//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd26))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[26] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd26)begin
                ov_ts_cnt[26] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[26] <= ov_ts_cnt[26]; 
            end        
        end
        else begin
            ov_ts_cnt[26] <= ov_ts_cnt[26];         
        end
    //////////////submit_addr == 5'd27//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd27))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[27] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd27)begin
                ov_ts_cnt[27] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[27] <= ov_ts_cnt[27]; 
            end        
        end
        else begin
            ov_ts_cnt[27] <= ov_ts_cnt[27];         
        end
    //////////////submit_addr == 5'd28//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd28))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[28] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd28)begin
                ov_ts_cnt[28] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[28] <= ov_ts_cnt[28]; 
            end        
        end
        else begin
            ov_ts_cnt[28] <= ov_ts_cnt[28];         
        end        
    //////////////submit_addr == 5'd29//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd29))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[29] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd29)begin
                ov_ts_cnt[29] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[29] <= ov_ts_cnt[29]; 
            end        
        end
        else begin
            ov_ts_cnt[29] <= ov_ts_cnt[29];         
        end        
    //////////////submit_addr == 5'd30//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd30))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[30] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd30)begin
                ov_ts_cnt[30] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[30] <= ov_ts_cnt[30]; 
            end        
        end 
        else begin
            ov_ts_cnt[30] <= ov_ts_cnt[30];         
        end        
    //////////////submit_addr == 5'd31//////////////////
        if(i_ts_descriptor_ack && (ts_descriptor_raddr == 5'd31))begin //else if(o_ts_descriptor_wr == 1'b1)begin
            ov_ts_cnt[31] <= 1'b0; 
        end
        else if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            if(iv_ts_submit_addr_hiq == 5'd31)begin
                ov_ts_cnt[31] <= 1'b1;  
            end
            else begin
                ov_ts_cnt[31] <= ov_ts_cnt[31]; 
            end        
        end
        else begin
            ov_ts_cnt[31] <= ov_ts_cnt[31];         
        end        
    end
end    
/*        
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_ts_cnt <= 32'b0;
    end
    else begin
        if((i_descriptor_wr_hiq == 1'b1)&&((iv_pkt_type_hiq == 3'b000) || (iv_pkt_type_hiq == 3'b001) || (iv_pkt_type_hiq == 3'b010)))begin
            case(iv_ts_submit_addr_hiq)
                5'd0:ov_ts_cnt[0] <= 1'b1;  
                5'd1:ov_ts_cnt[1] <= 1'b1; 
                5'd2:ov_ts_cnt[2] <= 1'b1; 
                5'd3:ov_ts_cnt[3] <= 1'b1; 
                5'd4:ov_ts_cnt[4] <= 1'b1; 
                5'd5:ov_ts_cnt[5] <= 1'b1; 
                5'd6:ov_ts_cnt[6] <= 1'b1; 
                5'd7:ov_ts_cnt[7] <= 1'b1; 
                5'd8:ov_ts_cnt[8] <= 1'b1; 
                5'd9:ov_ts_cnt[9] <= 1'b1; 
                5'd10:ov_ts_cnt[10] <= 1'b1; 
                5'd11:ov_ts_cnt[11] <= 1'b1; 
                5'd12:ov_ts_cnt[12] <= 1'b1; 
                5'd13:ov_ts_cnt[13] <= 1'b1; 
                5'd14:ov_ts_cnt[14] <= 1'b1; 
                5'd15:ov_ts_cnt[15] <= 1'b1; 
                5'd16:ov_ts_cnt[16] <= 1'b1; 
                5'd17:ov_ts_cnt[17] <= 1'b1; 
                5'd18:ov_ts_cnt[18] <= 1'b1; 
                5'd19:ov_ts_cnt[19] <= 1'b1; 
                5'd20:ov_ts_cnt[20] <= 1'b1; 
                5'd21:ov_ts_cnt[21] <= 1'b1;
                5'd22:ov_ts_cnt[22] <= 1'b1; 
                5'd23:ov_ts_cnt[23] <= 1'b1; 
                5'd24:ov_ts_cnt[24] <= 1'b1; 
                5'd25:ov_ts_cnt[25] <= 1'b1; 
                5'd26:ov_ts_cnt[26] <= 1'b1; 
                5'd27:ov_ts_cnt[27] <= 1'b1; 
                5'd28:ov_ts_cnt[28] <= 1'b1; 
                5'd29:ov_ts_cnt[29] <= 1'b1; 
                5'd30:ov_ts_cnt[30] <= 1'b1; 
                5'd31:ov_ts_cnt[31] <= 1'b1;
            endcase 
        end             
        else if(o_ts_descriptor_wr == 1'b1)begin
            case(ts_descriptor_raddr)
                5'd0:ov_ts_cnt[0] <= 1'b0;  
                5'd1:ov_ts_cnt[1] <= 1'b0; 
                5'd2:ov_ts_cnt[2] <= 1'b0; 
                5'd3:ov_ts_cnt[3] <= 1'b0; 
                5'd4:ov_ts_cnt[4] <= 1'b0; 
                5'd5:ov_ts_cnt[5] <= 1'b0; 
                5'd6:ov_ts_cnt[6] <= 1'b0; 
                5'd7:ov_ts_cnt[7] <= 1'b0; 
                5'd8:ov_ts_cnt[8] <= 1'b0; 
                5'd9:ov_ts_cnt[9] <= 1'b0; 
                5'd10:ov_ts_cnt[10] <= 1'b0; 
                5'd11:ov_ts_cnt[11] <= 1'b0; 
                5'd12:ov_ts_cnt[12] <= 1'b0; 
                5'd13:ov_ts_cnt[13] <= 1'b0; 
                5'd14:ov_ts_cnt[14] <= 1'b0; 
                5'd15:ov_ts_cnt[15] <= 1'b0; 
                5'd16:ov_ts_cnt[16] <= 1'b0; 
                5'd17:ov_ts_cnt[17] <= 1'b0; 
                5'd18:ov_ts_cnt[18] <= 1'b0; 
                5'd19:ov_ts_cnt[19] <= 1'b0; 
                5'd20:ov_ts_cnt[20] <= 1'b0; 
                5'd21:ov_ts_cnt[21] <= 1'b0;
                5'd22:ov_ts_cnt[22] <= 1'b0; 
                5'd23:ov_ts_cnt[23] <= 1'b0; 
                5'd24:ov_ts_cnt[24] <= 1'b0; 
                5'd25:ov_ts_cnt[25] <= 1'b0; 
                5'd26:ov_ts_cnt[26] <= 1'b0; 
                5'd27:ov_ts_cnt[27] <= 1'b0; 
                5'd28:ov_ts_cnt[28] <= 1'b0; 
                5'd29:ov_ts_cnt[29] <= 1'b0; 
                5'd30:ov_ts_cnt[30] <= 1'b0; 
                5'd31:ov_ts_cnt[31] <= 1'b0;
                default:begin
                    ov_ts_cnt <= ov_ts_cnt;
                end
            endcase         
        end
        else begin
            ov_ts_cnt <= ov_ts_cnt;
        end
    end
end
*/
//***************************************************
//      count underflow error of 32 TS flow 
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_ts_underflow_error_pulse <= 1'b0;
    end
    else begin
        if(i_ts_submit_addr_wr & o_ts_submit_addr_ack == 1'b1)begin
            if(|((32'h1 << iv_ts_submit_addr) & ov_ts_cnt)==1'b0)begin//underflow error
                o_ts_underflow_error_pulse <= 1'b1;    
            end
            else begin
                o_ts_underflow_error_pulse <= 1'b0;
            end
        end
        else begin
            o_ts_underflow_error_pulse <= 1'b0;
        end     
    end
end
sdprf32x13_rq ts_bufid_buffer
(    
    .aclr(!i_rst_n),  
    .clock(i_clk),
    .data(iv_ts_descriptor),
    .wren(i_ts_descriptor_wr),
    .wraddress(iv_ts_descriptor_waddr),
    
    .rden(ts_descriptor_rd),
    .rdaddress(ts_descriptor_raddr),
    .q(ts_descriptor_rdata)    
);
output reg [15:0] ov_debug_ts_cnt; 
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_debug_ts_cnt <= 16'b0;
    end
    else begin
        if(i_ts_descriptor_wr)begin
            ov_debug_ts_cnt <= ov_debug_ts_cnt + 1'b1;
        end
        else begin
            ov_debug_ts_cnt <= ov_debug_ts_cnt;
        end
    end
end	               
endmodule