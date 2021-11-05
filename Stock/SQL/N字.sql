---下跌N字结构 13个周期里面见底点后至少反弹3天
 -----------------------------------------------------------------------------------
 --找最近21个交易日的K线
   use stock 
   go 
WITH    T AS ( SELECT   ( CASE WHEN ( shou - kai ) > 0 THEN 1
                               WHEN ( shou - kai ) = 0 THEN 0
                               WHEN ( shou - kai ) < 0 THEN -1
                          END ) AS zhangdie ,
                        ( shou - kai ) AS shiti ,
                        ( shou - kai ) / kai * 100 AS shitifudu ,
                        [code] ,
                        [riqi] ,
                        [kai] ,
                        [shou] ,
                        [di] ,
                        [gao] ,
                        [chengjiaoliang] ,
                        1 AS [pctChg]
               FROM     dbo.lishijiager
             --  WHERE    riqi >= DATEADD(DAY, -21, GETDATE())
			    WHERE    riqi >='2021-10-11' AND  riqi<='2021-11-04'
				--AND code='sh.603317'
             )-----------------------------------------------------------------
	,   T2
          AS (
		  --取最大值时间  最小值时间
		   SELECT  
		     ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi DESC  ) AS riqihao ,
		   ROW_NUMBER() OVER ( PARTITION BY code ORDER BY gao ASC ) AS zuidijiahao ,

                        ROW_NUMBER() OVER ( PARTITION BY code ORDER BY gao DESC ) AS RowID ,
						ROW_NUMBER() OVER ( PARTITION BY code ORDER BY di Asc ) AS RowID2 ,
                        *
               FROM     T
             )
       ,T3 AS (	SELECT * FROM T2  WHERE RowID=1)
	    ,T4 AS (SELECT * FROM T2  WHERE RowID2=1)
		,T5 AS  ( 
			 SELECT   T3.riqi AS griqi,T4.riqi AS driqi,T3.code FROM  T3   INNER JOIN  T4 ON T3.code = T4.code  
			WHERE  T3.riqi<T4.riqi 
		)
	   ,T6
          AS (
		  -- 后续数据按日期正序标号  最低价按日期倒序标号
		   SELECT   
		   ROW_NUMBER() OVER ( PARTITION BY T.code ORDER BY T.riqi ) AS riqihao ,
                        T.*,T5.driqi,T5.griqi
               FROM     T  INNER JOIN  T5 ON T.code = T5.code WHERE T.riqi>T5.driqi
             ),
			-- SELECT * FROM T6
        T7
          AS (
		  --查找后续中所有阴线并重新按日期正序标号 用以查找连续日期号的阴线
		   SELECT   riqihao
                        - ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi ) AS lianxuxiadieriqizu ,
                        *
               FROM     T6
               WHERE   zhangdie = 1
             ),
        T8
          AS ( 
		  --标识后续中所有连续阴线的天数
		  SELECT   COUNT(1) OVER ( PARTITION BY code, lianxuxiadieriqizu ) AS lianxuxiadieshu ,
                        *
               FROM     T7
             ),
        T9
          AS ( 
		  --标识后续中阴线最大连续天数 
		  SELECT   MAX(lianxuxiadieshu) OVER ( PARTITION BY code ) zuidalianxushangzhangshu ,
                        *
               FROM     T8
             )

	  SELECT DISTINCT  zuidalianxushangzhangshu,griqi,driqi,MIN(riqi) OVER(PARTITION BY code ),code    FROM T9 WHERE zuidalianxushangzhangshu>=3
	  ORDER BY	      1 DESC 