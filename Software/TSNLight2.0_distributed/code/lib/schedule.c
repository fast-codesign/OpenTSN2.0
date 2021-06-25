/** *************************************************************************
 *  @file       main.c
 *  @brief	    NP平台主线程
 *  @date		2020/06/05  星期四
 *  @author		psz
 *  @version	0.1.0
 ****************************************************************************/
#include "../include/schedule.h"


struct schedule_info schedule_table[MAX_SCHEDULE_NUM];
struct buf_list schedule_buf_list;

void hx_schedule_resource_init()
{
	schedule_buf_list=hx_buf_list_get();//调度线程为主线程只需要缓存区
	if(schedule_buf_list.head==NULL) 
		SCHEDULE_DBG("schedule_buf_list get buf fail \n");

	return;
}


void hx_schedule_init()
{
	int i=0;
	hx_schedule_resource_init();
	
	for(i=0;i<MAX_SCHEDULE_NUM;i++)
		{
		  schedule_table[i].key=0xffff;
		  schedule_table[i].value=0xff;
		}
	
	schedule_table[0].key=0x1648;//定时线程+流量产生定时消息
	schedule_table[0].value=TSN_FLOW_BUILD_ID;//流量产生线程
	
	schedule_table[1].key=0x1231;//NMAC线程+NMAC消息
	schedule_table[1].value=DATA_RESPONSE_ID;//数据响应线程
	
	schedule_table[2].key=0x0030;//数据接收线程+PTP消息
	schedule_table[2].value=PTP_SERVICE_ID;//PTP线程
	
	schedule_table[3].key=0x1030;//PTP线程+PTP消息
	schedule_table[3].value=DATA_RESPONSE_ID;//数据响应线程
	
	schedule_table[4].key=0x1644;//定时器线程+ptp定时消息
	schedule_table[4].value=PTP_SERVICE_ID;//PTP线程
	
	schedule_table[5].key=0x1031;//PTP线程+NMAC消息
	schedule_table[5].value=DATA_RESPONSE_ID;//数据响应线程
	
	schedule_table[6].key=0x1432;//流量产生线程+转发流消息
	schedule_table[6].value=DATA_RESPONSE_ID;//数据响应线程
	
	schedule_table[7].key=0x0033;//数据接收线程+终端接收流消息
	schedule_table[7].value=TSN_FLOW_END_ID;//终端接收线程

	schedule_table[8].key=0x0035;//数据接收线程+重组消息
	schedule_table[8].value=TSN_REGROUP_ID;//重组的线程

	schedule_table[9].key=0x1735;//重组线程+重组消息
	schedule_table[9].value=DATA_RESPONSE_ID;//数据响应线程
	
	schedule_table[10].key=0x0032;//数据接收线程+需要映射消息
	schedule_table[10].value=MAP_SERVICE_ID;//流量映射线程

	schedule_table[11].key=0x1645;//定时器线程+流量映射定时器
	schedule_table[11].value=MAP_SERVICE_ID;//流量映射线程

	schedule_table[12].key=0x1132;//映射线程+映射的消息
	schedule_table[12].value=DATA_RESPONSE_ID;//数据响应线程

	schedule_table[13].key=0x1836;//arp_reply线程+arp消息
	schedule_table[13].value=DATA_RESPONSE_ID;//数据响应线程

	schedule_table[14].key=0x0036;//数据接收线程+arp消息
	schedule_table[14].value=TSN_ARP_REPLY_ID;//arp线程

	schedule_table[15].key=0x0034;//数据接收线程+timer消息
	schedule_table[15].value=TSN_TIMER_ID;//timer线程
	
	SCHEDULE_DBG("np_schedule_init success \n");
	return;

}




void hx_msg_schedule()
{

		struct msg_quene *rd_msg_quene=NULL;
		struct msg_quene **wr_msg_quene=NULL;
		struct msg_node* tmp_msg=NULL;
		u8 hit_flag=0;
		u16 *msg_key=NULL;	
		int i=0;
		int j=0;
		for(i=0;i<MAX_SERVICE_NUM;i++)
		{
		  if(txq_service_list[i]!=NULL)//轮询tx队列
		    {

			    
				rd_msg_quene=txq_service_list[i];
				tmp_msg=hx_read_msg_quene_node(rd_msg_quene);//先从tx队列读出消息
				if(tmp_msg==NULL)
				  continue;        
                
				 msg_key=(u16*)tmp_msg;//
				 
                 for(j=0;j<MAX_SCHEDULE_NUM;j++)//查调度表
                 {
                   if(*msg_key==schedule_table[j].key)
                   	{
                       //NPLIB_DBG("main msg_key:%x j:%d\n",*msg_key,j);
                       if(schedule_table[j].value < MAX_SERVICE_NUM)
                       	{
                       		
                       		//printf("7777777777777777777777\n");
	                   	   wr_msg_quene=&rxq_service_list[schedule_table[j].value];	
							//printf("7777777777wr_msg_quene %p \n",*wr_msg_quene);
							
							if((*wr_msg_quene)->flag == 1)
						           hx_write_msg_quene_node_blocking(*wr_msg_quene,tmp_msg);//然后写入rx队列
						     else
							 	hx_free_buf(&schedule_buf_list,tmp_msg);
						   //printf("888888888888888888888\n");

						   hit_flag=1;
	
                       	}
					   break;
                   	}

				 }

				 if(hit_flag==0)
				 {
				   SCHEDULE_DBG("  schedule_buf_list\n");
				   hx_free_buf(&schedule_buf_list,tmp_msg);//调度表中不存在，归还缓存区归还
				 }
			  
		  	}  
		}

		return;
}


void hx_schedule_destroy()
{
	hx_free_buf_list(&schedule_buf_list);//归还（调度线程)缓冲区	

	return;
}



