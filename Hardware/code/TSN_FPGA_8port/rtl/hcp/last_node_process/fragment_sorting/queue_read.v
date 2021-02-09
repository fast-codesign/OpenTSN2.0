// Copyright (C) 1953-2020 NUDT
// Verilog module name - FSM
// Version: FSM_V1.0
// Created:
//         by - fenglin
//         at - 08.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         read all fragement of a packet.
//             - read flowid to lookup table; 
//             - write packet to ram;
//             - write last_frag_flag & bufid to ram;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module queue_read
(
       i_clk,
       i_rst_n,
       
       ov_queue_id_free,
	   o_queue_id_free_wr,
       iv_queue_empty,
       
       iv_queue_ram_rdata,
       o_queue_ram_rd,
       ov_queue_ram_raddr,
	   
	   ov_bufid,
	   o_bufid_wr,
       i_pkt_last_cycle_valid
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// free queue id
output reg  [4:0]	   ov_queue_id_free;
output reg	           o_queue_id_free_wr;

input       [31:0]     iv_queue_empty;
// read bufid & last_frag_flag
input       [9:0]      iv_queue_ram_rdata;
output reg      	   o_queue_ram_rd;
output reg	[8:0]      ov_queue_ram_raddr;
//queue data output
output reg  [8:0]	   ov_bufid;
output reg             o_bufid_wr;

input                  i_pkt_last_cycle_valid;
//***************************************************
//                 read queue 
//***************************************************  
reg		   [4:0]		rv_read_queue;
reg		        		r_last_frag_flag;
reg		   [2:0]		queue_read_state;
localparam			    PKT_READ_IDLE_S = 3'd0,
                        READ_QUEUE_S = 3'd1,
						WAIT_FIRST_S   = 3'd2,
						WAIT_SECOND_S = 3'd3,
                        GET_DATA_S = 3'd4,
                        PKT_TRANS_S = 3'd5;
always @(posedge i_clk or negedge i_rst_n) begin
	if(i_rst_n == 1'b0)begin
		ov_queue_ram_raddr <= 9'h0;
		o_queue_ram_rd <= 1'b0;
        
        rv_read_queue <= 5'b0;
        ov_queue_id_free <= 5'b0;
        o_queue_id_free_wr<=1'b0;
        
        ov_bufid <= 9'b0;
        o_bufid_wr <= 1'b0;
        
        r_last_frag_flag <= 1'b0;
		queue_read_state <= PKT_READ_IDLE_S;
	end
	else begin
		case(queue_read_state)
			PKT_READ_IDLE_S:begin 
                ov_queue_id_free <= 5'b0;
                o_queue_id_free_wr <= 1'b0;
				casex(iv_queue_empty)
                    32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_xxxxxxx0:begin
                        ov_queue_ram_raddr <= {5'h00,4'b0};
                        o_queue_ram_rd <= 1'b1;
                        rv_read_queue <= 5'd0;
                        queue_read_state <= WAIT_FIRST_S;
                    end
                    32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_xxxxxx01:begin
                        ov_queue_ram_raddr <= {5'h01,4'b0};
                        o_queue_ram_rd <= 1'b1;   
                        rv_read_queue <= 5'd1;
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_xxxxx011:begin
                        ov_queue_ram_raddr <= {5'h02,4'b0};
                        o_queue_ram_rd <= 1'b1;  
                        rv_read_queue <= 5'd2;
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_xxxx0111:begin
                        ov_queue_ram_raddr <= {5'h03,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd3;
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_xxx01111:begin
                        ov_queue_ram_raddr <= {5'h04,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd4;
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_xx011111:begin
                        ov_queue_ram_raddr <= {5'h05,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd5;
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_x0111111:begin
                        ov_queue_ram_raddr <= {5'h06,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd6;
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xxxxxxxx_01111111:begin
                        ov_queue_ram_raddr <= {5'h07,4'b0};
                        o_queue_ram_rd <= 1'b1;                         
                        rv_read_queue <= 5'd7;
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xxxxxxx0_11111111:begin
                        ov_queue_ram_raddr <= {5'h08,4'b0};
                        o_queue_ram_rd <= 1'b1;
                        rv_read_queue <= 5'd8;
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xxxxxx01_11111111:begin
                        ov_queue_ram_raddr <= {5'h09,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd9;
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xxxxx011_11111111:begin
                        ov_queue_ram_raddr <= {5'h0a,4'b0};
                        o_queue_ram_rd <= 1'b1;
                        rv_read_queue <= 5'd10;                        
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xxxx0111_11111111:begin
                        ov_queue_ram_raddr <= {5'h0b,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd11;
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xxx01111_11111111:begin
                        ov_queue_ram_raddr <= {5'h0c,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd12;
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_xx011111_11111111:begin
                        ov_queue_ram_raddr <= {5'h0d,4'b0};
                        o_queue_ram_rd <= 1'b1;
                        rv_read_queue <= 5'd13;                        
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_x0111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h0e,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd14; 
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxxx_01111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h0f,4'b0};
                        o_queue_ram_rd <= 1'b1;
                        rv_read_queue <= 5'd15;                         
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxxx0_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h10,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd16; 
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxxx01_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h11,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd17; 
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxxx011_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h12,4'b0};
                        o_queue_ram_rd <= 1'b1;
                        rv_read_queue <= 5'd18;                         
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxxx0111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h13,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd19; 
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xxx01111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h14,4'b0};
                        o_queue_ram_rd <= 1'b1;
                        rv_read_queue <= 5'd20;                         
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_xx011111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h15,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd21; 
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_x0111111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h16,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd22; 
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxxx_01111111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h17,4'b0};
                        o_queue_ram_rd <= 1'b1;
                        rv_read_queue <= 5'd23;                        
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxxx0_11111111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h18,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd24; 
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxxx01_11111111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h19,4'b0};
                        o_queue_ram_rd <= 1'b1;
                        rv_read_queue <= 5'd25;  
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxxx011_11111111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h1a,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd26; 
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxxx0111_11111111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h1b,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd27; 
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'bxxx01111_11111111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h1c,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd28; 
                        queue_read_state <= WAIT_FIRST_S;
                    end
                    32'bxx011111_11111111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h1d,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd29; 
                        queue_read_state <= WAIT_FIRST_S;
                    end  
                    32'bx0111111_11111111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h1e,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd30; 
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'b01111111_11111111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h1f,4'b0};
                        o_queue_ram_rd <= 1'b1; 
                        rv_read_queue <= 5'd31; 
                        queue_read_state <= WAIT_FIRST_S;
                    end 
                    32'b11111111_11111111_11111111_11111111:begin
                        ov_queue_ram_raddr <= {5'h00,4'b0};
                        o_queue_ram_rd <= 1'b0;
                        rv_read_queue <= 5'd0;  
                        queue_read_state <= PKT_READ_IDLE_S;
                    end
                    default:begin  
                        ov_queue_ram_raddr <= {5'h00,4'b0};
                        o_queue_ram_rd <= 1'b0; 
                        rv_read_queue <= 5'd0;                         
                        queue_read_state <= PKT_READ_IDLE_S;
                    end
                endcase                    
			end
            READ_QUEUE_S:begin
                ov_queue_ram_raddr <= ov_queue_ram_raddr + 1'b1;
                o_queue_ram_rd <= 1'b1;                    
                queue_read_state <= WAIT_FIRST_S;            
            end
			WAIT_FIRST_S:begin 
                o_queue_ram_rd <= 1'b0;
                queue_read_state <= WAIT_SECOND_S;
			end
			WAIT_SECOND_S:begin
                o_queue_ram_rd <= 1'b0;
                queue_read_state <= GET_DATA_S;
			end	
			GET_DATA_S:begin
                ov_bufid <= iv_queue_ram_rdata[8:0];
                o_bufid_wr <= 1'b1; 
                queue_read_state <= PKT_TRANS_S;
				if(iv_queue_ram_rdata[9] == 1'b1)begin//last fragment
				    r_last_frag_flag <= 1'b1;
                    
                    ov_queue_id_free <= rv_read_queue;
                    o_queue_id_free_wr<=1'b1;
				end
				else begin
                    r_last_frag_flag <= 1'b0;
                
                    ov_queue_id_free <= 5'b0;
                    o_queue_id_free_wr<=1'b0;
				end
			end
            PKT_TRANS_S:begin            
                ov_bufid <= 9'b0;
                o_bufid_wr <= 1'b0;
                ov_queue_id_free <= 5'b0;
                o_queue_id_free_wr<=1'b0;                
                if(i_pkt_last_cycle_valid == 1'b1)begin
                    if(r_last_frag_flag)begin
                        queue_read_state	<= PKT_READ_IDLE_S;
                    end
                    else begin
                        queue_read_state	<= READ_QUEUE_S;
                    end
                end
                else begin
                    queue_read_state	<= PKT_TRANS_S;
                end
            end			
			default:begin
				queue_read_state <= PKT_READ_IDLE_S;		
			end
		endcase
	end
end
endmodule