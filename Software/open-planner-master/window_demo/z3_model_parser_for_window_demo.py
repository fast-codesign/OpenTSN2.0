from z3 import *
import re


def _classify_declare_set(declare_set, total_link_num):
    tmp_declare_set = [{'phi_array': {'name': '', 'value': ''},
                        'tau_array': {'name': '', 'value': ''},
                        'kappa_array': {'name': '', 'value': ''},
                        'omega_set': []}
                       for i in range(total_link_num)]

    # window_demo的变量分为四类
    # 1. phi_array，命名：P^(link_id)
    # 2. tau_array（还包括两个中间变量tau_0_array，tau_1_array），命名：T^(link_id)
    # 3. kappa_array，命名：K^(link_id)
    # 4. omega，命名：O_stream_id,instance_id^(link_id)
    for declare in declare_set:
        name = declare['name']
        value = declare['value']
        # 解析link_id
        link_id = int(name.split('(')[1].split(')')[0])
        if re.match(r'P\^.', name):
            tmp_declare_set[link_id]['phi_array'] = declare
        elif re.match(r'T\^.', name):
            tmp_declare_set[link_id]['tau_array'] = declare
        elif re.match(r'K\^.', name):
            tmp_declare_set[link_id]['kappa_array'] = declare
        elif re.match(r'O_.', name):
            tmp_declare_set[link_id]['omega_set'].append(declare)
    # print(tmp_declare_set)
    return tmp_declare_set


# 将z3 Array变量转化成可读的列表
# 注意：只转化那些有“有意义”的值，“有意义”是指
# 该位置（index）有数据帧的omega对应
def _transform_z3_array_to_list(array, gcl_len, omega_set):
    # 提取出omega_set的值
    # print(omega_set)
    omega_set = [omega['value'] for omega in omega_set]
    # print(omega_set)
    array_to_list = ['n/a'] * gcl_len
    for i in range(gcl_len):
        if str(i) in omega_set:
            value = str(simplify(array[i]))
            array_to_list[i] = value
    return array_to_list


# 将declare_set中的z3变量（Array和Int）转化成
# “可读”的值
def _transform_z3_declare_set_to_readable_declare_set(declare_set,
                                                      link_obj_set):
    link_id = 0
    for declare in declare_set:
        omega_set = declare['omega_set']
        gcl_len = link_obj_set[link_id].gcl_len

        # 如果某条链路没有ST流经过
        # 那么该链路的未知量就不会被添加到z3
        # 因此z3不会输出该链路的未知数
        if not omega_set:
            for array_name in ['phi_array', 'tau_array', 'kappa_array']:
                declare[array_name]['value'] = ['n/a'] * gcl_len
        # 如果某条链路有ST流经过
        elif omega_set:
            for array_name in ['phi_array', 'tau_array', 'kappa_array']:
                array = declare[array_name]['value']
                array_to_list = _transform_z3_array_to_list(array, gcl_len, omega_set)
                declare[array_name]['value'] = array_to_list
            declare['omega_set'] = _sort_z3_int_ref(omega_set)
        link_id += 1
    # print(declare_set)
    return declare_set


# 将omega的值按照大小进行排序
def _sort_z3_int_ref(omega_set):
    # 将omega的值由IntSort转化成字符串
    for omega in omega_set:
        omega['value'] = str(omega['value'])
    # 按照omega的值的大小，将经过某条链路的omega进行排序
    omega_set.sort(key=lambda x: x['value'])
    return omega_set


# 打印表头和phi、tau、kappa的值
def _format_table_header_or_array(fd, name, array, width):
    # width = 9
    length = len(array)
    format_list = ['|', name, '|']
    for item in array:
        format_list.append(str(item))
        format_list.append('|')

    format_str = "{0[0]}{0[1]:^%d}{0[2]}" % width
    index = 3
    for i in range(length):
        format_str = format_str + "{0[%d]:^%d}{0[%d]}" % (index, width, index + 1)
        index += 2

    fd.write(format_str.format(format_list))
    fd.write('\n')

    divider = '|' + '-' * width + '|'
    for i in range(length):
        divider = divider + '-' * width + '|'

    fd.write(divider)
    fd.write('\n')


# 将array的值写入文本文档
def _write_arrays_to_txt(fd, phi_array, tau_array, kappa_array, width):
    # 先打印表头
    table_len = len(phi_array['value'])
    name = 'INDEX'
    value = range(table_len)
    _format_table_header_or_array(fd, name, value, width)
    # 然后依次打印phi tau和kappa
    # name = phi_array['name']
    name = 'phi'
    value = phi_array['value']
    _format_table_header_or_array(fd, name, value, width)
    # name = tau_array['name']
    name = 'tau'
    value = tau_array['value']
    _format_table_header_or_array(fd, name, value, width)
    # name = kappa_array['name']
    name = 'kappa'
    value = kappa_array['value']
    _format_table_header_or_array(fd, name, value, width)


# 打印omega
def _write_omega_to_txt(f, omega_set, gcl_len, width):
    width = width + 6
    f.write('stream\'s window index as follow:\n')
    divider_between_array_and_int_str = '-' * (3 * (width+1) + 1)
    f.write("%s\n" % divider_between_array_and_int_str)

    # 打印表头
    format_str = '{}{:^%d}{}{:^%d}{}{:^%d}{}' % (width, width, width)
    f.write(format_str.format('|', 'stream_id', '|', 'instance_id', '|', 'omega', '|'))
    f.write('\n')
    f.write(format_str.format('|', '-' * width, '|', '-' * width, '|', '-' * width, '|'))
    f.write('\n')

    for omega in omega_set:
        name = omega['name']
        # print(name)
        value = omega['value']
        # omega的命名规则
        # omega，命名：O_stream_id,instance_id^(link_id)
        stream_id = name.split('_')[1].split(',')[0]
        instance_id = name.split(',')[1].split('^')[0]
        f.write(format_str.format('|', stream_id, '|', instance_id, '|', value, '|'))
        f.write('\n')
        f.write(format_str.format('|', '-' * width, '|', '-' * width, '|', '-' * width, '|'))
        f.write('\n')

    f.write("%s\n" % divider_between_array_and_int_str)


def _write_time_used_to_txt(f, time_used_in_second):
    divider = '+' * 80
    f.write('%s\n' % divider)
    f.write('time used:\n')
    f.write("%s s\n" % time_used_in_second)
    f.write("%s min\n" % (time_used_in_second / 60))
    return


# 将z3的解写入解文件
def write_declare_set_to_txt(result_set,
                             link_obj_set,
                             solution_txt):
    time_used_in_second = result_set['time_used_in_second']
    sat_or_not = result_set['sat_or_not']
    z3_declare_set = result_set['declare_set']
    unknown_reason = result_set['unknown_reason']

    f = open(solution_txt, 'w')

    # 如果有可行解
    if sat_or_not == 'sat':
        width = 9

        z3_declare_set = _classify_declare_set(z3_declare_set, len(link_obj_set))

        readable_declare_set = _transform_z3_declare_set_to_readable_declare_set(z3_declare_set, link_obj_set)

        link_id = 0
        for declare in readable_declare_set:
            gcl_len = link_obj_set[link_id].gcl_len
            src_node_id = link_obj_set[link_id].src_node
            dst_node_id = link_obj_set[link_id].dst_node

            divider_between_link_str = '=' * ((gcl_len+1) * (width+1) + 1)
            f.write("%s\n" % divider_between_link_str)

            src_to_dst = '(%d, %d)' % (src_node_id, dst_node_id)
            f.write('arrays at link %s, link_id: %d\n' % (src_to_dst, link_id))

            '''打印链路上的phi、tau、kappa'''
            _write_arrays_to_txt(f,
                                 declare['phi_array'],
                                 declare['tau_array'],
                                 declare['kappa_array'],
                                 width)

            '''打印该链路上的所有omega'''
            omega_set = declare['omega_set']
            _write_omega_to_txt(f, omega_set, gcl_len, width)

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
