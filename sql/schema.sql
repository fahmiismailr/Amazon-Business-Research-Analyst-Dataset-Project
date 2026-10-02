CREATE DATABASE amazon_delivery;
USE amazon_delivery;


SELECT 'updated (training)' AS dataset, COUNT(*) AS total_rows FROM updated
UNION ALL
SELECT 'cleaned_test (test)', COUNT(*) FROM cleaned_test
UNION ALL
SELECT 'feature_importance', COUNT(*) FROM feature_importance;


SELECT * from cleaned_test;
SELECT * from updated;
SELECT * from feature_importance;


SELECT ID, COUNT(*) FROM cleaned_test 
	GROUP BY ID HAVING COUNT(*) > 1;
    
ALTER TABLE cleaned_test
    MODIFY ID VARCHAR(20) NOT NULL;
ALTER TABLE cleaned_test
    ADD PRIMARY KEY (ID);


SELECT ID, COUNT(*) FROM updated 
	GROUP BY ID HAVING COUNT(*) > 1;

ALTER TABLE updated
    MODIFY ID VARCHAR(20) NOT NULL;
ALTER TABLE updated
    ADD PRIMARY KEY (ID);