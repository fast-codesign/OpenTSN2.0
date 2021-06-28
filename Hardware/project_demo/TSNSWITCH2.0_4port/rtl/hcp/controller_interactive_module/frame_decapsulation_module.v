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

module frame_decapsulation_module
(
        i_clk,
        i_rst_n,
       
        iv_data,
	    i_data_wr,
	    
	    ov_data,
	    o_data_wr
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input	   [133:0]	   iv_data;
input	         	   i_data_wr;
// pkt output to FEM
output reg [133:0]	   ov_data;
output reg	           o_data_wr;
//***************************************************
//               decapsulating frame
//***************************************************
// internal reg&wire for state machine
reg      [1:0]       fdm_state;
localparam  IDLE_S = 2'd0,
            TRANS_DATA_S = 2'd1;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data <= 134'b0;
		o_data_wr <= 1'b0;

		fdm_state <= IDLE_S;
    end
    else begin
		case(fdm_state)
			IDLE_S:begin             
				if((i_data_wr == 1'b1) && (iv_data[133:132] == 2'b01))begin//first cycle;discard the cycle and output metadata                    
                    ov_data[133:128] <= 6'b010000;
                    ov_data[124:120] <= 5'b0;//5bit injection address 
                    ov_data[109] <= 1'b1;//frag_last
                    ov_data[108:0] <= 109'b0;
                    if(iv_data[15:8] == 8'h00)begin//ARP ack frame
                        ov_data[127:125] <= 3'b110;//pkt type:BE frame    
                        ov_data[119:111] <= (9'h001 << iv_data[7:0]);//9bit outport,bitmap.
                        ov_data[110] <= 1'b0;//lookup_en  
                        o_data_wr <= i_data_wr;                        
                        fdm_state <= TRANS_DATA_S;
                    end
                    else if(iv_data[15:8] == 8'h02)begin//NMAC configuration frame
                        ov_data[127:125] <= 3'b101;//pkt type:NMAC frame    
                        ov_data[119:111] <= 9'b0;//9bit outport,bitmap.
                        ov_data[110] <= 1'b0;//lookup_en 
                        o_data_wr <= i_data_wr;                            
                        fdm_state <= TRANS_DATA_S;                    
                    end
                    else if(iv_data[15:8] == 8'h05)begin//PTP frame
                        ov_data[127:125] <= 3'b100;//pkt type:PTP frame    
                        ov_data[119:111] <= 9'b0;//9bit outport,bitmap.
                        ov_data[110] <= 1'b1;//lookup_en  
                        o_data_wr <= i_data_wr;                            
                        fdm_state <= TRANS_DATA_S;                      
                    end 
                    else begin//unexpected frame
                        ov_data[127:125] <= 3'b110;//pkt type:BE frame    
                        ov_data[119:111] <= 9'b0;//9bit outport,bitmap.
                        ov_data[110] <= 1'b1;//lookup_en 
                        o_data_wr <= 1'b0;                            
                        fdm_state <= IDLE_S;                      
                    end                    
                end
				else begin
                    ov_data <= 134'b0;
		            o_data_wr <= 1'b0;
					fdm_state <= IDLE_S;					
				end
			end
            TRANS_DATA_S:begin 
                ov_data <= iv_data;
                o_data_wr <= i_data_wr;
                if((i_data_wr == 1'b1) && (iv_data[133:132] == 2'b10))begin
                    fdm_state <= IDLE_S;   
                end
                else begin
                    fdm_state <= TRANS_DATA_S;  
                end                 
            end           
			default:begin
                ov_data <= 134'b0;
                o_data_wr <= 1'b0;
                fdm_state <= IDLE_S;	
			end
		endcase
   end
end	
endmodule