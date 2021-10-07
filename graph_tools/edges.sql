CREATE TABLE paths_xy (
    from_tweet_id        INT NOT NULL,
    to_tweet_id          INT NOT NULL,
    from_author_tweet_id INT NOT NULL,
    to_author_tweet_id   INT NOT NULL,
    path_distance        INT NOT NULL,

    PRIMARY KEY (from_tweet_id, to_tweet_id)
);
