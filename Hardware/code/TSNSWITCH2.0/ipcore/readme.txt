因针对不同的平台或者不同的FPGA器件，所使用的IP核生成存在差异，所以ip核文件需要自行依据提供的IP核配置参数去生成ip核。
TSN交换机硬件逻辑源码中总共使用到26个ip核文件，IP核详细配置参数如下：
（1）IP核名称: clk125M_50M125M
    Reference Clock Frequency : 125.0 MHz
    Number Of Clocks : 2
    Clock Name of outclk0 : clk_50M
    Clock Name of outclk1 : clk_125M
    PLL Bandwidth Preset : Low
    Others:default 
（2）IP核名称: sgmii_pcs_share
    Core variation : 10/100/1000Mb Ethernet MAC with 1000BASE-X/sgmii pcs
    Number of ports : 4
    Transceiver type : LVDS I/O
    PHY ID : 0x00000000
    Others:default

（3）IP核名称: asdprf16x8_rq
    Operation Mode:With one read port and one write port
    Ram_width:8
    Ram_depth:16
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（4）IP核名称: asdprf16x9_rq
    Operation Mode:With one read port and one write port
    Ram_width:9
    Ram_depth:16
    Clocking method:dual clock:use separate 'read' and 'write' clocks
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（5）IP核名称:  sdprf32x36_rq
    Operation Mode:With one read port and one write port
    Ram_width:36
    Ram_depth:32
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（6）IP核名称:  suhddpsram1024x16_rq
    Operation Mode:With two read/write ports
    Ram_width:16
    Ram_depth:1024
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
   Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

（7）IP核名称: sdprf256x13_s
    Operation Mode:With one read port and one write port
    Ram_width:13
    Ram_depth:256
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（8）IP核名称: sdprf32x13_rq
    Operation Mode:With one read port and one write port
    Ram_width:13
    Ram_depth:32
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（9）IP核名称: sdprf512x9_s
    Operation Mode:With one read port and one write port
    Ram_width:9
    Ram_depth:512
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Read input aclrs:selected
    Others:default

（10）IP核名称: suhddpsram1024x8_rq
    Operation Mode:With two read/write ports
    Ram_width:8
    Ram_depth:1024
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

（11）IP核名称: suhddpsram16384x9_s
    Operation Mode:With two read/write ports
    Ram_width:9
    Ram_depth:16384
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

（12）IP核名称: suhddpsram65536x134_s
    Operation Mode:With two read/write ports
    Ram_width:134
    Ram_depth:65536
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

（13）IP核名称: suhddpsram512x4_rq
    Operation Mode:With two read/write ports
    Ram_width:4
    Ram_depth:512
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Output aclrs:"q_a port" and "q_b port" are both selected
    Others:default

（14）IP核名称: DCFIFO_10bit_64
    Fifo_width:10
    Fifo_depth:64
    Clock for reading and writing the FIFO : synchronize reading and writing to 'rdclk' and 'wrclk', respectively.
    Asynchronous clear: selected
    Read access:Normal synchronous FIFO mode
    Others:default

（15）IP核名称: fifo_9_16
    Fifo_width:9
    Fifo_depth:16
    Clock for reading and writing the FIFO : synchronize reading and writing to 'rdclk' and 'wrclk', respectively.
    Asynchronous clear: selected
    Read access:show_ahead synchronous FIFO mode
    Others:default

（16）IP核名称: fifo_64_4
    Fifo_width:64
    Fifo_depth:4
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Others:default

（17）IP核名称: fifo_134_128
    Fifo_width:134
    Fifo_depth:128
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Others:default

（18）IP核名称: fifo_134_512
    Fifo_width:134
    Fifo_depth:512
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Others:default

（19）IP核名称: fifo_pkt_data_64_134
    Fifo_width:134
    Fifo_depth:64
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Others:default

（20）IP核名称: fifo_tsntag_4_48
    Fifo_width:48
    Fifo_depth:4
    Clock for reading and writing the FIFO : synchronize both reading and writing to 'clock'.
    Read access:show_ahead synchronous FIFO mode
    Others:default

（21）IP核名称: ram_5tuple_32_131
    Operation Mode:With two read/write ports
    Ram_width:131
    Ram_depth:32
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Others:default

（22）IP核名称: ram_tsntag_8_48
    Operation Mode:With one read port and one write port
    Ram_width:48
    Ram_depth:8
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

（23）IP核名称: ram_19_32
    Operation Mode:With one read port and one write port
    Ram_width:19
    Ram_depth:32
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

（24）IP核名称: ram_134_4096
    Operation Mode:With one read port and one write port
    Ram_width:134
    Ram_depth:4096
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

（25）IP核名称: ram_10_512
    Operation Mode:With one read port and one write port
    Ram_width:10
    Ram_depth:512
    Clocking method : Single
    Create a 'rden' read enable signal:selected
    Others:default

（26）IP核名称: ram_71_256
    Operation Mode:With two read/write ports
    Ram_width:71
    Ram_depth:256
    Clocking method : Single
    Create 'rden_a' and 'read_b' read enable signal:selected
    Others:default