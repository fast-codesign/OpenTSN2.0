// Copyright (C) 1953-2020 NUDT
// Verilog module name - output_schedule_module 
// Version: GAH_V1.0
// Created:
//         by - Shangming Wu  guangming836@163.com
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         1.The code of osm.
//         2.Output Schedule Module.
//		   3.More information in Doc.
///////////////////////////////////////////////////////////////////////////

 
module output_schedule_module #(
    parameter PLATFORM="hcp")
(
    input clk,
    input rst_n,
	
	input [6:0] iv_fifo_usedw,

    //fnp_fifo 2 osm
    output reg o_fnp_fifo_rd,
    input i_fnp_fifo_empty,
    input [133:0] iv_fnp_fifo_data,

    //lnp_fifo 2 osm
    output reg o_lnp_fifo_rd,
    input i_lnp_fifo_empty,
    input [133:0] iv_lnp_fifo_data,


//////////////////////////////////
    //mux2fifo 2 osm
    output reg o_mux2fifo_rd,
    input i_mux2fifo_empty,
    input [133:0] iv_mux2fifo_data,

    //srm2fifo 2 osm
    output reg o_srm2fifo_rd,
    input i_srm2fifo_empty,
    input [133:0] iv_srm2fifo_data,


    //output
    output reg [133:0] ov_pkt_data,
    output reg o_pkt_data_wr
);

    reg [3:0] osm_state;
    
    reg [3:0] fnp_data_read;
    reg [3:0] lnp_data_read;
    reg [3:0] mux2fifo_data_read;
    reg [3:0] srm2fifo_data_read;

    localparam  READ_FNP_DATA_S =4'd0,
				FNP_DATA_S =4'd1,
				READ_FNP_FINISH_S =4'd2,
				
				READ_LNP_DATA_S =4'd3,
                LNP_DATA_S =4'd4,
				READ_LNP_FINISH_S =4'd5,
				
				READ_MUX2FIFO_DATA_S =4'd6,
                MUX2FIFO_DATA_S =4'd7,
				READ_MUX2FIFO_FINISH_S =4'd8,
				
				READ_SRM2FIFO_DATA_S =4'd9,
                SRM2FIFO_DATA_S =4'd10,
				READ_SRM2FIFO_FINISH_S =4'd11;


    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            o_fnp_fifo_rd <=1'b0;
            o_lnp_fifo_rd <=1'b0;
            o_mux2fifo_rd <=1'b0;
            o_srm2fifo_rd <=1'b0;
			
			ov_pkt_data <=134'b0;
			o_pkt_data_wr <=1'b0;

            fnp_data_read <=4'd0;
            lnp_data_read <=4'd0;
            mux2fifo_data_read <=4'd0;
            srm2fifo_data_read <=4'd0;
            osm_state <=FNP_DATA_S;
        end
        else begin
            case(osm_state)
                READ_FNP_DATA_S:begin
				    //fnp_data_read <= 4'd0;
					if(iv_fnp_fifo_data[133:132]!=2'b10)begin
						ov_pkt_data <=iv_fnp_fifo_data;
						o_pkt_data_wr <=1'b1;

						o_fnp_fifo_rd <=1'b1;
                             
						osm_state <= READ_FNP_DATA_S;
				    end
					else begin
						ov_pkt_data <=iv_fnp_fifo_data;
						o_pkt_data_wr <=1'b1;

						o_fnp_fifo_rd <=1'b0;
						fnp_data_read <= 4'd0;
						osm_state <= READ_FNP_FINISH_S;
					end					
				end
				
				
				FNP_DATA_S:begin
				    if(iv_fifo_usedw <=7'd20)begin
						if(i_fnp_fifo_empty ==1'b0)begin
							if(fnp_data_read ==4'd0)begin
								o_fnp_fifo_rd <=1'b1;
								fnp_data_read <= fnp_data_read +4'd1;
								osm_state <= READ_FNP_DATA_S;
							end
							else  begin 
								osm_state <= FNP_DATA_S;
							end
						end
						else begin
							osm_state <= LNP_DATA_S;
						end
					end
					else begin
						osm_state <= LNP_DATA_S;
					end
                end
				
				READ_FNP_FINISH_S:begin
					ov_pkt_data <=134'b0;
					o_pkt_data_wr <=1'b0;
					osm_state <= LNP_DATA_S;
				end
			//////////////////////////////////////////////////////////////////////	

				READ_LNP_DATA_S:begin
					if(iv_lnp_fifo_data[133:132]!=2'b10)begin
						ov_pkt_data <=iv_lnp_fifo_data;
						o_pkt_data_wr <=1'b1;

						o_lnp_fifo_rd <=1'b1;
                             
						osm_state <= READ_LNP_DATA_S;
					end
					else begin
						ov_pkt_data <=iv_lnp_fifo_data;
						o_pkt_data_wr <=1'b1;

						o_lnp_fifo_rd <=1'b0;
						lnp_data_read <= 4'd0;
						osm_state <= READ_LNP_FINISH_S;
					end		
				end
				
				
                LNP_DATA_S:begin
				    if(iv_fifo_usedw <=7'd20)begin
						if(i_lnp_fifo_empty ==1'b0)begin
							if(lnp_data_read ==4'd0)begin
								o_lnp_fifo_rd <=1'b1;
								lnp_data_read <= lnp_data_read +4'd1;
								osm_state <= READ_LNP_DATA_S;
							end
							else begin
								osm_state <= LNP_DATA_S;
							end
						end
						else begin
							osm_state <= MUX2FIFO_DATA_S;
						end
					end
					else begin
						osm_state <=  MUX2FIFO_DATA_S;
					end
                end
				
				READ_LNP_FINISH_S:begin
					ov_pkt_data <=134'b0;
					o_pkt_data_wr <=1'b0;
					osm_state <= MUX2FIFO_DATA_S;
				end
				/////////////////////////////////////////////////////////////////////////////
				
				READ_MUX2FIFO_DATA_S:begin
					//mux2fifo_data_read <= 4'd0;
					if(iv_mux2fifo_data[133:132]!=2'b10)begin
						ov_pkt_data <=iv_mux2fifo_data;
						o_pkt_data_wr <=1'b1;

						o_mux2fifo_rd <=1'b1;
                             
						osm_state <= READ_MUX2FIFO_DATA_S;
					end
					else begin
						ov_pkt_data <=iv_mux2fifo_data;
						o_pkt_data_wr <=1'b1;

						o_mux2fifo_rd <=1'b0;
						mux2fifo_data_read <= 4'd0;
						osm_state <= READ_MUX2FIFO_FINISH_S;
					end		
				end
				
			   
                MUX2FIFO_DATA_S:begin
					if(iv_fifo_usedw <=7'd20)begin
						if(i_mux2fifo_empty ==1'b0)begin
							if(mux2fifo_data_read ==4'd0)begin
								o_mux2fifo_rd <=1'b1;
								mux2fifo_data_read <= mux2fifo_data_read +4'd1;
								osm_state <= READ_MUX2FIFO_DATA_S;
							end
							else begin
								osm_state <= MUX2FIFO_DATA_S;
							end
						end
						else begin
							osm_state <= SRM2FIFO_DATA_S;
						end 
					end
					else begin
						osm_state <= SRM2FIFO_DATA_S;
					end
                end
				
				READ_MUX2FIFO_FINISH_S:begin
					ov_pkt_data <=134'b0;
					o_pkt_data_wr <=1'b0;
					osm_state <= SRM2FIFO_DATA_S;
				end
	
				///////////////////////////////////////////////////////////////////////////////////////////	
				READ_SRM2FIFO_DATA_S:begin
					if(iv_srm2fifo_data[133:132]!=2'b10)begin
						ov_pkt_data <=iv_srm2fifo_data;
						o_pkt_data_wr <=1'b1;

						o_srm2fifo_rd <=1'b1;
                             
						osm_state <= READ_SRM2FIFO_DATA_S;
					end
					else begin
						ov_pkt_data <=iv_srm2fifo_data;
						o_pkt_data_wr <=1'b1;

						o_srm2fifo_rd <=1'b0;
						srm2fifo_data_read <= 4'd0;
						osm_state <= READ_SRM2FIFO_FINISH_S;
					end	
				end

                SRM2FIFO_DATA_S:begin
					if(iv_fifo_usedw <=7'd20)begin	
						if(i_srm2fifo_empty ==1'b0)begin
							if(srm2fifo_data_read ==4'd0)begin
								o_srm2fifo_rd <=1'b1;
								srm2fifo_data_read <= srm2fifo_data_read +4'd1;
								osm_state <= READ_SRM2FIFO_DATA_S;
							end
							else begin
								osm_state <= SRM2FIFO_DATA_S;
							end
						end
						else begin
							osm_state <= FNP_DATA_S;
						end 
     				end
					else begin
						osm_state <= FNP_DATA_S;
					end
				end
				
				READ_SRM2FIFO_FINISH_S:begin
					ov_pkt_data <=134'b0;
					o_pkt_data_wr <=1'b0;
					osm_state <= FNP_DATA_S;
				end
				
            endcase
        end
    end
endmodule
