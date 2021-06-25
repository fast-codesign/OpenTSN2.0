// Copyright (C) 1953-2020 NUDT
// Verilog module name - frame_decapsulation_module
// Version: frame_decapsulation_module_V1.0
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - decapsulate TSMP frame to ARP ack frame、PTP frame、NMAC configuration frame;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module mux
(
        i_clk,
        i_rst_n,
       
        iv_data_fem,
	    i_data_wr_fem,
        
        iv_data_fdm,
	    i_data_wr_fdm,
	    
	    iv_fifo_usedw,
        o_fifo_overflow_pulse,

        ov_data,
        o_data_wr
);

// I/O
// clk & rst
input                   i_clk;
input                   i_rst_n;  
// pkt input from fem
input	   [133:0]	    iv_data_fem;
input	         	    i_data_wr_fem;
// pkt input from fdm
input	   [133:0]	    iv_data_fdm;
input	         	    i_data_wr_fdm;
// fifo state
input	   [8:0]	    iv_fifo_usedw;
output reg              o_fifo_overflow_pulse;
// pkt output to mux
output reg [133:0]	    ov_data;
output reg	            o_data_wr;
//***************************************************
//               mux 2to1
//***************************************************
// internal reg&wire for state machine
reg      [1:0]       mux_state;
localparam  IDLE_S = 2'd0,
            TRANS_FEM_S = 2'd1,
            TRANS_FDM_S = 2'd2,
            DISCARD_DATA_S = 2'd3;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data <= 134'b0;
		o_data_wr <= 1'b0;
        o_fifo_overflow_pulse <= 1'b0;
		mux_state <= IDLE_S;
    end
    else begin
		case(mux_state)
			IDLE_S:begin           
				if((i_data_wr_fem == 1'b1) && (iv_data_fem[133:132] == 2'b01))begin//first cycle
                    if(iv_fifo_usedw <= 9'd383)begin//the max length is 128 cycles;511 - 128
                        ov_data <= iv_data_fem;
		                o_data_wr <= i_data_wr_fem;
                        o_fifo_overflow_pulse <= 1'b0;
                        mux_state <= TRANS_FEM_S;
                    end
                    else begin
                        ov_data <= 134'b0;
		                o_data_wr <= 1'b0; 
                        o_fifo_overflow_pulse <= 1'b1;   
                        mux_state <= DISCARD_DATA_S;                       
                    end
                end
				else if((i_data_wr_fdm == 1'b1) && (iv_data_fdm[133:132] == 2'b01))begin//first cycle
                    if(iv_fifo_usedw <= 9'd383)begin//the max length is 128 cycles;511 - 128
                        ov_data <= iv_data_fdm;
		                o_data_wr <= i_data_wr_fdm;
                        o_fifo_overflow_pulse <= 1'b0;
                        mux_state <= TRANS_FDM_S;
                    end
                    else begin
                        ov_data <= 134'b0;
		                o_data_wr <= 1'b0; 
                        o_fifo_overflow_pulse <= 1'b1;   
                        mux_state <= DISCARD_DATA_S;                       
                    end
                end                
				else begin
                    ov_data <= 134'b0;
		            o_data_wr <= 1'b0;
                    o_fifo_overflow_pulse <= 1'b0;
					mux_state <= IDLE_S;					
				end
			end
            TRANS_FEM_S:begin 
                ov_data <= iv_data_fem;
                o_data_wr <= i_data_wr_fem;
                o_fifo_overflow_pulse <= 1'b0;
                if((i_data_wr_fem == 1'b1) && (iv_data_fem[133:132] == 2'b10))begin
                    mux_state <= IDLE_S;   
                end
                else begin
                    mux_state <= TRANS_FEM_S;  
                end                 
            end
            TRANS_FDM_S:begin 
                ov_data <= iv_data_fdm;
                o_data_wr <= i_data_wr_fdm;
                o_fifo_overflow_pulse <= 1'b0;
                if((i_data_wr_fdm == 1'b1) && (iv_data_fdm[133:132] == 2'b10))begin
                    mux_state <= IDLE_S;   
                end
                else begin
                    mux_state <= TRANS_FDM_S;  
                end                 
            end                  
			default:begin
                ov_data <= 134'b0;
                o_data_wr <= 1'b0;
                o_fifo_overflow_pulse <= 1'b0;
                mux_state <= IDLE_S;	
			end
		endcase
   end
end	
endmodule