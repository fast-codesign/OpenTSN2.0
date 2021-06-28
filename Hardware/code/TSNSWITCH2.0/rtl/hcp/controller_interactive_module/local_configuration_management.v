// Copyright (C) 1953-2020 NUDT
// Verilog module name - hcp_configuration_management
// Version: hcp_configuration_management_V1.0
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - decapsulate TSMP frame to ARP ack frame、PTP frame、NMAC configuration frame;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module local_configuration_management
(
        i_clk,
        i_rst_n,
       
        iv_data,
	    i_data_wr,
        
        o_lcm_inpkt_pulse,

        ov_dmac,
        ov_smac,
        
        i_initial_finish,
        ov_report_type,
        ov_chip_port_type,
        ov_hcp_state,

        ov_frag_ram_wdata,
        ov_frag_ram_waddr,
        o_frag_ram_wr,

        ov_regroup_ram_wdata,
        ov_regroup_ram_waddr,
        o_regroup_ram_wr
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input	   [133:0]	   iv_data;
input	         	   i_data_wr;

output reg             o_lcm_inpkt_pulse;
// dmac and smac of tsmp frame from controller
output reg [47:0]      ov_dmac;
output reg [47:0]      ov_smac;
//report infomation of hcp
output reg [15:0]      ov_report_type;
// type of 8 ports of tsn chip
output reg [7:0]       ov_chip_port_type;
//initial 512 bufid
input                  i_initial_finish;
// type of 8 ports of tsn chip
output reg [1:0]       ov_hcp_state;
// 5tuple mapping table
output reg [151:0]     ov_frag_ram_wdata;
output reg [4:0]       ov_frag_ram_waddr;
output reg             o_frag_ram_wr;
// regroup mapping table
output reg [70:0]      ov_regroup_ram_wdata;
output reg [7:0]       ov_regroup_ram_waddr;
output reg             o_regroup_ram_wr;
//***************************************************
//               decapsulating frame
//***************************************************
// internal reg&wire for state machine
reg      [1:0]       rv_hcp_state;
reg      [1:0]       lcm_state;
localparam  IDLE_S = 2'd0,
            CONFIG_HCP_S = 2'd1,
            WRITE_MAP_TABLE_S = 2'd2;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_dmac <= 48'b0;
        ov_smac <= 48'b0;
        ov_report_type <= 16'b0;//the default is reporting registers
        ov_chip_port_type <= 8'hff;
        rv_hcp_state <= 2'b0;
        
        ov_frag_ram_wdata <= 152'b0;
        ov_frag_ram_waddr <= 5'b0;
        o_frag_ram_wr <= 1'b0;
        ov_regroup_ram_wdata <= 71'b0;
        ov_regroup_ram_waddr <= 8'b0;
        o_regroup_ram_wr <= 1'b0;
        
        o_lcm_inpkt_pulse <= 1'b0;
		lcm_state <= IDLE_S;
    end
    else begin
		case(lcm_state)
			IDLE_S:begin
                ov_frag_ram_wdata <= 152'b0;
                ov_frag_ram_waddr <= 5'b0;
                o_frag_ram_wr <= 1'b0;
                ov_regroup_ram_wdata <= 71'b0;
                ov_regroup_ram_waddr <= 8'b0;
                o_regroup_ram_wr <= 1'b0;                
				if((i_data_wr == 1'b1) && (iv_data[133:132] == 2'b01))begin//first cycle;discard the cycle and output metadata
                    o_lcm_inpkt_pulse <= 1'b1;
                    ov_dmac <= iv_data[127:80];
                    ov_smac <= iv_data[79:32];                                         
                    lcm_state <= CONFIG_HCP_S;                                      
                end
				else begin
                    o_lcm_inpkt_pulse <= 1'b0;
                    ov_dmac <= ov_dmac;
                    ov_smac <= ov_smac;        
					lcm_state <= IDLE_S;					
				end
			end
            CONFIG_HCP_S:begin
                o_lcm_inpkt_pulse <= 1'b0;
                o_frag_ram_wr <= 1'b0; 
                if(i_data_wr == 1'b1)begin
                    if((iv_data[127] == 1'b1) && (iv_data[126:120] == 7'h00) && (iv_data[119:96] == 24'h0))begin//config chip_port_type of PDM
                        ov_chip_port_type <= iv_data[71:64];
                        
                        ov_regroup_ram_wdata <= 71'b0;
                        ov_regroup_ram_waddr <= 8'b0;
                        o_regroup_ram_wr <= 1'b0;                          
                        if((iv_data[63] == 1'b1) && (iv_data[62:56] == 7'h01) && (iv_data[55:32] == 24'h0))begin//config state of hcp
                            rv_hcp_state <= iv_data[1:0];                         
                        end
                        else if((iv_data[63] == 1'b1) && (iv_data[62:56] == 7'h01) && (iv_data[55:32] == 24'h1))begin//config report type
                            ov_report_type <= iv_data[15:0];                         
                        end
                        else begin
                            ov_report_type <= ov_report_type;
                            rv_hcp_state <= rv_hcp_state;  
                        end
                    end
                    else if((iv_data[127] == 1'b1) && (iv_data[126:120] == 7'h01) && (iv_data[119:96] == 24'h0))begin//config state of hcp
                        rv_hcp_state <= iv_data[65:64];
                        
                        ov_regroup_ram_wdata <= 71'b0;
                        ov_regroup_ram_waddr <= 8'b0;
                        o_regroup_ram_wr <= 1'b0;                            
                        if((iv_data[63] == 1'b1) && (iv_data[62:56] == 7'h00) && (iv_data[55:32] == 24'h0))begin//config chip_port_type of PDM
                            ov_chip_port_type <= iv_data[7:0];
                        end
                        else if((iv_data[63] == 1'b1) && (iv_data[62:56] == 7'h01) && (iv_data[55:32] == 24'h1))begin//config report type
                            ov_report_type <= iv_data[15:0];                         
                        end                        
                        else begin
                            ov_report_type <= ov_report_type;
                            ov_chip_port_type <= ov_chip_port_type;  
                        end                        
                    end
                    else if((iv_data[127] == 1'b1) && (iv_data[126:120] == 7'h01) && (iv_data[119:96] == 24'h1))begin//config report type
                        ov_report_type <= iv_data[79:64];     
                        
                        ov_regroup_ram_wdata <= 71'b0;
                        ov_regroup_ram_waddr <= 8'b0;
                        o_regroup_ram_wr <= 1'b0;                            
                        if((iv_data[63] == 1'b1) && (iv_data[62:56] == 7'h00) && (iv_data[55:32] == 24'h0))begin//config chip_port_type of PDM
                            ov_chip_port_type <= iv_data[7:0];
                        end
                        else if((iv_data[63] == 1'b1) && (iv_data[62:56] == 7'h01) && (iv_data[55:32] == 24'h0))begin//config state of hcp
                            rv_hcp_state <= iv_data[1:0];                       
                        end                        
                        else begin
                            rv_hcp_state <= rv_hcp_state;
                            ov_chip_port_type <= ov_chip_port_type;  
                        end                        
                    end                    
                    else if((iv_data[127] == 1'b1) && (iv_data[126:120] == 7'h02) && (iv_data[119:96] <= 24'h1f))begin//config frag mapping table
                        ov_frag_ram_wdata <= {iv_data[23:0],128'b0};    
                        ov_frag_ram_waddr <= iv_data[100:96];
                                                
                        ov_regroup_ram_wdata <= 71'b0;
                        ov_regroup_ram_waddr <= 8'b0;
                        o_regroup_ram_wr <= 1'b0;                                                                     
                    end
                    else if((iv_data[127] == 1'b1) && (iv_data[126:120] == 7'h03) && (iv_data[119:96] <= 24'h3fff))begin//config regroup mapping table
                        ov_regroup_ram_wdata <= {iv_data[77:64],iv_data[63:16],iv_data[8:0]};//iv_data[15:9] is reserved
                        ov_regroup_ram_waddr <= iv_data[103:96];
                        o_regroup_ram_wr <= 1'b1;                                              
                    end
                    else begin
                        ov_regroup_ram_wdata <= 71'b0;
                        ov_regroup_ram_waddr <= 8'b0;
                        o_regroup_ram_wr <= 1'b0;  
                    end                    
                end
                else begin
                    ov_frag_ram_wdata <= 152'b0;
                    ov_frag_ram_waddr <= 5'b0;
                    ov_regroup_ram_wdata <= 71'b0;
                    ov_regroup_ram_waddr <= 8'b0;
                    o_regroup_ram_wr <= 1'b0;                   
                end
                
                if((i_data_wr == 1'b1) && (iv_data[133:132] == 2'b10))begin
                    lcm_state <= IDLE_S; 
                end
                else if((i_data_wr == 1'b1) && (iv_data[133:132] == 2'b11))begin
                    if((iv_data[127] == 1'b1) && (iv_data[126:120] == 7'h02) && (iv_data[119:96] <= 24'h1f))begin//config frag mapping table
                        lcm_state <= WRITE_MAP_TABLE_S; 
                    end
                    else begin
                        lcm_state <= CONFIG_HCP_S; 
                    end
                end
                else begin
                    lcm_state <= IDLE_S; 
                end
            end
            WRITE_MAP_TABLE_S:begin
                ov_frag_ram_wdata <= {ov_frag_ram_wdata[151:128],iv_data[127:0]};    
                ov_frag_ram_waddr <= ov_frag_ram_waddr;
                o_frag_ram_wr <= 1'b1;
                lcm_state <= CONFIG_HCP_S;                    
            end            
			default:begin            
                lcm_state <= IDLE_S;	
			end
		endcase
   end
end	
//***************************************************
//           control of hcp_state
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_hcp_state <= 2'b0;
    end
    else begin
        if(i_initial_finish)begin
            if(rv_hcp_state >= 2'd2)begin
                ov_hcp_state <= rv_hcp_state;
            end
            else begin
                ov_hcp_state <= {1'b0,i_initial_finish};
            end
        end
        else begin
            ov_hcp_state <= 2'b0;
        end
    end
end
endmodule