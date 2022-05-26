# 将网络拓扑或流写入文本文件
def write_topo_or_stream_to_txt(filename,
                                topo_or_stream_set):
    with open(filename, 'w') as f:
        for link in topo_or_stream_set:
            for attr in link:
                if type(link[attr]) is list:
                    for i in range(len(link[attr])):
                        link[attr][i] = str(link[attr][i])
                    link[attr] = ' '.join(link[attr])
                f.write('%s:%s\n' % (attr, link[attr]))
            if link != topo_or_stream_set[-1]:
                f.write('\n')


# 从网络拓扑文本或流文本读取链路信息
def read_topo_or_streams_from_txt(filename):
    topo_or_stream_set = []
    with open(filename, 'r') as f:
        data = f.readline()
        item = {}
        while data:
            if data == '\n':
                topo_or_stream_set.append(item)
                item = {}
            if data != '\n':
                key = data.split(':')[0]
                value = data.split(':')[1].split()
                if len(value) == 1:
                    value = int(value[0])
                else:   # 如果这条表项是路由路径
                    value = [int(i) for i in value]
                item[key] = value
            data = f.readline()
        # 还要将最后一条流或拓扑加入到topo_or_stream_set
        else:
            if item:
                topo_or_stream_set.append(item)
    return topo_or_stream_set


# 将z3的解写入文本文件
# frame


# 将z3的解写入文本文件
# window


def _main():
    topo_set = read_topo_or_streams_from_txt('../stream_test')
    print(topo_set)


if __name__ == '__main__':
    _main()
