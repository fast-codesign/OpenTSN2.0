derive_pll_clocks
derive_clock_uncertainty
create_clock -name FPGA_SYS_CLK -period 8.000 -waveform {0 4} [get_ports {FPGA_SYS_CLK}]
create_clock -name VSC8211_GXB_REFCLK -period 8.000 -waveform {0 4} [get_ports {VSC8211_GXB_REFCLK}]
create_clock -name SGMII_LVDS_REFCLK -period 8.000 -waveform {0 4} [get_ports {SGMII_LVDS_REFCLK}]