#include "../include/np.h"
#include "../include/tools.h"


#define BUF_LEN_2048 2048
#define BUF_LEN_4096 4096
#define TSN_METEDATA_LEN 8
#define MAC_LEN 12

#define FLOW_MAP_FLAG 0x10
#define NMAC_FLAG 0xA0
#define PTP_FLAG 0x80
#define REGROUP_FLAG 0x40
#define FRAGID_FLAG 0x3c


#define READ_FILE_PATH8 "./tsn_app/data018.txt"


extern struct hx_context data_request_context;//数据请求线程变量


FILE *hx_libpcap_fp8 = NULL;

typedef int(*hx_pcap_callback)(unsigned char* pkt, int len,int inport);



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

	printf("1111 inport = %d \n",inport);

	get_cfgx_file(TSN_CONFIG_FILE, "endpoint_port", endpoint_port);
	port = atoi(endpoint_port);

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
		else if(PTP_FLAG == (tmp[0] & PTP_FLAG))//flow type = 100,PTP类型
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


int ethernet_protocol_callback(unsigned char* pkt, int len,int inport)
{
    //NPLIB_DBG("libpcap data\n");
    //np_pkt_print(pkt,len);

	struct msg_node* tmp_msg_node=NULL;
	u8 tmp_msg_type = 0;
	u8 *ptr = NULL;

	if(len<=0)
    {
      NPLIB_DBG("libpcap data is err \n");
    }
	

	//第一步将报文拷贝至缓存区
	u8* mt_addr;//有metedata
	mt_addr=hx_malloc_metedata_buf(&data_request_context.buffer_list);//取一个缓存区mt地址

	if(mt_addr==NULL) 
		return ERR;

	memcpy(mt_addr,pkt,len);//将报文拷贝至缓存区
	

	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)mt_addr-PAD_BUF_LEN-MSG_NODE_LEN);
	
	//根据metedata数据获取msg类型
	//np_pkt_print(pkt, len);

	if((ptr = strstr(pkt,"ffffffff"))!= NULL)
	{
		tmp_msg_type = TSN_TIMER;
	}
	else
	{
		tmp_msg_type=get_msg_type(pkt);
	}
	
	tmp_msg_node->msg_type=tmp_msg_type;
    
    //NPLIB_DBG("11111tmp_msg_type = %x \n",tmp_msg_type);

	//仿真测试需要
	tmp_msg_node->reserve = inport;
	
	tmp_msg_node->src_service_id=DATA_REQUEST_ID;
	tmp_msg_node->eth_pkt_len=len;
	tmp_msg_node->eth_head_ptr=mt_addr;
	
	//memcpy(&tmp_msg_node->um,pkt,8);//拷贝metedata至msg的um
	//NPLIB_DBG("libpcap data tmp_msg_node->um.eth_type:%x dmid:%d\n",htons(tmp_msg_node->um.eth_type),tmp_msg_node->um.dmid);	

	if(ERR==hx_write_msg_quene_node(&data_request_context.txq,tmp_msg_node))
	{
	  NPLIB_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&data_request_context.buffer_list,tmp_msg_node);
	}
	
	return SUCCESS;

}


//删除字符串中的空格
void str_del_space(unsigned char *str)
{
	unsigned char *str_c=str;
	int i,j=0;
	for(i=0;str[i]!='\0';i++)
	{
		if((str[i]!=' ') && (str[i]!='\r') && (str[i]!='\n') )
			str_c[j++]=str[i];
	}
	str_c[j]='\0';
	str=str_c;	
}



int str_to_hex(unsigned char *str, unsigned char *out, unsigned int *outlen)
{
    unsigned char *p = str;
    unsigned char high = 0, low = 0;
    int tmplen = strlen(p), cnt = 0;
    tmplen = strlen(p);
    while(cnt < (tmplen / 2))
    {
        high = ((*p > '9') && ((*p <= 'F') || (*p <= 'f'))) ? *p - 48 - 7 : *p - 48;
		low = (*(++ p) > '9' && ((*p <= 'F') || (*p <= 'f'))) ? *(p) - 48 - 7 : *(p) - 48;
        out[cnt] = ((high & 0x0f) << 4 | (low & 0x0f));
        p ++;
        cnt ++;
    }
    if(tmplen % 2 != 0) out[cnt] = ((*p > '9') && ((*p <= 'F') || (*p <= 'f'))) ? *p - 48 - 7 : *p - 48;
    
    if(outlen != NULL) *outlen = tmplen / 2 + tmplen % 2;
    return tmplen / 2 + tmplen % 2;
}


int hx_data_rec_init()
{

	char *file8 = READ_FILE_PATH8;

	char tmp_buf[128] = {0};


	if(access(file8,0) == -1)
    {
    	sprintf(tmp_buf,"touch %s", READ_FILE_PATH8);
		system(tmp_buf);
    }


	if( NULL==(hx_libpcap_fp8=fopen(file8,"r+") ))
	{
	
		printf("open %s failed\n",file8);
		
		return -1;
	
	}
	
	return 0;
}


void hx_data_receive_destroy()
{

	if(hx_libpcap_fp8!=NULL)
	
	{
	
		fclose(hx_libpcap_fp8);
	
	}
	
	return ;
}


int hx_pcap_loop(hx_pcap_callback callback)
{
	unsigned char *line = (unsigned char *)malloc(BUF_LEN_2048 * sizeof(char));
	unsigned char *line1 = (unsigned char *)malloc(BUF_LEN_4096 * sizeof(char));
	int len = 0;
	int inport = 0;

	unsigned char *ptr = NULL;
	unsigned char *ptr_head = NULL;

	memset(line,0,BUF_LEN_2048);
	memset(line1,0,BUF_LEN_4096);

	
	while(1 )//逐行读取数据
	
	{
		if(fgets(line1, BUF_LEN_4096, hx_libpcap_fp8) != NULL)
		{
			len = strlen(line1);
			//printf("the len = %d, content of each line is:\n %s \n",len,line1);

			if((ptr = strstr(line1,"1111")) != NULL)
			{
				strcpy(ptr,"\0");
				inport = 8;
				
				if((ptr = strstr(line1,"ffffffff"))!= NULL)
				{
					len = strlen(line1);
					callback(line1,len,inport);
				}
				else
				{
					str_del_space(line1);
					ptr_head = line1 + 24;

					
					len = strlen(ptr_head);
					printf("1111the len = %d, content of each line is:\n %s \n",len,ptr_head);

					str_to_hex(ptr_head,line,&len);
					callback(line,len,inport);
				}
				
				//len = strlen(line);
				//printf("2222the len = %d, content of each line is:\n %s \n",len,line);
				
				
			}
			else
			{
				//printf("the len = %d \n",len);
				fseek(hx_libpcap_fp8,-len,SEEK_CUR);
			}
			
			memset(line,0,BUF_LEN_2048);
			memset(line1,0,BUF_LEN_4096);
		}

	}


	if(line1 != NULL)
	{
		free(line1);
		line1 = NULL;
	}

	if(line != NULL)
	{
		free(line);
		line = NULL;
	}
}

void hx_data_receive_loop()
{
	hx_data_rec_init();
	
	hx_pcap_loop(ethernet_protocol_callback);
}


#if 0
int main()
{

	//hx_libpcap_init();
	
	//hx_pcap_loop(callback);

	//hx_libpcap_destroy();

	unsigned char  str[128] ="00000b06f7";

	unsigned char  str1[128];
	int len =0;
	int i = 0;
	len = strlen(str);

	str_to_hex(str,str1,&len);

	for(i=0;i<len;i++)
	{
		printf("%d \n",str1[i]);
	}

	len = strlen(str1);
	printf("len = %d, %s \n",len,str1);
	return 0;
}
#endif

