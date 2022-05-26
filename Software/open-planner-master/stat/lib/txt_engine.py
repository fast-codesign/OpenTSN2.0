# 读取window_demo的解文件
# 只需要读取每个窗口开和关的时刻
import re


def _transform_array_string_to_list(array):
    array = array.split("|")[2:-1]
    array = [item.split()[0] for item in array]
    cnt = 0
    for item in array:
        if item == 'n/a':
            array[cnt] = 0
        else:
            array[cnt] = int(item)
        cnt += 1
    return array


# 从window_demo解文件读取出所有窗口打开和关闭的时刻
def read_solution_from_window_demo_txt(filename):
    f = open(filename, "r", encoding='utf-8')
    data = f.readline()
    arrays_per_link = []
    while data:
        # 匹配data
        # 如果某行字符串是”arrays at link...“，
        # 那么该字符串向后的2、4、6行就是我们需要提取的
        # 开关窗口的时刻
        if re.match("arrays at link.", data):
            f.readline()  # 跳过index
            f.readline()  # 跳过分割线
            # 这一行是phi
            phi_array = f.readline()
            # phi_array = phi_array.split("|")[1:]
            phi_array = _transform_array_string_to_list(phi_array)
            f.readline()  # 跳过分割线
            tau_array = f.readline()
            # tau_array = tau_array.split("|")[1:]
            tau_array = _transform_array_string_to_list(tau_array)
            f.readline()  # 跳过分割线
            kappa_array = f.readline()
            # kappa_array = kappa_array.split("|")[1:]
            kappa_array = _transform_array_string_to_list(kappa_array)
            arrays_per_link.append({'phi_array': phi_array,
                                    'tau_array': tau_array})
        data = f.readline()
    f.close()

    # print(arrays_per_link)
    return arrays_per_link


# 从frame_demo的解文件中读取所有帧的发送时刻
# TODO:
# 后续将会在frame_demo的解文件中加入帧的长度，这样就能知道
# 帧发送开始和发送结束的时刻
def read_solution_from_frame_demo_txt(filename):
    point_in_time_per_link = []
    f = open(filename, "r", encoding='utf-8')
    data = f.readline()
    while data:
        offset_at_current_link = []
        # 匹配data
        # 如果某行字符串是”==...“
        # 那么从这行字符串开始，直到下一行”==...“
        # 之间的offset，是需要提取的内容
        while data and not re.match("=.", data):
            if re.search("offset:", data):
                # print(data)
                offset = data.split("=")[1].split()[0]
                offset = int(offset)
                offset_at_current_link.append(offset)
            data = f.readline()
        else:
            point_in_time_per_link.append(offset_at_current_link)
        data = f.readline()
    f.close()

    # print(point_in_time_per_link[1:])
    return point_in_time_per_link[1:]


def _main():
    read_solution_from_frame_demo_txt('../../log/solution_frame_demo')


if __name__ == '__main__':
    _main()
