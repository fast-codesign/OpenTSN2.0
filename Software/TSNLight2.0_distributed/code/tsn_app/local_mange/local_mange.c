/** *************************************************************************
 *  @file          local_mange.c
 *  @brief	  本地管理模块，用于对TSN芯片的寄存器进行配置，并且发送2个be报文和一个1个ts报文
 				两个be报文分别从主机口发送，网络口发出，网络口接收，主机口发送，ts报文从主机口发送，主机口接收
 * 
 *  详细说明
 * 
 *  @date	   2020/06/29 
 *  @author		junshuai.li
 *  @email		1145331404@qq.com
 *  @version	1.0
 ****************************************************************************/

#include "local_mange.h"



struct hx_context  local_mange_context;

//struct nmac_pkt nmac;



//md 转化函数
void md_transf_fun_local(u8 *tmp_md,u16 outport,u8 lookup_en,u8 frag_last)
{
	tmp_md[0] = 0;
	tmp_md[0] = outport>>1;

	tmp_md[1] = 0;
	tmp_md[1] = tmp_md[1] | (outport<<7);

	tmp_md[1] = tmp_md[1] | (lookup_en<<6);
	tmp_md[1] = tmp_md[1] | (frag_last<<5);

	tmp_md[2] = 0;
	tmp_md[3] = 0;
	tmp_md[4] = 0;
	tmp_md[5] = 0;
	tmp_md[6] = 0;
	
}


//目的mac转换tag函数
void dmac_transf_tag_local(u8 *tmp_dmac,u8 flow_type,u16 flowid,u16 seqid,u8 frag_flag,u8 frag_id,u8 inject_addr,u8 submit_addr )
{
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

}

#define BUF_LEN  4096

struct chip_cfg_info chip;

#define NO_FLOW  0
#define NEW_FLOW 1

int flow_flag = 0;


void riprt(char *str)
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

void print_chip_cfg_info()
{
	printf("***********************reg*********************************\n");
	printf("inject_slot_period: %d\n", chip.reg_state.inject_slot_period);
	printf("submit_slot_period: %d\n", chip.reg_state.submit_slot_period);
	printf("slot_length: %d\n",chip.reg_state.slot_length);
	printf("port_type: %d\n", chip.reg_state.port_type);
	printf("report_type: %d\n", chip.reg_state.report_type);
	printf("report_en: %d\n",chip.reg_state.report_en);
	printf("report_period: %d\n", chip.reg_state.report_period);

	printf("************************forward********************************\n");
	struct forward_info *tmp_forward = NULL;
	tmp_forward = chip.forward_node;
	while(tmp_forward != NULL)
	{
		printf("imac_flowid: %d\n", tmp_forward->imac_flowid);
		printf("outport: %d\n", tmp_forward->outport);
		tmp_forward = tmp_forward->next;
	}

	
	printf("************************inject********************************\n");
	struct inject_time *tmp_inject = NULL;
	tmp_inject = chip.inject_node;
	while(tmp_inject != NULL)
	{
		printf("valid: %d\n", tmp_inject->valid);
		printf("cur_time_slot: %d\n", tmp_inject->cur_time_slot);		
		printf("inject_addr: %d\n", tmp_inject->inject_addr);
		tmp_inject = tmp_inject->next;
	}


	printf("************************submit********************************\n");
	struct submit_time *tmp_submit = NULL;
	tmp_submit = chip.submit_node;
	while(tmp_submit != NULL)
	{
		printf("valid: %d\n", tmp_submit->valid);
		printf("cur_time_slot: %d\n", tmp_submit->cur_time_slot);		
		printf("inject_addr: %d\n", tmp_submit->submit_addr);
		tmp_submit = tmp_submit->next;
	}

	/*
	printf("************************gate_in********************************\n");
	
	for(i=0;i<8;i++)
	{
		for(j=0;j<chip.reg_state.gate_depth;j++)
		{
			printf("%d\n",chip.gate_in[i][j]);
		}
	}
	*/
	int i=0,j=0;

	printf("************************gate_out********************************\n");
	for(i=0;i<8;i++)
	{
		for(j=0;j<chip.reg_state.gate_depth;j++)
		{
			printf("%d\n",chip.gate_out[i][j]);
		}
	}
	

	

}







//从文本中获取配置信息
void get_cfg_info_local()
{
	FILE *fp = NULL;
	int i = 0;
	char buf[BUF_LEN];
	char *save_pstr = NULL;
	char *fir_pstr = NULL;
	char *sec_pstr = NULL;

	struct forward_info *forward_tail = NULL;
	struct inject_time  *inject_tail  = NULL;
	struct submit_time	*submit_tail  = NULL;

	struct forward_info *tmp_forward = NULL;
	struct inject_time  *tmp_inject = NULL;
	struct submit_time *tmp_submit = NULL;

	u8 cur_slot[10];
	u8 cur_addr[5];

	u8 high=0,low=0;


	u16 tmp_depth=0;
	u16 gate_in_idx = 0;


	fp = fopen("./reg_info", "r");
	if(fp == NULL)
	{
		printf("Could not read reg_info file!\n");
		return ;
	}
	printf("Open reg_info reserve file successfully!\n");
	while(fgets(buf, BUF_LEN, fp) != NULL)
	{
		//printf("line content: %s", buf);
		riprt(buf);
		if(flow_flag == NO_FLOW)
		{
			if(!strcmp(buf, "{"))
			{
				//printf("Find a new flow!\n");
				flow_flag = NEW_FLOW;
			}
			else
				continue;
		}

		else if(flow_flag == NEW_FLOW)
		{
			fir_pstr = strtok_r(buf, ":", &sec_pstr);
			if(!strcmp(fir_pstr + 1, "type"))
			{
				if(!strcmp(sec_pstr, "register"))
				{
					flow_flag = TYPE_REG;
					//printf("Find TS flow!\n");
				}
				else if(!strcmp(sec_pstr, "forward_info"))
					flow_flag = TYPE_FORWARD;
				else if(!strcmp(sec_pstr, "inject_time_table"))
					flow_flag = TYPE_INJECT;
				else if(!strcmp(sec_pstr, "submit_time_table"))
					flow_flag = TYPE_SUBMIT;
				/*
				else if(!strcmp(sec_pstr, "gate_in"))
					flow_flag = TYPE_GATE_IN;
				*/
				else if(!strcmp(sec_pstr, "gate_out"))
					flow_flag = TYPE_GATE_OUT;
				else
					flow_flag = NO_FLOW;
			}
			else
				flow_flag = NO_FLOW;
			//printf("111111111flow_flag: %d\n",flow_flag);
		}

		else if(flow_flag == TYPE_REG)
		{
			if(!strcmp(buf, "}"))
			{
				flow_flag = NO_FLOW;
#if 0
				printf("slot_num: %d\n", chip.reg_state.slot_num);
				printf("gate_period: %d\n", chip.reg_state.gate_period);
				printf("slot_length: %d\n",chip.reg_state.slot_length);
				printf("port_type: %d\n", chip.reg_state.port_type);
				/*
				printf("latency: %d\n", globle_ts_flow.tsn[cur_ts_num].latency);
				printf("interval: %d\n", globle_ts_flow.tsn[cur_ts_num].interval);
				printf("src_mac: %x:%x:%x:%x:%x:%x\n", globle_ts_flow.tsn[cur_ts_num].src_mac[0],globle_ts_flow.tsn[cur_ts_num].src_mac[1],globle_ts_flow.tsn[cur_ts_num].src_mac[2],
														globle_ts_flow.tsn[cur_ts_num].src_mac[3],globle_ts_flow.tsn[cur_ts_num].src_mac[4],globle_ts_flow.tsn[cur_ts_num].src_mac[5]);
				printf("dst_mac: %x:%x:%x:%x:%x:%x\n", globle_ts_flow.tsn[cur_ts_num].dst_mac[0],globle_ts_flow.tsn[cur_ts_num].dst_mac[1],globle_ts_flow.tsn[cur_ts_num].dst_mac[2],
														globle_ts_flow.tsn[cur_ts_num].dst_mac[3],globle_ts_flow.tsn[cur_ts_num].dst_mac[4],globle_ts_flow.tsn[cur_ts_num].dst_mac[5]);
				*/
#endif


			}
			else
			{
				fir_pstr = strtok_r(buf, ":", &sec_pstr);
				if(!strcmp(fir_pstr + 1, "inject_slot_period"))
					chip.reg_state.inject_slot_period = atoi(sec_pstr);
				else if(!strcmp(fir_pstr + 1, "submit_slot_period"))
				{
					chip.reg_state.submit_slot_period = atoi(sec_pstr);
					//printf("22222222222gate_period: %d\n", chip.reg_state.gate_period);
				}
				else if(!strcmp(fir_pstr + 1, "slot_length"))
				{
					chip.reg_state.slot_length = atoi(sec_pstr);
				}
				else if(!strcmp(fir_pstr + 1, "port_type"))
					chip.reg_state.port_type = atoi(sec_pstr);				
				else if(!strcmp(fir_pstr + 1, "qbv_or_qch"))
					chip.reg_state.qbv_qch = atoi(sec_pstr);

				else if(!strcmp(fir_pstr + 1, "report_type"))
					chip.reg_state.report_type = atoi(sec_pstr);
				else if(!strcmp(fir_pstr + 1, "report_en"))
					chip.reg_state.report_en = atoi(sec_pstr);
				else if(!strcmp(fir_pstr + 1, "report_period"))
					chip.reg_state.report_period = atoi(sec_pstr);
				else if(!strcmp(fir_pstr + 1, "rc_regulation_value"))
					chip.reg_state.rc_regulation_value = atoi(sec_pstr);
				else if(!strcmp(fir_pstr + 1, "be_regulation_value"))
					chip.reg_state.be_regulation_value = atoi(sec_pstr);
				else if(!strcmp(fir_pstr + 1, "unmap_regulation_value"))
					chip.reg_state.unmap_regulation_value = atoi(sec_pstr);
				else
					continue;
			}

		}

		else if(flow_flag == TYPE_FORWARD)
		{
			if(!strcmp(buf, "}"))
			{
				flow_flag = NO_FLOW;
				

			}
			else
			{				
				tmp_forward = (struct forward_info *)malloc(sizeof(struct forward_info));
				fir_pstr = strtok_r(buf, " ", &sec_pstr);
				
				tmp_forward->imac_flowid = atoi(fir_pstr);
				tmp_forward->outport     = atoi(sec_pstr);
				tmp_forward->next        = NULL;
				if(chip.forward_node == NULL)
				{
					chip.forward_node = tmp_forward;
					forward_tail = tmp_forward;
				}
				else
				{
					forward_tail->next = tmp_forward;
					forward_tail = tmp_forward;
				}
			}
		}
		else if(flow_flag == TYPE_INJECT)
		{
			if(!strcmp(buf, "}"))
			{
				flow_flag = NO_FLOW;		

			}
			else
			{

				tmp_inject = (struct inject_time *)malloc(sizeof(struct inject_time));

				fir_pstr = strtok_r(buf, " ", &sec_pstr);
				
				tmp_inject->valid         = atoi(fir_pstr);
				fir_pstr = strtok_r(sec_pstr, " ", &sec_pstr);
				tmp_inject->cur_time_slot = atoi(fir_pstr);
				tmp_inject->inject_addr = atoi(sec_pstr);

				if(chip.inject_node == NULL)
				{
					chip.inject_node = tmp_inject;
					inject_tail = tmp_inject;
				}
				else
				{
					inject_tail->next = tmp_inject;
					inject_tail = tmp_inject;
				}
			}
		}	
		else if(flow_flag == TYPE_SUBMIT)
		{
			if(!strcmp(buf, "}"))
			{
				flow_flag = NO_FLOW;		

			}
			else
			{
												
				tmp_submit = (struct submit_time *)malloc(sizeof(struct submit_time));


				fir_pstr = strtok_r(buf, " ", &sec_pstr);
				
				tmp_submit->valid         = atoi(fir_pstr);
				fir_pstr = strtok_r(sec_pstr, " ", &sec_pstr);
				tmp_submit->cur_time_slot = atoi(fir_pstr);
				tmp_submit->submit_addr = atoi(sec_pstr);
				
				if(chip.submit_node == NULL)
				{
					chip.submit_node = tmp_submit;
					submit_tail = tmp_submit;
				}
				else
				{
					submit_tail->next = tmp_submit;
					submit_tail = tmp_submit;
				}
			}
		}	
		else if(flow_flag == TYPE_GATE_OUT)
		{
			if(!strcmp(buf, "}"))
			{
				flow_flag = NO_FLOW;		

			}
			else
			{

				fir_pstr = strtok_r(buf, ":", &sec_pstr);
				if(!strcmp(fir_pstr + 1, "depth"))
				{
					tmp_depth = atoi(sec_pstr);

					chip.reg_state.gate_depth = tmp_depth;

				}
				else if(!strcmp(fir_pstr + 1, "gate_out_0"))
				{
					for(gate_in_idx=0;gate_in_idx<tmp_depth;gate_in_idx++)
					{
						if(gate_in_idx == (tmp_depth - 1))
						{
							high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
							low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					        chip.gate_out[0][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
							
						}
						else 
						{
							
							fir_pstr = strtok_r(sec_pstr, " ", &sec_pstr);
							
							high = ((*fir_pstr > '9') && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *fir_pstr - 48 - 7 : *fir_pstr - 48;
							low = (*(++ fir_pstr) > '9' && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *(fir_pstr) - 48 - 7 : *(fir_pstr) - 48;
							chip.gate_out[0][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
						}

					}


				}
				else if(!strcmp(fir_pstr + 1, "gate_out_1"))
				{
					for(gate_in_idx=0;gate_in_idx<tmp_depth;gate_in_idx++)
					{
						
						if(gate_in_idx == (tmp_depth - 1))
						{
							high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
							low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					        chip.gate_out[1][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
							
						}
						else 
						{
							
							fir_pstr = strtok_r(sec_pstr, " ", &sec_pstr);
							
							high = ((*fir_pstr > '9') && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *fir_pstr - 48 - 7 : *fir_pstr - 48;
							low = (*(++ fir_pstr) > '9' && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *(fir_pstr) - 48 - 7 : *(fir_pstr) - 48;
							chip.gate_out[1][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
						}

					}


				}
				else if(!strcmp(fir_pstr + 1, "gate_out_2"))
				{
					for(gate_in_idx=0;gate_in_idx<tmp_depth;gate_in_idx++)
					{
						
						if(gate_in_idx == (tmp_depth - 1))
						{
							high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
							low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					        chip.gate_out[2][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
							
						}
						else 
						{
							
							fir_pstr = strtok_r(sec_pstr, " ", &sec_pstr);
							
							high = ((*fir_pstr > '9') && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *fir_pstr - 48 - 7 : *fir_pstr - 48;
							low = (*(++ fir_pstr) > '9' && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *(fir_pstr) - 48 - 7 : *(fir_pstr) - 48;
							chip.gate_out[2][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
						}

					}

				}
				else if(!strcmp(fir_pstr + 1, "gate_out_3"))
				{
					for(gate_in_idx=0;gate_in_idx<tmp_depth;gate_in_idx++)
					{
						
						if(gate_in_idx == (tmp_depth - 1))
						{
							high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
							low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					        chip.gate_out[3][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
							
						}
						else 
						{
							
							fir_pstr = strtok_r(sec_pstr, " ", &sec_pstr);
							
							high = ((*fir_pstr > '9') && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *fir_pstr - 48 - 7 : *fir_pstr - 48;
							low = (*(++ fir_pstr) > '9' && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *(fir_pstr) - 48 - 7 : *(fir_pstr) - 48;
							chip.gate_out[3][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
						}

					}

				}
				else if(!strcmp(fir_pstr + 1, "gate_out_4"))
				{
					for(gate_in_idx=0;gate_in_idx<tmp_depth;gate_in_idx++)
					{
						
						if(gate_in_idx == (tmp_depth - 1))
						{
							high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
							low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					        chip.gate_out[4][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
							
						}
						else 
						{
							
							fir_pstr = strtok_r(sec_pstr, " ", &sec_pstr);
							
							high = ((*fir_pstr > '9') && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *fir_pstr - 48 - 7 : *fir_pstr - 48;
							low = (*(++ fir_pstr) > '9' && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *(fir_pstr) - 48 - 7 : *(fir_pstr) - 48;
							chip.gate_out[4][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
						}

					}


				}
				else if(!strcmp(fir_pstr + 1, "gate_out_5"))
				{
					for(gate_in_idx=0;gate_in_idx<tmp_depth;gate_in_idx++)
					{
						
						if(gate_in_idx == (tmp_depth - 1))
						{
							high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
							low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					        chip.gate_out[5][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
							
						}
						else 
						{
							
							fir_pstr = strtok_r(sec_pstr, " ", &sec_pstr);
							
							high = ((*fir_pstr > '9') && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *fir_pstr - 48 - 7 : *fir_pstr - 48;
							low = (*(++ fir_pstr) > '9' && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *(fir_pstr) - 48 - 7 : *(fir_pstr) - 48;
							chip.gate_out[5][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
						}

					}

				}
				else if(!strcmp(fir_pstr + 1, "gate_out_6"))
				{
					for(gate_in_idx=0;gate_in_idx<tmp_depth;gate_in_idx++)
					{
						
						if(gate_in_idx == (tmp_depth - 1))
						{
							high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
							low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					        chip.gate_out[6][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
							
						}
						else 
						{
							
							fir_pstr = strtok_r(sec_pstr, " ", &sec_pstr);
							
							high = ((*fir_pstr > '9') && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *fir_pstr - 48 - 7 : *fir_pstr - 48;
							low = (*(++ fir_pstr) > '9' && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *(fir_pstr) - 48 - 7 : *(fir_pstr) - 48;
							chip.gate_out[6][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
						}

					}


				}
				else if(!strcmp(fir_pstr + 1, "gate_out_7"))
				{
					for(gate_in_idx=0;gate_in_idx<tmp_depth;gate_in_idx++)
					{
						
						if(gate_in_idx == (tmp_depth - 1))
						{
							high = ((*sec_pstr > '9') && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *sec_pstr - 48 - 7 : *sec_pstr - 48;
							low = (*(++ sec_pstr) > '9' && ((*sec_pstr <= 'F') || (*sec_pstr <= 'f'))) ? *(sec_pstr) - 48 - 7 : *(sec_pstr) - 48;
					        chip.gate_out[7][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
							
						}
						else 
						{
							
							fir_pstr = strtok_r(sec_pstr, " ", &sec_pstr);
							
							high = ((*fir_pstr > '9') && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *fir_pstr - 48 - 7 : *fir_pstr - 48;
							low = (*(++ fir_pstr) > '9' && ((*fir_pstr <= 'F') || (*fir_pstr <= 'f'))) ? *(fir_pstr) - 48 - 7 : *(fir_pstr) - 48;
							chip.gate_out[7][gate_in_idx] = ((high & 0x0f) << 4 | (low & 0x0f));
						}

					}


				}

			}
		}

		
		else
		{
			continue;
		}	
	}
}



int hx_local_mange_contex_init()
{
	struct hx_context_arg  hx_local_mange_arg;
	memset(&hx_local_mange_arg,0,sizeof(struct hx_context_arg));
	
	hx_local_mange_arg.service_id = TSN_NMAC_SERVICE_ID;//0x01
	hx_local_mange_arg.rxq_size = 0;
	hx_local_mange_arg.txq_size = 2048;
	
	hx_init(&local_mange_context,&hx_local_mange_arg); 

	return 0;
}

int hx_local_mange_contex_destroy()
{
	hx_destroy(&local_mange_context); 
	return 0;
}

int build_nmac_info(u8 *tmp_buf)
{
	struct nmac_pkt *nmac = (struct nmac_pkt *)tmp_buf;
	nmac->pkttype   = 5;//nmac//101
	nmac->inject_addr   = 0;//10001

	md_transf_fun_local(nmac->md,0,0,0);


	dmac_transf_tag_local(nmac->dst_mac,5,0,0,0,0,0,0);//报文类型011       flowID=0000  


	nmac->src_mac[0] = 0;
	nmac->src_mac[1] = 1;
	nmac->src_mac[2] = 1;
	nmac->src_mac[3] = 3;
	nmac->src_mac[4] = 4;
	nmac->src_mac[5] = 6;

	nmac->ether_type = ntohs(0x1662);

	nmac->type  = 3;


#ifdef TSN
	nmac->pkt_len = ntohs(128-4);
	nmac->interal_time = ntohs(0xc);
#endif

	return 0;

}



int build_forward_info_ge()
{

	//1st
	//第一步申请buf
	u8* buf_addr;
	struct msg_node* tmp_msg_node = NULL;


	u8 send_num = 0;

	u32 tmp_addr = 0;
	
	u16 tmp_flowid = 0;
	
	struct nmac_pkt *nmac = NULL;
	struct forward_info *tmp_forward = chip.forward_node;
	
	while(tmp_forward != NULL)
	{
		send_num = 0;
		tmp_flowid = 0;
		//取一个缓存区eth地址
		buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址

		nmac = (struct nmac_pkt *)buf_addr;
		build_nmac_info((u8 *)nmac);
		//第二步构造消息填充到发送队列
		tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
		tmp_msg_node->msg_type =  TSN_NMAC;//	
		tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
		tmp_msg_node->eth_pkt_len= 128;
		tmp_msg_node->eth_head_ptr=buf_addr;
		tmp_msg_node->um_type  = 0;//无md
		tmp_msg_node->reserve  = 8;

		
		while(tmp_forward != NULL)
		{
			
			send_num = send_num + 1;

			//printf("tmp_forward->imac_flowid = %d,tmp_flowid = %d\n",tmp_forward->imac_flowid,tmp_flowid);

			//tmp_flowid = tmp_forward->imac_flowid;
			if(send_num == 1)
			{
				tmp_addr = 0xc00000 + tmp_forward->imac_flowid;
				nmac->addr = ntohl(tmp_addr);
				nmac->data[(send_num - 1)%24] = ntohl(tmp_forward->outport);	
				if(tmp_forward->next == NULL)
				{
					nmac->count = 1;
					if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
					{
					  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
					  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
					}
					tmp_forward = tmp_forward->next;
					break;
				}
				tmp_flowid = tmp_forward->imac_flowid;			
			}

			else if(tmp_forward->imac_flowid == tmp_flowid+1)//连续写入
			{
				//printf("send_num %d\n",send_num);
				//send_num = send_num + 1;
				nmac->data[(send_num - 1)%24] = ntohl(tmp_forward->outport);
				if(send_num%24 == 0)//如果写满一个报文
				{
					//printf("full\n");
					//nmac->addr = ntohl(0xc00000 + tmp_forward->imac_flowid);
					nmac->count = 24;
					if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
					{
					  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
					  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
					}
					send_num = 0;
					if(tmp_forward->next != NULL)
					{
						
						//取一个缓存区eth地址
						buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址	
						nmac = (struct nmac_pkt *)buf_addr;
						build_nmac_info((u8 *)nmac);
						//第二步构造消息填充到发送队列
						tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
						tmp_msg_node->msg_type =  TSN_NMAC;//	
						tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
						tmp_msg_node->eth_pkt_len= 128;
						tmp_msg_node->eth_head_ptr=buf_addr;
						tmp_msg_node->um_type  = 0;//无md
						tmp_msg_node->reserve  = 8;
					}
				}
	
				if(tmp_forward->next == NULL && send_num%24 != 0)
				{

					nmac->count = (send_num)%24;
					if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
					{
					  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
					  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
					}


				}
				

			}
			else//不连续写入
			{
				nmac->count = (send_num-1)%24;
				if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
				{
				  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
				  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
				}
				break;
			}
			tmp_flowid = tmp_forward->imac_flowid;
			tmp_forward = tmp_forward->next;
		}
	}

}


int build_inject_info_ge()
{

	//1st
	//第一步申请buf
	u8* buf_addr;
	struct msg_node* tmp_msg_node = NULL;

	u32 tmp_test = 0;
	u32 tmp_test1 = 0;

	u8  send_num = 0;
	u32 tmp_addr = 0x100000;
	
	struct nmac_pkt *nmac = NULL;
	struct inject_time *tmp_inject = chip.inject_node;

	//取一个缓存区eth地址
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址	
	nmac = (struct nmac_pkt *)buf_addr;
	build_nmac_info((u8 *)nmac);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;

	
	while(tmp_inject != NULL)
	{
		tmp_test = 0;
		tmp_test1 = 0;


		send_num = send_num + 1;
		
		
		tmp_test = (tmp_test | (tmp_inject->valid))<<15;		
		tmp_test1 = (tmp_test1 | (tmp_inject->cur_time_slot))<<5;		
		tmp_test = 	tmp_test + tmp_test1 + tmp_inject->inject_addr;
		nmac->data[(send_num - 1)%24] = ntohl(tmp_test);

		//printf("nmac->data(send_num - 1)    %x\n",tmp_test);
		if(send_num%24 == 0)
		{
			send_num = 0;
			nmac->addr = ntohl(tmp_addr);
			tmp_addr = tmp_addr + 24;
			nmac->count = 24;
			if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
			{
			  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
			  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
			}
			
			if(tmp_inject->next != NULL)
			{
				//取一个缓存区eth地址
				buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址	
				nmac = (struct nmac_pkt *)buf_addr;
				build_nmac_info((u8 *)nmac);
				//第二步构造消息填充到发送队列
				tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
				tmp_msg_node->msg_type =  TSN_NMAC;//	
				tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
				tmp_msg_node->eth_pkt_len= 128;
				tmp_msg_node->eth_head_ptr=buf_addr;
				tmp_msg_node->um_type  = 0;//无md
				tmp_msg_node->reserve  = 8;
			}
			else
				break;
		}
		if(tmp_inject->next == NULL)
		{
			nmac->addr = ntohl(tmp_addr);
			nmac->count = send_num%24;
			if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
			{
			  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
			  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
			}
		}
		tmp_inject = tmp_inject->next;
		
	}

	
}


int build_submit_info_ge()
{

	//1st
	//第一步申请buf
	u8* buf_addr;
	struct msg_node* tmp_msg_node = NULL;

	u32 tmp_test = 0;
	u32 tmp_test1 = 0;

	u8  send_num = 0;
	u32 tmp_addr = 0x200000;
	
	struct nmac_pkt *nmac = NULL;
	struct submit_time *tmp_submit = chip.submit_node;

	//取一个缓存区eth地址
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址	
	nmac = (struct nmac_pkt *)buf_addr;
	build_nmac_info((u8 *)nmac);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;

	
	while(tmp_submit != NULL)
	{
		tmp_test = 0;
		tmp_test1 = 0;

		send_num = send_num + 1;
				
		tmp_test = (tmp_test | (tmp_submit->valid))<<15;		
		tmp_test1 = (tmp_test1 | (tmp_submit->cur_time_slot))<<5;		
		tmp_test = 	tmp_test + tmp_test1 + tmp_submit->submit_addr;
		nmac->data[(send_num - 1)%24] = ntohl(tmp_test);

		//printf("nmac->data(send_num - 1)    %x\n",tmp_test);
		if(send_num%24 == 0)
		{
			send_num = 0;
			nmac->addr = ntohl(tmp_addr);
			tmp_addr = tmp_addr + 24;
			nmac->count = 24;
			if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
			{
			  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
			  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
			}
			
			if(tmp_submit->next != NULL)
			{
				//取一个缓存区eth地址
				buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址	
				nmac = (struct nmac_pkt *)buf_addr;
				build_nmac_info((u8 *)nmac);
				//第二步构造消息填充到发送队列
				tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
				tmp_msg_node->msg_type =  TSN_NMAC;//	
				tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
				tmp_msg_node->eth_pkt_len= 128;
				tmp_msg_node->eth_head_ptr=buf_addr;
				tmp_msg_node->um_type  = 0;//无md
				tmp_msg_node->reserve  = 8;
			}
			else
				break;
		}
		if(tmp_submit->next == NULL)
		{
			nmac->addr = ntohl(tmp_addr);
			nmac->count = send_num%24;
			#ifdef TSN
			nmac->pkt_len = ntohs(128-4);
			#endif
			if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
			{
			  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
			  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
			}
		}
		tmp_submit = tmp_submit->next;
		
	}

	
}




//门控表
int build_gate_info_ge()
{
	//1st
	//第一步申请buf
	u8* buf_addr;
	struct msg_node* tmp_msg_node = NULL;

	u8 send_num = 0;
	u8 tmp_flowid = 0;

	u16 period_idx = 0;
	
	struct nmac_pkt *nmac = NULL;

	u8 port_idx = 0;
	u32 tmp_addr = 0;

	//输出门控
	for(port_idx=0;port_idx<8;port_idx++)
	{
		tmp_addr = 0x300000 + 0x100000*port_idx;//删除+1024，目前只有输出门控，硬件地址改动

			//取一个缓存区eth地址
		buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址

		nmac = (struct nmac_pkt *)buf_addr;
		build_nmac_info((u8 *)nmac);
		//第二步构造消息填充到发送队列
		tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
		tmp_msg_node->msg_type =  TSN_NMAC;//	
		tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
		tmp_msg_node->eth_pkt_len= 128;
		tmp_msg_node->eth_head_ptr=buf_addr;
		tmp_msg_node->um_type  = 0;//无
		tmp_msg_node->reserve  = 8;

	
		for(period_idx=0;period_idx<chip.reg_state.gate_depth;period_idx++)
		{
			
			nmac->data[period_idx%24] = ntohl(chip.gate_out[port_idx][period_idx]);
			
			if((period_idx+1)%24 == 0)//说明是26的正数倍
			{
				nmac->addr = ntohl(tmp_addr);
				tmp_addr = tmp_addr + 24;
				nmac->count = 24;
				if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
				{
					LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
					hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
				}
				//取一个缓存区eth地址
				buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址

				nmac = (struct nmac_pkt *)buf_addr;
				build_nmac_info((u8 *)nmac);
				//第二步构造消息填充到发送队列
				tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
				tmp_msg_node->msg_type =  TSN_NMAC;//	
				tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
				tmp_msg_node->eth_pkt_len= 128;
				tmp_msg_node->eth_head_ptr=buf_addr;
				tmp_msg_node->um_type  = 0;//无
				tmp_msg_node->reserve  = 8;
			}
		}
		if((period_idx+1)%24 != 0)
		{
			//tmp_addr = tmp_addr + 26;
			nmac->addr = ntohl(tmp_addr);
			nmac->count = (period_idx)%24;
			if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
			{
				LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
				hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
			}
		}

	}

}




//建造寄存器信息
int build_register_info(u8 *tmp_buf,u8 type,u8 rd_wr,u32 data)
{
	struct nmac_pkt *nmac = (struct nmac_pkt *)tmp_buf;

	nmac->pkttype   = 5;//nmac//101
	nmac->inject_addr   = 0;//

	md_transf_fun_local(nmac->md,0,0,0);


	dmac_transf_tag_local(nmac->dst_mac,5,0,0,0,0,0,0);//报文类型101       flowID=0000  


	nmac->src_mac[0] = 0;
	nmac->src_mac[1] = 1;
	nmac->src_mac[2] = 1;
	nmac->src_mac[3] = 3;
	nmac->src_mac[4] = 4;
	nmac->src_mac[5] = 6;


	nmac->ether_type = ntohs(0x1662);
	nmac->count = 1;
	if(rd_wr == opt_write)
		nmac->type  = 3;
	else if(rd_wr == opt_read)
		nmac->type  = 1;
	nmac->data[0] = ntohl(data);//

#ifdef TSN
	nmac->interal_time = ntohs(0xc);
	nmac->pkt_len = ntohs(128-4);
#endif
	if(type == slot_length)
		nmac->addr = ntohl(2);
	else if(type == cfg_finish)
		nmac->addr = ntohl(3);
	else if(type == port_type)
		nmac->addr = ntohl(4);
	else if(type == qbv_qch)
		nmac->addr = ntohl(5);
	else if(type == report_type)
		nmac->addr = ntohl(6);
	else if(type == report_en)
		nmac->addr = ntohl(7);
	else if(type == slot_num_inject)
		nmac->addr = ntohl(8);
	else if(type == slot_num_submit)
		nmac->addr = ntohl(9);
	else if(type == report_period)
		nmac->addr = ntohl(10);
	else if(type == rc_regulation_value)
			nmac->addr = ntohl(12);
	else if(type == be_regulation_value)
			nmac->addr = ntohl(13);
	else if(type == unmap_regulation_value)
			nmac->addr = ntohl(14);

	/*
	else if(type == gate_period_0)
		nmac->addr = ntohl(0x300800);
	else if(type == gate_period_1)
		nmac->addr = ntohl(0x400800);	
	else if(type == gate_period_2)
		nmac->addr = ntohl(0x500800);
	else if(type == gate_period_3)
		nmac->addr = ntohl(0x600800);
	else if(type == gate_period_4)
		nmac->addr = ntohl(0x700800);
	else if(type == gate_period_5)
		nmac->addr = ntohl(0x800800);
	else if(type == gate_period_6)
		nmac->addr = ntohl(0x900800);
	else if(type == gate_period_7)
		nmac->addr = ntohl(0xa00800);
	*/
}


//建造寄存器信息
int build_register_info_ge()
{
	//1st
	//第一步申请buf
	u8* buf_addr;
	struct msg_node* tmp_msg_node = NULL;
	
	struct nmac_pkt *nmac = NULL;

	//port_type
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址
	nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,port_type,opt_write,chip.reg_state.port_type);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;
	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}

	//qbv_qch
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址
	nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,qbv_qch,opt_write,chip.reg_state.qbv_qch);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;
	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}


	//slot_length
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址
	nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,slot_length,opt_write,chip.reg_state.slot_length);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;
	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}

	//slot_num_inject
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址
	nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,slot_num_inject,opt_write,chip.reg_state.inject_slot_period);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;
	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}

	//slot_num_submit
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址
	nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,slot_num_submit,opt_write,chip.reg_state.submit_slot_period);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;
	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}

	//report_type
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址
	nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,report_type,opt_write,chip.reg_state.report_type);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;
	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}

	//report_en
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址
	nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,report_en,opt_write,chip.reg_state.report_en);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;
	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}

	//report_period
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址
	nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,report_period,opt_write,chip.reg_state.report_period);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;
	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}

	//rc_regulation_value
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址
	nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,rc_regulation_value,opt_write,chip.reg_state.rc_regulation_value);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;
	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}

	//be_regulation_value
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址
	nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,be_regulation_value,opt_write,chip.reg_state.be_regulation_value);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;
	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}

	//unmap_regulation_value
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址
	nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,unmap_regulation_value,opt_write,chip.reg_state.unmap_regulation_value);
	//第二步构造消息填充到发送队列
	tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len= 128;
	tmp_msg_node->eth_head_ptr=buf_addr;
	tmp_msg_node->um_type  = 0;//无md
	tmp_msg_node->reserve  = 8;
	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}


}


struct eth_pkt_info build_cfg_finish_pkt(u8 tmp_finish)
{
	struct eth_pkt_info cfg_finish_pkt;

	u8* buf_addr;
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址

	

//构造NMAC报文
	struct nmac_pkt *nmac = (struct nmac_pkt *)buf_addr;
	build_register_info((u8 *)nmac,cfg_finish,opt_write,tmp_finish);


	cfg_finish_pkt.len = 128;
	cfg_finish_pkt.buf = (u8 *)nmac;

	
	return cfg_finish_pkt;

}

int send_cfg_finish_pkt(u8 tmp_finish)
{
	struct msg_node* tmp_msg_node = NULL;
	struct eth_pkt_info cfg_finish_pkt;
	cfg_finish_pkt = build_cfg_finish_pkt(tmp_finish);

	tmp_msg_node = (struct msg_node*)((u8*)cfg_finish_pkt.buf - PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);

	tmp_msg_node->msg_type       =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len    = 128;
	tmp_msg_node->eth_head_ptr   = (u8*)cfg_finish_pkt.buf;
	tmp_msg_node->um_type        = 0;//无md
	tmp_msg_node->reserve        = 8;


	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}

	
	return 0;


}




//构建配置offset报文信息
struct eth_pkt_info build_offset_pkt(u32 l_offset,u32 h_offset)
{
	struct eth_pkt_info offset_pkt;

	u8* buf_addr;
	

	
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址


//构造NMAC报文
	struct nmac_pkt *nmac = (struct nmac_pkt *)buf_addr;

	nmac->pkttype   = 5;//nmac//011
	nmac->inject_addr   = 0;//10001

	md_transf_fun_local(nmac->md,0,0,0);


	dmac_transf_tag_local(nmac->dst_mac,5,0,0,0,0,0,0);//报文类型011       flowID=0000  


	nmac->src_mac[0] = 0;
	nmac->src_mac[1] = 1;
	nmac->src_mac[2] = 1;
	nmac->src_mac[3] = 3;
	nmac->src_mac[4] = 4;
	nmac->src_mac[5] = 6;


	nmac->ether_type = ntohs(0x1662);
	nmac->count = 2;
	nmac->type  = 3;
	#ifdef TSN
	nmac->pkt_len = ntohs(128-4);
	#endif
	nmac->addr = ntohl(0);

	nmac->data[0] = l_offset;//已经经过大小端转换
	nmac->data[1] = h_offset;//已经经过大小端转换


	offset_pkt.len = 128;
	offset_pkt.buf = (u8 *)nmac;

	
	return offset_pkt;

}

//发送offset报文信息
int send_offset_pkt()
{

	
	struct msg_node* tmp_msg_node = NULL;
	struct eth_pkt_info offset_pkt;
	offset_pkt = build_offset_pkt(1,2);

	tmp_msg_node = (struct msg_node*)((u8*)offset_pkt.buf - PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);

	tmp_msg_node->msg_type       =  TSN_NMAC;//	
	tmp_msg_node->src_service_id = TSN_NMAC_SERVICE_ID;
	tmp_msg_node->eth_pkt_len    = 128;
	tmp_msg_node->eth_head_ptr   = (u8*)offset_pkt.buf;
	tmp_msg_node->um_type        = 0;//无md
	tmp_msg_node->reserve        = 8;



	if(ERR==hx_write_msg_quene_node(&local_mange_context.txq,tmp_msg_node))
	{
	  LOCAL_MANGE_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&local_mange_context.buffer_list,tmp_msg_node);
	}

	
	return 0;

}


//构建配置offset报文信息
struct eth_pkt_info build_offset_period(u32 offset_period)
{
	struct eth_pkt_info offset_period_pkt;

	u8* buf_addr;
	

	
	buf_addr=hx_malloc_eth_pkt_buf(&local_mange_context.buffer_list);//取一个缓存区eth地址


//构造NMAC报文
	struct nmac_pkt *nmac = (struct nmac_pkt *)buf_addr;

	nmac->pkttype   = 5;//nmac//011
	nmac->inject_addr   = 0;//10001

	md_transf_fun_local(nmac->md,0,0,0);


	dmac_transf_tag_local(nmac->dst_mac,5,0,0,0,0,0,0);//报文类型011       flowID=0000  


	nmac->src_mac[0] = 0;
	nmac->src_mac[1] = 1;
	nmac->src_mac[2] = 1;
	nmac->src_mac[3] = 3;
	nmac->src_mac[4] = 4;
	nmac->src_mac[5] = 6;


	nmac->ether_type = ntohs(0x1662);
	nmac->count = 1;
	nmac->type  = 3;
	#ifdef TSN
	nmac->pkt_len = ntohs(128-4);
	#endif
	nmac->addr = ntohl(11);

	nmac->data[0] = offset_period;//已经经过大小端转换


	offset_period_pkt.len = 128;
	offset_period_pkt.buf = (u8 *)nmac;

	
	return offset_period_pkt;

}


/*本地管理处理线程*/
void hx_local_mange(void *argv)
{
	get_cfg_info_local();
	//print_chip_cfg_info();


	#if 1
	hx_local_mange_contex_init();
//无效报文
	//build_forward_info_ge();
	//build_forward_info_ge();


	build_forward_info_ge();
	build_gate_info_ge();

	build_register_info_ge();
	

	build_inject_info_ge();
	build_submit_info_ge();

	send_cfg_finish_pkt(3);


	while(1)
	{
		pause();
	}

	hx_local_mange_contex_destroy();

	LOCAL_MANGE_DBG("hx_start_timer end!\n");

	#endif
}


int hx_local_mange_handler()
{
	int ret = -1;
	pthread_t local_mange_id;

	
	ret=pthread_create(&local_mange_id,NULL,(void *)hx_local_mange,NULL); 
	
	if(0 != ret)
	{
		LOCAL_MANGE_ERR("create hx_local_mange_handler fail!ret=%d err=%s\n",ret, strerror(ret));
	}

	return ret;
}







