---	WHERE tingriqi='2021-10-22' 后续天数不破涨停2分之一水位
 -----------------------------------------------------------------------------------

USE stock 
   go 
WITH    T AS ( SELECT      
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
              WHERE    riqi >= '2021-10-01'                        AND riqi <= '2021-11-08'
						--AND  code NOT  LIKE 'sh.688%'
	--AND   code='sz.300672'
                        
	         )
			 ,T2 AS (
			 -------找到最早涨停日期 最低的收盘价格 最低的日期 统计涨停的次数
	 SELECT DISTINCT MIN(riqihao2) OVER(PARTITION BY code) AS tingriqihao2,  MIN(shou) OVER(PARTITION BY code) AS tingshou, COUNT(1) OVER(PARTITION BY code) AS tongjitingtianshu,   code  FROM  T   WHERE (( T.zf>=9.94 AND T.code   NOT  LIKE 'sh.688%' AND  T.code NOT LIKE 'sz%') OR (T.zf>=19.90 AND  ( T.code LIKE 'sh.688' OR T.code LIKE 'sz%')  )) )  
 ,T3 AS (
 -- 后续的天数
	SELECT COUNT(1) OVER(PARTITION BY T2.code) AS houxutianshu, tingriqihao2, tongjitingtianshu,tingshou ,T.* FROM T2 INNER JOIN  T ON T2.code = T.code WHERE T2.tingriqihao2<T.riqihao2   
	)
	,T4 AS (
	--后续最低价不破最早涨停收盘价的2分之一水位
	SELECT COUNT(1) OVER(PARTITION BY T3.code) AS houxuzhongtianshu, * FROM T3  WHERE 
	 (((code NOT  LIKE 'sh.688%' OR code NOT LIKE 'sz%') AND 	 tingshou/1.05<di )   OR ((code  LIKE 'sz%' OR code LIKE 'sh.688%') AND 	 tingshou/1.10<di  ))
	AND  ((di*1.05>=shou AND zf<0) 	OR (di*1.05>=kai AND zf>=0))
		) 
	
   --后续调整不破2分之一水位
   ,T5 AS (
	SELECT (SELECT TOP 1 riqi FROM T WHERE T.code=T4.code AND T.riqihao2=T4.tingriqihao2) AS tingriqi, *    FROM T4 WHERE  houxuzhongtianshu=houxutianshu )
	
	SELECT * FROM T5	
	WHERE tingriqi='2021-10-22' 
	ORDER BY shou desc
	-- houxutianshu IN(4,5,6,7,8)    


	
		 
  