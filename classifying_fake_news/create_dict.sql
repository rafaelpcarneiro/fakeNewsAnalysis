-- vim: set ts=4 expandtab sw=4:
CREATE TABLE dictionary (
	tweet_id				            INT,
	word_found_on_tweet_id		        TEXT NOT NULL,
	word_counter_considering_tweet_id	INT  NOT NULL,
	was_this_tweet_id_sampled		    INT  DEFAULT 0,
	if_tweet_id_was_sampled_is_it_fake	INT  DEFAULT 0,

	PRIMARY KEY (tweet_id, word_found_on_tweet_id)
);
