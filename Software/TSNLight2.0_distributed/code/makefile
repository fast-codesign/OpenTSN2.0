#!/bin/bash
#
#make TYPE=NP 表示对np应用场景进行编译
#make TYPE=TSN 表示对tsn仿真应用场景进行编译
#make TYPE=TSN_FPGA 表示对tsn FPGA应用场景进行编译


CC=gcc -g


LDHDPATH = -I ./include 
LDLIBS =-lm -lpthread -lpcap -lnet

LIBSRC=./lib/
IDPS=./np_app/idps/

AR=ar

all: clean hx

ifeq (NP,$(TYPE))
hx:	main.c libhxlib.a libnp.a
	$(CC) -D $(TYPE) -o hx main.c -L ./ -lhxlib -L ./ -lnp $(LDLIBS) $(LDHDPATH)
else
hx:	main.c libhxlib.a libtsn.a
	$(CC) -D $(TYPE) -o hx main.c -L ./ -lhxlib -L ./ -ltsn $(LDLIBS) $(LDHDPATH)
endif

libhxlib.a:
	$(CC) -o $(LIBSRC)buf.o -c ./lib/buf.c $(LDLIBS) $(LDHDPATH) 
	$(CC) -o $(LIBSRC)quene.o -c ./lib/quene.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)msg.o -c ./lib/msg.c $(LDLIBS) $(LDHDPATH)
ifeq (NP,$(TYPE))
	$(CC) -o $(LIBSRC)data_rec_engine.o -c ./lib/np_data_rec_engine.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)data_send_engine.o -c ./lib/np_data_send_engine.c $(LDLIBS) $(LDHDPATH)
else ifeq (TSN,$(TYPE))
	$(CC) -o $(LIBSRC)data_rec_engine.o -c ./lib/tsn_simulate_rec_engine.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)data_send_engine.o -c ./lib/tsn_simulate_send_engine.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)timer.o -c ./tsn_app/timer/hw_timer.c $(LDLIBS) $(LDHDPATH)	
else ifeq (TSN_FPGA,$(TYPE))
	$(CC) -o $(LIBSRC)data_rec_engine.o -c ./lib/tsn_data_rec_engine.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)data_send_engine.o -c ./lib/tsn_data_send_engine.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)timer.o -c ./tsn_app/timer/timer.c $(LDLIBS) $(LDHDPATH)
endif
	$(CC) -o $(LIBSRC)basic.o -c ./lib/basic.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)schedule.o -c ./lib/schedule.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)tools.o -c ./lib/tools.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)table_operations.o -c ./lib/table_operations.c $(LDLIBS) $(LDHDPATH)
	#$(CC) -o $(LIBSRC)timer.o -c ./tsn_app/timer/hw_timer.c $(LDLIBS) $(LDHDPATH)	
	$(AR) -rc libhxlib.a $(LIBSRC)buf.o $(LIBSRC)quene.o $(LIBSRC)msg.o $(LIBSRC)data_rec_engine.o $(LIBSRC)data_send_engine.o $(LIBSRC)basic.o $(LIBSRC)\
	schedule.o $(LIBSRC)tools.o $(LIBSRC)timer.o $(LIBSRC)table_operations.o 


ifeq (NP,$(TYPE))

libnp.a:
	$(CC) -o $(IDPS)idps_main.o -c $(IDPS)idps_main.c $(LDLIBS) 
	$(CC) -o $(IDPS)print.o -c $(IDPS)print.c $(LDLIBS) 
	$(AR) -rc libnp.a $(IDPS)idps_main.o $(IDPS)print.o 

else

libtsn.a:
	$(CC) -D $(TYPE) -o local_mange.o -c ./tsn_app/local_mange/local_mange.c  $(LDLIBS) $(LDHDPATH)    #local_mange
	$(CC) -D $(TYPE) -o regroup.o -c ./tsn_app/pkt_regroup/regroup.c $(LDLIBS) $(LDHDPATH)    #regroup
	$(CC) -D $(TYPE) -o ptp.o -c ./tsn_app/ptp/ptp.c $(LDLIBS) $(LDHDPATH)    #ptp   

	$(CC) -D $(TYPE) -o map_service.o -c ./tsn_app/flow_map/map_service.c $(LDLIBS) $(LDHDPATH) 

	$(CC) -o arp_reply.o -c ./tsn_app/arp_reply/arp_reply.c $(LDLIBS) $(LDHDPATH) 
	$(AR)  -rc  libtsn.a local_mange.o regroup.o ptp.o map_service.o arp_reply.o 

endif

	$(warning "the value is $(TYPE)")
	
clean:
	rm -rf hx *.a *.o $(LIBSRC)*.o $(IDPS)*.o
	






