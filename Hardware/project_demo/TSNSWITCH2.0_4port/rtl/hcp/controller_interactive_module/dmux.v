// Copyright (C) 1953-2020 NUDT
// Verilog module name - dmux
// Version: dmux_V1.0
// Created:
//         by - peng jintao
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - dispatch ARP request frame、PTP frame、NMAC report frame to frame encapsulation module;
//         - dispatch TSMP frame to frame decapsulation module;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module dmux
(
    i_clk,
    i_rst_n,
       
    iv_data,
	i_data_wr,
    iv_inport,

	ov_data_lcm,
	o_data_wr_lcm,
    
	ov_data_fem,
	o_data_wr_fem,
    ov_inport_fem,
	   
	ov_data_fdm,
	o_data_wr_fdm    
);

// I/O
// clk & rst
input                   i_clk;
input                   i_rst_n;  
// pkt input
input	   [133:0]	    iv_data;
input	         	    i_data_wr;
input      [3:0]        iv_inport;
// pkt output to FDM
output reg [133:0]	    ov_data_lcm;
output reg	            o_data_wr_lcm;
// pkt output to FEM
output reg [133:0]	    ov_data_fem;
output reg	            o_data_wr_fem;
output reg [3:0]        ov_inport_fem;
// pkt output to FDM
output reg [133:0]	    ov_data_fdm;
output reg	            o_data_wr_fdm;
//***************************************************
//               pkt dispatch 
//***************************************************
// internal reg&wire for state machine
reg                  r_dispatch_error;
reg      [1:0]       dmux_state;
localparam  IDLE_S = 2'd0,
            TRANS_LCM_S = 2'd1,
            TRANS_FEM_S = 2'd2,
			TRANS_FDM_S = 2'd3;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data_lcm <= 134'b0;
        o_data_wr_lcm <= 1'b0;
    
        ov_data_fem <= 134'b0;
		o_data_wr_fem <= 1'b0;
        ov_inport_fem <= 4'b0;
		
        ov_data_fdm <= 134'b0;
		o_data_wr_fdm <= 1'b0;
        
        r_dispatch_error <= 1'b0;
  
		dmux_state <= IDLE_S;
    end
    else begin
		case(dmux_state)
			IDLE_S:begin
				if((i_data_wr == 1'b1) && (iv_data[133:132] == 2'b01))begin//first cycle
					if((iv_data[31:16] == 16'h0806)||(iv_data[31:16] == 16'h1662)||(iv_data[31:16] == 16'h98f7))begin //arp request frame,nmac report frame,PTP frame.
						ov_data_fem <= iv_data;
						o_data_wr_fem <= i_data_wr;
                        ov_inport_fem <= iv_inport;
                        
                        ov_data_lcm <= 134'b0;
                        o_data_wr_lcm <= 1'b0;
        
                        ov_data_fdm <= 134'b0;
                        o_data_wr_fdm <= 1'b0;
                        r_dispatch_error <= 1'b0;
						dmux_state <= TRANS_FEM_S;
					end
					else if(iv_data[31:16] == 16'hff01)begin//tsmp frame
                        if(iv_data[15:8] == 8'h03)begin//hcp configuration frame
                            ov_data_lcm <= iv_data;
                            o_data_wr_lcm <= i_data_wr;
                        
                            ov_data_fem <= 134'b0;
                            o_data_wr_fem <= 1'b0;
                            ov_inport_fem <= 4'b0;
                            
                            ov_data_fdm <= 134'b0;
                            o_data_wr_fdm <= 1'b0;
                            r_dispatch_error <= 1'b0;
                            dmux_state <= TRANS_LCM_S;
                        end
                        else begin
                            ov_data_lcm <= 134'b0;
                            o_data_wr_lcm <= 1'b0;
                        
                            ov_data_fem <= 134'b0;
                            o_data_wr_fem <= 1'b0;
                            ov_inport_fem <= 4'b0;
                            
                            ov_data_fdm <= iv_data;
                            o_data_wr_fdm <= i_data_wr;
                            r_dispatch_error <= 1'b0;
                            dmux_state <= TRANS_FDM_S;
                        end                        
					end
					else begin//not ip pkt that isn't mapped,except arp pkt,ptp pkt,nmac pkt.
					/*
                        ov_data_lcm <= 134'b0;
                        o_data_wr_lcm <= 1'b0;
                            
						ov_data_fem <= 134'b0;
						o_data_wr_fem <= 1'b0;
                        ov_inport_fem <= 4'b0;
                        
                        ov_data_fdm <= 134'b0;
                        o_data_wr_fdm <= 1'b0;
                        r_dispatch_error <= 1'b1;
						dmux_state <= IDLE_S;
                    */
						ov_data_fem <= iv_data;
						o_data_wr_fem <= i_data_wr;
                        ov_inport_fem <= iv_inport;
                        
                        ov_data_lcm <= 134'b0;
                        o_data_wr_lcm <= 1'b0;
        
                        ov_data_fdm <= 134'b0;
                        o_data_wr_fdm <= 1'b0;
                        r_dispatch_error <= 1'b0;
						dmux_state <= TRANS_FEM_S;						
					end	
				end
				else begin
                    ov_data_lcm <= 134'b0;
                    o_data_wr_lcm <= 1'b0;                
                
                    ov_data_fem <= 134'b0;
                    o_data_wr_fem <= 1'b0;
                    ov_inport_fem <= 4'b0;
                    
                    ov_data_fdm <= 134'b0;
                    o_data_wr_fdm <= 1'b0;
                    
                    r_dispatch_error <= 1'b0;
					
					dmux_state <= IDLE_S;					
				end
			end
            TRANS_LCM_S:begin
                ov_data_lcm <= iv_data;
                o_data_wr_lcm <= i_data_wr;
            
                ov_data_fem <= 134'b0;
                o_data_wr_fem <= 1'b0;
                ov_inport_fem <= 4'b0;
                
                ov_data_fdm <= 134'b0;
                o_data_wr_fdm <= 1'b0;
                
                r_dispatch_error <= 1'b0;
				if(i_data_wr == 1'b1 && iv_data[133:132] == 2'b10)begin
					dmux_state <= IDLE_S;	
				end
				else begin  
					dmux_state <= TRANS_LCM_S;	
				end
            end            
            TRANS_FEM_S:begin 
                ov_data_fem <= iv_data;
                o_data_wr_fem <= i_data_wr;
                ov_inport_fem <= iv_inport;
                
                ov_data_lcm <= 134'b0;
                o_data_wr_lcm <= 1'b0;   
                    
                ov_data_fdm <= 134'b0;
                o_data_wr_fdm <= 1'b0;
                
                r_dispatch_error <= 1'b0;
				if(i_data_wr == 1'b1 && iv_data[133:132] == 2'b10)begin
					dmux_state <= IDLE_S;	
				end
				else begin  
					dmux_state <= TRANS_FEM_S;	
				end
            end
            TRANS_FDM_S:begin
                ov_data_lcm <= 134'b0;
                o_data_wr_lcm <= 1'b0;   
                
                ov_data_fem <= 134'b0;
                o_data_wr_fem <= 1'b0;
                ov_inport_fem <= 4'b0;
                
                ov_data_fdm <= iv_data;
                o_data_wr_fdm <= i_data_wr;
                
                r_dispatch_error <= 1'b0;
				if(i_data_wr == 1'b1 && iv_data[133:132] == 2'b10)begin
					dmux_state <= IDLE_S;	
				end
				else begin  
					dmux_state <= TRANS_FDM_S;	
				end
            end			
			default:begin
                ov_data_lcm <= 134'b0;
                o_data_wr_lcm <= 1'b0;   
                
                ov_data_fem <= 134'b0;
                o_data_wr_fem <= 1'b0;
                ov_inport_fem <= 4'b0;
                
                ov_data_fdm <= 134'b0;
                o_data_wr_fdm <= 1'b0;
                
                r_dispatch_error <= 1'b0;
                
                dmux_state <= IDLE_S;	
			end
		endcase
   end
end	
endmodule