// Copyright (C) 1953-2020 NUDT
// Verilog module name - ptp_receive_process
// Version: PRP_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         Read data from fifo and record timestamp for PTP packet.
//             
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module ptp_receive_process
(
        clk_sys,
        reset_n,
        
        iv_cfg_finish,

        iv_data,
        o_data_rd,
        i_data_empty,
        timer,
        iv_syned_global_time,       

        ov_data,
        o_data_wr,
        report_prp_state,
        o_fifo_underflow_pulse     
);

// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;
//configuration finish and time synchronization finish
input      [1:0]        iv_cfg_finish;  
// fifo read
output  reg             o_data_rd;
input       [8:0]       iv_data;
input                   i_data_empty;
//timer
input       [18:0]      timer;
input       [47:0]      iv_syned_global_time;
// data output
output  reg [8:0]       ov_data;
output  reg             o_data_wr;
output      [1:0]       report_prp_state;
output  reg             o_fifo_underflow_pulse;
// internal reg&wire
reg         [18:0]      rv_rec_ts;
reg         [47:0]      rv_rec_global_ts;
reg         [1:0]       delay_cycle;
reg                     r_is_ptp;
reg                     r_is_ptp_resp;
reg         [10:0]      pkt_cycle_cnt;
reg         [2:0]       prp_state;
assign report_prp_state = prp_state[1:0];
localparam  IDLE_S        = 3'd0,
            FIRST_CYCLE_S = 3'd1,
            TRANS_S       = 3'd2,
            DISC_S        = 3'd3,
            RDEMPTY_ERROR_S= 3'd4;
//***************************************************
//              record timestamp 
//***************************************************
always@(posedge clk_sys or negedge reset_n)begin
    if(!reset_n) begin
        ov_data          <= 9'b0;
        o_data_wr        <= 1'b0;
        r_is_ptp         <= 1'b0;
        r_is_ptp_resp    <= 1'b0;
        rv_rec_ts        <= 19'b0;
        rv_rec_global_ts <= 48'b0;
        o_data_rd        <= 1'b0;
        pkt_cycle_cnt    <= 11'd0;
        delay_cycle      <= 2'b0;
        o_fifo_underflow_pulse <= 1'b0;
        prp_state        <= IDLE_S;
    end
    else begin
        case(prp_state)
            IDLE_S:begin
                ov_data             <= 9'b0;
                o_data_wr           <= 1'b0;
                pkt_cycle_cnt       <= 11'd0;
                rv_rec_ts           <= 19'b0;
                rv_rec_global_ts    <= 48'b0;
                r_is_ptp_resp       <= 1'b0;
                o_fifo_underflow_pulse <= 1'b0;
                if(i_data_empty == 1'b0)begin
                    if(delay_cycle == 2'h3)begin//delay 1 cycle
                        o_data_rd <= 1'b1;
                        delay_cycle <= 2'h0;
                        prp_state <= FIRST_CYCLE_S;
                    end
                    else if(delay_cycle == 2'h2)begin
                        o_data_rd       <= 1'b1;
                        delay_cycle <= delay_cycle + 1'b1;
                        prp_state <= IDLE_S;
                    end
                    else begin
                        o_data_rd       <= 1'b0;
                        delay_cycle <= delay_cycle + 1'b1;
                        prp_state <= IDLE_S;
                    end                    
                end
                else begin  
                    o_data_rd       <= 1'b0;
                    delay_cycle <= 2'h0;                
                    prp_state <= IDLE_S;
                end
            end          
            FIRST_CYCLE_S:begin
                o_fifo_underflow_pulse <= 1'b0;
                if(iv_data[8] == 1'b1 && i_data_empty == 1'b0) begin
                    if(iv_data[7:5] == 3'b100)begin //ptp packet
                        r_is_ptp <= 1'b1;
                    end
                    else begin
                        r_is_ptp <= 1'b0;
                    end
                    if(iv_cfg_finish == 2'h0)begin//discard all pkt.
                        ov_data <= 9'b0;
                        o_data_wr <= 1'b0;
                        o_data_rd <= 1'b1;
                        prp_state <= DISC_S;                        
                    end                    
                    else if(iv_cfg_finish == 2'h1)begin//only forward nmac pkt.
                        if(iv_data[7:5] == 3'b101)begin//nmac pkt
                            ov_data <= iv_data;
                            o_data_wr <= 1'b1;
                            pkt_cycle_cnt <= pkt_cycle_cnt + 11'd1;
                            rv_rec_ts <= timer;
                            rv_rec_global_ts <= iv_syned_global_time;
                            o_data_rd <= 1'b1;
                            prp_state <= TRANS_S;
                        end
                        else begin
                            ov_data <= 9'b0;
                            o_data_wr <= 1'b0;
                            o_data_rd <= 1'b1;
                            prp_state <= DISC_S;                        
                        end
                    end
                    else if(iv_cfg_finish == 2'h2)begin//forward pkt except ts pkt.
                        if((iv_data[7:5] != 3'b000) && (iv_data[7:5] != 3'b001) && (iv_data[7:5] != 3'b010))begin 
                            ov_data <= iv_data;
                            o_data_wr <= 1'b1;
                            pkt_cycle_cnt <= pkt_cycle_cnt + 11'd1;
                            rv_rec_ts <= timer;
                            rv_rec_global_ts <= iv_syned_global_time;
                            o_data_rd <= 1'b1;
                            prp_state <= TRANS_S;
                        end
                        else begin
                            ov_data <= 9'b0;
                            o_data_wr <= 1'b0;
                            o_data_rd <= 1'b1;
                            prp_state <= DISC_S;                        
                        end                    
                    end
                    else if(iv_cfg_finish == 2'h3)begin//forward all pkt.
                        ov_data <= iv_data;
                        o_data_wr <= 1'b1;
                        pkt_cycle_cnt <= pkt_cycle_cnt + 11'd1;
                        rv_rec_ts <= timer;
                        rv_rec_global_ts <= iv_syned_global_time;
                        o_data_rd <= 1'b1;
                        prp_state <= TRANS_S;
                    end
                    else begin
                        ov_data <= 9'b0;
                        o_data_wr <= 1'b0;
                        o_data_rd <= 1'b1;
                        prp_state <= DISC_S;                        
                    end                    
                end
                else begin
                    ov_data <= 9'b0;
                    o_data_wr <= 1'b0;
                    o_data_rd <= 1'b0;                  
                    prp_state <= IDLE_S;
                end
            end
            TRANS_S:begin
                if(r_is_ptp == 1'b1 && pkt_cycle_cnt == 11'd22 && iv_data[3:0] == 4'd4)begin //ptp resp
                    r_is_ptp_resp <= 1'b1;
                end
                else begin
                    r_is_ptp_resp <= r_is_ptp_resp;
                end
                if(iv_data[8] == 1'b0 && i_data_empty == 1'b0) begin
                    o_data_wr <= 1'b1;
                    pkt_cycle_cnt <= pkt_cycle_cnt + 11'd1;                 
                    o_data_rd <= 1'b1;
                    prp_state <= TRANS_S;
                    if(r_is_ptp == 1'b1 && r_is_ptp_resp == 1'b0)begin //ptp sync, ptp req
                        case(pkt_cycle_cnt)
                            11'd11:ov_data <= {iv_data[8:3],rv_rec_ts[18:16]};
                            11'd12:ov_data <= {1'b0,rv_rec_ts[15:8]};
                            11'd13:ov_data <= {1'b0,rv_rec_ts[7:0]};
                            11'd60:ov_data <= {1'b0,rv_rec_global_ts[47:40]};
                            11'd61:ov_data <= {1'b0,rv_rec_global_ts[39:32]};
                            11'd62:ov_data <= {1'b0,rv_rec_global_ts[31:24]};
                            11'd63:ov_data <= {1'b0,rv_rec_global_ts[23:16]};
                            11'd64:ov_data <= {1'b0,rv_rec_global_ts[15:8]};
                            11'd65:ov_data <= {1'b0,rv_rec_global_ts[7:0]};
                            default:begin
                                ov_data <= iv_data;
                            end
                        endcase
                    end 
                    else if(r_is_ptp == 1'b1 && r_is_ptp_resp == 1'b1)begin//ptp resp
                        case(pkt_cycle_cnt)
                            11'd11:ov_data <= {iv_data[8:3],rv_rec_ts[18:16]};
                            11'd12:ov_data <= {1'b0,rv_rec_ts[15:8]};
                            11'd13:ov_data <= {1'b0,rv_rec_ts[7:0]};
                            default:begin
                                ov_data <= iv_data;
                            end
                        endcase
                    end
                    else begin
                        ov_data <= iv_data;
                    end                 
                end
                else if(iv_data[8] == 1'b1) begin
                    ov_data <= iv_data;
                    o_data_wr <= 1'b1;
                    o_data_rd <= 1'b0;                  
                    prp_state <= IDLE_S;
                end
                else if(i_data_empty == 1'b1)begin
                    ov_data <= {1'b1,8'b0};
                    o_data_wr <= 1'b1;
                    o_data_rd <= 1'b1;
                    o_fifo_underflow_pulse <= 1'b1;
                    prp_state <= RDEMPTY_ERROR_S;
                end                
                else begin
                    ov_data <= 9'b0;
                    o_data_wr <= 1'b0;
                    o_data_rd <= 1'b0;
                    prp_state <= IDLE_S;
                end
            end
            DISC_S:begin
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                if(iv_data[8] == 1'b1)begin
                    o_data_rd <= 1'b0;                  
                    prp_state <= IDLE_S;
                end
                else begin
                    o_data_rd <= 1'b1;
                    prp_state <= DISC_S;
                end                           
            end
            RDEMPTY_ERROR_S:begin
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                o_fifo_underflow_pulse <= 1'b0;
                if(iv_data[8] == 1'b1)begin
                    o_data_rd <= 1'b0;                  
                    prp_state <= IDLE_S;
                end
                else begin
                    o_data_rd <= 1'b1;
                    prp_state <= RDEMPTY_ERROR_S;
                end             
            end
            default:begin
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                o_data_rd <= 1'b0;
                o_fifo_underflow_pulse <= 1'b0; 
                prp_state <= IDLE_S;                
            end
        endcase
    end
end 
endmodule