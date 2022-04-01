-- vim: set ts=4 expandtab sw=4: 

    
-- start printing data to txt files

-- NODES
.separator "    "
.output nodes.txt
SELECT DISTINCT COUNT(*) FROM aSample_nodes;
SELECT DISTINCT * 
FROM 
    aSample_nodes
ORDER BY
    nodes  ASC;

-- EDGES
.output edges.txt
SELECT COUNT(*)
FROM
    (SELECT DISTINCT
        from_author_tweet_id, 
        to_author_tweet_id
     FROM
        paths_xy_SAMPLE);

SELECT 
    from_author_tweet_id,
    to_author_tweet_id,
    MIN(path_weight)
FROM
    paths_xy_SAMPLE
GROUP BY
    from_author_tweet_id,
    to_author_tweet_id;

--.output pathDim2.txt
--SELECT DISTINCT COUNT(*) FROM paths_xyz_SAMPLE;
--SELECT DISTINCT       *  FROM paths_xyz_SAMPLE;

.output stdout
