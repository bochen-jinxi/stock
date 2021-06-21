-- SCS���5���յ�����1
--���������
--2.�µ�������,�ճ�������ֹ����̬��ڶ������ճ������ߵ��Ƶ����ӵ͵㣬���������ճ������ߡ�
 -----------------------------------------------------------------------------------
   --�����8�������յ�K��
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
		   --��߻���/̽�׻����ı��� ����
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
		    -- �������ݰ�����������  �����Ӱ�߷���
		   SELECT   ROW_NUMBER() OVER ( PARTITION BY code ORDER BY riqi ) AS riqihao ,
		    MAX(ABS(shangyingxianfudu)) OVER(PARTITION BY code) AS zuidajueduizhishangyingxianfudu , 
                        *
               FROM     T5 
			  
             )
			 , T60 AS (
			  --�����������ݲ�����Ӱ�����K�� �����Ӱ�ߵ���͵�
				SELECT  *,di AS syxdi FROM T6
				WHERE zuidajueduizhishangyingxianfudu=ABS(shangyingxianfudu)  
				)		
			, T7 AS ( 
			--������Ӱ�ߺ�ڶ������̼۵�����͵������
			 SELECT T6.riqi AS posyxriqi,T6.riqihao AS posyxriqihao ,T60.*	  FROM T60 INNER JOIN T6 ON  T60.code = T6.code			
			 WHERE T60.riqihao+1=T6.riqihao  
		 AND  T60.syxdi>T6.shou 	
			 AND T6.shiti<0 
		 )
		 ---������Ӱ�ߺ�ڶ������̼۵�����͵������ ��������������ʵ�����3
		 SELECT T6.riqi, * FROM T7 INNER JOIN T6 ON  T7.code = T6.code
		 WHERE T7.posyxriqihao+1=T6.riqihao
		 AND  T6.shiti>0  AND  T6.shitifudu>3
			 