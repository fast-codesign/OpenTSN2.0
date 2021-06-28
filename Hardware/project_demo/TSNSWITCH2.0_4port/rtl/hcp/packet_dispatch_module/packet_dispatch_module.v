// Copyright (C) 1953-2020 NUDT
// Verilog module name - packet_dispatch_module 
// Version: GAH_V1.0
// Created:
//         by - Shangming Wu  guangming836@163.com
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         1.The code of pdm.
//         2.packet dispatch module.
//         3.More information in Doc.
///////////////////////////////////////////////////////////////////////////


module packet_dispatch_module #(
    parameter PLATFORM="hcp")
(
    input clk,
    input rst_n,

    //fpga 0s-pdm
    input [133:0] iv_pkt_data,
    input i_pkt_data_wr,
    input [3:0] iv_pkt_inport,
    
    //pdm-fnp
    output reg [133:0] ov_pkt_data_fnp,
    output reg o_pkt_data_wr_fnp,
    output reg [3:0] ov_pkt_inport_fnp,
    output reg o_first_frag_fnp,
    
    //pdm-cim
    output reg [133:0] ov_pkt_data_cim,
    output reg o_pkt_data_wr_cim,
    input [7:0] iv_chip_port_type_cim2pdm,
    output reg o_first_frag_cim,

    //pdm-lnp
    output reg [133:0] ov_pkt_data_lnp,
    output reg o_pkt_data_wr_lnp,
    output reg o_first_frag_lnp,
	
	//lost count
	output reg o_pkt_lost_pulse
);

    reg [5:0] pdm_state;

    reg [8:0] discard;
    reg [1:0] pkt_orientation[8:0];  //1:to FNP  /2:to CIM  /3:to LNP
    

    localparam INIT_S =6'd0,
               IDENTIFY_PORTTYPR_S =6'd1,
               PKT2FNP_S =6'd2,
               PKT2CIM_S =6'd3,
               PKT2LNP_S =6'd4,
			   PKT_LOST_S =6'd5;

    

    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
           ov_pkt_data_fnp <=134'b0;
           o_pkt_data_wr_fnp <=1'b0;
           ov_pkt_inport_fnp <=4'b0;

           ov_pkt_data_cim <=134'b0;
           o_pkt_data_wr_cim <=1'b0;

           ov_pkt_data_lnp <=134'b0;
           o_pkt_data_wr_lnp <=1'b0;

           discard <=8'b0;
           pkt_orientation[0] <=2'b0;
           pkt_orientation[1] <=2'b0;
           pkt_orientation[2] <=2'b0;
           pkt_orientation[3] <=2'b0;
           pkt_orientation[4] <=2'b0;
           pkt_orientation[5] <=2'b0;
           pkt_orientation[6] <=2'b0;
           pkt_orientation[7] <=2'b0;
		   pkt_orientation[8] <=2'b0;
		   
		   o_pkt_lost_pulse <=1'b0;

           o_first_frag_fnp <=1'b0;
           o_first_frag_cim <=1'b0;
           o_first_frag_lnp <=1'b0;

           pdm_state <=INIT_S;
        end
        else begin 
            case(pdm_state)
                INIT_S:begin
                        //**************this is nmac / ptp / arp / smp****************
                        if( (iv_pkt_data[133:132] ==2'b01) && (i_pkt_data_wr ==1'b1) && ( (iv_pkt_data[31:16]==16'h1662) || (iv_pkt_data[31:16]==16'h98f7) || (iv_pkt_data[31:16]==16'h0806) || (iv_pkt_data[31:16]==16'hff01) ) )begin
                            ov_pkt_data_cim <=iv_pkt_data;
                            o_pkt_data_wr_cim <=1'b1;
                            ov_pkt_inport_fnp <=iv_pkt_inport;
                            case(iv_pkt_inport)
                                4'd0:begin
                                    pkt_orientation[0] <=2'd2;
                                    discard[0] <=1'b0;
                                end
                                4'd1:begin
                                    pkt_orientation[1] <=2'd2;
                                    discard[1] <=1'b0;
                                end
                                4'd2:begin
                                    pkt_orientation[2] <=2'd2;
                                    discard[2] <=1'b0;
                                end
                                4'd3:begin
                                    pkt_orientation[3] <=2'd2;
                                    discard[3] <=1'b0;
                                end
                                4'd4:begin
                                    pkt_orientation[4] <=2'd2;
                                    discard[4] <=1'b0;
                                end
                                4'd5:begin
                                    pkt_orientation[5] <=2'd2;
                                    discard[5] <=1'b0;
                                end
                                4'd6:begin
                                    pkt_orientation[6] <=2'd2;
                                    discard[6] <=1'b0;
                                end
                                4'd7:begin
                                    pkt_orientation[7] <=2'd2;
                                    discard[7] <=1'b0;
                                end
								default:ov_pkt_inport_fnp <=iv_pkt_inport;
                            endcase

                            pdm_state <=PKT2CIM_S;
                        end
                        //**************not nmac / ptp / arp / smp****************
                        else if( (iv_pkt_data[133:132] ==2'b01) && (i_pkt_data_wr ==1'b1) && (iv_pkt_data[127:0] !=128'b0) )begin //first frag
                            ov_pkt_inport_fnp <=iv_pkt_inport;
                            case(iv_pkt_inport)
                                4'd0:begin
                                    if(iv_chip_port_type_cim2pdm[0]==1'b1)begin
                                        if(iv_pkt_data[31:16] ==16'h0800)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b1;

                                            discard[0] <=1'b0;
                                            pkt_orientation[0] <=2'd1;
                                            pdm_state <= PKT2FNP_S;
                                        end 
                                        else begin
											ov_pkt_data_cim <=iv_pkt_data;
											o_pkt_data_wr_cim <=1'b1;
											//ov_pkt_inport_fnp <=iv_pkt_inport;
											
											pkt_orientation[0] <=2'd2;
                                            discard[0] <=1'b0;
											pdm_state <=PKT2CIM_S;
											/*
											o_pkt_lost_pulse <=1'b1;
                                            discard[0] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
											*/
                                        end   
                                    end
                                    else begin  //iv_chip_port_type_cim2pdm[0]==1'b0
										if((iv_pkt_data[31:16] ==16'h1800) || (iv_pkt_data[79:0] ==80'b0))begin	
											ov_pkt_data_lnp <=iv_pkt_data;
											o_pkt_data_wr_lnp <=1'b1;
											o_first_frag_lnp <=1'b1;
                                             
											discard[0] <=1'b0;
											pkt_orientation[0] <=2'd3;
											pdm_state <=PKT2LNP_S;
										end
										else begin
											o_pkt_lost_pulse <=1'b1;
                                            discard[0] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										end
                                    end
                                end

                                4'd1:begin
                                    if(iv_chip_port_type_cim2pdm[1]==1'b1)begin
                                        if(iv_pkt_data[31:16] ==16'h0800)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b1;

                                            discard[1] <=1'b0;
                                            pkt_orientation[1] <=2'd1;
                                            pdm_state <= PKT2FNP_S;
                                        end 
                                        else begin
											ov_pkt_data_cim <=iv_pkt_data;
											o_pkt_data_wr_cim <=1'b1;
											//ov_pkt_inport_fnp <=iv_pkt_inport;
											
											pkt_orientation[1] <=2'd2;
                                            discard[1] <=1'b0;
											pdm_state <=PKT2CIM_S;
										
										/*
                                            o_pkt_lost_pulse <=1'b1;
											discard[1] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										*/
                                        end   
                                    end
                                    else begin  //iv_chip_port_type_cim2pdm[1]==1'b0
                                        if((iv_pkt_data[31:16] ==16'h1800) || (iv_pkt_data[79:0] ==80'b0))begin
											ov_pkt_data_lnp <=iv_pkt_data;
											o_pkt_data_wr_lnp <=1'b1;
											o_first_frag_lnp <=1'b1;
                                             
											discard[1] <=1'b0;
											pkt_orientation[1] <=2'd3;
											pdm_state <=PKT2LNP_S;
										end
										else begin
											o_pkt_lost_pulse <=1'b1;
                                            discard[1] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										end
                                    end
                                end

                                4'd2:begin
                                    if(iv_chip_port_type_cim2pdm[2]==1'b1)begin
                                        if(iv_pkt_data[31:16] ==16'h0800)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b1;

                                            discard[2] <=1'b0;
                                            pkt_orientation[2] <=2'd1;
                                            pdm_state <= PKT2FNP_S;
                                        end 
                                        else begin
											ov_pkt_data_cim <=iv_pkt_data;
											o_pkt_data_wr_cim <=1'b1;
											//ov_pkt_inport_fnp <=iv_pkt_inport;
											
											pkt_orientation[2] <=2'd2;
                                            discard[2] <=1'b0;
											pdm_state <=PKT2CIM_S;
										
										/*
											o_pkt_lost_pulse <=1'b1;
											discard[2] <=1'b1;
                                            pdm_state <=PKT_LOST_S;                              
                                        */
										end   
                                    end
                                    else begin  //iv_chip_port_type_cim2pdm[2]==1'b0
                                        if((iv_pkt_data[31:16] ==16'h1800) || (iv_pkt_data[79:0] ==80'b0))begin
											ov_pkt_data_lnp <=iv_pkt_data;
											o_pkt_data_wr_lnp <=1'b1;
											o_first_frag_lnp <=1'b1;
                                             
											discard[2] <=1'b0;
											pkt_orientation[2] <=2'd3;
											pdm_state <=PKT2LNP_S;
										end
										else begin
											o_pkt_lost_pulse <=1'b1;
                                            discard[2] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										end
                                    end
                                end

                                4'd3:begin
                                    if(iv_chip_port_type_cim2pdm[3]==1'b1)begin
                                        if(iv_pkt_data[31:16] ==16'h0800)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b1;

                                            discard[3] <=1'b0;
                                            pkt_orientation[3] <=2'd1;
                                            pdm_state <= PKT2FNP_S;
                                        end 
                                        else begin
											ov_pkt_data_cim <=iv_pkt_data;
											o_pkt_data_wr_cim <=1'b1;
											//ov_pkt_inport_fnp <=iv_pkt_inport;
											
											pkt_orientation[3] <=2'd2;
                                            discard[3] <=1'b0;
											pdm_state <=PKT2CIM_S;
										
										/*
											o_pkt_lost_pulse <=1'b1;
											discard[3] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										*/	
                                        end   
                                    end
                                    else begin  //iv_chip_port_type_cim2pdm[3]==1'b0
                                        if((iv_pkt_data[31:16] ==16'h1800) || (iv_pkt_data[79:0] ==80'b0))begin
											ov_pkt_data_lnp <=iv_pkt_data;
											o_pkt_data_wr_lnp <=1'b1;
											o_first_frag_lnp <=1'b1;
                                             
											discard[3] <=1'b0;
											pkt_orientation[3] <=2'd3;
											pdm_state <=PKT2LNP_S;
										end
										else begin
											o_pkt_lost_pulse <=1'b1;
                                            discard[3] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										end
									end
								end

                                4'd4:begin
                                    if(iv_chip_port_type_cim2pdm[4]==1'b1)begin
                                        if(iv_pkt_data[31:16] ==16'h0800)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b1;

                                            discard[4] <=1'b0;
                                            pkt_orientation[4] <=2'd1;
                                            pdm_state <= PKT2FNP_S;
                                        end 
                                        else begin
											ov_pkt_data_cim <=iv_pkt_data;
											o_pkt_data_wr_cim <=1'b1;
											//ov_pkt_inport_fnp <=iv_pkt_inport;
											
											pkt_orientation[4] <=2'd2;
                                            discard[4] <=1'b0;
											pdm_state <=PKT2CIM_S;
										
										/*
											o_pkt_lost_pulse <=1'b1;
											discard[4] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										*/
                                        end   
                                    end
                                    else begin  ////iv_chip_port_type_cim2pdm[4]==1'b0
                                        if((iv_pkt_data[31:16] ==16'h1800) || (iv_pkt_data[79:0] ==80'b0))begin
											ov_pkt_data_lnp <=iv_pkt_data;
											o_pkt_data_wr_lnp <=1'b1;
											o_first_frag_lnp <=1'b1;
                                             
											discard[4] <=1'b0;
											pkt_orientation[4] <=2'd3;
											pdm_state <=PKT2LNP_S;
										end
										else begin
											o_pkt_lost_pulse <=1'b1;
                                            discard[4] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										end
									end
                                end

                                4'd5:begin
                                    if(iv_chip_port_type_cim2pdm[5]==1'b1)begin
                                        if(iv_pkt_data[31:16] ==16'h0800)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b1;

                                            discard[5] <=1'b0;
                                            pkt_orientation[5] <=2'd1;
                                            pdm_state <= PKT2FNP_S;
                                        end 
                                        else begin
											ov_pkt_data_cim <=iv_pkt_data;
											o_pkt_data_wr_cim <=1'b1;
											//ov_pkt_inport_fnp <=iv_pkt_inport;
											
											pkt_orientation[5] <=2'd2;
                                            discard[5] <=1'b0;
											pdm_state <=PKT2CIM_S;
										
										/*
											o_pkt_lost_pulse <=1'b1;
											discard[5] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										*/
                                        end   
                                    end
                                    else begin  //////iv_chip_port_type_cim2pdm[5]==1'b0
                                        if((iv_pkt_data[31:16] ==16'h1800) || (iv_pkt_data[79:0] ==80'b0))begin
											ov_pkt_data_lnp <=iv_pkt_data;
											o_pkt_data_wr_lnp <=1'b1;
											o_first_frag_lnp <=1'b1;
                                             
											discard[5] <=1'b0;
											pkt_orientation[5] <=2'd3;
											pdm_state <=PKT2LNP_S;
										end
										else begin
											o_pkt_lost_pulse <=1'b1;
                                            discard[5] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										end
                                    end
                                end

                                4'd6:begin
                                    if(iv_chip_port_type_cim2pdm[6]==1'b1)begin
                                        if(iv_pkt_data[31:16] ==16'h0800)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b1;

                                            discard[6] <=1'b0;
                                            pkt_orientation[6] <=2'd1;
                                            pdm_state <= PKT2FNP_S;
                                        end 
                                        else begin
											ov_pkt_data_cim <=iv_pkt_data;
											o_pkt_data_wr_cim <=1'b1;
											//ov_pkt_inport_fnp <=iv_pkt_inport;
											
											pkt_orientation[6] <=2'd2;
                                            discard[6] <=1'b0;
											pdm_state <=PKT2CIM_S;
										
										/*
											o_pkt_lost_pulse <=1'b1;
											discard[6] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										*/
                                        end   
                                    end
                                    else begin   ////iv_chip_port_type_cim2pdm[6]==1'b0
                                        if((iv_pkt_data[31:16] ==16'h1800) || (iv_pkt_data[79:0] ==80'b0))begin
											ov_pkt_data_lnp <=iv_pkt_data;
											o_pkt_data_wr_lnp <=1'b1;
											o_first_frag_lnp <=1'b1;
                                             
											discard[6] <=1'b0;
											pkt_orientation[6] <=2'd3;
											pdm_state <=PKT2LNP_S;
										end
										else begin
											o_pkt_lost_pulse <=1'b1;
                                            discard[6] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										end
                                    end
                                end

                                4'd7:begin
                                    if(iv_chip_port_type_cim2pdm[7]==1'b1)begin
                                        if(iv_pkt_data[31:16] ==16'h0800)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b1;

                                            discard[7] <=1'b0;
                                            pkt_orientation[7] <=2'd1;
                                            pdm_state <= PKT2FNP_S;
                                        end 
                                        else begin
											ov_pkt_data_cim <=iv_pkt_data;
											o_pkt_data_wr_cim <=1'b1;
											//ov_pkt_inport_fnp <=iv_pkt_inport;
											
											pkt_orientation[7] <=2'd2;
                                            discard[7] <=1'b0;
											pdm_state <=PKT2CIM_S;
										
										/*
											o_pkt_lost_pulse <=1'b1;
											discard[7] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										*/
                                        end   
                                    end
                                    else begin   ////iv_chip_port_type_cim2pdm[7]==1'b0
                                        if((iv_pkt_data[31:16] ==16'h1800) || (iv_pkt_data[79:0] ==80'b0))begin
											ov_pkt_data_lnp <=iv_pkt_data;
											o_pkt_data_wr_lnp <=1'b1;
											o_first_frag_lnp <=1'b1;
                                             
											discard[7] <=1'b0;
											pkt_orientation[7] <=2'd3;
											pdm_state <=PKT2LNP_S;
										end
										else begin
											o_pkt_lost_pulse <=1'b1;
                                            discard[7] <=1'b1;
                                            pdm_state <=PKT_LOST_S;
										end
                                    end
                                end
								/*4'd8:begin
									ov_pkt_data_lnp <=iv_pkt_data;
									o_pkt_data_wr_lnp <=1'b1;
									o_first_frag_lnp <=1'b1;
                                             
									discard[8] <=1'b0;
									pkt_orientation[8] <=2'd3;
									pdm_state <=PKT2LNP_S;
								end*/
								default:ov_pkt_inport_fnp <=iv_pkt_inport;
								
                            endcase
                        end
                        
                        else if( (iv_pkt_data[133:132] ==2'b01) && (i_pkt_data_wr ==1'b1) && (iv_pkt_data[127:64] ==64'b0) )begin  //not first frag
                            ov_pkt_inport_fnp <=iv_pkt_inport;
                            case(iv_pkt_inport)
                                4'd0:begin
                                    if(discard[0] ==1'b0)begin
                                        if(pkt_orientation[0] ==2'd1)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b0;
                                            pdm_state <=PKT2FNP_S;
                                        end
                                        else if(pkt_orientation[0] ==2'd2)begin
                                            ov_pkt_data_cim <= iv_pkt_data;
                                            o_pkt_data_wr_cim <=1'b1;
                                            o_first_frag_cim <=1'b0;
                                            pdm_state <=PKT2CIM_S;
                                        end
                                        else if(pkt_orientation[0] ==2'd3)begin
                                            ov_pkt_data_lnp <= iv_pkt_data;
                                            o_pkt_data_wr_lnp <=1'b1;
                                            o_first_frag_lnp <=1'b0;
                                            pdm_state <=PKT2LNP_S;
                                        end
                                        else begin
                                            pdm_state <=INIT_S;
                                        end
                                    end
                                    else begin
										o_pkt_lost_pulse <=1'b1;
                                        pdm_state <=PKT_LOST_S;
                                    end
                                end

                                4'd1:begin
                                    if(discard[1] ==1'b0)begin
                                        if(pkt_orientation[1] ==2'd1)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b0;
                                            pdm_state <=PKT2FNP_S;
                                        end
                                        else if(pkt_orientation[1] ==2'd2)begin
                                            ov_pkt_data_cim <= iv_pkt_data;
                                            o_pkt_data_wr_cim <=1'b1;
                                            o_first_frag_cim <=1'b0;
                                            pdm_state <=PKT2CIM_S;
                                        end
                                        else if(pkt_orientation[1] ==2'd3)begin
                                            ov_pkt_data_lnp <= iv_pkt_data;
                                            o_pkt_data_wr_lnp <=1'b1;
                                            o_first_frag_lnp <=1'b0;
                                            pdm_state <=PKT2LNP_S;
                                        end
                                        else begin
                                            pdm_state <=INIT_S;
                                        end
                                    end
                                    else begin
                                        o_pkt_lost_pulse <=1'b1;
                                        pdm_state <=PKT_LOST_S;
                                    end
                                end

                                4'd2:begin
                                    if(discard[2] ==1'b0)begin
                                        if(pkt_orientation[2] ==2'd1)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b0;
                                            pdm_state <=PKT2FNP_S;
                                        end
                                        else if(pkt_orientation[2] ==2'd2)begin
                                            ov_pkt_data_cim <= iv_pkt_data;
                                            o_pkt_data_wr_cim <=1'b1;
                                            o_first_frag_cim <=1'b0;
                                            pdm_state <=PKT2CIM_S;
                                        end
                                        else if(pkt_orientation[2] ==2'd3)begin
                                            ov_pkt_data_lnp <= iv_pkt_data;
                                            o_pkt_data_wr_lnp <=1'b1;
                                            o_first_frag_lnp <=1'b0;
                                            pdm_state <=PKT2LNP_S;
                                        end
                                        else begin
                                            pdm_state <=INIT_S;
                                        end
                                    end
                                    else begin
                                        o_pkt_lost_pulse <=1'b1;
                                        pdm_state <=PKT_LOST_S;
                                    end
                                end

                                4'd3:begin
                                    if(discard[3] ==1'b0)begin
                                        if(pkt_orientation[3] ==2'd1)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b0;
                                            pdm_state <=PKT2FNP_S;
                                        end
                                        else if(pkt_orientation[3] ==2'd2)begin
                                            ov_pkt_data_cim <= iv_pkt_data;
                                            o_pkt_data_wr_cim <=1'b1;
                                            o_first_frag_cim <=1'b0;
                                            pdm_state <=PKT2CIM_S;
                                        end
                                        else if(pkt_orientation[3] ==2'd3)begin
                                            ov_pkt_data_lnp <= iv_pkt_data;
                                            o_pkt_data_wr_lnp <=1'b1;
                                            o_first_frag_lnp <=1'b0;
                                            pdm_state <=PKT2LNP_S;
                                        end
                                        else begin
                                            pdm_state <=INIT_S;
                                        end
                                    end
                                    else begin
                                        o_pkt_lost_pulse <=1'b1;
                                        pdm_state <=PKT_LOST_S;
                                    end
                                end

                                4'd4:begin
                                    if(discard[4] ==1'b0)begin
                                        if(pkt_orientation[4] ==2'd1)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b0;
                                            pdm_state <=PKT2FNP_S;
                                        end
                                        else if(pkt_orientation[4] ==2'd2)begin
                                            ov_pkt_data_cim <= iv_pkt_data;
                                            o_pkt_data_wr_cim <=1'b1;
                                            o_first_frag_cim <=1'b0;
                                            pdm_state <=PKT2CIM_S;
                                        end
                                        else if(pkt_orientation[4] ==2'd3)begin
                                            ov_pkt_data_lnp <= iv_pkt_data;
                                            o_pkt_data_wr_lnp <=1'b1;
                                            o_first_frag_lnp <=1'b0;
                                            pdm_state <=PKT2LNP_S;
                                        end
                                        else begin
                                            pdm_state <=INIT_S;
                                        end
                                    end
                                    else begin
                                        o_pkt_lost_pulse <=1'b1;
                                        pdm_state <=PKT_LOST_S;
                                    end
                                end

                                4'd5:begin
                                    if(discard[5] ==1'b0)begin
                                        if(pkt_orientation[5] ==2'd1)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b0;
                                            pdm_state <=PKT2FNP_S;
                                        end
                                        else if(pkt_orientation[5] ==2'd2)begin
                                            ov_pkt_data_cim <= iv_pkt_data;
                                            o_pkt_data_wr_cim <=1'b1;
                                            o_first_frag_cim <=1'b0;
                                            pdm_state <=PKT2CIM_S;
                                        end
                                        else if(pkt_orientation[5] ==2'd3)begin
                                            ov_pkt_data_lnp <= iv_pkt_data;
                                            o_pkt_data_wr_lnp <=1'b1;
                                            o_first_frag_lnp <=1'b0;
                                            pdm_state <=PKT2LNP_S;
                                        end
                                        else begin
                                            pdm_state <=INIT_S;
                                        end
                                    end
                                    else begin
                                        o_pkt_lost_pulse <=1'b1;
                                        pdm_state <=PKT_LOST_S;
                                    end
                                end

                                4'd6:begin
                                    if(discard[6] ==1'b0)begin
                                        if(pkt_orientation[6] ==2'd1)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b0;
                                            pdm_state <=PKT2FNP_S;
                                        end
                                        else if(pkt_orientation[6] ==2'd2)begin
                                            ov_pkt_data_cim <= iv_pkt_data;
                                            o_pkt_data_wr_cim <=1'b1;
                                            o_first_frag_cim <=1'b0;
                                            pdm_state <=PKT2CIM_S;
                                        end
                                        else if(pkt_orientation[6] ==2'd3)begin
                                            ov_pkt_data_lnp <= iv_pkt_data;
                                            o_pkt_data_wr_lnp <=1'b1;
                                            o_first_frag_lnp <=1'b0;
                                            pdm_state <=PKT2LNP_S;
                                        end
                                        else begin
                                            pdm_state <=INIT_S;
                                        end
                                    end
                                    else begin
                                        o_pkt_lost_pulse <=1'b1;
                                        pdm_state <=PKT_LOST_S;
                                    end
                                end

                                4'd7:begin
                                    if(discard[7] ==1'b0)begin
                                        if(pkt_orientation[7] ==2'd1)begin
                                            ov_pkt_data_fnp <= iv_pkt_data;
                                            o_pkt_data_wr_fnp <=1'b1;
                                            o_first_frag_fnp <=1'b0;
                                            pdm_state <=PKT2FNP_S;
                                        end
                                        else if(pkt_orientation[7] ==2'd2)begin
                                            ov_pkt_data_cim <= iv_pkt_data;
                                            o_pkt_data_wr_cim <=1'b1;
                                            o_first_frag_cim <=1'b0;
                                            pdm_state <=PKT2CIM_S;
                                        end
                                        else if(pkt_orientation[7] ==2'd3)begin
                                            ov_pkt_data_lnp <= iv_pkt_data;
                                            o_pkt_data_wr_lnp <=1'b1;
                                            o_first_frag_lnp <=1'b0;
                                            pdm_state <=PKT2LNP_S;
                                        end
                                        else begin
                                            pdm_state <=INIT_S;
                                        end
                                    end
                                    else begin
                                        o_pkt_lost_pulse <=1'b1;
                                        pdm_state <=PKT_LOST_S;
                                    end
                                end
								default:ov_pkt_inport_fnp <=iv_pkt_inport;

                            endcase
                        end
                end

                
                PKT2FNP_S:begin
                    if(i_pkt_data_wr ==1'b1)begin
                        ov_pkt_data_fnp <= iv_pkt_data;
                        o_pkt_data_wr_fnp <=1'b1;
                        pdm_state <=PKT2FNP_S;
                    end
                    else  begin //10tail
                        ov_pkt_data_fnp <= 134'b0;
                        o_pkt_data_wr_fnp <=1'b0;
                        pdm_state <=INIT_S;
                    end       
                end

                PKT2CIM_S:begin
                    if(i_pkt_data_wr ==1'b1)begin
                        ov_pkt_data_cim <= iv_pkt_data;
                        o_pkt_data_wr_cim <=1'b1;
                        pdm_state <=PKT2CIM_S;
                    end
                    else  begin //10tail
                        ov_pkt_data_cim <=134'b0;
                        o_pkt_data_wr_cim <=1'b0;
                        pdm_state <=INIT_S;
                    end
                end

                PKT2LNP_S:begin
                    if(i_pkt_data_wr ==1'b1)begin
                        ov_pkt_data_lnp <= iv_pkt_data;
                        o_pkt_data_wr_lnp <=1'b1;
                        pdm_state <=PKT2LNP_S;
                    end
                    else  begin //10tail
                        ov_pkt_data_lnp <=134'b0;
                        o_pkt_data_wr_lnp <=1'b0;
                        pdm_state <=INIT_S;
                    end
                end
				
				PKT_LOST_S:begin
					o_pkt_lost_pulse <=1'b0;
					pdm_state <=INIT_S;
				end

            endcase
        end   
    end
endmodule

/*
 * @Author: Wu Shangming
 * @Email: guangming836@163.com
 * @Date: 2020-11-01 23:03:42
 * @LastEditors: Shangming.W
 * @LastEditTime: 2020-11-04 21:31:20
 * @Description: 
   1.The code of pdm.
   2.TSNtag Replace module.
   3.More information in Doc.
 */