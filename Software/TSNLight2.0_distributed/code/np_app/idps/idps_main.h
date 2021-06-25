#ifndef IDPS_H 
#define IDPS_H 


#include "../../include/np.h"


int hx_idps_init();


#define IDPS_DEBUG 1

#if IDPS_DEBUG
	#define IDPS_DBG(args...) do{printf("IDPS-INFO:");printf(args);}while(0)
	#define IDPS_ERR(args...) do{printf("IDPS-ERROR:");printf(args);}while(0)
#else
	#define IDPS_DBG(args...)
	#define IDPS_DBG(args...)
#endif
void ids_pkt_print(u8 *pkt,int len);

#endif 

