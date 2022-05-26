from matplotlib import pyplot as plt, rcParams

from lib.txt_engine import read_solution_from_frame_demo_txt


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
        r'frame demo | macrotick=1',
        fontsize=title_font_size
    )

    plt.tight_layout()
    plt.show()


def _transform_offset_into_trans_duration(offsets_per_link):
    stat = []
    link_id = 0
    for offsets in offsets_per_link:
        stat_per_link = []
        for offset in offsets:
            for point_in_time in range(offset, offset + 13):
                # +13是因为当前配置中，所有报文大小均为1518字节
                stat_per_link.append(point_in_time)
        stat.append({'x_axis': [link_id] * len(stat_per_link),
                     'y_axis': stat_per_link})
        link_id += 1
    return stat


def main():
    # 1. 读取解文件
    offsets_per_link = read_solution_from_frame_demo_txt('../log/solution_macrotick_1_stream_50')
    # 2. 处理offsets_per_link
    #    TODO:
    #    在frame_demo的解文件中加入报文长度，
    #    这样才能画出一个数据帧占用的时间段。
    #    目前只知道开始传输的时刻，不知道传输结束的时刻
    stat = _transform_offset_into_trans_duration(offsets_per_link)
    # print(stat)
    # 3. 画出所有窗口（scatter）
    #    横坐标：链路索引
    #    纵坐标：位于窗口内的时刻
    _draw_schedule_porosity_fig(stat)
    return


if __name__ == '__main__':
    main()
