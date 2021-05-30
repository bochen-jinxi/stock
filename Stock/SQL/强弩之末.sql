--SCS买点1：强誓之末
--买点描述：在下跌过程中连续出现几根影线长,体小的K线后，没价在地位收出大实体阳线。
---意味着下跌趋势将被扭转。
 -----------------------------------------------------------------------------------
WITH    T AS ( SELECT
( CASE WHEN ( shou - kai ) > 0 THEN 1
                               WHEN ( shou - kai ) = 0 THEN 0
                               WHEN ( shou - kai ) < 0 THEN -1
                          END ) AS zd ,
                        ( shou - kai ) AS st ,
                        ( shou - kai ) / kai * 100 AS stf,
                        [code] ,
                        [riqi] ,
                        [kai] ,
                        [shou] ,
                        [di] ,
                        [gao] ,
                        [chengjiaoliang] ,
                        1 AS [pctChg]                       
               FROM     dbo.lishijiager
               WHERE   riqi>=DATEADD(DAY,-21,GETDATE())
             )
-----------------------------------------------------------------
 ,      T2
          AS ( SELECT   ( CASE zd
                            WHEN 1 THEN ( gao - shou )
                            WHEN -1 THEN ( kai - gao )
                          END ) AS syx ,
                        ( CASE zd
                            WHEN 1 THEN ( kai - di )
                            WHEN -1 THEN ( di - shou )
                          END ) AS xyx ,
                        *
               FROM     T
             )
     ----------------------------------------------------------------
	,T3 AS ( SELECT  syx/st AS syxbst,xyx/st AS xyxbst, 
	 ROW_NUMBER() OVER ( PARTITION BY code ORDER BY gao DESC )AS RowID,
	               *
        FROM    T2)
	,T4 AS (	SELECT * FROM T3  WHERE RowID=1 )
	-------------------------------------------------------------------------
	,T5 AS (
	SELECT COUNT(1) OVER(PARTITION BY  T3.code) AS zdzqs,T4.code, T4.riqi AS ksriqi ,T3.riqi,T3.st,T3.stf  FROM T4 INNER JOIN T3 ON T4.code = T3.code AND T4.riqi < T3.riqi
	WHERE T4.RowID=1
      )
	  -------------------------------------
	  ,T6 AS (
	SELECT ROW_NUMBER() OVER( PARTITION BY code  ORDER BY riqi ASC ) AS riqizx,
	ROW_NUMBER() OVER( PARTITION BY code  ORDER BY st ASC ) AS stzx,
	 * FROM T5 WHERE  zdzqs>4 
	)
	SELECT * FROM T6  WHERE zdzqs=stzx AND stzx=riqizx
	ORDER BY zdzqs ASC 
	--SELECT A.* FROM T6 INNER JOIN  T6 AS A ON  T6.code = A.code AND T6.zdst=A.zdst   WHERE A.zdstf>2 
	
	
  

