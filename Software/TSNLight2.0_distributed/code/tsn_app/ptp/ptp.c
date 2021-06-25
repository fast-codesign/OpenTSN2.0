#include "ptp.h"

struct hx_context ptp_context;
ts_info Local_ts_info;
u64 offset_seq = 0 ;
//short M_S_Flag = 1; //标志位为1时 为主时钟，为0时为从时钟
int m_s_flag = 0;//标志位为1时 为主时钟，为0时为从时钟
u16 ptp_local_imac = 0;//本机imac
u16 ptp_mult_imac = 0;//组播imac
u16 ptp_period = 500; //同步周期
u8 recoup_flag = 1;  //1为使用差值法，0为不使用


void file_write_s(u64 a,u64 b, u64 c, u64 d,u64 e){

    FILE * fp = NULL;
    fp = fopen("offset.txt","a");
    fprintf(fp,"ptp_seq=%lld\t       t1=%lld\t     t2=%lld\t      corr_ms=%lld\t        offset=%lld\n",e,a,b,c,d);
    fclose(fp);
    return ;

}
void file_write_m(u64 a,u64 b, u64 c, u8 e){

    FILE * fp = NULL;
    fp = fopen("offset.txt","a");
    fprintf(fp,"ptp_seq=%d\t       t3=%lld\t     t4=%lld\t      corr_sm=%lld\t\n ",e,a,b,c);
    fclose(fp);
    return ;

}

u32 get_l_offset(u64 offset){
    return htonl((u32)offset);

}

u32 get_h_offset(u64 offset){
    if(Local_ts_info.offset_flag == 0 ){
        offset = offset + 0x1000000000000;
    }
    return htonl((u32)(offset>>32));
}

u32 get_h_guide_offset(u64 offset){
    if(Local_ts_info.guide_offset_flag == 0 ){
        offset = offset + 0x1000000000000;
    }
    return htonl((u32)(offset>>32));
}

u64 corr_trans(u64 a)    //修正域时间戳格式转换函数
{
    u64 corr_7 = a%125;
    u64 corr_41 = (a/125)*128 ;
	return corr_41+corr_7;
}

u64 ts_add(u64 u1,u64 u2){              //时间戳相加函数
    u64 u_sum;
    u64 u1_41 = (u1/128)*128;
    u64 u2_41 = (u2/128)*128;
    u8 u1_7 = u1%128;
    u8 u2_7 = u2%128;
    u1_41 = u1_41+u2_41;
    u1_7 = u1_7+u2_7;
    if(u1_7>124){
        u1_41 = u1_41+128;
        u1_7 = u1_7-125;
    }
    u_sum = u1_41+u1_7;
    return u_sum;
}

u64 ts_sub(u64 u1, u64 u2){               // 时间戳相减函数
    int flag;
    u64 u_sub;
    u64 u1_41 = (u1/128)*128;
    u64 u2_41 = (u2/128)*128;
    u64 u1_7 = u1%128;
    u64 u2_7 = u2%128;
    if(u1>=u2){
        flag = 0;
    }else {
        flag = 1;
    }
    if(flag == 0){
      if(u1_7>u2_7){
        u_sub = (u1_7-u2_7)+(u1_41-u2_41);
      }else if (u1_7<u2_7){
          u1_7 = u1_7 + 125 -u2_7;
          u1_41 = u1_41 - 128 -u2_41;
          u_sub = ts_add(u1_7,u1_41);
      }else if(u1_41>u2_41){
          u_sub = u1_41-u2_41;
      }else {
          u_sub = 0;
      }
    }else{
        if(u2_7>u1_7){
            u_sub = (u2_7-u1_7)+(u2_41-u1_41) +0X1000000000000;
        }else if (u2_7<u1_7){
            u1_7 = u2_7+125-u1_7;
            u1_41 = u2_41 -128 -u1_41;
            u_sub = ts_add(u1_7,u1_41)+0X1000000000000;
        }else if(u2_41>u1_41){
          u_sub = u2_41-u1_41+0X1000000000000;
      }
    }
    return u_sub;
}

void ts_compute(){
    u64 t4 = ts_sub(Local_ts_info.t2,ts_add(Local_ts_info.t1,corr_trans(Local_ts_info.rorr1)));
	//printf(" t2 - t1 - corr1 = %lld\n",t4);
    if(t4<0x1000000000000&&Local_ts_info.t3<0x1000000000000){
        if(t4>=Local_ts_info.t3){
            Local_ts_info.offset = ts_sub(t4,Local_ts_info.t3)/2;
            Local_ts_info.offset_flag = 0;
        }else if(t4<Local_ts_info.t3){
            Local_ts_info.offset = ts_sub(Local_ts_info.t3,t4)/2;
            Local_ts_info.offset_flag = 1;
        }
    }else if(t4<0x1000000000000&&Local_ts_info.t3>0x1000000000000){
        Local_ts_info.offset_flag = 0;
        Local_ts_info.offset = ts_add(t4,Local_ts_info.t3-0x1000000000000)/2;
    }else if(t4>0x1000000000000&&Local_ts_info.t3<0x1000000000000){
        Local_ts_info.offset_flag = 1 ;
        Local_ts_info.offset = ts_add(t4-0x1000000000000,Local_ts_info.t3)/2;
    }else{
        if((t4-0x1000000000000)>=(Local_ts_info.t3-0x1000000000000)){
            Local_ts_info.offset_flag = 1;
            Local_ts_info.offset = ts_sub(t4,Local_ts_info.t3)/2;
        }else{
            Local_ts_info.offset_flag = 0;
            Local_ts_info.offset = ts_sub(Local_ts_info.t3,t4)/2;
        }
    }

}
u32 htonl(u32 a){                        //16位数据转网络序

    return ((a >> 24) & 0x000000ff) |         ((a >>  8) & 0x0000ff00) |         ((a <<  8) & 0x00ff0000) |         ((a << 24) & 0xff000000);

};

u16 htons(u16 a){                       //32位数据转网络序

  return ((a >> 8) & 0x00ff) | ((a << 8) & 0xff00);

};

u64 htonll(u64 a){                      //64位数据转网络序
    return ((a>>56)&0X00000000000000ff) | ((a>>40)&0X000000000000ff00) | ((a>>24)&0X0000000000ff0000) | ((a>>8)&0X00000000ff000000) | ((a<<8)&0X000000ff00000000)| ((a<<24)&0X0000ff0000000000)| ((a<<40)&0X00ff000000000000)| ((a<<56)&0Xff00000000000000);
};

void md_transf_fun(u8 *tmp_md,u16 outport,u8 lookup_en,u8 frag_last){              //metedata转网络序
	tmp_md[0] = 0;
	tmp_md[0] = outport>>1;

	tmp_md[1] = 0;
	tmp_md[1] = tmp_md[1] | (outport<<7);

	tmp_md[1] = tmp_md[1] | (lookup_en<<6);
	tmp_md[1] = tmp_md[1] | (frag_last<<5);

};

void dmac_transf_tag(u8 *tmp_dmac,u8 flow_type,u16 flowid,u16 seqid,u8 frag_flag,u8 frag_id,u8 inject_addr,u8 submit_addr ){    //目的MAC转网络序
	tmp_dmac[0] = 0;
	tmp_dmac[0] = flow_type<<5;
	tmp_dmac[0] = tmp_dmac[0] | (flowid>>9);

	tmp_dmac[1] = 0;
	tmp_dmac[1] = flowid >> 1;

	tmp_dmac[2] = 0;
	tmp_dmac[2] = flowid << 7;
	tmp_dmac[2] = tmp_dmac[2] | (seqid >> 9);

	tmp_dmac[3] = 0;
	tmp_dmac[3] = seqid >> 1;
	tmp_dmac[3] = tmp_dmac[3] | (seqid >> 9);

	tmp_dmac[4] = 0;
	tmp_dmac[4] = seqid << 7;
	tmp_dmac[4] = tmp_dmac[4] | (frag_flag << 6);
	tmp_dmac[4] = tmp_dmac[4] | (frag_id << 2);
	tmp_dmac[4] = tmp_dmac[4] | (inject_addr >> 3);

	tmp_dmac[5] = 0;
	tmp_dmac[5] = inject_addr << 5;
	tmp_dmac[5] = tmp_dmac[5] | submit_addr;

};

void   pkt_init(ptp_pkt* pkt){          //PTP报文构造的初始化函数
    memset(pkt,0,sizeof(ptp_pkt));
    return ;
};

char*  get_src_mac(ptp_pkt_rec* pkt){        //从接收到的ptp_pkt中取出源目的Mac
    char src_mac[6];
    char* ptr = NULL;
    int i;
    for(i=0;i<6;i++){
        src_mac[i]=pkt->src_mac[i];
    }
    ptr = src_mac;
    return ptr;

};

void set_des_mac(ptp_pkt_rec* pkt,char* ptr){   //对构造的ptp_pkt设置目的Mac
        int i;
    for(i=0;i<6;i++){
        pkt->des_mac[i]=*(ptr+i);}

};

long long get_corr(ptp_pkt_rec* pkt){                //从接收到的ptp_pkt中取出修正域字段值
    long long * ptr;
    ptr = (long long *)(pkt->corrField);
    return htonll(*ptr);
};

void set_corr(ptp_pkt_rec* pkt,long long  corr){       // 对发送的ptp_pkt设置修正域字段（供测试使用）
    long long * ptr;
    ptr = (long long *)(pkt->corrField) ;
    *ptr = htonll(corr);

};

long long get_pkt_ts(ptp_pkt_rec* pkt){                //从接收的ptp_pkt中取出报文携带的时间戳
    long long * ptr;
    ptr = (long long *)(pkt->timestamp);
    return htonll(*ptr);
};

void set_pkt_ts(ptp_pkt_rec* pkt,long long  ts){         //对发送的ptp_pkt设置报文时间戳字段（供测试使用）
    long long * ptr;
    ptr = (long long *)(pkt->timestamp) ;
    *ptr = htonll(ts);

};

long long get_md_ts(ptp_pkt_rec* pkt){                  //从接收的ptp_pkt中取出metedata携带的时间戳
    long long * ptr;
   // char * ptr1 = (char*)pkt;
    ptr = (long long *)(pkt);
    return htonll(*ptr)>>16;
};

void set_md_ts(ptp_pkt_rec* pkt,long long ts ){         //对发送的ptp_pkt设置metedata戳字段（供测试使用）
    long long * ptr;
    char * ptr1 = (char*)pkt;
    ptr = (long long *)(ptr1+4);
    *ptr = htonll(ts<<16);


};

int sync_pkt_build(ptp_pkt* pkt){                      //对sync报文的构造
    pkt_init(pkt);                                    //报文初始化
#ifdef TSN
    pkt->pkt_len = htons(72);
    pkt->interal_time = htons(0X000c);                  //对报文前四个字节中报文长度及间隔时间字段进行填充
#endif
    pkt->pkttype= 0X4;                                  //填充报文类型字段
    md_transf_fun(pkt->md,0X0000,0X01,0X00);            //填充metedata字段
    dmac_transf_tag(pkt->des_mac,0X4,ptp_mult_imac,0X0000,0X00,0X00,0X00,0X00);      //填充目的MAC字段
    dmac_transf_tag(pkt->src_mac,0x4,ptp_local_imac,0x0000,0x00,0x00,0x00,0x00);     //填充源MAC字段
    pkt->eth_type=htons(0X98F7);                         //以太网报文字段填充
    pkt->ptp_type=0X1;                                   //ptp类型字段填充
    pkt->pkt_length = htons(72);                         //报文长度字段填充
    return sizeof(ptp_pkt);
};

int delay_req_pkt_build(ptp_pkt_rec* sync_pkt){

    u16* ptr =NULL;
    Local_ts_info.t1 = get_pkt_ts(sync_pkt);
    Local_ts_info.t2 = get_md_ts(sync_pkt);
   // Local_ts_info.rorr1 = get_corr(sync_pkt);
    Local_ts_info.rorr1 = get_corr(sync_pkt);
    memset(sync_pkt,0,8);
    sync_pkt->pkttype= 0X4;
     md_transf_fun(sync_pkt->md,0X0000,0X01,0X00);
    set_des_mac(sync_pkt,get_src_mac(sync_pkt));
    dmac_transf_tag(sync_pkt->src_mac,0x4,ptp_local_imac,0x0000,0x00,0x00,0x00,0x00);
    sync_pkt->ptp_type=0X3;
    memset(sync_pkt->timestamp,0,8);
    memset(sync_pkt->corrField,0,8);
    //pkt->eth_type=htons(0X88F7);
#ifdef TSN
    ptr = (u16*)(sync_pkt) - 2;
    * ptr = htons(0x0048) ;
    * (ptr+1) = 0X0000 ;
#endif
    return sizeof(ptp_pkt);


};



int delay_resp_pkt_build(ptp_pkt_rec* req_pkt){

//	np_pkt_print((u8 *)req_pkt, 20);
    u16* ptr = NULL;
    u64 t3 = 0 ;
    t3 = ts_sub(get_md_ts(req_pkt),ts_add(get_pkt_ts(req_pkt),corr_trans(get_corr(req_pkt))));      //计算接收到的delay_req报文中时间戳信息（t4-t3-corr)
	//printf(" t4 = %lld t3 = %lld corr = %lld \n",get_md_ts(req_pkt),get_pkt_ts(req_pkt),corr_trans(get_corr(req_pkt)));
    file_write_m(get_pkt_ts(req_pkt),get_md_ts(req_pkt),get_corr(req_pkt),offset_seq);
    memset(req_pkt,0,8);                                                 //对metedata字段的置零
    req_pkt->pkttype= 0X4;
    md_transf_fun(req_pkt->md,0X0000,0X01,0X00);                         //metedata字段的填充
    set_des_mac(req_pkt,get_src_mac(req_pkt));
    dmac_transf_tag(req_pkt->src_mac,0x4,ptp_local_imac,0x0000,0x00,0x00,0x00,0x00);                 //对源、目的MAC 字段进行填充
    req_pkt->ptp_type=0X4;                                               //对ptp类型字段的填充
    memset(req_pkt->timestamp,0,8);
    set_pkt_ts(req_pkt,t3);                                              //对报文时间戳字段进行填充
    memset(req_pkt->corrField,0,8);
#ifdef TSN
    ptr =( u16*) (req_pkt)- 2 ;
    * ptr = htons(0X0048);
    *(ptr+1) = 0X0000 ;                                                   //对报文前4字节进行填写
#endif
    return sizeof(ptp_pkt);


}

void delay_resp_pkt_handler(ptp_pkt_rec* pkt){           //从时钟接收到delay_resp对offset值进行计算
    Local_ts_info.t3 = get_pkt_ts(pkt);
    //u64 t4 = ts_sub(tsinfo.t2,ts_add(tsinfo.t1,tsinfo.rorr1));
    ts_compute();
};

void print_pkt(ptp_pkt* pkt){                                        //对ptp_ptk进行打印
    char* ptr;
    ptr = (char*)pkt;
    int i;
    for(i=0;i<4;i++){
        printf("%.2x ",(u8)*(ptr+i));
    };
    printf("\n");
    for(i=4;i<12;i++){
        printf("%.2x ",(u8)*(ptr+i));
    };
    for(i=12;i<76;i++){
        if((i-12)%16==0){
            printf("\n");
        };
        printf("%.2x ",(u8)*(ptr+i));
    }
}

void hx_ptp_contex_init()                             //对线程进行初始化
{
    struct hx_context_arg hx_ptp_arg;
    memset(&hx_ptp_arg,0,sizeof(struct hx_context_arg));

    hx_ptp_arg.service_id = PTP_SERVICE_ID; //0X10
    hx_ptp_arg.rxq_size = 128;
    hx_ptp_arg.txq_size = 128;

    hx_init(&ptp_context,&hx_ptp_arg);



}

int hx_ptp_contex_destroy()
{
    hx_destroy(&ptp_context);
    return 0;
}

void sync_ptp_msg_build(u8* pkt,u16 len,struct msg_node* msg)             //对携带sync报文的msg进行构造
{
    memset(msg,0,sizeof(struct msg_node));
    msg->eth_head_ptr = pkt;
    msg->eth_pkt_len = len;
    msg->msg_type = TSN_PTP;
    msg->src_service_id = PTP_SERVICE_ID;
    msg->reserve = 8;

}

void nmac_msg_build(u8* pkt,u16 len,struct msg_node* msg)             //对携带sync报文的msg进行构造
{
    memset(msg,0,sizeof(struct msg_node));
    msg->eth_head_ptr = pkt;
    msg->eth_pkt_len = len;
    msg->msg_type = TSN_NMAC;
    msg->src_service_id = PTP_SERVICE_ID;
    msg->reserve = 8;

}

void msg_rewrite(u8* pkt,u16 len,struct msg_node* msg)                    //对msg进行改写
{
   msg->eth_head_ptr = pkt;
   msg->eth_pkt_len = len;
   msg->msg_type = TSN_PTP;
   msg->reserve = 8;
   msg->src_service_id = PTP_SERVICE_ID;
}

void sync_handler_master(struct msg_quene* txq,struct buf_list * head_list,struct msg_node* msg)         //主时钟对发送sync报文进行操作
{
    u8* pkt = NULL;
    u16 len = 0;
    struct msg_node* sync_ptp_msg = NULL;

    hx_free_buf(head_list,msg);

    pkt = hx_malloc_eth_pkt_buf(head_list);
    len = sync_pkt_build((ptp_pkt*)pkt);

    sync_ptp_msg = (struct msg_node*)((u8*)pkt-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
    sync_ptp_msg_build(pkt,len,sync_ptp_msg);

	if(ERR==hx_write_msg_quene_node(txq,sync_ptp_msg))
	{
	  PTP_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&ptp_context.buffer_list,sync_ptp_msg);
	}
    return ;
}

void sync_handler_slave(struct msg_quene* txq,struct buf_list * head_list,struct msg_node* msg)     //从时钟对接接收的sync报文进行操作
{
  //  u8* pkt = NULL;
    u16 len = 0;
    //struct msg_node* delay_req_ptp_msg = NULL;

   // pkt = hx_malloc_eth_pkt_buf(head_list);
    len =delay_req_pkt_build((ptp_pkt_rec*)(msg->eth_head_ptr));

#ifdef TSN
    msg_rewrite((msg->eth_head_ptr)-4,len,msg);
#else
	msg_rewrite((msg->eth_head_ptr),len,msg);
#endif

	if(ERR==hx_write_msg_quene_node(txq,msg))
	{
	  PTP_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&ptp_context.buffer_list,msg);
	}
   // hx_write_msg_quene_node(txq,msg);

    return ;




}

void delay_req_handler(struct msg_quene* txq,struct buf_list* head_list,struct msg_node* msg)     //主时钟对接收带delay_req报文进行操作
{
    u16 len = 0;
    len = delay_resp_pkt_build((ptp_pkt_rec*)(msg->eth_head_ptr));

#ifdef TSN
    msg_rewrite((msg->eth_head_ptr)-4,len,msg);
#else
	msg_rewrite((msg->eth_head_ptr),len,msg);
#endif


	if(ERR==hx_write_msg_quene_node(txq,msg))
	{
	  PTP_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&ptp_context.buffer_list,msg);
	}else{
	   // printf("hx write msg quene sucess!\n");
	}
    return ;
}
/*
void delay_resp_handler(struct msg_node* msg,struct buf_list * head_list)                        //从时钟对接收的delay_resp报文进行处理
{
    delay_resp_pkt_handler((ptp_pkt_rec*)(msg->eth_head_ptr));
        hx_free_buf(head_list,msg);


}*/




void delay_resp_handler_1(struct msg_quene* txq,struct msg_node* msg,struct buf_list * head_list)
{
    static u64 preoffset = 0;
	//static offset_seq = 0;
	struct msg_node* nmac_msg = NULL;
	struct msg_node* nmac_msg_1 = NULL;
	//offset_seq = offset_seq + 1 ;
	delay_resp_pkt_handler((ptp_pkt_rec*)(msg->eth_head_ptr));
	hx_free_buf(head_list,msg);
	//struct eth_pkt_info eth2;
	struct eth_pkt_info eth1;
	struct eth_pkt_info eth2;
	eth1 = build_offset_pkt(get_l_offset(Local_ts_info.offset),get_h_offset(Local_ts_info.offset));
	eth2 = build_offset_period(htonl((u32)0));
	nmac_msg = (struct msg_node*)((u8*)eth1.buf-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	nmac_msg_build(eth1.buf,eth1.len,nmac_msg);
	if(ERR==hx_write_msg_quene_node(txq,nmac_msg))
	{
	  PTP_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&ptp_context.buffer_list,nmac_msg);
	}
    nmac_msg_1 = (struct msg_node*)((u8*)eth2.buf-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	nmac_msg_build(eth2.buf,eth2.len,nmac_msg_1);
	if(ERR==hx_write_msg_quene_node(txq,nmac_msg_1))
	{
	  PTP_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&ptp_context.buffer_list,nmac_msg_1);
	}
	if (offset_seq  == 2 ){
            struct msg_node* nmac_msg_2 =NULL;
            struct msg_node* nmac_msg_3 = NULL;
            struct eth_pkt_info eth3;
            struct eth_pkt_info eth4;
            Local_ts_info.guide_offset = 1;
            if(Local_ts_info.offset == 0){
                    Local_ts_info.guide_offset = 0;
                      Local_ts_info.guide_offset_frequency = ptp_period*1000000/8;
            }else{
            Local_ts_info.guide_offset_frequency = ptp_period*1000000/(8*Local_ts_info.offset);
            }
            Local_ts_info.guide_offset_flag = Local_ts_info.offset_flag ;
            preoffset = preoffset + Local_ts_info.offset;
            eth3 = build_offset_pkt(get_l_offset(Local_ts_info.guide_offset),get_h_guide_offset(Local_ts_info.guide_offset));
            eth4 = build_offset_period(htonl(Local_ts_info.guide_offset_frequency));
            nmac_msg_2 = (struct msg_node*)((u8*)eth3.buf-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
            nmac_msg_build(eth3.buf,eth3.len,nmac_msg_2);
            if(ERR==hx_write_msg_quene_node(txq,nmac_msg_2))
            {
            PTP_DBG("hx_write_msg_quene_node fail\n");
            hx_free_buf(&ptp_context.buffer_list,nmac_msg_2);
            }
            nmac_msg_3 = (struct msg_node*)((u8*)eth4.buf-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
            nmac_msg_build(eth4.buf,eth4.len,nmac_msg_3);
            if(ERR==hx_write_msg_quene_node(txq,nmac_msg_3))
            {
            PTP_DBG("hx_write_msg_quene_node fail\n");
            hx_free_buf(&ptp_context.buffer_list,nmac_msg_3);
            }

	}else if(offset_seq >2 ){

        struct msg_node* nmac_msg_2 =NULL;
        struct msg_node* nmac_msg_3 = NULL;
        struct eth_pkt_info eth3;
        struct eth_pkt_info eth4;
	    if(Local_ts_info.guide_offset_flag!=Local_ts_info.offset_flag){
                if(Local_ts_info.offset>preoffset){
                    Local_ts_info.guide_offset_flag = !Local_ts_info.guide_offset_flag;
                    preoffset = Local_ts_info.offset - preoffset ;
                }else{
                preoffset = preoffset - Local_ts_info.offset ;
                }
                Local_ts_info.guide_offset = 1 ;
                if(preoffset == 0){
                      Local_ts_info.guide_offset = 0;
                      Local_ts_info.guide_offset_frequency = ptp_period*1000000/8;
                }else{
                Local_ts_info.guide_offset_frequency = ptp_period*1000000/(8*preoffset);
                 }

          //  Local_ts_info.guide_offset = Local_ts_info.guide_offset - Local_ts_info.offset/25;
	    }else {
	        preoffset = preoffset + Local_ts_info.offset ;
	        Local_ts_info.guide_offset = 1 ;
                if(preoffset == 0){
                      Local_ts_info.guide_offset_frequency = ptp_period*1000000/8;
                }else{
                Local_ts_info.guide_offset_frequency = ptp_period*1000000/(8*preoffset);
                 }
	       // Local_ts_info.guide_offset_frequency = ptp_period*1000000/(8*preoffset);
	        //Local_ts_info.guide_offset = Local_ts_info.guide_offset + Local_ts_info.offset/25;
	    }

        eth3 = build_offset_pkt(get_l_offset(Local_ts_info.guide_offset),get_h_guide_offset(Local_ts_info.guide_offset));
        eth4 = build_offset_period(htonl(Local_ts_info.guide_offset_frequency));
        nmac_msg_2 = (struct msg_node*)((u8*)eth3.buf-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
        nmac_msg_build(eth3.buf,eth3.len,nmac_msg_2);
        if(ERR==hx_write_msg_quene_node(txq,nmac_msg_2))
        {
        PTP_DBG("hx_write_msg_quene_node fail\n");
        hx_free_buf(&ptp_context.buffer_list,nmac_msg_2);
        }
        nmac_msg_3 = (struct msg_node*)((u8*)eth4.buf-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
        nmac_msg_build(eth4.buf,eth4.len,nmac_msg_3);
        if(ERR==hx_write_msg_quene_node(txq,nmac_msg_3))
        {
        PTP_DBG("hx_write_msg_quene_node fail\n");
        hx_free_buf(&ptp_context.buffer_list,nmac_msg_3);
        }
	}
     //   printf("------------------------------------------------------------------------------------------------------------- \n");
    //    printf("第 %d 次同步信息： \n", offset_seq);
	//printf("preoffset = %lld   \n",preoffset);
    //    printf("guide_offset_flag = %d   guide_offset_frequency = %d\n",Local_ts_info.guide_offset_flag,Local_ts_info.guide_offset_frequency);

	return ;


}





void delay_resp_handler(struct msg_quene* txq,struct msg_node* msg,struct buf_list * head_list)
{
	struct msg_node* nmac_msg = NULL;
	delay_resp_pkt_handler((ptp_pkt_rec*)(msg->eth_head_ptr));
	hx_free_buf(head_list,msg);
	struct eth_pkt_info eth1;
	eth1 = build_offset_pkt(get_l_offset(Local_ts_info.offset),get_h_offset(Local_ts_info.offset));
      //  printf("nmac_pkt: \n");
       // np_pkt_print(eth1.buf,eth1.len);
	nmac_msg = (struct msg_node*)((u8*)eth1.buf-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	nmac_msg_build(eth1.buf,eth1.len,nmac_msg);
     //   printf("nmac_msg_pkt: \n");
        //np_pkt_print(nmac_msg->eth_head_ptr,nmac_msg->eth_pkt_len);
	if(ERR==hx_write_msg_quene_node(txq,nmac_msg))
	{
	  PTP_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&ptp_context.buffer_list,nmac_msg);
	}
	return ;


}



/* ptp 主时钟处理线程 */
void hx_start_master_ptp()
{
    hx_ptp_contex_init();

    pthread_detach(pthread_self());

    printf("hx_start_ptp_master start!\n");

    struct msg_node* tmp_msg_node = NULL;
    ptp_pkt_rec* ptr = NULL;
	sleep(10);
    hx_register_timer(ptp_period,PTP_SERVICE_ID,1);     // 要求Timer周期为1ms发送msg


    FILE * fp = NULL;
    fp = fopen("offset.txt","w");
    fclose(fp);

    while(1){
        tmp_msg_node = hx_read_msg_quene_node(&ptp_context.rxq);
        if(tmp_msg_node!=NULL){
        if(tmp_msg_node->msg_type == TSN_TIMER+PTP_SERVICE_ID){
                sync_handler_master(&ptp_context.txq,&ptp_context.buffer_list,tmp_msg_node);
               // hx_unregister_timer(PTP_SERVICE_ID);
        }else if(tmp_msg_node->msg_type == TSN_PTP){
            delay_req_handler(&ptp_context.txq,&ptp_context.buffer_list,tmp_msg_node);
            offset_seq = offset_seq+1;
        }else {
            printf(" wrong ptp   \n");
            hx_free_buf(&ptp_context.buffer_list,tmp_msg_node);
        }
        }else
        {
               //  printf("tmp_msg_node = NULL!\n");
        }

       }
    hx_destroy(&ptp_context);
    return;
}
/* ptp从时钟线程*/
void hx_start_slave_ptp()
{
    hx_ptp_contex_init();
    pthread_detach(pthread_self());
    memset(&Local_ts_info,0,sizeof(ts_info));
    struct msg_node* tmp_msg_node = NULL;
    ptp_pkt_rec* ptr = NULL;
     FILE * fp = NULL;
    fp = fopen("offset.txt","w");
    fclose(fp);
    printf("ptp  slave   start!  \n");
     while(1){

        tmp_msg_node = hx_read_msg_quene_node(&ptp_context.rxq);
        if(tmp_msg_node!=NULL){
        ptr = (ptp_pkt_rec*)(tmp_msg_node->eth_head_ptr);
        if(tmp_msg_node->msg_type == TSN_PTP){
                //printf("get TSN_PTP!\n");
        if(ptr->ptp_type == 0X1){
            //printf(" SYNC MSG: !\n");
            //np_pkt_print(tmp_msg_node->eth_head_ptr,tmp_msg_node->eth_pkt_len);

            sync_handler_slave(&ptp_context.txq,&ptp_context.buffer_list,tmp_msg_node);
            //printf("delay req build sucess!\n ");
        }else  if(ptr->ptp_type == 0X4){
            //printf(" DELAY RESP MSG:\n");
            //np_pkt_print(tmp_msg_node->eth_head_ptr,tmp_msg_node->eth_pkt_len);
            if(recoup_flag == 1){
            delay_resp_handler_1(&ptp_context.txq,tmp_msg_node,&ptp_context.buffer_list);

}else{
    delay_resp_handler(&ptp_context.txq,tmp_msg_node,&ptp_context.buffer_list);
}                        //printf("offset_seq: %lld \n",offset_seq);
			printf("flag = %d  offset = %lld\n",Local_ts_info.offset_flag,Local_ts_info.offset);
			//printf("t1    = %lld  t2  = %lld  t4 -t3-corr2 = %lld  corr = %lld\n",Local_ts_info.t1,Local_ts_info.t2,Local_ts_info.t3,Local_ts_info.rorr1);
           offset_seq = offset_seq + 1;
         file_write_s(Local_ts_info.t1,Local_ts_info.t2,Local_ts_info.rorr1,Local_ts_info.offset,offset_seq);
        }else{
            printf("wrong ptp_type!\n");
            hx_free_buf(&ptp_context.buffer_list,tmp_msg_node);
        }

    }
        //printf("tmp_msg_node->msg_type: %x\n",tmp_msg_node->msg_type);
        }else{
         //   printf("msg_node = NULL \n");
        }

    }
    hx_destroy(&ptp_context);
    return;
}

void hx_star_ptp(void *argv)
{
	u8 tmp[16] = {0};
	get_cfgx_file(TSN_CONFIG_FILE, "Multicast_IMAC", tmp);
	ptp_mult_imac = atoi(tmp);

	get_cfgx_file(TSN_CONFIG_FILE, "HOST_IMAC", tmp);
	ptp_local_imac = atoi(tmp);

	get_cfgx_file(TSN_CONFIG_FILE, "M_S_Flag", tmp);
	m_s_flag = atoi(tmp);
	printf("m_s_flag %d\n",m_s_flag);
    if(m_s_flag==0){
        hx_start_slave_ptp();
    }else{
        hx_start_master_ptp();
    }
}

int hx_ptp_init()
{
    int ret = -1;
    pthread_t ptpid;

    ret = pthread_create(&ptpid,NULL,(void*)hx_star_ptp,NULL);

    if(0!=ret)
    {
        PTP_ERR("create hx_ptp_handler fail! ret=%d err=%s\n",ret,strerror(ret));
    }

    return ret;
}
