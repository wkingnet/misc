"""
循环读取自定义雪球组合列表的组合名字、日收益、月收益、总收益，保存在DataFrame里。读取列表收益无需登录雪球。
由于雪球页面显示了日、月、总收益。因此本地不需要建立数据库文件。每日直接读取雪球页面即可获取数据，之后再本地排序加工。

现在使用BBSCODE复制到剪贴板并打开回复网页的方式。使用cookie自动回复帖子的代码理论没问题，但不知为何无法回复。

作者：wking [wking.net]
"""

import time
import datetime
import requests
import pyperclip
import webbrowser
from retry import retry
from bs4 import BeautifulSoup
import pandas as pd

# 要读取的组合ID
url_lists = ['ZH2399052',
             'ZH1396883',
             'ZH2398898',
             'ZH2907361',
             'ZH2418586',
             'ZH2186568',
             'ZH2017811',
             'ZH2542261',
             'ZH2580889',
             'zh2509688',
             'zh2577477',
             'ZH2404535',
             'ZH2463061',
             'ZH2888245',
             'ZH2580585',
             'ZH2403691',
             'ZH2302821',
             'ZH2626696',
             'ZH2626696',
             'ZH2485134',
             'zh2862916',
             'ZH2487283',
             'zh2414161',
             'Zh2564526',
             'ZH2541861',
             'ZH2406193',
             'ZH2506934',
             'ZH2475362',
             'zh2548709',
             'ZH2508102',
             'ZH2457307',
             'ZH2481474',
             'ZH2404545',
             'zh1039525',
             'ZH2506201',
             'ZH2506024',
             'ZH2205763',
             'ZH2480553',
             'ZH2423760',
             'ZH2500190',
             'zh2447269',
             'zh2380465',
             'zh2392428',
             'ZH2460579',
             'ZH2414244',
             'ZH2372490',
             'ZH2450588',
             'ZH2374072',
             'ZH2278426',
             'ZH2444269',
             'ZH2374929',
             'ZH2376010',
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

nga_cookies = '12345'

url_base = 'https://xueqiu.com/P/'
url_nga = 'https://bbs.nga.cn/post.php'
# NGA回复帖子的内容字典
nga_form = {
    'action': 'reply',  # 回复
    'fid': 706,  # 板块ID
    'tid': 23272091,  # 帖子ID
    # 'post_content': ,  # 帖子内容
    }

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


def read_xueqiu_to_df(_url_lists):
    """
    循环雪球组合列表获取组合信息，拼凑为DF格式
    :param _url_lists: 雪球组合列表
    :return: df_today
    """
    df_today = pd.DataFrame()
    starttime = time.time()
    for num, url_list in enumerate(_url_lists):
        url = url_base + url_list
        response_obj = getpage(url)
        zuhe_dict = {}
        # print(f'response_obj.text={response_obj.text}')  # print html content
        soup_obj = BeautifulSoup(response_obj.text, 'html.parser')
        zuhename = soup_obj.find('span', class_='name').get_text()
        zuheid = soup_obj.find('span', class_='symbol').get_text()
        username = soup_obj.find('div', class_='name').get_text()
        userid = soup_obj.find('a', class_="creator fn-clear").get('href')
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
        print(f'[{nowtime}] {num + 1:>2d}/{len(_url_lists)} 已用{round(time.time() - starttime, 2):>6.2f}秒'
              f' 组合ID={zuheid}')
    return df_today


def float_to_bbscode(df, column):
    """
    将DF实参列转换为object类型，每个具体数值乘以100，根据正负值加上BBSCODE代码，加上百分号
    :param df: 要转换的DataFrame对象
           columns:要转换的列
    :return: 转换过的DataFrame对象
    """
    df[column] = df[column].astype('object')  # 转换为object（字符串）类型
    for num, _value in enumerate(df[column]):
        if type(df.iat[num, df.columns.get_loc(column)]) == float:
            if _value > 0:
                df.iat[num, df.columns.get_loc(column)] = "[td][color=red]" + str(
                    round(_value * 100, 2)) + "%[/color][/td]"
            else:
                df.iat[num, df.columns.get_loc(column)] = "[td][color=green]" + str(
                    round(_value * 100, 2)) + "%[/color][/td]"
        elif type(df.iat[num, df.columns.get_loc(column)]) == str:
            df.iat[num, df.columns.get_loc(column)] = "[td]" + str(_value) + "[/td]"
    # df = df.rename(columns={column: '[td][B]' + column + '[/B][/td]'})  # 列名也添加
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
        df.iat[num, df.columns.get_loc(cvt_col)] = "[td][url=" + url + "]" + str(value) + "[/url][/td]"
    return df


if __name__ == '__main__':
    # 主程序

    # 读取雪球组合
    df = read_xueqiu_to_df(url_lists)

    df_sort = pd.DataFrame()

    # 生成收益率排行DF
    for i in ['日收益', '月收益', '总收益']:
        df_temp = df.sort_values(by=i, ascending=False)
        df_temp = float_to_bbscode(df_temp, i)
        df_temp = float_to_bbscode(df_temp, '雪球昵称')
        df_temp = link_to_bbscode(df_temp, '组合名', '组合ID')
        df_temp = df_temp.reset_index(drop=True)
        df_sort = pd.concat([df_sort, df_temp[['雪球昵称', '组合名', i]]], axis=1, ignore_index=True)

    post_content = '[table][tr][td]雪球昵称[/td][td]组合名[/td][td][B]日收益[/B][/td]' \
                   '[td]雪球昵称[/td][td]组合名[/td][td][B]月收益[/B][/td]' \
                   '[td]雪球昵称[/td][td]组合名[/td][td][B]总收益[/B][/td][/tr]'

    for row in df_sort.itertuples():
        post_content += '[tr]'
        for cell in row[1:]:
            post_content += cell
        post_content += '[/tr]'
    post_content += '[/table]'

    while True:
        # 复制到系统剪贴板
        pyperclip.copy(post_content)

        choose = input("BBSCODE已复制到剪贴板，输入r打开回复网页并退出，其他输入再次粘贴:")
        if choose == "r":
            webbrowser.open_new_tab("https://bbs.nga.cn/post.php?action=reply&_newui&fid=706&tid=23272091")
            exit()

    # 分割构造response可用的cookie
    cookie = {}
    for line in nga_cookies.split(';'):
        name, value = line.strip().split('=', 1)
        cookie[name] = value

    # 把构造好的帖子内容加入nga_form字典里
    nga_form['post_content'] = post_content

    # 提交帖子数据
    response = requests.post(url_nga, data=nga_form, headers=header, cookies=cookie)
    soup = BeautifulSoup(response.text, 'html.parser')
