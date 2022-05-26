import math


# 求所有流量的调度周期
def compute_hyper_period(*args):
    # period_set = []
    # for stream_obj in stream_obj_set:
    #     period_set.append(stream_obj.period)
    hyper_period = 1
    for period in args:
        hyper_period = int(period) * int(hyper_period) / math.gcd(int(period), int(hyper_period))
    return int(hyper_period)
