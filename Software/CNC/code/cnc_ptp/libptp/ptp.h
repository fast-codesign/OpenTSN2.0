#ifndef NODE_H_INCLUDED
#define NODE_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <malloc.h>
#include <unistd.h>
#include "../../cnc_api/include/cnc_api.h"

typedef char s8;				/**< �з��ŵ�8λ��1�ֽڣ����ݶ���*/
typedef unsigned char u8;		/**< �޷��ŵ�8λ��1�ֽڣ����ݶ���*/
typedef short s16;				/**< �з��ŵ�16λ��2�ֽڣ����ݶ���*/
typedef unsigned short u16;	/**< �޷��ŵ�16λ��2�ֽڣ����ݶ���*/
typedef int s32;				/**< �з��ŵ�32λ��4�ֽڣ����ݶ���*/
typedef unsigned int u32;		/**< �޷��ŵ�32λ��4�ֽڣ����ݶ���*/
typedef long long s64;				/**< �з��ŵ�64λ��8�ֽڣ����ݶ���*/
typedef unsigned long long u64;		/**< �޷��ŵ�64λ��8�ֽڣ����ݶ���*/
typedef struct {
    u64 t1;
    u64 t2;
    u64 corr_ms;
    u64 t3;
    u64 t4;
    u64 corr_sm;
    u64 sync_seq;
    u64 Latest_Offset;
    u64 Avg_Offset;
    u64 Corr_Fre;
    u16 guide_offset;
    u32 guide_offset_frequency;
    u8 guide_offset_flag;
    u64 preoffset;
    u8 offset_flag;
}sync_info;



typedef struct {
    sync_info table[200];
    int info_count;
}sync_info_table;



typedef struct{
    u8  ptp_des_mac[6];   // 48λptp����Ŀ��mac��ַ
    u8  ptp_src_mac[6];    // 48λptp����Դmac��ַ�ֶ�
    u16  eth_type:16;            // 16λ���������ֶ�
    u8   ptp_type:4,            //4λPTP�����ֶ�
         reserve1:4;
    u8  reserve2;
    u16 pkt_length;                 //16λ���ĳ���
    u16 reserve3;
    u16 reserve4;
    u8  corrField[8];             //�������ֶ�
    u16 reserve5;
    u32 reserve6[2];
    u32 reserve7;
    u32 sync_seq;
    u16 reserve8;
    u8 timestamp1[8];                       //ʱ���1�ֶ�
    u8 timestamp2[6];                    //ʱ���2�ֶ�
}__attribute__((packed))ptp_pkt;

//int sync_pkt_build(ptp_pkt* pkt);
void   pkt_init(ptp_pkt* pkt);
void dmac_transf_tag(u8 *tmp_dmac,u8 flow_type,u16 flowid,u16 seqid,u8 frag_flag,u8 frag_id,u8 inject_addr,u8 submit_addr );

void ptp_callback(unsigned char *argument,const struct pcap_pkthdr *packet_heaher,const unsigned char *packet_content);
/*

typedef struct _node{
    sync_info info;
    struct _node*next;
} Node;

typedef struct _list{
    Node* node_head;
    Node* node_end;
    int node_count;
} List_node;
*/
#endif // NODE_H_INCLUDED
