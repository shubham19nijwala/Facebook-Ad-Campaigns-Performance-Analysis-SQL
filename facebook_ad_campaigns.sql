---Creating Table Facebook_Ad_Campaigns

CREATE TABLE Facebook_Ad_Campaigns(ad_id int not null,xyz_campaign_id int not null,
								  fb_campaign_id int not null,age varchar(5), gender char(1),
								  interest int,Impressions int,Clicks int ,Spent float,Total_Conversion int,Approved_Conversion int);
		
COPY Facebook_Ad_Campaigns FROM 'D:\DATA SCIENCE\PostgreSql\Facebook\Facebook_Ad_Campaigns.csv'	with CSV HEADER;

SELECT * FROM Facebook_Ad_Campaigns;

                                  ------Ad Reach-------
--1. Total Impressions for each ad campaign:

SELECT xyz_campaign_id, SUM(Impressions) AS Total_Impressions
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
ORDER BY Total_Impressions DESC;


                             ---------Ad Engagement-----------
--2. Total Clicks for each ad campaign:

SELECT xyz_campaign_id, SUM(Clicks) AS "Total_Clicks"
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
ORDER BY "Total_Clicks" DESC;

--3. Click-Through Rate (CTR) for each campaign:

SELECT xyz_campaign_id,SUM(Clicks)/SUM(Impressions):: FLOAT AS "CTR"
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
ORDER BY "CTR" DESC;

--4. Total Clicks by Gender:

SELECT gender, SUM(Clicks) AS Total_Clicks
FROM Facebook_Ad_Campaigns
GROUP BY gender;

--5. Average CTR by Age Group:

SELECT age, AVG(Clicks/Impressions :: FLOAT) AS Average_CTR
FROM Facebook_Ad_Campaigns
GROUP BY age
ORDER BY Average_CTR DESC;

--6. Average CTR by Gender:

SELECT gender, AVG(Clicks / Impressions :: FLOAT) AS Average_CTR
FROM Facebook_Ad_Campaigns
GROUP BY gender;

                                    ------Ad Conversion-------
--7. Total Enquiries for each campaign:

SELECT xyz_campaign_id, SUM(Total_Conversion) AS "Total_Enquiries"
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
ORDER BY "Total_Enquiries" DESC;

--8. Conversion Rate for each campaign:

SELECT xyz_campaign_id, SUM(Total_Conversion) / SUM(Clicks) :: FLOAT AS Conversion_Rate
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
ORDER BY Conversion_Rate DESC;


--9. Cost per Conversion (CPC):

SELECT
    ad_id,
    xyz_campaign_id,
    Total_Conversion,
    Approved_Conversion,
    Spent,
    SUM(Total_Conversion) OVER (PARTITION BY xyz_campaign_id) AS Total_Conversions_Campaign,
    SUM(Approved_Conversion) OVER (PARTITION BY xyz_campaign_id) AS Approved_Conversions_Campaign,
    Spent / NULLIF(Total_Conversion,0) AS Cost_Per_Conversion
FROM Facebook_Ad_Campaigns
ORDER BY xyz_campaign_id, ad_id;

--10. Total Sales for each campaign:

SELECT xyz_campaign_id, SUM(Approved_Conversion) AS Total_Sales
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
ORDER BY Total_Sales DESC;

--11. Ad Conversion Performance Analysis:

SELECT ad_id,xyz_campaign_id,Total_Conversion,Approved_Conversion,Clicks,Impressions,Spent,
    100.0 * Approved_Conversion / NULLIF(Total_Conversion,0) AS Conversion_Rate,
    DENSE_RANK() OVER (PARTITION BY xyz_campaign_id ORDER BY 100.0 * Approved_Conversion / NULLIF(Total_Conversion,0) DESC) AS Conversion_Rate_Rank
FROM Facebook_Ad_Campaigns
ORDER BY Conversion_Rate_Rank,xyz_campaign_iD

--12. Total Sales by Gender:

SELECT gender, SUM(Approved_Conversion) AS Total_Sales
FROM Facebook_Ad_Campaigns
GROUP BY gender;

--13. Top Performing Campaigns by Total Conversions:

SELECT
    c.xyz_campaign_id,
    c.fb_campaign_id,
    c.age,
    c.gender,
    c.interest,
    SUM(a.Total_Conversion) AS Total_Conversions
FROM
    Facebook_Ad_Campaigns a
JOIN
    Facebook_Ad_Campaigns c ON a.xyz_campaign_id = c.xyz_campaign_id
GROUP BY
    c.xyz_campaign_id, c.fb_campaign_id, c.age, c.gender, c.interest
ORDER BY
    Total_Conversions DESC LIMIT 10;


                                     ----Ad Cost-----
--14. Total Ad Spend for each campaign:

SELECT xyz_campaign_id, SUM(Spent) AS "Total_Ad_Spend"
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
ORDER BY "Total_Ad_Spend" DESC;

--15. Campaigns with High Cost per Click (CPC) and Low Conversion Rate:

SELECT
    xyz_campaign_id,
    AVG(Spent / NULLIF(Clicks,0)) AS CPC,
    AVG(Approved_Conversion) / AVG(NULLIF(Clicks,0)) AS Conversion_Rate
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
HAVING
    AVG(Spent / NULLIF(Clicks,0)) > (SELECT AVG(Spent / NULLIF(Clicks,0)) FROM Facebook_Ad_Campaigns) AND
    AVG(Approved_Conversion) / AVG(NULLIF(Clicks,0)) < (SELECT AVG(Approved_Conversion / NULLIF(Clicks,0)) FROM Facebook_Ad_Campaigns)
ORDER BY CPC DESC, Conversion_Rate;

--16. Campaigns with High Spent but Low Total Conversions:

SELECT xyz_campaign_id,SUM(Spent) AS Total_Ad_Spend,SUM(Total_Conversion) AS Total_Conversions
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
HAVING
    SUM(Spent) > (SELECT AVG(Spent) FROM Facebook_Ad_Campaigns) AND
    SUM(Total_Conversion) < (SELECT AVG(Total_Conversion) FROM Facebook_Ad_Campaigns)
ORDER BY
    Total_Ad_Spend DESC;

--17. Cost Per Thousand Impressions (CPM) for each campaign:

SELECT xyz_campaign_id, (SUM(Spent) / SUM(Impressions)) * 1000 AS CPM
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
ORDER BY CPM DESC;

                              ----Ad ROI-----
--18. Return on Ad Spend (ROAS) for each campaign:

SELECT xyz_campaign_id, SUM(Approved_Conversion * Spent) / SUM(Spent) AS "ROAS"
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
ORDER BY "ROAS" DESC;

--19. Average ROI per Gender:

SELECT gender,AVG(Approved_Conversion * Spent) / AVG(Spent) AS "Avg_ROI"
FROM Facebook_Ad_Campaigns
GROUP BY gender;

--20. Campaigns with Negative ROI:

SELECT xyz_campaign_id,SUM(Approved_Conversion * Spent) / SUM(Spent) AS ROI
FROM Facebook_Ad_Campaigns
GROUP BY xyz_campaign_id
HAVING SUM(Approved_Conversion * Spent) / SUM(Spent) < 0;

                              -----Audience Insights------
--21. Top 10 Interests with the highest number of Impressions:

SELECT interest, SUM(Impressions) AS "Total_Impressions"
FROM Facebook_Ad_Campaigns
GROUP BY interest
ORDER BY "Total_Impressions" DESC
LIMIT 10;

--22. Gender-based Click-Through Rate (CTR) and Conversion Rate by Age Group:

SELECT
    age,gender,
    SUM(Clicks) AS Total_Clicks,
    SUM(Approved_Conversion) AS Total_Conversions,
    AVG(Clicks / NULLIF(Impressions,0)::FLOAT) AS "CTR",
    AVG(Approved_Conversion / NULLIF(Clicks,0)) AS "Conversion_Rate"
FROM Facebook_Ad_Campaigns
GROUP BY age, gender
ORDER BY age, gender;
                              -----Ad Performance Overview------

--23. Analyze campaign performance across different campaigns:

SELECT c.xyz_campaign_id, 
       SUM(a.Impressions) AS total_impressions,
       SUM(a.Clicks) AS total_clicks,
       SUM(a.Spent) AS total_spent,
       SUM(a.Total_Conversion) AS total_enquiries,
       SUM(a.Approved_Conversion) AS total_sales
FROM Facebook_Ad_Campaigns a
INNER JOIN Facebook_Ad_Campaigns c ON a.xyz_campaign_id = c.xyz_campaign_id
GROUP BY c.xyz_campaign_id;







