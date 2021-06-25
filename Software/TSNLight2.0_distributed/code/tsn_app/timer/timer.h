
#ifndef _TIMER_H__
#define _TIMER_H__

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include <pthread.h>
#include<malloc.h>
#include <sys/time.h>
#include <signal.h>
#include <unistd.h>
#include "../../include/np.h"  



#define MAX_TIMER_NUM 10
#define BASE_TIMER 1000  //1000us = 1ms

struct hx_timer
{
	int status;/*1表示启用，0表示未启用*/
    int total_time;  /*每隔total_time毫秒*/
    int left_time;   /*还剩left_time毫秒*/
    int service_id;        /*该定时器超时，要执行的代码的标志*/
    int multtimes;	/*表示定时器超时后是否就停止，1:表示循环多次使用，0表示只使用1次*/
};/*定义Timer类型的数组，用来保存所有的定时器*/

int hx_register_timer(int total_time,int service_id,int ismult);

int hx_unregister_timer(int service_id);

int hx_timer_init();



#define TIMER_DEBUG 1

#if TIMER_DEBUG
	#define TIMER_DBG(args...) do{printf("TIMER-INFO:");printf(args);}while(0)
	#define TIMER_ERR(args...) do{printf("TIMER-ERROR:");printf(args);}while(0)
#else
	#define TIMER_DBG(args...)
	#define TIMER_DBG(args...)
#endif
//void ids_pkt_print(u8 *pkt,int len);


#endif

