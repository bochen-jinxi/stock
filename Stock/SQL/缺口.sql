--AND T.riqi='2021-11-05' 日期跳空缺口是强支撑 缺口能跳过重要阻力位是最强缺口
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
                
                         [pctChg] AS zf						
						 
               FROM     dbo.lishijiager
 WHERE    riqi >='2021-11-08' AND  riqi<='2021-11-25'
 --AND code LIKE '%300118%'
							)

							SELECT  * FROM T   INNER JOIN T AS T0   ON T.code = T0.code 
							WHERE T.riqidaoxu=T0.riqidaoxu-1   
							--前一天阴
							--AND (T0.di*1.20)>=T0.shou AND T0.zf<0
							--AND T0.riqidaoxu=2
							-- 后一天孕
							AND T.kai>=T0.gao*1.01
							AND T.kai/1.01<=T.di
							AND T.zf>=0
							AND T.riqi='2021-11-25'
							ORDER BY T.shou desc


		 		
		  