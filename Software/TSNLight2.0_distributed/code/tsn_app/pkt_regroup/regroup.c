/** *************************************************************************
 *  @file          regroup.c
 *  @brief	  报文重组模块，对接收到的分片的报文进行重组，在MD中携带输出端口号，pkttype=111，
 				frag_last=1时为最后一片，开始和中间片为0,从接收的报文中TSNTag位置中获取frag_flag，放在MD中
 				需要把目的mac替换为本身的mac地址
 				输出端口为需要查表，目前为默认为2
 				非第一片需要需要丢弃DMAC

 				V2.0：不需要重组，直接替换目的mac，指定输出端口发送
 * 
 *  详细说明：
 * 
 *  @date	   2020/07/11
 *  @author		junshuai.li
 *  @email		1145331404@qq.com
 *  @version	2.0
 ****************************************************************************/

#include "regroup.h"

u8 ed_dmac[6] = {0xd8,0xcb,0x8a,0xd7,0x22,0x9e};

struct hx_context  regroup_context;

u8 frag_pkt[2000] = {0};

//md 转化函数
void md_transf_fun_regroup(u8 *tmp_md,u8 pkt_type,u8 inject_addr,u16 outport,u8 lookup_en,u8 frag_last)
{
	tmp_md[0] = 0;
	tmp_md[0] = pkt_type<<5;
	tmp_md[0] = tmp_md[0] | inject_addr;	

	tmp_md[1] = 0;
	tmp_md[1] = outport>>1;

	tmp_md[2] = 0;
	tmp_md[2] = tmp_md[2] | (outport<<7);

	tmp_md[2] = tmp_md[2] | (lookup_en<<6);
	tmp_md[2] = tmp_md[2] | (frag_last<<5);
	
}

int hx_regroup_contex_init()
{
	struct hx_context_arg  hx_regroup_arg;
	memset(&hx_regroup_arg,0,sizeof(struct hx_context_arg));
	
	hx_regroup_arg.service_id = TSN_REGROUP_ID;//0x017
	hx_regroup_arg.rxq_size = 1024;
	hx_regroup_arg.txq_size = 1024;
	
	hx_init(&regroup_context,&hx_regroup_arg); 

	return 0;
}

int hx_regroup_contex_destroy()
{
	hx_destroy(&regroup_context); 
	return 0;
}

struct mac_flowid_map
{
	u16 flowid;
	u8 mac[6];
	u8 outport;
	
}__attribute__((packed));

struct mac_flowid_map ed_map[8];

u16 get_flowid_from_tsntag(u8 *tsntag)
{
	u16 flowid = 0;
	flowid = (tsntag[0] & 0x1f)*512 ;
	flowid = flowid + tsntag[1]*2 ;
	flowid = flowid + tsntag[2]>>7;
	return flowid;
}
//增加把时间戳写在文本的函数，用于测试

u64 htonll_regroup(u64 a)
{                      //64位数据转网络序
    return ((a>>56)&0X00000000000000ff) | ((a>>40)&0X000000000000ff00) | ((a>>24)&0X0000000000ff0000) | ((a>>8)&0X00000000ff000000) | ((a<<8)&0X000000ff00000000)| ((a<<24)&0X0000ff0000000000)| ((a<<40)&0X00ff000000000000)| ((a<<56)&0Xff00000000000000);
};

u64 timestamp_to_beats(u64 timeStamp){
    u8 timeStamp_low = timeStamp%128;
    u64 timeStamp_high = timeStamp/128;
    u64 beats = timeStamp_high*125+timeStamp_low;
    return beats;
}

u64  get_md_ts_regroup(u8* pkt)
{                  
//从接收的ptp_pkt中取出metedata携带的时间戳
    u64 * ptr = NULL;
   // char * ptr1 = (char*)pkt;
    ptr = (u64 *)(pkt);
    return htonll_regroup(*ptr)>>16;
};



FILE * file_write_regroup()
{

    FILE * fp = NULL;
    fp = fopen("timestamp.txt","a");
    //fprintf(fp,"MD_timestamp=%lld\t \n",timestamp);
    //fclose(fp);
    return fp;

}

/*本地管理处理线程*/
void hx_regroup(void *argv)
{
	struct msg_node* tmp_msg_node = NULL;
	u8 *tmp_pkt = NULL;
	
	hx_regroup_contex_init();
	u8 tmp_pkt_type = 0;

	
	u64 tmp_timeStamp = 0;
	
	FILE * fp = NULL;
	fp = file_write_regroup();
	
	u16 flow_ID = 0;


	
	while(1)
	{
		tmp_msg_node = hx_read_msg_quene_node_blocking(&(regroup_context.rxq));
		tmp_pkt      = tmp_msg_node->eth_head_ptr;
		tmp_pkt_type = tmp_pkt[8]>>5;//获取当前的流类型
		if(tmp_pkt_type==0 || tmp_pkt_type==1 || tmp_pkt_type==2)//如果接收到的时TS流，则输出时间戳到文本
		{
			flow_ID = (tmp_pkt[8] & 0x1f)*512 + tmp_pkt[9] * 32 + tmp_pkt[10] * 2 + tmp_pkt[11]>>7;
					//测试TS流时增加
			
			//file_write_regroup(get_md_ts_regroup(tmp_msg_node->eth_head_ptr));
			
			tmp_timeStamp = get_md_ts_regroup(tmp_msg_node->eth_head_ptr);
			fprintf(fp,"flowID=%d,MD_timestamp=%lld\t \n",flow_ID,timestamp_to_beats(tmp_timeStamp));
			hx_free_buf(&regroup_context.buffer_list,tmp_msg_node);
			continue;						
		}

		
		tmp_pkt      = tmp_msg_node->eth_head_ptr;
		tmp_pkt_type = tmp_pkt[8]>>5;//获取当前的流类型
		//md的保留位置0，使主机口不会当成杂包丢弃
		tmp_pkt[2] = tmp_pkt[2] & 0XE0;
		tmp_pkt[3] = 0;
		tmp_pkt[4] = 0;
		tmp_pkt[5] = 0;
		tmp_pkt[6] = 0;
		tmp_pkt[7] = 0;
		
		
		memcpy(tmp_pkt+8,&ed_dmac,6);
		tmp_msg_node->eth_head_ptr[20] = tmp_msg_node->eth_head_ptr[20] & 0xef;//以太网类型字段改为0800
		tmp_msg_node->eth_head_ptr = tmp_msg_node->eth_head_ptr;
		tmp_msg_node->eth_pkt_len  = tmp_msg_node->eth_pkt_len;
		tmp_msg_node->reserve = 8;//主机口输出
		tmp_msg_node->src_service_id = TSN_REGROUP_ID;		
		tmp_msg_node->msg_type = TSN_REGROUP_FLOW;
		
		if(ERR==hx_write_msg_quene_node(&regroup_context.txq,tmp_msg_node))
		{
			  REGROUP_ERR("hx_write_msg_quene_node fail\n");
			  hx_free_buf(&regroup_context.buffer_list,tmp_msg_node);
		}				
		

	}

	hx_regroup_contex_destroy();

	REGROUP_DBG("hx_start_timer end!\n");

}


int hx_regroup_handler()
{
	int ret = -1;
	pthread_t regroup_id;

	
	ret=pthread_create(&regroup_id,NULL,(void *)hx_regroup,NULL); 
	
	if(0 != ret)
	{
		REGROUP_ERR("create hx_regroup_handler fail!ret=%d err=%s\n",ret, strerror(ret));
	}

	return ret;
}







