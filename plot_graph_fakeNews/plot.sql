.open twitter.db

.once nodes.txt
SELECT DISTINCT author_tweet_id 
FROM   tweet
WHERE  tweet_id IN (SELECT nodes.tweet_id
                    FROM nodes);

.separator "--"
.once edges.txt
SELECT a.author_tweet_id, b.author_tweet_id
FROM tweet AS a, tweet AS b
WHERE a.tweet_id IN (SELECT from_node FROM paths_xy)
      AND
      b.tweet_id IN (SELECT to_node FROM paths_xy)
