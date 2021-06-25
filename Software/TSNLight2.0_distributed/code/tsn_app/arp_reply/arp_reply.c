
#include "arp_reply.h"

//以太网头的长度
#define ARP_ETH_LEN 14

//mac的长度
#define ARP_MAC_LEN 6

//arp表最大的数目
#define ARP_TABLE_NUM 4




struct hx_context  arp_reply_context;

struct arp_mac_info arp_table[ARP_TABLE_NUM]={0};

u8 arp_type[2] = {0x00,0x002};



int hx_arp_reply_contex_init()
{
	struct hx_context_arg  arp_reply_context_arg;
	memset(&arp_reply_context_arg,0,sizeof(struct hx_context_arg));
	
	arp_reply_context_arg.service_id=TSN_ARP_REPLY_ID;//0x01
	arp_reply_context_arg.rxq_size=128;
	arp_reply_context_arg.txq_size=128;

	memset(&arp_reply_context,0,sizeof(struct hx_context));
	hx_init(&arp_reply_context,&arp_reply_context_arg); 

	return 0;
}


int hx_arp_reply_contex_destroy()
{
	hx_destroy(&arp_reply_context); 
	return 0;
	
}


void buid_arp_reply_pkt(u8* pkt, u16 len,int index)
{
	u8* ptr = NULL;
	u8 metedata[16] = {0};
	u8 tmp[32] = {0};

	u8 inport;

	/****metedata的处理***/
	//拷贝metedata
	memcpy(metedata,pkt,8);

	//清空pkt的metedata
	memset(pkt,0,8);
	
	//获取metedata输入端口号
	inport = metedata[6]>>4;

	//设置metedata 的pkt type为BE,更新c
	metedata[0] = 0xc0;
	
	//设置metedata输出端口号
	if(0 == inport)
	{
		metedata[1] = 0;
		metedata[2] = 0;
		metedata[2] = 1<<7; 
	}
	else
	{
		inport = inport - 1;
		metedata[1] = 0;
		metedata[1] = 1<<inport;	
		metedata[2] = 0;
		
	}

	//metedata赋值
	ptr = pkt ;
	memcpy(ptr,metedata,3);

	/****arp报文的处理***/
	//偏移metedata，指向报文的源mac
	ptr = pkt + 8+ ARP_MAC_LEN;

	//目的mac赋值
	memcpy(pkt+8,ptr,ARP_MAC_LEN);

	//源mac赋值
	memcpy(ptr,arp_table[index].enet_local,ARP_MAC_LEN);

	//arp  type
	ptr = pkt + 8 + ARP_ETH_LEN + ARP_MAC_LEN;
	memcpy(ptr,arp_type,2);

	//原报文的send mac和send ip存储，以赋值arp reply的target mac和ip
	ptr = ptr +2;
	memcpy(tmp,ptr,10);
	
	//send mac
	memcpy(ptr,arp_table[index].enet_local,ARP_MAC_LEN);

	//send IP
	ptr = ptr + ARP_MAC_LEN;
	memcpy(ptr,arp_table[index].ip_local,4);

	//target mac和ip
	ptr = ptr + 4;
	memcpy(ptr,tmp,10);

	np_pkt_print(pkt , len);	
	
	return;
}

#if 0
int cmp_tuples(struct five_tuple_info *key1,struct five_tuple_info *key2)
{
    u8 *m1 = (u8 *)key1;
	u8 *m2 = (u8 *)key2;
	u8 diffs = 0;
	int i = 0;//*cnt = sizeof(struct flow)/4;

	while(i<13 && diffs == 0)
	{
		diffs |= (m1[i] ^ m2[i]);	
		//printf("[%d]rule:%08lX,mask:%08lX,key:%08lX,diffs:%08lX\n",i,m1[i],m3[i],m2[i],diffs);
		i++;
	}
	//printf("-----------------diffs:%lX---------------\n",diffs);
	return diffs == 0;
}
#endif

int arp_table_match(u8* ip)
{
	int i = 0;
	int j = 0;
	u8 diffs = 0;
	
	//printf("%02x,%02x,%02x,%02x\n",ip[0],ip[1],ip[2],ip[3]);

	for(i =0 ; i<ARP_TABLE_NUM;i++)
	{
		j = 0;
		diffs = 0;
		while(j<4 && diffs == 0)
		{
			diffs |= (arp_table[i].ip_local[j] ^ ip[j]);
			//printf("i= %d ,j=%d \n",i,j);
			j++;
		}

		//printf("i= %d ,j=%d ,diff = %d \n",i,j,diffs);
		
		if(diffs == 0)
		{
			break;
			
		}
	}

	if( i == ARP_TABLE_NUM)
	{
		i = -1;
	}

	//printf("i = %d \n",i);
	
	return i;

	
}


int is_arp_type_req(u8* pkt, u16 len)
{
	pkt = pkt + 8 + 14 + 6 ;//偏移metedata+以太网头+arp头前6字节，以偏移到arp类型

	u8 type[2] = {0};

	memcpy(type,pkt,2);
	
	if((type[0] == 0x00) && (type[1] == 0x01))
	{
		return 0;
	}
	else
	{
		return -1;
	}
	
	return 0;
}


void ip_mac_table_init()
{
	u8 tmp_mac_name[16]={0};
	u8 tmp_ip_name[16]={0};
	u8 tmp[32] = {0};
	u8 str[128] = {0};

	int i = 0;

	for(i =0 ; i<ARP_TABLE_NUM;i++)
	{
		sprintf(tmp_mac_name,"LOCAL_MAC%d",i+1);
		sprintf(tmp_ip_name,"LOCAL_IP%d",i+1);

		//获取mac和IP
		get_cfgx_file(TSN_CONFIG_FILE, tmp_mac_name, tmp);
		
		sscanf(tmp,"%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
			&arp_table[i].enet_local[0],&arp_table[i].enet_local[1],
			&arp_table[i].enet_local[2],&arp_table[i].enet_local[3],
			&arp_table[i].enet_local[4],&arp_table[i].enet_local[5]);

		get_cfgx_file(TSN_CONFIG_FILE, tmp_ip_name, tmp);
		sscanf(tmp,"%hhd.%hhd.%hhd.%hhd.",&arp_table[i].ip_local[0],&arp_table[i].ip_local[1],&arp_table[i].ip_local[2],&arp_table[i].ip_local[3]);
	}

#if 0	
	for(i =0 ; i<ARP_TABLE_NUM;i++)
	{
		sprintf(str,"%02x%02x%02x%02x%02x%02x",arp_table[i].enet_local[0],arp_table[i].enet_local[1],
			arp_table[i].enet_local[2],arp_table[i].enet_local[3],
			arp_table[i].enet_local[4],arp_table[i].enet_local[5]);
		printf("mac = %s \n",str);

		sprintf(str,"%02x%02x%02x%02x",arp_table[i].ip_local[0],arp_table[i].ip_local[1],arp_table[i].ip_local[2],arp_table[i].ip_local[3]);
		printf("ip = %s \n",str);
	}

#endif
	return;
}



/*处理线程*/
void start_arp_reply(void *argv)
{
	struct msg_node* tmp_msg_node = NULL;
	
	hx_arp_reply_contex_init();
	ip_mac_table_init();
	int ret = -1;
	u8* ptr = NULL;
	u8 tmp_ip[4] = {0};
	
	while(1)
	{
		tmp_msg_node=hx_read_msg_quene_node(&arp_reply_context.rxq);//读取接收队列的消息
		
	   if(tmp_msg_node!=NULL)
	   	{
			
            //打印
			np_pkt_print(tmp_msg_node->eth_head_ptr , tmp_msg_node->eth_pkt_len);	

			//是否是arp请求报文
			ret = is_arp_type_req(tmp_msg_node->eth_head_ptr , tmp_msg_node->eth_pkt_len);
			if(-1 == ret)
			{
				ARP_REPLY_ERR("is not arp req pkt!\n");
				hx_free_buf(&arp_reply_context.buffer_list,tmp_msg_node);
				continue;
			}

			//是否arp表匹配成功
			ptr = tmp_msg_node->eth_head_ptr + 8 + 38;//指针偏移到请求IP地址的位置，8为metedata长度，38为arp报文偏移量
			//tmp_ip = ptr;
			printf("IP:%d,%d,%d,%d\n",ptr[0],ptr[1],ptr[2],ptr[3]);
			ret = arp_table_match(ptr);
			if(-1 == ret)
			{
				ARP_REPLY_ERR("is not match arp table!\n");
				hx_free_buf(&arp_reply_context.buffer_list,tmp_msg_node);
				continue;
			}

			buid_arp_reply_pkt(tmp_msg_node->eth_head_ptr, tmp_msg_node->eth_pkt_len,ret);

			//msg修改
			tmp_msg_node->src_service_id = TSN_ARP_REPLY_ID;
			tmp_msg_node->reserve = 2;
				
			if(ERR==hx_write_msg_quene_node(&arp_reply_context.txq,tmp_msg_node))
			{
			  ARP_REPLY_DBG("hx_write_msg_quene_node fail\n");
			  hx_free_buf(&arp_reply_context.buffer_list,tmp_msg_node);
			}
	   }
	}

	hx_arp_reply_contex_destroy();

	ARP_REPLY_DBG("start_arp_reply end!\n");
}



int arp_reply_init()
{
	int ret = -1;
	pthread_t arp_replyid;

	//ARP_REPLY_ERR("1111111111111111arp_reply_init \n");
		
	ret=pthread_create(&arp_replyid,NULL,(void *)start_arp_reply,NULL); 
	
	if(0 != ret)
	{
		ARP_REPLY_ERR("create rec_test_init fail!ret=%d err=%s\n",ret, strerror(ret));
	}

	return ret;
}

/*
int main()
{
	pthread_mutex_init(&timer_lock,NULL);
	
	hx_register_timer(2*BASE_TIMER,2,1);
	hx_timer_handler();

	//sleep(3);

	//hx_register_timer(8*BASE_TIMER,8,1);
	
	while(1)
	{
		sleep(99999);
	}

	return 0;
}
*/
