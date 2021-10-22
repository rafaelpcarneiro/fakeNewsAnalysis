CREATE VIEW influencers AS
SELECT
    from_author_tweet_id,
    COUNT(*) AS weight
FROM
    paths_xy
WHERE
    from_author_tweet_id !=-1
GROUP BY
    from_author_tweet_id
ORDER BY
    weight ASC;


CREATE VIEW convincers AS
SELECT
    to_author_tweet_id,
    COUNT(*) AS weight
FROM
    paths_xy
WHERE
    from_author_tweet_id !=-1
GROUP BY
    to_author_tweet_id
ORDER BY
    weight ASC;

.separator " -- "
.once "edges_influencers.dot"
SELECT 
    L.from_author_tweet_id,
    L.to_author_tweet_id,
    cast( R.weight / 3610.0 * 90/10 AS INT) + 1
FROM
    (SELECT DISTINCT
        from_author_tweet_id,
        to_author_tweet_id
     FROM
        paths_xy
     WHERE
        from_author_tweet_id != -1) AS L,
    influencers                     AS R
WHERE
    L.from_author_tweet_id = R.from_author_tweet_id;


.separator " -- "
.once "edges_convincers.dot"
SELECT 
    L.from_author_tweet_id,
    L.to_author_tweet_id,
    cast( R.weight / 170.0 * 90/10 AS INT) + 1
FROM
    (SELECT DISTINCT
        from_author_tweet_id,
        to_author_tweet_id
     FROM
        paths_xy
     WHERE
        from_author_tweet_id != -1) AS L,
    convincers                      AS R
WHERE
    L.to_author_tweet_id = R.to_author_tweet_id;

DROP VIEW influencers;
DROP VIEW convincers;

