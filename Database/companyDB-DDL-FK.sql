/* SQL "CompanyDB" database query exercises */

USE company;

SELECT COUNT(*) FROM Department;	/* 3개 투플 */
SELECT COUNT(*) FROM Employee;		/* 8개 투플 */
SELECT COUNT(*) FROM Project;		/* 6개 투플 */
SELECT COUNT(*) FROM Works_on;		/* 16개 투플 */


-- Q1: company DB를 초기화하고 실행

DELETE 
FROM 	Employee
where 	Ssn = '123456789';

SELECT COUNT(*) FROM Department;
SELECT COUNT(*) FROM Employee;		/* 1개 투플 삭제 */
SELECT COUNT(*) FROM Project;
SELECT COUNT(*) FROM Works_on;		/* 2개 투플 삭제 */


-- Q2: company DB를 초기화하고 실행

DELETE 
FROM 	Department
where 	Dnumber = 5;

SELECT COUNT(*) FROM Department;	/* 1개 투플 삭제 */
SELECT COUNT(*) FROM Employee;		/* 4개 투플 삭제 */
SELECT COUNT(*) FROM Project;		/* 3개 투플 삭제 */
SELECT COUNT(*) FROM Works_on;		/* 9개 투플 삭제 */


-- Q3: company DB를 초기화하고 실행

DELETE 
FROM 	Department
where 	Dnumber = 1;

SELECT COUNT(*) FROM Department;	/* 모든 투플 삭제 */
SELECT COUNT(*) FROM Employee;		/* 모든 투플 삭제 */
SELECT COUNT(*) FROM Project;		/* 모든 투플 삭제 */
SELECT COUNT(*) FROM Works_on;		/* 모든 투플 삭제 */
