---3 4 5 6前是涨停板 后续 3 4 5 6 天不破涨停开盘价
 -----------------------------------------------------------------------------------

USE stock 
   go 
WITH    T AS ( SELECT   ( CASE WHEN ( shou - kai ) > 0 THEN 1
                               WHEN ( shou - kai ) = 0 THEN 0
                               WHEN ( shou - kai ) < 0 THEN -1
                          END ) AS zhangdie ,
						   ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi DESC ) AS riqihao ,
						    ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi ASC ) AS riqihao2 ,
                        [code] ,
                        [riqi] ,
                        [kai] ,
                        [shou] ,
                        [di] ,
                        [gao] ,
                        [chengjiaoliang] ,
                         [pctChg] AS zf
               FROM     dbo.lishijiager
               WHERE    riqi >= '2021-10-15'
                        AND riqi <= '2021-11-04'
						AND  code NOT  LIKE 'sh.688%'
	AND   code='sz.300820'
                        
	         )
			 ,T2 AS (
			 -------找到涨停日期
	 SELECT DISTINCT MIN(riqihao2) OVER(PARTITION BY code) AS tingriqihao2,  MIN(shou) OVER(PARTITION BY code) AS tingshou, MIN(riqi) OVER(PARTITION BY code) AS tingriqi, COUNT(1) OVER(PARTITION BY code) AS tianshu,   code  FROM  T   WHERE (( T.zf>=9.94 AND T.code   LIKE 'sh%') OR (T.zf>=19.90 AND T.code LIKE 'sz%')) )  
 ,T3 AS (
	SELECT COUNT(1) OVER(PARTITION BY T2.code) AS houxutianshu,  tingshou ,T2.tingriqi,T.* FROM T2 INNER JOIN  T ON T2.code = T.code WHERE T2.tingriqihao2<T.riqihao2   
	)

	,T4 AS (
	SELECT COUNT(1) OVER(PARTITION BY T3.code) AS tingkaitianshu, * FROM T3  WHERE 	 (T3.tingshou)<T3.di  )
		
	SELECT *    FROM T4 WHERE  tingkaitianshu=houxutianshu AND houxutianshu IN(4,5,6,7,8)


	
		 
  