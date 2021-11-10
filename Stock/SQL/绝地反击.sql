﻿----SCS买点2：绝地反击
---买点描述：股价在连续下跌后收出低位大阴线形态，第二天股价低开后高走，盘间最高价回补缺口
---最终低开收阳的倒锤子形态
 
 -----------------------------------------------------------------------------------
 --找最近8个交易日的K线
   use stock 
   go 
WITH    T AS ( SELECT   
 ROW_NUMBER() OVER(PARTITION BY code ORDER BY riqi desc) AS riqidaoxu,
 ROW_NUMBER() OVER(PARTITION BY code ORDER BY gao desc) AS gaodaoxu,
 [code] ,
                        [riqi] ,
                        [kai] ,
                        [shou] ,
                        [di] ,
                        [gao] ,
                
                         [pctChg] AS zhangdie						
						 
               FROM     dbo.lishijiager
 WHERE    riqi >='2021-11-01' AND  riqi<='2021-11-09'
							)

							SELECT  * FROM T   INNER JOIN T AS T0   ON T.code = T0.code 
							WHERE T.riqidaoxu=T0.riqidaoxu-1   
							--前一天进似光脚 
							AND (((T0.di*1.01)>=T0.shou AND T0.zhangdie<1) 	OR ((T0.di*1.01)>=T0.kai AND T0.zhangdie>-1)							 ) 
							AND T0.riqidaoxu=2
							-- 后一天进似光脚倒锤子
							AND T.kai<=T0.di  
							--AND (( T.gao>=T0.shou*1.01 AND T0.zhangdie<1) OR( T.gao>=T0.kai*1.01 AND T0.zhangdie>-1))
							AND ((T.shou<=T.kai*1.01 AND T.zhangdie>-1) OR  ( T.shou<=T.kai/1.01 AND  T.zhangdie<1) )
							AND T.riqidaoxu=1
							ORDER BY T.shou desc


		 		
		  