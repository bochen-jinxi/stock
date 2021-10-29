---N字结构 见高点后下跌4天之内见地点 有破底N字结构
 -----------------------------------------------------------------------------------
 --找最近8个交易日的K线键高点的
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
			    WHERE    riqi >='2021-10-11' AND  riqi<='2021-10-28'
		--AND code like '%002304%'
             )-----------------------------------------------------------------
	,   T2
          AS (
		  --取最大值时间  最小值时间
		   SELECT  
		     ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi asc   ) AS riqihao2 ,
		     ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi DESC  ) AS riqihao ,
		   ROW_NUMBER() OVER ( PARTITION BY code ORDER BY gao ASC ) AS zuidijiahao ,

                        ROW_NUMBER() OVER ( PARTITION BY code ORDER BY gao DESC ) AS RowID ,
						ROW_NUMBER() OVER ( PARTITION BY code ORDER BY di Asc ) AS RowID2 ,
                        *
               FROM     T
             )

       ,T3 AS (	SELECT * FROM T2  WHERE RowID=1  and zhangdie=1 and  riqi>'2021-10-11'
	  
	   )

	    ,T4 AS (SELECT T2.* FROM T2   WHERE RowID2=1      ) 
			--	 select  * from T4 order by riqi
		,T5 AS  ( 
			 SELECT T2.riqihao2-T3.riqihao2 as num  , T3.riqi AS griqi,T2.riqi AS d1riqi,T2.*,T2.di as djiage FROM  T3   INNER JOIN  T2 ON T3.code = T2.code  
			WHERE   (T2.riqihao2-1=T3.riqihao2 or T2.riqihao2-2=T3.riqihao2 or T2.riqihao2-3=T3.riqihao2 or T2.riqihao2-4=T3.riqihao2 )   and T2.zhangdie=-1
		)
		,T6 As (
		 select MAx(num) over(PARTITION BY code) as jin4tianxiadieshu, min(djiage) over(PARTITION BY code) as djia, * from T5  )
--select * from T6
		 ,T7 as (
		 select ROW_NUMBER() over(PARTITION BY code order by riqihao2 desc) as num3, * from T6  )
		 ,T8 as (
		 select * from T7 where num3=1)
		 select T8.djia,T4.di, T8.riqihao2,T4.riqihao2, jin4tianxiadieshu,T4.code,griqi,d1riqi,T4.riqi as d2riqi from T8 inner join T4 on T4.code=T8.code
		 inner join T2 on T8.code=T2.code
		  where T8.di>=T4.di
	  and  T8.djia-T4.di>0
		 and ((T8.djia-T4.di)/t8.djia)*100<4
		 and T4.riqi>d1riqi
		 and T2.riqi='2021-10-28' 
		 --and T2.zhangdie=1
		 and T8.riqihao2<T4.riqihao2-2
		 order by T4.shou desc 
  