.separator "    "
.output "users_rt.txt"
.print "#author_id  rt  total_msg   followers_count following_count tweet_count"
CREATE VIEW user_stat AS
SELECT
    X.author_tweet_id,
    X.rt,
    Y.total_msg,
    Z.username,
    Z.followers_count,
    Z.following_count,
    Z.tweet_count
FROM
    (SELECT
        author_tweet_id,
        COUNT(*) AS rt
     FROM tweet
     WHERE tweet_type = "retweet"
     GROUP BY author_tweet_id) AS X,
    (SELECT 
        author_tweet_id,
        COUNT(*) AS total_msg
     FROM tweet
     GROUP BY author_tweet_id) AS Y,
    (SELECT 
        id,
        username,
        followers_count,
        following_count,
        tweet_count
     FROM twitter_user) AS Z
WHERE 
    X.author_tweet_id = Y.author_tweet_id AND X.author_tweet_id = Z.id; 

