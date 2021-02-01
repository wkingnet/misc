"""
循环读取自定义雪球组合列表的组合名字、日收益、月收益、总收益，保存在DataFrame里。读取列表收益无需登录雪球。
由于雪球页面显示了日、月、总收益。因此本地不需要建立数据库文件。每日直接读取雪球页面即可获取数据，之后再本地排序加工。

作者：wking [wking.net]
"""

import os
import time
import datetime
import requests
import openpyxl
from retry import retry
from bs4 import BeautifulSoup
import pandas as pd

# 要读取的组合ID
url_lists = ['ZH2399052',
             'ZH1396883',
             'ZH2398898',
             'ZH2418586',
             'ZH2414244',
             'ZH2372490',
             'ZH2342455',
             'ZH2424429',
             'ZH2381174',
             'ZH2381185',
             'ZH2400703',
             'ZH1377246',
             'ZH2223562',
             'ZH2346130',
             'ZH2408102',
             'ZH2365623',
             'ZH2403691',
             'ZH2374057',
             'ZH2382196',
             'ZH2303396',
             'ZH2372792',
             'ZH2339665',
             'ZH2373479',
             'ZH2368023',
             'ZH2365407',
             'ZH2345231',
             'ZH2326519',
             'ZH2326537',
             'ZH2339224',
             'ZH2241084',
             'ZH2325187',
             'ZH2353533',
             'ZH2351188',
             'ZH2308758',
             'ZH2340722',
             'ZH2339225',
             'ZH2285554',
             'ZH2340735',
             'ZH2339132',
             'ZH2340639',
             'ZH2318626',
             'ZH2312362',
             'ZH2222197',
             'ZH2314977',
             'ZH2255031',
             'ZH2315177',
             'ZH2254555',
             'ZH2252559',
             'ZH2246116',
             'ZH2286904',
             'ZH2303543',
             'ZH2276271',
             'ZH2295461',
             'ZH2212240',
             'ZH1215018',
             'ZH2276217',
             'ZH2220066',
             'ZH2236636',
             'ZH2217838',
             'ZH2202084',
             'ZH2206566',
             'ZH2288900',
             'ZH2262394',
             'ZH2297522',
             'ZH2209411',
             'ZH2210521',
             'ZH2247841',
             'ZH2246573',
             'ZH2297263',
             'ZH2254517',
             'ZH2297237',
             'ZH2240558',
             'ZH2218156',
             'ZH2250739',
             'ZH2268610',
             'ZH2232730',
             'ZH2254990',
             'ZH2219921',
             'ZH2210854',
             'ZH2213726',
             'ZH2202768',
             'ZH2167050',
             'ZH2215795',
             'ZH2239426',
             'ZH2201867',
             'ZH2214821',
             'ZH2218858',
             ]

url_base = 'https://xueqiu.com/P/'
DataFrame_file = 'DataFrame数据库.csv'  # 全量DataFrame数据库保存文件名
xlsx_file = 'NGA_today.xlsx'  # 每日生成的xlsx文件名
today_date = datetime.date.today()
header = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
                  'Chrome/87.0.4280.141',
}


# 函数部分
@retry(delay=3)  # 无限重试装饰性函数，3秒为雪球最佳重试间隔
def getpage(url):
    """
    使用request.get获取雪球组合详细页面HTML代码
    :param url:雪球组合URL
    :return: request.get实例化对象
    """
    response_obj = requests.get(url, headers=header, timeout=5)  # get方式请求
    response_obj.raise_for_status()  # 检测异常方法。如有异常则抛出，触发retry
    return response_obj


def read_xueqiu_to_df(url_lists):
    """
    循环雪球组合列表获取组合信息，拼凑为DF格式
    :param url_lists: 雪球组合列表
    :return: df_today
    """
    df_today = pd.DataFrame()
    starttime = time.time()
    for num, url_list in enumerate(url_lists):
        url = url_base + url_list
        response_obj = getpage(url)
        zuhe_dict = {}
        # print(f'response_obj.text={response_obj.text}')  # print html content
        soup_obj = BeautifulSoup(response_obj.text, 'html.parser')
        zuhename = soup_obj.find('span', class_='name').get_text()
        zuheid = soup_obj.find('span', class_='symbol').get_text()
        username = soup_obj.find('div', class_='name').get_text()
        userid = soup_obj.find('a', class_="creator fn-clear").get('href')
        zuhe_dict['date'] = today_date
        zuhe_dict['昵称ID'] = userid[1:]
        zuhe_dict['雪球昵称'] = username
        zuhe_dict['组合ID'] = zuheid
        zuhe_dict['组合名'] = zuhename
        a = []
        for tag in soup_obj.find_all('div', class_='per'):  # 提取所有<div class=per>
            a.append(tag.get_text())
        a[0] = round(float(a[0][:-1]) / 100, 4)  # 日涨跌幅，原始为-2.42%形式，去百分比换算为浮点数
        a[1] = round(float(a[1][:-1]) / 100, 4)  # 月涨跌幅，原始为-2.42%形式，去百分比换算为浮点数
        a[2] = round(float(a[2]) - 1, 4)  # 总净值，原始为1.0963形式，减1后换算为浮点数
        zuhe_dict['日收益'] = a[0]
        zuhe_dict['月收益'] = a[1]
        zuhe_dict['总收益'] = a[2]
        # print(zuhe_dict)
        df_url = pd.DataFrame.from_dict(zuhe_dict, orient='index').T
        nowtime = time.strftime("%H:%M:%S", time.localtime())
        df_today = df_today.append(df_url, ignore_index=True)
        print(f'[{nowtime}] {num + 1:>2d}/{len(url_lists)} 已用{round(time.time() - starttime, 2):>6.2f}秒'
              f' 组合ID={zuheid}')
    print(df_today)
    return df_today


# 文件保存
def file_save_to_csv(DataFrame_file, df_today):
    """
    保存到CSV文件
    :param DataFrame_file: 已有、要被附加DF格式的文件
    :param df_today:  今日数据，要附加到DataFrame_file的DataFrame对象
    :return: none
    """
    if not os.path.isfile(DataFrame_file):  # 如果本地不存在CSV文件则创建
        df_today.to_csv(DataFrame_file, encoding='gbk')
    else:
        df = pd.read_csv(DataFrame_file, index_col=0, encoding='gbk')
        df = df.append(df_today, ignore_index=True)
        df.to_csv(DataFrame_file, encoding='gbk')


def file_backup(DataFrame_file):
    """
    备份文件另存为“当前年月日-时分秒.csv”格式
    :param DataFrame_file:
    :return: none
    """
    nowdate = time.strftime("%Y%m%d-%H%M%S", time.localtime())
    os.popen('copy ' + DataFrame_file + ' ' + DataFrame_file[:-4] + '-' + nowdate + '.csv')


def float_to_bbscode(df, column):
    """
    将DF实参列转换为object类型，每个具体数值乘以100，根据正负值加上BBSCODE代码，加上百分号
    :param df: 要转换的DataFrame对象
           columns:要转换的列
    :return: 转换过的DataFrame对象
    """
    df[column] = round(df[column] * 100, 2)
    df[column] = df[column].astype('object')  # 转换为object（字符串）类型
    for num, value in enumerate(df[column]):
        if type(df.iat[num, df.columns.get_loc(column)]) == float:
            if value > 0:
                df.iat[num, df.columns.get_loc(column)] = "[color=red]" + str(value) + "%[/color]"
            else:
                df.iat[num, df.columns.get_loc(column)] = "[color=green]" + str(value) + "%[/color]"
    df = df.rename(columns={column: '[B]' + column + '[/B]'})  # 列名也添加
    return df

def link_to_bbscode(df, cvt_col, link_col):
    """
    转换DF列为BBSCODE链接形式
    :param df: 要转换的DF对象
    :param cvt_col: 要转换的列
    :param link_col: 链接来源列
    :return: 转换后的DF对象
    """
    df[cvt_col] = df[cvt_col].astype('object')  # 转换为object（字符串）类型

    for num, value in enumerate(df[cvt_col]):
        url_base = "https://xueqiu.com/"
        url_link = df.iat[num, df.columns.get_loc(link_col)]
        if 'ZH' in url_link:  # 如果是组合的链接，改一下URL链接样式
            url_base = url_base + "P/"
        url = url_base + url_link  # 最终形成的URL
        df.iat[num, df.columns.get_loc(cvt_col)] = "[url=" + url + "]" + str(value) + "[/url]"
    return df


# 主程序
#file_backup(DataFrame_file)  # 不需要备份了

#choose = input("输入 y 更新当日数据，其他输入跳过: ")
if True:
    # 如果已存在DataFrame_file则删除
	if os.path.exists(DataFrame_file):
	    os.remove(DataFrame_file)
	df_today = read_xueqiu_to_df(url_lists)
	file_save_to_csv(DataFrame_file, df_today)  # 附加今日数据到数据库文件
#choose = input("输入 任意键 开始处理当日数据: ")

# 如果已存在NGA_today.xlsx则删除
if os.path.exists(xlsx_file):
    os.remove(xlsx_file)

# 创建空白xlsx，只有名字是sheet的一个工作表
wb = openpyxl.Workbook()
wb.save(xlsx_file)

# df.loc[(df['date']=='2021-01-15') & (df['total'] < 1)].sort_values(by=['total'],ascending=False)
# 常规用法：读取 date列的值为2021-01-15 且 total列的值 <1 的所有行，按total列的值降序排列。
# 不能用在已把date设置成index的DF上

df = pd.read_csv(DataFrame_file, index_col=0, encoding='gbk')
df['date'] = pd.to_datetime(df['date'])  # 读取文件后date变为字符串类型。重新转换为date类型
df = df.set_index('date')  # 将 date 设置为index
# 确保(type(df.index)是pandas.core.indexes.datetimes.DatetimeIndex，即可使用日期直接筛选
# 获取具体某天的数据，用datafrme直接选取某天时会报错，而series的数据就没有问题 df['2013-11-06']
# 可以考虑用区间来获取某天的数据 df['2013-11-06':'2013-11-06']
# df['2021-01-16':'2021-01-16'].sort_values(by=['total'], ascending=False)

# 下面代码段可实现日月总全变色。但为了在论坛醒目查看，不这么处理
# for for1 in ['day', 'month', 'total']:
#     df = df[today_date:today_date].sort_values(by=for1, ascending=False)
#     for for2 in ['day', 'month', 'total']:
#         df = df_add_bbscodecolor(df, for2)
#     df.to_csv('NGA_'+for1+'.csv', encoding='gbk', INDEX=False)
#     print(f'NGA_{for1}.csv 已更新保存')

# 下面代码段可实现只有排序的列变色
start_col = 0
with pd.ExcelWriter(xlsx_file, mode='a') as writer:
    for for1 in ['日收益', '月收益', '总收益']:
        df_sort = df[today_date:today_date].sort_values(by=for1, ascending=False)
        df_sort = float_to_bbscode(df_sort, for1)
        df_sort = link_to_bbscode(df_sort, '组合名', '组合ID')
        df_sort = link_to_bbscode(df_sort, '雪球昵称', '昵称ID')
        df_sort.to_excel(writer, sheet_name='Sheet1', columns=['雪球昵称', '组合名', '[B]' + for1 + '[/B]'],
                         index=False, startcol=start_col)
        start_col += 5
        print(f'{for1} 保存完成')

# 由于df保存到excel会因为未知问题，自动新建sheet1保存，因此再手动删除空白的sheet
wb = openpyxl.load_workbook(xlsx_file)
ws = wb["Sheet"]  # 删除空白的sheet
wb.remove(ws)
wb.save(xlsx_file)

os.popen(xlsx_file)  # 调用系统管道打开今天的xlsx文件
print('全部完成，自动打开xlsx，程序退出')
