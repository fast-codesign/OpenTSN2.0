#include "../include/np.h"

#define BUF_LEN_2048 2048
#define BUF_LEN_4096 4096


unsigned char *strBuf = NULL;
unsigned char *line1 = NULL;


#define WRITE_FILE_PATH8 "./tsn_app/data118.txt"
#define WRITE_FILE_PATH "./tsn_app/data218.txt"



FILE *hx_libnet_fp8 = NULL;
FILE *hx_libnet_fp = NULL;



//字符串数组转换成十六进制形式的字符串
int array_to_Str(unsigned char *buf, unsigned int buflen, unsigned char *out)
{

    unsigned char pbuf[32];
	memset(strBuf,0,BUF_LEN_4096);

    int i = 0;

	sprintf(pbuf, "%02X", buf[i]);
	strncat(strBuf, pbuf, 2);
	
    for(i = 1; i < buflen; i++)
    {
        sprintf(pbuf, "%02X", buf[i]);
		strncat(strBuf, " ", 1);
        strncat(strBuf, pbuf, 2);
    }

    strncpy(out, strBuf, buflen * 2 + i);
    printf("out = %s\n", out);

	
	
    return buflen * 2 + i;
}



void hx_data_send_init()
{

	char *file8 = WRITE_FILE_PATH8;
	char *file = WRITE_FILE_PATH;


	line1 = (unsigned char *)malloc(BUF_LEN_4096 * sizeof(char));
	strBuf = (unsigned char *)malloc(BUF_LEN_4096 * sizeof(char));


	if( NULL==(hx_libnet_fp8=fopen(file8,"w+") ))
	{
	
		printf("open %s failed\n",file8);
		
		exit(1);
	
	}

	if( NULL==(hx_libnet_fp=fopen(file,"w+") ))
	{
	
		printf("open %s failed\n",file);
		
		exit(1);
	
	}
	
	return ;
}


void hx_data_send_destroy()
{

	if(hx_libnet_fp8!=NULL)
	
	{
	
		fclose(hx_libnet_fp8);
	
	}
	

	if(hx_libnet_fp!=NULL)
	
	{
	
		fclose(hx_libnet_fp);
	
	}

	
	if(strBuf != NULL)
	{
		free(strBuf);
		strBuf = NULL;
	}

	if(line1 != NULL)
	{
		free(line1);
		line1 = NULL;
	}
	
	return ;
}


int hx_libnet_write(unsigned char* pkt,unsigned int len)
{
	int f_len;
	
	memset(line1,0,BUF_LEN_4096);	

	array_to_Str(pkt,len,line1);
	
	f_len = fputs(line1,hx_libnet_fp8);

	if( -1 == f_len)
	{
		printf("hx_libnet_write error! \n");
	}

	fputc('\r', hx_libnet_fp8);

	fputc('\n', hx_libnet_fp8);

	fflush(hx_libnet_fp8);

	
	return 0;
}


int hx_libnet_write_state()
{
	int f_len;
	
	unsigned char tmp[8]={0};

	tmp[0]='0';
	
	tmp[1]='1';
	
	f_len = fputs(tmp,hx_libnet_fp);

	if( -1 == f_len)
	{
		printf("hx_libnet_write error! \n");
	}

	fflush(hx_libnet_fp);

	
	return 0;
}


void hx_data_send(struct msg_node* tmp_msg_node)
{
	hx_libnet_write(tmp_msg_node->eth_head_ptr,tmp_msg_node->eth_pkt_len);
	hx_libnet_write_state();

	unsigned char tmp[8]={0};
	unsigned char *ptr = NULL;
	char tmp_buf[128] = {0};
	
	sprintf(tmp_buf,"cat /dev/null > %s", WRITE_FILE_PATH8);

	while(1)
	{
		if((fgets(tmp, 8, hx_libnet_fp) != NULL) && (ptr = strstr(tmp,"02")) != NULL)
		{
			printf("have read the data \n");
			system(tmp_buf);
			rewind(hx_libnet_fp8);
			break;
		}
	}
	
	
	return;
}

#if 0
int main()
{
	unsigned char pkt[1024];
	unsigned int outport;
	int len = 0;



	hx_libnet_init();
	
	while(1)
	{
		memset(pkt,0,1024);
		printf("enter a string:\n");
		
      	scanf("%s",pkt);

		printf("enter outport:\n");
      	scanf("%u",&outport);
		
		len = strlen(pkt);
		
		hx_libnet_write(pkt,len,outport);
	}

	hx_libnet_destroy();


	
	return 0;
}
#endif



