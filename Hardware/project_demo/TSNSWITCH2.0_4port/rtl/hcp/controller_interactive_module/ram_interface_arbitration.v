// Copyright (C) 1953-2020 NUDT
// Verilog module name - ram_interface_arbitration
// Version: ram_interface_arbitration_V1.0
// Created:
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         arbitration of read and write of ram.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module ram_interface_arbitration
(
       i_clk,
       i_rst_n,
       
       iv_5tuple_ram_wdata,
       iv_5tuple_ram_waddr,
       i_5tuple_ram_wr,

       iv_regroup_ram_wdata,
       iv_regroup_ram_waddr,
       i_regroup_ram_wr,
       
       //ov_5tuple_ram_rdata,
       iv_5tuple_ram_raddr,
       i_5tuple_ram_rd,
       
       //ov_regroup_ram_rdata,
       iv_regroup_ram_raddr,
       i_regroup_ram_rd,
       
       ov_5tuple_ram_addr,
       ov_5tuple_ram_wdata,
       o_5tuple_ram_wr,       
       //iv_5tuple_ram_rdata,
       o_5tuple_ram_rd,
       
       ov_regroup_ram_addr,
       ov_regroup_ram_wdata,
       o_regroup_ram_wr,
       //iv_regroup_ram_rdata,
       o_regroup_ram_rd,
       
       o_5tupleram_read_write_conflict,
       o_regroupram_read_write_conflict
);

// I/O
// i_clk & rst
input                  i_clk;
input                  i_rst_n;
// configurate 5tuple mapping table & regroup mapping table
input      [151:0]     iv_5tuple_ram_wdata;
input      [4:0]       iv_5tuple_ram_waddr;
input                  i_5tuple_ram_wr;

input      [70:0]      iv_regroup_ram_wdata;
input      [7:0]       iv_regroup_ram_waddr;
input                  i_regroup_ram_wr;
// report 5tuple mapping table & regroup mapping table
//output reg [151:0]     ov_5tuple_ram_rdata;
input      [4:0]       iv_5tuple_ram_raddr;
input                  i_5tuple_ram_rd;

//output reg [56:0]      ov_regroup_ram_rdata;
input      [7:0]       iv_regroup_ram_raddr;
input                  i_regroup_ram_rd;
// arbitration of read and write of ram
output reg [4:0]       ov_5tuple_ram_addr;
output reg [151:0]     ov_5tuple_ram_wdata;
output reg             o_5tuple_ram_wr;
//input      [151:0]     iv_5tuple_ram_rdata;
output reg             o_5tuple_ram_rd;

output reg [7:0]       ov_regroup_ram_addr;
output reg [70:0]      ov_regroup_ram_wdata;
output reg             o_regroup_ram_wr;
//input      [56:0]      iv_regroup_ram_rdata;
output reg             o_regroup_ram_rd;

output reg             o_5tupleram_read_write_conflict;
output reg             o_regroupram_read_write_conflict;

//***************************************************
//    arbitration of read and write of 5tuple_ram
//***************************************************
reg             r_5tupleram_read_write_conflict_0;
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        //ov_5tuple_ram_rdata <= 152'b0;
                          
        ov_5tuple_ram_addr <=  5'b0;
        ov_5tuple_ram_wdata <=  152'b0;
        o_5tuple_ram_wr <=  1'b0;
        o_5tuple_ram_rd <=  1'b0;
        
        r_5tupleram_read_write_conflict_0 <= 1'b0;
    end
    else begin
        if((i_5tuple_ram_wr == 1'b1) && (i_5tuple_ram_rd == 1'b1))begin//read and write at the same time.write first.
            ov_5tuple_ram_addr <=  iv_5tuple_ram_waddr;
            ov_5tuple_ram_wdata <=  iv_5tuple_ram_wdata;
            o_5tuple_ram_wr <=  1'b1;
            o_5tuple_ram_rd <=  1'b0;
            
            r_5tupleram_read_write_conflict_0 <= 1'b1;
        end
        else if((i_5tuple_ram_wr == 1'b1) && (i_5tuple_ram_rd == 1'b0))begin//write but not read
            ov_5tuple_ram_addr <=  iv_5tuple_ram_waddr;
            ov_5tuple_ram_wdata <=  iv_5tuple_ram_wdata;
            o_5tuple_ram_wr <=  1'b1;
            o_5tuple_ram_rd <=  1'b0;
            
            r_5tupleram_read_write_conflict_0 <= 1'b0;
        end
        else if((i_5tuple_ram_wr == 1'b0) && (i_5tuple_ram_rd == 1'b1))begin//read but not write
            ov_5tuple_ram_addr <=  iv_5tuple_ram_raddr;
            ov_5tuple_ram_wdata <=  152'b0;
            o_5tuple_ram_wr <=  1'b0;
            o_5tuple_ram_rd <=  1'b1;
            
            r_5tupleram_read_write_conflict_0 <= 1'b0;
        end
        else begin//not read and not write
            ov_5tuple_ram_addr <=  5'b0;
            ov_5tuple_ram_wdata <=  152'b0;
            o_5tuple_ram_wr <=  1'b0;
            o_5tuple_ram_rd <=  1'b0;
            
            r_5tupleram_read_write_conflict_0 <= 1'b0;
        end
    end
end    
//***************************************************
//    arbitration of read and write of regroup_ram
//***************************************************
reg             r_regroupram_read_write_conflict_0;
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        //ov_regroup_ram_rdata <= 57'b0;
        
        ov_regroup_ram_addr <=  8'b0;
        ov_regroup_ram_wdata <=  71'b0;
        o_regroup_ram_wr <=  1'b0;
        o_regroup_ram_rd <=  1'b0; 
        
        r_regroupram_read_write_conflict_0 <= 1'b0;
    end
    else begin
        if((i_regroup_ram_wr == 1'b1) && (i_regroup_ram_rd == 1'b1))begin//read and write at the same time.write first.
            ov_regroup_ram_addr <=  iv_regroup_ram_waddr;
            ov_regroup_ram_wdata <=  iv_regroup_ram_wdata;
            o_regroup_ram_wr <=  1'b1;
            o_regroup_ram_rd <=  1'b0;
            
            r_regroupram_read_write_conflict_0 <= 1'b1;
        end
        else if((i_regroup_ram_wr == 1'b1) && (i_regroup_ram_rd == 1'b0))begin//write but not read
            ov_regroup_ram_addr <=  iv_regroup_ram_waddr;
            ov_regroup_ram_wdata <=  iv_regroup_ram_wdata;
            o_regroup_ram_wr <=  1'b1;
            o_regroup_ram_rd <=  1'b0;
            
            r_regroupram_read_write_conflict_0 <= 1'b0;
        end
        else if((i_regroup_ram_wr == 1'b0) && (i_regroup_ram_rd == 1'b1))begin//read but not write
            ov_regroup_ram_addr <=  iv_regroup_ram_raddr;
            ov_regroup_ram_wdata <=  71'b0;
            o_regroup_ram_wr <=  1'b0;
            o_regroup_ram_rd <=  1'b1;
            
            r_regroupram_read_write_conflict_0 <= 1'b0;
        end
        else begin//not read and not write
            ov_regroup_ram_addr <=  8'b0;
            ov_regroup_ram_wdata <=  71'b0;
            o_regroup_ram_wr <=  1'b0;
            o_regroup_ram_rd <=  1'b0;
            
            r_regroupram_read_write_conflict_0 <= 1'b0;
        end
    end
end 
//***************************************************
//            delay 2 cycles
//***************************************************
reg             r_5tupleram_read_write_conflict_1;
reg             r_regroupram_read_write_conflict_1;
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        r_5tupleram_read_write_conflict_1 <= 1'b0;
        r_regroupram_read_write_conflict_1 <= 1'b0;
        o_5tupleram_read_write_conflict <= 1'b0;
        o_regroupram_read_write_conflict <= 1'b0;
    end
    else begin
        r_5tupleram_read_write_conflict_1 <= r_5tupleram_read_write_conflict_0;
        o_5tupleram_read_write_conflict <= r_5tupleram_read_write_conflict_1;
        
        r_regroupram_read_write_conflict_1 <= r_regroupram_read_write_conflict_0;
        o_regroupram_read_write_conflict <= r_regroupram_read_write_conflict_1;        
    end
end    
endmodule