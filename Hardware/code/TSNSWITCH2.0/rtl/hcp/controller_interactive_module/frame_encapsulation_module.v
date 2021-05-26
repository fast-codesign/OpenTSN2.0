// Copyright (C) 1953-2020 NUDT
// Verilog module name - frame_encapsulation_module
// Version: frame_encapsulation_module_V1.0
// Created:
//         by - peng jintao
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - encapsulate ARP request frame、PTP frame、NMAC report frame to tsmp frame;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module frame_encapsulation_module
(
       i_clk,
       i_rst_n,
       
       iv_dmac,
       iv_smac,
       
       o_report_pulse,
       
       iv_data,
	   i_data_wr,
       iv_inport,
	   
	   ov_data,
	   o_data_wr   
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// dmac and smac of tsmp frame from controller
input      [47:0]      iv_dmac;
input      [47:0]      iv_smac;
// trigged by nmac report pkt of tsn chip
output reg             o_report_pulse;
// pkt input
input	   [133:0]	   iv_data;
input	         	   i_data_wr;
input	   [3:0]       iv_inport;
// pkt output to FEM
output reg [133:0]	   ov_data;
output reg	           o_data_wr;
//***************************************************
//               delay 2 cycle
//***************************************************
reg    [133:0] rv_data1;
reg            r_data1_wr;
reg    [133:0] rv_data2;
reg            r_data2_wr;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_data1 <= 134'b0;
		r_data1_wr <= 1'b0;
        
        rv_data2 <= 134'b0;
		r_data2_wr <= 1'b0;        
    end
    else begin
        rv_data1 <= iv_data;
		r_data1_wr <= i_data_wr;
        
        rv_data2 <= rv_data1;
		r_data2_wr <= r_data1_wr;    
    end
end
//***************************************************
//               encapsulating frame
//***************************************************
// internal reg&wire for state machine
reg      [15:0]      rv_tsn_chip_report_type;
reg                  r_remain_reporttype_flag;
reg      [2:0]       fem_state;
localparam  IDLE_S = 3'd0,
            TRANS_TSMP_HEAD_S = 3'd1,
			TRANS_NMAC_S = 3'd2,
            TRANS_REPORT_TYPE_S = 3'd3,
            TRANS_ARP_PTP_S = 3'd4;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data <= 134'b0;
		o_data_wr <= 1'b0;
        o_report_pulse <= 1'b0;
        rv_tsn_chip_report_type <= 16'b0;
        r_remain_reporttype_flag <= 1'b0;
		fem_state <= IDLE_S;
    end
    else begin
		case(fem_state)
			IDLE_S:begin
                o_report_pulse <= 1'b0;
                r_remain_reporttype_flag <= 1'b0;
				if((i_data_wr == 1'b1) && (iv_data[133:132] == 2'b01))begin//first cycle;output metadata.
                    ov_data[133:128] <= 6'b010000;
                    ov_data[127:125] <= 3'b110;//pkt type:BE frame
                    ov_data[124:111] <= 14'b0;//5bit injection address and 9bit outport.
                    ov_data[110] <= 1'b1;//lookup_en
                    ov_data[109] <= 1'b1;//frag_last
                    ov_data[108:0] <= 109'b0;
                    o_data_wr <= i_data_wr;

                    fem_state <= TRANS_TSMP_HEAD_S;
                end
				else begin
                    ov_data <= 134'b0;
                    o_data_wr <= 1'b0;

					fem_state <= IDLE_S;					
				end
			end
            TRANS_TSMP_HEAD_S:begin 
                o_data_wr <= 1'b1;
                ov_data[133:128] <= 6'b110000;
                ov_data[79:32] <= iv_dmac;
                ov_data[31:16] <= 16'hff01;//len/type
                ov_data[7:0] <= {4'h0,iv_inport}; 
                if(rv_data1[31:16] == 16'h0806)begin//arp frame
                    ov_data[127:80] <= {iv_smac[47:24],8'h00,iv_smac[15:0]};//exchange the dmac and smac of  tsmp frame from controller;iv_smac[23:16] is revised to store subtype to recognize conveniently.
                    ov_data[15:8] <= 8'h00; 
                    o_report_pulse <= 1'b0;
                    fem_state <= TRANS_ARP_PTP_S;
                end
                else if(rv_data1[31:16] == 16'h1662)begin//NMAC report frame
                    ov_data[127:80] <= {iv_smac[47:24],8'h01,iv_smac[15:0]};//exchange the dmac and smac of  tsmp frame from controller;iv_smac[23:16] is revised to store subtype to recognize conveniently.                
                    ov_data[15:8] <= 8'h01; 
                    rv_tsn_chip_report_type <= rv_data1[15:0];
                    o_report_pulse <= 1'b1;
                    fem_state <= TRANS_NMAC_S;
                end
                else if(rv_data1[31:16] == 16'h98f7)begin//PTP frame
                    ov_data[127:80] <= {iv_smac[47:24],8'h05,iv_smac[15:0]};//exchange the dmac and smac of  tsmp frame from controller;iv_smac[23:16] is revised to store subtype to recognize conveniently.                                
                    ov_data[15:8] <= 8'h05; 
                    o_report_pulse <= 1'b0;
                    fem_state <= TRANS_ARP_PTP_S;
                end
                else begin //not ip pkt that isn't mapped,except arp pkt,ptp pkt,nmac pkt.
                    /*
					o_report_pulse <= 1'b0;
                    ov_data[15:8] <= 8'hff; 
                    fem_state <= TRANS_ARP_PTP_S;
					*/
                    ov_data[127:80] <= {iv_smac[47:24],8'h0f,iv_smac[15:0]};//exchange the dmac and smac of  tsmp frame from controller;iv_smac[23:16] is revised to store subtype to recognize conveniently.
                    ov_data[15:8] <= 8'h0f; 
                    o_report_pulse <= 1'b0;
                    fem_state <= TRANS_ARP_PTP_S;						
                end  
            end
            TRANS_ARP_PTP_S:begin 
				if(r_data2_wr == 1'b1 && rv_data2[133:132] == 2'b01)begin
                    ov_data <= {2'b11,rv_data2[131:0]};
                    o_data_wr <= r_data2_wr;
                    fem_state <= TRANS_ARP_PTP_S;	
				end
                else if(r_data2_wr == 1'b1 && rv_data2[133:132] == 2'b10)begin//last cycle
                    ov_data <= rv_data2;
                    o_data_wr <= r_data2_wr;
                    fem_state <= IDLE_S;
                end
				else if(r_data2_wr == 1'b1 && rv_data2[133:132] == 2'b11)begin//middle cycle  
					ov_data <= rv_data2;
                    o_data_wr <= r_data2_wr;
                    fem_state <= TRANS_ARP_PTP_S;	
				end
                else begin//pkt occurs error
					ov_data <= 134'b0;
                    o_data_wr <= 1'b0;
                    fem_state <= IDLE_S;	                
                end
            end
            TRANS_NMAC_S:begin//discard the first cycle of nmac report frame to avoid that length of frame encapsulated is more than 128B.
                o_report_pulse <= 1'b0;
				if(r_data1_wr == 1'b1 && rv_data1[133:132] == 2'b11)begin
                    ov_data <= rv_data1;
                    o_data_wr <= r_data1_wr;
                    fem_state <= TRANS_NMAC_S;	
				end
                else if(r_data1_wr == 1'b1 && rv_data1[133:132] == 2'b10)begin//last cycle
                    case(rv_data1[131:128])
                        4'h0:begin
                            ov_data <= {2'b11,4'h0,rv_data1[127:0]};
                            o_data_wr <= r_data1_wr;
                            r_remain_reporttype_flag <= 1'b1;//remain 2B to transmit.
                            fem_state <= TRANS_REPORT_TYPE_S;
                        end
                        4'h1:begin
                            ov_data <= {2'b11,4'h0,rv_data1[127:8],rv_tsn_chip_report_type[15:8]};
                            o_data_wr <= r_data1_wr;
                            r_remain_reporttype_flag <= 1'b0;//remain 1B to transmit.
                            fem_state <= TRANS_REPORT_TYPE_S;
                        end
                        4'h2:begin
                            ov_data <= {2'b10,4'b0000,rv_data1[127:16],rv_tsn_chip_report_type};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end  
                        4'h3:begin
                            ov_data <= {2'b10,4'h1,rv_data1[127:24],rv_tsn_chip_report_type,8'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end  
                        4'h4:begin
                            ov_data <= {2'b10,4'h2,rv_data1[127:32],rv_tsn_chip_report_type,16'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end  
                        4'h5:begin
                            ov_data <= {2'b10,4'h3,rv_data1[127:40],rv_tsn_chip_report_type,24'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end  
                        4'h6:begin
                            ov_data <= {2'b10,4'h4,rv_data1[127:48],rv_tsn_chip_report_type,32'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end  
                        4'h7:begin
                            ov_data <= {2'b10,4'h5,rv_data1[127:56],rv_tsn_chip_report_type,40'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end  
                        4'h8:begin
                            ov_data <= {2'b10,4'h6,rv_data1[127:64],rv_tsn_chip_report_type,48'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end  
                        4'h9:begin
                            ov_data <= {2'b10,4'h7,rv_data1[127:72],rv_tsn_chip_report_type,56'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end
                        4'ha:begin
                            ov_data <= {2'b10,4'h8,rv_data1[127:80],rv_tsn_chip_report_type,64'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end
                        4'hb:begin
                            ov_data <= {2'b10,4'h9,rv_data1[127:88],rv_tsn_chip_report_type,72'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end    
                        4'hc:begin
                            ov_data <= {2'b10,4'ha,rv_data1[127:96],rv_tsn_chip_report_type,80'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end    
                        4'hd:begin
                            ov_data <= {2'b10,4'hb,rv_data1[127:104],rv_tsn_chip_report_type,88'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end
                        4'he:begin
                            ov_data <= {2'b10,4'hc,rv_data1[127:112],rv_tsn_chip_report_type,96'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end 
                        4'hf:begin
                            ov_data <= {2'b10,4'hd,rv_data1[127:120],rv_tsn_chip_report_type,104'h0};
                            o_data_wr <= r_data1_wr;
                            fem_state <= IDLE_S;
                        end
                        default:begin
                            fem_state <= IDLE_S;
                        end
                    endcase                        
                end
                else begin//pkt occurs error
					ov_data <= 134'b0;
                    o_data_wr <= 1'b0;
                    fem_state <= IDLE_S;	                
                end
            end	
            TRANS_REPORT_TYPE_S:begin
                if(r_remain_reporttype_flag)begin//remain 2B to transmit.
                    ov_data <= {2'b10,4'he,rv_tsn_chip_report_type,112'h0};
                    o_data_wr <= 1'b1;
                end
                else begin//remain 1B to transmit.
                    ov_data <= {2'b10,4'hf,rv_tsn_chip_report_type[7:0],120'h0};
                    o_data_wr <= 1'b1;             
                end
                fem_state <= IDLE_S;   
            end            
			default:begin
                ov_data <= 134'b0;
                o_data_wr <= 1'b0;
                fem_state <= IDLE_S;	
			end
		endcase
   end
end	
endmodule