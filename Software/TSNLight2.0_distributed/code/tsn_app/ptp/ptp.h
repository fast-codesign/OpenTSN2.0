#ifndef PTP_H_INCLUDED
#define PTP_H_INCLUDED

//#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include<malloc.h>
#include <unistd.h>
#include "../../include/np.h"
#include "../timer/timer.h"
#include "../../include/tools.h"
#include "../local_mange/local_mange.h"


//#define HOST_IMAC 0X0000    //可更改的主机IMAC

#if 0
//using namespace std;
typedef unsigned __int64 u64;
typedef unsigned __int32 u32;
typedef unsigned __int16 u16;
typedef unsigned __int8 u8;
#endif


int hx_ptp_init();

typedef struct{
    u8  offset_flag;
    u8  guide_offset_flag;
    u32 guide_offset_frequency;
    u64 t1;
    u64 t2;
    u64 rorr1;
    u64 t3;
    u64 offset;
    u64 guide_offset;

}ts_info;
typedef struct{
    u32 inject_addr:5,
        pkttype:3,
        outport:9,
        lookup_en:1,
        reserve1:14;
    u32 reserve2;

}metedata;

typedef struct {
    u32 flow_type:3,
        flow_id:14,
        reserve1:15;
    u16 reserve2;
}ptp_TSNTag;

typedef struct{
    u64 beats_field:17,
        microsecond_field:31,
        reserve:16;

}timeStamp;

typedef struct{
#ifdef TSN
    u16 pkt_len;
    u16 interal_time;
#endif
	//MD
	u8 inject_addr:5,
		pkttype:3;
	u8 md[7];//
    u8 des_mac[6];   // 48位目的mac地址
    u8 src_mac[6];// 48位源mac地址字段
    u16  eth_type:16;            // 16位报文类型字段
    u8   ptp_type:4,            //4位PTP类型字段
         reserve1:4;
    u8  reserve2;
    u16 pkt_length;                 //16位报文长度
    u16 reserve3;
    u16 reserve4;
    u8  corrField[8];             //修正域字段
    u16 reserve5;
    u32 reserve6[2];
    u32 reserve7[2];
    u16 reserve8;
    u8 timestamp[8];                       //时间戳字段
    u8 pad[6];                    //填充字段

}__attribute__((packed))ptp_pkt;


typedef struct{
	//MD
	u8 inject_addr:5,
		pkttype:3;
	u8 md[7];//
    u8 des_mac[6];   // 48位目的mac地址
    u8 src_mac[6];// 48位源mac地址字段
    u16  eth_type:16;            // 16位报文类型字段
    u8   ptp_type:4,            //4位PTP类型字段
         reserve1:4;
    u8  reserve2;
    u16 pkt_length;                 //16位报文长度
    u16 reserve3;
    u16 reserve4;
    u8  corrField[8];             //修正域字段
    u16 reserve5;
    u32 reserve6[2];
    u32 reserve7[2];
    u16 reserve8;
    u8 timestamp[8];                       //时间戳字段
    u8 pad[6];                    //填充字段

}__attribute__((packed))ptp_pkt_rec;

//u64 ts_add(u64 u1,u64 u2);

//u64 ts_sub(u64 u1,u64 u2)

u32 htonl(u32 a);

u16 htons(u16 a);

u64 htonll(u64 a);

void md_transf_fun(u8 *tmp_md,u16 outport,u8 lookup_en,u8 frag_last);

void dmac_transf_tag(u8 *tmp_dmac,u8 flow_type,u16 flowid,u16 seqid,u8 frag_flag,u8 frag_id,u8 inject_addr,u8 submit_addr );

void   pkt_init(ptp_pkt* pkt);

char*  get_src_mac(ptp_pkt_rec* pkt);

void set_des_mac(ptp_pkt_rec* pkt,char* ptr);

long long get_corr(ptp_pkt_rec* pkt);

void set_corr(ptp_pkt_rec* pkt,long long  corr);

long long get_pkt_ts(ptp_pkt_rec* pkt);

void set_pkt_ts(ptp_pkt_rec* pkt,long long  ts);

long long get_md_ts(ptp_pkt_rec* pkt);

void set_md_ts(ptp_pkt_rec* pkt,long long ts);

int sync_pkt_build(ptp_pkt* pkt);   //建立sync并且发送pkt

int delay_req_pkt_build(ptp_pkt_rec* sync_pkt);   //接收sync 构造req

int delay_resp_pkt_build(ptp_pkt_rec* req_pkt);         //接收req 构造resp

void delay_resp_pkt_handler(ptp_pkt_rec* pkt);     //接收

void print_pkt(ptp_pkt* pkt);

void hx_ptp_contex_init();

int hx_ptp_contex_destroy();

void sync_ptp_msg_build(u8* pkt,u16 len,struct msg_node* msg);

void msg_rewrite(u8* pkt,u16 len,struct msg_node* msg );


void sync_handler_master(struct msg_quene* txq,struct buf_list * head_list,struct msg_node* msg);

void sync_handler_slave(struct msg_quene* txq,struct buf_list * head_list,struct msg_node* msg);

void delay_req_handler(struct msg_quene* txq,struct buf_list* head_list,struct msg_node* msg);

void delay_resp_handler(struct msg_quene* txq,struct msg_node* msg,struct buf_list * head_list);
void hx_start_master_ptp();
void hx_start_slave_ptp();

void hx_star_ptp(void *argv);

#define PTP_DEBUG 1

#if PTP_DEBUG
	#define PTP_DBG(args...) do{printf("PTP-INFO:");printf(args);}while(0)
	#define PTP_ERR(args...) do{printf("PTP-ERROR:");printf(args);}while(0)
#else
	#define PTP_DBG(args...)
	#define PTP_DBG(args...)
#endif



#endif

//#endif // PTP_H_INCLUDED


