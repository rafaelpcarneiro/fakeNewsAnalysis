CREATE VIEW numberOfEdges AS
SELECT 
    COUNT(*) 
FROM
    (SELECT DISTINCT
        from_author_tweet_id,
        to_author_tweet_id
     FROM 
        paths_xy
     WHERE
        from_author_tweet_id != -1
        AND
        from_author_tweet_id != to_author_tweet_id
        AND
        path_distance = 1);


CREATE TABLE aSample (
    from_author_tweet_id INT NOT NULL,
    to_author_tweet_id   INT NOT NULL,

    PRIMARY KEY (from_author_tweet_id, to_author_tweet_id)
);

CREATE TABLE paths_xy_SAMPLE (
    from_tweet_id        INT NOT NULL,
    to_tweet_id          INT NOT NULL,
    from_author_tweet_id INT NOT NULL,
    to_author_tweet_id   INT NOT NULL,
    path_distance        INT NOT NULL,

    PRIMARY KEY (from_tweet_id, to_tweet_id)
);

-- Take a sample size equal to 25% of the numberOfEdges
INSERT INTO aSample
SELECT DISTINCT
    from_author_tweet_id,
    to_author_tweet_id
FROM 
    paths_xy
WHERE
    from_author_tweet_id != -1
    AND
    from_author_tweet_id != to_author_tweet_id
    AND
    path_distance = 1
ORDER BY random()
LIMIT CAST(0.25 * (SELECT * FROM numberOfEdges) AS INT);

-- Fill paths_xy_SAMPLE with the sample
INSERT INTO paths_xy_SAMPLE 
SELECT 
    *
FROM 
    paths_xy
WHERE
    from_author_tweet_id != -1
    AND
    from_author_tweet_id != to_author_tweet_id
    AND
    EXISTS (SELECT
                S.from_author_tweet_id, 
                S.to_author_tweet_id
            FROM
                aSample AS S
            WHERE
                S.from_author_tweet_id = paths_xy.from_author_tweet_id
                AND
                S.to_author_tweet_id = paths_xy.to_author_tweet_id);

DROP VIEW numberOfEdges;
