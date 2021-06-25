/** *************************************************************************
 *  @file       main.c
 *  @brief	    NP平台主线程
 *  @date		2020/06/05  星期四
 *  @author		psz
 *  @version	0.1.0
 ****************************************************************************/
#include "./include/np.h"
#include "./include/schedule.h"
#include "./tsn_app/timer/timer.h"
#include "./np_app/idps/idps_main.h"

#include "./tsn_app/local_mange/local_mange.h"
#include "./tsn_app/pkt_regroup/regroup.h"
#include "./tsn_app/ptp/ptp.h"

#include "./tsn_app/flow_map/map_service.h"
#include "./tsn_app/arp_reply/arp_reply.h"


int main(int argc,char* argv[])
{
	hx_txq_rxq_service_list_init();//平台服务队列初始化ALL	
	hx_buf_pool_init();//平台缓存池初始化ALL
	hx_schedule_init();//调度表部分初始化
	
   /*********外部服务线程*********/
#ifdef NP
 	hx_idps_init();//idps线程  

#else

	hx_local_mange_handler();//本地管理线程
	
	hx_ptp_init();  //ptp线程

	hx_map_init();
	
	hx_regroup_handler();
	
#ifdef TSN_FPGA
	arp_reply_init();
#endif

#endif	

   /***********外部服务线程*******/

	hx_data_service_thread_init();//创建基础服务线程
	//hx_controller_service_thread_init();//创建基础服务线程
	
	sleep(2); //为了避免selep不生效，先sleep再起定时器线程以保证线程都初始化完了再调度
	hx_timer_init();//定时器线程

	sleep(2); //为了避免selep不生效，先sleep再起定时器线程以保证线程都初始化完了再调度

	while(1)//调度
	{
	 	hx_msg_schedule();
		//usleep(1);
	}

	hx_schedule_destroy();
	hx_buf_pool_destroy();//主线程结束，销毁缓存池（平台）

	return SUCCESS;

}
