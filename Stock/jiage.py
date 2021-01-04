﻿import baostock as bs
import pandas as pd
import fileinput
i=1
with fileinput.input(files=('c:\code.EBK')) as f:
    for line in f:
        print(i)
        print(line)
        line = line.replace("\n", "")

        # 登陆系统
        lg = bs.login(user_id="anonymous", password="123456")
        # 详细指标参数，参见“历史行情指标参数”章节
        rs = bs.query_history_k_data(line,
                                     "date,code,open,high,low,close,volume,amount,adjustflag,pctChg",
                                     start_date='2020-12-01', end_date='2020-12-02',
                                     frequency="d", adjustflag="2")
        #print(rs.error_code)
        #print(rs.error_msg!='')
		 
        # 获取具体的信息
        result_list = []
        while (rs.error_code == '0') & rs.next():
            # 分页查询，将每页信息合并在一起
            result_list.append(rs.get_row_data())
        for el in result_list:
            pricedata= ";INSERT INTO dbo.lishijiage (code,riqi,kai,shou,di,gao,chengjiaoliang,pctChg) VALUES ('%s', '%s','%s',N'%s',N'%s',N'%s',N'%s',N'%s')" % (el[1], el[0],el[2],el[5],el[4],el[3],el[7],el[9])
            with open('D:\\' + str(i) + '.sql', 'a+') as f2:
                f2.write(pricedata+'\n')
            #print(result_list[0])
        #result = pd.DataFrame(result_list, columns=rs.fields)
       # result.to_csv("D:/history_k_data.csv", encoding="gbk", index=False)
        #print(result)
        #if(len(result_list)>0):
          #  with open('c:\\rightcode.txt', 'a+') as f3:
          #      f3.write(line + '\n')
        #else:
        #    with open('c:\\errorcode.txt', 'a+') as f4:
         #       f4.write(line + '\n')
        # 登出系统
        # bs.logout()
        i = i + 1
		

