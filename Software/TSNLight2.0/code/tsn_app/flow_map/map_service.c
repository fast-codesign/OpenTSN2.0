#include "map_service.h"
#include "../timer/timer.h"


struct hx_context map_context;
struct map_table map_table_list[map_table_len];

void hx_map_contex_init()
{
    struct hx_context_arg hx_map_arg;
    memset(&hx_map_arg,0,sizeof(struct hx_context_arg));

    hx_map_arg.service_id = MAP_SERVICE_ID; //0X11
    hx_map_arg.rxq_size = 1024;
    hx_map_arg.txq_size = 1024;


	memset(&map_context,0,sizeof(struct hx_context));
    hx_init(&map_context,&hx_map_arg);

    return ;
}

int hx_map_contex_destroy()
{
    hx_destroy(&map_context);
    return 0;
}


struct five_tuple_info five_tuple_init(u8 src_ip[],u8 dst_ip[],u16 src_port,u16 dst_port,u8 protocol_type)
{
	int i = 0;
	struct five_tuple_info five_tuple_init;
	memset(&five_tuple_init,0,sizeof(five_tuple_init));
	for(i=0;i<4;i++)
	{
		five_tuple_init.src_ip[i] = src_ip[i];
		five_tuple_init.dst_ip[i] = dst_ip[i];
	}
	five_tuple_init.src_port = src_port;
	five_tuple_init.dst_port = dst_port;
	five_tuple_init.protocol_type = protocol_type;

	return five_tuple_init;
}

struct TSNtag TSNtag_init(u8 flow_type,u16 flow_id,u16 seq_id,u8 frag_flag,u8 frag_id,u8 inject_addr,u8 submit_addr)
{
	struct TSNtag TSNtag_init;
	memset(&TSNtag_init,0,sizeof(TSNtag_init));
	TSNtag_init.flow_type = flow_type;
	TSNtag_init.flow_id = flow_id;
	TSNtag_init.seq_id = seq_id;
	TSNtag_init.frag_flag = frag_flag;
	TSNtag_init.frag_id = frag_id;
	TSNtag_init.inject_addr = inject_addr;
	TSNtag_init.submit_addr = submit_addr;
	return TSNtag_init;
}

struct metedata metedata_init(u8 pkttype,u8 md_inject_addr,u16 outport,u8 lookup_en,u8 frag_last,u64 reserve)
{
	struct metedata metedata_init;
	memset(&metedata_init,0,sizeof(metedata_init));
	metedata_init.pkttype = pkttype;
	metedata_init.md_inject_addr = md_inject_addr;
	metedata_init.outport = outport;
	metedata_init.lookup_en = lookup_en;
	metedata_init.frag_last = frag_last;
	metedata_init.reserve = reserve;
	return metedata_init;
}

void print_five_tuple(struct five_tuple_info five_tuple)
{
	int i = 0;
	for(i=0;i<4;i++)
	{
		printf("this is src_ip: %02x\t",five_tuple.src_ip[i]);
	}
	printf("\n\n");
	for(i=0;i<4;i++)
	{
		printf("this is dst_ip: %02x\t",five_tuple.dst_ip[i]);
	}
	printf("\n\n");
	printf("this is src_port_1: %02x\t",(five_tuple.src_port & 0xff00));
	printf("this is src_port_2: %02x\t",(five_tuple.src_port & 0x00ff));
	printf("\n\n");
	printf("this is dst_port_1: %02x\t",(five_tuple.dst_port & 0xff00));
	printf("this is dst_port_2: %02x\t",(five_tuple.dst_port & 0x00ff));
	printf("\n\n");
	printf("this is protocol_type: %02x\t",five_tuple.protocol_type);
}

struct map_table map_table_init(int table_id,struct TSNtag TSNtag_init,struct metedata metedata_init,struct five_tuple_info five_tuple_init)
{
	struct map_table map_table_init;
	memset(&map_table_init,0,sizeof(map_table_init));

	map_table_init.ID = table_id;
	map_table_init.TSNtag_init = TSNtag_init;
	map_table_init.metedata_init = metedata_init;
	map_table_init.five_tuple_init = five_tuple_init;
	return map_table_init;
}

void riprt_1(char *str)
{
	int len, i;

	if (str == NULL)
		return;
	len = strlen(str);
	if (len == 0) 
		return;

	for (i = 0; i < len; i++)
	{
		if (str[i] == '\r' || str[i] == '\n')
			str[i] = '\0';
	}
}

//从文本中获取配置信息
void get_cfg_info()
{
	FILE *fp = NULL;
	char table_info[50];
    unsigned char high;
    unsigned char low;
    //struct map_table map_table_list[map_table_len];
    int ID=0;
    int i=0;
    int flow_flag = 0;
    char *fir_pstr = NULL;
    char *sec_pstr = NULL;
    unsigned char temp;
    unsigned char temp_1;
	fp = fopen("./static_table.txt", "r");
	if(fp == NULL)
	{
		//printf("Could not read static_table.txt file!\n");
		return ;
	}
	//printf("Open static_table.txt file successfully!\n");
	while(fgets(table_info,50,fp) != NULL)
	{
        riprt_1(table_info);
        if(flow_flag == NO_FLOW)
		{
			if(!strcmp(table_info, "{"))
			{
				flow_flag = NEW_FLOW;
			}
			else
            {
                continue;
            }
				
		}
        else if(flow_flag == NEW_FLOW)
        {
            if(!strcmp(table_info, "}"))
            {
                flow_flag = NO_FLOW;
            }
            else 
            {
                fir_pstr = strtok_r(table_info, ":", &sec_pstr);
				if(!strcmp(fir_pstr, "ID"))
                {
                    ID = *sec_pstr - 48 ;
                    //printf("ID:%d\n",ID);
                }
					
				else if(!strcmp(fir_pstr, "src_ip"))
				{
                    for(i=0;i<4;i++)
                    {
                        high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					    low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                        sec_pstr +=1;
                        temp = ((high & 0x0f) << 4 | (low & 0x0f));
                        map_table_list[ID].five_tuple_init.src_ip[i] = temp;
                        //printf("src_ip:%02x\n",map_table_list[ID].five_tuple_init.src_ip[i]);
                    }
				}
                else if(!strcmp(fir_pstr, "dst_ip"))
                {
                    for(i=0;i<4;i++)
                    {
                        high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					    low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                        sec_pstr +=1;
                        temp = ((high & 0x0f) << 4 | (low & 0x0f));
                        map_table_list[ID].five_tuple_init.dst_ip[i] = temp;
                        //printf("dst_ip:%02x\n",map_table_list[ID].five_tuple_init.dst_ip[i]);
                    }
                }
                else if(!strcmp(fir_pstr, "src_port"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                    temp = ((high & 0x0f) << 4 | (low & 0x0f));

                    sec_pstr +=1;
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                    temp_1 = ((high & 0x0f) << 4 | (low & 0x0f));

                    map_table_list[ID].five_tuple_init.src_port = (((unsigned short)temp & 0x00ff) <<8 |((unsigned short)temp_1 & 0x00ff));
                    //printf("src_port:%02x\n",map_table_list[ID].five_tuple_init.src_port);

                }
                else if(!strcmp(fir_pstr, "dst_port"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                    temp = ((high & 0x0f) << 4 | (low & 0x0f));
                    
                    sec_pstr +=1;
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                    temp_1 = ((high & 0x0f) << 4 | (low & 0x0f));

                    map_table_list[ID].five_tuple_init.dst_port = (((unsigned short)temp & 0x00ff) <<8 |((unsigned short)temp_1 & 0x00ff));
                    //printf("dst_port:%02x\n",map_table_list[ID].five_tuple_init.dst_port);
                }
                else if(!strcmp(fir_pstr, "protocol_type"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					temp = ((high & 0x0f) << 4 | (low & 0x0f));
                    map_table_list[ID].five_tuple_init.protocol_type = temp;
                    //printf("protocol_type:%02x\n",map_table_list[ID].five_tuple_init.protocol_type);
                }
                else if(!strcmp(fir_pstr, "flow_type"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					temp = ((high & 0x0f) << 4 | (low & 0x0f));
                    map_table_list[ID].TSNtag_init.flow_type = temp>>4;
                    //printf("flow_type:%02x\n",map_table_list[ID].TSNtag_init.flow_type);
                }
                else if(!strcmp(fir_pstr, "flow_id_TSNtag"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                    temp = ((high & 0x0f) << 4 | (low & 0x0f));

                    sec_pstr +=1;
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                    temp_1 = ((high & 0x0f) << 4 | (low & 0x0f));

                    map_table_list[ID].TSNtag_init.flow_id = (((unsigned short)temp & 0x00ff) <<8 |((unsigned short)temp_1 & 0x00ff));
                    //printf("flow_id:%02x\n",map_table_list[ID].TSNtag_init.flow_id);

                }
                else if(!strcmp(fir_pstr, "seq_id"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                    temp = ((high & 0x0f) << 4 | (low & 0x0f));

                    sec_pstr +=1;
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                    temp_1 = ((high & 0x0f) << 4 | (low & 0x0f));

                    map_table_list[ID].TSNtag_init.seq_id = (((unsigned short)temp & 0x00ff) <<8 |((unsigned short)temp_1 & 0x00ff));
                    //printf("seq_id:%02x\n",map_table_list[ID].TSNtag_init.seq_id);
                }
                else if(!strcmp(fir_pstr, "frag_flag"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					temp = ((high & 0x0f) << 4 | (low & 0x0f));
                    map_table_list[ID].TSNtag_init.frag_flag = temp;
                    //printf("frag_flag:%02x\n",map_table_list[ID].TSNtag_init.frag_flag);
                }
                else if(!strcmp(fir_pstr, "frag_id"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					temp = ((high & 0x0f) << 4 | (low & 0x0f));
                    map_table_list[ID].TSNtag_init.frag_id = temp;
                    //printf("frag_id:%02x\n",map_table_list[ID].TSNtag_init.frag_id);
                }
                else if(!strcmp(fir_pstr, "inject_addr"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					temp = ((high & 0x0f) << 4 | (low & 0x0f));
                    map_table_list[ID].TSNtag_init.inject_addr = temp;
                    //printf("inject_addr:%02x\n",map_table_list[ID].TSNtag_init.inject_addr);
                }
                else if(!strcmp(fir_pstr, "submit_addr"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					temp = ((high & 0x0f) << 4 | (low & 0x0f));
                    map_table_list[ID].TSNtag_init.submit_addr = temp;
                    //printf("submit_addr:%02x\n",map_table_list[ID].TSNtag_init.submit_addr);
                }
                else if(!strcmp(fir_pstr, "pkttype"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					temp = ((high & 0x0f) << 4 | (low & 0x0f));
                    map_table_list[ID].metedata_init.pkttype = temp >> 4;
                    //printf("pkttype:%02x\n",map_table_list[ID].metedata_init.pkttype);
                }
                else if(!strcmp(fir_pstr, "md_inject_addr"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					temp = ((high & 0x0f) << 4 | (low & 0x0f));
                    map_table_list[ID].metedata_init.md_inject_addr = (temp << 3) >>3;
                    //printf("md_inject_addr:%02x\n",map_table_list[ID].metedata_init.md_inject_addr);
                }
                else if(!strcmp(fir_pstr, "outport"))
                {
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                    temp = ((high & 0x0f) << 4 | (low & 0x0f));

                    sec_pstr +=1;
                    high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
					low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
                    temp_1 = ((high & 0x0f) << 4 | (low & 0x0f));

                    map_table_list[ID].metedata_init.outport = (((unsigned short)temp & 0x00ff) <<8 |((unsigned short)temp_1 & 0x00ff))&0x01ff;
                    //printf("outport:%02x\n",map_table_list[ID].metedata_init.outport);
                }
                else if(!strcmp(fir_pstr, "lookup_en"))
                {
					temp = *sec_pstr-48;
                    map_table_list[ID].metedata_init.lookup_en = temp;
                    //printf("lookup_en:%02x\n",map_table_list[ID].metedata_init.lookup_en);
                }
                else if(!strcmp(fir_pstr, "frag_last"))
                {
                    temp = *sec_pstr-48;
                    map_table_list[ID].metedata_init.frag_last = temp;
                    //printf("frag_last:%02x\n",map_table_list[ID].metedata_init.frag_last);
                }
                else if(!strcmp(fir_pstr, "reserve"))
                {
                    map_table_list[ID].metedata_init.reserve = 0x0;
                    //printf("reserve:%02x\n",map_table_list[ID].metedata_init.reserve);
                }
                else 
                {
                    continue;
                }
            }
        }
        else 
        {
            continue;
        }
	}
}

void map_table_initial()
{
	//TSNtag信息
	u8 flow_type_1=0x4;
	u8 flow_type_2=0x1;

	u16 flow_id_TSNtag=0x0005;
	u16 seq_id=0x0000;
	u8 frag_flag=0x0;
	u8 frag_id=0x0;
	u8 inject_addr=0x0;
	u8 submit_addr=0x0;
	struct TSNtag TSNtag_1,TSNtag_2;
	memset(&TSNtag_1,0,sizeof(TSNtag_1));
	memset(&TSNtag_2,0,sizeof(TSNtag_2));
	TSNtag_1 = TSNtag_init(flow_type_1,flow_id_TSNtag,seq_id,frag_flag,frag_id,inject_addr,submit_addr);
	TSNtag_2 = TSNtag_init(flow_type_2,flow_id_TSNtag,seq_id,frag_flag,frag_id,inject_addr,submit_addr);

	//五元组信息
	u8 src_ip[4] = {0xc0,0xa8,0x01,0x05};
	u8 dst_ip[4] = {0xc0,0xa8,0x01,0x04};
	u16 src_port = 0x1388;
	u16 dst_port = 0x1770; 
	u8 protocol_type = 0x11;

	u8 src_ip_2[4] = {0xff,0xff,0xff,0xff};
	u8 dst_ip_2[4] = {0xff,0xff,0xff,0xff};
	u16 src_port_2 = 0xffff;
	u16 dst_port_2 = 0xffff; 
	u8 protocol_type_2 = 0xff;
	struct five_tuple_info five_tuple_1= five_tuple_init(src_ip,dst_ip,src_port,dst_port,protocol_type);
	struct five_tuple_info five_tuple_2= five_tuple_init(src_ip_2,dst_ip_2,src_port_2,dst_port_2,protocol_type_2);

	//metedata信息
 	u8 pkttype = 0x4;
	u8 pkttype_2 = 0x1;
	u8 md_inject_addr = 0x0;
 	u16 outport = 0x0;
 	u8 lookup_en = 0x01;
 	u8 frag_last = 0x0;
 	u32 reserve = 0x0;

	struct metedata metedata_1= metedata_init(pkttype,md_inject_addr,outport,lookup_en,frag_last,reserve);
	struct metedata metedata_2= metedata_init(pkttype_2,md_inject_addr,outport,lookup_en,frag_last,reserve);

	//printf("metedata_1:%02x\n",metedata_1.pkttype);

	struct map_table map_table_1,map_table_2;
	memset(&map_table_1,0,sizeof(map_table_1));
	memset(&map_table_2,0,sizeof(map_table_2));
	map_table_1 = map_table_init(1,TSNtag_1,metedata_1,five_tuple_1);
	map_table_2 = map_table_init(2,TSNtag_2,metedata_2,five_tuple_2);
 	map_table_list[1] = map_table_1;
	map_table_list[2] = map_table_2;
}

struct five_tuple_info form_five_tuple(u8 *eth_head_ptr)
{
	int j = 0;
    struct five_tuple_info five_tuple;
    u8 *temp;
    temp = eth_head_ptr+23+metedata_len;//指针指向protocol字段
    five_tuple.protocol_type = *(temp);
    temp = eth_head_ptr+26+metedata_len;//指针指向源IP字段
    for(j=0;j<4;j++)
    {
        five_tuple.src_ip[j] = *(temp+j);
    }
	temp = eth_head_ptr+30+metedata_len;//指针指向目的IP字段
    for(j=0;j<4;j++)
    {
        five_tuple.dst_ip[j] = *(temp+j);
    }
	temp = eth_head_ptr+34+metedata_len;//指针指向源port字段
    five_tuple.src_port = ((u16)*(temp)<<8 )| (u16)*(temp+1);
    temp = eth_head_ptr+36+metedata_len;//指针指向源port字段
    five_tuple.dst_port = ((u16)*(temp)<<8 )| (u16)*(temp+1);      

    return five_tuple;
}

int cmp_tuples(struct five_tuple_info *key1,struct five_tuple_info *key2)
{
    u8 *m1 = (u8 *)key1;
	u8 *m2 = (u8 *)key2;
	u8 diffs = 0;
	int i = 0;//*cnt = sizeof(struct flow)/4;
	while(i<13 && diffs == 0)
	{
		diffs |= (m1[i] ^ m2[i]);	
		i++;
	}
	return diffs == 0;
}

int LUT_table(struct five_tuple_info five_tuple,struct map_table map_table_list[])
{
	int i = 0;
	for(i=0;i<map_table_len;i++)
	{
		if(cmp_tuples(&five_tuple,&map_table_list[i].five_tuple_init))
		{
			//printf("start cmp_tuples\n");
			return i;
		}
	}
	return -1;
}

//映射函数
int flow_mapping(int flow_ID,u8 *eth_head_ptr,struct map_table map_table_list[],u16 count,u16 ip_len,u16 sum_pkt_len)
{
	if(flow_ID >=map_table_len)
	{
		return 0;
	}
	u8 *temp = eth_head_ptr;
	if(count == 0)
	{		
		
		u8 pkttype = map_table_list[flow_ID].metedata_init.pkttype;//3
		u8 md_inject_addr = map_table_list[flow_ID].metedata_init.md_inject_addr;//5
		u16 outport =  map_table_list[flow_ID].metedata_init.outport;//9
		u8 lookup_en = map_table_list[flow_ID].metedata_init.lookup_en;//1
		u8 frag_last = map_table_list[flow_ID].metedata_init.frag_last;//1

		temp[0] = 0;
		temp[0] = temp[0] | (pkttype<<5);
		temp[0] = temp[0] | (md_inject_addr);
		//printf("映射函数：%02x\n",temp[0]);

		temp[1] = 0;
		temp[1] = outport>>1;

		temp[2] = 0;
		temp[2] = temp[2] | (outport<<7);
		temp[2] = temp[2] | (lookup_en<<6);
		temp[2] = temp[2] | (frag_last<<5);

		temp[3] = 0;
		temp[4] = 0;
		temp[5] = 0;
		temp[6] = 0;
		temp[7] = 0;


		u8 flow_type = map_table_list[flow_ID].TSNtag_init.flow_type;
		u16 flow_id = map_table_list[flow_ID].TSNtag_init.flow_id;
		u16 seq_id = map_table_list[flow_ID].TSNtag_init.seq_id;
		u8 frag_flag = 0;
		if(ip_len <= sum_pkt_len)
		{
			//printf("报文头的frag_flag置为1：\n");
			frag_flag = 1;
		}
		else
		{
			//printf("报文头的frag_flag置为0：\n");
			frag_flag = map_table_list[flow_ID].TSNtag_init.frag_flag;
		}		
		u8 frag_id = map_table_list[flow_ID].TSNtag_init.frag_id;
		//printf("frag_id:%d\n",frag_id);
		u8 inject_addr = map_table_list[flow_ID].TSNtag_init.inject_addr;
		u8 submit_addr = map_table_list[flow_ID].TSNtag_init.submit_addr;

		temp = temp + metedata_len;

		temp[0] = 0;
		temp[0] = flow_type<<5;
		temp[0] = temp[0] | (flow_id>>9);

		temp[1] = 0;
		temp[1] = flow_id >> 1;

		temp[2] = 0;
		temp[2] = flow_id << 7;
		temp[2] = temp[2] | (seq_id >> 9);

		temp[3] = 0;
		temp[3] = seq_id >> 1;
		//temp[3] = temp[3] | (seq_id >> 9);

		temp[4] = 0;
		temp[4] = seq_id << 7;
		temp[4] = temp[4] | (frag_flag << 6);
		temp[4] = temp[4] | (frag_id << 2);
		temp[4] = temp[4] | (inject_addr >> 3);
		//printf("temp[4]:%d\n",temp[4]);

		temp[5] = 0;
		temp[5] = inject_addr << 5;
		temp[5] = temp[5] | submit_addr;
	}
	else
	{
		//u8 inport = temp[6]>>4;
		u8 pkttype = map_table_list[flow_ID].metedata_init.pkttype;//3
		u8 md_inject_addr = map_table_list[flow_ID].metedata_init.md_inject_addr;//5
		u16 outport =  map_table_list[flow_ID].metedata_init.outport;//9
		u8 lookup_en = map_table_list[flow_ID].metedata_init.lookup_en;//1
		u8 frag_last = map_table_list[flow_ID].metedata_init.frag_last;//1
		//u64 reserve = map_table_list[flow_ID].metedata_init->reserve;//45

		temp[0] = 0;
		temp[0] = temp[0] | (pkttype<<5);
		temp[0] = temp[0] | (md_inject_addr);

		temp[1] = 0;
		temp[1] = outport>>1;

		temp[2] = 0;
		temp[2] = temp[2] | (outport<<7);
		temp[2] = temp[2] | (lookup_en<<6);
		temp[2] = temp[2] | (frag_last<<5);

		temp[3] = 0;
		temp[4] = 0;
		temp[5] = 0;
		temp[6] = 0;
		temp[7] = 0;


		u8 flow_type = map_table_list[flow_ID].TSNtag_init.flow_type;
		u16 flow_id = map_table_list[flow_ID].TSNtag_init.flow_id;
		u16 seq_id = map_table_list[flow_ID].TSNtag_init.seq_id;

		u8 frag_flag = 0;
		if(ip_len <= sum_pkt_len)
		{
			//printf("报文体的frag_flag置为1：\n");
			frag_flag = 1;
		}
		else
		{
			//printf("报文体的ip_len:")
			//printf("报文体的frag_flag置为0：\n");
			frag_flag = map_table_list[flow_ID].TSNtag_init.frag_flag;
		}

		u8 frag_id = count; //报文体中修改该字段
		u8 inject_addr = map_table_list[flow_ID].TSNtag_init.inject_addr+ count;
		u8 submit_addr = map_table_list[flow_ID].TSNtag_init.submit_addr + count;

		temp = temp + metedata_len;

		temp[0] = 0;
		temp[0] = flow_type<<5;
		temp[0] = temp[0] | (flow_id>>9);

		temp[1] = 0;
		temp[1] = flow_id >> 1;

		temp[2] = 0;
		temp[2] = flow_id << 7;
		temp[2] = temp[2] | (seq_id >> 9);

		temp[3] = 0;
		temp[3] = seq_id >> 1;
		//temp[3] = temp[3] | (seq_id >> 9);

		temp[4] = 0;
		temp[4] = seq_id << 7;
		temp[4] = temp[4] | (frag_flag << 6);
		temp[4] = temp[4] | (frag_id << 2);
		temp[4] = temp[4] | (inject_addr >> 3);

		temp[5] = 0;
		temp[5] = inject_addr << 5;
		temp[5] = temp[5] | submit_addr;
	}
	return 1;
}


int RC_quene_init(struct msg_quene* quene)//消息队列初始化
{
    struct msg_quene_node* head=NULL;
    struct msg_quene_node* tmp_node=NULL;

    if(quene==NULL) 
	 {
	    NPLIB_DBG("msg_quene err\n");
		return ERR;
	 }

	if(quene->service_id >= MAX_SERVICE_NUM) 
	 {
	    NPLIB_DBG("mquene->pthread_id err\n");
		return ERR;
	 }
	struct msg_quene_node* new_node = (struct msg_quene_node*)malloc(sizeof(struct	msg_quene_node));
	if (new_node == NULL)
	{ 
	   NPLIB_DBG("malloc fail\n");
	   return ERR; 
	}
	new_node->msg = NULL;
	new_node->next = new_node;
	
    head=new_node;//先malloc一个新节点作为头 
	int i = 0;
	for(i=0;i<quene->size-1;i++)//创建循环单链表节点
    {
       new_node = (struct msg_quene_node*)malloc(sizeof(struct msg_quene_node));//malloc新节点
	   if (new_node == NULL)
		{ 
		   NPLIB_DBG("malloc fail\n");
		   return ERR; 
		}
	   new_node->msg=NULL;
	   new_node->next=NULL;

	   tmp_node=head;
	   while(tmp_node->next!=head)//遍历到最后节点
	   	{
	   	  tmp_node=tmp_node->next;
	   	}
	   tmp_node->next=new_node;
	   new_node->next=head;//保持最后节点的*next指向head
    }

	quene->front=head;
	quene->rear=head;
}
void RC_handler(struct msg_quene* txq,struct msg_quene* rxq,struct buf_list* head_list,struct msg_node* msg)
{
	//释放时间报文所占的缓冲区
	//printf("RC_hander-start:\n");
	hx_free_buf(head_list,msg);
	//从RC_rxq队列中获取msg
	struct msg_node* RC_msg_node = NULL;
	RC_msg_node = hx_read_msg_quene_node(rxq);
	if(RC_msg_node == NULL)
	{
		//printf("从RC队列取出的msg为空\n");
	}
	else
	{
		if(ERR==hx_write_msg_quene_node(txq,RC_msg_node))
		{
	  		MAP_DBG("hx_write_msg_quene_node fail\n");
	  		hx_free_buf(head_list,RC_msg_node);
		}
		return ;
	}
    
}

void map_handler(struct msg_quene* txq,struct msg_quene* rxq,struct buf_list* head_list,struct msg_node* msg,u16 count,u16 flow_id,u16 ip_len,u16 sum_pkt_len)
{
	//printf("map_handler!!!\n");
	u8 *eth_head_ptr = NULL;
	eth_head_ptr = msg->eth_head_ptr;

	//映射函数
	if(flow_mapping(flow_id,eth_head_ptr,map_table_list,count,ip_len,sum_pkt_len))
	{
		//映射后测试
		//printf("映射后的TSNtag->flow_type:%02x\n",*(eth_head_ptr+metedata_len)>>5);
		//printf("映射后的metedata->flow_type:%02x\n",*(eth_head_ptr+metedata_len)>>5);
		//printf("map success!!!\n\n");
	}
	else
	{
		//printf("map failed!!!");
	}

	u8 RC_flag = *(msg->eth_head_ptr+metedata_len)>>5;
	if(RC_flag == 3)
	{
		//写入RC_context_txq队列
		//printf("写入RC队列：\n");
		msg->src_service_id = MAP_SERVICE_ID;
		#ifdef TSN
		msg->eth_pkt_len +=4;
		msg->eth_head_ptr -=4;
		#endif
		if(ERR==hx_write_msg_quene_node(rxq,msg))
		{
	  		MAP_DBG("hx_write_msg_quene_node fail\n");
	  		//hx_free_buf(head_list,msg);
		}
	}
	else
	{
		//写入map_context_txq队列
		//printf("写入TX队列：\n");
		msg->src_service_id = MAP_SERVICE_ID;
		#ifdef TSN
		msg->eth_pkt_len +=4;
		msg->eth_head_ptr -=4;
		#endif
		if(ERR==hx_write_msg_quene_node(txq,msg))
		{
	  		MAP_DBG("hx_write_msg_quene_node fail\n");
	  		hx_free_buf(head_list,msg);
		}
	}
	
	return ;
}


void hx_start_map()
{
    hx_map_contex_init();

	//printf("hx_start_map:\n");

	//表项初始化
	//map_table_initial();
	get_cfg_info();

	
	//初始化RC队列
	struct msg_quene RC_queue;
	memset(&RC_queue,0,sizeof(RC_queue));
	RC_queue.flag=1;
	RC_queue.service_id = MAP_SERVICE_ID; //0X11
	RC_queue.size = 128;
	if(RC_quene_init(&RC_queue)==ERR) NPLIB_DBG("rxq creat fail\n");

    pthread_detach(pthread_self());

    //printf("hx_map start!\n");

    struct msg_node* tmp_msg_node = NULL;

    hx_register_timer(100,MAP_SERVICE_ID,1);     

	u16 count = 0;
	u16 sum_pkt_len = 0;
	int flow_id = 0;
	u16 ip_len = 0;
    while(1){
        tmp_msg_node = hx_read_msg_quene_node(&map_context.rxq);

        if(tmp_msg_node!=NULL&&tmp_msg_node->msg_type == TSN_TIMER + MAP_SERVICE_ID){
			//printf("收到了时间信息：\n");
            RC_handler(&map_context.txq,&RC_queue,&map_context.buffer_list,tmp_msg_node);
        }
		else if(tmp_msg_node!=NULL&&tmp_msg_node->msg_type == TSN_FORWORD_FLOW){
			//判定是报文头还是报文体
			u8 *eth_head_ptr = 	tmp_msg_node->eth_head_ptr;
			u8 *temp_1 = tmp_msg_node->eth_head_ptr;
			temp_1 = temp_1 -4;
			u16 eth_pkt_len = tmp_msg_node->eth_pkt_len;
	#ifdef TSN
			struct map_test val;
			val.len = htons(eth_pkt_len);
			val.inval_time = htons(0x0c);
			memcpy(temp_1,&val,4);
			//printf("temp_1[0]:%02x\n\n",temp_1[0]);
			//printf("temp_1[1]:%02x\n\n",temp_1[1]);
	#endif
			//生成五元组
			struct five_tuple_info five_tuple;
			memset(&five_tuple,0,sizeof(struct five_tuple_info));
			five_tuple = form_five_tuple(eth_head_ptr);
			printf("取得的报文的五元组格式：\n\n");
			print_five_tuple(five_tuple);
			

			u8 *temp = eth_head_ptr + metedata_len;
			if(temp[0]==0 && temp[1]==0 && temp[2]==0 && temp[3]==0 &&temp[4]==0 && temp[5]==0)//&& inport_before_map == inport_after_map)//报文体
			{
                sum_pkt_len = sum_pkt_len + eth_pkt_len - 14 - 10;		
			}
			else//报文头
			{
				count = 0;
				sum_pkt_len = 0;
				temp[12] = temp[12] | (0x01<<4);//将0800改成1800
				ip_len = (u16)*(eth_head_ptr+metedata_len+16)<<8 | (u16)*(eth_head_ptr+metedata_len+17);
				sum_pkt_len = sum_pkt_len + eth_pkt_len - 22;
				//利用五元组查表
				flow_id = LUT_table(five_tuple,map_table_list);
			}
			//报文映射处理
			printf("映射前的count:%d\n\n",count);
			printf("映射前ididididididiid:%d\n\n",flow_id);
			//查询不到表项
			if(flow_id == -1)
			{
				if(temp[23]==0x1 || count != 0)//增加固定的icmp报文
				{
					printf("icmp\n");
					map_handler(&map_context.txq,&RC_queue,&map_context.buffer_list,tmp_msg_node,count,1,ip_len,sum_pkt_len);
				}
				else
				{
					count = 0;
					sum_pkt_len = 0;
					printf("free success!!!");
					hx_free_buf(&map_context.buffer_list,tmp_msg_node);
					continue;
				}

			}
			else
			{
				map_handler(&map_context.txq,&RC_queue,&map_context.buffer_list,tmp_msg_node,count,flow_id,ip_len,sum_pkt_len);
			}
			//verity iplen
			printf("eth_pkt_len:%d\n",eth_pkt_len);
			printf("ip_len:%d\n",ip_len);
			printf("sum_pkt_len:%d\n",sum_pkt_len);
			
			if(ip_len <= sum_pkt_len)//当收到最后一个报文
			{
				count = 0;
				sum_pkt_len = 0;
				flow_id =-1;
				ip_len = 0;
			}
			else
			{
				count = count+1;
			}
        }
		else//msg为空
		{
			continue;
		}
    }
	hx_unregister_timer(MAP_SERVICE_ID);
    hx_destroy(&map_context);
    return;
}

int hx_map_init()
{
    int ret = -1;
    pthread_t map_id;
    ret = pthread_create(&map_id,NULL,(void*)hx_start_map,NULL);


    if(0!=ret)
    {
        MAP_ERR("create hx_ptp_handler fail! ret=%d err=%s\n",ret,strerror(ret));
    }

    return ret;
}