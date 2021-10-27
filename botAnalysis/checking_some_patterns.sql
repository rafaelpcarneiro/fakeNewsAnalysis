-- vim: foldmethod=marker:

-- lets call as 'A' and 'B' any user on the graph, G,
-- which interect with each other.
--
-- Here we will define as
--      weight(A) := card{ B in G; B interacts with A }
-- and
--      MAX := max { weight(A); A in G }.

DROP VIEW constants;
DROP TABLE influencers;

CREATE VIEW constants AS
SELECT DISTINCT
    A.weight AS max_weight_of_influencers,
    B.max_of_tweets_by_everybody,
    C.max_of_rt
FROM 
    (SELECT 
        COUNT(*) AS weight
    FROM
        paths_xy
    WHERE
        from_author_tweet_id != -1
    AND
        path_distance = 1
    GROUP BY
        from_author_tweet_id
    ORDER BY
        weight DESC
    LIMIT 1) AS A,
    (SELECT
        COUNT(*) AS max_of_tweets_by_everybody
    FROM
        tweet
    GROUP BY
        author_tweet_id
    ORDER BY
        max_of_tweets_by_everybody DESC
    LIMIT 1) AS B,
    (SELECT
        COUNT(*) AS max_of_rt
    FROM
        tweet
    WHERE 
        tweet_type = "retweeted"
    GROUP BY
        author_tweet_id
    ORDER BY
        max_of_rt DESC
    LIMIT 1) AS C;

    

--CREATE TABLE influencers (
--    from_author_tweet_id    INT,
--    weight                  INT  NOT NULL,
--    normalized_weight       REAL NOT NULL,
--
--    PRIMARY KEY (from_author_tweet_id)
--);
--
--INSERT INTO influencers 
--SELECT
--    X.from_author_tweet_id,
--    COUNT(*),
--    1.0 * COUNT(*) / (SELECT * FROM constants) 
--FROM
--    paths_xy AS X
--WHERE
--    X.from_author_tweet_id !=-1
--    AND
--    X.path_distance = 1
--GROUP BY
--    X.from_author_tweet_id;
