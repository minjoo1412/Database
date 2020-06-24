-- Queries for kleague Sample Database
-- Version 1.0

USE kleague;

DESCRIBE PLAYER;
DESCRIBE TEAM;
DESCRIBE STADIUM;
DESCRIBE SCHEDULE;


-------------------------------------------
-- 1. SELECT 문의 WHERE 절에 사용된 Subquery
-------------------------------------------

-------------------------------------------
-- 1.1 Single Value Subquery (단일값 서브쿼리)
-------------------------------------------

USE kleague;

-- Q: 서브쿼리에 집단함수를 사용 (비연관 서브쿼리)

SELECT 	PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버 
FROM 	PLAYER 
WHERE 	HEIGHT <= (	SELECT	AVG(HEIGHT) 
					FROM	PLAYER ) 
ORDER 	BY PLAYER_NAME; 


-------------------------------------------
-- 1.2 Multi-Value Subquery (다중값 서브쿼리)
-------------------------------------------

-- Q: ‘정현수’ 선수가 소속되어 있는 팀 정보를 검색 (비연관 서브쿼리)

SELECT 	REGION_NAME 연고지명, TEAM_NAME 팀명, E_TEAM_NAME 영문팀명 
FROM 	TEAM 
WHERE 	TEAM_ID = (	SELECT	TEAM_ID 
					FROM	PLAYER 
					WHERE	PLAYER_NAME = '정현수') 		/* 에러: 결과가 2개 이상 */
ORDER 	BY TEAM_NAME;

------------------------------

/* 아래 두 질의는 동일함 */

SELECT 	REGION_NAME 연고지명, TEAM_NAME 팀명, E_TEAM_NAME 영문팀명 
FROM 	TEAM 
WHERE 	TEAM_ID = ANY (	SELECT	TEAM_ID 
						FROM	PLAYER 
						WHERE	PLAYER_NAME = '정현수') 
ORDER 	BY TEAM_NAME;

SELECT 	REGION_NAME 연고지명, TEAM_NAME 팀명, E_TEAM_NAME 영문팀명 
FROM 	TEAM 
WHERE 	TEAM_ID IN (SELECT	TEAM_ID 
					FROM	PLAYER 
					WHERE	PLAYER_NAME = '정현수') 
ORDER 	BY TEAM_NAME;


-------------------------------------------
-- 1.3 Multi-Row Subquery (다중행 서브쿼리)
-------------------------------------------

-- Q: 각 팀에서 제일 키가 작은 선수들을 검색

SELECT	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	(TEAM_ID, HEIGHT) IN (	SELECT	TEAM_ID, MIN(HEIGHT) 
								FROM	PLAYER 
								GROUP	BY TEAM_ID	) 
ORDER 	BY TEAM_ID, PLAYER_NAME;


-- Q: 포지션이 GK인 선수들을 검색.

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, 
		BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER X
WHERE 	EXISTS (	SELECT 	*         /* * 대신 PLAYER의 어떤 속성도 가능 */
					FROM 	PLAYER Y 
					WHERE 	X.PLAYER_ID = Y.PLAYER_ID AND 
							Y.POSITION = 'GK'
		           );


-------------------------------------------
-- 1.4 Correlated Subquery (연관 서브쿼리)
-------------------------------------------

-- Q: 각 팀에서 제일 키가 큰 선수를 검색.

SELECT	TEAM_ID, PLAYER_NAME, HEIGHT
FROM	PLAYER X
WHERE	HEIGHT = (	SELECT	MAX(HEIGHT)
					FROM	PLAYER Y
					WHERE	X.TEAM_ID = Y.TEAM_ID
				 )
ORDER	BY TEAM_ID;

SELECT	TEAM_ID, PLAYER_NAME, HEIGHT
FROM	PLAYER
WHERE	(TEAM_ID, HEIGHT) IN (	SELECT	TEAM_ID, MAX(HEIGHT)
								FROM	PLAYER
								GROUP	BY TEAM_ID
							 )
ORDER	BY TEAM_ID;


-- Q: 소속 팀의 평균 키보다 작은 선수들의 정보를 검색.

SELECT	X.TEAM_ID, X.PLAYER_NAME 선수명, X.POSITION 포지션, X.BACK_NO 백넘버, X.HEIGHT 키 
FROM	PLAYER X
WHERE	X.HEIGHT < (	SELECT	AVG(Y.HEIGHT) 
						FROM	PLAYER Y
						WHERE	X.TEAM_ID = Y.TEAM_ID
					)
ORDER	BY X.TEAM_ID, 키, 선수명;


-- Q: 20120501부터 20120502 사이에 경기가 열렸던 경기장을 조회.

SELECT

	STADIUM_ID ID, STADIUM_NAME 경기장명
FROM	STADIUM ST 
WHERE	EXISTS (	SELECT 	1						/* 1 대신 *도 가능  */
					FROM 	SCHEDULE SC 
					WHERE	ST.STADIUM_ID = SC.STADIUM_ID AND 
							SC.SCHE_DATE BETWEEN '20120501' AND '20120502' 
				);

SELECT *
FROM SCHEDULE S
WHERE S.GUBUN = 'Y'
;


WITH TEMP1 AS(
SELECT T.TEAM_ID, MAX(S.SCHE_DATE) T1S
FROM TEAM T JOIN SCHEDULE S ON T.TEAM_ID = S.HOMETEAM_ID
WHERE GUBUN = 'Y'
GROUP BY TEAM_ID
), TEMP2 AS
(SELECT TEAM_ID, MAX(S.SCHE_DATE) T2S
FROM TEAM T JOIN SCHEDULE S ON T.TEAM_ID = S.AWAYTEAM_ID
WHERE GUBUN = 'Y'
group by TEAM_ID
)
SELECT T1.TEAM_ID, 
	CASE
		WHEN T1S > T2S THEN T1S
        ELSE T2S
	END AS SHEDATE
FROM TEMP1 T1 JOIN TEMP2 T2 ON T1.TEAM_ID = T2.TEAM_ID
GROUP BY TEAM_ID
ORDER BY TEAM_ID ASC
;

WITH TEMP1 AS(
SELECT T.TEAM_ID, COUNT(P.PLAYER_ID) GKS
FROM TEAM T JOIN PLAYER P USING (TEAM_ID)
WHERE P.POSITION = 'GK'
GROUP BY T.TEAM_ID
)
SELECT T2.TEAM_ID, TEMP1.GKS, COUNT(PLAYER.PLAYER_ID)
FROM TEAM T2 JOIN TEMP1 USING (TEAM_ID)
	JOIN PLAYER ON T2.TEAM_ID = PLAYER.TEAM_ID
WHERE TEMP1.GKS >= 4
GROUP BY TEAM_ID
ORDER BY TEAM_ID
;

SELECT T.TEAM_ID
FROM SCHEDULE S JOIN TEAM T ON S.HOMETEAM_ID = T.TEAM_ID
WHERE S.GUBUN = 'Y' AND T.TEAM_ID NOT IN (select B.TEAM_ID
											FROM SCHEDULE S1 JOIN TEAM B ON S1.HOMETEAM_ID = B.TEAM_ID
                                            WHERE S1.HOME_SCORE < AWAY_SCORE)
GROUP BY TEAM_ID
ORDER BY TEAM_ID
;



-- Q: 소속이 K02 팀이면서 포지션이 GK인 선수들을 검색. (INTERSECT 연산)

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, 
		BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER X
WHERE 	TEAM_ID = 'K02' AND 
		EXISTS (	SELECT 	1						/* 1 대신 *도 가능  */
					FROM 	PLAYER Y 
					WHERE 	X.PLAYER_ID = Y.PLAYER_ID AND 
							Y.POSITION = 'GK'
				) 
ORDER 	BY 1, 2, 3, 4, 5;

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, 
		BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER X
WHERE 	TEAM_ID = 'K02' AND POSITION = 'GK';


-- Q: 소속이 K02 팀이면서 포지션이 MF가 아닌 선수들을 검색 (EXCEPT 연산)

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER X
WHERE 	TEAM_ID = 'K02' AND 
		NOT EXISTS (	SELECT 	1 
						FROM 	PLAYER Y 
						WHERE 	Y.PLAYER_ID = X.PLAYER_ID AND POSITION = 'MF'
					) 
ORDER 	BY 1, 2, 3, 4, 5;

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER X
WHERE 	TEAM_ID = 'K02' AND POSITION <> 'MF';


-- Q: 브라질 혹은 러시아 출신의 선수가 있는 팀을 검색하시오.

SELECT	TEAM_ID, TEAM_NAME
FROM	TEAM T
WHERE	TEAM_ID = ANY 	(
							SELECT	TEAM_ID
							FROM	PLAYER P
							WHERE	T.TEAM_ID = P.TEAM_ID AND 
									(P.NATION = '브라질' OR P.NATION = '러시아')
						);

SELECT	TEAM_ID, TEAM_NAME
FROM	TEAM T
WHERE	TEAM_ID IN 	(
							SELECT	TEAM_ID
							FROM	PLAYER P
							WHERE	T.TEAM_ID = P.TEAM_ID AND 
									(P.NATION = '브라질' OR P.NATION = '러시아')
					);
                        
                        
-------------------------------------------
-- 1.4 Join과 subquery의 차이
------------------------------------------- 

SELECT	T.TEAM_NAME, P.PLAYER_NAME						/* 피연산자 어느 쪽의 속성도 올 수 있음 */
FROM	TEAM T JOIN PLAYER P ON T.TEAM_ID = P.TEAM_ID;	/* 480개 투플 */

SELECT	T.TEAM_NAME										/* 메인 쿼리에 사용된 테이블의 속성만 올 수 있음 */
FROM	TEAM T
WHERE	T.TEAM_ID IN (	SELECT	P.TEAM_ID
						FROM 	PLAYER P
						WHERE	T.TEAM_ID = P.TEAM_ID
					  );								/* 15개 투플 */


-------------------------------------------
-- 2. SELECT 문의 WHERE 절 이외의 위치에 사용된 Subquery
-------------------------------------------

-------------------------------------------
-- 2.1 SELECT 문의 SELECT 절 (Scalar Subquery)
-------------------------------------------

-- Q: 선수 정보와 해당 선수가 속한 팀의 평균 키를 함께 검색.

SELECT 	TEAM_ID, PLAYER_NAME 선수명, HEIGHT 키, 
		(
			SELECT	ROUND(AVG(HEIGHT),2) 
			FROM	PLAYER Y 
			WHERE	X.TEAM_ID = Y.TEAM_ID
		) 팀평균키 
FROM	PLAYER X
ORDER	BY TEAM_ID;


-- Q: 팀명과 팀의 소속 선수수를 검색

SELECT 	TEAM_ID, TEAM_NAME,
		(
			SELECT	COUNT(*)
			FROM	PLAYER Y 
			WHERE	X.TEAM_ID = Y.TEAM_ID
		) 팀인원수
FROM	TEAM X
ORDER	BY TEAM_ID;


-- Q: 각 팀의 최종 경기일을 검색

SELECT	TEAM_ID, TEAM_NAME, 
		(	SELECT	MAX(SCHE_DATE)
			FROM	SCHEDULE S
            WHERE	T.TEAM_ID = S.HOMETEAM_ID OR T.TEAM_ID = S.AWAYTEAM_ID
		) '최종 경기일'
FROM	TEAM T;


-------------------------------------------
-- 2.2 SELECT 문의 FROM 절 (inline view, 혹은 dynamic view라 함)
-------------------------------------------

-- Q: K09 팀의 선수 이름, 포지션, 백넘버를 검색

SELECT	PLAYER_NAME, POSITION, BACK_NO
FROM	(
			SELECT	TEAM_ID, PLAYER_ID, PLAYER_NAME, POSITION, BACK_NO
			FROM	PLAYER
			ORDER 	BY PLAYER_ID ASC
		) AS TEMP						/* In MySQL, every derived table must have its own alias. */
WHERE	TEAM_ID = 'K09';

SELECT * FROM TEMP;			/* 에러: TEMP 테이블이 존재하지 않음 */
DESCRIBE TEMP;				/* 에러: TEMP 테이블이 존재하지 않음 */


-- Q: 포지션이 MF인 선수들의 소속팀명 및 선수 정보를 검색

SELECT	T.TEAM_NAME 팀명, P.PLAYER_NAME 선수명, P.BACK_NO 백넘버 
FROM	(
			SELECT	TEAM_ID, PLAYER_NAME, BACK_NO 
			FROM	PLAYER 
			WHERE	POSITION = 'MF'
		) P, TEAM T 
WHERE	P.TEAM_ID = T.TEAM_ID 
ORDER	BY 팀명, 선수명; 


-- Q: 키가 제일 큰 5명 선수들의 정보를 검색 (top-N query)

SELECT 	PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버,
		HEIGHT 키 
FROM 	(
			SELECT 	PLAYER_NAME, POSITION, BACK_NO, HEIGHT 
			FROM 	PLAYER 
			WHERE 	HEIGHT IS NOT NULL 
			ORDER 	BY HEIGHT DESC
		) AS TEMP
LIMIT	5;


-------------------------------------------
-- 2.3 SELECT 문의 HAVING 절
-------------------------------------------

-- Q: 평균키가 K02 (삼성 블루윙즈) 팀의 평균키보다 작은 팀의 이름과 해당 팀의 평균키를 검색

SELECT	P.TEAM_ID 팀코드, T.TEAM_NAME 팀명, AVG(P.HEIGHT) 평균키 
FROM	PLAYER P JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID 
GROUP	BY P.TEAM_ID										/* TEAM_NAME을 GROUP BY에 포함하지 않아도 됨. */ 
HAVING	AVG(P.HEIGHT) < (	SELECT	AVG(HEIGHT) 
							FROM	PLAYER 
							WHERE	TEAM_ID ='K02' 
						);


-------------------------------------------
-- 3. 갱신문의 Subquery
-------------------------------------------

-------------------------------------------
-- 3.1 Subquery : UPDATE 문
-------------------------------------------

ALTER	TABLE	TEAM
ADD		COLUMN	STADIUM_NAME VARCHAR(40);

SET sql_safe_updates=0;	

UPDATE	TEAM T 
SET		T.STADIUM_NAME = (	SELECT	S.STADIUM_NAME 
							FROM	STADIUM S 
							WHERE	T.STADIUM_ID = S.STADIUM_ID); 
                            
SELECT	TEAM_NAME, STADIUM_ID, STADIUM_NAME
FROM	TEAM;

SET sql_safe_updates=1;	


-------------------------------------------
-- 3.2 Subquery : INSERT 문
-------------------------------------------

/* 에러: MySQL에서는 같은 테이블에서 SELECT하여 INSERT/UPDATE 할 수 없음. */
INSERT	INTO	PLAYER (PLAYER_ID, PLAYER_NAME, TEAM_ID) 
VALUES	(
			(
				SELECT	MAX(PLAYER_ID) + 1 
				FROM 	PLAYER
            ), 
			'홍길동', 'K06'
		); 


-------------------------------------------
-- 4. View
-------------------------------------------

-- DDL: 뷰 생성
 
CREATE 	VIEW V_PLAYER_TEAM AS 
SELECT 	P.PLAYER_NAME, P.POSITION, P.BACK_NO, P.TEAM_ID, T.TEAM_NAME 
FROM 	PLAYER P JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID; 

CREATE 	VIEW V_PLAYER_TEAM_FILTER AS 
SELECT 	PLAYER_NAME, POSITION, BACK_NO, TEAM_NAME 
FROM 	V_PLAYER_TEAM 
WHERE 	POSITION IN ('GK', 'MF'); 


-- Q: 뷰에 대한 질의와 변환된 질의

SELECT 	PLAYER_NAME, POSITION, BACK_NO, TEAM_ID, TEAM_NAME 
FROM 	V_PLAYER_TEAM 
WHERE 	PLAYER_NAME LIKE '황%';

SELECT 	P.PLAYER_NAME, P.POSITION, P.BACK_NO, P.TEAM_ID, T.TEAM_NAME
FROM 	PLAYER P JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID
WHERE 	P.PLAYER_NAME LIKE '황%';


-- Q: 뷰에 대한 질의와 변환된 질의

SELECT 	PLAYER_NAME, POSITION, BACK_NO, TEAM_NAME 
FROM 	V_PLAYER_TEAM_FILTER 
WHERE 	PLAYER_NAME LIKE '황%';

SELECT 	P.PLAYER_NAME, P.POSITION, P.BACK_NO, T.TEAM_NAME
FROM 	PLAYER P JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID
WHERE 	POSITION IN ('GK', 'MF') AND 
		P.PLAYER_NAME LIKE '황%';

