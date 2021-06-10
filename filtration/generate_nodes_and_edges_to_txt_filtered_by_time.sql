-- vim: set ts=4 expandtab sw=4: 
-- Only nodes that have their published time
CREATE VIEW nodes_with_time AS
SELECT tweet_id, generation_of_tweet_id, amount_of_sons
FROM nodes
WHERE tweet_id IN (SELECT X.tweet_id 
		   FROM tweet AS X
		   WHERE X.created_at IS NOT NULL
			 AND
			 tweet_id = X.tweet_id);


CREATE VIEW edges_with_time AS
SELECT from_node,
       to_node,
       strftime('%s', (SELECT x.created_at FROM tweet AS x WHERE x.tweet_id = to_node)) -
       strftime('%s', (SELECT y.created_at FROM tweet AS y WHERE y.tweet_id = from_node))
FROM   paths_xy
WHERE  (from_node IN (SELECT X.tweet_id
		      FROM nodes_with_time AS X
		      WHERE from_node = X.tweet_id))
	   AND
       (to_node   IN (SELECT X.tweet_id
		      FROM nodes_with_time AS X
		      WHERE to_node = X.tweet_id));


.separator "    "
.output nodes.txt
SELECT COUNT(*) FROM nodes_with_time;
SELECT * 
FROM nodes_with_time
ORDER BY generation_of_tweet_id ASC;

.output edges.txt
SELECT COUNT(*) FROM edges_with_time;
SELECT * FROM edges_with_time;

.output stdout

DROP VIEW nodes_with_time;
DROP VIEW edges_with_time;
