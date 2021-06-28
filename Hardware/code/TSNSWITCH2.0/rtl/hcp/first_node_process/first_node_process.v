// Copyright (C) 1953-2020 NUDT
// Verilog module name - first_node_process 
// Version: GAH_V1.0
// Created:
//         by - Shangming Wu  guangming836@163.com
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         1.The code of fnp.
//         2.The top module.
//         3.More information in Doc.
///////////////////////////////////////////////////////////////////////////


module first_node_process #(
    parameter PLATFORM="hcp")
(
    input clk,
    input rst_n,

    //input
    input [133:0] iv_fnp_pkt_data,
    input i_fnp_pkt_data_wr,
    input [3:0] iv_fnp_pkt_inport,
    
    //cim to fifo(5tuple)
    input [4:0] iv_fnp_fmt_ram_addr,
    input i_fnp_fmt_ram_wr,
    input [151:0] iv_fnp_fmt_ram_wdata,
	output wire [151:0] ov_fnp_fmt_ram_rdata,
	input i_fnp_fmt_ram_rd,

    //output 2 osm
    input   i_fnp_fifo_rd,
    output wire o_fnp_fifo_empty,
    output wire [133:0] ov_fnp_fifo_data,

    //impulse lost pkt_head_fragment
    output wire o_fnp_inport_0_lost_head, 
    output wire o_fnp_inport_1_lost_head,
    output wire o_fnp_inport_2_lost_head,
    output wire o_fnp_inport_3_lost_head,
    output wire o_fnp_inport_4_lost_head,
    output wire o_fnp_inport_5_lost_head,
    output wire o_fnp_inport_6_lost_head,
    output wire o_fnp_inport_7_lost_head,

    //impulse lost pkt_nothead_fragment
    output wire o_fnp_inport_0_lost_nothead, 
    output wire o_fnp_inport_1_lost_nothead,
    output wire o_fnp_inport_2_lost_nothead,
    output wire o_fnp_inport_3_lost_nothead,
    output wire o_fnp_inport_4_lost_nothead,
    output wire o_fnp_inport_5_lost_nothead,
    output wire o_fnp_inport_6_lost_nothead,
    output wire o_fnp_inport_7_lost_nothead,

    //fifo overflow
    output reg o_fnp_fifo_overflow,

    //pkt count
    output wire o_fnp_inpkt_pulse, 
    output reg o_fnp_outpkt_pulse
);

    //gfm 2 fifo
    wire [133:0] pkt_data_gfm2fifo;
    wire pkt_data_wr_gfm2fifo;

    //gfm 2 mlt
    wire [103:0] tuple_data_gfm2mlt;
    wire [3:0] pkt_inport_gfm2mlt;
    wire first_frag_flag_gfm2mlt;
    wire data_wr_gfm2mlt;

    wire [47:0] ov_temp_tsntag_gfm2mlt;

    wire [1:0] ov_tcp_or_udp_pkt_gfm2mlt;

    //fifo -- trm
    wire [133:0] pkt_data_fifo2trm;
    wire fifo_rd_trm2fifo;

    /*
	//mlt 2 trm
    wire [47:0] tsntag_data_mlt2trm;
    wire tsntag_wr_mlt2trm;
	*/
	
	//mlt 2 fifo_tsntag
	wire [47:0] mlt2fifo_tsntag;
	wire mlt2fifo_tsntag_wr;
	
	//trm 2 fifo_tsntag
	wire [47:0] fifo_tsntag2trm;
	wire trm2fifo_tsntag_rd;
	wire fifo_tsntag2trm_empty;
	
	
	//mlt 2 trm
	wire [3:0] pkt_fragment_seq_mlt2trm;
	wire [3:0] pkt_inport_mlt2trm;

    //trm 2 fifo
    wire [133:0] pkt_data_trm2fifo;
    wire pkt_data_wr_trm2fifo;

    //mlt -- ram(5tuple)
    wire [4:0] fmt_ram_raddr;
    wire fmt_ram_rd;
    wire [130:0] fmt_ram_rdata;

    //mlt --ram(TSNtag)
    wire [3:0] tdt_ram_waddr;
    wire tdt_ram_wr;
    wire [47:0] tdt_ram_wdata;
    wire [3:0] tdt_ram_raddr;
    wire tdt_ram_rd;
    wire [47:0] tdt_ram_rdata;

    //cim 2 ram(5tuple)
    wire [130:0] cim2ram_wdata;
	wire [130:0] ram2cim_wdata;
	
	//fifo_134_512 overflow
	wire fifo_134_512_full;

   assign cim2ram_wdata ={iv_fnp_fmt_ram_wdata[151:31], iv_fnp_fmt_ram_wdata[9:0]};
   
   assign ov_fnp_fmt_ram_rdata ={ram2cim_wdata[130:27], ram2cim_wdata[26:10], 21'b0, ram2cim_wdata[9:0]};
   
/*    always @(posedge clk or negedge rst_n) begin
       if(!rst_n)begin
            o_fnp_outpkt_pulse <=1'b0;
        end
        else begin
			if( (fifo_134_512_full ==1'b1) && (pkt_data_wr_trm2fifo ==1'b1) )begin
				o_fnp_fifo_overflow <=1'b1;
			end
			else begin
				o_fnp_fifo_overflow <=1'b0;
		    end
		end
   end
    
    //count pkt out number
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            o_fnp_outpkt_pulse <=1'b0;
        end
        else begin
            if((ov_fnp_fifo_data[133:132] ==2'b01) && (i_fnp_fifo_rd == 1'b1))begin
                o_fnp_outpkt_pulse <=1'b1;
            end
            else begin
                o_fnp_outpkt_pulse <=1'b0;
            end
        end
    end
 */
 
  always @(posedge clk or negedge rst_n) begin
       if(!rst_n)begin
            o_fnp_outpkt_pulse <=1'b0;
			o_fnp_fifo_overflow <=1'b0;
        end
        else begin
			if( (fifo_134_512_full ==1'b1) && (pkt_data_wr_trm2fifo ==1'b1) )begin
				o_fnp_fifo_overflow <=1'b1;
			end
			else begin
				o_fnp_fifo_overflow <=1'b0;
		    end
			 if((ov_fnp_fifo_data[133:132] ==2'b01) && (i_fnp_fifo_rd == 1'b1))begin //count pkt out number
                o_fnp_outpkt_pulse <=1'b1;
            end
            else begin
                o_fnp_outpkt_pulse <=1'b0;
            end
				
		end
		
   end
    

 

//***************************************************
//                  Module Instance
//***************************************************
    get_five_tuple_module   gfm_inst(
        .clk (clk),
        .rst_n (rst_n),
   
    //input
        .iv_pkt_data (iv_fnp_pkt_data),
        .i_pkt_data_wr (i_fnp_pkt_data_wr),
        .iv_pkt_inport (iv_fnp_pkt_inport), 

    //gfm 2 fifo
        .ov_pkt_data (pkt_data_gfm2fifo),
        .o_pkt_data_wr (pkt_data_wr_gfm2fifo),

    //gfm 2 mlt
        .ov_5tuple_data (tuple_data_gfm2mlt),
        .ov_pkt_inport (pkt_inport_gfm2mlt),
        .o_first_frag_flag (first_frag_flag_gfm2mlt),
        .o_data_wr (data_wr_gfm2mlt),

        .ov_temp_tsntag (ov_temp_tsntag_gfm2mlt),

        .ov_tcp_or_udp_pkt (ov_tcp_or_udp_pkt_gfm2mlt),

    //inpkt_cnt
        .o_inpkt_cnt(o_fnp_inpkt_pulse)            
    );



    map_look_up_table   mlt_inst(
        .clk (clk),
        .rst_n (rst_n),

    //gfm 2 mlt
        .iv_5tuple_data (tuple_data_gfm2mlt),
        .iv_pkt_inport (pkt_inport_gfm2mlt),
        .i_first_frag_flag (first_frag_flag_gfm2mlt),
        .i_data_wr (data_wr_gfm2mlt),

        .iv_temp_tsntag (ov_temp_tsntag_gfm2mlt),
        .iv_tcp_or_udp_pkt (ov_tcp_or_udp_pkt_gfm2mlt), 

    //mlt 2 ram(5tuple)
        .ov_fmt_ram_raddr (fmt_ram_raddr),
        .o_fmt_ram_rd (fmt_ram_rd),
        .iv_fmt_ram_rdata (fmt_ram_rdata),

    //mlt 2 ram(TSNtag)
        .ov_tdt_ram_waddr (tdt_ram_waddr),
        .o_tdt_ram_wr (tdt_ram_wr),
        .ov_tdt_ram_wdata (tdt_ram_wdata),
        .ov_tdt_ram_raddr (tdt_ram_raddr),
        .o_tdt_ram_rd (tdt_ram_rd),
        .iv_tdt_ram_rdata (tdt_ram_rdata),

    //mlt 2 tsntag_fifo
        .ov_tsntag_data (mlt2fifo_tsntag),
        .o_tsntag_wr (mlt2fifo_tsntag_wr),
		
	//mlt 2 trm	
		.ov_pkt_fragment_seq ( pkt_fragment_seq_mlt2trm ),
		.ov_pkt_inport( pkt_inport_mlt2trm )
    );

/////////////////////	

    tsntag_replace_module   trm_inst(
        .clk (clk),
        .rst_n (rst_n),

    //fifo_tsntag 2 trm
        .iv_tsn_tag_data ( fifo_tsntag2trm ),
        .fifo_tsntag_empty ( fifo_tsntag2trm_empty ),
		.fifo_tsntag_rd (trm2fifo_tsntag_rd),
		
	//mlt 2 trm	
		.iv_pkt_fragment_seq ( pkt_fragment_seq_mlt2trm ),
		.iv_pkt_inport ( pkt_inport_mlt2trm ),

    //fifo -- trm
        .iv_pkt_data (pkt_data_fifo2trm),
        .o_fifo_rd (fifo_rd_trm2fifo),

    //trm 2 fifo
        .ov_pkt_data (pkt_data_trm2fifo),
        .o_pkt_data_wr (pkt_data_wr_trm2fifo),

    //state (pkt lost_head_fragment)
        .inport_0_lost_head ( o_fnp_inport_0_lost_head ),
        .inport_1_lost_head ( o_fnp_inport_1_lost_head ),
        .inport_2_lost_head ( o_fnp_inport_2_lost_head ),
        .inport_3_lost_head ( o_fnp_inport_3_lost_head ),
        .inport_4_lost_head ( o_fnp_inport_4_lost_head ),
        .inport_5_lost_head ( o_fnp_inport_5_lost_head ),
        .inport_6_lost_head ( o_fnp_inport_6_lost_head ),
        .inport_7_lost_head ( o_fnp_inport_7_lost_head ),

    //state (pkt lost_nothead_fragment)
        .inport_0_lost_nothead ( o_fnp_inport_0_lost_nothead ),
        .inport_1_lost_nothead ( o_fnp_inport_1_lost_nothead ),
        .inport_2_lost_nothead ( o_fnp_inport_2_lost_nothead ),
        .inport_3_lost_nothead ( o_fnp_inport_3_lost_nothead ),
        .inport_4_lost_nothead ( o_fnp_inport_4_lost_nothead ),
        .inport_5_lost_nothead ( o_fnp_inport_5_lost_nothead ),
        .inport_6_lost_nothead ( o_fnp_inport_6_lost_nothead ),
        .inport_7_lost_nothead ( o_fnp_inport_7_lost_nothead )	
    );
////
    
	///*
	fifo_pkt_data_64_134   fifo_pkt_data_64_134_inst (
		.data  (pkt_data_gfm2fifo),  //  fifo_input.datain
		.wrreq (pkt_data_wr_gfm2fifo), //            .wrreq
		.rdreq (fifo_rd_trm2fifo), //            .rdreq
		.clock (clk), //            .clk
		.sclr  (!rst_n),  //            .sclr
		.q     (pkt_data_fifo2trm),     // fifo_output.dataout
		.usedw ( ), //            .usedw
		.full  (full),  //            .full
		.empty (empty)  //            .empty
	);
	//*/
	
	
	fifo_134_512  fifo_pkt_data_512_134_inst(
        .data  (pkt_data_trm2fifo),  //  fifo_input.datain
		.wrreq (pkt_data_wr_trm2fifo), //            .wrreq
		.rdreq (i_fnp_fifo_rd), //            .rdreq(ack)
		.clock (clk), //            .clk
		.q     (ov_fnp_fifo_data),     // fifo_output.dataout
		.usedw ( ), //            .usedw
		.full  (fifo_134_512_full),  //            .full
		.empty (o_fnp_fifo_empty)  //            .empty     
    );

  

	ram_5tuple_32_131    ram_5tuple_32_131_inst (
		.data_a    (cim2ram_wdata),    //  ram_input.datain_a
		.data_b    (134'b0),    //           .datain_b
		.address_a (iv_fnp_fmt_ram_addr), //           .address_a
		.address_b (fmt_ram_raddr), //           .address_b
		.wren_a    (i_fnp_fmt_ram_wr),    //           .wren_a
		.wren_b    (1'b0),    //           .wren_b
		.clock     (clk),     //           .clock
		.rden_a    (i_fnp_fmt_ram_rd),    //           .rden_a
		.rden_b    (fmt_ram_rd),    //           .rden_b
		.q_a       (ram2cim_wdata),       // ram_output.dataout_a
		.q_b       (fmt_ram_rdata)        //           .dataout_b
	);
	
	
	
	ram_tsntag_8_48  ram_tsntag_8_48_inst (
		.data      (tdt_ram_wdata),      //  ram_input.datain
		.wraddress (tdt_ram_waddr), //           .wraddress
		.rdaddress (tdt_ram_raddr), //           .rdaddress
		.wren      (tdt_ram_wr),      //           .wren
		.clock     (clk),     //           .clock
		.rden      (tdt_ram_rd),      //           .rden
		.q         (tdt_ram_rdata)          // ram_output.dataout
	);
	
	fifo_tsntag_4_48 fifo_tsntag_4_48_inst (
		.data  (mlt2fifo_tsntag),  //  fifo_input.datain
		.wrreq (mlt2fifo_tsntag_wr), //            .wrreq
		.rdreq (trm2fifo_tsntag_rd), //            .rdreq(ack)
		.clock (clk), //            .clk
		.q     (fifo_tsntag2trm),     // fifo_output.dataout
		.usedw ( ), //            .usedw
		.full  ( ),  //            .full
		.empty (fifo_tsntag2trm_empty)  //            .empty     
	);

endmodule