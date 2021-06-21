-- SCS买点5：诱敌深入1
--买点描述：
--2.下跌波段中,收出倒锤子止跌形态后第二天再收出大阴线跌破倒锤子低点，第三天再收出大阳线。
 -----------------------------------------------------------------------------------
   --找最近8个交易日的K线
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
               --WHERE    riqi >= DATEADD(DAY, -21, GETDATE())
			    WHERE    riqi >='2021-06-08' AND  riqi<='2021-06-18'
             )-----------------------------------------------------------------
 ,      T2
          AS ( 
		   --取上/下影线
		  SELECT   ( CASE zhangdie
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
          AS (
		   --冲高回落/探底回升的比例 幅度
		   SELECT   shanyingxian / shiti AS syxbst ,
                        xiayingxian / shiti AS xyxbst ,
						( CASE zhangdie
                            WHEN 1 THEN shanyingxian/shou
                            WHEN -1 THEN shanyingxian/kai
                          END ) AS shangyingxianfudu ,
                        ( CASE zhangdie
                            WHEN 1 THEN xiayingxian/kai
                            WHEN -1 THEN xiayingxian/shou
                          END ) AS xiayingxianfudu ,
                        ROW_NUMBER() OVER ( PARTITION BY code ORDER BY gao DESC ) AS RowID ,
						
                        *
               FROM     T2
             ),
        T4
          AS ( 
		  -- 各代码见高点的日期 价格
		  SELECT   *
               FROM     T3
               WHERE    RowID = 1
             )-----------------------------------------------------------------------
	,   T5
          AS ( 
		   	--见高点后 后续价格数据中所有阴阳线 并统计后续阴阳线的数量
		  SELECT   COUNT(1) OVER ( PARTITION BY T3.code ) AS zhangdiezhouqishu ,
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
						T3.shangyingxianfudu,
						T3.xiayingxianfudu,
						MIN(T3.shitifudu) OVER(PARTITION BY T3.code) AS zuidadiefu
               FROM     T4
                        INNER JOIN T3 ON T4.code = T3.code
                                         AND T4.riqi < T3.riqi
               WHERE    T4.RowID = 1
             ),
        T6
          AS (
		    -- 后续数据按日期正序标号  标记上影线幅度
		   SELECT   ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi ) AS riqihao ,
		    MAX(ABS(shangyingxianfudu)) OVER(PARTITION BY code) AS zuidajueduizhishangyingxianfudu , 
                        *
               FROM     T5 
			  
             )
			 , T60 AS (
			  --后续数据数据查找上影线最长的K线 标记上影线的最低点
				SELECT  *,di AS syxdi FROM T6
				WHERE zuidajueduizhishangyingxianfudu=ABS(shangyingxianfudu)  
				)		
			, T7 AS ( 
			--查找上影线后第二天收盘价跌破最低点的阴线
			 SELECT T6.riqi AS posyxriqi,T6.riqihao AS posyxriqihao ,T60.*	  FROM T60 INNER JOIN T6 ON  T60.code = T6.code			
			 WHERE T60.riqihao+1=T6.riqihao  
		 AND  T60.syxdi>T6.shou 	
			 AND T6.shiti<0 
		 )
		 ---查找上影线后第二天收盘价跌破最低点的阴线 紧接着收阳线且实体大于3
		 SELECT T6.riqi, * FROM T7 INNER JOIN T6 ON  T7.code = T6.code
		 WHERE T7.posyxriqihao+1=T6.riqihao
		 AND  T6.shiti>0  AND  T6.shitifudu>3
			 