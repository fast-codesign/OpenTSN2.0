// Copyright (C) 1953-2020 NUDT
// Verilog module name - nmac_parse_module 
// Version: NPM_V1.0
// Created:
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         parse NMAC pkt 
//         configure the regist
//         configure the RAM
///////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module nmac_parse_module
(
       i_clk,
       i_rst_n,

       iv_nmac_data,
       i_nmac_data_wr,
       
       ov_time_offset,
       o_time_offset_wr,
       ov_cfg_finish,
       ov_port_type,
       ov_slot_len,
       ov_inject_slot_period,
       ov_submit_slot_period,
       o_qbv_or_qch,
       ov_report_period,
       ov_report_type,
       o_report_en,
       
       ov_rc_regulation_value,
       ov_be_regulation_value,
       ov_unmap_regulation_value,
       
       ov_offset_period,//
       
       o_nmac_receive_pulse,
       
       ov_nmac_dmac,
       ov_nmac_smac,
       
       ov_wdata,
       ov_waddr,
       ov_wr
);


// I/O
// i_clk & rst
input                  i_clk;
input                  i_rst_n;
       
//nmac data
input      [8:0]       iv_nmac_data;               // input nmac data
input                  i_nmac_data_wr;             // nmac writer signals

//configure regist
output reg [48:0]      ov_time_offset;
output reg             o_time_offset_wr;
output reg [1:0]       ov_cfg_finish;
output reg [7:0]       ov_port_type;
output reg [10:0]      ov_slot_len;
output reg [10:0]      ov_inject_slot_period;
output reg [10:0]      ov_submit_slot_period;
output reg             o_qbv_or_qch;
output reg [11:0]      ov_report_period;
output reg [15:0]      ov_report_type;
output reg             o_report_en;

output reg [8:0]       ov_rc_regulation_value;
output reg [8:0]       ov_be_regulation_value;
output reg [8:0]       ov_unmap_regulation_value;

output reg [23:0]      ov_offset_period;

output reg             o_nmac_receive_pulse;

// NMAC DMAC and SMAC
output reg [47:0]      ov_nmac_dmac;
output reg [47:0]      ov_nmac_smac;

//configure RAM
output reg [15:0]      ov_wdata;
output reg [15:0]      ov_waddr;
output reg [10:0]      ov_wr;

reg        [8:0]       rv_init_cnt;
reg        [3:0]       rv_pkt_cycle_cnt;
reg        [7:0]       rv_configure_cnt;
reg        [31:0]      rv_configure_addr;
//////////////////////////////////////////////////
//                  state                       //
//////////////////////////////////////////////////
reg     [2:0]         npm_state;
localparam            INIT_S    = 3'd0,
                      IDLE_S    = 3'd1,
                      DMAC_S    = 3'd2,
                      SMAC_S    = 3'd3,
                      COUNT_S   = 3'd4,
                      ADDR_S    = 3'd5,
                      DATA_S    = 3'd6,
                      DISC_S    = 3'd7;
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        ov_offset_period <= 24'h0;
        ov_time_offset   <= 49'h0;
        o_time_offset_wr <= 1'h0;
        ov_cfg_finish    <= 2'h0;
        ov_port_type     <= 8'hFF; //reset port type is 1
        ov_slot_len      <= 11'h4;
        ov_inject_slot_period   <= 11'h1;
        ov_submit_slot_period   <= 11'h1;
        
        ov_rc_regulation_value   <= 9'h0;
        ov_be_regulation_value   <= 9'h0;
        ov_unmap_regulation_value<= 9'h0;
                                   
        o_qbv_or_qch     <= 1'h0;
        ov_report_period <= 12'h1;
        ov_report_type   <= 16'h0;
        o_report_en      <= 1'h1;
        ov_nmac_smac     <= 48'h010101010101;
        ov_nmac_dmac     <= 48'ha00000004000;
        
        ov_wdata         <= 16'h0;
        ov_waddr         <= 16'h0;
        ov_wr            <= 11'h0;
        
        o_nmac_receive_pulse <= 1'd0;
        
        rv_init_cnt      <= 9'h0;
        rv_pkt_cycle_cnt <= 4'b0;
        rv_configure_cnt <= 8'h0;
        rv_configure_addr<= 32'd0;
        npm_state        <= INIT_S;
    end
    else begin
        case(npm_state)
            INIT_S:begin // wait the PCB write bufid to fifo
                if(rv_init_cnt < 9'd510) begin
                    rv_init_cnt      <= rv_init_cnt + 1'b1;
                end
                else begin
                    ov_cfg_finish <= 2'd1;
                    npm_state     <= IDLE_S;
                end 
            end
            
            IDLE_S:begin // receive the nmac pkt
                o_time_offset_wr <= 1'h0;
                
                rv_configure_addr<= 32'd0;
                rv_configure_cnt <= 8'h0;
                
                ov_wdata         <= 16'h0;
                ov_waddr         <= 16'h0;
                ov_wr            <= 11'h0;
                if(i_nmac_data_wr == 1'b1)begin
                    o_nmac_receive_pulse <= 1'd1;
                    ov_nmac_dmac[47:40] <= iv_nmac_data[7:0];
                    npm_state     <= DMAC_S;
                end
                else begin
                    o_nmac_receive_pulse <= 1'd0;
                    npm_state     <= IDLE_S;
                end
            end
            
            DMAC_S:begin // record the pkt dmac
                o_nmac_receive_pulse <= 1'd0;
                if(i_nmac_data_wr == 1'b1)begin
                    if(rv_pkt_cycle_cnt < 4'd4)begin//extract DMAC
                        rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                        case(rv_pkt_cycle_cnt)
                            4'd0:ov_nmac_dmac[39:32] <= iv_nmac_data[7:0];
                            4'd1:ov_nmac_dmac[31:24] <= iv_nmac_data[7:0];
                            4'd2:ov_nmac_dmac[23:16] <= iv_nmac_data[7:0];
                            4'd3:ov_nmac_dmac[15:8]  <= iv_nmac_data[7:0];
                            default: ov_nmac_dmac   <= ov_nmac_dmac;
                        endcase
                        npm_state     <= DMAC_S;
                    end
                    else begin
                        ov_nmac_dmac[7:0]   <= iv_nmac_data[7:0];
                        rv_pkt_cycle_cnt    <= 4'b0;
                        npm_state           <= SMAC_S;
                    end
                end
                else begin
                    rv_pkt_cycle_cnt   <= rv_pkt_cycle_cnt;
                    npm_state     <= DMAC_S;
                end
            end
            
            SMAC_S:begin // record the pkt smac
                if(i_nmac_data_wr == 1'b1)begin
                    if(rv_pkt_cycle_cnt < 4'd5)begin//extract SMAC
                        rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                        case(rv_pkt_cycle_cnt)
                            4'd0:ov_nmac_smac[47:40] <= iv_nmac_data[7:0];
                            4'd1:ov_nmac_smac[39:32] <= iv_nmac_data[7:0];
                            4'd2:ov_nmac_smac[31:24] <= iv_nmac_data[7:0];
                            4'd3:ov_nmac_smac[23:16] <= iv_nmac_data[7:0];
                            4'd4:ov_nmac_smac[15:8]  <= iv_nmac_data[7:0];
                            default: ov_nmac_smac   <= ov_nmac_smac;
                        endcase
                        npm_state     <= SMAC_S;
                    end
                    else begin
                        ov_nmac_smac[7:0]   <= iv_nmac_data[7:0];
                        rv_pkt_cycle_cnt    <= 4'b0;
                        npm_state           <= COUNT_S;
                    end
                end
                else begin
                    rv_pkt_cycle_cnt   <= rv_pkt_cycle_cnt;
                    npm_state     <= SMAC_S;
                end
            end
            
            COUNT_S:begin  // record the namc pkt configure count
                if(i_nmac_data_wr == 1'b1)begin
                    if(rv_pkt_cycle_cnt < 4'd3)begin//extract count
                        rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                        case(rv_pkt_cycle_cnt)
                            4'd2:rv_configure_cnt <= iv_nmac_data[7:0];
                            default: rv_configure_cnt   <= rv_configure_cnt;   
                        endcase
                        npm_state     <= COUNT_S;
                    end
                    else begin
                        rv_pkt_cycle_cnt   <= 4'b0;
                        npm_state     <= ADDR_S;
                    end
                end
                else begin
                    rv_pkt_cycle_cnt   <= rv_pkt_cycle_cnt;
                    npm_state     <= COUNT_S;
                end
            end
            
            ADDR_S:begin // record the nmac pkt configure regist addr
                if(i_nmac_data_wr == 1'b1)begin
                    if(rv_pkt_cycle_cnt < 4'd3)begin//extract regist addr
                        rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                        case(rv_pkt_cycle_cnt)
                            4'd0:rv_configure_addr[31:24] <= iv_nmac_data[7:0];
                            4'd1:rv_configure_addr[23:16]  <= iv_nmac_data[7:0];
                            4'd2:rv_configure_addr[15:8]  <= iv_nmac_data[7:0];
                            default: rv_configure_addr   <= rv_configure_addr;   
                        endcase
                        npm_state     <= ADDR_S;
                    end
                    else begin
                        rv_pkt_cycle_cnt        <= 4'b0;
                        rv_configure_addr[7:0]  <= iv_nmac_data[7:0];
                        npm_state               <= DATA_S;
                    end
                end
                else begin
                    rv_pkt_cycle_cnt   <= rv_pkt_cycle_cnt;
                    npm_state     <= ADDR_S;
                end
            end
            
            DATA_S:begin
                if(i_nmac_data_wr == 1'b1)begin
                    if(rv_configure_addr[26:20] == 7'd0)begin//configure csm module
                        if(rv_configure_addr[18:0] == 19'd0)begin//configure offset regist low
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                case(rv_pkt_cycle_cnt)
                                    4'd0:ov_time_offset  <= {ov_time_offset[48:32],iv_nmac_data[7:0],ov_time_offset[23:0]};
                                    4'd1:ov_time_offset  <= {ov_time_offset[48:24],iv_nmac_data[7:0],ov_time_offset[15:0]};
                                    4'd2:ov_time_offset  <= {ov_time_offset[48:16],iv_nmac_data[7:0],ov_time_offset[7:0]};
                                    default:ov_time_offset  <= ov_time_offset;
                                endcase
                            end
                            else begin
                                ov_time_offset  <= {ov_time_offset[48:8],iv_nmac_data[7:0]};
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd1)begin//configure offset regist high 
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                case(rv_pkt_cycle_cnt)
                                    4'd1:ov_time_offset  <= {iv_nmac_data[0],ov_time_offset[47:0]};
                                    4'd2:ov_time_offset  <= {ov_time_offset[48],iv_nmac_data[7:0],ov_time_offset[39:0]};
                                    default:ov_time_offset  <= ov_time_offset;
                                endcase
                            end
                            else begin
                                ov_time_offset   <= {ov_time_offset[48:40],iv_nmac_data[7:0],ov_time_offset[31:0]};
                                o_time_offset_wr <= 1'b1;
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin 
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd2)begin//configure slot_len regist
                            o_time_offset_wr <= 1'b0;
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                case(rv_pkt_cycle_cnt)
                                    4'd2:ov_slot_len  <= {iv_nmac_data[2:0],ov_slot_len[7:0]};
                                    default:ov_slot_len  <= ov_slot_len;
                                endcase
                            end
                            else begin
                                ov_slot_len  <= {ov_slot_len[10:8],iv_nmac_data[7:0]};
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd3)begin//configure cfg_finish regist
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                ov_cfg_finish  <= ov_cfg_finish;
                            end
                            else begin
                                ov_cfg_finish  <= iv_nmac_data[1:0];
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd4)begin//configure port_type regist
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                ov_port_type  <= ov_port_type;
                            end
                            else begin
                                ov_port_type  <= iv_nmac_data[7:0];
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd5)begin//configure qbv_or_qch regist
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                o_qbv_or_qch  <= o_qbv_or_qch;
                            end
                            else begin
                                o_qbv_or_qch  <= iv_nmac_data[0];
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd6)begin//configure report_type regist
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                case(rv_pkt_cycle_cnt)
                                    4'd2:ov_report_type[15:8]  <= iv_nmac_data[7:0];
                                    default:ov_report_type  <= ov_report_type;
                                endcase
                            end
                            else begin
                                ov_report_type[7:0]   <= iv_nmac_data[7:0];
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd7)begin//configure report_en regist
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                o_report_en  <= o_report_en;
                            end
                            else begin
                                o_report_en   <= iv_nmac_data[0];
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd8)begin//configure inject_slot_period regist
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                case(rv_pkt_cycle_cnt)
                                    4'd2:ov_inject_slot_period[10:8]   <= iv_nmac_data[2:0];
                                    default:ov_inject_slot_period  <= ov_inject_slot_period;
                                endcase
                            end
                            else begin
                                ov_inject_slot_period[7:0]   <= iv_nmac_data[7:0];
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd9)begin//configure submit_slot_period regist
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                case(rv_pkt_cycle_cnt)
                                    4'd2:ov_submit_slot_period[10:8]   <= iv_nmac_data[2:0];
                                    default:ov_submit_slot_period  <= ov_submit_slot_period;
                                endcase
                            end
                            else begin
                                ov_submit_slot_period[7:0]   <= iv_nmac_data[7:0];
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd10)begin//configure report_period regist
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                case(rv_pkt_cycle_cnt)
                                    4'd2:ov_report_period[11:8]  <= iv_nmac_data[3:0];
                                    default:ov_report_period  <= ov_report_period;
                                endcase
                            end
                            else begin
                                ov_report_period[7:0]   <= iv_nmac_data[7:0];
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin  
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd11)begin//configure offset_period regist 
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                case(rv_pkt_cycle_cnt)
                                    4'd1:ov_offset_period  <= {iv_nmac_data[7:0],ov_offset_period[15:0]};
                                    4'd2:ov_offset_period  <= {ov_offset_period[23:16],iv_nmac_data[7:0],ov_offset_period[7:0]};
                                    default:ov_offset_period  <= ov_offset_period;
                                endcase
                            end
                            else begin
                                ov_offset_period  <= {ov_offset_period[23:8],iv_nmac_data[7:0]};
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd12)begin//configure rc_regulation_value regist 
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                case(rv_pkt_cycle_cnt)
                                    4'd2:ov_rc_regulation_value  <= {iv_nmac_data[0],ov_rc_regulation_value[7:0]};
                                    default:ov_rc_regulation_value  <= ov_rc_regulation_value;
                                endcase
                            end
                            else begin
                                ov_rc_regulation_value  <= {ov_rc_regulation_value[8],iv_nmac_data[7:0]};
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd13)begin//configure be_regulation_value regist 
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                case(rv_pkt_cycle_cnt)
                                    4'd2:ov_be_regulation_value  <= {iv_nmac_data[0],ov_be_regulation_value[7:0]};
                                    default:ov_be_regulation_value  <= ov_be_regulation_value;
                                endcase
                            end
                            else begin
                                ov_be_regulation_value  <= {ov_be_regulation_value[8],iv_nmac_data[7:0]};
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end
                        
                        else if(rv_configure_addr[18:0] == 19'd14)begin//configure unmap_regulation_value regist 
                            if(rv_pkt_cycle_cnt < 4'd3)begin
                                rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                                npm_state     <= DATA_S;
                                case(rv_pkt_cycle_cnt)
                                    4'd2:ov_unmap_regulation_value  <= {iv_nmac_data[0],ov_unmap_regulation_value[7:0]};
                                    default:ov_unmap_regulation_value  <= ov_unmap_regulation_value;
                                endcase
                            end
                            else begin
                                ov_unmap_regulation_value  <= {ov_unmap_regulation_value[8],iv_nmac_data[7:0]};
                                rv_pkt_cycle_cnt <= 4'd0;
                                if(rv_configure_cnt == 8'b1)begin
                                    if(iv_nmac_data[8] == 1'b1)begin
                                        npm_state        <= IDLE_S;
                                    end
                                    else begin
                                        npm_state        <= DISC_S;
                                    end
                                end
                                else begin
                                    rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                    rv_configure_addr<= rv_configure_addr + 19'd1;
                                    npm_state        <= DATA_S;
                                end
                            end
                        end

                        else begin
                           rv_pkt_cycle_cnt <= 4'd0;
                           if(rv_configure_cnt == 8'b1)begin
                               if(iv_nmac_data[8] == 1'b1)begin
                                   npm_state        <= IDLE_S;
                               end
                               else begin
                                   npm_state        <= DISC_S;
                               end
                           end
                           else begin
                               rv_configure_cnt <= rv_configure_cnt - 8'b1;
                               rv_configure_addr<= rv_configure_addr + 19'd1;
                               npm_state        <= DATA_S;
                           end
                        end
                    end
                    
                    else if(rv_configure_addr[26:20] == 7'd1)begin//configure tis RAM
                        ov_waddr  <= rv_configure_addr[15:0];
                        if(rv_pkt_cycle_cnt < 4'd3)begin
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                            npm_state     <= DATA_S;
                            case(rv_pkt_cycle_cnt)
                                4'd2:ov_wdata  <= {iv_nmac_data[7:0],ov_wdata[7:0]};
                                default:begin
                                    ov_wdata  <= ov_wdata;
                                    ov_wr     <= 11'd0;
                                end
                            endcase  
                        end
                        else begin
                            ov_wdata  <= {ov_wdata[15:8],iv_nmac_data[7:0]};
                            ov_wr     <= 11'd2;
                            rv_pkt_cycle_cnt <= 4'd0;
                            if(rv_configure_cnt == 8'b1)begin
                                if(iv_nmac_data[8] == 1'b1)begin
                                    npm_state        <= IDLE_S;
                                end
                                else begin
                                    npm_state        <= DISC_S;
                                end
                            end
                            else begin
                                rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                rv_configure_addr<= rv_configure_addr + 19'd1;
                                npm_state        <= DATA_S;
                            end
                        end
                    end   
                    
                    else if(rv_configure_addr[26:20] == 7'd2)begin//configure tss RAM
                        ov_waddr  <= rv_configure_addr[15:0];
                        if(rv_pkt_cycle_cnt < 4'd3)begin
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                            npm_state     <= DATA_S;
                            case(rv_pkt_cycle_cnt)
                                4'd2:ov_wdata  <= {iv_nmac_data[7:0],ov_wdata[7:0]};
                                default:begin
                                    ov_wdata  <= ov_wdata;
                                    ov_wr     <= 11'd0;
                                end
                            endcase  
                        end
                        else begin
                            ov_wdata  <= {ov_wdata[15:8],iv_nmac_data[7:0]};
                            ov_wr     <= 11'd1;
                            rv_pkt_cycle_cnt <= 4'd0;
                            if(rv_configure_cnt == 8'b1)begin
                                if(iv_nmac_data[8] == 1'b1)begin
                                    npm_state        <= IDLE_S;
                                end
                                else begin
                                    npm_state        <= DISC_S;
                                end
                            end
                            else begin
                                rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                rv_configure_addr<= rv_configure_addr + 19'd1;
                                npm_state        <= DATA_S;
                            end
                        end
                    end                  
                    
                    else if(rv_configure_addr[26:20] == 7'd3)begin//configure qgc0 RAM
                        ov_waddr  <= rv_configure_addr[15:0];
                        if(rv_pkt_cycle_cnt < 4'd3)begin
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                            npm_state     <= DATA_S;
                            case(rv_pkt_cycle_cnt)
                                4'd2:ov_wdata  <= {iv_nmac_data[7:0],ov_wdata[7:0]};
                                default:begin
                                    ov_wdata  <= ov_wdata;
                                    ov_wr     <= 11'd0;
                                end
                            endcase  
                        end
                        else begin
                            ov_wdata  <= {ov_wdata[15:8],iv_nmac_data[7:0]};
                            ov_wr     <= 11'd8;
                            rv_pkt_cycle_cnt <= 4'd0;
                            if(rv_configure_cnt == 8'b1)begin  
                                if(iv_nmac_data[8] == 1'b1)begin
                                    npm_state        <= IDLE_S;
                                end
                                else begin
                                    npm_state        <= DISC_S;
                                end
                            end
                            else begin
                                rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                rv_configure_addr<= rv_configure_addr + 19'd1;
                                npm_state        <= DATA_S;
                            end
                        end
                    end
                    
                    else if(rv_configure_addr[26:20] == 7'd4)begin//configure qgc1 RAM
                        ov_waddr  <= rv_configure_addr[15:0];
                        if(rv_pkt_cycle_cnt < 4'd3)begin
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                            npm_state     <= DATA_S;
                            case(rv_pkt_cycle_cnt)
                                4'd2:ov_wdata  <= {iv_nmac_data[7:0],ov_wdata[7:0]};
                                default:begin
                                    ov_wdata  <= ov_wdata;
                                    ov_wr     <= 11'd0;
                                end
                            endcase  
                        end
                        else begin
                            ov_wdata  <= {ov_wdata[15:8],iv_nmac_data[7:0]};
                            ov_wr     <= 11'd16;
                            rv_pkt_cycle_cnt <= 4'd0;
                            if(rv_configure_cnt == 8'b1)begin
                                if(iv_nmac_data[8] == 1'b1)begin
                                    npm_state        <= IDLE_S;
                                end
                                else begin
                                    npm_state        <= DISC_S;
                                end
                            end
                            else begin
                                rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                rv_configure_addr<= rv_configure_addr + 19'd1;
                                npm_state        <= DATA_S;
                            end
                        end
                    end
                    
                    else if(rv_configure_addr[26:20] == 7'd5)begin//configure qgc2 RAM
                        ov_waddr  <= rv_configure_addr[15:0];
                        if(rv_pkt_cycle_cnt < 4'd3)begin
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                            npm_state     <= DATA_S;
                            case(rv_pkt_cycle_cnt)
                                4'd2:ov_wdata  <= {iv_nmac_data[7:0],ov_wdata[7:0]};
                                default:begin
                                    ov_wdata  <= ov_wdata;
                                    ov_wr     <= 11'd0;
                                end
                            endcase  
                        end
                        else begin
                            ov_wdata  <= {ov_wdata[15:8],iv_nmac_data[7:0]};
                            ov_wr     <= 11'd32;
                            rv_pkt_cycle_cnt <= 4'd0;
                            if(rv_configure_cnt == 8'b1)begin
                                if(iv_nmac_data[8] == 1'b1)begin
                                    npm_state        <= IDLE_S;
                                end
                                else begin
                                    npm_state        <= DISC_S;
                                end
                            end
                            else begin
                                rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                rv_configure_addr<= rv_configure_addr + 19'd1;
                                npm_state        <= DATA_S;
                            end
                        end
                    end
                    
                    else if(rv_configure_addr[26:20] == 7'd6)begin//configure qgc3 RAM
                        ov_waddr  <= rv_configure_addr[15:0];
                        if(rv_pkt_cycle_cnt < 4'd3)begin
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                            npm_state     <= DATA_S;
                            case(rv_pkt_cycle_cnt)
                                4'd2:ov_wdata  <= {iv_nmac_data[7:0],ov_wdata[7:0]};
                                default:begin
                                    ov_wdata  <= ov_wdata;
                                    ov_wr     <= 11'd0;
                                end
                            endcase  
                        end
                        else begin
                            ov_wdata  <= {ov_wdata[15:8],iv_nmac_data[7:0]};
                            ov_wr     <= 11'd64;
                            rv_pkt_cycle_cnt <= 4'd0;
                            if(rv_configure_cnt == 8'b1)begin
                                if(iv_nmac_data[8] == 1'b1)begin
                                    npm_state        <= IDLE_S;
                                end
                                else begin
                                    npm_state        <= DISC_S;
                                end
                            end
                            else begin
                                rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                rv_configure_addr<= rv_configure_addr + 19'd1;
                                npm_state        <= DATA_S;
                            end
                        end
                    end
                    
                    else if(rv_configure_addr[26:20] == 7'd7)begin//configure qgc4 RAM
                        ov_waddr  <= rv_configure_addr[15:0];
                        if(rv_pkt_cycle_cnt < 4'd3)begin
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                            npm_state     <= DATA_S;
                            case(rv_pkt_cycle_cnt)
                                4'd2:ov_wdata  <= {iv_nmac_data[7:0],ov_wdata[7:0]};
                                default:begin
                                    ov_wdata  <= ov_wdata;
                                    ov_wr     <= 11'd0;
                                end
                            endcase  
                        end
                        else begin
                            ov_wdata  <= {ov_wdata[15:8],iv_nmac_data[7:0]};
                            ov_wr     <= 11'd128;
                            rv_pkt_cycle_cnt <= 4'd0;
                            if(rv_configure_cnt == 8'b1)begin
                                if(iv_nmac_data[8] == 1'b1)begin
                                    npm_state        <= IDLE_S;
                                end
                                else begin
                                    npm_state        <= DISC_S;
                                end
                            end
                            else begin
                                rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                rv_configure_addr<= rv_configure_addr + 19'd1;
                                npm_state        <= DATA_S;
                            end
                        end
                    end
                    
                    else if(rv_configure_addr[26:20] == 7'd8)begin//configure qgc5 RAM
                        ov_waddr  <= rv_configure_addr[15:0];
                        if(rv_pkt_cycle_cnt < 4'd3)begin
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                            npm_state     <= DATA_S;
                            case(rv_pkt_cycle_cnt)
                                4'd2:ov_wdata  <= {iv_nmac_data[7:0],ov_wdata[7:0]};
                                default:begin
                                    ov_wdata  <= ov_wdata;
                                    ov_wr     <= 11'd0;
                                end
                            endcase  
                        end
                        else begin
                            ov_wdata  <= {ov_wdata[15:8],iv_nmac_data[7:0]};
                            ov_wr     <= 11'd256;
                            rv_pkt_cycle_cnt <= 4'd0;
                            if(rv_configure_cnt == 8'b1)begin
                                if(iv_nmac_data[8] == 1'b1)begin
                                    npm_state        <= IDLE_S;
                                end
                                else begin
                                    npm_state        <= DISC_S;
                                end
                            end
                            else begin
                                rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                rv_configure_addr<= rv_configure_addr + 19'd1;
                                npm_state        <= DATA_S;
                            end
                        end
                    end
                    
                    else if(rv_configure_addr[26:20] == 7'd9)begin//configure qgc6 RAM
                        ov_waddr  <= rv_configure_addr[15:0];
                        if(rv_pkt_cycle_cnt < 4'd3)begin
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                            npm_state     <= DATA_S;
                            case(rv_pkt_cycle_cnt)
                                4'd2:ov_wdata  <= {iv_nmac_data[7:0],ov_wdata[7:0]};
                                default:begin
                                    ov_wdata  <= ov_wdata;
                                    ov_wr     <= 11'd0;
                                end
                            endcase  
                        end
                        else begin
                            ov_wdata  <= {ov_wdata[15:8],iv_nmac_data[7:0]};
                            ov_wr     <= 11'd512;
                            rv_pkt_cycle_cnt <= 4'd0;
                            if(rv_configure_cnt == 8'b1)begin
                                if(iv_nmac_data[8] == 1'b1)begin
                                    npm_state        <= IDLE_S;
                                end
                                else begin
                                    npm_state        <= DISC_S;
                                end
                            end
                            else begin
                                rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                rv_configure_addr<= rv_configure_addr + 19'd1;
                                npm_state        <= DATA_S;
                            end
                        end
                    end
                    
                    else if(rv_configure_addr[26:20] == 7'd10)begin//configure qgc7 RAM
                        ov_waddr  <= rv_configure_addr[15:0];
                        if(rv_pkt_cycle_cnt < 4'd3)begin
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                            npm_state     <= DATA_S;
                            case(rv_pkt_cycle_cnt)
                                4'd2:ov_wdata  <= {iv_nmac_data[7:0],ov_wdata[7:0]};
                                default:begin
                                    ov_wdata  <= ov_wdata;
                                    ov_wr     <= 11'd0;
                                end
                            endcase  
                        end
                        else begin
                            ov_wdata  <= {ov_wdata[15:8],iv_nmac_data[7:0]};
                            ov_wr     <= 11'd1024;
                            rv_pkt_cycle_cnt <= 4'd0;
                            if(rv_configure_cnt == 8'b1)begin
                                if(iv_nmac_data[8] == 1'b1)begin
                                    npm_state        <= IDLE_S;
                                end
                                else begin
                                    npm_state        <= DISC_S;
                                end
                            end
                            else begin
                                rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                rv_configure_addr<= rv_configure_addr + 19'd1;
                                npm_state        <= DATA_S;
                            end
                        end
                    end

                    else if(rv_configure_addr[26:20] == 7'd12)begin//configure flt RAM
                        ov_waddr  <= rv_configure_addr[15:0];
                        if(rv_pkt_cycle_cnt < 4'd3)begin
                            rv_pkt_cycle_cnt <= rv_pkt_cycle_cnt + 4'b1;
                            npm_state     <= DATA_S;
                            case(rv_pkt_cycle_cnt)
                                4'd2:ov_wdata  <= {iv_nmac_data[7:0],ov_wdata[7:0]};
                                default:begin
                                    ov_wdata  <= ov_wdata;
                                    ov_wr     <= 11'd0;
                                end
                            endcase  
                        end
                        else begin
                            ov_wdata  <= {ov_wdata[15:8],iv_nmac_data[7:0]};
                            ov_wr     <= 11'd4;
                            rv_pkt_cycle_cnt <= 4'd0;
                            if(rv_configure_cnt == 8'b1)begin
                                if(iv_nmac_data[8] == 1'b1)begin
                                    npm_state        <= IDLE_S;
                                end
                                else begin
                                    npm_state        <= DISC_S;
                                end
                            end
                            else begin
                                rv_configure_cnt <= rv_configure_cnt - 8'b1;
                                rv_configure_addr<= rv_configure_addr + 19'd1;
                                npm_state        <= DATA_S;
                            end
                        end
                    end
                    
                    else begin
                        rv_pkt_cycle_cnt <= 4'd0;
                        npm_state        <= IDLE_S;
                    end
                end
                else begin
                    npm_state     <= DATA_S;
                end
            end
            
            DISC_S:begin
                o_time_offset_wr <= 1'h0;

                rv_configure_addr<= 32'd0;
                rv_configure_cnt <= 8'h0;
                
                ov_wdata         <= 16'h0;
                ov_waddr         <= 16'h0;
                ov_wr            <= 11'h0;
                if(iv_nmac_data[8] == 1'b1)begin
                    npm_state     <= IDLE_S;
                end
                else begin
                    npm_state     <= DISC_S;
                end
            end
            
            default:npm_state        <= IDLE_S;
            
        endcase
    end
end    

endmodule
    