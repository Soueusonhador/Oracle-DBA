SELECT * From ALL_OBJECTS;
Select * FROM ALL_OBJECTS where object_ID <= 25;



SELECT metric_name, Value FROM V$SYSMETRIC WHERE
metric_name IN ('Database CPU Time Ratio','Database Wait Time Ratio');


SELECT *  FROM V$SYSTEM_WAIT_CLASS
Where WAIT_CLASS <> 'Idle';


SELECT SUM(TOTAL_WAITS) as SUM_TOTAL_WAITS, SUM(TIME_WAITED) as SUM_TIME_WAITED  FROM V$SYSTEM_WAIT_CLASS
Where WAIT_CLASS <> 'Idle';  

SELECT A.WAIT_CLASS, ROUND((A.TOTAL_WAITS/B.SUM_TOTAL_WAITS)*100,2) AS PCT_TOTAL_WAITS,
ROUND((A.TIME_WAITED/B.SUM_TIME_WAITED)*100,2) AS PCP_TIME_WAITED
FROM
(SELECT * FROM V$SYSTEM_WAIT_CLASS
WHERE WAIT_CLASS <> 'Idle') A,
(SELECT SUM(TOTAL_WAITS) AS SUM_TOTAL_WAITS, SUM(TIME_WAITED) AS SUM_TIME_WAITED 
FROM V$SYSTEM_WAIT_CLASS
WHERE WAIT_CLASS <> 'Idle') B;


SELECT  * FROM  V$PGA_TARGET_ADVICE;

-- verificar Consumers Groups
SELECT * FROM DBA_RSRC_CONSUMER_GROUPS;

-- Cria uma area pendente (biblioteca)
EXEC DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA;

-- criar plano de recursos
EXEC DBMS_RESOURCE_MANAGER.CREATE_PLAN (PLAN=>'DAY', COMMENT=>'Plano Diurno');

-- definir prioridades
EXEC DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE (PLAN=>'DAY', GROUP_OR_SUBPLAN=>'SYS_GROUP', MGMT_P1=>100, COMMENT=>'Prioridade 1 para administradores do sistema');
EXEC DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE (PLAN=>'DAY', GROUP_OR_SUBPLAN=>'INTERACTIVE_GROUP', MGMT_P2=>100, COMMENT=>'Prioridade 2 para operadores de Televendas');
EXEC DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE (PLAN=>'DAY', GROUP_OR_SUBPLAN=>'DSS_CRITICAL_GROUP', MGMT_P3=>50, COMMENT=>'Prioridade 3 para relat�rios');
EXEC DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE (PLAN=>'DAY', GROUP_OR_SUBPLAN=>'BATCH_GROUP', MGMT_P3=>50, COMMENT=>'Prioridade 3 para processos em Batch');


-- escolher prioridade
EXEC DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE (PLAN=>'DAY', GROUP_OR_SUBPLAN=>'DSS_CRITICAL_GROUP', MGMT_P3=>50, COMMENT=>'Prioridade 3 para relat�rios');

EXEC DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE (PLAN=>'DAY', GROUP_OR_SUBPLAN=>'BATCH_GROUP', MGMT_P3=>50, COMMENT=>'Prioridade 3 para processos em Batch');
EXEC DBMS_RESOURCE_MANAGER.CREATE_PLAN_DIRECTIVE (PLAN=>'DAY', GROUP_OR_SUBPLAN=>'OTHER_GROUPS', MGMT_P4=>100, COMMENT=>'Prioridade 4 para outros usu�rios');

--validar e submeter prioridade
EXEC DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA;

EXEC DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA;

--verificar se fi criado
SELECT * FROM DBA_RSRC_PLAN_DIRECTIVES WHERE PLAN = 'DAY';
--ativar
ALTER SYSTEM SET RESOURCE_MANAGER_PLAN = 'DAY';


-- novo Curso!

-- Oracle coleta estatisticas para escolher qual melhor Plano de Execu��o

SELECT * FROM DBA_TABLES;
SELECT * FROM DBA_TAB_COLUMNS;
SELECT * FROM DBA_INDEX;
SELECT * FROM DBMS_STATS;

dbms_stats._auto_cascate;      --  analisar o �ndice e a tabela. E isso permite que o Oracle vai decidir quais os �ndices devem ser analisados.
dbms_statis.auto_sample_size;   -- eu vou instruir ao Oracle de fazer uma estimativa inteligente da quantidade de linhas da tabela necess�ria para voc� obter uma boa amostra.
dbms_stats.auto_degree;  --        que vai especificar se � necess�rio executar a an�lise das estat�sticas atrav�s de um processo em paralelo. Isso, claro, vai permitir ao Oracle decidir quantos processadores e quanto n�cleos do hardware, da m�quina, eu vou utilizar no momento em que eu for coletar as minhas estat�sticas.

-- praticando coleta de estatisticas

CREATE TABLE ST as SELECT * FROM all_USERS;

Select * from ST;

CREATE INDEX STI on ST(USERNAME);

ALTER SESSION SET NLS_DATE_FORMAT = 'dd-mm-yy hh24:mi:ss';

SELECT COUNT(*) FROM ST;


SELECT NUM_ROWS, LAST_ANALYZED FROM USER_TABLES WHERE TABLE_NAME= 'ST'; -- nada retornou pois ainda n�o realizei nenhuma coleta de estatistica

SELECT DISTINCT_KEYS, LAST_ANALYZED FROM USER_INDEXES WHERE INDEX_NAME = 'STI';

EXEC DBMS_STATS.GATHER_TABLE_STATS ('SYS','ST');

SELECT NUM_ROWS, LAST_ANALYZED FROM USER_TABLES WHERE TABLE_NAME= 'ST'; -- retornou OK

EXEC DBMS_STATS.GATHER_SCHEMA_STATS ('SYS'); -- altera o Schema das statisticas

SELECT DISTINCT_KEYS, LAST_ANALYZED FROM USER_INDEXES WHERE INDEX_NAME = 'STI';

DROP TABLE ST;
 -- fim modulo estatisticas e In�cio m�dulo ADVISORS
 
 -- B-TREE
 
Create table test_normal (empno varchar2(10), ename varchar2(30), sal number(10), faixa varchar2(10)); 
 Begin 
    For i in 1..1000000 
    Loop 
        Insert into test_normal values(
            to_char(i), dbms_random.string('U',30), 
            dbms_random.value(1000,7000), 'ND'
        ); 
        If mod(i, 10000) = 0 then 
            Commit; 
        End if; 
    End loop; 
End; 
 -- Logo ap�s o comando "Insert", h� uma condi��o "If" que verifica se o resultado da opera��o "mod(i, 10000)" � igual a zero. O operador "mod" retorna o resto da divis�o de "i" por 10000. 
 -- Isso significa que o bloco "Commit" ser� executado a cada 10.000 itera��es do loop.
-- O bloco "Commit" � executado quando a condi��o na etapa anterior � verdadeira. O comando "Commit" � usado para confirmar as altera��es feitas nas transa��es anteriores. Nesse caso, o "Commit" � usado para confirmar
--as inser��es na tabela "test_normal" a cada 10.000 registros.
 
 Select count(*) from TEST_NORMAL;
 
 
 Create table test_random as select /*+ append */ * from test_normal order by dbms_random.random;
 
 SELECT * FROM TEST_RANDOM WHERE EMPNO= '236400';
 
 -- custo sem indice 1892
 
  SELECT * FROM TEST_RANDOM WHERE EMPNO in ('236400','1000','90032','567900');
 -- criando �ndice e comparando o plano de execu��o
 CREATE INDEX IDX_RANDOM_1 on TEST_RANDOM (EMPNO);
 
  SELECT * FROM TEST_RANDOM WHERE EMPNO in ('236400','1000','90032','567900');
 
-- custo com �ndice -> 14

-- Praticando BITMAP
-- setando valor da faixa salarial
UPDATE TEST_RANDOM SET FAIXA = 'Baixa' Where Sal >= '1000' AND SAL <= '3000';
UPDATE TEST_RANDOM SET FAIXA = 'MEDIA' Where Sal >= '3000' AND SAL <= '6000';
UPDATE TEST_RANDOM SET FAIXA = 'ALTA' Where Sal >= '6000' AND SAL <= '7000';

SELECT * FROM TEST_RANDOM WHERE FAIXA = 'MEDIA';
-- custo SEM INDICE 1898

CREATE INDEX IDX_RANDOM_2 on TEST_RANDOM (FAIXA);

SELECT * FROM TEST_RANDOM WHERE FAIXA = 'MEDIA';

-- custo COM  INDICE BITREE 26

-- criando indice BITMAP e APAGANDO o indice BITREE

DROP INDEX IDX_RANDOM_2;

CREATE BITMAP INDEX IDX_RANDOM_2 on TEST_RANDOM (FAIXA);

SELECT * FROM TEST_RANDOM WHERE FAIXA = 'MEDIA';

-- custo COM  INDICE BITMAP 3

-------------------------------------------------------------

-- Tableas Materializadas

-- dropar a tabela
DROP Table test_random;

 Create table test_random as select /*+ append */ * from test_normal order by dbms_random.random;
 
 
SELECT FAIXA COUNT(*) AS NUM_FUNC, SUM(SAL) AS SOMA_SALARIO from test_random GROUP BY FAIXA;
