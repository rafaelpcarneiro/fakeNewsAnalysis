.separator "    "
.output nodes.txt
SELECT COUNT(*) 
FROM nodes
WHERE
    tweet_id IN (SELECT from_tweet_id 
                 FROM   paths_xy 
                 WHERE  from_author_tweet_id != -1 AND path_distance = 1
    	         UNION
    	         SELECT to_tweet_id FROM paths_xy WHERE  path_distance = 1);
SELECT *
FROM nodes
WHERE
    tweet_id IN (SELECT from_tweet_id 
                 FROM   paths_xy 
                 WHERE  from_author_tweet_id != -1 AND path_distance = 1
    	         UNION
    	         SELECT to_tweet_id 
                 FROM   paths_xy 
                 WHERE  path_distance = 1)
ORDER BY generation_of_tweet_id ASC;

.output edges.txt
SELECT COUNT(*)
FROM paths_xy
WHERE
    from_author_tweet_id != -1 AND path_distance = 1;
SELECT from_tweet_id, to_tweet_id, 1
FROM paths_xy
WHERE
    from_author_tweet_id != -1 AND path_distance = 1;

.exit
