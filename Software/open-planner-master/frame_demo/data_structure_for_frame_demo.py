import math
from z3 import *

'''frame_demo的数据结构定义'''


# 链路信息
class Link:
    def __init__(self, link_id, src_node, dst_node,
                 speed,
                 macrotick,
                 st_queues):
        self.link_id = link_id  # 链路id就是链路集合数组的下标
        self.src_node = src_node
        self.dst_node = dst_node
        self.speed = speed  # 链路速率
        self.macrotick = macrotick
        self.st_queues = st_queues  # src_node的egress_port的ST队列的数量
        # 由于window_demo未考虑propagation delay，因此frame_demo暂时不考虑
        # propagation delay
        # self.propagation_delay = propagation_delay
        # 记录经过该链路的所有流量，并记录
        # 该链路是该报文的第几跳
        self.stream_set = []

    def add_stream_to_current_link(self, stream_id, hop_id):
        self.stream_set.append({'stream_id': stream_id, 'hop_id': hop_id})


class Stream:
    def __init__(self, stream_id, size, period, latency_requirement, route_set):
        self.stream_id = stream_id
        self.size = size
        self.period = period
        self.latency_requirement = latency_requirement
        # 这条流的路由信息
        self.route_set = route_set


# 与window_demo不同，frame_demo中的流实例是
# 每条链路对应一个，调度周期内该链路上的所有报文的offset
# 可以由第一个报文的offset+n*period求出
class Stream_Instance:
    def __init__(self,
                 stream_id,
                 link_id,
                 hop_id,
                 period,
                 trans_duration):
        self.stream_id = stream_id
        self.link_id = link_id
        # 该流实例对应这条流的哪一跳路由
        self.hop_id = hop_id
        # 数据帧的周期应当scale to macrotick
        # 注意：这里的period与Stream类中的period不同
        # Stream类中的period并没有scale to macrotick
        self.period_scaled_to_macrotick = period
        self.trans_duration_scaled_to_macrotick = trans_duration
        # 即该报文实例对应在链路link_id上的offset
        # 这个值应该scale to macrotick
        # name = 'O_' + str(self.stream_id) + '_' + str(self.link_id)
        self.offset = Int(f'O_{stream_id}^({link_id})')
        self.prio = Int(f'P_{stream_id}^({link_id})')

    def init_period_and_trans_duration(self, macrotick):
        self.period_scaled_to_macrotick = math.ceil(self.period_scaled_to_macrotick / macrotick)
        self.trans_duration_scaled_to_macrotick = math.ceil(self.trans_duration_scaled_to_macrotick /
                                                            macrotick)


if __name__ == '__main__':
    pass
