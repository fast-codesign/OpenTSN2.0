/** *************************************************************************
 *  @file          local_mange.c
 *  @brief	  本地管理模块，用于对TSN芯片的寄存器进行配置，并且发送2个be报文和一个1个ts报文
 				两个be报文分别从主机口发送，网络口发出，网络口接收，主机口发送，ts报文从主机口发送，主机口接收
 * 
 *  详细说明
 * 
 *  @date	   2020/07/08 
 *  @author		junshuai.li
 *  @email		1145331404@qq.com
 *  @version	1.0
 ****************************************************************************/

#ifndef _LOCAL_MANGE_H__
#define _LOCAL_MANGE_H__



#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include<stdlib.h>
#include <pthread.h>
#include<malloc.h>


#include "../../include/np.h" 


typedef char s8;				/**< 有符号的8位（1字节）数据定义*/
typedef unsigned char u8;		/**< 无符号的8位（1字节）数据定义*/
typedef short s16;				/**< 有符号的16位（2字节）数据定义*/
typedef unsigned short u16;	/**< 无符号的16位（2字节）数据定义*/
typedef int s32;				/**< 有符号的32位（4字节）数据定义*/
typedef unsigned int u32;		/**< 无符号的32位（4字节）数据定义*/
typedef long long s64;				/**< 有符号的64位（8字节）数据定义*/
typedef unsigned long long u64;		/**< 无符号的64位（8字节）数据定义*/

#define LOCAL_MANGE_DEBUG 1

#if LOCAL_MANGE_DEBUG
	#define LOCAL_MANGE_DBG(args...) do{printf("TIMER-INFO:");printf(args);}while(0)
	#define LOCAL_MANGE_ERR(args...) do{printf("TIMER-ERROR:");printf(args);}while(0)
#else
	#define LOCAL_MANGE_DBG(args...)
	#define LOCAL_MANGE_ERR(args...)
#endif


enum cfg_type
{

	cfg_finish = 0,//配置就绪寄存器
	port_type = 1,//端口类型
	slot_length = 2,//时间槽长度
	slot_num_inject = 3,
	slot_num_submit = 4,
	report_type = 5,
	report_en = 6,
	report_period = 7,
	rc_regulation_value = 8,
	be_regulation_value = 9,
	unmap_regulation_value = 10,
	qbv_qch       = 13,
	
};

enum opt_type
{

	opt_read = 0,//配置就绪寄存器
	opt_write = 1,//端口类型
	
	
};

enum reg_ram_type
{

	TYPE_REG      = 3,//
	TYPE_FORWARD  = 4,//
	TYPE_INJECT   = 5,//
	TYPE_SUBMIT   = 6,//	
	TYPE_GATE_IN  = 7,//
	TYPE_GATE_OUT = 8,//	
	
};


struct nmac_pkt
{
#ifdef TSN
	u16 pkt_len;
	u16 interal_time;
#endif

	u8 inject_addr:5,
		pkttype:3;


	u8 md[7];//

	u8 dst_mac[6];
	u8 src_mac[6];
	u16 ether_type;
	u8 count;
	u8 type;
	u32 addr;
	u32 data[27];
	
}__attribute__((packed));




struct ptp_packet
{

	u16 pkt_len;
	u16 interal_time;
	//MD
	u8 inject_addr:5,
		pkttype:3;
	u8 md[7];//

	u8 dst_mac[6];//目的mac地址
	u8 src_mac[6];//源mac地址
	u16 eth_type;//协议类型，暂定为0x88F7
	u16 msg_type:4,//msg_type和transpec换位置进行主机序转网络序
		transpec:4,		
		reserve0:4,//reserve0和ver_ptp换位置进行主机序转网络序		
		ver_ptp:4;
	u16 tmp_pkt_len;//报文长度
	u8	domain_no;//域号
	u8 	reserve1;
	u16	flag;//控制信息标志位
	u64	correct_field;//透明时钟的修正域
	u16	seq;//序列号
	u8 pad[16];
	u16 timestamp[5];	//时间戳
	u8 reserve2[6];
	u8 data[80];
}__attribute__((packed));


#define GATE_PORT_NUM   8
#define GATE_PORT_DEPTH 1024



struct reg_info
{
	u16 slot_length;//时间槽的长度	
	u8 port_type;//端口类型
	u16 inject_slot_period;//slot的周期 1 2 4 8 16 32 64 128 256 512 1024,门控使用注入时间槽
	u16 submit_slot_period;//slot的周期 1 2 4 8 16 32 64 128 256 512 1024
	u16 gate_depth;//配置的门控深度，门控的周期由注入时间槽周期决定 
	u8 qbv_qch;//0表示qbv，1表示qch
	u16 report_type;
	u16 report_en;
	u16 report_period;
	u16 rc_regulation_value;
	u16 be_regulation_value;
	u16 unmap_regulation_value;
}__attribute__((packed));

struct forward_info
{
	u16 imac_flowid;//imac或者flowID	
	u16 outport;//输出端口
	struct forward_info *next;
}__attribute__((packed));


struct inject_time
{
	u8  valid;//有效位	
	u16 cur_time_slot;//当前时间槽
	u8 inject_addr;//保存存储的地址
	struct inject_time *next;
}__attribute__((packed));

struct submit_time
{
	u8  valid;//有效位	
	u16 cur_time_slot;//当前时间槽
	u8 submit_addr;//保存提交的地址
	struct submit_time *next;
}__attribute__((packed));



struct chip_cfg_info
{
	struct reg_info reg_state;

	struct forward_info *forward_node;//转发表节点头指针
	struct inject_time *inject_node;// 注入时刻表头指针
	struct submit_time * submit_node;//提交时刻表头指针
	//u8 gate_in[GATE_PORT_NUM][GATE_PORT_DEPTH];//二维数组的形式，每个值代表当前时刻8个队列的门控状态
	u8 gate_out[GATE_PORT_NUM][GATE_PORT_DEPTH];//二维数组的形式，每个值代表当前时刻8个队列的门控状态
};




int hx_local_mange_handler();
struct eth_pkt_info build_offset_pkt(u32 l_offset,u32 h_offset);
struct eth_pkt_info build_offset_period(u32 offset_period);



#endif


