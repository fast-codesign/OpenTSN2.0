// Copyright (C) 1953-2020 NUDT
// Verilog module name - map_look_up_table 
// Version: GAH_V1.0
// Created:
//         by - Shangming Wu  guangming836@163.com
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         1.The code of mlt.
//         2.Map lookup table module.
//         3.More information in Doc.
///////////////////////////////////////////////////////////////////////////


module map_look_up_table #(
    parameter PLATFORM="hcp")
(
    input clk,
    input rst_n,

    //gfm 2 mlt
    input [103:0] iv_5tuple_data,
    input [3:0] iv_pkt_inport,
    input i_first_frag_flag,
    input i_data_wr,

    input [47:0] iv_temp_tsntag,	 
    input [1:0] iv_tcp_or_udp_pkt, 

    //mlt 2 ram(5tuple)
    output reg [4:0] ov_fmt_ram_raddr,
    output reg o_fmt_ram_rd,
    input [130:0] iv_fmt_ram_rdata,

    //mlt 2 ram(TSNtag)
    output reg [3:0] ov_tdt_ram_waddr,
    output reg o_tdt_ram_wr,
    output reg [47:0] ov_tdt_ram_wdata,
    output reg [3:0] ov_tdt_ram_raddr,
    output reg o_tdt_ram_rd,
    input [47:0] iv_tdt_ram_rdata,

    //mlt 2 tsntag_fifo
    output reg [47:0] ov_tsntag_data,
    output reg o_tsntag_wr,
	
	//mlt 2 trm
	output reg [3:0] ov_pkt_fragment_seq,
    output reg [3:0] ov_pkt_inport
);

    reg [3:0] mlt_state;

    reg [5:0] match_5tuple_cnt;

    reg [1:0] find_tsntag_cnt;
    reg [2:0] find_tsntag_finish_cnt;
	
	reg [3:0] pkt_fragment_seq0, pkt_fragment_seq1, pkt_fragment_seq2, pkt_fragment_seq3, pkt_fragment_seq4, pkt_fragment_seq5, pkt_fragment_seq6, pkt_fragment_seq7;

    reg [47:0] temp_inport0_tsntag, temp_inport1_tsntag, temp_inport2_tsntag, temp_inport3_tsntag, temp_inport4_tsntag, temp_inport5_tsntag, temp_inport6_tsntag, temp_inport7_tsntag;

    localparam  INIT_S =4'd0,
                MATCH_5TUPLE_S =4'd1,
                FIND_TSNTAG_S =4'd2,
                MATCH_5TUPLE_FINISH_S =4'd3,
                FIND_TSNTAG_FINISH_S =4'd4,
                DIRECT_OUTPUT_5TUPLE_S =4'd5,
				CLEAR_O_TSNTAG_WR_S =4'd6;



    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            ov_fmt_ram_raddr <=5'd0;
            o_fmt_ram_rd <=1'b0;

            ov_tdt_ram_waddr <=4'd0;
            o_tdt_ram_wr <=1'b0;
            ov_tdt_ram_wdata <=48'b0;
            ov_tdt_ram_raddr <=4'd0;
            o_tdt_ram_rd <=1'b0;

            ov_tsntag_data <=48'b0;
            o_tsntag_wr <=1'b0;
            ov_pkt_fragment_seq <=4'd0;
            ov_pkt_inport <=4'd0;

            
            match_5tuple_cnt <=6'd0;
            find_tsntag_cnt <=2'd0;
            find_tsntag_finish_cnt <=3'd0;
			
			pkt_fragment_seq0 <=4'd0;
			pkt_fragment_seq1 <=4'd0;
			pkt_fragment_seq2 <=4'd0;
			pkt_fragment_seq3 <=4'd0;
			pkt_fragment_seq4 <=4'd0;
			pkt_fragment_seq5 <=4'd0;
			pkt_fragment_seq6 <=4'd0;
			pkt_fragment_seq7 <=4'd0;

            temp_inport0_tsntag <=48'b0;
            temp_inport1_tsntag <=48'b0;
            temp_inport2_tsntag <=48'b0;
            temp_inport3_tsntag <=48'b0;
            temp_inport4_tsntag <=48'b0;
            temp_inport5_tsntag <=48'b0;
            temp_inport6_tsntag <=48'b0;
            temp_inport7_tsntag <=48'b0;
            mlt_state <=INIT_S;
        end
        else begin
            case(mlt_state)
                INIT_S:begin
                    ov_pkt_inport <=iv_pkt_inport;
                    //o_tsntag_wr <=1'b0;

                    //********first frag  (TCP or UDP)********>>>>>>>>>>>>>>
                    if( (i_first_frag_flag ==1'b1) && (i_data_wr ==1'b1) && (iv_tcp_or_udp_pkt ==2'b11) )begin
                        ov_fmt_ram_raddr <=5'd0;
                        o_fmt_ram_rd <=1'b1;
                            
                        ov_tdt_ram_waddr <=iv_pkt_inport;
						
                        case(iv_pkt_inport)
							4'd0:begin
								pkt_fragment_seq0 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport0_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq0 <=pkt_fragment_seq0 +4'd1;
							end
							4'd1:begin
								pkt_fragment_seq1 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport1_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq1 <=pkt_fragment_seq1 +4'd1;
							end
							4'd2:begin
								pkt_fragment_seq2 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport2_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq2 <=pkt_fragment_seq2 +4'd1;
							end
							4'd3:begin
								pkt_fragment_seq3 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport3_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq3 <=pkt_fragment_seq3 +4'd1;
							end
							4'd4:begin
								pkt_fragment_seq4 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport4_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq4 <=pkt_fragment_seq4 +4'd1;
							end
							4'd5:begin
								pkt_fragment_seq5 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport5_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq5 <=pkt_fragment_seq5 +4'd1;
							end
							4'd6:begin
								pkt_fragment_seq6 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport6_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq6 <=pkt_fragment_seq6 +4'd1;
							end
							4'd7:begin
								pkt_fragment_seq7 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport7_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq7 <=pkt_fragment_seq7 +4'd1;
							end
							default: mlt_state <=INIT_S;
							
						endcase
                        ov_tdt_ram_waddr <=iv_pkt_inport;
                        o_tdt_ram_wr <=1'b0;
                        ov_tdt_ram_wdata <=iv_temp_tsntag;
                        mlt_state <=MATCH_5TUPLE_S;
                    end 

                    //********first frag  (NOT TCP or UDP)********>>>>>>>>>>>>>>>>>>
                    else if( (i_first_frag_flag ==1'b1) && (i_data_wr ==1'b1) && (iv_tcp_or_udp_pkt ==2'b01) )begin
                        ov_fmt_ram_raddr <=5'd0;
                        o_fmt_ram_rd <=1'b1;
                            
                        ov_tdt_ram_waddr <=iv_pkt_inport;
						o_tdt_ram_wr <=1'b1;
                        ov_tdt_ram_wdata <=iv_temp_tsntag;
						
                        case(iv_pkt_inport)
							4'd0:begin
								pkt_fragment_seq0 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport0_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq0 <=pkt_fragment_seq0 +4'd1;
							end
							4'd1:begin
								pkt_fragment_seq1 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport1_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq1 <=pkt_fragment_seq1 +4'd1;
							end
							4'd2:begin
								pkt_fragment_seq2 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport2_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq2 <=pkt_fragment_seq2 +4'd1;
							end
							4'd3:begin
								pkt_fragment_seq3 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport3_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq3 <=pkt_fragment_seq3 +4'd1;
							end
							4'd4:begin
								pkt_fragment_seq4 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport4_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq4 <=pkt_fragment_seq4 +4'd1;
							end
							4'd5:begin
								pkt_fragment_seq5 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport5_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq5 <=pkt_fragment_seq5 +4'd1;
							end
							4'd6:begin
								pkt_fragment_seq6 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport6_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq6 <=pkt_fragment_seq6 +4'd1;
							end
							4'd7:begin
								pkt_fragment_seq7 <=4'd0;
                                ov_pkt_fragment_seq  <=4'd0;
                                temp_inport7_tsntag <=iv_temp_tsntag;
								//pkt_fragment_seq7 <=pkt_fragment_seq7 +4'd1;
							end
							default: mlt_state <=INIT_S;
							
						endcase

                        mlt_state <=DIRECT_OUTPUT_5TUPLE_S;
                    end

                    //********not first frag********
                    else if( (i_first_frag_flag ==1'b0) && (i_data_wr ==1'b1) )begin
                        ov_tdt_ram_raddr <=iv_pkt_inport;  //////////////////////////////////////////////////////************************************
                        //o_tdt_ram_rd <=1'b1;
						case(iv_pkt_inport)
                            4'd0:begin
								ov_pkt_fragment_seq  <=pkt_fragment_seq0 +4'd1;
								pkt_fragment_seq0 <=pkt_fragment_seq0 +4'd1;
								 ov_tsntag_data <=temp_inport0_tsntag;
									o_tsntag_wr <=1'b1;
								
							end
							4'd1:begin
								ov_pkt_fragment_seq  <=pkt_fragment_seq1 +4'd1;
								pkt_fragment_seq1 <=pkt_fragment_seq1 +4'd1;
								ov_tsntag_data <=temp_inport1_tsntag;
									o_tsntag_wr <=1'b1;
							
							end
							4'd2:begin
								ov_pkt_fragment_seq  <=pkt_fragment_seq2 +4'd1;
								pkt_fragment_seq2 <=pkt_fragment_seq2 +4'd1;
								ov_tsntag_data <=temp_inport2_tsntag;
									o_tsntag_wr <=1'b1;
								
							end
							4'd3:begin
								ov_pkt_fragment_seq  <=pkt_fragment_seq3 +4'd1;
								pkt_fragment_seq3 <=pkt_fragment_seq3 +4'd1;
								ov_tsntag_data <=temp_inport3_tsntag;
									o_tsntag_wr <=1'b1;
								
							end
							4'd4:begin
								ov_pkt_fragment_seq  <=pkt_fragment_seq4 +4'd1;
								pkt_fragment_seq4 <=pkt_fragment_seq4 +4'd1;
								ov_tsntag_data <=temp_inport4_tsntag;
									o_tsntag_wr <=1'b1;
								
							end
							4'd5:begin
								ov_pkt_fragment_seq  <=pkt_fragment_seq5 +4'd1;
								pkt_fragment_seq5 <=pkt_fragment_seq5 +4'd1;
								ov_tsntag_data <=temp_inport5_tsntag;
									o_tsntag_wr <=1'b1;
								
							end
							4'd6:begin
								ov_pkt_fragment_seq  <=pkt_fragment_seq6 +4'd1;
								pkt_fragment_seq6 <=pkt_fragment_seq6 +4'd1;
								ov_tsntag_data <=temp_inport6_tsntag;
									o_tsntag_wr <=1'b1;
								
							end
							4'd7:begin
								ov_pkt_fragment_seq  <=pkt_fragment_seq7 +4'd1;
								pkt_fragment_seq7 <=pkt_fragment_seq7 +4'd1;
								ov_tsntag_data <=temp_inport7_tsntag;
									o_tsntag_wr <=1'b1;
								
							end
                            default: mlt_state <=INIT_S;
						endcase
                        mlt_state <=FIND_TSNTAG_S;
                    end
                end

                MATCH_5TUPLE_S:begin
                    if( (match_5tuple_cnt ==6'd0) )begin
                        ov_fmt_ram_raddr <=5'd1;
                        o_fmt_ram_rd <=1'b1;

                        match_5tuple_cnt <=match_5tuple_cnt +6'd1;
                        mlt_state <=MATCH_5TUPLE_S;
                    end
                    else if(match_5tuple_cnt ==6'd1)begin
                        ov_fmt_ram_raddr <=5'd2;
                        o_fmt_ram_rd <=1'b1;

                        match_5tuple_cnt <=match_5tuple_cnt +6'd1;
                        mlt_state <=MATCH_5TUPLE_S;
                    end 
                    
                    //addr_00----addr_29
                    else if( (match_5tuple_cnt >=6'd2) && (match_5tuple_cnt <=6'd30))begin ///addr_1
                        ov_fmt_ram_raddr <=ov_fmt_ram_raddr +5'd1;
                        o_fmt_ram_rd <=1'b1;

                        if(iv_fmt_ram_rdata[130:27] ==iv_5tuple_data)begin
                            //ov_tsntag_data <={iv_fmt_ram_rdata[26:10], 21'b0, iv_fmt_ram_rdata[9:0] };
							ov_tsntag_data <={iv_fmt_ram_rdata[26:10], 21'b0, iv_fmt_ram_rdata[9:0] };
                            o_tsntag_wr <=1'b1;
                            
                            ov_tdt_ram_waddr <=iv_pkt_inport;
                            o_tdt_ram_wr <=1'b1;
                            ov_tdt_ram_wdata <={iv_fmt_ram_rdata[26:10], 21'b0, iv_fmt_ram_rdata[9:0] };

                            match_5tuple_cnt <=6'd0;
                            mlt_state <=MATCH_5TUPLE_FINISH_S;
                        end
                        else begin
                            match_5tuple_cnt <=match_5tuple_cnt +6'd1;
                            mlt_state <=MATCH_5TUPLE_S;
                        end
                    end

                    //addr_30
                    else if(match_5tuple_cnt ==6'd31)begin ///addr_1

                        if(iv_fmt_ram_rdata[130:27] ==iv_5tuple_data)begin
                            ///ov_tsntag_data <={iv_fmt_ram_rdata[26:10], 21'b0, iv_fmt_ram_rdata[9:0] };
							ov_tsntag_data <={iv_fmt_ram_rdata[26:10], 21'b0, iv_fmt_ram_rdata[9:0] };
							o_tsntag_wr <=1'b1;
                            
                            ov_tdt_ram_waddr <=iv_pkt_inport;
                            o_tdt_ram_wr <=1'b1;
                            ov_tdt_ram_wdata <={iv_fmt_ram_rdata[26:10], 21'b0, iv_fmt_ram_rdata[9:0] };

                            match_5tuple_cnt <=6'd0;
                            mlt_state <=MATCH_5TUPLE_FINISH_S;
                        end
                        else begin
                            match_5tuple_cnt <=match_5tuple_cnt +6'd1;
                            mlt_state <=MATCH_5TUPLE_S;
                        end
                    end
                    //addr_31
                    else if(match_5tuple_cnt ==6'd32)begin ///addr_1
                        
                        o_fmt_ram_rd <=1'b0;
                        if(iv_fmt_ram_rdata[130:27] ==iv_5tuple_data)begin
                            //ov_tsntag_data <={iv_fmt_ram_rdata[26:10], 21'b0, iv_fmt_ram_rdata[9:0] };
						    ov_tsntag_data <={iv_fmt_ram_rdata[26:10], 21'b0, iv_fmt_ram_rdata[9:0] };
                            o_tsntag_wr <=1'b1;
                            
                            ov_tdt_ram_waddr <=iv_pkt_inport;
                            o_tdt_ram_wr <=1'b1;
                            ov_tdt_ram_wdata <={iv_fmt_ram_rdata[26:10], 21'b0, iv_fmt_ram_rdata[9:0] };

                            match_5tuple_cnt <=6'd0;
                            mlt_state <=MATCH_5TUPLE_FINISH_S;
                        end
                        else begin
						    
                            match_5tuple_cnt <=6'd0;
                            mlt_state <=DIRECT_OUTPUT_5TUPLE_S;
                        end
                    end
                end
                
                

                FIND_TSNTAG_S:begin
                    if(find_tsntag_cnt ==2'd0)begin
                         ov_tdt_ram_raddr <=iv_pkt_inport;
                         o_tdt_ram_rd <=1'b1;
                         //o_tdt_ram_rd <=1'b0;
						 //ov_tsntag_data <=iv_tdt_ram_rdata;
						//o_tsntag_wr <=1'b1;
						
                        find_tsntag_cnt <=find_tsntag_cnt+2'd1;
                        mlt_state <=FIND_TSNTAG_S;
                    end
                    else if(find_tsntag_cnt ==2'd1)begin
                    
                        o_tdt_ram_rd <=1'b0;
                        find_tsntag_cnt <=find_tsntag_cnt+2'd1;
                        mlt_state <=FIND_TSNTAG_S;
                    end
                    else if(find_tsntag_cnt ==2'd2)begin
                        
                         ov_tsntag_data <=iv_tdt_ram_rdata;
                         o_tsntag_wr <=1'b1;
                        
                        o_tdt_ram_rd <=1'b0;
                        find_tsntag_cnt <=find_tsntag_cnt+2'd1;
         
                        mlt_state <=FIND_TSNTAG_S;
                    end
                    else if(find_tsntag_cnt ==2'd3)begin
                         ov_tsntag_data <=iv_tdt_ram_rdata;
                         o_tsntag_wr <=1'b0;
                       
                        find_tsntag_cnt <=2'd0;
                        mlt_state <=FIND_TSNTAG_FINISH_S;
                    end
                    
                    else begin
                        mlt_state <=INIT_S;
                    end
                end
                
                MATCH_5TUPLE_FINISH_S:begin
                    o_tsntag_wr <=1'b0;
                    o_tdt_ram_wr <=1'b0;
                    o_fmt_ram_rd <=1'b0;
                    if( i_data_wr ==1'b1  )begin
                        
                        mlt_state <=MATCH_5TUPLE_FINISH_S;
                    end
                    else begin
                        mlt_state <=INIT_S;
                    end                                   
                end
                
                FIND_TSNTAG_FINISH_S:begin
                    if( find_tsntag_finish_cnt <=3'd4 )begin
                        find_tsntag_finish_cnt <=find_tsntag_finish_cnt+3'd1;
                        mlt_state <=FIND_TSNTAG_FINISH_S;
                    end
                    else begin
                        find_tsntag_finish_cnt <=3'd0;
                        o_tsntag_wr <=1'b0;
                        mlt_state <=INIT_S;
                    end
                end

                DIRECT_OUTPUT_5TUPLE_S:begin
                    //if(not_tcp_udp_output_5tuple)||(tcp udp not match)
                        case(iv_pkt_inport)
                            4'd0:begin
                                ov_tsntag_data <=temp_inport0_tsntag;
                                o_tsntag_wr <=1'b1;

                                ov_tdt_ram_waddr <=iv_pkt_inport;
                                o_tdt_ram_wr <=1'b1;
                                ov_tdt_ram_wdata <=temp_inport0_tsntag;    
                            end
                            4'd1:begin
                                ov_tsntag_data <=temp_inport1_tsntag;
                                o_tsntag_wr <=1'b1;

                                ov_tdt_ram_waddr <=iv_pkt_inport;
                                o_tdt_ram_wr <=1'b1;
                                ov_tdt_ram_wdata <=temp_inport1_tsntag;    
                            end
                            4'd2:begin
                                ov_tsntag_data <=temp_inport2_tsntag;
                                o_tsntag_wr <=1'b1;

                                ov_tdt_ram_waddr <=iv_pkt_inport;
                                o_tdt_ram_wr <=1'b1;
                                ov_tdt_ram_wdata <=temp_inport2_tsntag;    
                            end
                            4'd3:begin
                                ov_tsntag_data <=temp_inport3_tsntag;
                                o_tsntag_wr <=1'b1;

                                ov_tdt_ram_waddr <=iv_pkt_inport;
                                o_tdt_ram_wr <=1'b1;
                                ov_tdt_ram_wdata <=temp_inport3_tsntag;    
                            end
                            4'd4:begin
                                ov_tsntag_data <=temp_inport4_tsntag;
                                o_tsntag_wr <=1'b1;

                                ov_tdt_ram_waddr <=iv_pkt_inport;
                                o_tdt_ram_wr <=1'b1;
                                ov_tdt_ram_wdata <=temp_inport4_tsntag;    
                            end
                            4'd5:begin
                                ov_tsntag_data <=temp_inport5_tsntag;
                                o_tsntag_wr <=1'b1;

                                ov_tdt_ram_waddr <=iv_pkt_inport;
                                o_tdt_ram_wr <=1'b1;
                                ov_tdt_ram_wdata <=temp_inport5_tsntag;    
                            end
                            4'd6:begin
                                ov_tsntag_data <=temp_inport6_tsntag;
                                o_tsntag_wr <=1'b1;
                                
                                ov_tdt_ram_waddr <=iv_pkt_inport;
                                o_tdt_ram_wr <=1'b1;
                                ov_tdt_ram_wdata <=temp_inport6_tsntag;    
                            end
                            4'd7:begin
                                ov_tsntag_data <=temp_inport7_tsntag;
                                o_tsntag_wr <=1'b1; 

                                ov_tdt_ram_waddr <=iv_pkt_inport;
                                o_tdt_ram_wr <=1'b1;
                                ov_tdt_ram_wdata <=temp_inport7_tsntag;   
                            end
                            default: mlt_state <=INIT_S;
                        endcase
                        mlt_state <=CLEAR_O_TSNTAG_WR_S;
                end
				
				CLEAR_O_TSNTAG_WR_S:begin
					o_tsntag_wr <=1'b0;
					mlt_state <=INIT_S;
				end

            endcase
        end
    end
endmodule           