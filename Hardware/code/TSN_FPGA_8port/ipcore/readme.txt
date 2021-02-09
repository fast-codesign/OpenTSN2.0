#custom ip
Custom 26 IP cores used in the project in Inter Quartus  and  put qsys file and IP core folder generated in current directory; information of those IP cores is as follow.
number_1 ip core : 
    Ip_core_name: clk125M_50M125M
    Device Family:Arria 10
    Component:10AX048H2F34I2SG
    Speed Grade:2
    Reference Clock Frequency : 125.0 MHz
    Enable locked output port : selected
    Compensation Mode : direct
    Number Of Clocks : 2
    Clock Name of outclk0 : clk_50M
    Desired Frequency of outclk0 : 50.0 MHz
    Phase Shift Units of outclk0 : ps
    Desired Phase Shift of outclk0 : 0.0  
    Desired  Duty Cycle of outclk0 : 50.0%
    Clock Name of outclk1 : clk_125M
    Desired Frequency of outclk0 : 125.0 MHz
    Phase Shift Units of outclk0 : ps
    Desired Phase Shift of outclk0 : 0.0  
    Desired  Duty Cycle of outclk0 : 50.0%
    PLL Bandwidth Preset : Low
    Others:default

number_2 ip core: 
    Ip_core_name: sgmii_pcs_share
    Core variation : 10/100/1000Mb Ethernet MAC with 1000BASE-X/sgmii pcs
    Number of ports : 4
    Transceiver type : LVDS I/O
    PHY ID : 0x00000000
    Others:default

number_3 ip core:
    Ip_core_name: asdprf16x8_rq
    Operation Mode:With one read port and one write port
    Ram_width:8
    Ram_depth:16
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

number_4 ip core:
    Ip_core_name: asdprf16x9_rq
    Operation Mode:With one read port and one write port
    Ram_width:9
    Ram_depth:16
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

number_5 ip core:
    Ip_core_name: sdprf32x36_rq
    Operation Mode:With one read port and one write port
    Ram_width:36
    Ram_depth:32
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

number_6 ip core:
    Ip_core_name: suhddpsram1024x16_rq
    Operation Mode:With two read/write ports
    Ram_width:16
    Ram_depth:1024
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
   Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

number_7 ip core:
    Ip_core_name: sdprf256x13_s
    Operation Mode:With one read port and one write port
    Ram_width:13
    Ram_depth:256
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

number_8 ip core
    Ip_core_name: sdprf32x13_rq
    Operation Mode:With one read port and one write port
    Ram_width:13
    Ram_depth:32
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

number_9 ip core:
    Ip_core_name: sdprf512x9_s
    Operation Mode:With one read port and one write port
    Ram_width:9
    Ram_depth:512
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

number_10 ip core:
    Ip_core_name: suhddpsram1024x8_rq
    Operation Mode:With two read/write ports
    Ram_width:8
    Ram_depth:1024
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

number_11 ip core:
    Ip_core_name: suhddpsram16384x9_s
    Operation Mode:With two read/write ports
    Ram_width:9
    Ram_depth:16384
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

number_12 ip core:
    Ip_core_name: suhddpsram65536x134_s
    Operation Mode:With two read/write ports
    Ram_width:134
    Ram_depth:65536
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

number_13 ip core:
    Ip_core_name: suhddpsram512x4_rq
    Operation Mode:With two read/write ports
    Ram_width:4
    Ram_depth:512
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

number_14 ip core:
    Ip_core_name: DCFIFO_10bit_64
    Fifo_width:10
    Fifo_depth:64
    Clock for reading and writing the FIFO : synchronize reading and writing to 'rdclk' and 'wrclk', respectively.
    Asynchronous clear: selected
    Read access:Normal synchronous FIFO mode
    Others:default

number_15 ip core:
    Ip_core_name: fifo_9_16
    Fifo_width:9
    Fifo_depth:16
    Clock for reading and writing the FIFO : synchronize reading and writing to 'rdclk' and 'wrclk', respectively.
    Asynchronous clear: selected
    Read access:show_ahead synchronous FIFO mode
    Others:default

number_16 ip core:
    Ip_core_name: fifo_64_4
    Fifo_width:64
    Fifo_depth:4
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Others:default

number_17 ip core:
    Ip_core_name: fifo_134_128
    Fifo_width:134
    Fifo_depth:128
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Others:default

number_18 ip core:
    Ip_core_name: fifo_134_512
    Fifo_width:134
    Fifo_depth:512
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Others:default

number_19 ip core:
    Ip_core_name: fifo_pkt_data_64_134
    Fifo_width:134
    Fifo_depth:64
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Others:default

number_20 ip core:
    Ip_core_name: fifo_tsntag_4_48
    Fifo_width:48
    Fifo_depth:4
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Others:default

number_21 ip core:
    Ip_core_name: ram_5tuple_32_131
    Operation Mode:With two read/write ports
    Ram_width:131
    Ram_depth:32
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Others:default

number_22 ip core:
    Ip_core_name: ram_tsntag_8_48
    Operation Mode:With one read port and one write port
    Ram_width:48
    Ram_depth:8
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

number_23 ip core:
    Ip_core_name: ram_19_32
    Operation Mode:With one read port and one write port
    Ram_width:19
    Ram_depth:32
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

number_24 ip core:
    Ip_core_name: ram_134_4096
    Operation Mode:With one read port and one write port
    Ram_width:134
    Ram_depth:4096
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

number_25 ip core:
    Ip_core_name: ram_10_512
    Operation Mode:With one read port and one write port
    Ram_width:10
    Ram_depth:512
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

number_26 ip core:
    Ip_core_name: ram_71_256
    Operation Mode:With two read/write ports
    Ram_width:71
    Ram_depth:256
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Others:default