
#include "../include/np.h"
#include "../include/tools.h"


int sock_raw_fd;
struct sockaddr_ll sll;	


void hx_data_send_init()
{
	//原始套接字发送
	sock_raw_fd = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
					//原始套接字地址结构
	struct ifreq req;					//网络接口地址
    
	char temp_net_interface[256] = {0};
	get_cfgx_file(TSN_CONFIG_FILE, "net_interface", temp_net_interface);

	//printf("temp_net_interface = %s \n",temp_net_interface);
	strncpy(req.ifr_name,temp_net_interface, IFNAMSIZ);			//指定网卡名称
	//strncpy(req.ifr_name, "enaftgm1i0", IFNAMSIZ);			//指定网卡名称
	if(-1 == ioctl(sock_raw_fd, SIOCGIFINDEX, &req))	//获取网络接口
	{
		perror("ioctl");
		close(sock_raw_fd);
		exit(-1);
	}
	
	/*将网络接口赋值给原始套接字地址结构*/
	bzero(&sll, sizeof(sll));
	sll.sll_ifindex = req.ifr_ifindex;
	

	return ;
}

void hx_data_send(struct msg_node* tmp_msg_node)
{
	int len;
	//printf("send pkt\n");
	//np_pkt_print((u8*)tmp_msg_node->eth_head_ptr, tmp_msg_node->eth_pkt_len);
	len = sendto(sock_raw_fd, (u8*)tmp_msg_node->eth_head_ptr, tmp_msg_node->eth_pkt_len, 0 , (struct sockaddr *)&sll, sizeof(sll));
	if(len == -1)
	{
	   perror("sendto fail\n");
	}

	return;
}

void hx_data_send_destroy()
{
	close(sock_raw_fd);
}


