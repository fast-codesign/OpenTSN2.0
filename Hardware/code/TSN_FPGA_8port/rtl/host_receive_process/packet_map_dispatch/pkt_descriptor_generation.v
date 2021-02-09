// Copyright (C) 1953-2020 NUDT
// Verilog module name - pkt_descriptor_generation
// Version: PDG_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         generate descriptor of packet.
//             - write descriptor of TS packet to ram;
//             - transmit descriptor of not TS packet to FLT to look up table.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module pkt_descriptor_generation
(
       i_clk,
       i_rst_n,
       
       i_data_wr,
       iv_data,
       iv_ctrl_data,
       
       i_bufid_empty,
       iv_bufid,
       
       ov_ts_descriptor,
       o_ts_descriptor_wr,
       ov_ts_descriptor_waddr,
       
       ov_nts_descriptor,
       o_nts_descriptor_wr,
       i_nts_descriptor_ack,
       
       iv_free_bufid_fifo_rdusedw,
       iv_rc_threshold_value,
       iv_be_threshold_value,       

       descriptor_state       
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input      [8:0]       iv_data;
input                  i_data_wr;
input      [18:0]      iv_ctrl_data;

input                  i_bufid_empty;
input      [8:0]       iv_bufid;
// descriptor of ts pkt output
output reg [35:0]      ov_ts_descriptor;
output reg             o_ts_descriptor_wr;
output reg [4:0]       ov_ts_descriptor_waddr;
// descriptor of not ts pkt output
output reg [45:0]      ov_nts_descriptor;
output reg             o_nts_descriptor_wr;
input                  i_nts_descriptor_ack; 
//threshold of discard
input      [8:0]       iv_free_bufid_fifo_rdusedw;
input      [8:0]       iv_rc_threshold_value;
input      [8:0]       iv_be_threshold_value;
//***************************************************
//          generate descriptor of packet 
//***************************************************
// internal reg&wire for state machine
reg        [1:0]       pkt_cycle_cnt;
reg        [45:0]      rv_descriptor;
output reg [2:0]       descriptor_state;
localparam  IDLE_S = 3'd0,
            GET_DESCRIPTOR_S = 3'd1,
            TRANSMIT_DESCRIPTOR_S = 3'd2,
            WAIT_ACK_S = 3'd3,
            WAIT_LAST_S = 3'd4;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_ts_descriptor <= 36'b0;
        o_ts_descriptor_wr <= 1'b0;
        ov_ts_descriptor_waddr <= 5'b0;
        
        ov_nts_descriptor <= 46'b0;
        o_nts_descriptor_wr <= 1'b0;
        
        rv_descriptor <= 46'b0;
        
        pkt_cycle_cnt <= 2'd0;
        
        descriptor_state <=IDLE_S;
    end
    else begin
        case(descriptor_state)
            IDLE_S:begin
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b1)begin //first cycle
                    if((((iv_ctrl_data[18:16] == 3'b011)||(iv_ctrl_data[18:16] == 3'b110)) && (iv_free_bufid_fifo_rdusedw <= iv_rc_threshold_value))||((iv_ctrl_data[18:16] == 3'b110) && (iv_free_bufid_fifo_rdusedw <= iv_be_threshold_value))||(i_bufid_empty == 1'b1))begin
                        //do not handle BE pkt when bufid under be_threshold_value
                        //do not handle BE & RC pkt when bufid under rc_threshold_value
                        //do not handle all pkt when bufid is used up
                        descriptor_state <= WAIT_LAST_S;
                    end 
                    else begin
                        rv_descriptor[45:41] <= iv_ctrl_data[15:11];  //injection addr
                        rv_descriptor[40] <= iv_ctrl_data[0]; //frag last
                        rv_descriptor[39:36] <= 4'd8; //host port
                        rv_descriptor[18] <= iv_ctrl_data[1]; //lookup_en
                        rv_descriptor[17:9] <= iv_ctrl_data[10:2]; //outport
                        rv_descriptor[8:0] <= iv_bufid;
                        
                        rv_descriptor[35:33] <= iv_ctrl_data[18:16]; //pkttype
                        rv_descriptor[32:28] <= iv_data[4:0]; //flowid
                        pkt_cycle_cnt <= pkt_cycle_cnt + 1'b1;
                        descriptor_state <= GET_DESCRIPTOR_S;
                    end                   
                end
                else begin
                    ov_ts_descriptor <= 36'b0;
                    o_ts_descriptor_wr <= 1'b0;
                    ov_ts_descriptor_waddr <= 5'b0;
                    
                    ov_nts_descriptor <= 46'b0;
                    o_nts_descriptor_wr <= 1'b0;
                    
                    rv_descriptor <= 46'b0;
                    pkt_cycle_cnt <= 2'd0;
                    
                    descriptor_state <=IDLE_S;                  
                end
            end
            GET_DESCRIPTOR_S:begin 
                pkt_cycle_cnt <= pkt_cycle_cnt + 1'b1;
                if(pkt_cycle_cnt == 2'd1)begin
                    rv_descriptor[27:20] <= iv_data[7:0]; //flowid
                end
                else begin                
                    rv_descriptor[19] <= iv_data[7]; //flowid
                    descriptor_state <= TRANSMIT_DESCRIPTOR_S;      
                end
            end
            TRANSMIT_DESCRIPTOR_S:begin
                if((rv_descriptor[35:33] == 3'b000) || (rv_descriptor[35:33] == 3'b001) || (rv_descriptor[35:33] == 3'b010))begin //TS
                    ov_ts_descriptor <= {rv_descriptor[40],rv_descriptor[34:33],rv_descriptor[32:0]};
                    o_ts_descriptor_wr <= 1'b1;
                    ov_ts_descriptor_waddr <= rv_descriptor[45:41];                 
                    descriptor_state <= WAIT_LAST_S;                            
                end
                else begin // not ts
                    ov_nts_descriptor <= rv_descriptor;
                    o_nts_descriptor_wr <= 1'b1;
                    descriptor_state <= WAIT_ACK_S;                     
                end
            end
            WAIT_ACK_S:begin//transmit nts descriptor to FLT,and wait receive ack signal from FLT.
                if(i_nts_descriptor_ack == 1'b1)begin
                    ov_nts_descriptor <= 46'b0;
                    o_nts_descriptor_wr <= 1'b0;
                    descriptor_state <= WAIT_LAST_S;                
                end
                else begin
                    descriptor_state <= WAIT_ACK_S;
                end
            end
            WAIT_LAST_S:begin
                o_ts_descriptor_wr <= 1'b0;
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b1)begin
                    descriptor_state <=IDLE_S;              
                end
                else begin
                    descriptor_state <= WAIT_LAST_S;
                end
            end         
            default:begin               
                descriptor_state <=IDLE_S;
            end
        endcase
   end
end  
endmodule 