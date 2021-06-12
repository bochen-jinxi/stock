-- SCS买点5：诱敌深入1
--买点描述：
--2.下跌波段中,收出倒锤子止跌形态后第二天再收出大阴线跌破倒锤子低点，第三天再收出大阳线。
 -----------------------------------------------------------------------------------
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
               WHERE    riqi >= DATEADD(DAY, -21, GETDATE())
             )-----------------------------------------------------------------
 ,      T2
          AS ( SELECT   ( CASE zhangdie
                            WHEN 1 THEN ( gao - shou )
                            WHEN -1 THEN ( kai - gao )
                          END ) AS shanyingxian ,
                        ( CASE zhangdie
                            WHEN 1 THEN ( kai - di )
                            WHEN -1 THEN ( di - shou )
                          END ) AS xiayingxian ,
                        *
               FROM     T
             )----------------------------------------------------------------
	,   T3
          AS ( SELECT   shanyingxian / shiti AS syxbst ,
                        xiayingxian / shiti AS xyxbst ,
						( CASE zhangdie
                            WHEN 1 THEN shanyingxian/shou
                            WHEN -1 THEN shanyingxian/kai
                          END ) AS shanyingxianfudu ,
                        ( CASE zhangdie
                            WHEN 1 THEN xiayingxian/kai
                            WHEN -1 THEN xiayingxian/shou
                          END ) AS xiayingxianfudu ,
                        ROW_NUMBER() OVER ( PARTITION BY code ORDER BY gao DESC ) AS RowID ,
						
                        *
               FROM     T2
             ),
        T4
          AS ( SELECT   *
               FROM     T3
               WHERE    RowID = 1
             )-----------------------------------------------------------------------
	,   T5
          AS ( SELECT   COUNT(1) OVER ( PARTITION BY T3.code ) AS zhangdiezhouqishu ,
                        T4.code ,
                        T4.riqi AS kaishiriqi ,
                        T3.riqi ,
                        T3.shiti ,
                        T3.shitifudu ,
                        T3.zhangdie ,
                        T3.syxbst ,
                        T3.xyxbst,
						T3.di,
						T3.kai,
						T3.shou,
						T3.gao,
						T3.shanyingxianfudu,
						T3.xiayingxianfudu,
						MIN(T3.shitifudu) OVER(PARTITION BY T3.code) AS zuidadiefu
               FROM     T4
                        INNER JOIN T3 ON T4.code = T3.code
                                         AND T4.riqi < T3.riqi
               WHERE    T4.RowID = 1
             ),
        T6
          AS ( SELECT   ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi ) AS riqihao ,
		   --ROW_NUMBER() OVER ( PARTITION BY code ORDER BY di DESC ) AS zuidijiahao ,
		    MAX(ABS(shanyingxianfudu)) OVER(PARTITION BY code) AS zuidajueduizhishanyingxianfudu , 
                        *
               FROM     T5 
			   --WHERE code='sh.600048'
             )
			 , T60 AS (
				SELECT  *,di AS syxdi FROM T6
				WHERE zuidajueduizhishanyingxianfudu=ABS(shanyingxianfudu)  
				)		
			, T7 AS ( 
			 SELECT T6.riqi AS posyxriqi,T6.riqihao AS posyxriqihao ,T60.*	  FROM T60 INNER JOIN T6 ON  T60.code = T6.code			
			 WHERE T60.riqihao+1=T6.riqihao  
		 AND  T60.syxdi>T6.shou 	
			 AND T6.shiti<0 
		 )
		 SELECT T6.riqi, * FROM T7 INNER JOIN T6 ON  T7.code = T6.code
		 WHERE T7.posyxriqihao+1=T6.riqihao
		 AND  T6.shiti>0  AND  T6.shitifudu>2
			 