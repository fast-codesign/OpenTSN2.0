import time

from z3 import *


def _parse_z3_model(model):
    solution = []
    for declare in model.decls():
        name = declare.name()
        value = model[declare]
        solution.append({'name': name, 'value': value})
    return solution


# 传入的timeout的单位是ms
def add_and_solve_constraints(constraint_set,
                              timeout=-1):
    start = 0
    end = 0
    s = Solver()
    if timeout > 0:
        s.set(timeout=timeout)

    for constraint in constraint_set:
        s.add(constraint)

    declare_set = []
    unknown_reason = ''
    # 开始计时
    start = time.time_ns()
    # 判断是否有可行解
    sat_or_not = s.check()
    if sat_or_not == sat:
        model = s.model()
        end = time.time_ns()
        print("end time: %f" % end)
        # 输出变量声明的集合
        declare_set = _parse_z3_model(model)
    elif sat_or_not == unsat:
        # 输出时间
        end = time.time_ns()
        # 输出一个空的declare_set
    elif sat_or_not == unknown:
        end = time.time_ns()
        # 输出一个空的declare_set
        # 输出unknown的原因
        unknown_reason = s.reason_unknown()
        pass

    time_used_in_second = (end - start) / 1000000000

    print('time_used:')
    print(time_used_in_second)

    # 返回time_used_in_second、sat_or_not、
    # declare_set、(unknown reason)
    return {'time_used_in_second': time_used_in_second, 'sat_or_not': str(sat_or_not),
            'declare_set': declare_set, 'unknown_reason': unknown_reason}


def _main():
    return


if __name__ == '__main__':
    _main()
