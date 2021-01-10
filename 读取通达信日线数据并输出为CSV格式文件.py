#!/usr/bin/python
# -*- coding: UTF-8 -*-
"""
在网络读取通达信代码上修改加工，增加、完善了一些功能
1、增加了读取深市股票功能。
2、增加了在已有数据的基础上追加最新数据，而非完全删除重灌。
3、增加了读取上证指数、沪深300指数功能。
4、过滤了无关的债券指数、板块指数等，只读取沪市、深市A股股票。

作者：wking [http://wkings.net]
"""
import os
import time
from struct import unpack
from decimal import Decimal  #用于浮点数四舍五入
 
source = 'd:/stock/通达信'   #指定通达信目录
target = 'd:/日线数据'  #指定数据保存目录
target_index = 'd:/日线数据/指数'  #指定数据保存目录
debug = 1   #是否开启调试日志输出  1开 0关
used_time = {}  #创建一个计时字典

# debug输出函数
def user_debug(print_str,print_value):
    """第一个参数为变量名称，第二个参数为变量的值"""
    if debug == 1:
        print(str(print_str) + ' = ' + str(print_value))


# 将通达信的日线文件转换成CSV格式函数。通达信数据文件32字节为一组。
def day2csv(source_dir, file_name, target_dir):
    """通达信数据文件转换为CSV格式函数"""

    # 以二进制方式打开源文件
    source_path = source_dir + os.sep + file_name  #源文件包含文件名的路径
    source_file = open(source_path, 'rb')
    buf = source_file.read()  #读取源文件保存在变量中
    source_file.close()
    source_size = os.path.getsize(source_path)   #获取源文件大小
    user_debug('源文件行数', int(source_size/32))

    # 打开目标文件，后缀名为CSV
    target_path = target_dir + os.sep + file_name[2:-4] + '.csv'  #目标文件包含文件名的路径
    #user_debug('target_path', target_path)
    
    if not os.path.isfile(target_path):
        #目标文件不存在。写入表头行。begin从0开始转换
        target_file = open(target_path, 'w', encoding="utf-8")  #以覆盖写模式打开文件
        header = str('date') + ', ' + str('open') + ', ' + str('high') + ', ' + str('low') + ', ' \
        + str('close') + ', ' + str('amount') + ', ' + str('vol') +  ', ' \
        + str('单位元、成交量股')
        target_file.write(header)
        begin = 0
        end = begin + 32
    else:
        # 不为0，文件有内容。行附加。
        # 通达信数据32字节为一组，因此通达信文件大小除以32可算出通达信文件有多少行（也就是多少天）的数据。
        # 再用readlines计算出目标文件已有多少行（目标文件多了首行标题行），(行数-1)*32 即begin要开始的字节位置
        
        target_file = open(target_path, 'a+', encoding="utf-8")  #以追加读写模式打开文件
        #target_size = os.path.getsize(target_path)  #获取目标文件大小

        # 由于文件指针在文件的结尾，需要先把指针改到文件开头，读取文件行数。
        user_debug('当前指针', target_file.tell())
        target_file.seek(0,0)  #文件指针移到文件头
        user_debug('移动指针到开头', target_file.seek(0,0))
        row_number = len(target_file.readlines())  #获得文件行数
        user_debug('文件总行数', row_number)
        target_file.seek(0,2)  #文件指针移到文件尾
        user_debug('移动指针到末尾', target_file.seek(0,2))

        if row_number == 0:  #如果文件出错是0的特殊情况
            begin = 0
        else:
            begin = (row_number - 1) * 32

        end = begin + 32
        print('追加模式，从' + str(row_number + 1) + '行开始')

    while begin<source_size:
        # 将字节流转换成Python数据格式
        # I: unsigned int
        # f: float
        #a[5]浮点类型的成交金额，使用decimal类四舍五入为整数
        a = unpack('IIIIIfII', buf[begin:end])       
        line = '\n' + str(a[0]) + ', ' + str(a[1] / 100.0) + ', ' + str(a[2] / 100.0) + ', ' \
            + str(a[3] / 100.0) + ', ' + str(a[4] / 100.0) + ', ' \
            + str(Decimal(a[5]).quantize(Decimal("1."), rounding = "ROUND_HALF_UP")) + ', ' \
            + str(a[6])
        target_file.write(line)
        begin += 32
        end += 32
    target_file.close()

#判断目录和文件是否存在，存在则直接删除
if os.path.exists(target) or os.path.exists(target_index):
    choose = input("文件已存在，输入 y 删除现有文件并重新生成完整数据，其他输入则附加最新日期数据: ")
    if choose == 'y':
        for root, dirs, files in os.walk(target, topdown=False):
            for name in files:
                os.remove(os.path.join(root,name))
            for name in dirs:
                os.rmdir(os.path.join(root,name))
        for root, dirs, files in os.walk(target_index, topdown=False):
            for name in files:
                os.remove(os.path.join(root,name))
            for name in dirs:
                os.rmdir(os.path.join(root,name))
        try:
            os.mkdir(target)
        except FileExistsError:
            pass
        try:
            os.mkdir(target_index)
        except  FileExistsError:
            pass
else:
    os.mkdir(target)
    os.mkdir(target_index)

#处理沪市股票
file_list = os.listdir(source + '/vipdoc/sh/lday')
used_time['sh_begintime'] = time.time()
for f in file_list:
    #处理沪市sh6开头和sh000300(沪深300指数)文件，否则跳过此次循环
    if f[0:3] == 'sh6' or f[0:8] == 'sh000300':
        print(time.strftime("[%H:%M:%S] 处理 ", time.localtime()) + f)
        day2csv(source + '/vipdoc/sh/lday', f, target)
    else:
        continue
used_time['sh_endtime'] = time.time()

#处理深市股票
file_list = os.listdir(source + '/vipdoc/sz/lday')
used_time['sz_begintime'] = time.time()
for f in file_list:
    if f[0:4] == 'sz00' or f[0:4] == 'sz30':    #处理深市sh00开头和创业板sh30文件，否则跳过此次循环
        print(time.strftime("[%H:%M:%S] 处理 ", time.localtime()) + f)
        day2csv(source + '/vipdoc/sz/lday', f, target)
    else:
        continue
used_time['sz_endtime'] = time.time()

#处理指数文件
file_list = os.listdir(source + '/vipdoc/sh/lday')
used_time['index_begintime'] = time.time()
for f in file_list:
    #处理sh999999（上证指数文件）和sh000300(沪深300指数)文件，否则跳过此次循环
    if f[0:8] == 'sh999999' or f[0:8] == 'sh000300':
        print(time.strftime("[%H:%M:%S] 处理 ", time.localtime()) + f)
        day2csv(source + '/vipdoc/sh/lday', f, target_index)
    else:
        continue
used_time['index_endtime'] = time.time()

print('沪市处理完毕，用时' + str(int(used_time['sh_endtime']-used_time['sh_begintime'])) + '秒')
print('深市处理完毕，用时' + str(int(used_time['sz_endtime']-used_time['sz_begintime'])) + '秒')
print('指数文件处理完毕，用时' + str(int(used_time['index_endtime']-used_time['index_begintime'])) + '秒')