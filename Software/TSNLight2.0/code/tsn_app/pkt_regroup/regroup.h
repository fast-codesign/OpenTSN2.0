/** *************************************************************************
 *  @file          regroup.h
 *  @brief	  
 * 
 *  详细说明
 * 
 *  @date	   2020/07/08 
 *  @author		junshuai.li
 *  @email		1145331404@qq.com
 *  @version	1.0
 ****************************************************************************/

#ifndef _REGROUP_H__
#define _REGROUP_H__



#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include<stdlib.h>
#include <pthread.h>
#include<malloc.h>


#include "../../include/np.h" 


typedef char s8;				/**< 有符号的8位（1字节）数据定义*/
typedef unsigned char u8;		/**< 无符号的8位（1字节）数据定义*/
typedef short s16;				/**< 有符号的16位（2字节）数据定义*/
typedef unsigned short u16;	/**< 无符号的16位（2字节）数据定义*/
typedef int s32;				/**< 有符号的32位（4字节）数据定义*/
typedef unsigned int u32;		/**< 无符号的32位（4字节）数据定义*/
typedef long long s64;				/**< 有符号的64位（8字节）数据定义*/
typedef unsigned long long u64;		/**< 无符号的64位（8字节）数据定义*/

#define REGROUP_DEBUG 1


#if REGROUP_DEBUG
	#define REGROUP_DBG(args...) do{printf("TIMER-INFO:");printf(args);}while(0)
	#define REGROUP_ERR(args...) do{printf("TIMER-ERROR:");printf(args);}while(0)
#else
	#define REGROUP_DBG(args...)
	#define REGROUP_ERR(args...)
#endif



int hx_regroup_handler();



#endif


