// Copyright (C) 1953-2020 NUDT
// Verilog module name - TSNSwitch_8port 
// Version: TSNSwitch_8port_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//        top of TSNSwitch_8port
//               
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module TSNSwitch_8port(

    input  wire        FPGA_SYS_CLK,//125Mhz
    input  wire        FPGA_SYS_RST_N,
    
    //SGMII 
    input              VSC8211_GXB_REFCLK,
    
    input              VSC8211_GXB_RXD,
    output             VSC8211_GXB_TXD,
    

    output             VCS8504_RST,
    
    input              SGMII_LVDS_REFCLK,
    input       [7:0]  SGMII_LVDS_RXD,
    output      [7:0]  SGMII_LVDS_TXD,
    
    input       [1:0]  VCS8504_MDIO_INT,
    output             VCS8504_MDIO_SCL,
    inout              VCS8504_MDIO_SDA,
    
    //GPIO
    input  wire [2:0]  CARD_ID,//当前子卡的ID号，由载板插座的pin脚提供
    input  wire [2:0]  MB_ID,//载板ID号，由载板插座的pin脚提供
    
    //led
    output      [8:0]  FACE_SYS_LED,
    output             FACE_PWR_LED,
    output             DEBUG_LED,
    output             BACKPLANE_LED,
    
    //custom io
    inout       [4:0]  CUSTOM_IO
    
/*
    input  wire       FPGA_SYS_CLK,//125Mhz
    input  wire       FPGA_SYS_RST_N,
    //Extenal PHY
    output wire       VCS8504_RST,
    output wire       VCS8504_MDIO_SCL,
    inout  wire       VCS8504_MDIO_SDA,
    input  wire       VCS8504_MDIO_INT,
    //SGMII
    input  wire       SGMII_LVDS_REFCLK,
    input  wire [3:0] SGMII_RXD,
    output wire [3:0] SGMII_TXD,    
    //GPIO
    input  wire [2:0] CARD_ID,//当前子卡的ID号，由载板插座的pin脚提供
    input  wire [2:0] MB_ID,//载板ID号，由载板插座的pin脚提供
    
    output wire [3:0] LED,
    output wire [9:0] RSV_IO,//载板插座上的保留功能IO
    output wire [4:0] DEBUG_LED
    
*/
);



wire        rst_n;
wire        clk_50M;
wire        clk_125M;

//host
wire [ 4:0] reg_addr_linkhost;
wire [15:0] reg_data_out_linkhost;
wire        reg_rd_linkhost;
wire [15:0] reg_data_in_linkhost;
wire        reg_wr_linkhost;
wire        reg_busy_linkhost;
//wire        led_an_linkhost;
wire        led_link_linkhost;
wire        gmii_rx_dv_linkhost;
wire [ 7:0] gmii_rxd_linkhost;
wire        gmii_rx_er_linkhost;
wire        gmii_tx_en_linkhost;
wire [ 7:0] gmii_txd_linkhost;
wire        gmii_tx_er_linkhost;

//0
wire [ 4:0] reg_addr_link0;
wire [15:0] reg_data_out_link0;
wire        reg_rd_link0;
wire [15:0] reg_data_in_link0;
wire        reg_wr_link0;
wire        reg_busy_link0;
//wire        led_an_link0;
wire        led_link_link0;
wire        gmii_rx_dv_link0;
wire [ 7:0] gmii_rxd_link0;
wire        gmii_rx_er_link0;
wire        gmii_tx_en_link0;
wire [ 7:0] gmii_txd_link0;
wire        gmii_tx_er_link0;

//1
wire [ 4:0] reg_addr_link1;
wire [15:0] reg_data_out_link1;
wire        reg_rd_link1;
wire [15:0] reg_data_in_link1;
wire        reg_wr_link1;
wire        reg_busy_link1;
//wire        led_an_link1;
wire        led_link_link1;
wire        gmii_rx_dv_link1;
wire [ 7:0] gmii_rxd_link1;
wire        gmii_rx_er_link1;
wire        gmii_tx_en_link1;
wire [ 7:0] gmii_txd_link1;
wire        gmii_tx_er_link1;

//2
wire [ 4:0] reg_addr_link2;
wire [15:0] reg_data_out_link2;
wire        reg_rd_link2;
wire [15:0] reg_data_in_link2;
wire        reg_wr_link2;
wire        reg_busy_link2;
//wire        led_an_link2;
wire        led_link_link2;
wire        gmii_rx_dv_link2;
wire [ 7:0] gmii_rxd_link2;
wire        gmii_rx_er_link2;
wire        gmii_tx_en_link2;
wire [ 7:0] gmii_txd_link2;
wire        gmii_tx_er_link2;
 
 //3
wire [ 4:0] reg_addr_link3;
wire [15:0] reg_data_out_link3;
wire        reg_rd_link3;
wire [15:0] reg_data_in_link3;
wire        reg_wr_link3;
wire        reg_busy_link3;
//wire        led_an_link3;
wire        led_link_link3;
wire        gmii_rx_dv_link3;
wire [ 7:0] gmii_rxd_link3;
wire        gmii_rx_er_link3;
wire        gmii_tx_en_link3;
wire [ 7:0] gmii_txd_link3;
wire        gmii_tx_er_link3;
 
 //4
wire [ 4:0] reg_addr_link4;
wire [15:0] reg_data_out_link4;
wire        reg_rd_link4;
wire [15:0] reg_data_in_link4;
wire        reg_wr_link4;
wire        reg_busy_link4;
//wire        led_an_link4;
wire        led_link_link4;
wire        gmii_rx_dv_link4;
wire [ 7:0] gmii_rxd_link4;
wire        gmii_rx_er_link4;
wire        gmii_tx_en_link4;
wire [ 7:0] gmii_txd_link4;
wire        gmii_tx_er_link4;
 
 //5
wire [ 4:0] reg_addr_link5;
wire [15:0] reg_data_out_link5;
wire        reg_rd_link5;
wire [15:0] reg_data_in_link5;
wire        reg_wr_link5;
wire        reg_busy_link5;
//wire        led_an_link5;
wire        led_link_link5;
wire        gmii_rx_dv_link5;
wire [ 7:0] gmii_rxd_link5;
wire        gmii_rx_er_link5;
wire        gmii_tx_en_link5;
wire [ 7:0] gmii_txd_link5;
wire        gmii_tx_er_link5;
 
 //6
wire [ 4:0] reg_addr_link6;
wire [15:0] reg_data_out_link6;
wire        reg_rd_link6;
wire [15:0] reg_data_in_link6;
wire        reg_wr_link6;
wire        reg_busy_link6;
//wire        led_an_link6;
wire        led_link_link6;
wire        gmii_rx_dv_link6;
wire [ 7:0] gmii_rxd_link6;
wire        gmii_rx_er_link6;
wire        gmii_tx_en_link6;
wire [ 7:0] gmii_txd_link6;
wire        gmii_tx_er_link6;
 
 //7
wire [ 4:0] reg_addr_link7;
wire [15:0] reg_data_out_link7;
wire        reg_rd_link7;
wire [15:0] reg_data_in_link7;
wire        reg_wr_link7;
wire        reg_busy_link7;
//wire        led_an_link7;
wire        led_link_link7;
wire        gmii_rx_dv_link7;
wire [ 7:0] gmii_rxd_link7;
wire        gmii_rx_er_link7;
wire        gmii_tx_en_link7;
wire [ 7:0] gmii_txd_link7;
wire        gmii_tx_er_link7;
 
//host
wire [ 7:0] ov_gmii_txd_host;
wire        o_gmii_tx_en_host;
wire        o_gmii_tx_er_host;
wire        o_gmii_tx_clk_host;
wire        PCS_tx_clk_host;
wire        PCS_rx_clk_host;

//0
wire [ 7:0] ov_gmii_txd_p0;
wire        o_gmii_tx_en_p0;
wire        o_gmii_tx_er_p0;
wire        o_gmii_tx_clk_p0;
wire        PCS_tx_clk_inst0;
wire        PCS_rx_clk_inst0;

//1
wire [ 7:0] ov_gmii_txd_p1;
wire        o_gmii_tx_en_p1;
wire        o_gmii_tx_er_p1;
wire        o_gmii_tx_clk_p1;
wire        PCS_tx_clk_inst1;
wire        PCS_rx_clk_inst1;

//2
wire [ 7:0] ov_gmii_txd_p2;
wire        o_gmii_tx_en_p2;
wire        o_gmii_tx_er_p2;
wire        o_gmii_tx_clk_p2;
wire        PCS_tx_clk_inst2;
wire        PCS_rx_clk_inst2;
 
 //3
wire [ 7:0] ov_gmii_txd_p3;
wire        o_gmii_tx_en_p3;
wire        o_gmii_tx_er_p3;
wire        o_gmii_tx_clk_p3;
wire        PCS_tx_clk_inst3;
wire        PCS_rx_clk_inst3;
 
 //4
wire [ 7:0] ov_gmii_txd_p4;
wire        o_gmii_tx_en_p4;
wire        o_gmii_tx_er_p4;
wire        o_gmii_tx_clk_p4;
wire        PCS_tx_clk_inst4;
wire        PCS_rx_clk_inst4;
 
 //5
wire [ 7:0] ov_gmii_txd_p5;
wire        o_gmii_tx_en_p5;
wire        o_gmii_tx_er_p5;
wire        o_gmii_tx_clk_p5;
wire        PCS_tx_clk_inst5;
wire        PCS_rx_clk_inst5;
 
 //6
wire [ 7:0] ov_gmii_txd_p6;
wire        o_gmii_tx_en_p6;
wire        o_gmii_tx_er_p6;
wire        o_gmii_tx_clk_p6;
wire        PCS_tx_clk_inst6;
wire        PCS_rx_clk_inst6;
 
 //7
wire [ 7:0] ov_gmii_txd_p7;
wire        o_gmii_tx_en_p7;
wire        o_gmii_tx_er_p7;
wire        o_gmii_tx_clk_p7;
wire        PCS_tx_clk_inst7;
wire        PCS_rx_clk_inst7;
 
wire         Smi_link;
wire         Smi_mdc;
wire          Smi_mdi; 
wire         Smi_mdo;
wire [1:0]   Smi_sel;
wire         init_done_link;
//wire         led_an_link;

assign  VCS8504_MDIO_SCL = (Smi_mdc == 1'b1) ? 1'b1 : 1'b0 ;
assign  VCS8504_MDIO_SDA = (Smi_link== 1'b1) ? Smi_mdo : 1'bz ;
assign  Smi_mdi = (Smi_link == 1'b1) ? 1'b1 : VCS8504_MDIO_SDA ;
//assign    VCS8504_RST = {rst_n , rst_n};
/*
always @(*)
    if(~FPGA_SYS_RST_N)
        Smi_mdi = 1'b0;
    else  if(~Smi_link)begin
        case(Smi_sel)
            2'b00 : Smi_mdi = VCS8504_MDIO_SDA ;
            default: Smi_mdi = 1'b1 ;
        endcase
    end
    else
      Smi_mdi = 1'b1;
*/

clk125M_50M125M clk125M_50M125M_inst(
    .rst      (!FPGA_SYS_RST_N),      //   reset.reset
    .refclk   (FPGA_SYS_CLK),   //  refclk.clk
    .locked   (rst_n),   //  locked.export
    .outclk_0 (clk_50M), // outclk0.clk
    .outclk_1 (clk_125M)  // outclk1.clk
);

extern_phy_config extern_phy_config_inst1(
    .clk_100m     (clk_50M) ,
    .rst_n        (rst_n),
    .smi_mdi     ( Smi_mdi ),
    .smi_mdc     ( Smi_mdc ), 
    .smi_mdo     ( Smi_mdo ),
    .smi_link    ( Smi_link),
    .init_done   (init_done_link )
);

phy_reset phy_reset_inst1(
    .clk              (clk_50M),
    .reset            (rst_n),
    .init_done        (init_done_link),
    .autoneg_success  (FACE_SYS_LED),                  
    .phy_reset_over   (VCS8504_RST)
);

TSNSwitch_top TSNSwitch_top_inst(
    .i_clk(clk_125M),
           
    .i_hard_rst_n(rst_n),
    .i_button_rst_n(rst_n),
    .i_et_resetc_rst_n(rst_n),  
           
    .ov_gmii_txd_p0(ov_gmii_txd_p0),
    .o_gmii_tx_en_p0(o_gmii_tx_en_p0),
    .o_gmii_tx_er_p0(o_gmii_tx_er_p0),
    .o_gmii_tx_clk_p0(o_gmii_tx_clk_p0),

    .ov_gmii_txd_p1(ov_gmii_txd_p1),
    .o_gmii_tx_en_p1(o_gmii_tx_en_p1),
    .o_gmii_tx_er_p1(o_gmii_tx_er_p1),
    .o_gmii_tx_clk_p1(o_gmii_tx_clk_p1),
           
    .ov_gmii_txd_p2(ov_gmii_txd_p2),
    .o_gmii_tx_en_p2(o_gmii_tx_en_p2),
    .o_gmii_tx_er_p2(o_gmii_tx_er_p2),
    .o_gmii_tx_clk_p2(o_gmii_tx_clk_p2),
 
    .ov_gmii_txd_p3(ov_gmii_txd_p3),
    .o_gmii_tx_en_p3(o_gmii_tx_en_p3),
    .o_gmii_tx_er_p3(o_gmii_tx_er_p3),
    .o_gmii_tx_clk_p3(o_gmii_tx_clk_p3),
 
    .ov_gmii_txd_p4(ov_gmii_txd_p4),
    .o_gmii_tx_en_p4(o_gmii_tx_en_p4),
    .o_gmii_tx_er_p4(o_gmii_tx_er_p4),
    .o_gmii_tx_clk_p4(o_gmii_tx_clk_p4),
 
    .ov_gmii_txd_p5(ov_gmii_txd_p5),
    .o_gmii_tx_en_p5(o_gmii_tx_en_p5),
    .o_gmii_tx_er_p5(o_gmii_tx_er_p5),
    .o_gmii_tx_clk_p5(o_gmii_tx_clk_p5),
 
    .ov_gmii_txd_p6(ov_gmii_txd_p6),
    .o_gmii_tx_en_p6(o_gmii_tx_en_p6),
    .o_gmii_tx_er_p6(o_gmii_tx_er_p6),
    .o_gmii_tx_clk_p6(o_gmii_tx_clk_p6),
 
    .ov_gmii_txd_p7(ov_gmii_txd_p7),
    .o_gmii_tx_en_p7(o_gmii_tx_en_p7),
    .o_gmii_tx_er_p7(o_gmii_tx_er_p7),
    .o_gmii_tx_clk_p7(o_gmii_tx_clk_p7),
 
    //Network input top module
    .i_gmii_rxclk_p0(PCS_rx_clk_inst0),
    .i_gmii_dv_p0(gmii_rx_dv_link0),
    .iv_gmii_rxd_p0(gmii_rxd_link0),
    .i_gmii_er_p0(gmii_rx_er_link0),
           
    .i_gmii_rxclk_p1(PCS_rx_clk_inst1),
    .i_gmii_dv_p1(gmii_rx_dv_link1),
    .iv_gmii_rxd_p1(gmii_rxd_link1),
    .i_gmii_er_p1(gmii_rx_er_link1),
           
    .i_gmii_rxclk_p2(PCS_rx_clk_inst2),
    .i_gmii_dv_p2(gmii_rx_dv_link2),
    .iv_gmii_rxd_p2(gmii_rxd_link2),
    .i_gmii_er_p2(gmii_tx_er_link2),   
 
    .i_gmii_rxclk_p3(PCS_rx_clk_inst3),
    .i_gmii_dv_p3(gmii_rx_dv_link3),
    .iv_gmii_rxd_p3(gmii_rxd_link3),
    .i_gmii_er_p3(gmii_tx_er_link3),   
 
    .i_gmii_rxclk_p4(PCS_rx_clk_inst4),
    .i_gmii_dv_p4(gmii_rx_dv_link4),
    .iv_gmii_rxd_p4(gmii_rxd_link4),
    .i_gmii_er_p4(gmii_tx_er_link4),   
 
    .i_gmii_rxclk_p5(PCS_rx_clk_inst5),
    .i_gmii_dv_p5(gmii_rx_dv_link5),
    .iv_gmii_rxd_p5(gmii_rxd_link5),
    .i_gmii_er_p5(gmii_tx_er_link5),   
 
    .i_gmii_rxclk_p6(PCS_rx_clk_inst6),
    .i_gmii_dv_p6(gmii_rx_dv_link6),
    .iv_gmii_rxd_p6(gmii_rxd_link6),
    .i_gmii_er_p6(gmii_tx_er_link6),   
 
    .i_gmii_rxclk_p7(PCS_rx_clk_inst7),
    .i_gmii_dv_p7(gmii_rx_dv_link7),
    .iv_gmii_rxd_p7(gmii_rxd_link7),
    .i_gmii_er_p7(gmii_tx_er_link7),   
  
    //hrp
    .i_gmii_rxclk_host(PCS_rx_clk_host),
    .i_gmii_dv_host(gmii_rx_dv_linkhost),
    .iv_gmii_rxd_host(gmii_rxd_linkhost),
    .i_gmii_er_host(gmii_rx_er_linkhost),

    //htp
    .ov_gmii_txd_host(ov_gmii_txd_host),//ov_gmii_txd_p3
    .o_gmii_tx_en_host(o_gmii_tx_en_host),
    .o_gmii_tx_er_host(o_gmii_tx_er_host),
    .o_gmii_tx_clk_host(o_gmii_tx_clk_host),

    .pluse_s(),
    .reset_clk_pulse        (),
    .asynfifo_rx_overflow_pulse (), 
    .asynfifo_rx_underflow_pulse(),
    .asynfifo_tx_overflow_pulse ()         
);

port_passthrough port_passthrough_host(
    .gmii_rxclk(o_gmii_tx_clk_host),
    .gmii_txclk(PCS_tx_clk_host),
    .rst_n(rst_n),
        
    .gmii_rx_en(o_gmii_tx_en_host),
    .gmii_rx_er(o_gmii_tx_er_host),
    .gmii_rxd(ov_gmii_txd_host),
        
    .gmii_tx_en(gmii_tx_en_linkhost),
    .gmii_tx_er(gmii_tx_er_linkhost),
    .gmii_txd(gmii_txd_linkhost)
);

sgmii_config sgmii_config_host(
    .clk(clk_50M),
    .reset(rst_n),
    
    .reg_data_out(reg_data_out_linkhost),
    .reg_rd(reg_rd_linkhost),
    .reg_data_in(reg_data_in_linkhost),
    .reg_wr(reg_wr_linkhost),
    .reg_busy(reg_busy_linkhost),
    .reg_addr(reg_addr_linkhost),

    .led_link(led_link_linkhost),
    .led_an(FACE_SYS_LED[8])
);

port_passthrough port_passthrough_inst0(
    .gmii_rxclk(o_gmii_tx_clk_p0),
    .gmii_txclk(PCS_tx_clk_inst0),
    .rst_n(rst_n),
        
    .gmii_rx_en(o_gmii_tx_en_p0),
    .gmii_rx_er(o_gmii_tx_er_p0),
    .gmii_rxd(ov_gmii_txd_p0),
        
    .gmii_tx_en(gmii_tx_en_link0),
    .gmii_tx_er(gmii_tx_er_link0),
    .gmii_txd(gmii_txd_link0)
);

sgmii_config sgmii_config_inst0(
    .clk(clk_50M),
    .reset(rst_n),
    
    .reg_data_out(reg_data_out_link0),
    .reg_rd(reg_rd_link0),
    .reg_data_in(reg_data_in_link0),
    .reg_wr(reg_wr_link0),
    .reg_busy(reg_busy_link0),
    .reg_addr(reg_addr_link0),

    .led_link(led_link_link0),
    .led_an(FACE_SYS_LED[0])
);

port_passthrough port_passthrough_inst1(
    .gmii_rxclk(o_gmii_tx_clk_p1),
    .gmii_txclk(PCS_tx_clk_inst1),
    .rst_n(rst_n),
        
    .gmii_rx_en(o_gmii_tx_en_p1),
    .gmii_rx_er(o_gmii_tx_er_p1),
    .gmii_rxd(ov_gmii_txd_p1),
        
    .gmii_tx_en(gmii_tx_en_link1),
    .gmii_tx_er(gmii_tx_er_link1),
    .gmii_txd(gmii_txd_link1)
);

sgmii_config sgmii_config_inst1(
    .clk(clk_50M),
    .reset(rst_n),
    
    .reg_data_out(reg_data_out_link1),
    .reg_rd(reg_rd_link1),
    .reg_data_in(reg_data_in_link1),
    .reg_wr(reg_wr_link1),
    .reg_busy(reg_busy_link1),
    .reg_addr(reg_addr_link1),

    .led_link(led_link_link1),
    .led_an(FACE_SYS_LED[1])
);

port_passthrough port_passthrough_inst2(
    .gmii_rxclk(o_gmii_tx_clk_p2),
    .gmii_txclk(PCS_tx_clk_inst2),
    .rst_n(rst_n),
        
    .gmii_rx_en(o_gmii_tx_en_p2),
    .gmii_rx_er(o_gmii_tx_er_p2),
    .gmii_rxd(ov_gmii_txd_p2),
        
    .gmii_tx_en(gmii_tx_en_link2),
    .gmii_tx_er(gmii_tx_er_link2),
    .gmii_txd(gmii_txd_link2)
);

sgmii_config sgmii_config_inst2(
    .clk(clk_50M),
    .reset(rst_n),
    
    .reg_data_out(reg_data_out_link2),
    .reg_rd(reg_rd_link2),
    .reg_data_in(reg_data_in_link2),
    .reg_wr(reg_wr_link2),
    .reg_busy(reg_busy_link2),
    .reg_addr(reg_addr_link2),

    .led_link(led_link_link2),
    .led_an(FACE_SYS_LED[2])
);
 
 port_passthrough port_passthrough_inst3(
    .gmii_rxclk(o_gmii_tx_clk_p3),
    .gmii_txclk(PCS_tx_clk_inst3),
    .rst_n(rst_n),
        
    .gmii_rx_en(o_gmii_tx_en_p3),
    .gmii_rx_er(o_gmii_tx_er_p3),
    .gmii_rxd(ov_gmii_txd_p3),
        
    .gmii_tx_en(gmii_tx_en_link3),
    .gmii_tx_er(gmii_tx_er_link3),
    .gmii_txd(gmii_txd_link3)
);

sgmii_config sgmii_config_inst3(
    .clk(clk_50M),
    .reset(rst_n),
    
    .reg_data_out(reg_data_out_link3),
    .reg_rd(reg_rd_link3),
    .reg_data_in(reg_data_in_link3),
    .reg_wr(reg_wr_link3),
    .reg_busy(reg_busy_link3),
    .reg_addr(reg_addr_link3),

    .led_link(led_link_link3),
    .led_an(FACE_SYS_LED[3])
);
 
 port_passthrough port_passthrough_inst4(
    .gmii_rxclk(o_gmii_tx_clk_p4),
    .gmii_txclk(PCS_tx_clk_inst4),
    .rst_n(rst_n),
        
    .gmii_rx_en(o_gmii_tx_en_p4),
    .gmii_rx_er(o_gmii_tx_er_p4),
    .gmii_rxd(ov_gmii_txd_p4),
        
    .gmii_tx_en(gmii_tx_en_link4),
    .gmii_tx_er(gmii_tx_er_link4),
    .gmii_txd(gmii_txd_link4)
);

sgmii_config sgmii_config_inst4(
    .clk(clk_50M),
    .reset(rst_n),
    
    .reg_data_out(reg_data_out_link4),
    .reg_rd(reg_rd_link4),
    .reg_data_in(reg_data_in_link4),
    .reg_wr(reg_wr_link4),
    .reg_busy(reg_busy_link4),
    .reg_addr(reg_addr_link4),

    .led_link(led_link_link4),
    .led_an(FACE_SYS_LED[4])
);
 
 port_passthrough port_passthrough_inst5(
    .gmii_rxclk(o_gmii_tx_clk_p5),
    .gmii_txclk(PCS_tx_clk_inst5),
    .rst_n(rst_n),
        
    .gmii_rx_en(o_gmii_tx_en_p5),
    .gmii_rx_er(o_gmii_tx_er_p5),
    .gmii_rxd(ov_gmii_txd_p5),
        
    .gmii_tx_en(gmii_tx_en_link5),
    .gmii_tx_er(gmii_tx_er_link5),
    .gmii_txd(gmii_txd_link5)
);

sgmii_config sgmii_config_inst5(
    .clk(clk_50M),
    .reset(rst_n),
    
    .reg_data_out(reg_data_out_link5),
    .reg_rd(reg_rd_link5),
    .reg_data_in(reg_data_in_link5),
    .reg_wr(reg_wr_link5),
    .reg_busy(reg_busy_link5),
    .reg_addr(reg_addr_link5),

    .led_link(led_link_link5),
    .led_an(FACE_SYS_LED[5])
);
 
 port_passthrough port_passthrough_inst6(
    .gmii_rxclk(o_gmii_tx_clk_p6),
    .gmii_txclk(PCS_tx_clk_inst6),
    .rst_n(rst_n),
        
    .gmii_rx_en(o_gmii_tx_en_p6),
    .gmii_rx_er(o_gmii_tx_er_p6),
    .gmii_rxd(ov_gmii_txd_p6),
        
    .gmii_tx_en(gmii_tx_en_link6),
    .gmii_tx_er(gmii_tx_er_link6),
    .gmii_txd(gmii_txd_link6)
);

sgmii_config sgmii_config_inst6(
    .clk(clk_50M),
    .reset(rst_n),
    
    .reg_data_out(reg_data_out_link6),
    .reg_rd(reg_rd_link6),
    .reg_data_in(reg_data_in_link6),
    .reg_wr(reg_wr_link6),
    .reg_busy(reg_busy_link6),
    .reg_addr(reg_addr_link6),

    .led_link(led_link_link6),
    .led_an(FACE_SYS_LED[6])
);
 
 port_passthrough port_passthrough_inst7(
    .gmii_rxclk(o_gmii_tx_clk_p7),
    .gmii_txclk(PCS_tx_clk_inst7),
    .rst_n(rst_n),
        
    .gmii_rx_en(o_gmii_tx_en_p7),
    .gmii_rx_er(o_gmii_tx_er_p7),
    .gmii_rxd(ov_gmii_txd_p7),
        
    .gmii_tx_en(gmii_tx_en_link7),
    .gmii_tx_er(gmii_tx_er_link7),
    .gmii_txd(gmii_txd_link7)
);

sgmii_config sgmii_config_inst7(
    .clk(clk_50M),
    .reset(rst_n),
    
    .reg_data_out(reg_data_out_link7),
    .reg_rd(reg_rd_link7),
    .reg_data_in(reg_data_in_link7),
    .reg_wr(reg_wr_link7),
    .reg_busy(reg_busy_link7),
    .reg_addr(reg_addr_link7),

    .led_link(led_link_link7),
    .led_an(FACE_SYS_LED[7])
);
 
sgmii_pcs_8port sgmii_pcs_8port_inst(
    .clk                   (clk_50M),                                          // control_port_clock_connection.clk
    .reset                 (!rst_n),                                           //              reset_connection.reset
    .ref_clk               (SGMII_LVDS_REFCLK),                                     //  pcs_ref_clk_clock_connection.clk

    .rxp_0                 (SGMII_LVDS_RXD[0]),                                     //             serial_connection.rxp_0
    .txp_0                 (SGMII_LVDS_TXD[0]),                                     //                              .txp_0
    .reg_addr_0            (reg_addr_link0),                                   //                  control_port.address
    .reg_data_out_0        (reg_data_out_link0),                               //                              .readdata
    .reg_rd_0              (reg_rd_link0),                                     //                              .read
    .reg_data_in_0         (reg_data_in_link0),                                //                              .writedata
    .reg_wr_0              (reg_wr_link0),                                     //                              .write
    .reg_busy_0            (reg_busy_link0),                                   //                              .waitrequest
    .tx_clk_0              (PCS_tx_clk_inst0),                                 // pcs_transmit_clock_connection.clk
    .rx_clk_0              (PCS_rx_clk_inst0),                                 //  pcs_receive_clock_connection.clk
    .reset_tx_clk_0        (1'b0),                                             // pcs_transmit_reset_connection.reset
    .reset_rx_clk_0        (1'b0),                                             //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_0          (gmii_rx_dv_link0),                                 //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_0           (gmii_rxd_link0),                                   //                              .gmii_rx_d
    .gmii_rx_err_0         (gmii_rx_er_link0),                                 //                              .gmii_rx_err
    .gmii_tx_en_0          (gmii_tx_en_link0),                                 //                              .gmii_tx_en
    .gmii_tx_d_0           (gmii_txd_link0),                                   //                              .gmii_tx_d
    .gmii_tx_err_0         (gmii_tx_er_link0),                                 //                              .gmii_tx_err
    .led_crs_0             (),                                                 //         status_led_connection.crs
    .led_link_0            (led_link_link0),                                   //                              .link
    .led_panel_link_0      (),                                                 //                              .panel_link
    .led_col_0             (),                                                 //                              .col
    .led_an_0              (FACE_SYS_LED[0]),                                           //                              .an
    .led_char_err_0        (),                                                 //                              .char_err
    .led_disp_err_0        (),                                                 //                              .disp_err
    .rx_recovclkout_0      (),                                                 //     serdes_control_connection.export

    .rxp_1                 (SGMII_LVDS_RXD[1]),                                     //             serial_connection.rxp_1
    .txp_1                 (SGMII_LVDS_TXD[1]),                                     //                              .txp_1
    .reg_addr_1            (reg_addr_link1),                                   //                  control_port.address
    .reg_data_out_1        (reg_data_out_link1),                               //                              .readdata
    .reg_rd_1              (reg_rd_link1),                                     //                              .read
    .reg_data_in_1         (reg_data_in_link1),                                //                              .writedata
    .reg_wr_1              (reg_wr_link1),                                     //                              .write
    .reg_busy_1            (reg_busy_link1),                                   //                              .waitrequest
    .tx_clk_1              (PCS_tx_clk_inst1),                                 // pcs_transmit_clock_connection.clk
    .rx_clk_1              (PCS_rx_clk_inst1),                                 //  pcs_receive_clock_connection.clk
    .reset_tx_clk_1        (1'b0),                                             // pcs_transmit_reset_connection.reset
    .reset_rx_clk_1        (1'b0),                                             //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_1          (gmii_rx_dv_link1),                                 //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_1           (gmii_rxd_link1),                                   //                              .gmii_rx_d
    .gmii_rx_err_1         (gmii_rx_er_link1),                                 //                              .gmii_rx_err
    .gmii_tx_en_1          (gmii_tx_en_link1),                                 //                              .gmii_tx_en
    .gmii_tx_d_1           (gmii_txd_link1),                                   //                              .gmii_tx_d
    .gmii_tx_err_1         (gmii_tx_er_link1),                                 //                              .gmii_tx_err
    .led_crs_1             (),                                                 //         status_led_connection.crs
    .led_link_1            (led_link_link1),                                   //                              .link
    .led_panel_link_1      (),                                                 //                              .panel_link
    .led_col_1             (),                                                 //                              .col
    .led_an_1              (FACE_SYS_LED[1]),                                           //                              .an
    .led_char_err_1        (),                                                 //                              .char_err
    .led_disp_err_1        (),                                                 //                              .disp_err
    .rx_recovclkout_1      (),                                                 //     serdes_control_connection.export

    .rxp_2                 (SGMII_LVDS_RXD[2]),                                     //             serial_connection.rxp_2
    .txp_2                 (SGMII_LVDS_TXD[2]),                                     //                              .txp_2
    .reg_addr_2            (reg_addr_link2),                                   //                  control_port.address
    .reg_data_out_2        (reg_data_out_link2),                               //                              .readdata
    .reg_rd_2              (reg_rd_link2),                                     //                              .read
    .reg_data_in_2         (reg_data_in_link2),                                //                              .writedata
    .reg_wr_2              (reg_wr_link2),                                     //                              .write
    .reg_busy_2            (reg_busy_link2),                                   //                              .waitrequest
    .tx_clk_2              (PCS_tx_clk_inst2),                                 // pcs_transmit_clock_connection.clk
    .rx_clk_2              (PCS_rx_clk_inst2),                                 //  pcs_receive_clock_connection.clk
    .reset_tx_clk_2        (1'b0),                                             // pcs_transmit_reset_connection.reset
    .reset_rx_clk_2        (1'b0),                                             //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_2          (gmii_rx_dv_link2),                                 //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_2           (gmii_rxd_link2),                                   //                              .gmii_rx_d
    .gmii_rx_err_2         (gmii_rx_er_link2),                                 //                              .gmii_rx_err
    .gmii_tx_en_2          (gmii_tx_en_link2),                                 //                              .gmii_tx_en
    .gmii_tx_d_2           (gmii_txd_link2),                                   //                              .gmii_tx_d
    .gmii_tx_err_2         (gmii_tx_er_link2),                                 //                              .gmii_tx_err
    .led_crs_2             (),                                                 //         status_led_connection.crs
    .led_link_2            (led_link_link2),                                   //                              .link
    .led_panel_link_2      (),                                                 //                              .panel_link
    .led_col_2             (),                                                 //                              .col
    .led_an_2              (FACE_SYS_LED[2]),                                           //                              .an
    .led_char_err_2        (),                                                 //                              .char_err
    .led_disp_err_2        (),                                                 //                              .disp_err
    .rx_recovclkout_2      (),                                                 //     serdes_control_connection.export

    .rxp_3                 (SGMII_LVDS_RXD[3]),                                     //             serial_connection.rxp_3
    .txp_3                 (SGMII_LVDS_TXD[3]),                                     //                              .txp_3
    .reg_addr_3            (reg_addr_link3),                                   //                  control_port.address
    .reg_data_out_3        (reg_data_out_link3),                               //                              .readdata
    .reg_rd_3              (reg_rd_link3),                                     //                              .read
    .reg_data_in_3         (reg_data_in_link3),                                //                              .writedata
    .reg_wr_3              (reg_wr_link3),                                     //                              .write
    .reg_busy_3            (reg_busy_link3),                                   //                              .waitrequest
    .tx_clk_3              (PCS_tx_clk_inst3),                                 // pcs_transmit_clock_connection.clk
    .rx_clk_3              (PCS_rx_clk_inst3),                                 //  pcs_receive_clock_connection.clk
    .reset_tx_clk_3        (1'b0),                                             // pcs_transmit_reset_connection.reset
    .reset_rx_clk_3        (1'b0),                                             //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_3          (gmii_rx_dv_link3),                                 //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_3           (gmii_rxd_link3),                                   //                              .gmii_rx_d
    .gmii_rx_err_3         (gmii_rx_er_link3),                                 //                              .gmii_rx_err
    .gmii_tx_en_3          (gmii_tx_en_link3),                                 //                              .gmii_tx_en
    .gmii_tx_d_3           (gmii_txd_link3),                                   //                              .gmii_tx_d
    .gmii_tx_err_3         (gmii_tx_er_link3),                                 //                              .gmii_tx_err
    .led_crs_3             (),                                                 //         status_led_connection.crs
    .led_link_3            (led_link_link3),                                   //                              .link
    .led_panel_link_3      (),                                                 //                              .panel_link
    .led_col_3             (),                                                 //                              .col
    .led_an_3              (FACE_SYS_LED[3]),                                           //                              .an
    .led_char_err_3        (),                                                 //                              .char_err
    .led_disp_err_3        (),                                                 //                              .disp_err
    .rx_recovclkout_3      (),                                                 //     serdes_control_connection.export

    .rxp_4                 (SGMII_LVDS_RXD[4]),                                     //             serial_connection.rxp_4
    .txp_4                 (SGMII_LVDS_TXD[4]),                                     //                              .txp_4
    .reg_addr_4            (reg_addr_link4),                                   //                  control_port.address
    .reg_data_out_4        (reg_data_out_link4),                               //                              .readdata
    .reg_rd_4              (reg_rd_link4),                                     //                              .read
    .reg_data_in_4         (reg_data_in_link4),                                //                              .writedata
    .reg_wr_4              (reg_wr_link4),                                     //                              .write
    .reg_busy_4            (reg_busy_link4),                                   //                              .waitrequest
    .tx_clk_4              (PCS_tx_clk_inst4),                                 // pcs_transmit_clock_connection.clk
    .rx_clk_4              (PCS_rx_clk_inst4),                                 //  pcs_receive_clock_connection.clk
    .reset_tx_clk_4        (1'b0),                                             // pcs_transmit_reset_connection.reset
    .reset_rx_clk_4        (1'b0),                                             //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_4          (gmii_rx_dv_link4),                                 //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_4           (gmii_rxd_link4),                                   //                              .gmii_rx_d
    .gmii_rx_err_4         (gmii_rx_er_link4),                                 //                              .gmii_rx_err
    .gmii_tx_en_4          (gmii_tx_en_link4),                                 //                              .gmii_tx_en
    .gmii_tx_d_4           (gmii_txd_link4),                                   //                              .gmii_tx_d
    .gmii_tx_err_4         (gmii_tx_er_link4),                                 //                              .gmii_tx_err
    .led_crs_4             (),                                                 //         status_led_connection.crs
    .led_link_4            (led_link_link4),                                   //                              .link
    .led_panel_link_4      (),                                                 //                              .panel_link
    .led_col_4             (),                                                 //                              .col
    .led_an_4              (FACE_SYS_LED[4]),                                           //                              .an
    .led_char_err_4        (),                                                 //                              .char_err
    .led_disp_err_4        (),                                                 //                              .disp_err
    .rx_recovclkout_4      (),                                                 //     serdes_control_connection.export

    .rxp_5                 (SGMII_LVDS_RXD[5]),                                     //             serial_connection.rxp_5
    .txp_5                 (SGMII_LVDS_TXD[5]),                                     //                              .txp_5
    .reg_addr_5            (reg_addr_link5),                                   //                  control_port.address
    .reg_data_out_5        (reg_data_out_link5),                               //                              .readdata
    .reg_rd_5              (reg_rd_link5),                                     //                              .read
    .reg_data_in_5         (reg_data_in_link5),                                //                              .writedata
    .reg_wr_5              (reg_wr_link5),                                     //                              .write
    .reg_busy_5            (reg_busy_link5),                                   //                              .waitrequest
    .tx_clk_5              (PCS_tx_clk_inst5),                                 // pcs_transmit_clock_connection.clk
    .rx_clk_5              (PCS_rx_clk_inst5),                                 //  pcs_receive_clock_connection.clk
    .reset_tx_clk_5        (1'b0),                                             // pcs_transmit_reset_connection.reset
    .reset_rx_clk_5        (1'b0),                                             //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_5          (gmii_rx_dv_link5),                                 //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_5           (gmii_rxd_link5),                                   //                              .gmii_rx_d
    .gmii_rx_err_5         (gmii_rx_er_link5),                                 //                              .gmii_rx_err
    .gmii_tx_en_5          (gmii_tx_en_link5),                                 //                              .gmii_tx_en
    .gmii_tx_d_5           (gmii_txd_link5),                                   //                              .gmii_tx_d
    .gmii_tx_err_5         (gmii_tx_er_link5),                                 //                              .gmii_tx_err
    .led_crs_5             (),                                                 //         status_led_connection.crs
    .led_link_5            (led_link_link5),                                   //                              .link
    .led_panel_link_5      (),                                                 //                              .panel_link
    .led_col_5             (),                                                 //                              .col
    .led_an_5              (FACE_SYS_LED[5]),                                           //                              .an
    .led_char_err_5        (),                                                 //                              .char_err
    .led_disp_err_5        (),                                                 //                              .disp_err
    .rx_recovclkout_5      (),                                                 //     serdes_control_connection.export

    .rxp_6                 (SGMII_LVDS_RXD[6]),                                     //             serial_connection.rxp_6
    .txp_6                 (SGMII_LVDS_TXD[6]),                                     //                              .txp_6
    .reg_addr_6            (reg_addr_link6),                                   //                  control_port.address
    .reg_data_out_6        (reg_data_out_link6),                               //                              .readdata
    .reg_rd_6              (reg_rd_link6),                                     //                              .read
    .reg_data_in_6         (reg_data_in_link6),                                //                              .writedata
    .reg_wr_6              (reg_wr_link6),                                     //                              .write
    .reg_busy_6            (reg_busy_link6),                                   //                              .waitrequest
    .tx_clk_6              (PCS_tx_clk_inst6),                                 // pcs_transmit_clock_connection.clk
    .rx_clk_6              (PCS_rx_clk_inst6),                                 //  pcs_receive_clock_connection.clk
    .reset_tx_clk_6        (1'b0),                                             // pcs_transmit_reset_connection.reset
    .reset_rx_clk_6        (1'b0),                                             //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_6          (gmii_rx_dv_link6),                                 //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_6           (gmii_rxd_link6),                                   //                              .gmii_rx_d
    .gmii_rx_err_6         (gmii_rx_er_link6),                                 //                              .gmii_rx_err
    .gmii_tx_en_6          (gmii_tx_en_link6),                                 //                              .gmii_tx_en
    .gmii_tx_d_6           (gmii_txd_link6),                                   //                              .gmii_tx_d
    .gmii_tx_err_6         (gmii_tx_er_link6),                                 //                              .gmii_tx_err
    .led_crs_6             (),                                                 //         status_led_connection.crs
    .led_link_6            (led_link_link6),                                   //                              .link
    .led_panel_link_6      (),                                                 //                              .panel_link
    .led_col_6             (),                                                 //                              .col
    .led_an_6              (FACE_SYS_LED[6]),                                           //                              .an
    .led_char_err_6        (),                                                 //                              .char_err
    .led_disp_err_6        (),                                                 //                              .disp_err
    .rx_recovclkout_6      (),                                                 //     serdes_control_connection.export

    .rxp_7                 (SGMII_LVDS_RXD[7]),                                     //             serial_connection.rxp_7
    .txp_7                 (SGMII_LVDS_TXD[7]),                                     //                              .txp_7
    .reg_addr_7            (reg_addr_link7),                                   //                  control_port.address
    .reg_data_out_7        (reg_data_out_link7),                               //                              .readdata
    .reg_rd_7              (reg_rd_link7),                                     //                              .read
    .reg_data_in_7         (reg_data_in_link7),                                //                              .writedata
    .reg_wr_7              (reg_wr_link7),                                     //                              .write
    .reg_busy_7            (reg_busy_link7),                                   //                              .waitrequest
    .tx_clk_7              (PCS_tx_clk_inst7),                                 // pcs_transmit_clock_connection.clk
    .rx_clk_7              (PCS_rx_clk_inst7),                                 //  pcs_receive_clock_connection.clk
    .reset_tx_clk_7        (1'b0),                                             // pcs_transmit_reset_connection.reset
    .reset_rx_clk_7        (1'b0),                                             //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_7          (gmii_rx_dv_link7),                                 //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_7           (gmii_rxd_link7),                                   //                              .gmii_rx_d
    .gmii_rx_err_7         (gmii_rx_er_link7),                                 //                              .gmii_rx_err
    .gmii_tx_en_7          (gmii_tx_en_link7),                                 //                              .gmii_tx_en
    .gmii_tx_d_7           (gmii_txd_link7),                                   //                              .gmii_tx_d
    .gmii_tx_err_7         (gmii_tx_er_link7),                                 //                              .gmii_tx_err
    .led_crs_7             (),                                                 //         status_led_connection.crs
    .led_link_7            (led_link_link7),                                   //                              .link
    .led_panel_link_7      (),                                                 //                              .panel_link
    .led_col_7             (),                                                 //                              .col
    .led_an_7              (FACE_SYS_LED[7]),                                           //                              .an
    .led_char_err_7        (),                                                 //                              .char_err
    .led_disp_err_7        (),                                                 //                              .disp_err
    .rx_recovclkout_7      ()                                                //     serdes_control_connection.export               

/*
    .clk            (clk_50M),             // control_port_clock_connection.clk
    .reset          (!rst_n),              //              reset_connection.reset
    .ref_clk        (SGMII_LVDS_REFCLK),        //  pcs_ref_clk_clock_connection.clk
        
    .rxp_0            (SGMII_RXD[0]),            //             serial_connection.rxp_0
    .txp_0            (SGMII_TXD[0]),            //                              .txp_0
    .reg_addr_0       (reg_addr_link0),       //                  control_port.address
    .reg_data_out_0   (reg_data_out_link0),   //                              .readdata
    .reg_rd_0         (reg_rd_link0),         //                              .read
    .reg_data_in_0    (reg_data_in_link0),    //                              .writedata
    .reg_wr_0         (reg_wr_link0),         //                              .write
    .reg_busy_0       (reg_busy_link0),       //                              .waitrequest
    .tx_clk_0         (PCS_tx_clk_inst0),         // pcs_transmit_clock_connection.clk
    .rx_clk_0         (PCS_rx_clk_inst0),         //  pcs_receive_clock_connection.clk
    .reset_tx_clk_0   (1'b0),                      // pcs_transmit_reset_connection.reset
    .reset_rx_clk_0   (1'b0),                     //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_0     (gmii_rx_dv_link0),     //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_0      (gmii_rxd_link0),      //                              .gmii_rx_d
    .gmii_rx_err_0    (gmii_rx_er_link0),    //                              .gmii_rx_err
    .gmii_tx_en_0     (gmii_tx_en_link0),     //                              .gmii_tx_en
    .gmii_tx_d_0      (gmii_txd_link0),      //                              .gmii_tx_d
    .gmii_tx_err_0    (gmii_tx_er_link0),    //                              .gmii_tx_err
    .led_crs_0        (),                       //         status_led_connection.crs
    .led_link_0       (led_link_link0),       //                              .link
    .led_panel_link_0 (),                         //                              .panel_link
    .led_col_0        (),                              //                              .col
    .led_an_0         (LED[0]),                        //                              .an
    .led_char_err_0   (),                         //                              .char_err
    .led_disp_err_0   (),                        //                              .disp_err
    .rx_recovclkout_0 (),                           //     serdes_control_connection.export
    
    .rxp_1            (SGMII_RXD[1]),            //             serial_connection.rxp_1
    .txp_1            (SGMII_TXD[1]),            //                              .txp_1
    .reg_addr_1       (reg_addr_link1),       //                  control_port.address
    .reg_data_out_1   (reg_data_out_link1),   //                              .readdata
    .reg_rd_1         (reg_rd_link1),         //                              .read
    .reg_data_in_1    (reg_data_in_link1),    //                              .writedata
    .reg_wr_1         (reg_wr_link1),         //                              .write
    .reg_busy_1       (reg_busy_link1),       //                              .waitrequest
    .tx_clk_1         (PCS_tx_clk_inst1),         // pcs_transmit_clock_connection.clk
    .rx_clk_1         (PCS_rx_clk_inst1),         //  pcs_receive_clock_connection.clk
    .reset_tx_clk_1   (1'b0),   // pcs_transmit_reset_connection.reset
    .reset_rx_clk_1   (1'b0),   //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_1     (gmii_rx_dv_link1),     //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_1      (gmii_rxd_link1),      //                              .gmii_rx_d
    .gmii_rx_err_1    (gmii_rx_er_link1),    //                              .gmii_rx_err
    .gmii_tx_en_1     (gmii_tx_en_link1),     //                              .gmii_tx_en
    .gmii_tx_d_1      (gmii_txd_link1),      //                              .gmii_tx_d
    .gmii_tx_err_1    (gmii_tx_er_link1),    //                              .gmii_tx_err
    .led_crs_1        (),        //         status_led_connection.crs
    .led_link_1       (led_link_link1),       //                              .link
    .led_panel_link_1 (), //                              .panel_link
    .led_col_1        (),        //                              .col
    .led_an_1         (LED[1]),         //                              .an
    .led_char_err_1   (),   //                              .char_err
    .led_disp_err_1   (),   //                              .disp_err
    .rx_recovclkout_1 (),  //     serdes_control_connection.export
    
    .rxp_2            (SGMII_RXD[2]),            //             serial_connection.rxp_2
    .txp_2            (SGMII_TXD[2]),            //                              .txp_2
    .reg_addr_2       (reg_addr_link2),       //                  control_port.address
    .reg_data_out_2   (reg_data_out_link2),   //                              .readdata
    .reg_rd_2         (reg_rd_link2),         //                              .read
    .reg_data_in_2    (reg_data_in_link2),    //                              .writedata
    .reg_wr_2         (reg_wr_link2),         //                              .write
    .reg_busy_2       (reg_busy_link2),       //                              .waitrequest
    .tx_clk_2         (PCS_tx_clk_inst2),         // pcs_transmit_clock_connection.clk
    .rx_clk_2         (PCS_rx_clk_inst2),         //  pcs_receive_clock_connection.clk
    .reset_tx_clk_2   (1'b0),   // pcs_transmit_reset_connection.reset
    .reset_rx_clk_2   (1'b0),   //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_2     (gmii_rx_dv_link2),     //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_2      (gmii_rxd_link2),      //                              .gmii_rx_d
    .gmii_rx_err_2    (gmii_rx_er_link2),    //                              .gmii_rx_err
    .gmii_tx_en_2     (gmii_tx_en_link2),     //                              .gmii_tx_en
    .gmii_tx_d_2      (gmii_txd_link2),      //                              .gmii_tx_d
    .gmii_tx_err_2    (gmii_tx_er_link2),    //                              .gmii_tx_err
    .led_crs_2        (),        //         status_led_connection.crs
    .led_link_2       (led_link_link2),       //                              .link
    .led_panel_link_2 (), //                              .panel_link
    .led_col_2        (),        //                              .col
    .led_an_2         (LED[2]),         //                              .an
    .led_char_err_2   (),   //                              .char_err
    .led_disp_err_2   (),   //                              .disp_err
    .rx_recovclkout_2 (),  //     serdes_control_connection.export
    
    .rxp_3            (SGMII_RXD[3]),            //             serial_connection.rxp_3
    .txp_3            (SGMII_TXD[3]),            //                              .txp_3
    .reg_addr_3       (reg_addr_linkhost),       //                  control_port.address
    .reg_data_out_3   (reg_data_out_linkhost),   //                              .readdata
    .reg_rd_3         (reg_rd_linkhost),         //                              .read
    .reg_data_in_3    (reg_data_in_linkhost),    //                              .writedata
    .reg_wr_3         (reg_wr_linkhost),         //                              .write
    .reg_busy_3       (reg_busy_linkhost),       //                              .waitrequest
    .tx_clk_3         (PCS_tx_clk_host),         // pcs_transmit_clock_connection.clk
    .rx_clk_3         (PCS_rx_clk_host),         //  pcs_receive_clock_connection.clk
    .reset_tx_clk_3   (1'b0),   // pcs_transmit_reset_connection.reset
    .reset_rx_clk_3   (1'b0),   //  pcs_receive_reset_connection.reset
    .gmii_rx_dv_3     (gmii_rx_dv_linkhost),     //               gmii_connection.gmii_rx_dv
    .gmii_rx_d_3      (gmii_rxd_linkhost),      //                              .gmii_rx_d
    .gmii_rx_err_3    (gmii_rx_er_linkhost),    //                              .gmii_rx_err
    .gmii_tx_en_3     (gmii_tx_en_linkhost),     //                              .gmii_tx_en
    .gmii_tx_d_3      (gmii_txd_linkhost),      //                              .gmii_tx_d
    .gmii_tx_err_3    (gmii_tx_er_linkhost),    //                              .gmii_tx_err
    .led_crs_3        (),        //         status_led_connection.crs
    .led_link_3       (led_link_linkhost),       //                              .link
    .led_panel_link_3 (), //                              .panel_link
    .led_col_3        (),        //                              .col
    .led_an_3         (LED[3]),         //                              .an
    .led_char_err_3   (),   //                              .char_err
    .led_disp_err_3   (),   //                              .disp_err
    .rx_recovclkout_3 ()  //     serdes_control_connection.export
*/
);

sgmii_pcs_1port sgmii_pcs_1port_inst(
    .clk            (clk_50M),            // control_port_clock_connection.clk
    .reset          (!rst_n),          //              reset_connection.reset
    .ref_clk        (VSC8211_GXB_REFCLK),        //  pcs_ref_clk_clock_connection.clk
        
    .rxp            (VSC8211_GXB_RXD),            //             serial_connection.rxp_0
    .txp            (VSC8211_GXB_TXD),            //                              .txp_0
    .reg_addr       (reg_addr_linkhost),       //                  control_port.address
    .reg_data_out   (reg_data_out_linkhost),   //                              .readdata
    .reg_rd         (reg_rd_linkhost),         //                              .read
    .reg_data_in    (reg_data_in_linkhost),    //                              .writedata
    .reg_wr         (reg_wr_linkhost),         //                              .write
    .reg_busy       (reg_busy_linkhost),       //                              .waitrequest
    .tx_clk         (PCS_tx_clk_host),         // pcs_transmit_clock_connection.clk
    .rx_clk         (PCS_rx_clk_host),         //  pcs_receive_clock_connection.clk
    .reset_tx_clk   (1'b0),   // pcs_transmit_reset_connection.reset
    .reset_rx_clk   (1'b0),   //  pcs_receive_reset_connection.reset
    .gmii_rx_dv     (gmii_rx_dv_linkhost),     //               gmii_connection.gmii_rx_dv
    .gmii_rx_d      (gmii_rxd_linkhost),      //                              .gmii_rx_d
    .gmii_rx_err    (gmii_rx_er_linkhost),    //                              .gmii_rx_err
    .gmii_tx_en     (gmii_tx_en_linkhost),     //                              .gmii_tx_en
    .gmii_tx_d      (gmii_txd_linkhost),      //                              .gmii_tx_d
    .gmii_tx_err   (gmii_tx_er_linkhost),    //                              .gmii_tx_err
    .led_crs        (),        //         status_led_connection.crs
    .led_link       (led_link_linkhost),       //                              .link
    .led_panel_link (), //                              .panel_link
    .led_col       (),        //                              .col
    .led_an         (FACE_SYS_LED[8]),         //                              .an
    .led_char_err   (),   //                              .char_err
    .led_disp_err   (),   //                              .disp_err
    .rx_recovclkout () //     serdes_control_connection.export                       
);
endmodule


  
  
     
     
     
     
     
     
     
     
  
  
     
     
     
     
     
     
  
     
  
  
  
  
  
 