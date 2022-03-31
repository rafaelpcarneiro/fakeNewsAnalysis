-- vim: foldmethod=marker:

-- lets call as 'A' and 'B' any user on the graph, G,
-- which interect with each other.
--
-- Here we will define as
--      weight(A) := card{ B in G; B interacts with A }
-- and
--      MAX := max { weight(A); A in G }.

DROP VIEW constants;
DROP VIEW time_to_rt;
DROP VIEW statistics_rt;
DROP VIEW influencers;
DROP VIEW convincers;


CREATE VIEW constants AS
-- {{{1
SELECT DISTINCT
    A.weight AS max_weight_of_influencers,
    B.weight AS max_weight_of_convincers
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
        COUNT(*) AS weight
    FROM
        paths_xy
    WHERE
        from_author_tweet_id != -1
    AND
        path_distance = 1
    GROUP BY
        to_author_tweet_id
    ORDER BY
        weight DESC
    LIMIT 1) AS B;
-- 1}}}

CREATE VIEW time_to_rt AS
-- {{{1
SELECT 
    to_author_tweet_id,
    strftime('%s', (SELECT t.created_at
                    FROM   tweet   AS t
                    WHERE  t.tweet_id = to_tweet_id
                           AND
                           t.tweet_type = "retweet")
    ) -
    strftime('%s', (SELECT t.created_at
                    FROM   tweet   AS t
                    WHERE  t.tweet_id = from_tweet_id)
    ) AS time
FROM
    paths_xy
WHERE
    from_author_tweet_id != -1
    AND
    EXISTS (SELECT *
            FROM
                tweet AS t
            WHERE
                t.tweet_type = "retweet"
                AND
                t.tweet_id = to_tweet_id);
-- 1}}}

CREATE VIEW statistics_rt AS
-- {{{1
SELECT
    A.author_tweet_id,
    A.amount_tweets_created,
    B.amount_rt,
    C.expected_time_to_rt
FROM
    (SELECT 
        author_tweet_id,
        COUNT(*) AS amount_tweets_created
    FROM
        tweet
    GROUP BY
        author_tweet_id) AS A,
    (SELECT 
        author_tweet_id,
        COUNT(*) AS amount_rt
    FROM
        tweet
    WHERE
        tweet_type = "retweet"
    GROUP BY
        author_tweet_id
    HAVING
        amount_rt > 0) AS B,
    (SELECT
        to_author_tweet_id,
        AVG(time) AS expected_time_to_rt
    FROM
        time_to_rt
    GROUP BY
        to_author_tweet_id) AS C
WHERE
    A.author_tweet_id = B.author_tweet_id
    AND
    B.author_tweet_id = C.to_author_tweet_id;
-- 1}}}

CREATE VIEW influencers AS 
-- {{{1
SELECT
    X.from_author_tweet_id,
    COUNT(*) AS weight,
    1.0 * COUNT(*) / (SELECT max_weight_of_influencers FROM constants) AS normalized_weight
FROM
    paths_xy AS X
WHERE
    X.from_author_tweet_id !=-1
    AND
    X.path_distance = 1
GROUP BY
    X.from_author_tweet_id;
-- 1}}}


CREATE VIEW convincers AS
-- {{{1
SELECT
    X.to_author_tweet_id,
    COUNT(*) AS weight,
    1.0 * COUNT(*) / (SELECT max_weight_of_convincers FROM constants) AS normalized_weight
FROM
    paths_xy AS X
WHERE
    X.from_author_tweet_id !=-1
    AND
    X.path_distance = 1
GROUP BY
    X.to_author_tweet_id;
-- 1}}}
