/** *************************************************************************
 *  @file       main.c
 *  @brief	    TSN������PTP���߳�
 *  @date		2020/11/24  ������
 *  @author		xxc
 *  @version	0.1.0
 ****************************************************************************/
#include "./libptp/ptp.h"
#include "./libptp/timer.h"
#include"../cnc_api/include/cnc_api.h"

int main(int argc,char* argv[])
{
    u16 ptp_period = 100;
    u16 ptp_mult_imac = 4096;
    u16 ptp_master_imac = 2;//��ȡ������Ϣ��ʱ��ͬ�����ڡ���ʱ��imac���鲥imac

    char test_rule[64] = {0};
	char temp_net_interface[16]={0};

	if(argc != 2)
	{
		printf("input format:./cnc_ptp net_interface\n");
		return 0;
	}


	sprintf(test_rule,"%s","ether[3:1]=0x05 and ether[12:2]=0xff01");       //libpcap����������ӿڸ�ֵ
	sprintf(temp_net_interface,"%s",argv[1]);

	data_pkt_receive_init(test_rule,temp_net_interface);           //��ʼ�����ݱ��Ľ����뷢��
	data_pkt_send_init(temp_net_interface);

    timer_init(ptp_period,ptp_mult_imac,ptp_master_imac);     //������ʱ�߳�


    data_pkt_receive_loop(ptp_callback);                        //ptp���߼�����

    data_pkt_receive_destroy();
	data_pkt_send_destroy();
    //ptp_destroy();
}
