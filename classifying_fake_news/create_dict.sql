-- vim: set ts=4 expandtab sw=4:
CREATE TABLE dictionary (
	tweet_id				                         INT,
	word_found_on_tweet_id		                     TEXT NOT NULL,
	word_counter_considering_tweet_id	             INT  NOT NULL,
	was_this_tweet_id_sampled		                 INT  DEFAULT 0, -- yes = 1, no = 0
	if_tweet_id_was_sampled_is_it_unreliable	     INT  DEFAULT 0, -- yes = 1, no = 0

	PRIMARY KEY (tweet_id, word_found_on_tweet_id)
);

-- Down below I use the following names, X and Theta, in 
-- order to express random variables. They mean:
-- X is our info from the universe of all tweets
-- Theta = 1 or 0 meaning that the tweet is unreliable (Theta = 1)
--   or not, otherwise (Theta = 0).
CREATE TABLE naiveBayes (
    tweet_id                 INT,
    is_tweet_id_unreliable   INT  DEFAULT 0, -- yes = 1, no = 0
    prob_Theta_eq_1_given_X  REAL DEFAULT 0.0,
    prob_Theta_eq_0_given_X  REAL DEFAULT 0.0,

    PRIMARY KEY (tweet_id)
);

-- Down below I use the name  Theta
-- order to express a random variable. It means:
-- Theta = 1 or 0 meaning that the tweet is unreliable (Theta = 1)
--   or not, otherwise (Theta = 0).
CREATE TABLE probabilities (
    word_sampled                      TEXT,
    prob_find_word_given_Theta_eq_1   REAL DEFAULT 0.0,
    prob_find_word_given_Theta_eq_0   REAL DEFAULT 0.0,

    PRIMARY KEY (word_sampled)
);
