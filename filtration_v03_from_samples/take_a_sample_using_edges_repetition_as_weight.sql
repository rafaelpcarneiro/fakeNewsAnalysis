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


CREATE TABLE aSample_nodes (
    nodes                INT  NOT NULL,
    PRIMARY KEY (nodes)
);

CREATE TABLE aSample_edges (
    from_author_tweet_id INT  NOT NULL,
    to_author_tweet_id   INT  NOT NULL,

    path_length          INT  NOT NULL,
    weight               REAL NOT NULL,

    PRIMARY KEY (from_author_tweet_id, to_author_tweet_id)
);

CREATE TABLE paths_xy_SAMPLE (
    from_tweet_id        INT  NOT NULL,
    to_tweet_id          INT  NOT NULL,
    
    from_author_tweet_id INT  NOT NULL,
    to_author_tweet_id   INT  NOT NULL,

    path_length          INT  NOT NULL,
    path_weight          REAL NOT NULL,

    PRIMARY KEY (from_tweet_id, to_tweet_id)

);

-- Take a sample size equal to 40% of the numberOfEdges
INSERT INTO aSample_edges
SELECT 
    from_author_tweet_id,
    to_author_tweet_id,
    path_distance,         -- variable name was choosen to be consistent with old definitions
    COUNT(*) AS weight     -- weight set as the influence of a user
FROM 
    paths_xy
WHERE
    from_author_tweet_id != -1
    AND
    from_author_tweet_id != to_author_tweet_id
    AND
    path_distance = 1
GROUP BY 
    from_author_tweet_id,
    to_author_tweet_id
ORDER BY
    random()
LIMIT
    CAST(.40 * (SELECT * FROM numberOfEdges) AS INT);

-- Get the table of nodes sampled from the edges
INSERT INTO aSample_nodes
SELECT
    from_author_tweet_id
FROM
    aSample_edges
UNION
SELECT
    to_author_tweet_id
FROM
    aSample_edges;

-- Fill paths_xy_SAMPLE with the sample
INSERT INTO paths_xy_SAMPLE 
SELECT 
    L.from_tweet_id,
    L.to_tweet_id,
    L.from_author_tweet_id,
    L.to_author_tweet_id,
    L.path_distance,
    R.weight
FROM 
    (SELECT
        *
     FROM 
        paths_xy
     WHERE
        EXISTS (SELECT *
                FROM
                    aSample_edges
                WHERE
                    paths_xy.from_author_tweet_id = aSample_edges.from_author_tweet_id
                    AND
                    paths_xy.to_author_tweet_id = aSample_edges.to_author_tweet_id
                )
    ) AS L
JOIN
    aSample_edges AS R
ON
    L.from_author_tweet_id = R.from_author_tweet_id
    AND
    L.to_author_tweet_id = R.to_author_tweet_id;
