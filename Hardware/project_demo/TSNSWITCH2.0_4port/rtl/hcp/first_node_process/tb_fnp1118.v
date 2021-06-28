`timescale 1ns / 1ps
module tb_fnp(

);
    reg clk;
    reg rst_n;

    //input
    reg [133:0] iv_fnp_pkt_data;
    reg i_fnp_pkt_data_wr;
    reg [3:0] iv_fnp_pkt_inport;
    
    //cim to fifo(5tuple)
    reg [4:0] iv_fnp_fmt_ram_waddr;
    reg i_fnp_fmt_ram_wr;
    reg [151:0] iv_fnp_fmt_ram_wdata;

    //output 2 osm
    reg i_fnp_fifo_rd;
    wire o_fnp_fifo_empty;
    wire [133:0] ov_fnp_fifo_data;

    //impulse lost pkt_head_fragment
    wire o_fnp_inport_0_lost_head;
    wire o_fnp_inport_1_lost_head;
    wire o_fnp_inport_2_lost_head;
    wire o_fnp_inport_3_lost_head;
    wire o_fnp_inport_4_lost_head;
    wire o_fnp_inport_5_lost_head;
    wire o_fnp_inport_6_lost_head;
    wire o_fnp_inport_7_lost_head;

    //impulse lost pkt_nothead_fragment
    wire o_fnp_inport_0_lost_nothead; 
    wire o_fnp_inport_1_lost_nothead;
    wire o_fnp_inport_2_lost_nothead;
    wire o_fnp_inport_3_lost_nothead;
    wire o_fnp_inport_4_lost_nothead;
    wire o_fnp_inport_5_lost_nothead;
    wire o_fnp_inport_6_lost_nothead;
    wire o_fnp_inport_7_lost_nothead;

    //fifo overflow
    wire o_fnp_fifo_overflow;

    //pkt count
    wire o_fnp_inpkt_cnt;
    wire o_fnp_outpkt_cnt;
	
	
//////////////////////////////////////////////////////
    // initialize module
        fnp fnp_tb(
            .clk(clk),
            .rst_n(rst_n),

            //input
            .iv_fnp_pkt_data(iv_fnp_pkt_data),
            .i_fnp_pkt_data_wr(i_fnp_pkt_data_wr),
            .iv_fnp_pkt_inport(iv_fnp_pkt_inport),
    
            //spp to fifo(5tuple)
            .iv_fnp_fmt_ram_waddr(iv_fnp_fmt_ram_waddr),
            .i_fnp_fmt_ram_wr(i_fnp_fmt_ram_wr),
            .iv_fnp_fmt_ram_wdata(iv_fnp_fmt_ram_wdata),

            //output 2 osm
            .i_fnp_fifo_rd(i_fnp_fifo_rd),
            .o_fnp_fifo_empty(o_fnp_fifo_empty),
            .ov_fnp_fifo_data(ov_fnp_fifo_data),

			//impulse lost pkt_head_fragment
            .o_fnp_inport_0_lost_head (o_fnp_inport_0_lost_head),
            .o_fnp_inport_1_lost_head (o_fnp_inport_1_lost_head),
            .o_fnp_inport_2_lost_head (o_fnp_inport_2_lost_head),
            .o_fnp_inport_3_lost_head (o_fnp_inport_3_lost_head),
            .o_fnp_inport_4_lost_head (o_fnp_inport_4_lost_head),
            .o_fnp_inport_5_lost_head (o_fnp_inport_5_lost_head),
            .o_fnp_inport_6_lost_head (o_fnp_inport_6_lost_head),
            .o_fnp_inport_7_lost_head (o_fnp_inport_7_lost_head),

            //impulse lost pkt_nothead_fragment
            .o_fnp_inport_0_lost_nothead (o_fnp_inport_0_lost_nothead),
            .o_fnp_inport_1_lost_nothead (o_fnp_inport_1_lost_nothead),
            .o_fnp_inport_2_lost_nothead (o_fnp_inport_2_lost_nothead),
            .o_fnp_inport_3_lost_nothead (o_fnp_inport_3_lost_nothead),
            .o_fnp_inport_4_lost_nothead (o_fnp_inport_4_lost_nothead),
            .o_fnp_inport_5_lost_nothead (o_fnp_inport_5_lost_nothead),
            .o_fnp_inport_6_lost_nothead (o_fnp_inport_6_lost_nothead),
            .o_fnp_inport_7_lost_nothead (o_fnp_inport_7_lost_nothead),

            //fifo overflow
            .o_fnp_fifo_overflow (o_fnp_fifo_overflow),

            //pkt count
            .o_fnp_inpkt_cnt (o_fnp_inpkt_cnt),
            .o_fnp_outpkt_cnt (o_fnp_outpkt_cnt)
        );

        initial begin
           clk = 1'b0;

           
           forever #5 clk = ~clk;
        end

        initial  begin
            rst_n =1'b0;

            #100
            rst_n =1'b1;

            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            #10
            iv_fnp_fmt_ram_waddr <=5'd0;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000001_00000001_0001_0001, 3'b001, 14'b0, 16'b0, 1'b0, 4'b0, 5'b00001, 5'b00111};

            #10
            iv_fnp_fmt_ram_waddr <=5'd1;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000002_00000002_0002_0002, 3'b010,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00010, 5'b00010};

            #10
            iv_fnp_fmt_ram_waddr <=5'd2;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0003, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd3;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000004_00000004_0004_0004, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd4;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000005_00000005_0005_0005, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd5;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000006_00000006_0006_0006, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd6;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000007_00000007_0007_0007, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd7;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000008_00000008_0008_0008, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd8;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000009_00000009_0009_0009, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd9;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000010_00000010_0010_0010, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd10;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0011, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd11;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0012, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd12;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0013, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd13;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0014, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd14;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0015, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd15;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0016, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd16;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0017, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd17;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0018, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd18;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0019, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd19;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0020, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd20;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0021, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd21;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0022, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd22;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0023, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd23;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0024, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd24;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0025, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd25;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0026, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd26;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0027, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd27;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0028, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd28;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0029, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd29;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0030, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
             #10
            iv_fnp_fmt_ram_waddr <=5'd30;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0031, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};
            
              #10
            iv_fnp_fmt_ram_waddr <=5'd31;
            i_fnp_fmt_ram_wr <=1'b1;
            iv_fnp_fmt_ram_wdata <={104'h06_00000003_00000003_0003_0032, 3'b011,  14'b0, 16'b0, 1'b0, 4'b0, 5'b00011, 5'b00011};

            #10
            
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            i_fnp_fmt_ram_wr <=1'b0;
            
            //a_1*************************
            #1000
            iv_fnp_pkt_data <={6'b010000, 64'h1111_0000_0000_0001, 32'h0000_0000, 16'h0800, 16'h000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd0;
            
            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0052 , 40'h0000_0000_00, 8'h06, 16'h0000, 32'h0000_0001, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd0;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0001, 16'h0001, 16'h0001, 80'h0000_0000_0000_0003_000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd0;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0004_000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd0;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0007_000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd0;

            #10
            iv_fnp_pkt_data <={6'b100000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0008_000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd0;
            
            #10
            i_fnp_pkt_data_wr <=1'b0 ;
            
            
            //b_1********************************
            #1000
            iv_fnp_pkt_data <={6'b010000, 64'h2222_0000_0000_0001, 32'h0000_0000, 16'h0800, 16'h001b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;
            
            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0152, 40'h0000_0000_00, 8'h06, 16'h0000, 32'h0000_0012, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0002, 16'h0002, 16'h0002, 80'h0000_0000_0000_0003_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0004_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0005_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0006_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0007_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b100000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0008_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;
            
            #10
            i_fnp_pkt_data_wr <=1'b0 ;
			
			
			//b_2********************************
            #1000
            iv_fnp_pkt_data <={6'b010000, 64'h0000_0000_0000_0000, 32'h0000_0000, 16'h0000, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;
            
            #10
            iv_fnp_pkt_data <={6'b110000, 16'h01c3, 40'h0000_0000_00, 8'h02, 16'h0000, 32'h0000_0002, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0002, 16'h0002, 16'h0002, 80'h0000_0000_0000_0003_002b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0004_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0005_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0006_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0007_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b100000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0008_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;
            
            #10
            i_fnp_pkt_data_wr <=1'b0 ;
			
			///*
			 //c_1********************************
            #1000
            iv_fnp_pkt_data <={6'b010000, 64'h3333_0000_0000_0001, 32'h0000_0000, 16'h0800, 16'h001c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;
            
            #10
            iv_fnp_pkt_data <={6'b110000, 16'h00e2, 40'h0000_0000_00, 8'h12, 16'h0000, 32'h0000_0003, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0003, 16'h0003, 16'h0003, 80'h0000_0000_0000_0003_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0004_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0005_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0006_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0007_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b100000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0008_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;
            
            #10
            i_fnp_pkt_data_wr <=1'b0 ;
			
			//*/
			
			//b_3********************************
            #1000
            iv_fnp_pkt_data <={6'b010000, 64'h0000_0000_0000_0000, 32'h0000_0000, 16'h0000, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;
            
            #10
            iv_fnp_pkt_data <={6'b110000, 16'h01c4, 40'h0000_0000_00, 8'h02, 16'h0000, 32'h0000_0002, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0002, 16'h0002, 16'h0002, 80'h0000_0000_0000_0003_003b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0004_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0005_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0006_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0007_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b100000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0008_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;
            
            #10
            i_fnp_pkt_data_wr <=1'b0 ;
			
			
			 
			
			///*
			//c_2********************************
            #1000
            iv_fnp_pkt_data <={6'b010000, 64'h0000_0000_0000_0000, 32'h0000_0000, 16'h0000, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;
            
            #10
            iv_fnp_pkt_data <={6'b110000, 16'h01c3, 40'h0000_0000_00, 8'h02, 16'h0000, 32'h0000_0002, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0002, 16'h0002, 16'h0002, 80'h0000_0000_0000_0003_002c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0004_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0005_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0006_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0007_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b100000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0008_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;
            
            #10
            i_fnp_pkt_data_wr <=1'b0 ;
			
			//*/
			
			
			
			
			/*
			//b_4********************************
            #1000
            iv_fnp_pkt_data <={6'b010000, 64'h0000_0000_0000_0000, 32'h0000_0000, 16'h0000, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;
            
            #10
            iv_fnp_pkt_data <={6'b110000, 16'h01c4, 40'h0000_0000_00, 8'h02, 16'h0000, 32'h0000_0002, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0002, 16'h0002, 16'h0002, 80'h0000_0000_0000_0003_004b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0004_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0005_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0006_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0007_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b100000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0008_000b};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;
            
            #10
            i_fnp_pkt_data_wr <=1'b0 ;
            
            */
            //////////////////////////////
			
            /*
            //c_1**********************************************************
            #1000
            iv_fnp_pkt_data <={6'b010000, 64'h0000_0000_0001, 32'h0000_0000, 16'h0800, 16'h000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;
            
            #10
            iv_fnp_pkt_data <={6'b110000, 56'h0000_0000_0000, 8'h03, 16'h0000, 32'h0000_0003, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0003, 16'h0003, 16'h0003, 80'h0000_0000_0000_0003_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0004_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0005_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0006_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0007_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;

            #10
            iv_fnp_pkt_data <={6'b100000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0008_000c};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd2;
            
            #10
            i_fnp_pkt_data_wr <=1'b0 ;
            
            //a_2************************************
            #1000
            iv_fnp_pkt_data <={6'b010000, 64'h0000_0000_0000, 32'h0000_0000, 16'h0000, 16'h000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;
            
            #10
            iv_fnp_pkt_data <={6'b110000, 56'h0000_0000_0000, 8'h03, 16'h0000, 32'h0000_0003, 16'h0000};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0003, 16'h0003, 16'h0003, 80'h0000_0000_0000_0003_000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0004_000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0005_000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0006_000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b110000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0007_000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;

            #10
            iv_fnp_pkt_data <={6'b100000, 16'h0000, 16'h0000, 16'h0000, 80'h0000_0000_0000_0008_000a};
            i_fnp_pkt_data_wr <=1'b1 ;
            iv_fnp_pkt_inport <=4'd1;
            
            #10
            i_fnp_pkt_data_wr <=1'b0 ;
            */
        end
endmodule