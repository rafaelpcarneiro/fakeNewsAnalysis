ATTACH DATABASE 'sample.db' AS sampleDB;

INSERT INTO sampleDB.aSample_nodes 
SELECT *
FROM aSample_nodes;


INSERT INTO sampleDB.aSample_edges
SELECT *
FROM aSample_edges;


INSERT INTO sampleDB.paths_xy_SAMPLE
SELECT *
FROM paths_xy_SAMPLE;


--INSERT INTO sampleDB.paths_xyz_SAMPLE
--SELECT
--    L.from_author_tweet_id,
--    L.to_author_tweet_id,
--    R.to_author_tweet_id
--FROM 
--   (SELECT from_author_tweet_id, to_author_tweet_id 
--    FROM 
--        paths_xy_SAMPLE
--    WHERE
--        from_author_tweet_id != -1
--        AND 
--        from_author_tweet_id != to_author_tweet_id
--    GROUP BY
--        from_author_tweet_id, to_author_tweet_id) AS L
--INNER JOIN
--   (SELECT from_author_tweet_id, to_author_tweet_id
--    FROM
--        paths_xy_SAMPLE
--    WHERE
--        from_author_tweet_id != -1
--        AND 
--        from_author_tweet_id != to_author_tweet_id
--    GROUP BY
--        from_author_tweet_id, to_author_tweet_id) AS R
--ON
--    L.to_author_tweet_id = R.from_author_tweet_id;
