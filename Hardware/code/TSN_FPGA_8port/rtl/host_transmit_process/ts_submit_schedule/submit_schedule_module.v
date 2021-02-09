// Copyright (C) 1953-2020 NUDT
// Verilog module name - submit_schedule_module 
// Version: SSM_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         schedule descriptor of time-sensitive packet
//             - use a true dual port ram to cache submit slot table; 
//             - schedule descriptor of time-sensitive packet 
//               according to submit slot table and time slot.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module submit_schedule_module
(
       i_clk,
       i_rst_n,
       iv_cfg_finish,
       
       iv_time_slot,
       i_time_slot_switch,
       
       iv_submit_slot_table_wdata,
       i_submit_slot_table_wr,
       iv_submit_slot_table_addr,
       
       ov_submit_slot_table_rdata,
       i_submit_slot_table_rd,
       
       i_ts_submit_addr_ack,
       ov_ts_submit_addr,
       o_ts_submit_addr_wr,

       ssm_state       
);
// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;
//configuration finish and time synchronization finish
input      [1:0]       iv_cfg_finish;   
// writting/reading data to ram
input      [15:0]      iv_submit_slot_table_wdata;
input                  i_submit_slot_table_wr;
input      [9:0]       iv_submit_slot_table_addr;
output    [15:0]       ov_submit_slot_table_rdata;
input                  i_submit_slot_table_rd;
// current time slot
input      [9:0]       iv_time_slot;
input                  i_time_slot_switch;
// result of schedule
output reg [4:0]       ov_ts_submit_addr;
output reg             o_ts_submit_addr_wr;
// TIM get ts_submit_addr 
input                  i_ts_submit_addr_ack;  

//***************************************************
//   schedule descriptor of time-sensitive packet
//***************************************************
// internal reg&wire for state machine
wire       [15:0]      wv_ram_portb_rdata;
reg                    r_ram_portb_rd;
reg        [9:0]       rv_ram_portb_addr;

output reg        [2:0]       ssm_state;
localparam  WAIT_CFG_FINISH_S = 3'd0,
            PORTB_IDLE_S = 3'd1,
            PORTB_WAIT_FIRST_S = 3'd2,
            PORTB_WAIT_SECOND_S = 3'd3, 
            PORTB_GET_DATA_S = 3'd4,
            PORTB_WAIT_SCHEDULE_S = 3'd5,
            PORTB_WAIT_ACK_S = 3'd6,
            WAIT_NEXT_SLOT_S = 3'd7;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_ram_portb_addr <= 10'b0;
        r_ram_portb_rd <= 1'b0;
        
        o_ts_submit_addr_wr <= 1'b0;
        ov_ts_submit_addr <= 5'b0;
        ssm_state <= WAIT_CFG_FINISH_S;
    end
    else begin
        case(ssm_state)
            WAIT_CFG_FINISH_S:begin
                if(iv_cfg_finish == 2'd3)begin//configuration finish and time synchronization finish.
                   ssm_state <= PORTB_IDLE_S; 
                end
                else begin
                   ssm_state <= WAIT_CFG_FINISH_S; 
                end
            end        
            PORTB_IDLE_S:begin
                ov_ts_submit_addr <= 5'b0;
                o_ts_submit_addr_wr <= 1'b0;
                
                rv_ram_portb_addr <= rv_ram_portb_addr;//rv_ram_portb_addr need add 1 after each schedule;submit_slot_table_raddr can't asset 0 in IDLE_S.
                r_ram_portb_rd <= 1'b1;
                
                ssm_state <= PORTB_WAIT_FIRST_S;
            end
            PORTB_WAIT_FIRST_S:begin  //get data after 2 cycles
                r_ram_portb_rd <= 1'b1;
                rv_ram_portb_addr <= rv_ram_portb_addr;
                
                ssm_state <= PORTB_WAIT_SECOND_S;
            end
            PORTB_WAIT_SECOND_S:begin
                r_ram_portb_rd <= 1'b1;
                rv_ram_portb_addr <= rv_ram_portb_addr;
                
                ssm_state <= PORTB_GET_DATA_S;
            end
            PORTB_GET_DATA_S:begin
                r_ram_portb_rd <= 1'b0;
                if(wv_ram_portb_rdata[15] == 1'b1)begin  //the entry is valid.
                    rv_ram_portb_addr <= rv_ram_portb_addr + 1'b1;//next address of reading entry from ram.
                    if(wv_ram_portb_rdata[14:5] == iv_time_slot)begin//time slot in the entry is current time slot;output ts_submit_addr in the entry. 
                        ov_ts_submit_addr <= wv_ram_portb_rdata[4:0];
                        o_ts_submit_addr_wr <= 1'b1;
                        
                        ssm_state <= PORTB_WAIT_ACK_S;
                    end
                    else begin//time slot in the entry isn't current time slot;wait until time slot in the entry is current time slot. 
                        ssm_state <= PORTB_WAIT_SCHEDULE_S;                 
                    end
                end
                else begin //the entry is invalid;read the first entry of submit slot table.
                    rv_ram_portb_addr <= 5'b0;  //read the first entry of submit slot table.
                    ssm_state <= WAIT_NEXT_SLOT_S;
                end
            end
            PORTB_WAIT_SCHEDULE_S:begin//wait until time slot in the entry is current time slot. 
                if(wv_ram_portb_rdata[14:5] == iv_time_slot)begin
                    ov_ts_submit_addr <= wv_ram_portb_rdata[4:0];
                    o_ts_submit_addr_wr <= 1'b1;
                        
                    ssm_state <= PORTB_WAIT_ACK_S;
                end
                else begin
                    ssm_state <= PORTB_WAIT_SCHEDULE_S;                 
                end
            end 
            PORTB_WAIT_ACK_S:begin//start next schedule after ts_submit_management_module get the ts submit address
                if(i_ts_submit_addr_ack == 1'b1)begin
                    ov_ts_submit_addr <= 5'd0;
                    o_ts_submit_addr_wr <= 1'b0;
                    ssm_state <= PORTB_IDLE_S;
                end
                else begin
                    ssm_state <= PORTB_WAIT_ACK_S;                  
                end         
            end
            WAIT_NEXT_SLOT_S:begin
                if(i_time_slot_switch)begin
                    ssm_state <= PORTB_IDLE_S;
                end
                else begin
                    ssm_state <= WAIT_NEXT_SLOT_S;
                end
            end            
            default:begin
                ov_ts_submit_addr <= 5'b0;
                o_ts_submit_addr_wr <= 1'b0;
        
                r_ram_portb_rd <= 1'b0;
        
                ssm_state <= PORTB_IDLE_S;
            end
        endcase
   end
end 
    
suhddpsram1024x16_rq submit_slot_table_buffer
(      
        .aclr(!i_rst_n),    
        .data_a(iv_submit_slot_table_wdata),    //ram_input.datain_a
        .data_b(16'b0),                         //.datain_b
        .address_a(iv_submit_slot_table_addr),  //.address_a
        .address_b(rv_ram_portb_addr),          //.address_b
        .wren_a(i_submit_slot_table_wr),        //.wren_a
        .wren_b(1'b0),                          //.wren_b
        .clock(i_clk),                          //.clock
        .rden_a(i_submit_slot_table_rd),        //.rden_a
        .rden_b(r_ram_portb_rd),                //.rden_b
        .q_a(ov_submit_slot_table_rdata),       //ram_output.dataout_a
        .q_b(wv_ram_portb_rdata)                //.dataout_b
);                   
endmodule