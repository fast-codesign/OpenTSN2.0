#include "idps_main.h"
#include "print.c"


void idps_thread(void *argv)
{

   pkt_print(2);

}

//创建idps线程
int hx_idps_init()
{
    pthread_t idps_tid;
	if(pthread_create(&idps_tid, NULL,(void *)idps_thread, NULL) == -1)
	{
		NPLIB_DBG("create idps error!\n");
		return ERR;
	}

	return SUCCESS;
}


