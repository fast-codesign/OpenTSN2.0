from window_demo.constraints_constructor_for_window_demo import *
from window_demo.topo_and_streams_txt_parser_for_window_demo import *
from window_demo.z3_model_parser_for_window_demo import *
from lib.z3_constraints_solver import *
from lib.topo_and_streams_generator import *


def main():
    # 1. 输入拓扑需求和流量需求

    # 2. 根据拓扑和流量需求生成拓扑文件和流量文件
    print('phase 1: generating topo and stream txt...')
    construct_topo_and_streams('C:/Users/662/Desktop/open-planner-master/log/topo_macrotick_1_stream_32',
                               'C:/Users/662/Desktop/open-planner-master/log/stream_macrotick_1_stream_32',
                               sw_num=5,
                               es_num_per_sw_set=[3],
                               speed_set=[1000],
                               st_queues_set=[2],
                               stream_num=100,
                               size_set=[1518],
                               period_set=[10000, 20000],
                               latency_requirement_set=[10000, 20000],
                               jitter_requirement_set=[100, 200],
                               gcl_len=4,
                               show_topo_graph=False)

    # 3. 按照window_demo的数据结构初始化链路、流量及流实例集合
    print('phase 2: initializing topo and stream object set...')
    (link_obj_set,
     stream_obj_set,
     stream_instance_obj_set) = init_topo_and_stream_obj_set_for_window_demo('C:/Users/662/Desktop/open-planner-master/log/topo_macrotick_1_stream_32', 'C:/Users/662/Desktop/open-planner-master/log/stream_macrotick_1_stream_32',)

    # 4. 生成约束
    print('phase 3: constructing constraints...')
    constraint_set = construct_constraints_for_window_demo(link_obj_set,
                                                           stream_obj_set,
                                                           stream_instance_obj_set,
                                                           sync_precision=1)

    # 5. 添加约束并求解
    print('phase 4: adding and solving constraints...')
    result_set = add_and_solve_constraints(constraint_set, timeout= -1)
    # print(result_set)

    # 6. 解析z3的解，并将解输出到文本文件
    print('phase 5: writing solution...')
    write_declare_set_to_txt(result_set, link_obj_set, 'C:/Users/662/Desktop/open-planner-master/log/solution_win_4_stream_32')

    return


if __name__ == '__main__':
    main()
