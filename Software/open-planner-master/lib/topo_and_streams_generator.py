from random import randint, choice
import matplotlib.pyplot as plt
import networkx as nx
from lib.txt_engine import write_topo_or_stream_to_txt


# TODO：


# 显示拓扑图
# 输入：图
def _show_topology_graph(graph):
    pos = nx.spring_layout(graph, iterations=200)  # 用 FR算法排列节点
    nx.draw(graph, pos, with_labels=True)
    labels = nx.get_edge_attributes(graph, 'link_id')
    nx.draw_networkx_edge_labels(graph, pos, edge_labels=labels)
    # 显示3秒后关闭
    plt.show(block=False)
    plt.pause(3)
    plt.close('all')


# 这个函数用于生成线性的网络拓扑图
# 输入：交换机数目，每个交换机上的终端数目集合
# 输出：拓扑图 DiGraph
def _generate_linear_topo_graph(sw_num,
                                es_num_per_sw_set,
                                show_topo_graph):
    # 网络拓扑
    G = nx.DiGraph()

    # 第一步，添加所有的交换机节点
    sw_id = 0
    for sw in range(sw_num):
        G.add_node(sw_id, node_id=sw_id, node_type='SW', es_set=[])
        sw_id += 1

    # 第二步，添加所有的终端节点
    es_id = sw_num
    for sw in range(sw_num):
        es_num_of_current_sw = choice(es_num_per_sw_set)
        for es in range(es_num_of_current_sw):
            G.add_node(es_id, node_id=es_id, node_type='ES')
            # 这个节点应当连接到哪一个交换机
            es_set = G.nodes[sw]['es_set']
            es_set.append(es_id)
            G.nodes[sw]['es_set'] = es_set
            es_id += 1

    # 第三步，添加交换机节点之间的链路
    sw_id_set = range(0, sw_num)
    link_id = 0
    for sw in sw_id_set[0:-1]:
        G.add_edge(sw, sw + 1, link_id=link_id)
        link_id += 1
        G.add_edge(sw + 1, sw, link_id=link_id)
        link_id += 1

    # 第四步，添加终端节点与交换机节点之间的链路
    for sw in sw_id_set:
        es_set = G.nodes[sw]['es_set']
        print(es_set)
        for es in es_set:
            G.add_edge(sw, es, link_id=link_id)
            link_id += 1
            G.add_edge(es, sw, link_id=link_id)
            link_id += 1

    # 如果要显示拓扑
    if show_topo_graph:
        _show_topology_graph(G)

    print(G)
    # 返回生成的拓扑图
    return G


# 根据链路需求生成网络拓扑
# 输入：图，带宽集合，ST队列数目集合，GCL表项深度或macrotick
# 输出：用列表表示的拓扑信息，列表的元素是字典
def _generate_topology(sw_num,
                       es_num_per_sw_set,
                       speed_set,  # 带宽
                       st_queues_set,  # ST队列数量
                       topo_type,
                       **kwargs  # 可选键值：show_topo_graph, gcl_len, macrotick
                       ):
    # 解析kwargs
    if kwargs.get('show_topo_graph') is None:
        show_topo_graph = False
    else:
        show_topo_graph = kwargs['show_topo_graph']

    if kwargs.get('macrotick') is not None and kwargs.get('gcl_len') is not None:
        print("Error - More than one parameter entered. "
              "Only one of gcl_len or macrotick can be selected.")
        exit(0)

    G = None
    topo_set = []
    if topo_type == 'linear':
        G = _generate_linear_topo_graph(sw_num, es_num_per_sw_set, show_topo_graph)
    else:
        print('Error - invalid topo_type')
        exit(0)

    links = G.edges
    for per_link in links:
        src_node = per_link[0]
        dst_node = per_link[1]
        link_id = G[src_node][dst_node]['link_id']
        speed = choice(speed_set)
        st_queues = choice(st_queues_set)
        # 判断kwargs的内容
        # 如果同时有gcl_len和macrotick
        # 报错
        link = {}
        if kwargs.get('macrotick') is not None and \
                kwargs.get('macrotick') > 0:
            macrotick = kwargs['macrotick']
            link = {'link_id': link_id, 'src_node': src_node,
                    'dst_node': dst_node, 'speed': speed,
                    'st_queues': st_queues, 'macrotick': macrotick
                    }
        elif kwargs.get('gcl_len') is not None and \
                kwargs.get('gcl_len') > 0:
            gcl_len = kwargs['gcl_len']
            link = {'link_id': link_id, 'src_node': src_node,
                    'dst_node': dst_node, 'speed': speed,
                    'st_queues': st_queues, 'gcl_len': gcl_len
                    }
        else:
            print("Error - invalid gcl_len or macrotick.")
            exit(0)
        topo_set.append(link)
    topo_set.sort(key=lambda x: x['link_id'])
    return G, topo_set


# 为流量随机生成stream_num条路由路径
# 输入：图，流量数目
# 输出：stream_num条流量的路由路径，路由路径由特定顺序的link_id构成
def _random_route_path_for_streams(G, stream_num):
    route_path_set = []
    # 找到图中的所有终端节点
    es_node = []
    for node in G.nodes:
        if G.nodes[node]['node_type'] == 'ES':
            es_id = G.nodes[node]['node_id']
            # print(es_id)
            es_node.append(es_id)
    # print(es_node)

    for stream in range(stream_num):
        src_es_id = choice(es_node)
        dst_es_id = choice(es_node)
        while dst_es_id == src_es_id:
            dst_es_id = choice(es_node)

        shortest_path_in_node_id = nx.shortest_path(G, src_es_id, dst_es_id)
        # shortest_path_in_node_id是node_id的集合
        # 将shortest_path_in_node_id转换成link_id的集合
        shortest_path_in_link_id = []
        for src_node_id, dst_node_id in zip(shortest_path_in_node_id, shortest_path_in_node_id[1:]):
            link_id = G[src_node_id][dst_node_id]['link_id']
            shortest_path_in_link_id.append(link_id)
        route_path_set.append(shortest_path_in_link_id)
    return route_path_set


# 在网络拓扑中随机生成stream_num条流量
# 注意：period_set、latency_requirement_set、jitter_requirement_set中的
# 元素是一一对应的关系
# 输入：图，流量数目，报文大小集合，周期集合，延时要求集合，抖动要求集合
# 输出：用列表表示的流集合，列表的元素是字典
def _generate_random_streams(G,
                             stream_num,
                             size_set,
                             period_set,
                             latency_requirement_set,
                             jitter_requirement_set):
    stream_set = []
    # 为流量随机生成路由路径
    route_set = _random_route_path_for_streams(G, stream_num)

    for (stream_id, route) in zip(range(stream_num), route_set):
        size = choice(size_set)
        index = randint(0, len(period_set) - 1)
        period = period_set[index]
        latency_requirement = latency_requirement_set[index]
        jitter_requirement = jitter_requirement_set[index]
        stream = {'stream_id': stream_id,
                  'size': size,
                  'period': period,
                  'latency_requirement': latency_requirement,
                  'jitter_requirement': jitter_requirement,
                  'route': route}
        stream_set.append(stream)
    return stream_set


# 对外提供的接口
# 根据输入的拓扑需求和流量需求，
# 生成拓扑和流量，并写入文本文件
# 输入：拓扑需求和流量需求
def construct_topo_and_streams(topo_txt,
                               stream_txt,
                               topo_type='linear',
                               sw_num=5,
                               es_num_per_sw_set=None,
                               speed_set=None,
                               st_queues_set=None,
                               stream_num=50,
                               size_set=None,
                               period_set=None,
                               latency_requirement_set=None,
                               jitter_requirement_set=None,
                               **kwargs):  # kwargs包括：gcl_len or macrotick, show_topo_graph

    if es_num_per_sw_set is None:
        es_num_per_sw_set = [2]
    if speed_set is None:
        speed_set = [1000]
    if st_queues_set is None:
        st_queues_set = [2]
    if size_set is None:
        size_set = [1518]
    if period_set is None:
        period_set = [20000]
    if latency_requirement_set is None:
        latency_requirement_set = [20000]
    if jitter_requirement_set is None:
        jitter_requirement_set = [200]

    # 第一步：生成拓扑
    G, topo_set = _generate_topology(sw_num,
                                     es_num_per_sw_set,
                                     speed_set,
                                     st_queues_set,
                                     topo_type,
                                     **kwargs
                                     )

    # 第二步：将拓扑信息输出到文本文件
    write_topo_or_stream_to_txt(topo_txt, topo_set)

    # 第三步：生成流量
    stream_set = _generate_random_streams(G, stream_num, size_set,
                                          period_set,
                                          latency_requirement_set,
                                          jitter_requirement_set)
    # 第四步：将流量信息输出到文本文件
    write_topo_or_stream_to_txt(stream_txt, stream_set)

    return


def _main():
    construct_topo_and_streams('../topo_test',
                               '../stream_test',
                               sw_num=5,
                               es_num_per_sw_set=[3],
                               speed_set=[1000],
                               st_queues_set=[2],
                               stream_num=75,
                               size_set=[1518],
                               period_set=[20000],
                               latency_requirement_set=[20000],
                               jitter_requirement_set=[200],
                               gcl_len=1,
                               show_topo_graph=True)
    return


if __name__ == '__main__':
    _main()
