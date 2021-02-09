// Copyright (C) 1953-2020 NUDT
// Verilog module name - ts_overflow_monitor
// Version: TOM_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - monitor whether TS packet is overflow;
//         - transmit nmac packet to CSM.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module ts_overflow_monitor
(
       i_clk,
       i_rst_n,
       
       iv_data,
       i_data_wr,
       iv_ctrl_data,
       
       iv_ts_cnt,
       o_pkt_cnt_pulse,
       
       ov_nmac_data,
       o_nmac_data_wr,
       
       ov_data,
       o_data_wr,
       ov_ctrl_data,
       
       o_ts_overflow_error_pulse,
       tom_state       
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input      [8:0]       iv_data;
input                  i_data_wr;
input      [18:0]      iv_ctrl_data;
//TS traffic state
input      [31:0]      iv_ts_cnt;
output reg             o_pkt_cnt_pulse;
// nmac pkt output
output reg [8:0]       ov_nmac_data;
output reg             o_nmac_data_wr;
// pkt output
output reg [8:0]       ov_data;
output reg             o_data_wr;
output reg [18:0]      ov_ctrl_data;

//count overflow error of 32 TS flow 
output reg             o_ts_overflow_error_pulse;
//***************************************************
//        judge whether TS traffic is overflow 
//***************************************************
// internal reg&wire for state machine
reg                    r_ts_overflow_flag;
reg        [4:0]       rv_ts_injection_addr;
output reg [1:0]       tom_state;
localparam  IDLE_S = 2'd0,
            TRANS_DATA_S = 2'd1,
            TRANS_NMAC_S = 2'd2,
            DISC_DATA_S = 2'd3;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_nmac_data <= 9'b0;
        o_nmac_data_wr <= 1'b0;
        
        ov_data <= 9'b0;
        o_data_wr <= 1'b0;
        ov_ctrl_data <= 19'b0;
        
        o_pkt_cnt_pulse <= 1'b0;
        
        r_ts_overflow_flag <= 1'b0;
        rv_ts_injection_addr <= 5'b0;
        
        tom_state <= IDLE_S;
    end
    else begin
        case(tom_state)
            IDLE_S:begin
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b1)begin
                    o_pkt_cnt_pulse <= 1'b1;
                    if(iv_ctrl_data[18:16] == 3'b101)begin //nmac
                        ov_nmac_data <= iv_data;
                        o_nmac_data_wr <= 1'b1;
                        tom_state <= TRANS_NMAC_S;
                    end
                    else if((iv_ctrl_data[18:16] == 3'b000) || (iv_ctrl_data[18:16] == 3'b001) || (iv_ctrl_data[18:16] == 3'b010))begin//ts
                        if(|((32'h1 << iv_ctrl_data[15:11]) & iv_ts_cnt)==1'b0)begin //not overflow
                            ov_data <= iv_data;
                            o_data_wr <= 1'b1;
                            ov_ctrl_data <= iv_ctrl_data;
                            tom_state <= TRANS_DATA_S;
                        end
                        else begin
                            r_ts_overflow_flag <= 1'b1;
                            rv_ts_injection_addr <= iv_ctrl_data[15:11];
                            ov_data <= 9'b0;
                            o_data_wr <= 1'b0;
                            tom_state <= DISC_DATA_S;
                        end                     
                    end
                    else begin
                        ov_data <= iv_data;
                        o_data_wr <= 1'b1;
                        ov_ctrl_data <= iv_ctrl_data;
                        tom_state <= TRANS_DATA_S;                      
                    end 
                end
                else begin
                    ov_nmac_data <= 9'b0;
                    o_nmac_data_wr <= 1'b0;
                    
                    ov_data <= 9'b0;
                    o_data_wr <= 1'b0;
                    ov_ctrl_data <= 19'b0;
                    
                    o_pkt_cnt_pulse <= 1'b0;
                    
                    r_ts_overflow_flag <= 1'b0;
                    rv_ts_injection_addr <= 5'b0;
                    
                    tom_state <= IDLE_S;                    
                end
            end
            TRANS_DATA_S:begin 
                ov_data <= iv_data;
                o_data_wr <= i_data_wr;
                o_pkt_cnt_pulse <= 1'b0;
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b1)begin
                    tom_state <= IDLE_S;    
                end
                else begin  
                    tom_state <= TRANS_DATA_S;  
                end
            end
            TRANS_NMAC_S:begin 
                ov_nmac_data <= iv_data;
                o_nmac_data_wr <= 1'b1;
                o_pkt_cnt_pulse <= 1'b0;
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b1)begin
                    tom_state <= IDLE_S;    
                end
                else begin  
                    tom_state <= TRANS_NMAC_S;  
                end
            end         
            DISC_DATA_S:begin 
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                r_ts_overflow_flag <= 1'b0;
                o_pkt_cnt_pulse <= 1'b0;
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b1)begin
                    tom_state <= IDLE_S;    
                end
                else begin  
                    tom_state <= DISC_DATA_S;   
                end
            end         
            default:begin
                ov_nmac_data <= 9'b0;
                o_nmac_data_wr <= 1'b0;
                
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                
                o_pkt_cnt_pulse <= 1'b0;
                
                tom_state <= IDLE_S;
            end
        endcase
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
        if(r_ts_overflow_flag == 1'b1 && (|((32'h1 << rv_ts_injection_addr) & iv_ts_cnt)==1'b1))begin
            o_ts_overflow_error_pulse <= 1'b1;           
        end
        else begin
            o_ts_overflow_error_pulse <= 1'b0; 
        end        
    end
end
endmodule