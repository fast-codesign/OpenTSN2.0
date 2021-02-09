// Copyright (C) 1953-2020 NUDT
// Verilog module name - pkt_write 
// Version: PWR_V1.0
// Created:
//         by - fenglin
//         at - 06.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         Pkt Write
//             - xxx: xxx
///////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "./rtl/hcp/hcp_macro_define.v"

module packet_centralized_buffer(
	clk_sys,
	reset_n,
	// pkt_write
	pkt_ram_wdata,
	pkt_ram_wr,
	pkt_ram_waddr,
	//pkt read
	pkt_ram_rdata,
	pkt_ram_rd,
	pkt_ram_raddr,	
	//bufid write
	bufid_free_req,
	bufid_free_req_wr,
	bufid_free_req_ack,
	//bufid read
	bufid_allocate,
	bufid_allocate_wr,
	bufid_allocate_ack,
    initial_finish
	);
input					clk_sys;
input					reset_n;
	// pkt_write
input		[133:0]		pkt_ram_wdata;
input					pkt_ram_wr;
input		[11:0]		pkt_ram_waddr;
	//pkt read
output wire [133:0]		pkt_ram_rdata;
input					pkt_ram_rd;
input		[11:0]		pkt_ram_raddr;	
	//bufid write
input		[8:0]		bufid_free_req;
input					bufid_free_req_wr;
output	reg				bufid_free_req_ack;
	//bufid read
output	reg	[8:0]		bufid_allocate;
output	reg				bufid_allocate_wr;
input					bufid_allocate_ack;

output	reg	    		initial_finish;
//internal register of fifo
reg			[8:0]		bufid_wr_into_fifo;
reg						bufid_wr_into_fifo_wr;
wire		[8:0]		bufid_rd_from_fifo;
reg						bufid_rd_from_fifo_rd;
wire					bufid_of_fifo_full;
wire					bufid_of_fifo_empty;		
wire		[8:0]   	ov_free_buf_fifo_rdusedw;

reg			[8:0]		bufid_of_fifo_initial_cnt;

reg			[2:0]		bufid_read_state;
reg			[1:0]		bufid_write_state;

localparam				initial_s			= 3'd0,
						bufid_wr_s			= 3'd1,
                        bufid_ack_s         = 3'd2,
						bufid_rd_s			= 3'd3,
						bufid_rd_wait_s		= 3'd4,
						bufid_rd_sucess_s	= 3'd5;

always @(posedge clk_sys or negedge reset_n)
	if(!reset_n) begin
		bufid_free_req_ack			<=	1'b0;
		
		
		bufid_wr_into_fifo			<=	9'b0;
		bufid_wr_into_fifo_wr		<=	1'b0;
		
		
		bufid_of_fifo_initial_cnt	<=	9'd1;
        initial_finish              <= 1'b0;
		bufid_write_state			<=	2'b0;
	end
	else begin
		case(bufid_write_state)
			initial_s: begin
				bufid_wr_into_fifo		<=	bufid_of_fifo_initial_cnt;
				bufid_wr_into_fifo_wr	<=	1'b1;
				if(bufid_of_fifo_initial_cnt < (`bufid_num-1))begin			
					bufid_of_fifo_initial_cnt	<=	bufid_of_fifo_initial_cnt + 9'd1;
                    initial_finish              <= 1'b0;
					bufid_write_state			<=	initial_s;
				end
				else begin
					bufid_of_fifo_initial_cnt	<=	bufid_of_fifo_initial_cnt;
                    initial_finish              <= 1'b1;
					bufid_write_state			<=	bufid_wr_s;
				end
			end
			bufid_wr_s:begin
				if(bufid_free_req_wr == 1'b1) begin
					bufid_wr_into_fifo		<=	bufid_free_req;
					bufid_wr_into_fifo_wr	<=	1'b1;
					bufid_free_req_ack		<=	1'b1;
                    bufid_write_state	    <=	bufid_ack_s;
				end
				else begin
					bufid_wr_into_fifo		<=	bufid_wr_into_fifo;
					bufid_wr_into_fifo_wr	<=	1'b0;
					bufid_free_req_ack		<=	1'b0;
                    bufid_write_state		<=	bufid_wr_s;
				end	
			end
 			bufid_ack_s:begin
                bufid_free_req_ack		<=	1'b0;
                bufid_write_state	    <=	bufid_wr_s;
			end           
		endcase
	end
	
	
	always @(posedge clk_sys or negedge reset_n)
	if(!reset_n) begin
		bufid_allocate				<=	9'b0;
		bufid_allocate_wr			<=	1'b0;
		bufid_rd_from_fifo_rd		<=	9'b0;
		bufid_read_state			<=	3'b0;
	end
	else begin
		case (bufid_read_state)
			initial_s:begin
				bufid_allocate		<=	9'd0;
				bufid_allocate_wr	<=	1'b1;
				bufid_read_state	<=	bufid_rd_s;
			end
			bufid_rd_s:begin
				if(bufid_allocate_ack == 1'b1) begin
					bufid_allocate_wr		<= 1'b0;
					bufid_rd_from_fifo_rd	<= 1'b1;
					bufid_read_state		<= bufid_rd_wait_s;
				end
				else begin
					bufid_allocate_wr		<= 1'b1;
					bufid_rd_from_fifo_rd	<= 1'b0;
					bufid_read_state		<= bufid_rd_s;
				end
			end
			bufid_rd_wait_s:begin
				bufid_rd_from_fifo_rd	<= 1'b0;
				bufid_read_state		<= bufid_rd_sucess_s;
			end
			bufid_rd_sucess_s: begin
				bufid_allocate		<=	bufid_rd_from_fifo;
				bufid_allocate_wr	<=	1'b1;
				bufid_read_state	<=	bufid_rd_s;
			end
		endcase
	end

	ram_134_4096 ram_134_4096_inst(
		.clock		(clk_sys				),	//ASYNC WriteClk, SYNC use wrclk
		.data		(pkt_ram_wdata			),	//RAM input data
		.rdaddress	(pkt_ram_raddr		),	//RAM read address
		.rden		(pkt_ram_rd			),	//RAM read request
		.wraddress	(pkt_ram_waddr		),	//RAM write address
		.wren		(pkt_ram_wr			),	//RAM write request
		.q			(pkt_ram_rdata			)	//RAM output data
	);
	
	SFIFO_9_512  SFIFO_9_512_inst
	(
		.aclr(!reset_n),					//Reset the all signal(active high)
		.data(bufid_wr_into_fifo),				//The Inport of data 
		.rdreq(bufid_rd_from_fifo_rd),		//active-high
		.clk(clk_sys),						//ASYNC WriteClk, SYNC use wrclk
		.wrreq(bufid_wr_into_fifo_wr),		//active-high
		.q(bufid_rd_from_fifo),				//The output of data
		.wrfull(bufid_of_fifo_full),	//Write domain full	
		.rdempty(bufid_of_fifo_empty),	//Read domain empty
        
        .wralfull(),	
        .wrempty(),	
        .wralempty(),	
        .rdfull(),		
        .rdalfull(),	
        .rdalempty(),	
        .wrusedw(),	
        .rdusedw(ov_free_buf_fifo_rdusedw)  
	);
endmodule