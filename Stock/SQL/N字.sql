-- riqi >='2021-11-10' AND  riqi<='2021-11-22' 今天是2021-11-29 高点调整3-5 天 调整日期范围是2021-11-22 2021-11-23 2021-11-24   调整日期前是8个交易日是有连阳的
 -----------------------------------------------------------------------------------
 --找最近21个交易日的K线
   use stock 
   go 
WITH    T AS ( SELECT       ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi asc  ) AS riqihao ,
                        [code] ,
                        [riqi] ,
                        [kai] ,
                        [shou] ,
                        [di] ,
                        [gao] ,
                        [chengjiaoliang] ,
                         [pctChg] AS zhangdie
               FROM     dbo.lishijiager
			   WHERE    riqi >='2021-11-10' AND  riqi<='2021-11-29'
		     -- AND  code LIKE '%603738%'
             )-----------------------------------------------------------------
	,   T2
          AS (
		  --取最大值时间  最小值时间
		   SELECT  
		                 ROW_NUMBER() OVER ( PARTITION BY code ORDER BY gao DESC ) AS maxriqinum ,
						ROW_NUMBER() OVER ( PARTITION BY code ORDER BY di Asc ) AS minriqinum ,
                        *
               FROM     T WHERE    riqi >='2021-11-10' AND  riqi<='2021-11-22'
             )
       ,T3 AS (	SELECT * FROM T2  WHERE minriqinum=1)
	    ,T4 AS (SELECT * FROM T2  WHERE maxriqinum=1)
 
		,T5 AS (
		 SELECT T3.riqihao AS minriqihao ,T3.riqi AS minriqi ,T4.riqihao AS maxriqihao, T4.riqi AS maxriqi,T3.code FROM T3 INNER JOIN  T4 ON T3.code = T4.code  WHERE T3.riqihao<T4.riqihao)
 --SELECT * FROM T5
		 ,T6 AS (
		 SELECT (COUNT(1) OVER(PARTITION BY T5.code)) AS zongshunum, minriqi,maxriqi, T.* FROM T INNER JOIN  T5 ON T.code = T5.code WHERE T.riqihao>=T5.minriqihao AND T.riqihao<=maxriqihao
		 )
	 
		 ,T7 AS (
		 --阳的天数
		 SELECT (COUNT(1) OVER(PARTITION BY code)) as yangnum,   * FROM T6 WHERE  zhangdie>0)
		 , T8 AS (
		 SELECT DISTINCT SUM(zhangdie) OVER(PARTITION BY code) AS sumzf, MIN(riqihao) OVER(PARTITION BY code) AS minriqihao, MAX(riqihao) OVER(PARTITION BY code) AS maxriqihao, MIN(di) OVER(PARTITION BY code) AS mindi, MAX(gao) OVER(PARTITION BY code) AS maxgao, yangnum,zongshunum,minriqi,maxriqi,code   FROM T7  WHERE 1=1 AND maxriqi='2021-11-22 00:00:00.000' 
		-- and  num=num3 
		 )
		 --T8是 N字的一撇找到了
		 --SELECT * FROM T8 ORDER BY sumzf DESC 
		 --T8 inner join T N字的一腊找到了
		 SELECT * FROM T8  INNER JOIN  T ON T8.code = T.code WHERE T8.maxriqihao<T.riqihao
		AND T.di>T8.mindi*1.05  AND T.di<T8.mindi*1.10
		 -- AND T.di>T8.mindi*1.10  AND T.di<T8.mindi*1.15
		  -- AND T.di>T8.mindi*1.20  AND T.di<T8.mindi*1.25
		  --  AND T.di>T8.mindi*1.30  AND T.di<T8.mindi*1.35
		  --AND T.di>T8.mindi*1.35  AND T.di<T8.mindi*1.40
		 --  AND T.di>T8.mindi*1.45  AND T.di<T8.mindi*1.50
		-- AND T.di>T8.mindi*1.55  AND T.di<T8.mindi*1.60
		-- AND T.di>T8.mindi*1.65  AND T.di<T8.mindi*1.70
		AND T.riqi='2021-11-29'
		 ORDER BY sumzf DESC
		 