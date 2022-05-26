from z3 import *

from frame_demo.topo_and_streams_txt_parser_for_frame_demo import init_topo_and_stream_obj_set_for_frame_demo
from lib.lib import compute_hyper_period


def construct_constraints_for_frame_demo(link_obj_set,
                                         stream_obj_set,
                                         stream_instance_obj_set,
                                         sync_precision=1):
    constraint_formula_set = []

    hyper_period = compute_hyper_period(*[int(stream_obj.period) for stream_obj in stream_obj_set])

    # 1. frame constraint

    for stream_instance_obj_set_per_stream in stream_instance_obj_set:
        for stream_instance_obj in stream_instance_obj_set_per_stream:
            formula = And(stream_instance_obj.offset >= 0,
                          stream_instance_obj.offset <=
                          stream_instance_obj.period_scaled_to_macrotick -
                          stream_instance_obj.trans_duration_scaled_to_macrotick)
            constraint_formula_set.append(formula)
    # print(constraint_formula_set)

    # 2. link constraint
    for link in link_obj_set:
        stream_set = link.stream_set
        link_id = link.link_id
        for i in range(len(stream_set)):
            for j in range(len(stream_set)):
                if i != j:
                    i_stream_id = stream_set[i]['stream_id']
                    i_hop_id = stream_set[i]['hop_id']
                    j_stream_id = stream_set[j]['stream_id']
                    j_hop_id = stream_set[j]['hop_id']
                    ik_offset = stream_instance_obj_set[i_stream_id][i_hop_id].offset
                    ik_period_scaled_to_macrotick = stream_instance_obj_set[i_stream_id][
                        i_hop_id].period_scaled_to_macrotick
                    ik_trans_duration = stream_instance_obj_set[i_stream_id][
                        i_hop_id].trans_duration_scaled_to_macrotick
                    jl_offset = stream_instance_obj_set[j_stream_id][j_hop_id].offset
                    jl_period_scaled_to_macrotick = stream_instance_obj_set[j_stream_id][
                        j_hop_id].period_scaled_to_macrotick
                    jl_trans_duration = stream_instance_obj_set[j_stream_id][
                        j_hop_id].trans_duration_scaled_to_macrotick

                    i_period = stream_obj_set[i_stream_id].period
                    j_period = stream_obj_set[j_stream_id].period

                    for alpha in range(math.ceil(hyper_period / i_period)):
                        for beta in range(math.ceil(hyper_period / j_period)):
                            formula = Or(ik_offset + alpha * ik_period_scaled_to_macrotick >=
                                         jl_offset + beta * jl_period_scaled_to_macrotick +
                                         jl_trans_duration,
                                         jl_offset + beta * jl_period_scaled_to_macrotick >=
                                         ik_offset + alpha * ik_period_scaled_to_macrotick + ik_trans_duration)
                            constraint_formula_set.append(formula)

    # 3.flow transmission constraint
    for stream_instance_obj in stream_instance_obj_set:
        for i in range(len(stream_instance_obj) - 1):
            ax_link_id = stream_instance_obj[i].link_id
            xb_link_id = stream_instance_obj[i + 1].link_id
            xb_macrotick = link_obj_set[xb_link_id].macrotick
            ax_macrotick = link_obj_set[ax_link_id].macrotick
            # ax_propagation_delay = link_obj_set[ax_link_id].prop_delay
            xb_offset = stream_instance_obj[i + 1].offset
            ax_offset = stream_instance_obj[i].offset
            ax_trans_duration = stream_instance_obj[i].trans_duration_scaled_to_macrotick
            formula = (xb_offset * xb_macrotick -
                       sync_precision >=
                       (ax_offset + ax_trans_duration) * ax_macrotick)
            constraint_formula_set.append(formula)

    # 4. end-to-end constraint
    stream_id = 0
    for stream_instance_obj_set_per_stream in stream_instance_obj_set:
        latency_requirement = stream_obj_set[stream_id].latency_requirement
        src_offset = stream_instance_obj_set_per_stream[0].offset
        src_link_id = stream_instance_obj_set_per_stream[0].link_id
        src_macrotick = link_obj_set[src_link_id].macrotick
        dst_offset = stream_instance_obj_set_per_stream[-1].offset
        dst_link_id = stream_instance_obj_set_per_stream[-1].link_id
        dst_macrotick = link_obj_set[dst_link_id].macrotick
        trans_duration_scaled_to_macrotick = stream_instance_obj_set_per_stream[-1].trans_duration_scaled_to_macrotick

        formula = (src_macrotick * src_offset + latency_requirement >=
                   dst_macrotick * (dst_offset + trans_duration_scaled_to_macrotick))
        constraint_formula_set.append(formula)

        stream_id += 1

    # 6. Frame isolation constraint
    for link in link_obj_set:
        stream_set = link.stream_set
        link_id = link.link_id
        ab_macrotick = link_obj_set[link_id].macrotick
        # ab_prop_delay = link_obj_set[link_id].prop_delay
        for i in range(len(stream_set)):
            for j in range(len(stream_set)):
                if i != j:
                    i_stream_id = stream_set[i]['stream_id']
                    ik_ab_hop_id = stream_set[i]['hop_id']
                    j_stream_id = stream_set[j]['stream_id']
                    jl_ab_hop_id = stream_set[j]['hop_id']
                    if ik_ab_hop_id != 0 and jl_ab_hop_id != 0:

                        ik_xa_hop_id = stream_set[i]['hop_id'] - 1
                        jl_ya_hop_id = stream_set[j]['hop_id'] - 1

                        jl_ab_offset = stream_instance_obj_set[j_stream_id][jl_ab_hop_id].offset
                        jl_ya_offset = stream_instance_obj_set[j_stream_id][jl_ya_hop_id].offset

                        j_period = stream_obj_set[j_stream_id].period
                        i_period = stream_obj_set[i_stream_id].period

                        ik_xa_offset = stream_instance_obj_set[i_stream_id][ik_xa_hop_id].offset

                        ik_ab_offset = stream_instance_obj_set[i_stream_id][ik_ab_hop_id].offset

                        xa_link_id = stream_instance_obj_set[i_stream_id][ik_xa_hop_id].link_id
                        xa_macrotick = link_obj_set[xa_link_id].macrotick
                        # xa_prop_delay = link_obj_set[xa_link_id].prop_delay

                        ya_link_id = stream_instance_obj_set[j_stream_id][jl_ya_hop_id].link_id
                        ya_macrotick = link_obj_set[ya_link_id].macrotick
                        # ya_prop_delay = link_obj_set[ya_link_id].prop_delay

                        i_ab_prio = stream_instance_obj_set[i_stream_id][ik_ab_hop_id].prio
                        j_ab_prio = stream_instance_obj_set[j_stream_id][jl_ab_hop_id].prio

                        # formula = (Const(1, IntSort()) == 1)

                        formula = Bool('p')

                        for alpha in range(int(math.ceil(hyper_period / i_period))):
                            for beta in range(math.ceil(hyper_period / j_period)):
                                formula = And(formula,
                                              Or(
                                                  jl_ab_offset * ab_macrotick + beta * j_period
                                                  + sync_precision <=
                                                  ik_xa_offset * xa_macrotick +
                                                  alpha * i_period,
                                                  ik_ab_offset * ab_macrotick + alpha * i_period
                                                  + sync_precision <=
                                                  jl_ya_offset * ya_macrotick +
                                                  beta * j_period
                                              ))

                        formula = Or(formula,
                                     i_ab_prio != j_ab_prio)
                        # print(formula)
                        constraint_formula_set.append(formula)
                    else:
                        jl_ab_offset = stream_instance_obj_set[j_stream_id][jl_ab_hop_id].offset
                        j_period = stream_obj_set[j_stream_id].period
                        i_period = stream_obj_set[i_stream_id].period
                        ik_ab_offset = stream_instance_obj_set[i_stream_id][ik_ab_hop_id].offset
                        i_ab_prio = stream_instance_obj_set[i_stream_id][ik_ab_hop_id].prio
                        j_ab_prio = stream_instance_obj_set[j_stream_id][jl_ab_hop_id].prio
                        formula = Bool('p')

                        for alpha in range(int(math.ceil(hyper_period / i_period))):
                            for beta in range(math.ceil(hyper_period / j_period)):
                                formula = And(formula,
                                              Or(
                                                  jl_ab_offset * ab_macrotick + beta * j_period
                                                  + sync_precision <=
                                                  ik_ab_offset * ab_macrotick +
                                                  alpha * i_period,
                                                  ik_ab_offset * ab_macrotick + alpha * i_period
                                                  + sync_precision <=
                                                  jl_ab_offset * ab_macrotick +
                                                  beta * j_period
                                              ))
                        formula = Or(formula,
                                     i_ab_prio != j_ab_prio)

                        constraint_formula_set.append(formula)

    for stream_instance_set in stream_instance_obj_set:
        for stream_instance in stream_instance_set:
            link_id = stream_instance.link_id
            formula = (stream_instance.prio < link_obj_set[link_id].st_queues,
                       stream_instance.prio >= 0)
            constraint_formula_set.append(formula)

    return constraint_formula_set


def _main():
    (link_obj_set,
     stream_obj_set,
     stream_instance_obj_set) = init_topo_and_stream_obj_set_for_frame_demo('../topo_test', '../stream_test')

    construct_constraints_for_frame_demo(link_obj_set,
                                         stream_obj_set,
                                         stream_instance_obj_set,
                                         sync_precision=1)
    return


if __name__ == '__main__':
    _main()
