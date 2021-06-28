// Copyright (C) 1953-2020 NUDT
// Verilog module name - HOI 
// Version: HOI_V1.0
// Created:
//         by - jintao peng 
//         at - 08.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//		   output process of host interface.
//             - receive pkt,and transmit pkt to PHY;
//		       - record timestamp for PTP packet;
//		   	   - add preamble of frame and start-of-frame delimiter before transmitting pkt;
//             - control interframe gap that is 12 cycles.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module output_width_transform
(
        i_clk,
        i_rst_n,
	          
        iv_pkt_data,
        o_pkt_data_rd,
        i_pkt_data_empty,
	    
        ov_data,
	    o_data_wr   
);

// I/O
// clk & rst
input                  i_clk;	
input                  i_rst_n;
// receive pkt 
input      [133:0]     iv_pkt_data;
input                  i_pkt_data_empty;
output reg             o_pkt_data_rd;
// transmit pkt to phy	   
output reg [7:0]       ov_data;
output reg             o_data_wr;
//***************************************************
//                 transmit pkt 
//***************************************************
reg		   [10:0]		rv_send_pkt_cnt;
reg		   [3:0]		rv_trans_pkt_cnt;
reg		   [3:0]        rv_interframe_gap_cnt;
reg		   [3:0]		owt_state;
localparam	IDLE_S = 4'd0,
			TRANS_PREAMBLE_SFD_S = 4'd1,
			TRANS_MD_S = 4'd2,
            TRANS_PKT_S = 4'd3,
			TRANS_INTERFRAME_GAP_S = 4'd4;
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n == 1'b0)begin
        ov_data <= 8'b0;
		o_data_wr <= 1'b0;
        o_pkt_data_rd <= 1'b0;
		rv_trans_pkt_cnt <= 4'd0;
		rv_send_pkt_cnt <= 11'd0;		
		rv_interframe_gap_cnt <= 4'd0;

		owt_state <= IDLE_S;
	end
	else begin
		case(owt_state)
			IDLE_S:begin
				rv_trans_pkt_cnt <= 4'd0;
				rv_interframe_gap_cnt <= 4'd0;
                o_pkt_data_rd <= 1'b0;
                if(i_pkt_data_empty == 1'b0)begin
                    ov_data	<= 8'h55;    //first byte of frame preamble
                    o_data_wr <= 1'b1;
                    rv_send_pkt_cnt <= 11'd1;                   
                    owt_state <= TRANS_PREAMBLE_SFD_S;
                end
                else begin
                    ov_data	<= 8'h0;
                    o_data_wr <= 1'b0;
                    rv_send_pkt_cnt <= 11'd0;                       
                    owt_state <= IDLE_S;
                end
			end
			TRANS_PREAMBLE_SFD_S:begin
                rv_send_pkt_cnt <= rv_send_pkt_cnt + 11'd1;
				if(rv_send_pkt_cnt <= 11'd6)begin
					ov_data	<= 8'h55;
					o_data_wr <= 1'b1;
					owt_state <= TRANS_PREAMBLE_SFD_S;
				end
				else begin
					ov_data	<= 8'hd5;
					o_data_wr <= 1'b1;
					owt_state <= TRANS_MD_S;
				end
			end
			TRANS_MD_S:begin //add 8B metadata
				if(rv_trans_pkt_cnt == 4'd7)begin
                    rv_trans_pkt_cnt <= 4'd0;
                    owt_state <= TRANS_PKT_S;
                end
                else begin
                    rv_trans_pkt_cnt <= rv_trans_pkt_cnt + 1'b1;
                    owt_state <= TRANS_MD_S;
                end
				if(rv_trans_pkt_cnt == 4'd6)begin
                    o_pkt_data_rd <= 1'b1;
                end
                else begin
                    o_pkt_data_rd <= 1'b0;
                end                
                case(rv_trans_pkt_cnt)
					4'h0:ov_data <= iv_pkt_data[127:120];
					4'h1:ov_data <= iv_pkt_data[119:112];
					4'h2:ov_data <= iv_pkt_data[111:104];
					4'h3:ov_data <= iv_pkt_data[103:96];
					4'h4:ov_data <= iv_pkt_data[95:88];		
					4'h5:ov_data <= iv_pkt_data[87:80];
					4'h6:ov_data <= iv_pkt_data[79:72];
					4'h7:ov_data <= iv_pkt_data[71:64];
                    default:ov_data <= 8'b0;              
				endcase
            end    
			TRANS_PKT_S:begin 
				rv_trans_pkt_cnt <= rv_trans_pkt_cnt + 4'd1;
                case(rv_trans_pkt_cnt)
					4'h0:ov_data <= iv_pkt_data[127:120];
					4'h1:ov_data <= iv_pkt_data[119:112];
					4'h2:ov_data <= iv_pkt_data[111:104];
					4'h3:ov_data <= iv_pkt_data[103:96];
					4'h4:ov_data <= iv_pkt_data[95:88];					
					4'h5:ov_data <= iv_pkt_data[87:80];
					4'h6:ov_data <= iv_pkt_data[79:72];
					4'h7:ov_data <= iv_pkt_data[71:64];
					4'h8:ov_data <= iv_pkt_data[63:56];
					4'h9:ov_data <= iv_pkt_data[55:48];
					4'ha:ov_data <= iv_pkt_data[47:40];
					4'hb:ov_data <= iv_pkt_data[39:32];
					4'hc:ov_data <= iv_pkt_data[31:24];					
					4'hd:ov_data <= iv_pkt_data[23:16];
					4'he:ov_data <= iv_pkt_data[15:8];	
                    4'hf:ov_data <= iv_pkt_data[7:0];						
				endcase
				if(iv_pkt_data[133:132]==2'b10)begin
					if(iv_pkt_data[131:128] + rv_trans_pkt_cnt == 4'hf)begin
						owt_state <= TRANS_INTERFRAME_GAP_S;
						o_pkt_data_rd <= 1'b1;
					end
					else begin
                        o_pkt_data_rd <= 1'b0;					
						owt_state <= TRANS_PKT_S;
					end
				end
				else begin
				    owt_state <= TRANS_PKT_S;                
					if(rv_trans_pkt_cnt == 4'he)begin
					    o_pkt_data_rd <= 1'b1;	
					end
					else begin
					    o_pkt_data_rd <= 1'b0;	
					end
				end
            end			
			TRANS_INTERFRAME_GAP_S:begin//transmit interframe gap(12 bytes) + 4B CRC
			    o_pkt_data_rd <= 1'b0;	
				o_data_wr	<= 1'b0;
				rv_interframe_gap_cnt <= rv_interframe_gap_cnt + 4'd1;
				if(rv_interframe_gap_cnt <= 4'd10)begin
					owt_state <= TRANS_INTERFRAME_GAP_S;
				end
				else begin
					owt_state <= IDLE_S;
				end
			end			
			default:begin
                ov_data <= 8'b0;
				o_data_wr <= 1'b0;			
				rv_trans_pkt_cnt <= 4'h0;
				rv_interframe_gap_cnt <= 4'd0;
				owt_state <= IDLE_S;
			end
		endcase
	end
end
endmodule