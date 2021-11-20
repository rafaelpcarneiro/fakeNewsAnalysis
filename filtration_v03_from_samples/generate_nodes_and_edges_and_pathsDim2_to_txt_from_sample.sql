-- vim: set ts=4 expandtab sw=4: 
-- Only nodes that have their published time
CREATE VIEW userNodes AS
SELECT
    from_author_tweet_id AS author_tweet_id
FROM
    paths_xy_SAMPLE
WHERE
    from_author_tweet_id != -1
    AND 
    from_author_tweet_id != to_author_tweet_id
UNION
SELECT
    to_author_tweet_id AS author_tweet_id
FROM
    paths_xy_SAMPLE
WHERE
    to_author_tweet_id != -1
    AND 
    from_author_tweet_id != to_author_tweet_id;


CREATE VIEW edges_with_weight AS
SELECT
    from_author_tweet_id,
    to_author_tweet_id,
    MIN(path_distance)
FROM
    paths_xy_SAMPLE
WHERE  
    from_author_tweet_id != -1
    AND
    to_author_tweet_id   != -1
    AND 
    from_author_tweet_id != to_author_tweet_id
GROUP BY
    from_author_tweet_id, to_author_tweet_id;
    
CREATE VIEW pathDim2 AS
SELECT
    L.from_author_tweet_id,
    L.to_author_tweet_id,
    R.to_author_tweet_id
FROM 
   (SELECT from_author_tweet_id, to_author_tweet_id 
    FROM 
        paths_xy_SAMPLE
    WHERE
        from_author_tweet_id != -1
        AND 
        from_author_tweet_id != to_author_tweet_id
    GROUP BY
        from_author_tweet_id, to_author_tweet_id) AS L
INNER JOIN
   (SELECT from_author_tweet_id, to_author_tweet_id
    FROM
        paths_xy_SAMPLE
    WHERE
        from_author_tweet_id != -1
        AND 
        from_author_tweet_id != to_author_tweet_id
    GROUP BY
        from_author_tweet_id, to_author_tweet_id) AS R
ON
    L.to_author_tweet_id = R.from_author_tweet_id;

-- start printing data to txt files
.separator "    "
.output nodes.txt
SELECT DISTINCT COUNT(*) FROM userNodes;
SELECT DISTINCT * 
FROM 
    userNodes
ORDER BY
    author_tweet_id ASC;

.output edges.txt
SELECT COUNT(*) FROM edges_with_weight;
SELECT       *  FROM edges_with_weight;

.output pathDim2.txt
SELECT DISTINCT COUNT(*) FROM pathDim2;
SELECT DISTINCT       *  FROM pathDim2;

.output stdout

DROP VIEW userNodes;
DROP VIEW edges_with_weight;
DROP VIEW pathDim2;
