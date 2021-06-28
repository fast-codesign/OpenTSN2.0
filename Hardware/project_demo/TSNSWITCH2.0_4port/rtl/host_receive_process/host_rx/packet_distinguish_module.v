// Copyright (C) 1953-2020 NUDT
// Verilog module name - packet_distinguish_module
// Version: PDM_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         Distinguish packet that isn't mapped and discard the packet.           
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module packet_distinguish_module
(
        i_clk,
        i_rst_n,

        iv_data,
        i_data_wr,  

        ov_data,
        o_data_wr,
        ov_ctrl_data,
        pdi_state         
);

// I/O
// clk & rst
input                   i_clk;
input                   i_rst_n; 
// data input
input       [8:0]       iv_data;
input                   i_data_wr;
// data output
output  reg [8:0]       ov_data;
output  reg             o_data_wr;
output  reg [18:0]      ov_ctrl_data;

output reg  [2:0]       pdi_state;
localparam  IDLE_S        = 3'd0,
            DISTINGUISH_PKT_S = 3'd1,
            TRANS_FIRST_S = 3'd2,
            TRANS_S       = 3'd3,
            DISC_S        = 3'd4;
//***************************************************
//              Distinguish packet 
//***************************************************
reg [2:0] rv_pkt_cnt;
reg [63:0]rv_data;
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n) begin
        ov_data <= 9'b0;
        o_data_wr <= 1'b0;
        ov_ctrl_data <= 19'b0;
        rv_pkt_cnt <= 3'b0;
        rv_data <= 64'b0;
        pdi_state <= IDLE_S;
    end
    else begin
        case(pdi_state)
            IDLE_S:begin//receive pkt data,and record data
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                ov_ctrl_data <= 19'b0;
                if(i_data_wr == 1'b1)begin
                    rv_data[63:56] <= iv_data[7:0];
                    rv_data[55:0] <= 56'b0;
                    rv_pkt_cnt <= rv_pkt_cnt + 1'b1;
                    pdi_state <= DISTINGUISH_PKT_S;
                end
                else begin  
                    rv_data <= 64'b0;                
                    rv_pkt_cnt <= 3'b0;                
                    pdi_state <= IDLE_S;
                end
            end
            DISTINGUISH_PKT_S:begin//record 8 cycle data,and disringuish base on the record data
                case(rv_pkt_cnt)
                    3'h1:rv_data <= {rv_data[63:56],iv_data[7:0],rv_data[47:0]};
                    3'h2:rv_data <= {rv_data[63:48],iv_data[7:0],rv_data[39:0]};
                    3'h3:rv_data <= {rv_data[63:40],iv_data[7:0],rv_data[31:0]};
                    3'h4:rv_data <= {rv_data[63:32],iv_data[7:0],rv_data[23:0]};
                    3'h5:rv_data <= {rv_data[63:24],iv_data[7:0],rv_data[15:0]};
                    3'h6:rv_data <= {rv_data[63:16],iv_data[7:0],rv_data[7:0]};
                    3'h7:rv_data <= {rv_data[63:8],iv_data[7:0]};
                    default:rv_data <= rv_data;
                endcase
                if(rv_pkt_cnt == 3'h7)begin
                    if(rv_data[44:8] == 37'b0 && iv_data[7:0] == 8'b0)begin
                    //the record data is 8 cycle metadata
                    //if metadata[44:0] is all 0,the pkt is mapped pkt
                        pdi_state <= TRANS_FIRST_S; 
                    end
                    else begin//is not mapped pkt,need discard the pkt
                        pdi_state <= DISC_S; 
                    end
                end
                else begin
                    rv_pkt_cnt <= rv_pkt_cnt + 1'b1;
                    pdi_state <= DISTINGUISH_PKT_S; 
                end
            end
            TRANS_FIRST_S:begin//discard metadata,and generate the new pkt first cycle
                ov_data <= {1'b1,iv_data[7:0]};
                o_data_wr <= 1'b1;   
                ov_ctrl_data <= rv_data[63:45];//pkt_type,injection addr,outport,lookup_en,frag_last
                pdi_state <= TRANS_S;                 
            end
            TRANS_S:begin//transmit pkt data until last cycle
                ov_data <= iv_data;
                o_data_wr <= 1'b1;            
                if(iv_data[8] == 1'b1) begin            
                    pdi_state <= IDLE_S;
                end
                else begin
                    pdi_state <= TRANS_S;
                end
            end
            DISC_S:begin
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                if(iv_data[8] == 1'b1)begin         
                    pdi_state <= IDLE_S;
                end
                else begin
                    pdi_state <= DISC_S;
                end                           
            end
            default:begin
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                pdi_state <= IDLE_S;                
            end
        endcase
    end
end 
endmodule