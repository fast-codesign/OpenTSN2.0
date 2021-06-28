// Copyright (C) 1953-2020 NUDT
// Verilog module name - tsntag_replace_module 
// Version: GAH_V1.0
// Created:
//         by - Shangming Wu  guangming836@163.com
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         1.The code of trm.
//         2.TSNtag Replace module.
//         3.More information in Doc.
///////////////////////////////////////////////////////////////////////////
`include "./rtl/hcp/hcp_macro_define.v"


module tsntag_replace_module #(
    parameter PLATFORM="hcp")
(
    input clk,
    input rst_n,

    //fifo_tsntag 2 trm
    input [47:0] iv_tsn_tag_data,
    input fifo_tsntag_empty,
	output reg fifo_tsntag_rd,
	
	//mlt 2 trm
    input [3:0] iv_pkt_fragment_seq,
    input [3:0] iv_pkt_inport,

    //fifo -- trm
    input [133:0] iv_pkt_data,
    output reg o_fifo_rd,

    //trm 2 fifo
    output reg [133:0] ov_pkt_data,
    output reg o_pkt_data_wr,

    //state (pkt lost_head_fragment)
    output reg  inport_0_lost_head, 
    output reg  inport_1_lost_head, 
    output reg  inport_2_lost_head, 
    output reg  inport_3_lost_head, 
    output reg  inport_4_lost_head, 
    output reg  inport_5_lost_head, 
    output reg  inport_6_lost_head, 
    output reg  inport_7_lost_head,

    //state (pkt lost_nothead_fragment)
    output reg  inport_0_lost_nothead, 
    output reg  inport_1_lost_nothead, 
    output reg  inport_2_lost_nothead, 
    output reg  inport_3_lost_nothead, 
    output reg  inport_4_lost_nothead, 
    output reg  inport_5_lost_nothead, 
    output reg  inport_6_lost_nothead, 
    output reg  inport_7_lost_nothead

);

    reg [3:0] trm_state;
    
    reg [47:0] temp_tsntag;
    reg [1:0] replace_tsntag_cnt;
    reg [2:0] trans_cnt;
    reg [15:0] pkt_total_len0, pkt_total_len1, pkt_total_len2, pkt_total_len3, pkt_total_len4, pkt_total_len5, pkt_total_len6, pkt_total_len7;
    reg [133:0] temp_pkt_data1, temp_pkt_data2;
	
    //reg []
    
	reg [1:0] first_frag_cnt;
    reg [1:0] first_frag_finish_cnt;
    reg [1:0] not_first_frag_finish_cnt;



    localparam  INIT_S =4'd0,
                REPLACE_TSNTAG_S =4'd1,
                TRANS_FIRST_FRAG_S1  =4'd2,
                TRANS_FIRST_FRAG_S2  =4'd3,
                TRANS_NOT_FIRST_FRAG_S  =4'd4,
                FIRST_FRAG_FINISH_S  =4'd5,
                NOT_FIRST_FRAG_FINISH_S  =4'd6;


    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            o_fifo_rd <=1'b0;
            
			
			fifo_tsntag_rd <=1'b0;
            ov_pkt_data <=134'b0;
            o_pkt_data_wr <=1'b0;

            inport_0_lost_head <=1'b0;
            inport_1_lost_head <=1'b0;
            inport_2_lost_head <=1'b0;
            inport_3_lost_head <=1'b0;
            inport_4_lost_head <=1'b0;
            inport_5_lost_head <=1'b0;
            inport_6_lost_head <=1'b0;
            inport_7_lost_head <=1'b0;

            inport_0_lost_nothead <=1'b0;
            inport_1_lost_nothead <=1'b0;
            inport_2_lost_nothead <=1'b0;
            inport_3_lost_nothead <=1'b0;
            inport_4_lost_nothead <=1'b0;
            inport_5_lost_nothead <=1'b0;
            inport_6_lost_nothead <=1'b0;
            inport_7_lost_nothead <=1'b0;



            
            temp_tsntag <=48'b0;
            replace_tsntag_cnt <=2'd0;
            trans_cnt <=3'd0;
            
            pkt_total_len0 <=16'd0;
            pkt_total_len1 <=16'd0;
            pkt_total_len2 <=16'd0;
            pkt_total_len3 <=16'd0;
            pkt_total_len4 <=16'd0;
            pkt_total_len5 <=16'd0;
            pkt_total_len6 <=16'd0;
            pkt_total_len7 <=16'd0;
            
            temp_pkt_data1 <=134'b0;
            temp_pkt_data2 <=134'b0;
            first_frag_cnt <=2'd0;
            first_frag_finish_cnt <=2'd0;
            not_first_frag_finish_cnt <=2'd0;

            trm_state <=INIT_S;
        end
        else begin
            case(trm_state)
                INIT_S:begin
                    inport_0_lost_head <=1'b0;
                    inport_1_lost_head <=1'b0;
                    inport_2_lost_head <=1'b0;
                    inport_3_lost_head <=1'b0;
                    inport_4_lost_head <=1'b0;
                    inport_5_lost_head <=1'b0;
                    inport_6_lost_head <=1'b0;
                    inport_7_lost_head <=1'b0;


                    if(fifo_tsntag_empty ==1'b0)begin
                         
                        fifo_tsntag_rd <=1'b1;
						 
                        trm_state <=REPLACE_TSNTAG_S;
                    end
                    else begin
			            fifo_tsntag_rd <=1'b0;
						o_fifo_rd <=1'b0;
                        trm_state <=INIT_S;
                    end
                end
				

                REPLACE_TSNTAG_S:begin
                    if(replace_tsntag_cnt ==2'd0)begin
					    temp_tsntag <=iv_tsn_tag_data;
                        temp_pkt_data1 <={6'b010000, iv_tsn_tag_data[47:45], iv_tsn_tag_data[9:5], 9'b0, 1'b1, 1'b0, 45'b0, 64'h0000_0000_0000_0000};  //metadata
						
                        o_pkt_data_wr <=1'b0;
                        
						fifo_tsntag_rd <=1'b0;
                        o_fifo_rd <=1'b1;
                        replace_tsntag_cnt <=replace_tsntag_cnt+2'd1;
                        trm_state <=REPLACE_TSNTAG_S;
                    end
                    else begin   //first frag
                        if( iv_pkt_data[31:16] ==16'h0800 )begin
                            
                            temp_pkt_data1 <={2'b11,iv_pkt_data[131:32], 16'h1800, iv_pkt_data[15:0] };
                            temp_pkt_data2 <=temp_pkt_data1;

                           
                            o_pkt_data_wr <=1'b0;
                    
                            o_fifo_rd <=1'b1;
                            replace_tsntag_cnt <=2'd0;

                            case(iv_pkt_inport)
                                4'd0:begin
                                    if(pkt_total_len0 >16'd0)begin
                                        inport_0_lost_nothead <=1'b1;
                                    end
                                    else begin
                                        inport_0_lost_nothead <=1'b0;
                                    end
                                end 
                                4'd1:begin
                                    if(pkt_total_len1 >16'd0)begin
                                        inport_1_lost_nothead <=1'b1;
                                    end
                                    else begin
                                        inport_1_lost_nothead <=1'b0;
                                    end
                                end 
                                4'd2:begin
                                    if(pkt_total_len2 >16'd0)begin
                                        inport_2_lost_nothead <=1'b1;
                                    end
                                    else begin
                                        inport_2_lost_nothead <=1'b0;
                                    end
                                end 
                                4'd3:begin
                                    if(pkt_total_len3 >16'd0)begin
                                        inport_3_lost_nothead <=1'b1;
                                    end
                                    else begin
                                        inport_3_lost_nothead <=1'b0;
                                    end
                                end 
                                4'd4:begin
                                    if(pkt_total_len4 >16'd0)begin
                                        inport_4_lost_nothead <=1'b1;
                                    end
                                    else begin
                                        inport_4_lost_nothead <=1'b0;
                                    end
                                end 
                                4'd5:begin
                                    if(pkt_total_len5 >16'd0)begin
                                        inport_5_lost_nothead <=1'b1;
                                    end
                                    else begin
                                        inport_5_lost_nothead <=1'b0;
                                    end
                                end 
                                4'd6:begin
                                    if(pkt_total_len6 >16'd0)begin
                                        inport_6_lost_nothead <=1'b1;
                                    end
                                    else begin
                                        inport_6_lost_nothead <=1'b0;
                                    end
                                end 
                                4'd7:begin
                                    if(pkt_total_len7 >16'd0)begin
                                        inport_7_lost_nothead <=1'b1;
                                    end
                                    else begin
                                        inport_7_lost_nothead <=1'b0;
                                    end
                                end         
                                default: trm_state <=INIT_S;
                            endcase
                            trm_state <=TRANS_FIRST_FRAG_S1;
                        end
                        else if( iv_pkt_data[127:0] ==128'b0) begin  //not  first frag
                            `ifdef frame_frag_version
							    temp_pkt_data1 <={6'b110000, temp_tsntag[47:15], 1'b0, iv_pkt_fragment_seq, temp_tsntag[9:0], iv_pkt_data[79:0]};  //Frag flag:1'b0-not pkt_fragment_tail   Frag ID:4'd0-pkt_fragment_seq 
								 
						    `endif
                            `ifdef frame_notfrag_version
							    temp_pkt_data1 <={6'b110000, temp_tsntag[47:15], 1'b1, iv_pkt_fragment_seq, temp_tsntag[9:0], iv_pkt_data[79:0]};  //Frag flag:1'b0-not pkt_fragment_tail   Frag ID:4'd0-pkt_fragment_seq
								
							`endif
                            ov_pkt_data <=temp_pkt_data1;
                            
                            case( iv_pkt_inport )
                                4'd0:begin
                                    if(pkt_total_len0 >16'd112)begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else if( (pkt_total_len0 <=16'd112) && (pkt_total_len0 >16'd0) )begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else begin //pkt_total_len0 ==16'd0
                                        inport_0_lost_head <=1'b1;
                                        trm_state <=INIT_S;
                                    end
                                end
                                4'd1:begin
                                    if(pkt_total_len1 >16'd112)begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else if( (pkt_total_len1 <=16'd112) && (pkt_total_len1 >16'd0)  )begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else begin //pkt_total_len1 ==16'd0
                                        inport_1_lost_head <=1'b1;
                                        trm_state <=INIT_S;
                                    end
                                end
                                4'd2:begin
                                    if(pkt_total_len2 >16'd112)begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else if( (pkt_total_len2 <=16'd112) && (pkt_total_len2 >16'd0)  )begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else begin //pkt_total_len2 ==16'd0
                                        inport_2_lost_head <=1'b1;
                                        trm_state <=INIT_S;
                                    end
                                end
                                4'd3:begin
                                    if(pkt_total_len3 >16'd112)begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else if( (pkt_total_len3 <=16'd112) && (pkt_total_len3 >16'd0)  )begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else begin //pkt_total_len3 ==16'd0
                                        inport_3_lost_head <=1'b1;
                                        trm_state <=INIT_S;
                                    end
                                end
                                4'd4:begin
                                    if(pkt_total_len4 >16'd112)begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else if( (pkt_total_len4 <=16'd112) && (pkt_total_len4 >16'd0)  )begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else begin //pkt_total_len4 ==16'd0
                                        inport_4_lost_head <=1'b1;
                                        trm_state <=INIT_S;
                                    end
                                end
                                4'd5:begin
                                    if(pkt_total_len5 >16'd112)begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else if( (pkt_total_len5 <=16'd112) && (pkt_total_len5 >16'd0)  )begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else begin //pkt_total_len5 ==16'd0
                                        inport_5_lost_head <=1'b1;
                                        trm_state <=INIT_S;
                                    end
                                end
                                4'd6:begin
                                    if(pkt_total_len6 >16'd112)begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else if( (pkt_total_len6 <=16'd112) && (pkt_total_len6 >16'd0)  )begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else begin //pkt_total_len6 ==16'd0
                                        inport_6_lost_head <=1'b1;
                                        trm_state <=INIT_S;
                                    end
                                end
                                4'd7:begin
                                    if(pkt_total_len7 >16'd112)begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else if( (pkt_total_len7 <=16'd112) && (pkt_total_len7 >16'd0)  )begin
                                        o_pkt_data_wr <=1'b1;
                                    end
                                    else begin //pkt_total_len7 ==16'd0
                                        inport_7_lost_head <=1'b1;
                                        trm_state <=INIT_S;
                                    end
                                end
                                default: trm_state <=INIT_S;
                            endcase

                                o_fifo_rd <=1'b1;
                                replace_tsntag_cnt <=2'd0;
                                trm_state <=TRANS_NOT_FIRST_FRAG_S;
                            
                        end
                        else begin  
                            trm_state <=INIT_S;
                        end
                    end
                end

                TRANS_FIRST_FRAG_S1:begin
                    //******first_frag_cnt ==2'd0
                    //if(first_frag_cnt ==2'd0)begin  
                    inport_0_lost_nothead <=1'b0;
                    inport_1_lost_nothead <=1'b0;
                    inport_2_lost_nothead <=1'b0;
                    inport_3_lost_nothead <=1'b0;
                    inport_4_lost_nothead <=1'b0;
                    inport_5_lost_nothead <=1'b0;
                    inport_6_lost_nothead <=1'b0;
                    inport_7_lost_nothead <=1'b0;

                        if((iv_pkt_data[133:132]==2'b11) && (iv_pkt_data[127:112]<=16'd114) )begin
                           
                            temp_pkt_data1 <={2'b11,iv_pkt_data[131:0]};
                            temp_pkt_data2 <={6'b110000, temp_tsntag[47:15], 1'b1, 4'd0, temp_tsntag[9:0], temp_pkt_data1[79:0]};  //Frag flag:1'b1-only one pkt_fragment_tail   Frag ID:4'd0-pkt_fragment_seq;
                            
							ov_pkt_data <= temp_pkt_data2;     //metadata
                            o_pkt_data_wr <=1'b1;
                        
                            o_fifo_rd <=1'b1;

                            case(iv_pkt_inport)
                                4'd0:begin
                                    pkt_total_len0 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd1:begin
                                    pkt_total_len1 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd2:begin
                                    pkt_total_len2 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd3:begin
                                    pkt_total_len3 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd4:begin
                                    pkt_total_len4 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd5:begin
                                    pkt_total_len5 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd6:begin
                                    pkt_total_len6 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd7:begin
                                    pkt_total_len7 <=iv_pkt_data[127:112] -16'd18;
                                end
                                default: trm_state <=INIT_S;
                            endcase
                        
                            trm_state <=TRANS_FIRST_FRAG_S2;            
                        end
                        else if((iv_pkt_data[133:132]==2'b11) && (iv_pkt_data[127:112] >16'd114) )begin
                            
                            temp_pkt_data1 <={2'b11,iv_pkt_data[131:0]};
                            `ifdef frame_frag_version
                                temp_pkt_data2 <={6'b110000, temp_tsntag[47:15], 1'b0, 4'd0, temp_tsntag[9:0], temp_pkt_data1[79:0]};  //Frag flag:1'b1-only one pkt_fragment_tail   Frag ID:4'd0-pkt_fragment_seq;
								 
                            `endif
                            `ifdef frame_notfrag_version
                                temp_pkt_data2 <={6'b110000, temp_tsntag[47:15], 1'b1, 4'd0, temp_tsntag[9:0], temp_pkt_data1[79:0]};  //Frag flag:1'b1-only one pkt_fragment_tail   Frag ID:4'd0-pkt_fragment_seq;
								 
                            `endif                            
                            ov_pkt_data <= temp_pkt_data2;     //metadata
                            o_pkt_data_wr <=1'b1;
                        
                            o_fifo_rd <=1'b1;

                            case(iv_pkt_inport)
                                4'd0:begin
                                    pkt_total_len0 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd1:begin
                                    pkt_total_len1 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd2:begin
                                    pkt_total_len2 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd3:begin
                                    pkt_total_len3 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd4:begin
                                    pkt_total_len4 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd5:begin
                                    pkt_total_len5 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd6:begin
                                    pkt_total_len6 <=iv_pkt_data[127:112] -16'd18;
                                end
                                4'd7:begin
                                    pkt_total_len7 <=iv_pkt_data[127:112] -16'd18;
                                end
                                default: trm_state <=INIT_S;
                            endcase
                        
                            trm_state <=TRANS_FIRST_FRAG_S2; 
                        end
                        else begin
                            trm_state <=INIT_S;
                        end
                                     
                end

                TRANS_FIRST_FRAG_S2:begin
                    if(iv_pkt_data[133:132]==2'b11 )begin
                        
                        temp_pkt_data1 <=iv_pkt_data;
                        temp_pkt_data2 <=temp_pkt_data1;  
                        ov_pkt_data <= temp_pkt_data2;    
                        o_pkt_data_wr <=1'b1;
                        
                        o_fifo_rd <=1'b1;

                        case(iv_pkt_inport)
                            4'd0:begin
                                pkt_total_len0 <=pkt_total_len0 -16'd16;
                            end
                            4'd1:begin
                                pkt_total_len1 <=pkt_total_len1 -16'd16;
                            end
                            4'd2:begin
                                pkt_total_len2 <=pkt_total_len2 -16'd16;
                            end
                            4'd3:begin
                                pkt_total_len3 <=pkt_total_len3 -16'd16;
                            end
                            4'd4:begin
                                pkt_total_len4 <=pkt_total_len4 -16'd16;
                            end
                            4'd5:begin
                                pkt_total_len5 <=pkt_total_len5 -16'd16;
                            end
                            4'd6:begin
                                pkt_total_len6 <=pkt_total_len6 -16'd16;
                            end
                            4'd7:begin
                                pkt_total_len7 <=pkt_total_len7 -16'd16;
                            end
                            default: trm_state <=INIT_S;
                        endcase
                        
                        trm_state <=TRANS_FIRST_FRAG_S2;            
                    end
                    else if(iv_pkt_data[133:132]==2'b10 )begin
                     
                        temp_pkt_data1 <=iv_pkt_data;
                        temp_pkt_data2 <=temp_pkt_data1;  
                        ov_pkt_data <= temp_pkt_data2; 
                        o_pkt_data_wr <=1'b1;
                        
                        o_fifo_rd <=1'b0;

                        case(iv_pkt_inport)
                            4'd0:begin
                                pkt_total_len0 <=pkt_total_len0 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd1:begin
                                pkt_total_len1 <=pkt_total_len1 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd2:begin
                                pkt_total_len2 <=pkt_total_len2 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd3:begin
                                pkt_total_len3 <=pkt_total_len3 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd4:begin
                                pkt_total_len4 <=pkt_total_len4 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd5:begin
                                pkt_total_len5 <=pkt_total_len5 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd6:begin
                                pkt_total_len6 <=pkt_total_len6 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd7:begin
                                pkt_total_len7 <=pkt_total_len7 +iv_pkt_data[131:128] -16'd16;
                            end
                            default: trm_state <=INIT_S;
                        endcase
                        trm_state <=FIRST_FRAG_FINISH_S;
                    end
                    else begin
                        trm_state <=INIT_S;
                    end                          
                end



                TRANS_NOT_FIRST_FRAG_S:begin
                    if(iv_pkt_data[133:132]==2'b11 )begin
                        //ov_pkt_data <= iv_pkt_data;
                        
                        temp_pkt_data1 <=iv_pkt_data;
                        ov_pkt_data <=temp_pkt_data1;
                        o_pkt_data_wr <=1'b1;
                        
                        o_fifo_rd <=1'b1;

                        case(iv_pkt_inport)
                            4'd0:begin
                                pkt_total_len0 <=pkt_total_len0 -16'd16;
                            end
                            4'd1:begin
                                pkt_total_len1 <=pkt_total_len1 -16'd16;
                            end
                            4'd2:begin
                                pkt_total_len2 <=pkt_total_len2 -16'd16;
                            end
                            4'd3:begin
                                pkt_total_len3 <=pkt_total_len3 -16'd16;
                            end
                            4'd4:begin
                                pkt_total_len4 <=pkt_total_len4 -16'd16;
                            end
                            4'd5:begin
                                pkt_total_len5 <=pkt_total_len5 -16'd16;
                            end
                            4'd6:begin
                                pkt_total_len6 <=pkt_total_len6 -16'd16;
                            end
                            4'd7:begin
                                pkt_total_len7 <=pkt_total_len7 -16'd16;
                            end
                            default: trm_state <=INIT_S;
                        endcase
                        
                        trm_state <=TRANS_NOT_FIRST_FRAG_S;            
                    end
                    else if(iv_pkt_data[133:132]==2'b10 )begin
                        //ov_pkt_data <= iv_pkt_data;
                        
                        temp_pkt_data1 <=iv_pkt_data;
                        ov_pkt_data <=temp_pkt_data1;
                        o_pkt_data_wr <=1'b1;
                        
                        o_fifo_rd <=1'b0;

                        case(iv_pkt_inport)
                            4'd0:begin
                                pkt_total_len0 <=pkt_total_len0 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd1:begin
                                pkt_total_len1 <=pkt_total_len1 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd2:begin
                                pkt_total_len2 <=pkt_total_len2 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd3:begin
                                pkt_total_len3 <=pkt_total_len3 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd4:begin
                                pkt_total_len4 <=pkt_total_len4 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd5:begin
                                pkt_total_len5 <=pkt_total_len5 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd6:begin
                                pkt_total_len6 <=pkt_total_len6 +iv_pkt_data[131:128] -16'd16;
                            end
                            4'd7:begin
                                pkt_total_len7 <=pkt_total_len7 +iv_pkt_data[131:128] -16'd16;
                            end
                            default: trm_state <=INIT_S;
                        endcase
                        trm_state <=NOT_FIRST_FRAG_FINISH_S;
                    end
                    else begin
                        trm_state <=INIT_S;
                    end                          
                end

                
                FIRST_FRAG_FINISH_S:begin
                    if( first_frag_finish_cnt ==2'd0 )begin
                        
                        temp_pkt_data2 <=temp_pkt_data1;  
                        ov_pkt_data <= temp_pkt_data2;
                        o_pkt_data_wr <=1'b1; 

                        first_frag_finish_cnt <=first_frag_finish_cnt +2'd1;
                        trm_state <=FIRST_FRAG_FINISH_S;
                    end
                    else if( first_frag_finish_cnt ==2'd1 ) begin
                      
                        ov_pkt_data <= temp_pkt_data2;
                        o_pkt_data_wr <=1'b1; 

                        first_frag_finish_cnt <=first_frag_finish_cnt +2'd1;
                        trm_state <=FIRST_FRAG_FINISH_S;
                    end
                    else if( first_frag_finish_cnt ==2'd2 )begin
                        ov_pkt_data <= 134'b0;
                        o_pkt_data_wr <=1'b0; 

                        first_frag_finish_cnt <=2'd0;
                        trm_state <= INIT_S;
                    end
                    else begin
                        trm_state <= INIT_S;
                    end
                end

                NOT_FIRST_FRAG_FINISH_S:begin
                    if(not_first_frag_finish_cnt ==2'd0)begin
                        ov_pkt_data <=temp_pkt_data1;
                        o_pkt_data_wr <=1'b1;
                        
                        not_first_frag_finish_cnt <=not_first_frag_finish_cnt+2'd1;
                        trm_state <=NOT_FIRST_FRAG_FINISH_S;
                    end
                    else begin
                    
                        ov_pkt_data <= 134'b0;
                        o_pkt_data_wr <=1'b0; 
                        not_first_frag_finish_cnt <=2'd0; 
						o_fifo_rd <=1'b0;		
                        trm_state <=INIT_S;
                    end
                end
                
            endcase
            
        end
    end
endmodule