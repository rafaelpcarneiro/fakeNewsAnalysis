-- vim: set ts=4 expandtab sw=4:
CREATE TABLE dictionary (
	tweet_id				                         INT,
	word_found_on_tweet_id		                     TEXT NOT NULL,
	word_counter_considering_tweet_id	             INT  NOT NULL,
	was_this_tweet_id_sampled		                 INT  DEFAULT 0, -- yes = 1, no = 0
	if_tweet_id_was_sampled_is_it_unreliable	     INT  DEFAULT 0, -- yes = 1, no = 0

	PRIMARY KEY (tweet_id, word_found_on_tweet_id)
);

-- Down below I take the follow names X Theta in 
-- order to express random variables. They mean:
-- X is our info from the universe of all tweets
-- Theta = 1 or 0 meaning that the tweet is unreliable (Theta = 1)
--   or not, otherwise (Theta = 0).
CREATE TABLE naiveBayes (
    tweet_id                 INT,
    is_tweet_id_unreliable   INT  DEFAULT 0, -- yes = 1, no = 0
    p[Theta=1|X]             REAL DEFAULT 0.0,
    p[Theta=0|X]             REAL DEFAULT 0.0,

    PRIMARY KEY (tweet_id)
);

-- Down below I take the follow names X Theta in 
-- order to express random variables. They mean:
-- W is the multinomial random variable whose values range
--   between all words from our sample
-- Theta = 1 or 0 meaning that the tweet is unreliable (Theta = 1)
--   or not, otherwise (Theta = 0).
CREATE TABLE probabilities (
    word_sampled        TEXT,
    p[W=word|Theta=1]   REAL DEFAULT 0.0,
    p[W=word|Theta=0]   REAL DEFAULT 0.0,

    PRIMARY KEY (word_sampled)
);
