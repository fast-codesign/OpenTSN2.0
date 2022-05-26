from matplotlib import rcParams
from lib.txt_engine import read_solution_from_window_demo_txt
import matplotlib.pyplot as plt


def _draw_schedule_porosity_fig(stat):
    config = {
        "font.family": 'serif',
        "font.size": 10,
        "mathtext.fontset": 'stix',
        "font.serif": ['Times New Roman'],
    }
    rcParams.update(config)

    # 柱子的宽度
    width = 0.3
    # 线条粗细
    line_width = 2
    # 坐标轴标题字体大小
    axis_font_size = 16
    # 标题字体大小
    title_font_size = 20
    # 图例字体大小
    legend_font_size = 16
    # bar的数据文字大小
    text_font_size = 15
    # marker大小
    marker_size = 9
    # 刻度大小
    tick_size = 16
    # 密度
    bins = 10000
    s = 20
    alpha = 0.4

    fig, ax1 = plt.subplots(figsize=[6.4, 4.8], dpi=200)

    for item in stat:
        ax1.scatter(
            item['x_axis'],
            item['y_axis'],
            # label='',
            s=5,
            c='olivedrab',
            marker='o',
            # size=5,
            alpha=0.9,
        )

    # 20000是调度周期的长度
    # ax1.set_ylim(0, 20000)

    ax1.set_xlabel(r'link id', size=axis_font_size)
    ax1.set_ylabel(r'point-in-time in schedule cycle', size=axis_font_size)

    x_tick_labels = ax1.get_xticklabels()
    [label.set_fontname('Times New Roman') for label in x_tick_labels]
    [label.set_fontsize(tick_size) for label in x_tick_labels]
    y_tick_labels = ax1.get_yticklabels()
    [label.set_fontname('Times New Roman') for label in y_tick_labels]
    [label.set_fontsize(tick_size) for label in y_tick_labels]

    ax1.set_title(
        r'window demo | gcl=32',
        fontsize=title_font_size
    )

    plt.tight_layout()
    plt.show()


# 把从文件读取出来的打开和关闭的时刻转化成
# 连续的点
def _transform_arrays_to_list(arrays_per_link):
    stat = []
    link_id = 0
    for array in arrays_per_link:
        array_to_list = []
        phi_array = array['phi_array']
        tau_array = array['tau_array']
        for phi, tau in zip(phi_array, tau_array):
            for time_in_point in range(phi, tau + 1):
                array_to_list.append(time_in_point)
        stat.append({'x_axis': [link_id] * len(array_to_list),
                     'y_axis': array_to_list})
        link_id += 1
    return stat


def main():
    # 1. 读取解文件
    #       1. 读取window-based的解文件 √
    #       2. 读取frame-based的解文件
    arrays_per_link = read_solution_from_window_demo_txt('../log/solution_window_demo')

    # 2. 处理arrays_per_link
    stat = _transform_arrays_to_list(arrays_per_link)

    # 3. 画出所有窗口（scatter）
    #    横坐标：链路索引
    #    纵坐标：位于窗口内的时刻
    _draw_schedule_porosity_fig(stat)


if __name__ == '__main__':
    main()
