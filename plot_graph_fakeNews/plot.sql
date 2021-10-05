.open twitter.db

.once nodes.txt
SELECT DISTINCT author_tweet_id 
FROM   tweet
WHERE  tweet_id IN (SELECT nodes.tweet_id
                    FROM nodes);

.separator "--"
.once edges.txt
SELECT DISTINCT a.author_tweet_id, b.author_tweet_id
FROM tweet AS a, tweet AS b
WHERE EXISTS (SELECT from_node, to_node
              FROM paths_xy
              WHERE a.tweet_id = from_node
                    AND
                    b.tweet_id = to_node); 
