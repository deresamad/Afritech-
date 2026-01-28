-- Table Creation
CREATE TABLE AfriTech_Data( 
    CustomerID TEXT,
    CustomerName TEXT,
    Region TEXT,
    Age INT,
    CustomerType TEXT,
    TransactionDate DATE,
    ProductPurchased TEXT,
    PurchaseAmount NUMERIC(10,2),
    ProductRecalled BOOLEAN,
    InteractionDate DATE,
    Platform TEXT,
    EngagementLikes INT,
    EngagementShares INT,
    EngagementComments INT,
    BrandMention BOOLEAN,
    CompetitionMention BOOLEAN,
    Sentiment TEXT,
    CrisisEventTime DATE,
    FirstResponseTime DATE,
    ResolutionStatus BOOLEAN
);

--Data Normalization
--Customer Table
Create TABLE CustomerData(
	CustomerID TEXT PRIMARY KEY,
	CustomerName TEXT,
	Region TEXT,
	Age INT,
	CustomerType TEXT,
);

CREATE TABLE TransactionData(
	TransactionID SERIAL PRIMARY KEY,
	CustomerID TEXT,
	TransactionDate DATE,
	ProductPurchased TEXT,
    PurchaseAmount NUMERIC(10,2),
    ProductRecalled BOOLEAN,
	FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);

CREATE TABLE SocialMedia(
	PostID SERIAL PRIMARY KEY,
	CustomerID TEXT,
    InteractionDate DATE,
    Platform TEXT,
    EngagementLikes INT,
    EngagementShares INT,
    EngagementComments INT,
    BrandMention BOOLEAN,
    CompetitionMention BOOLEAN,
    Sentiment TEXT,
    CrisisEventTime DATE,
    FirstResponseTime DATE,
    ResolutionStatus BOOLEAN
	FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);

ALTER TABLE SocialMedia
RENAME COLUMN TransactionDate TO InteractionDate;

ALTER TABLE socialmedia
DROP COLUMN TransactionDate,
DROP COLUMN ProductPurchased,
DROP COLUMN PurchaseAmount,
DROP COLUMN ProductRecalled;


--Add Data into table
--customer

INSERT INTO CustomerData(CustomerID,CustomerName,Region,Age,CustomerType)
SELECT DISTINCT CustomerID,CustomerName,Region,Age,CustomerType
FROM Afritech_data;

SELECT * FROM CustomerData

--Transaction 
INSERT INTO TransactionData(CustomerID,TransactionDate,ProductPurchased,PurchaseAmount,ProductRecalled)
SELECT CustomerID,TransactionDate,ProductPurchased,PurchaseAmount,ProductRecalled
FROM Afritech_Data;

SELECT * FROM socialmedia

--SocialMedia
INSERT INTO Socialmedia(CustomerID,
    InteractionDate,
    Platform ,
    EngagementLikes,
    EngagementShares,
    EngagementComments ,
    BrandMention,
    CompetitorMention,
    Sentiment,
    CrisisEventTime,
    FirstResponseTime,
    ResolutionStatus)
SELECT CustomerID,
    InteractionDate,
    Platform ,
    EngagementLikes,
    EngagementShares,
    EngagementComments ,
    BrandMention,
    CompetitionMention,
    Sentiment,
    CrisisEventTime,
    FirstResponseTime,
    ResolutionStatus
FROM Afritech_Data;

select *
from afritech_data

--checking for duplicates
SELECT CustomerID,COUNT (*) FROM CustomerData
GROUP BY CustomerID
HAVING COUNT(*) > 1

--CHECKING FOR NULL
SELECT COUNT(*) AS null_count FROM Socialmedia
WHERE crisiseventtime IS NOT NULL;

EXPLORATORY DATA ANALYSIS 
--Likes across socialmedia platform
SELECT platform, SUM(Engagementlikes) AS Total_Likes,ROUND(AVG(Engagementlikes))AS Average_Likes
FROM Socialmedia
GROUP BY platform
ORDER BY SUM(EngagementLikes) desc;

--Comment across Socialmedia platforms
SELECT platform, SUM(Engagementcomments) AS Total_Comments,ROUND(AVG(Engagementcomments))AS Average_Comments
FROM Socialmedia
GROUP BY platform
ORDER BY SUM(EngagementComments) desc;

--Sentiment Distribution
SELECT sentiment,COUNT(*) AS Sentiment_count 
FROM Socialmedia
GROUP BY Sentiment

SELECT sentiment, COUNT(*) AS Sentiment_count FROM Socialmedia
GROUP BY Sentiment,platform
ORDER BY platform


--month by month breakdown of likes,comments and shares
SELECT 
    EXTRACT(MONTH FROM InteractionDate) AS Month,
    SUM(EngagementLikes) AS Total_Likes,
    SUM(EngagementShares) AS Total_Shares,
    SUM(EngagementComments) AS Total_Comments
FROM SocialMedia
GROUP BY EXTRACT(MONTH FROM InteractionDate)
ORDER BY Month;

--Brand Mention vs Competitor mention
SELECT SUM(CASE
	WHEN brandmention = 'True' THEN 1
	ELSE 0
	END) AS BrandMentionCount,
	Sum(CASE
	WHEN Competitormention = 'True' THEN 1
	ELSE 0
	END) AS CompetitorMentionCount 
FROM SocialMedia
GROUP BY Sentiment;

SELECT * 
FROM SocialMedia 

--Breakdown of brand and competitor mention by month and year
	
SELECT
    EXTRACT(YEAR FROM InteractionDate) AS year,
    TO_CHAR(InteractionDate, 'Mon') AS month,
    SUM(CASE WHEN BrandMention = TRUE THEN 1 ELSE 0 END) AS BrandMentionCount,
    SUM(CASE WHEN CompetitorMention = TRUE THEN 1 ELSE 0 END) AS CompetitorMentionCount
FROM SocialMedia
GROUP BY
    EXTRACT(YEAR FROM InteractionDate),
    TO_CHAR(InteractionDate, 'Mon'),
    EXTRACT(MONTH FROM InteractionDate)
ORDER BY
    year,
    EXTRACT(MONTH FROM InteractionDate);

--Sentiments and Brand mentions vs Competitor mentions
SELECT Sentiment, SUM(CASE
	WHEN brandmention = 'True' THEN 1
	ELSE 0
	END) AS BrandMentionCount,
	Sum(CASE
	WHEN Competitormention = 'True' THEN 1
	ELSE 0
	END) AS CompetitorMentionCount 
FROM SocialMedia
GROUP BY Sentiment;


-platform and Brand mentions vs Competitor mentions
SELECT platform, SUM(CASE
	WHEN brandmention = 'True' THEN 1
	ELSE 0
	END) AS BrandMentionCount,
	Sum(CASE
	WHEN Competitormention = 'True' THEN 1
	ELSE 0
	END) AS CompetitorMentionCount 
FROM SocialMedia
GROUP BY platform;

--Response time
SELECT firstresponsetime - crisiseventtime 
FROM socialmedia
WHERE firstresponsetime IS NOT NULL


SELECT MIN(firstresponsetime - crisiseventtime ) AS Minresponsedays,
	MAX(firstresponsetime - crisiseventtime) AS Maxresponsedays,
	ROUND(AVG(firstresponsetime - crisiseventtime), 0) AS avgresponsedays,
	Percentile_cont(0.5) within group (ORDER BY firstresponsetime - crisiseventtime)
FROM socialmedia

--Resolution Status
SELECT resolutionstatus, COUNT (*) FROM socialmedia
WHERE resolutionstatus IS NOT NULL
GROUP BY resolutionstatus

SELECT resolutionstatus,
	MIN(firstresponsetime - crisiseventtime ) AS Minresponsedays,
	MAX(firstresponsetime - crisiseventtime) AS Maxresponsedays,
	ROUND(AVG(firstresponsetime - crisiseventtime), 0) AS avgresponsedays,
	Percentile_cont(0.5) within group (ORDER BY firstresponsetime - crisiseventtime)
FROM socialmedia
WHERE resolutionstatus IS NOT NULL
GROUP BY resolutionstatus


--Customer Data
--Total number of customers
SELECT COUNT(CustomerID) AS TotalCustomers FROM Customerdata

--customers by region
SELECT Region, COUNT (*) AS customers_count FROM customerdata
GROUP BY Region
ORDER BY COUNT(*) DESC
LIMIT 15;


--Age (Highest, Lowest, Average)
SELECT MAX(age) AS highest_age,
		MAX(age) AS lowest_age,
		ROUND(AVG(age),0) AS average_age
FROM Customerdata;

--Customer type breakdown
SELECT Customertype,COUNT(*) FROM customerdata
GROUP BY customertype

--Transaction date
--product recall
SELECT * FROM transactiondata

SELECT productrecalled, COUNT(*) AS recall_count, SUM(Purchaseamount) AS total_amount FROM Transactiondata
GROUP BY productrecalled

--region and product recall
SELECT Region, COUNT (*) AS recall_count FROM customerdata
JOIN transactiondata ON customerdata.customerid transactiondata.customerid
WHERE productrecalled = 'True'
GROUP BY Region 

SELECT Region, COUNT (*) AS recall_count 
FROM customerdata 
JOIN transactiondata ON customerdata.customerid transactiondata.customerid 
WHERE productrecalled = 'True' 
GROUP BY Region

