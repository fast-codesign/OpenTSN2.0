
#include "../include/np.h"
#include "../include/tools.h"


#define TSN_METEDATA_LEN 8
#define MAC_LEN 12

#define FLOW_MAP_FLAG 0x10
#define NMAC_FLAG 0xA0
#define PTP_FLAG 0x80
#define REGROUP_FLAG 0x40
#define FRAGID_FLAG 0x3c
//#define NETWORK_PORT 0x02


extern struct hx_context data_request_context;//数据请求线程变量

pcap_t * pcap_handle;

struct pcap_stat p_stat;


//数据响应线程变量
 struct ether_header
 {
	 unsigned char ether_dhost[6];	 //目的mac
	 unsigned char ether_shost[6];	 //源mac
	 unsigned short ether_type; 	 //以太网类型
 };
 

 int get_msg_type(u8* pkt)
 {
	 int type = 0;
	 u8 tmp[6] = {0};
	 u8 str_tmp[6] = {0};
 
	 u8 eth_type[2] = {0};
	 u8 metedata[16] = {0};
	 u8 inport = 0;

	 u8 endpoint_port[8];
	 int port = 0;
 
	 //拷贝metedata
	 memcpy(metedata,pkt,8);
	 inport = metedata[6]>>4;
 
	 //偏移TSN的metedata，指向dmac
	 pkt = pkt + TSN_METEDATA_LEN;
 
	 //获取dmac或TSNTag
	 memcpy(tmp,pkt,6);
 
	 //偏移到以太网类型,获取以太网类型值
	 pkt = pkt + MAC_LEN;
	 memcpy(eth_type,pkt,2);
 
	 printf("22221111 inport = %d \n",inport);

	 get_cfgx_file(TSN_CONFIG_FILE, "endpoint_port", endpoint_port);
	 port = atoi(endpoint_port);

	 //printf("1111 port = %d \n",port);
 
	 //网络口报文
	 if(port == inport)
	 {
		 //dmac全0，表示分片且未映射的流
		 if(0 == strcmp(tmp,str_tmp))
		 {
			 type = TSN_FORWORD_FLOW;
		 }
		 else
		 {
			 //未分片报文或者分片的头
			 if(eth_type[0] == 0x08 && eth_type[1] == 0x06)
			 {
				 //printf("1111\n");
				 type = TSN_ARP_FLOW;
			 }
			 else
			 {
				 //printf("22222\n");
				 type = TSN_FORWORD_FLOW;
			 }
		 }
	 }
	 else
	 {
		 //非网络口报文，都是映射后的，所以dmac为tsntag
		 if(NMAC_FLAG == (tmp[0] & NMAC_FLAG))//flow type = 101,nmac类型
		 {
			 type = TSN_NMAC;
		 }
		 /*
		 else if(PTP_FLAG == (tmp[0] & PTP_FLAG))//flow type = 100,PTP类型
		 {
			 type = TSN_PTP;
		 }
		 */
		 else if(tmp[0]>>5 == 4)
		 {
			type = TSN_PTP;
		 }
		 else //其他类型映射流，需要判断是否为分片重组报文,暂时没有考虑TSMP报文
		 {
			 
				 type = TSN_REGROUP_FLOW;
		 }		 
		 
	 }
	 
	 return type;
 }

 u16 count = 0;
 u64 libpcap_count = 0;


 void ethernet_protocol_callback(unsigned char *argument,const struct pcap_pkthdr *packet_heaher,const unsigned char *packet_content)
{
	u8 tmp[6] = {0};
	u8 tmp1[6] = {0};
	
    //NPLIB_DBG("libpcap data\n");

	libpcap_count = libpcap_count+1;
	//printf("libpcap_count=%lld\n",libpcap_count);

	if(pcap_stats(pcap_handle,&p_stat)!=0)
		{
			printf("88888\n");
			perror("error");

		}
	printf("1111111111  p_stat.ps_recv = %d,p_stat.ps_drop=%d,p_stat.ps_ifdrop=%d \n",p_stat.ps_recv,p_stat.ps_drop,p_stat.ps_ifdrop);
    
	memcpy(tmp,(u8*)packet_content + 6,6);
	if(tmp[0]==244 && tmp[1]==147)
	{
		//printf("discard\n");
		return;
	}
	memcpy(tmp1,(u8*)packet_content + 8,6);

	//printf("tmp1[0] = %d\n",tmp1[0]);
	if(tmp1[0] == 176 && tmp1[1] == 131)
	{
		count++;
		printf("count = %d\n",count);
	}
	//count++;
	//printf("count = %d\n",count);
	np_pkt_print((u8*)packet_content,packet_heaher->len);
	//np_pkt_print((u8*)packet_content,packet_heaher->len);
	//np_pkt_print((u8*)packet_content,packet_heaher->len);
	//np_pkt_print((u8*)packet_content,packet_heaher->len);
	//np_pkt_print((u8*)packet_content,packet_heaher->len);
	//np_pkt_print((u8*)packet_content,packet_heaher->len);
	//np_pkt_print((u8*)packet_content,packet_heaher->len);
	//np_pkt_print((u8*)packet_content,packet_heaher->len);
	//np_pkt_print((u8*)packet_content,packet_heaher->len);
    if(packet_heaher->len<=0)
    {
      //NPLIB_DBG("libpcap data is err \n");
    }
	
	//第一步将报文拷贝至缓存区
	u8* mt_addr;//没有metedata
	mt_addr=hx_malloc_metedata_buf(&data_request_context.buffer_list);//取一个缓存区mt地址
	
	if(mt_addr==NULL)
	{
		//NPLIB_DBG("hx_malloc_metedata_buf err \n");
		return;
	}
		
    memcpy(mt_addr,packet_content,packet_heaher->len);//将报文拷贝至缓存区

	//第二步构造消息填充到发送队列
	struct msg_node* tmp_msg_node=(struct msg_node*)((u8*)mt_addr-PAD_BUF_LEN-MSG_NODE_LEN);
	u8 tmp_msg_type=0;
	
	tmp_msg_type=get_msg_type((u8*)packet_content);
	tmp_msg_node->msg_type=tmp_msg_type;

	//NPLIB_DBG("ethernet_protocol_callback tmp_msg_type = %x\n",tmp_msg_type);
	
	tmp_msg_node->src_service_id=DATA_REQUEST_ID;
	tmp_msg_node->eth_pkt_len=packet_heaher->len;
	tmp_msg_node->eth_head_ptr=mt_addr;
	
	if(ERR==hx_write_msg_quene_node(&data_request_context.txq,tmp_msg_node))
	{
	  //NPLIB_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&data_request_context.buffer_list,tmp_msg_node);
	}

	return ;

}
 

void hx_data_receive_loop()
{
        char error_content[128];    //出错信息
		//pcap_t * pcap_handle;
		unsigned char *mac_string;
		unsigned short ethernet_type;           //以太网类型
		char *net_interface =NULL;//"enaftgm1i0";                 //接口名字
		struct pcap_pkthdr protocol_header;
		struct ether_header *ethernet_protocol;

		char temp_net_interface[256] = {0};
		get_cfgx_file(TSN_CONFIG_FILE, "net_interface", temp_net_interface);
		net_interface=temp_net_interface;
		//printf("temp_net_interface:%s\n",temp_net_interface);
		
		//获取网络接口
		//net_interface = pcap_lookupdev(error_content);//寻找网络设备
		//printf("net_interface:%s\n",net_interface);
		if(NULL == net_interface)
		{
		    perror("pcap_lookupdev");
		    exit(-1);
		}
		pcap_handle = pcap_open_live(net_interface,2000,1,0,error_content);//打开网络接口

		/*配置过滤器*/
#if 1
		struct bpf_program filter;
		pcap_compile(pcap_handle, &filter, "not ether src 50:9a:4c:30:1D:09", 1, 0);
		pcap_setfilter(pcap_handle, &filter);
#endif

		if(pcap_setdirection(pcap_handle,PCAP_D_IN)!=0)
		{
			//printf("88888\n");
			perror("error");

		}
		else
		{}
			//printf("*************set success\n");
			
		if(pcap_loop(pcap_handle,-1,ethernet_protocol_callback,NULL) < 0)//捕获数据包
		{
		    perror("pcap_loop");
		}
		pcap_close(pcap_handle);

		return;
}



void hx_data_receive_destroy()
{
	
	return ;
}






