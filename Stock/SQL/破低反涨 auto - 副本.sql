--SCS���4���Ƶͷ���
--����������ɼ��ڽ���֧��λ���ִ�������λ���ƣ��ڶ��������ǿ���ո��� ���ۿɼ�ǰ����һ�����������
 
 -----------------------------------------------------------------------------------
    --�����8�������յ�K��
	  use stock 
   go 

    --SELECT    ROW_NUMBER() OVER( PARTITION BY code ORDER BY riqi ASC) AS riqihao,*
    --          INTO T90
			 --  FROM     dbo.lishijiager
			 -- WHERE  riqi >='2022-04-11' AND  riqi<='2022-05-11'

			 DECLARE @i INT ;
			 SET @i=(SELECT COUNT(1) FROM dbo.T90 WHERE  code ='sz.000001')
			 WHILE(@i>5)
			 BEGIN
             --SELECT * FROM dbo.T90 WHERE riqihao<=@i
			 

WITH    T AS ( SELECT   riqihao,  ( CASE WHEN ( shou - kai ) > 0 THEN 1
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
              FROM dbo.T90 WHERE riqihao<=@i
              -- WHERE    riqi >= DATEADD(DAY, -21, GETDATE())
			  --WHERE    riqi >='2022-03-27' AND  riqi<='2022-04-27'
			  --AND   code LIKE '%sh.600619%'
             )-----------------------------------------------------------------
	
  ,T2
          AS ( 
		    --ȡ��/��Ӱ��
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
		   --��߻���/̽�׻����ı��� 
		  SELECT   shanyingxian / shiti AS syxbst ,
                        xiayingxian / shiti AS xyxbst ,
                        ROW_NUMBER() OVER ( PARTITION BY code ORDER BY gao DESC ) AS RowID ,
						
                        *
               FROM     T2
             ),
        T4
          AS ( 
		    -- ��������ߵ������ �۸�
		  SELECT   *
               FROM     T3
               WHERE    RowID = 1
             )-----------------------------------------------------------------------
	,   T5
          AS (
		  	--���ߵ�� �����۸����������������� ��ͳ�ƺ��������ߵ�����
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
						MIN(T3.shitifudu) OVER(PARTITION BY T3.code) AS zuidadiefu
               FROM     T4
                        INNER JOIN T3 ON T4.code = T3.code
                                         AND T4.riqi < T3.riqi
               WHERE    T4.RowID = 1
             ),
        T6
          AS ( 
		      -- �������ݰ�����������  ��ͼ۵���
		  SELECT   ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi ) AS riqihao ,
		   ROW_NUMBER() OVER ( PARTITION BY code ORDER BY di DESC ) AS zuidijiahao ,
                        *
               FROM     T5
             ),
        T7
          AS (
		   --���Һ������������߲����°����������� ���Բ����������ںŵ�����
		   SELECT   riqihao
                        - ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi ) AS lianxuxiadieriqizu , COUNT(1) OVER(PARTITION BY code) AS  yingxianshu,
						(SELECT COUNT(1) FROM T6 AS A WHERE A.zhangdie=1 AND A.code=T6.code ) AS yangxianshu,
                         *
               FROM     T6
               WHERE   --- code='sh.603985' AND   
                        zhangdie = -1
             ),
        T8
          AS (
		   --��ʶ�����������������ߵ�����
		   SELECT   COUNT(1) OVER ( PARTITION BY code, lianxuxiadieriqizu ) AS lianxuxiadieshu ,
                        *
               FROM     T7
             ),
        T9
          AS ( 
		   --��ʶ��������������������� 
		  SELECT   MAX(lianxuxiadieshu) OVER ( PARTITION BY code ) zuidalianxuxiadieshu ,
                        *
               FROM     T8
             )
			
			 ,T10 AS (
			 --���Һ��������������� ��������һ����������
			 SELECT * FROM T9 WHERE riqihao+1=zhangdiezhouqishu 
			-- AND  T9.shitifudu=zuidadiefu
			 		 			-- AND zuidijiahao=zhangdiezhouqishu
			 )
	 
			--�ڶ��������ո�
		 INSERT INTO  [dbo].[T900](
	[gaoriqi]		,
	[code]			,
	[ciriqi]		,
	[zhuriqi]		,
	[shitifudu]		,
	[yingxianshu]	,
	[yangxianshu]	
)  
		 SELECT DISTINCT T10.kaishiriqi AS gaoriqi ,T10.code,T10.riqi AS ciriqi,T6.riqi AS zhuriqi
		 ,T10.shitifudu,
		 --T6.shitifudu,
		 T10.yingxianshu,T10.yangxianshu
		 ---, T10.* 
		 
		  
		 FROM T10 INNER JOIN T6 ON  T10.code = T6.code
		 WHERE  
	     T10.riqihao+1=t6.riqihao 
		 AND T10.zhangdie=-1  AND  ABS(T10.shitifudu)/(100/61.8)<T6.shitifudu
		  and T10.kai>=T6.shou	
	     AND (T10.zuidijiahao=T10.zhangdiezhouqishu	 OR T10.zuidijiahao+1=T10.zhangdiezhouqishu)
		 --AND T10.zhangdiezhouqishu>8	 	
		 AND T10.yingxianshu<T10.yangxianshu
			 	--AND 		  T6.riqi='2022-04-27'	
				 ORDER BY T10.code
	
 	SET @i=@i-1;
			 END