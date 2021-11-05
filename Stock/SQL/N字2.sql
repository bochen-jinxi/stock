---N字结构 见高点后下跌4天之内见地点 有破底N字结构
 -----------------------------------------------------------------------------------
 --找最近8个交易日的K线键高点的
USE stock 
   go 
WITH    T AS ( SELECT   ( CASE WHEN ( shou - kai ) > 0 THEN 1
                               WHEN ( shou - kai ) = 0 THEN 0
                               WHEN ( shou - kai ) < 0 THEN -1
                          END ) AS zhangdie ,
                        [code] ,
                        [riqi] ,
                        [kai] ,
                        [shou] ,
                        [di] ,
                        [gao] ,
						  ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi ASC ) AS riqihao2 ,
                        [chengjiaoliang] ,
                        1 AS [pctChg]
               FROM     dbo.lishijiager
               WHERE    riqi >= '2021-10-01'
                        AND riqi <= '2021-11-29'
		--AND code like '%002608%'
                        
             )-----------------------------------------------------------------
	,   T2
          AS (
		  --取最大值时间  最小值时间 实体幅度 上影线和实体的比值 上影线幅度
               SELECT   ( CASE zhangdie
                            WHEN 1 THEN ( shou - kai ) / kai
                          END ) * 100 AS shitifudu ,
                        ( ( CASE zhangdie
                              WHEN 1 THEN ( gao - shou )
                            END ) / ( CASE zhangdie
                                        WHEN 1 THEN ( shou - kai )
                                      END ) ) AS syxbst ,
                        ( CASE zhangdie
                            WHEN 1 THEN ( gao - shou ) / shou
                          END ) * 100 AS syxfd ,
                      
                        ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi DESC ) AS riqihao ,
                        ROW_NUMBER() OVER ( PARTITION BY code ORDER BY gao DESC ) AS RowID ,
                        ROW_NUMBER() OVER ( PARTITION BY code ORDER BY di ASC ) AS RowID2 ,
                        *
               FROM     T
             ),
			 --最高点日期
        T3
          AS ( SELECT   *
               FROM     T2
               WHERE    RowID = 1
                        AND zhangdie = 1
                                             
             ),
			 --最低点日期
        T4
          AS ( SELECT   T2.*
               FROM     T2
               WHERE    RowID2 = 1
             ),
			 --	 见高点后下跌4天之内见地点
        T5
          AS ( SELECT   T2.riqihao2 - T3.riqihao2 AS num ,
                        T3.riqi AS griqi ,
                        T2.riqi AS d1riqi ,
                        T2.* ,
                        T2.di AS d1jiage
               FROM     T3
                        INNER JOIN T2 ON T3.code = T2.code
               WHERE    ( T2.riqihao2 - 1 = T3.riqihao2
                          OR T2.riqihao2 - 2 = T3.riqihao2
                          OR T2.riqihao2 - 3 = T3.riqihao2
                          OR T2.riqihao2 - 4 = T3.riqihao2
                        )
                        AND T2.zhangdie = -1
             ),
			 --1低点日期 日期倒序排号
        T6
          AS ( SELECT   MAX(num) OVER ( PARTITION BY code ) AS jin4tianxiadieshu ,
                        MIN(d1jiage) OVER ( PARTITION BY code ) AS d1jia ,
                        ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqihao2 DESC ) AS num3 ,
                        *
               FROM     T5
             ),
			 -- 1低点最大日期
        T7
          AS ( SELECT   *
               FROM     T6
               WHERE    num3 = 1
             ),
        T9
          AS ( SELECT   T7.d1jia ,
                        T4.di AS d2jia ,
                        T7.riqihao2 AS minriqihao2 ,
                        T4.riqihao2 AS maxriqihao2 ,
                        jin4tianxiadieshu ,
                        T4.code ,
                        griqi ,
                        d1riqi ,
                        T4.riqi AS d2riqi
               FROM     T7
                        INNER JOIN T4 ON T4.code = T7.code
               WHERE    1 = 1
                        AND 
					     --2低点破1低点 1底点 和 2底点之间低点间距3个点之内
                        ( ( T7.d1jia - T4.di ) / T4.di ) * 100 < 3			                                      
		--1低点日期小于2低点日子
                        AND T7.riqihao2 < T4.riqihao2
             )
    --上冲2个点以上 回落
		 SELECT T2.shou AS d2shou ,
                T9.* ,
                T2.riqi AS syxrq ,
                T2.riqihao2
         FROM   T9
                INNER JOIN T2 ON T2.code = T9.code
         WHERE  T2.riqihao2 >= minriqihao2
                AND T2.riqihao2 <= maxriqihao2  
                AND syxfd > 2
         ORDER BY 1 DESC 



 


	
		 
  