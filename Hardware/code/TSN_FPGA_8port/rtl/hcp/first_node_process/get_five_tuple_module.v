// Copyright (C) 1953-2020 NUDT
// Verilog module name - get_five_tuple_module 
// Version: GAH_V1.0
// Created:
//         by - fenglin
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         1.The code of gfm.
//         2.Get 5tuple of TCP and UDP.
//         3.More information in Doc.
///////////////////////////////////////////////////////////////////////////


module get_five_tuple_module #(
    parameter PLATFORM="hcp")
(
    input clk,
    input rst_n,
    
    //input
    input [133:0] iv_pkt_data,
    input i_pkt_data_wr,
    input [3:0] iv_pkt_inport, 

    //gfm 2 fifo
    output reg [133:0] ov_pkt_data,
    output reg o_pkt_data_wr,

    //gfm 2 mlt
    output reg [103:0] ov_5tuple_data,
    output reg [3:0] ov_pkt_inport,
    output reg o_first_frag_flag,
    output reg o_data_wr,

    output reg [47:0] ov_temp_tsntag,

    output reg [1:0] ov_tcp_or_udp_pkt,
    


    //inpkt_cnt
    output reg o_inpkt_cnt
);
 
    reg [3:0] gfm_state;

    reg [1:0] tuple_cnt;

    reg [133:0] temp_pkt_data;


    localparam INIT_S =4'd0,
                GET_5TUPLE_S1 =4'd1,
                GET_5TUPLE_S2 =4'd5,
                TRANS_FIRST_S =4'd2,
                TRANS_FIRST_FINISH_S =4'd3,
                TRANS_NOTFIRST_S =4'd4;
               

    

    always @(posedge clk or negedge rst_n)begin 
        if(!rst_n)begin
            ov_pkt_data <=134'b0;
            o_pkt_data_wr <=1'b0;
            
            ov_5tuple_data <=104'b0;
            ov_pkt_inport <=4'd0;
            o_first_frag_flag <= 1'b0;
            o_data_wr <=1'b0;

            tuple_cnt <=2'd0;

            ov_temp_tsntag <=48'b0;

            ov_tcp_or_udp_pkt <=2'b00;
			
			o_inpkt_cnt <=1'b0;
			
			temp_pkt_data <=134'b0;
    
            gfm_state <=INIT_S;
        end
        else begin
            case(gfm_state)
                INIT_S:begin
                    ov_pkt_inport <=iv_pkt_inport;
                //********first frag********
                    if( (iv_pkt_data[133:132] ==2'b01) && (i_pkt_data_wr ==1'b1) && (iv_pkt_data[127:0] !=128'b0) )begin
                                                                                               //ov_pkt_data <=iv_pkt_data;
                        temp_pkt_data <=iv_pkt_data;
                        o_pkt_data_wr <=1'b0;
                        
                        o_first_frag_flag <=1'b1;
                        o_data_wr <=1'b0;

                        ov_temp_tsntag <=iv_pkt_data[127:80];

                        o_inpkt_cnt <=1'b1;
                        gfm_state <=GET_5TUPLE_S1;
                    end
                //********not first frag********    
                    else if( (iv_pkt_data[133:132] ==2'b01) && (i_pkt_data_wr ==1'b1) && (iv_pkt_data[127:0] ==128'b0) )begin
                        ov_pkt_data <=iv_pkt_data;
                        o_pkt_data_wr <=1'b1;

                        o_first_frag_flag <=1'b0;
                        o_data_wr <=1'b1;

                        gfm_state <=TRANS_NOTFIRST_S;
                    end
                    else begin
                        gfm_state <=INIT_S;
                    end
                end

                GET_5TUPLE_S1:begin
                           
                    o_inpkt_cnt <=1'b0;
                    //TCP & UDP
                    if( (iv_pkt_data[133:132] ==2'b11) && (i_pkt_data_wr ==1'b1) &&((iv_pkt_data[71:64] ==8'd6) ||(iv_pkt_data[71:64] ==8'd17)) )begin                                                                                                                                           //ov_pkt_data <=iv_pkt_data;
                            temp_pkt_data <=iv_pkt_data;
                            ov_pkt_data <=temp_pkt_data;
                            o_pkt_data_wr <=1'b1;

                            ov_tcp_or_udp_pkt <=2'b11;  //This is TCP or UDP pkt

                            ov_5tuple_data[103:96] <=iv_pkt_data[71:64]; //protocal
                            ov_5tuple_data[95:64] <=iv_pkt_data[47:16];  //src ip
                            ov_5tuple_data[63:48] <=iv_pkt_data[15:0];   //dst ip
                            o_data_wr <=1'b0;
                            
                            gfm_state <=GET_5TUPLE_S2;
                    end
                      
                    // NOT TCP & UDP
					else begin
                        temp_pkt_data <=iv_pkt_data;
                        ov_pkt_data <=temp_pkt_data;
                        o_pkt_data_wr <=1'b1;

                        ov_tcp_or_udp_pkt <=2'b01;  //This is not TCP or UDP pkt
                        o_data_wr <=1'b1;
                       
						gfm_state <=TRANS_FIRST_S;
					end
                end
//
                GET_5TUPLE_S2:begin
                        if( (iv_pkt_data[133:132] ==2'b11) && (i_pkt_data_wr ==1'b1) )begin
                            //ov_pkt_data <=iv_pkt_data;
                            temp_pkt_data <=iv_pkt_data;
                            ov_pkt_data <=temp_pkt_data;
                            o_pkt_data_wr <=1'b1;

                            ov_5tuple_data[47:0] <=iv_pkt_data[127:80]; //dst ip /src port /dst port
                            o_data_wr <=1'b1;
                            //tuple_cnt <=2'd0;
                            gfm_state <=TRANS_FIRST_S;
                        end
                        else begin
                            gfm_state <=INIT_S;
                        end    

                end



                TRANS_FIRST_S:begin
					o_data_wr <=1'b0;
                    if( i_pkt_data_wr ==1'b1 )begin
                                                                                                                   
                        temp_pkt_data <=iv_pkt_data;
                        ov_pkt_data <=temp_pkt_data;                                                                                            
                        o_pkt_data_wr <=1'b1;

                        gfm_state <=TRANS_FIRST_S;
                    end
                    else begin
                        ov_pkt_data <=temp_pkt_data;
                        o_pkt_data_wr <=1'b1;

                        o_first_frag_flag <=1'b1;
                        
                        gfm_state <=TRANS_FIRST_FINISH_S;
                    end
                end

                TRANS_FIRST_FINISH_S:begin
                    ov_pkt_data <=134'b0;
                    o_pkt_data_wr <=1'b0;

                    ov_tcp_or_udp_pkt <=2'b00;

                    o_data_wr <=1'b0;
                    o_first_frag_flag <=1'b0;
                    gfm_state <=INIT_S;
                end

                TRANS_NOTFIRST_S:begin
				    o_data_wr <=1'b0;
                    if( i_pkt_data_wr ==1'b1 )begin
                        ov_pkt_data <=iv_pkt_data;
                        o_pkt_data_wr <=1'b1;

                        gfm_state <=TRANS_NOTFIRST_S; 
                    end
                    else begin
                        ov_pkt_data <=134'b0;
                        o_pkt_data_wr <=1'b0;

                        o_data_wr <=1'b0;
                        
                        gfm_state <=INIT_S;
                    end
                end 
            endcase
        end
    end
endmodule