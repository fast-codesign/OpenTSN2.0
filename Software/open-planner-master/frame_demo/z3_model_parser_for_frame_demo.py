from z3 import *
import re


# 将所有流实例按照链路分类
# 分类后的declare_set的形式如下：
# declare_set = [ {'offset_set': [{'name': '', 'value': ''}, {'name': '', 'value': ''}],
#                    'prio_set': [{'name': '', 'value': ''}, {'name': '', 'value': ''}]},
#                    {}, {}
# ]
def _classify_declare_set(declare_set, link_num):
    tmp_declare_set = [{'offset_set': [], 'prio_set': []} for link_id in range(link_num)]

    # frame_demo的变量分为两类
    # 1. offset，命名：O_stream_id^(link_id)
    # 2. prio，命名：P_stream_id^(link_id)
    for declare in declare_set:
        name = declare['name']
        value = declare['value']
        value = str(value)

        if re.match(r'O.', name):
            # 解析link_id
            link_id = int(name.split('(')[1].split(')')[0])
            declare['value'] = int(value)
            tmp_declare_set[link_id]['offset_set'].append(declare)
        elif re.match(r'P.', name):
            # 解析link_id
            link_id = int(name.split('(')[1].split(')')[0])
            declare['value'] = int(value)
            tmp_declare_set[link_id]['prio_set'].append(declare)

    declare_set = tmp_declare_set

    # 重排列
    # offset与prio应当一一对应
    # 依次取出每条链路的offset_set和prio_set
    for declare_set_per_link in declare_set:
        offset_set = declare_set_per_link['offset_set']
        prio_set = declare_set_per_link['prio_set']
        tmp_prio_set = [''] * len(offset_set)

        for prio in prio_set:
            name = prio['name']
            # 提取出stream_id
            prio_stream_id = name.split('_')[1].split('^')[0]
            idx = 0
            for offset in offset_set:
                offset_stream_id = offset['name'].split('_')[1].split('^')[0]
                if prio_stream_id == offset_stream_id:
                    break
                idx += 1
            # print(idx)
            tmp_prio_set[idx] = prio

        declare_set_per_link['prio_set'] = tmp_prio_set
    return declare_set


def _sort_declare_set(declare_set):
    # print(declare_set)
    for declare in declare_set:
        offset_set = declare['offset_set']
        prio_set = declare['prio_set']
        if offset_set and prio_set:
            # print(offset_set)
            # print(prio_set)
            zipped_set = zip(offset_set, prio_set)
            # print(zipped_set)
            sorted_zipped_set = sorted(zipped_set, key=lambda tmp: (tmp[0]['value'], tmp[1]['value']))
            sorted_set = zip(*sorted_zipped_set)
            # print(sorted_set)
            # for x in sorted_set:
            #     print(list(x))
            declare['offset_set'], declare['prio_set'] = [list(x) for x in sorted_set]
    # print(declare_set)
    return declare_set


def _format_offset_set_and_prio_set(f, declare, width):
    offset_set = declare['offset_set']
    prio_set = declare['prio_set']

    f.write('-' * (width - 1) + '|' + '\n')
    for offset, prio in zip(offset_set, prio_set):
        f.write('{:>15}{:^20}{}{:^15}{}\n'.format('offset:', offset['name'], '=', offset['value'], '|'))
        f.write('{:>15}{:^20}{}{:^15}{}\n'.format('prio_queues:', prio['name'], '=', prio['value'], '|'))
        f.write('-' * (width - 1) + '|' + '\n')


def _write_time_used_to_txt(f, time_used_in_second):
    divider = '+' * 80
    f.write('%s\n' % divider)
    f.write('time used:\n')
    f.write("%s s\n" % time_used_in_second)
    f.write("%s min\n" % (time_used_in_second / 60))
    return


def write_declare_set_to_txt(result_set,
                             link_obj_set,
                             solution_txt
                             ):
    time_used_in_second = result_set['time_used_in_second']
    sat_or_not = result_set['sat_or_not']
    z3_declare_set = result_set['declare_set']
    unknown_reason = result_set['unknown_reason']

    width = 52

    f = open(solution_txt, 'w')

    # 如果有可行解
    if sat_or_not == 'sat':

        z3_declare_set = _classify_declare_set(z3_declare_set, len(link_obj_set))

        sorted_declare_set = _sort_declare_set(z3_declare_set)

        link_id = 0
        for declare in sorted_declare_set:
            src_node_id = link_obj_set[link_id].src_node
            dst_node_id = link_obj_set[link_id].dst_node

            divider_between_link_str = '=' * width
            f.write("%s\n" % divider_between_link_str)

            src_to_dst = '(%d, %d)' % (src_node_id, dst_node_id)
            f.write('offset and prio set at link %s, link_id: %d\n' % (src_to_dst, link_id))

            '''打印这条链路上所有的offset和prio'''
            _format_offset_set_and_prio_set(f, declare, width)

            f.write('\n')

            link_id += 1
    elif sat_or_not == 'unsat':
        f.write('unsat\n')
    elif sat_or_not == 'unknown':
        f.write('unknown\n')
        # 写入原因
        f.write('the reason for unknown result: %s\n' % unknown_reason)

    # 将求解时间写入文件
    _write_time_used_to_txt(f, time_used_in_second)

    f.close()


def _main():
    return


if __name__ == '__main__':
    _main()
