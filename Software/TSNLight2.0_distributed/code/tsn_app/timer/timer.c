
#include "timer.h"



struct hx_timer msg_timer[MAX_TIMER_NUM];
pthread_mutex_t timer_lock;
int cur_timer_num;
struct hx_context  timer_context;

int hx_register_timer(int total_time,int service_id,int ismult)
{
	int i =0 ;
	int findflag = 0;
	pthread_mutex_lock(&timer_lock);

	for(i=0; i<MAX_TIMER_NUM; i++)
	{
		//每一个serviece_id只允许注册一个有效的定时器，如果存在会覆盖
		if((service_id == msg_timer[i].service_id) && (1 == msg_timer[i].status))
		{
			TIMER_ERR("timer is already exist! id:%d", service_id);
			findflag=1;
			break;
		}
	}

	if(!findflag)
	{
		for(i=0; i<MAX_TIMER_NUM; i++)
		{
			if(0 == msg_timer[i].status)
			{
				break;
			}
		}
	}
	
	if(i == MAX_TIMER_NUM)
	{
		TIMER_ERR("timer num is maximum!\n");
		pthread_mutex_unlock(&timer_lock);
		return -1;
	}
	
	if(!findflag)
	{
		cur_timer_num++;
	}

	msg_timer[i].total_time=total_time;
	msg_timer[i].left_time=total_time;
	msg_timer[i].service_id =service_id;
	msg_timer[i].multtimes=ismult;
	msg_timer[i].status=1;

	pthread_mutex_unlock(&timer_lock);
	return 0;
}


int hx_unregister_timer(int service_id)
{
	int i =0 ;
	int findflag = 0;

	if(0 == cur_timer_num)
	{
		TIMER_ERR("Current Timer number is 0, return!");
		return 0;
	}
	
	pthread_mutex_lock(&timer_lock);

	for(i=0; i<MAX_TIMER_NUM; i++)
	{
		//每一个serviece_id只允许注册一个有效的定时器，如果存在会覆盖
		if(service_id == msg_timer[i].service_id)
		{
			TIMER_ERR("timer is already exist! id:%d", service_id);
			break;
		}
	}

	if(i == MAX_TIMER_NUM)
	{
		TIMER_ERR("not found timer, timer is already destory!");
		pthread_mutex_unlock(&timer_lock);
		return 0;
	}

	memset(&msg_timer[i], 0, sizeof(struct hx_timer));
	cur_timer_num--;

	pthread_mutex_unlock(&timer_lock);
	return 0;
}


void timer_out_handler(int i)
{
	//第一步申请buf
	u8* buf_addr;
	buf_addr=hx_malloc_eth_pkt_buf(&timer_context.buffer_list);//取一个缓存区eth地址

	//第二步构造消息填充到发送队列
	struct msg_node* tmp_msg_node=(struct msg_node*)((u8*)buf_addr-PAD_BUF_LEN-MSG_NODE_LEN-METADATA_BUF_LEN);
	tmp_msg_node->msg_type=TSN_TIMER + msg_timer[i].service_id;//TSM_TIMER + 服务ID
	
	tmp_msg_node->src_service_id=TSN_TIMER_ID;
	tmp_msg_node->eth_pkt_len=0;
	tmp_msg_node->eth_head_ptr=buf_addr;

	if(ERR==hx_write_msg_quene_node(&timer_context.txq,tmp_msg_node))
	{
	  TIMER_DBG("hx_write_msg_quene_node fail\n");
	  hx_free_buf(&timer_context.buffer_list,tmp_msg_node);
	}

	return;
}


void timer_callback()
{
	int j=0, ret=0;
	pthread_t id1;
	
	for(j=0; j<MAX_TIMER_NUM; j++)
	{
		if(!msg_timer[j].status)
		{
			continue;
		}
		msg_timer[j].left_time--;
		if(0 == msg_timer[j].left_time)
		{
			//TIMER_DBG("time is out = %x \n",msg_timer[j].service_id);
			timer_out_handler(j);

			if(msg_timer[j].multtimes == 1)
			{
				msg_timer[j].left_time = msg_timer[j].total_time;
			}
			else
			{
				msg_timer[j].status = 0;
			}
		}
	}

	return;
}


int hx_timer_contex_init()
{
	struct hx_context_arg  hx_timer_arg;
	memset(&hx_timer_arg,0,sizeof(struct hx_context_arg));
	
	hx_timer_arg.service_id=TSN_TIMER_ID;//0x01
	hx_timer_arg.txq_size=128;
	
	hx_init(&timer_context,&hx_timer_arg); 

	return 0;
}


int hx_timer_contex_destroy()
{
	hx_destroy(&timer_context); 
	return 0;
}


/*定时器处理线程*/
void hx_start_timer(void *argv)
{
	
	hx_timer_contex_init();
	
	struct itimerval tick;
	
	pthread_detach(pthread_self());
		
	printf("hx_start_timer start!\n");
	signal(SIGALRM, timer_callback);
	memset(&tick, 0, sizeof(tick));
	
	//Timeout to run first time
	tick.it_value.tv_sec = 0;
	tick.it_value.tv_usec = BASE_TIMER;
	
	//After first, the Interval time for clock
	tick.it_interval.tv_sec = 0;
	tick.it_interval.tv_usec = BASE_TIMER;
	
	if(setitimer(ITIMER_REAL, &tick, NULL) < 0)
	{
		TIMER_ERR("Set timer failed!\n");
	}
	
	while(1)
	{
		pause();
	}

	hx_timer_contex_destroy();

	TIMER_DBG("hx_start_timer end!\n");
}



int hx_timer_init()
{
	int ret = -1;
	pthread_t timerid;

	pthread_mutex_init(&timer_lock,NULL);
	
	ret=pthread_create(&timerid,NULL,(void *)hx_start_timer,NULL); 
	
	if(0 != ret)
	{
		TIMER_ERR("create hx_timer_handler fail!ret=%d err=%s\n",ret, strerror(ret));
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
