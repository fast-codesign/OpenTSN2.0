from lib.txt_engine import read_topo_or_streams_from_txt
from frame_demo.data_structure_for_frame_demo import *


# 从文本文件中读取topo_set，
# 并将topo_set的信息初始化成window_based的数据结构
# 输入：topo_txt
# 输出：包含Link对象的列表
def _init_link_obj_set_for_frame_demo(topo_txt):
    topo_set = read_topo_or_streams_from_txt(topo_txt)
    # print(topo_set)
    link_obj_set = []
    for link in topo_set:
        link_obj = Link(link_id=link['link_id'],
                        src_node=link['src_node'],
                        dst_node=link['dst_node'],
                        speed=link['speed'],
                        st_queues=link['st_queues'],
                        macrotick=link['macrotick']
                        )
        link_obj_set.append(link_obj)
    # print(link_obj_set)
    return link_obj_set


def _init_stream_obj_set_for_frame_demo(stream_txt, link_obj_set):
    stream_set = read_topo_or_streams_from_txt(stream_txt)
    stream_obj_set = []
    # print(stream_set)
    for stream in stream_set:
        hop_id = 0
        for link_id in stream['route']:
            link_obj_set[link_id].add_stream_to_current_link(stream['stream_id'], hop_id)
            hop_id += 1
        stream_obj = Stream(stream_id=stream['stream_id'],
                            size=stream['size'],
                            period=stream['period'],
                            latency_requirement=stream['latency_requirement'],
                            route_set=stream['route'])
        stream_obj_set.append(stream_obj)
    return stream_obj_set


def _init_stream_instance_obj_set_for_frame_demo(stream_obj_set, link_obj_set):
    stream_instance_obj_set = []
    for stream_obj in stream_obj_set:
        stream_instance_obj_set_per_stream = []
        period = stream_obj.period
        route_set = stream_obj.route_set
        hop_id = 0
        stream_id = stream_obj.stream_id
        size = stream_obj.size
        for link_id in route_set:
            macrotick = link_obj_set[link_id].macrotick
            speed = link_obj_set[link_id].speed
            trans_duration = math.ceil(size*8/speed)
            stream_instance_obj = Stream_Instance(stream_id=stream_id,
                                                  link_id=link_id,
                                                  hop_id=hop_id,
                                                  period=period,
                                                  trans_duration=trans_duration)
            stream_instance_obj.init_period_and_trans_duration(macrotick)
            hop_id += 1
            stream_instance_obj_set_per_stream.append(stream_instance_obj)
        stream_instance_obj_set.append(stream_instance_obj_set_per_stream)
    return stream_instance_obj_set


def init_topo_and_stream_obj_set_for_frame_demo(topo_txt, stream_txt):
    link_obj_set = _init_link_obj_set_for_frame_demo(topo_txt)
    stream_obj_set = _init_stream_obj_set_for_frame_demo(stream_txt, link_obj_set)
    stream_instance_obj_set = _init_stream_instance_obj_set_for_frame_demo(stream_obj_set,
                                                                           link_obj_set)
    return link_obj_set, stream_obj_set, stream_instance_obj_set


def _main():
    init_topo_and_stream_obj_set_for_frame_demo('../topo_test', '../stream_test')
    return


if __name__ == '__main__':
    _main()
    pass
