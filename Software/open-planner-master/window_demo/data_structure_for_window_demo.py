from z3 import *

'''window-demo的数据结构定义'''


# 链路类
class Link:
    def __init__(self, link_id, src_node, dst_node,
                 speed, gcl_len, st_queues):
        self.link_id = link_id  # 链路id就是链路集合数组的下标
        self.src_node = src_node
        self.dst_node = dst_node
        self.speed = speed  # 链路速率
        self.gcl_len = gcl_len  # src_node的egress port的GCL表项数目
        self.st_queues = st_queues  # src_node的egress_port的ST队列的数量

        # 下列三个数组是需要SMT求解的未知变量
        # 变量命名规则：
        # Phi/Tau/Kappa^(link_id)： P/T/K区分三个array
        #           i表示link_id
        # 开窗口的时刻的array，即论文中的Phi
        self.phi_array = Array(f'P^({link_id})', IntSort(), IntSort())
        # 关窗口的时刻的array，即论文中的Tau
        self.tau_array = Array(f'T^({link_id})', IntSort(), IntSort())
        # 初始的tau
        self.tau_0_array = Array(f'T_0^({link_id})', IntSort(), IntSort())
        # 存放中间结果的tau
        self.tau_1_array = Array(f'T_1^({link_id})', IntSort(), IntSort())
        # 窗口到队列的映射，即论文中的Kappa
        self.kappa_array = Array(f'K^({link_id})', IntSort(), IntSort())

        # 记录经过该链路的所有流量：[stream_id, hop_id]
        # stream_id用于标识流，hop_id用于标识该链路是这条流的第几跳
        self.stream_set = []

    def add_stream_to_current_link(self, stream_id, hop_id):
        self.stream_set.append({'stream_id': stream_id, 'hop_id': hop_id})


# 流量的路由信息类
class Route:
    def __init__(self, link_id):
        self.link_id = link_id
        self.trans_duration = 0

    # trans_duration的计算需要使用：Link类中的speed以及Stream类里面的size
    def compute_trans_duration(self, size, speed):
        self.trans_duration = math.ceil(size * 8 / speed)


# 流量类
class Stream:
    def __init__(self, stream_id, size, period,
                 latency_requirement, jitter_requirement,
                 route_obj_set):
        self.stream_id = stream_id
        self.size = size
        self.period = period
        self.latency_requirement = latency_requirement
        self.jitter_requirement = jitter_requirement
        # 这条流的路由信息
        self.route_obj_set = route_obj_set


# 流实例/数据帧类
# 每条流量在每条链路上的第i个周期的报文
class Stream_Instance:
    # Stream_Instance包含以下几个成员变量
    # stream_id, link_id, instance_id, Omega(window_index)
    # 其中，Omega是未知数，需要z3求解
    def __init__(self, stream_id, link_id,
                 instance_id, hop_id):
        self.stream_id = stream_id
        self.link_id = link_id
        self.instance_id = instance_id
        # 该流实例对应这条流的哪一跳路由
        self.hop_id = hop_id
        # 即该报文实例对应在Phi和Tau两个array内的索引
        # 对应论文中的Omega
        # Omega也是一个未知数，在初始化的阶段再分配变量名
        # name = 'Omega_' + str(self.stream_id) + ',' + str(self.link_id) \
        #        + '_' + str(self.instance_id)
        self.omega = Int(f'O_{stream_id},{instance_id}^({link_id})')


if __name__ == '__main__':
    pass
