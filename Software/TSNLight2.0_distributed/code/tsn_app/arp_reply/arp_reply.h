
#ifndef _ARP_REPLY_H__
#define _ARP_REPLY_H__

//#include <libnet.h>
#include "../../include/np.h"  
#include "../../include/tools.h" 




struct arp_hdr
{
    u16 ar_hrd;         /* format of hardware address */
    u16 ar_pro;         /* format of protocol address */
    u8  ar_hln;         /* length of hardware address */
    u8  ar_pln;         /* length of protocol addres */
    u16 ar_op;          /* operation type */
};

struct arp_mac_info
{
	u8 enet_local[6];
	u8 ip_local[4];
};


int arp_reply_init();


#define ARP_REPLY_DEBUG 1

#if ARP_REPLY_DEBUG
	#define ARP_REPLY_DBG(args...) do{printf("ARP_REPLY-INFO:");printf(args);}while(0)
	#define ARP_REPLY_ERR(args...) do{printf("ARP_REPLY-ERROR:");printf(args);}while(0)
#else
	#define ARP_REPLY_DBG(args...)
	#define ARP_REPLY_DBG(args...)
#endif
//void ids_pkt_print(u8 *pkt,int len);


#endif

