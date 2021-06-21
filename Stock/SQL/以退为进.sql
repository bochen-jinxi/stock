--SCS买点2：以退为进
--买点描述：股价在连续下跌后收出低位锤子形态，第二天股价低开后高走，最终收出实体大影线小的阳线，
---并且收盘价格突破头天锤子线最高价
 
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
              -- WHERE    riqi >= DATEADD(DAY, -21, GETDATE())
		    WHERE    riqi >='2021-06-11' AND  riqi<='2021-06-21'
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
						T4.shangyingxianfudu,
						T4.xiayingxianfudu
               FROM     T4
                        INNER JOIN T3 ON T4.code = T3.code
                                         AND T4.riqi < T3.riqi
               WHERE    T4.RowID = 1
             ),
        T6
          AS (
		   -- 后续数据按日期正序标号  最低价按日期倒序标号
		   SELECT   ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi ) AS riqihao ,
		   ROW_NUMBER() OVER ( PARTITION BY code ORDER BY di DESC ) AS zuidijiahao ,
                        *
               FROM     T5
             ),
        T7
          AS (
		   --查找后续中所有阴线并重新按日期正序标号 用以查找连续日期号的阴线
		   SELECT   riqihao
                        - ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi ) AS lianxuxiadieriqizu ,
                        *
               FROM     T6
               WHERE   --- code='sh.603985' AND   
                        zhangdie = -1
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
		   SELECT   MAX(lianxuxiadieshu) OVER ( PARTITION BY code ) zuidalianxuxiadieshu ,
                        *
               FROM     T8
             )
			 ,T10 AS (
			 SELECT * FROM T9 WHERE riqihao=zhangdiezhouqishu-1 
			 AND  shitifudu*100<1	
			 AND xiayingxianfudu*100>2
			 )
		 SELECT * FROM T10 INNER JOIN T6 ON  T10.code = T6.code
		 WHERE  T10.riqihao+1=T6.riqihao AND T10.shou>T6.kai AND T10.gao<T6.shou
		 ORDER BY T10.code
		 		
		  