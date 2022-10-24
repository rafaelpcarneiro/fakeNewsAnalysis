
CREATE TABLE aWindow_nodes (
    nodes                INT  NOT NULL,
    PRIMARY KEY (nodes)
);

CREATE TABLE aWindow_edges (
    from_author_tweet_id INT  NOT NULL,
    to_author_tweet_id   INT  NOT NULL,

    path_length          INT  NOT NULL,
    weight               REAL NOT NULL,

    PRIMARY KEY (from_author_tweet_id, to_author_tweet_id)
);

CREATE TABLE paths_xy_WINDOW (
    from_tweet_id        INT  NOT NULL,
    to_tweet_id          INT  NOT NULL,

    from_author_tweet_id INT  NOT NULL,
    to_author_tweet_id   INT  NOT NULL,

    path_length          INT  NOT NULL,
    path_weight          REAL NOT NULL,

    PRIMARY KEY (from_tweet_id, to_tweet_id)

);

CREATE TABLE paths_xyz_WINDOW (
    -- here the path is of the form [A, B, C]
    -- representing A -> B -> C
    author_tweet_id_A   INT  NOT NULL,
    author_tweet_id_B   INT  NOT NULL,
    author_tweet_id_C   INT  NOT NULL,

    PRIMARY KEY (author_tweet_id_A, author_tweet_id_B, author_tweet_id_C)
);

.save graph_of_a_time_interval.db
