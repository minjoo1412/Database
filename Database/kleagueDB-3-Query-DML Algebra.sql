-- Queries for kleague Sample Database
-- Version 1.0

USE kleague;

DESCRIBE PLAYER;
DESCRIBE TEAM;
DESCRIBE STADIUM;
DESCRIBE SCHEDULE;


-------------------------------------------
-- 1. DML Algebra : 집합 연산자
-------------------------------------------

-------------------------------------------
-- 1.1 UNION 연산
-------------------------------------------

/* UNION 연산은 OR 혹은 IN 연산으로 표현 가능 */

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키    /* 아래 셋 모두 동일한 결과 */
FROM 	PLAYER
WHERE 	TEAM_ID = 'K02' 
UNION 
SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER
WHERE 	TEAM_ID = 'K07'
ORDER	BY 선수명;

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K02' OR TEAM_ID = 'K07'
ORDER	BY 선수명;

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID IN ('K02','K07')
ORDER	BY 선수명;

------------------------------

/* UNION ALL과 UNION DISTINCT */

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K02' 
UNION 	ALL
SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	POSITION = 'GK'
ORDER	BY 팀코드, 선수명, 포지션;

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K02' 
UNION 	DISTINCT
SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	POSITION = 'GK'
ORDER	BY 팀코드, 선수명, 포지션;				/* 디폴트임 */

------------------------------

/* union compatible 개념 */

SELECT 	'P' 구분코드, POSITION 포지션, AVG(HEIGHT) 평균키 
FROM 	PLAYER 
GROUP 	BY POSITION 
UNION 
SELECT 	'T' 구분코드, TEAM_ID 팀명, AVG(HEIGHT) 평균키 
FROM 	PLAYER 
GROUP 	BY TEAM_ID 
ORDER 	BY 1;


-------------------------------------------
-- 1.2 INTERSECT 연산
-------------------------------------------

-- Q: 소속이 K02 팀이면서 포지션이 GK인 선수들을 검색. (INTERSECT 연산)

/* 에러: MySQL에서는 INTERSECT 연산을 지원 안함 */

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 	
FROM 	PLAYER
WHERE 	TEAM_ID = 'K02' 
INTERSECT 
SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	POSITION = 'GK' 
ORDER 	BY 1, 2, 3, 4, 5;

/* INTERSECT 연산은 AND 혹은 subquery로 표현 가능 (아래 셋 모두 동일한 결과) */

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K02' AND POSITION = 'GK' 
ORDER 	BY 1, 2, 3, 4, 5;

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER
WHERE 	TEAM_ID = 'K02' AND 
		PLAYER_ID IN (	SELECT 	PLAYER_ID 
						FROM 	PLAYER 
						WHERE 	POSITION = 'GK') 
ORDER 	BY 1, 2, 3, 4, 5;

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER X
WHERE 	X.TEAM_ID = 'K02' AND 
		EXISTS (	SELECT 	1 
					FROM 	PLAYER Y 
					WHERE 	Y.PLAYER_ID = X.PLAYER_ID AND Y.POSITION = 'GK') 
ORDER 	BY 1, 2, 3, 4, 5;


-------------------------------------------
-- 1.3 EXCEPT 연산
-------------------------------------------

-- Q: 소속이 K02 팀이면서 포지션이 MF가 아닌 선수들을 검색

/* 에러: MySQL에서는 EXCEPT 연산을 지원 안함 */

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 		
FROM 	PLAYER
WHERE 	TEAM_ID = 'K02' 
EXCEPT
SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	POSITION = 'MF' 
ORDER 	BY 1, 2, 3, 4, 5; 

/* EXCEPT 연산은 AND 혹은 subquery로 표현 가능 (아래 셋 모두 동일한 결과) */

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K02' AND POSITION <> 'MF' 
ORDER 	BY 1, 2, 3, 4, 5;

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K02' AND 
		PLAYER_ID NOT IN (	SELECT  PLAYER_ID
							FROM 	PLAYER 
							WHERE	POSITION = 'MF') 
ORDER 	BY 1, 2, 3, 4, 5; 

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER X
WHERE 	X.TEAM_ID = 'K02' AND 
		NOT EXISTS (	SELECT 	1 
						FROM 	PLAYER Y 
						WHERE 	Y.PLAYER_ID = X.PLAYER_ID AND POSITION = 'MF') 
ORDER 	BY 1, 2, 3, 4, 5;


-------------------------------------------
-- 2. DML Algebra : WHERE 절 JOIN (inner join 기능만 지원함)
-------------------------------------------

-- Q: 선수와 팀의 관계

/* WHERE 절 및 FROM 절 조인 조건 표현법 */

SELECT 	PLAYER.PLAYER_NAME, PLAYER.BACK_NO, PLAYER.TEAM_ID, 
		TEAM.TEAM_NAME, TEAM.REGION_NAME 
FROM 	PLAYER, TEAM 
WHERE 	PLAYER.TEAM_ID = TEAM.TEAM_ID;

SELECT 	PLAYER.PLAYER_NAME, PLAYER.BACK_NO, PLAYER.TEAM_ID, 
		TEAM.TEAM_NAME, TEAM.REGION_NAME 
FROM 	PLAYER JOIN TEAM ON PLAYER.TEAM_ID = TEAM.TEAM_ID; 

/* Table alias의 사용 */

SELECT 	P.PLAYER_NAME 선수명, P.BACK_NO 백넘버, P.TEAM_ID 팀코드, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지 
FROM 	PLAYER P, TEAM T 
WHERE 	P.TEAM_ID = T.TEAM_ID;

SELECT 	P.PLAYER_NAME 선수명, P.BACK_NO 백넘버, P.TEAM_ID 팀코드, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지 
FROM 	PLAYER P JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID; 

/* 조인 조건과 검색 조건 */

SELECT 	P.PLAYER_NAME 선수명, P.BACK_NO 백넘버, P.TEAM_ID 팀코드,
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지
FROM 	PLAYER P, TEAM T 
WHERE 	P.TEAM_ID = T.TEAM_ID AND P.POSITION = 'GK'		/* 조인 조건과 검색 조건이 WHERE 절에서 같이 서술됨 */
ORDER 	BY P.BACK_NO;    

SELECT 	P.PLAYER_NAME 선수명, P.BACK_NO 백넘버, P.TEAM_ID 팀코드,
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지 
FROM 	PLAYER P JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID	/* 조인 조건은 FROM 절 */
WHERE 	P.POSITION = 'GK'								/* 검색 조건은 WHERE 절 */
ORDER 	BY P.BACK_NO;


-- Q: 팀과 경기장의 관계

SELECT 	T.TEAM_NAME, T.REGION_NAME, T.STADIUM_ID, 
		S.STADIUM_NAME, S.SEAT_COUNT 
FROM 	TEAM T, STADIUM S
WHERE	T.STADIUM_ID = S.STADIUM_ID;

SELECT 	T.TEAM_NAME, T.REGION_NAME, T.STADIUM_ID, 
		S.STADIUM_NAME, S.SEAT_COUNT 
FROM 	TEAM T JOIN STADIUM S ON T.STADIUM_ID = S.STADIUM_ID;


-- Q: 선수, 팀, 경기장의 관계 (다중 테이블 조인)

SELECT 	P.PLAYER_NAME 선수명, P.POSITION 포지션, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지, 
		S.STADIUM_NAME 전용구장, S.SEAT_COUNT 좌석수
FROM 	PLAYER P, TEAM T, STADIUM S 
WHERE 	P.TEAM_ID = T.TEAM_ID AND T.STADIUM_ID = S.STADIUM_ID 
ORDER 	BY 선수명;

SELECT 	P.PLAYER_NAME 선수명, P.POSITION 포지션, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지, 
		S.STADIUM_NAME 전용구장, S.SEAT_COUNT 좌석수
FROM 	PLAYER P JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID
		JOIN STADIUM S ON T.STADIUM_ID = S.STADIUM_ID 
ORDER 	BY 선수명;

------------------------------

SELECT 	P.PLAYER_NAME 선수명, P.POSITION 포지션, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지, 
		S.STADIUM_NAME 전용구장, S.SEAT_COUNT 좌석수
FROM 	TEAM T JOIN STADIUM S ON T.STADIUM_ID = S.STADIUM_ID 
		JOIN PLAYER P ON P.TEAM_ID = T.TEAM_ID
ORDER 	BY 선수명;


-- Q: 직원과 임금 등급 (비둥가 조인)

USE company;

CREATE TABLE SALARY_GRADE (
	GRADE	TINYINT		NOT NULL,
    LOW		MEDIUMINT	NOT NULL,
    HIGH	MEDIUMINT	NOT NULL,
	CONSTRAINT 	PK_SALARY_GRADE 	PRIMARY KEY (GRADE)
);

INSERT INTO SALARY_GRADE VALUES
(1, 50000, 100000),
(2, 40000, 49999),
(3, 30000, 39999),
(4, 20000, 29999),
(5, 10000, 19999),
(6, 0, 9999);

SELECT * FROM SALARY_GRADE;
SELECT CONCAT(FNAME, ' ', MINIT, '. ', LNAME) AS 'FULL NAME', SALARY FROM EMPLOYEE;

SELECT 	CONCAT(E.FNAME, ' ', E.MINIT, '. ', E.LNAME) AS 'FULL NAME', E.SALARY, S.GRADE 
FROM 	EMPLOYEE E, SALARY_GRADE G 
WHERE 	E.SALARY BETWEEN G.LOW AND G.HIGH;

DROP TABLE SALARY_GRADE;
USE kleague;


-------------------------------------------
-- 3. DML Algebra : FROM 절 JOIN
-------------------------------------------

-------------------------------------------
-- 3.1 INNER JOIN
-------------------------------------------

-- Q: ON 절과 USING 절의 사용 조건

/* 조인 속성의 명칭이 같을 때, ON 절 및 USING 절 모두 사용 가능함. */

SELECT 	TEAM_NAME, TEAM.STADIUM_ID, STADIUM_NAME 				 
FROM 	TEAM JOIN STADIUM ON TEAM.STADIUM_ID = STADIUM.STADIUM_ID 
ORDER 	BY STADIUM_ID;

SELECT 	TEAM_NAME, TEAM.STADIUM_ID, STADIUM_NAME
FROM 	TEAM JOIN STADIUM USING (STADIUM_ID) 
ORDER 	BY STADIUM_ID;

/* 조인 속성의 명칭이 다를 때, ON절을 사용해야 함. (USING 절은 사용할 수 없음.) */

SELECT	S.STADIUM_ID, SCHE_DATE, 
		TEAM_NAME AS HOME_TEAM_NAME, AWAYTEAM_ID, 
		HOME_SCORE, AWAY_SCORE
FROM	SCHEDULE S JOIN TEAM T ON S.HOMETEAM_ID = T.TEAM_ID;


-- Q: ON 절과 USING 절의 출력 차이

WITH TEAM_TEMP AS
(
	SELECT	TEAM_ID, TEAM_NAME, STADIUM_ID
    FROM	TEAM
),
STADIUM_TEMP AS
(
	SELECT 	STADIUM_ID, STADIUM_NAME, SEAT_COUNT
    FROM	STADIUM
)
SELECT	*
FROM	TEAM_TEMP T JOIN STADIUM_TEMP S ON T.STADIUM_ID = S.STADIUM_ID;		/* 속성의 순서에 주의 */

WITH TEAM_TEMP AS
(
	SELECT	TEAM_ID, TEAM_NAME, STADIUM_ID
    FROM	TEAM
),
STADIUM_TEMP AS
(
	SELECT 	STADIUM_ID, STADIUM_NAME, SEAT_COUNT
    FROM	STADIUM
)
SELECT	*
FROM	TEAM_TEMP JOIN STADIUM_TEMP USING (STADIUM_ID);				/* 속성의 순서에 주의 */


-- Q: 다중 테이블 조인 1
-- GK 포지션의 선수 마다 연고지명, 팀명, 구장명을 출력함. 

SELECT 	PLAYER_NAME 선수명, POSITION 포지션, 
		REGION_NAME 연고지, TEAM_NAME 팀명, STADIUM_NAME 구장명 
FROM 	PLAYER JOIN TEAM ON PLAYER.TEAM_ID = TEAM.TEAM_ID
		JOIN STADIUM ON TEAM.STADIUM_ID = STADIUM.STADIUM_ID
WHERE	POSITION ='GK'
ORDER 	BY 선수명;

SELECT 	PLAYER_NAME 선수명, POSITION 포지션, 
		REGION_NAME 연고지명, TEAM_NAME 팀명, STADIUM_NAME 구장명 
FROM 	PLAYER JOIN TEAM USING (TEAM_ID) 
		JOIN STADIUM USING (STADIUM_ID) 
WHERE 	POSITION = 'GK' 
ORDER 	BY 선수명;


-- Q: 다중 테이블 조인 2
-- 홈팀이 3점 이상 차이로 승리한 경기의 경기장 이름, 경기 일정, 홈팀 이름과 원정팀 이름을 출력함.

/* step 1 */

SELECT 	*
FROM 	SCHEDULE
WHERE 	HOME_SCORE >= AWAY_SCORE + 3;

/* step 2 */

SELECT 	STADIUM_NAME AS 경기장명, SCHE_DATE AS 경기일정, 
		HT.TEAM_NAME AS 홈팀명, AT.TEAM_NAME AS 원정팀명, 
		HOME_SCORE AS '홈팀 점수', AWAY_SCORE AS '원정팀 점수' 
FROM 	SCHEDULE SC JOIN STADIUM ST ON SC.STADIUM_ID = ST.STADIUM_ID 
		JOIN TEAM HT ON SC.HOMETEAM_ID = HT.TEAM_ID 
		JOIN TEAM AT ON SC.AWAYTEAM_ID = AT.TEAM_ID 
WHERE 	HOME_SCORE >= AWAY_SCORE + 3;


-------------------------------------------
-- 3.2 NATURAL JOIN
-------------------------------------------

-- Q: NATURAL JOIN과 INNER JOIN의 출력 차이

SELECT 	* 	
FROM 	PLAYER NATURAL JOIN TEAM; 					/* TEAM_ID가 맨 앞에 한 번만 나옴 */			

SELECT 	* 
FROM 	PLAYER INNER JOIN TEAM ON PLAYER.TEAM_ID = TEAM.TEAM_ID; 		/* 결과에 TEAM_ID가 두 번 나옴 */		

SELECT 	* 
FROM 	PLAYER INNER JOIN TEAM USING (TEAM_ID); 	/* NATURAL JOIN과 결과가 동이함. */


-- Q: NATURAL JOIN은 두 테이블 간의 동일한 이름(같은 데이터 유형이어야 함)을 갖는 
-- “모든” 컬럼 (조인 속성)들에 대해 equi-join을 수행함. 

SELECT 	TEAM_NAME, STADIUM_ID, STADIUM_NAME 	/* 공톻되는 애츠리뷰트가 STADIUM_ID, ADDRESS, DDD, TEL 네 개가 있음. */ 
FROM 	TEAM NATURAL JOIN STADIUM 				/* 이 네 개 값이 모두 일치하는 경우는 없으므로, 결과가 공집합 */
ORDER 	BY STADIUM_ID;

SELECT 	* 
FROM 	TEAM JOIN STADIUM USING (STADIUM_ID); 	/* STADIUM_ID만으로 조인하므로 실행됨 */

ALTER TABLE STADIUM
DROP COLUMN ADDRESS,
DROP COLUMN DDD,
DROP COLUMN TEL;

SELECT 	TEAM_NAME, STADIUM_ID, STADIUM_NAME 	/* 공톻되는 애츠리뷰트는 STADIUM_ID만 존재 */ 
FROM 	TEAM NATURAL JOIN STADIUM 
ORDER 	BY STADIUM_ID;


-- kleague DB를 초기화한 후, 아래 질의를 실행

-- Q: 선수, 팀, 경기장 테이블을 모두 조인하는 가장 간단한 형태 

SELECT 	PLAYER_ID, PLAYER_NAME, POSITION, BACK_NO, TEAM_NAME, STADIUM_NAME 	
FROM 	PLAYER NATURAL JOIN TEAM
		INNER JOIN STADIUM USING (STADIUM_ID);


-------------------------------------------
-- 3.3 LEFT/RIGHT OUTER JOIN
-------------------------------------------

-- Q: TEAM 테이블과 STADIUM 테이블 간의 OUTER JOIN
-- TEAM에는 2개 투플, STADIUM에는 2개 투플이 INNER JOIN이 불가능한 투플임.

ALTER TABLE 	TEAM
MODIFY COLUMN 	STADIUM_ID	CHAR(3);		/* NOT NULL 제약조건을 제거 */

INSERT INTO TEAM (TEAM_ID, REGION_NAME, TEAM_NAME, STADIUM_ID) VALUES 
('K16','서울','MBC청룡', NULL),
('K17','인천','삼미슈퍼스타즈', NULL);

SELECT	TEAM_ID, TEAM_NAME, REGION_NAME, STADIUM_ID		/* 17개 팀, 그 중 2개 팀은 전용구장이 없음 */
FROM	TEAM;

SELECT	STADIUM_ID, STADIUM_NAME, SEAT_COUNT			/* 20개 경기장, 그 중 5개 경기장은 전용구장이 아님 */
FROM	STADIUM;

------------------------------

SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, TEAM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM JOIN STADIUM USING (STADIUM_ID)
ORDER 	BY TEAM_ID;

SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, TEAM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM LEFT JOIN STADIUM USING (STADIUM_ID) 
ORDER 	BY TEAM_ID;

SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, TEAM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM RIGHT JOIN STADIUM USING (STADIUM_ID) 
ORDER 	BY TEAM_ID;

/* 에러: MySQL은 Full Join을 지원하지 않음 */
SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, TEAM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM FULL JOIN STADIUM ON TEAM.STADIUM_ID = STADIUM.STADIUM_ID 
ORDER 	BY TEAM_ID;

SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, TEAM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM LEFT JOIN STADIUM USING (STADIUM_ID) 
UNION
SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, TEAM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM RIGHT JOIN STADIUM USING (STADIUM_ID) 
ORDER 	BY TEAM_ID;


-------------------------------------------
-- 3.4 CROSS JOIN (Cartesian Product)
-------------------------------------------

-- kleague DB를 초기화한 후, 아래 질의를 실행

SELECT  TEAM_ID, TEAM_NAME, TEAM.STADIUM_ID, STADIUM_NAME 
FROM 	TEAM CROSS JOIN STADIUM							/* 조인 조건 혹은 조인 애트르비튜를 사용하지 않음 */
ORDER 	BY TEAM_ID;

SELECT	COUNT(*) 
FROM 	(
			SELECT  TEAM_ID, TEAM_NAME, TEAM.STADIUM_ID, STADIUM_NAME 
			FROM 	TEAM CROSS JOIN STADIUM
			ORDER 	BY TEAM_ID
		) AS TEMP;

/* 주의: CROSS JOIN에 조인 조건 혹은 조인 애트르비튜를 사용하면, JOIN 혹은  INNER JOIN과 같은 결과임 */
SELECT  TEAM_ID, TEAM_NAME, TEAM.STADIUM_ID, STADIUM_NAME 
FROM 	TEAM CROSS JOIN STADIUM ON TEAM.STADIUM_ID = STADIUM.STADIUM_ID 
ORDER 	BY TEAM_ID;


-------------------------------------------
-- 4. DML Algebra : SELF JOIN
-------------------------------------------

USE		company;

SELECT	*
FROM	employee;

SELECT	emp.Ssn, CONCAT(emp.Fname, ', ', emp.Minit, '. ', emp.Lname) AS Employee, 
		mgr.Ssn, CONCAT(mgr.Fname, ', ', mgr.Minit, '. ', mgr.Lname) AS Manager
FROM  	employee emp JOIN employee mgr ON emp.Super_ssn=mgr.ssn;

------------------------------

SELECT	CONCAT(emp.Fname, ', ', emp.Minit, '. ', emp.Lname) AS Employee, 
		CONCAT(mgr.Fname, ', ', mgr.Minit, '. ', mgr.Lname) AS Manager
FROM  	employee emp JOIN employee mgr ON emp.Super_ssn=mgr.ssn;

SELECT	CONCAT(emp.Fname, ', ', emp.Minit, '. ', emp.Lname) AS Employee, 
		CONCAT(mgr.Fname, ', ', mgr.Minit, '. ', mgr.Lname) AS Manager
FROM  	employee emp LEFT JOIN employee mgr ON emp.Super_ssn=mgr.ssn;

SELECT 	CONCAT(emp.Fname, ', ', emp.Minit, '. ', emp.Lname) AS Employee, 
		CONCAT(mgr.Fname, ', ', mgr.Minit, '. ', mgr.Lname) AS Manager,
        CONCAT(mgrOfMgr.Fname, ', ', mgrOfMgr.Minit, '. ', mgrOfMgr.Lname) AS ManagerOfManager
FROM	employee emp LEFT JOIN employee mgr ON emp.Super_ssn=mgr.ssn
		LEFT JOIN employee mgrOfMgr ON mgr.Super_ssn = mgrOfMgr.ssn;

------------------------------

SELECT	emp.Ssn, CONCAT(emp.Fname, ', ', emp.Minit, '. ', emp.Lname) AS Employee, 
		mgr.Ssn, CONCAT(mgr.Fname, ', ', mgr.Minit, '. ', mgr.Lname) AS Manager
FROM  	employee emp JOIN employee mgr on emp.Super_ssn=mgr.ssn
where	mgr.Fname='Franklin' and mgr.Lname='Wong';

SELECT	emp.Ssn, CONCAT(emp.Fname, ', ', emp.Minit, '. ', emp.Lname) AS Employee, 
		mgr.Ssn, CONCAT(mgr.Fname, ', ', mgr.Minit, '. ', mgr.Lname) AS Manager
FROM  	employee emp JOIN employee mgr on emp.Super_ssn=mgr.ssn
where	emp.Fname='Franklin' and emp.Lname='Wong';


-------------------------------------------
-- 5. CTE와 With 절
-------------------------------------------

-------------------------------------------
-- 5.1 CTE
-------------------------------------------

USE		kleague;

-- Q9: CTE와 WITH 절

WITH 	TEMP AS 
(
		SELECT	TEAM_NAME, STADIUM_ID, STADIUM_NAME
		FROM 	TEAM JOIN STADIUM USING (STADIUM_ID)
)
SELECT	TEMP.TEAM_NAME, TEMP.STADIUM_NAME
FROM	TEMP;

/* 버전 8 이전 버전으로는 아래와 같이 할 수 있음. */

SELECT	TEAM_NAME, STADIUM_NAME
FROM	(
			SELECT	TEAM_NAME, STADIUM_ID, STADIUM_NAME
			FROM 	TEAM JOIN STADIUM USING (STADIUM_ID)
		) AS TEMP;


-- Q10 : Multiple CTE
-- SCHEDULE 테이블에서 STADIUM_ID, HOMETEAM_ID, AWAYTEAM_ID를 
-- 각각 경기장명, 홈팀명, 어웨이팀명으로 출력하시오.

WITH TEMP1_SCHEDULE AS 			/* 홈팀명을 갖는 SCHEDULE */
(
		SELECT 	S.STADIUM_ID, SCHE_DATE, TEAM_NAME AS HOMETEAM_NAME, AWAYTEAM_ID, 
				HOME_SCORE, AWAY_SCORE
		FROM	SCHEDULE S JOIN TEAM T ON S.HOMETEAM_ID = T.TEAM_ID
),
TEMP2_SCHEDULE AS				/* 홈팀명, 어웨이팀명을 갖는 SCHEDULE */
(
		SELECT	T1.STADIUM_ID, SCHE_DATE, HOMETEAM_NAME, TEAM_NAME AS AWAYTEAM_NAME,
				HOME_SCORE, AWAY_SCORE
		FROM	TEMP1_SCHEDULE T1 JOIN TEAM T ON T1.AWAYTEAM_ID = T.TEAM_ID
)
SELECT	STADIUM_NAME 경기장명, SCHE_DATE, HOMETEAM_NAME 홈팀명, AWAYTEAM_NAME 어웨이팀명, 
		HOME_SCORE, AWAY_SCORE
FROM	TEMP2_SCHEDULE T2 JOIN STADIUM S ON T2.STADIUM_ID = S.STADIUM_ID;


-------------------------------------------
-- 5.2 Recursive CTE
-------------------------------------------

-- Q: 수열 출력

WITH RECURSIVE cte AS 
(
	SELECT  1 AS n
	UNION	ALL
	SELECT  n + 1 FROM cte WHERE n < 5
)
SELECT 	* FROM 	cte;

WITH RECURSIVE cte(n) AS 
(
	SELECT  1
	UNION	ALL
	SELECT  n + 1 FROM cte WHERE n < 5
)
SELECT 	* FROM 	cte;


-- Q: CTE와 Type casting

WITH RECURSIVE cte AS 
(
	SELECT	1 AS n, 'abc' AS str			/* 예러: str의 데이터 타입은 CHAR(3) */
	UNION	ALL
	SELECT	n + 1, CONCAT(str, str) FROM cte WHERE n < 3
)
SELECT * FROM cte;

WITH RECURSIVE cte AS 
(
	SELECT	1 AS n, CAST('abc' AS CHAR(30)) AS str
	UNION 	ALL
	SELECT	n + 1, CONCAT(str, str) FROM cte WHERE n < 4
)
SELECT	* FROM cte;

WITH RECURSIVE cte(n,str) AS 
(
	SELECT	1, CAST('abc' AS CHAR(30))
	UNION 	ALL
	SELECT	n + 1, CONCAT(str, str) FROM cte WHERE n < 4
)
SELECT	* FROM cte;


-------------------------------------------
-- 5.3 Recursive CTE의 사용 예
-------------------------------------------

-- Q: Fibonacci Series

WITH RECURSIVE fibonacci (n, fib_n, next_fib_n) AS 
(
	SELECT  1, 0, 1
	UNION  ALL
	SELECT  n + 1, next_fib_n, fib_n + next_fib_n 
	FROM   fibonacci 
	WHERE n < 10
)
SELECT 	*  FROM 	fibonacci;


-- Q: Data Series Generation

WITH RECURSIVE DATES (DATE) AS 
( 
	SELECT CAST(MIN(SCHE_DATE) AS DATE) FROM SCHEDULE		/* Casting 하지 않으면 에러 */
		UNION ALL 
	SELECT DATE + INTERVAL 1 DAY 
	FROM  DATES
	WHERE DATE + INTERVAL 1 DAY <= '2012-03-25'
) 
SELECT 	DATES.DATE, COALESCE(COUNT(*),0) AS NO_OF_GAMES 
FROM 	DATES LEFT JOIN SCHEDULE ON DATES.DATE = SCHEDULE.SCHE_DATE 
GROUP	BY DATES.DATE 
ORDER 	BY DATES.DATE;


-- Q: Hierarchical Query

USE		company;

WITH RECURSIVE employee_paths (Ssn, Fname, Minit, Lname, path) AS
(
		SELECT	Ssn, Fname, Minit, Lname, CAST(Ssn AS CHAR(200))
        FROM	employee
        WHERE	Super_ssn IS NULL
        UNION	ALL
        SELECT	e.Ssn, e.Fname, e.Minit, e.Lname, CONCAT(ep.path, ':', e.Ssn)
        FROM	employee_paths ep join employee e ON ep.Ssn = e.Super_ssn
)
SELECT	*
FROM	employee_paths
ORDER	BY path;
