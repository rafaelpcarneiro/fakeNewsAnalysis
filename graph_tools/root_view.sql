-- Root nodes regarding only the graph obtained from tweets
DROP VIEW root_tt;

CREATE VIEW root_tt AS
SELECT tweet_id AS tweet_id
FROM   tweet 
WHERE  parent_tweet_id IS NULL
UNION
SELECT parent_tweet_id AS tweet_id
FROM   tweet
WHERE  ((parent_tweet_id IS NOT NULL) 
	AND
	(parent_tweet_id NOT IN (SELECT x.tweet_id FROM tweet AS x)));
