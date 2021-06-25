#ifndef _MAP_SERVICE_H_
#define _MAP_SERVICE_H_

#include<time.h>
#include<stdio.h>
#include<string.h>
#include<stdlib.h>

#include <pthread.h>
#include<malloc.h>
#include <sys/time.h>
#include <signal.h>
#include <unistd.h>
#include "../../include/np.h"
//#include "../include/table_operations.h"  

#define metedata_len 8
#define map_table_len 5
#define NO_FLOW  0
#define NEW_FLOW 1

struct map_test{
	u16 len;
	u16 inval_time;
};

struct TSNtag{
	u8 flow_type; //流类型:3
	u16 flow_id; //静态流量使用flowID，每条静态流分配一个唯一flowID:14
	u16 seq_id; //用于标识每条流中报文的序列号:16
	u8 frag_flag; //用于标识分片后的报文头尾:1
	u8 frag_id; //用于表示当前分片报文在原报文中的分片序列号:4
	u8 inject_addr; // TS流在源端等待发送调度时缓存地址:5
	u8 submit_addr;// TS流在终端等待接收调度时缓存地址:5
};

struct metedata{
    u32 pkttype:3,//3
		md_inject_addr:5,//5
        outport:9,//9
        lookup_en:1,//1
        frag_last:1; //	1
    u64 reserve; //45
};

struct five_tuple_info{
	u8 src_ip[4];//源端ip地址
	u8 dst_ip[4];//目的端ip地址
	u16 src_port; //源端端口
	u16 dst_port; //目的端端口
	u8 protocol_type; //IP协议类型
};

struct map_table{
    int ID;//表项ID
	struct five_tuple_info five_tuple_init;
	struct TSNtag TSNtag_init;
	struct metedata metedata_init;
};

struct tsn_forward_pkt{
	u8 pkt_version:4,//版本
         head_len:4;//首部长度
	u8 tos;//服务类型:8
	u16 total_len; //总长度:16
	u16 pkt_log; //标识:16
	u16 pkt_id:3, //标志
 		frag_off:13; //分片偏移
	u8 ttl; //生存时间:8
	u8 protocol; //协议:8
	u16 check_sum; //检验和:16
	u8 src_ip[4]; //源IP地址
	u8 dst_ip[4]; //目的IP地址
};
void riprt_1(char *str);
void get_cfg_info();
void map_table_initial();
struct five_tuple_info form_five_tuple(u8 *eth_head_ptr);
int cmp_tuples(struct five_tuple_info *key1,struct five_tuple_info *key2);
int LUT_table(struct five_tuple_info five_tuple,struct map_table map_table_list[]);
int flow_mapping(int flow_ID,u8 *eth_head_ptr,struct map_table map_table_list[],u16 count,u16 ip_len,u16 sum_pkt_len);
struct five_tuple_info five_tuple_init(u8 src_ip[],u8 dst_ip[],u16 src_port,u16 dst_port,u8 protocol_type);
struct TSNtag TSNtag_init(u8 flow_type,u16 flow_id,u16 seq_id,u8 frag_flag,u8 frag_id,u8 inject_addr,u8 submit_addr);
struct metedata metedata_init(u8 pkttype,u8 md_inject_addr,u16 outport,u8 lookup_en,u8 frag_last,u64 reserve);
struct map_table map_table_init(int table_id,struct TSNtag TSNtag_init,struct metedata metedata_init,struct five_tuple_info five_tuple_init);
void print_five_tuple(struct five_tuple_info five_tuple);
int RC_quene_init(struct msg_quene* quene);//消息队列初始化
void RC_handler(struct msg_quene* txq,struct msg_quene* rxq,struct buf_list* head_list,struct msg_node* msg);
void map_handler(struct msg_quene* txq,struct msg_quene* rxq,struct buf_list* head_list,struct msg_node* msg,u16 count,u16 flow_id,u16 ip_len,u16 sum_pkt_len);
void hx_start_map();
int hx_map_init();






#define MAP_DEBUG 1

#if MAP_DEBUG
	#define MAP_DBG(args...) do{printf("MAP-INFO:");printf(args);}while(0)
	#define MAP_ERR(args...) do{printf("MAP-ERROR:");printf(args);}while(0)
#else
	#define MAP_DBG(args...)
	#define MAP_DBG(args...)
#endif



#endif
