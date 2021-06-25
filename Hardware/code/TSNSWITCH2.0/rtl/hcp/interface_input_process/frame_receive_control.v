// Copyright (C) 1953-2020 NUDT
// Verilog module name - frame_receive_control
// Version: frame_receive_control_V1.0
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         -only forward tsmp frame when the network is in configuration;
//         -forward all frames after configuration of network is finished;
//         -put 8B metadata of PTP frame into end frame.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module frame_receive_control(
		i_clk,
		i_rst_n,
        
        iv_hcp_state,
        
		iv_pkt_data,
		o_pkt_data_rd,
		i_pkt_data_empty,
        
        iv_metadata,
		o_metadata_rd,
		i_metadata_fifo_empty,

		ov_data,
		o_data_wr,
        ov_chip_pkt_inport,

        o_frc_discard_pkt_pulse        
);

// I/O
// clk & rst
input					i_clk;
input					i_rst_n;
//hcp state
input       [1:0]       iv_hcp_state;
// fifo read
output	reg				o_pkt_data_rd;
input		[133:0]		iv_pkt_data;
input					i_pkt_data_empty;

input					i_metadata_fifo_empty;
output	reg				o_metadata_rd;
input		[63:0]		iv_metadata;
// data output
output	reg	[133:0]     ov_data;
output	reg		      	o_data_wr;
output	reg	[3:0]       ov_chip_pkt_inport;

output	reg             o_frc_discard_pkt_pulse;
//***************************************************
//          	frame receive control 
//***************************************************
// internal reg&wire
reg                     r_is_ptp;
reg         [63:0]      rv_metadata;
reg	        [1:0]      	frc_state;
localparam	IDLE_S 	 = 2'd0,
            TRANS_DATA_S  = 2'd1,
            DISC_DATA_S  = 2'd2;
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) begin
		o_pkt_data_rd <= 1'b0;
		ov_data <= 134'b0;
        o_data_wr <= 1'b0;
        ov_chip_pkt_inport <= 4'b0;
        r_is_ptp <= 1'b0;
        rv_metadata <= 64'b0;
		o_metadata_rd <= 1'b0;
        
        o_frc_discard_pkt_pulse <= 1'b0;
		frc_state <= IDLE_S;
	end
	else begin
		case(frc_state)
			IDLE_S:begin
                ov_data <= 134'b0;
                o_data_wr <= 1'b0;
				if(i_metadata_fifo_empty == 1'b0)begin
				    o_metadata_rd <= 1'b1;
                    rv_metadata <= iv_metadata;
					ov_chip_pkt_inport <= iv_metadata[15:12];
                    o_pkt_data_rd <= 1'b1;                
                    if((iv_hcp_state == 2'h0) || (iv_hcp_state == 2'h1))begin//only forward tsmp frame
                        r_is_ptp <= 1'b0;
                        if((iv_pkt_data[133:132] == 2'b01) && (iv_pkt_data[31:16] == 16'hff01))begin//tsmp frame
                            o_frc_discard_pkt_pulse <= 1'b0;
                            frc_state <= TRANS_DATA_S;		                        
                        end
                        else begin
                            o_frc_discard_pkt_pulse <= 1'b1;
                            frc_state <= DISC_DATA_S;		                    
                        end
                    end
                    else if(iv_hcp_state == 2'h2)begin//forward all frames
                        o_frc_discard_pkt_pulse <= 1'b0;
                        frc_state <= TRANS_DATA_S;	
                        if((iv_pkt_data[133:132] == 2'b01) && (iv_pkt_data[31:16] == 16'h98f7))begin//ptp frame
                            r_is_ptp <= 1'b1; 
                        end
                        else begin
                            r_is_ptp <= 1'b0;                    
                        end                
                    end                
				end
                else begin
                    r_is_ptp <= 1'b0;                              
                    ov_chip_pkt_inport <= 4'b0;
                    o_pkt_data_rd <= 1'b0;
					o_metadata_rd <= 1'b0;
                    o_frc_discard_pkt_pulse <= 1'b0;                    
                    frc_state <= IDLE_S;
                end
			end
			TRANS_DATA_S:begin
			    o_metadata_rd <= 1'b0;
				o_data_wr <= 1'b1;				
				if(iv_pkt_data[133:132] == 2'b10) begin
                    o_pkt_data_rd <= 1'b0;
                    frc_state <= IDLE_S;
                    if(r_is_ptp == 1'b1)begin
					    ov_data <= {iv_pkt_data[133:48],rv_metadata[63:16]}; 
                    end
                    else begin
                        ov_data <= iv_pkt_data;
                    end                    
				end
				else begin
                    ov_data <= iv_pkt_data;
                    o_pkt_data_rd <= 1'b1;
					frc_state <= TRANS_DATA_S;
				end
			end
            DISC_DATA_S:begin
			    o_metadata_rd <= 1'b0;
                ov_data <= 134'b0;
				o_data_wr <= 1'b0;	
                o_frc_discard_pkt_pulse <= 1'b0;
				if(iv_pkt_data[133:132] == 2'b10) begin
                    o_pkt_data_rd <= 1'b0;
                    frc_state <= IDLE_S;              
				end
				else begin
                    o_pkt_data_rd <= 1'b1;
					frc_state <= DISC_DATA_S;
				end
			end            
            default:begin
			    o_metadata_rd <= 1'b0;
                ov_data <= 134'b0;
				o_data_wr <= 1'b0;
                o_pkt_data_rd <= 1'b0;
                frc_state <= IDLE_S;                
            end
		endcase
	end
end	
endmodule