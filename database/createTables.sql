-- vim: set ts=4 expandtab sw=4 foldmethod=marker:
-- Script responsible to create all tables from	 the relational
-- model of the file db.relationalmodel.

CREATE TABLE twitter_user (
	id  		    INT,
	name  		    TEXT NOT NULL,
	username 	    TEXT NOT NULL,
	location 	    TEXT     NULL,
	followers_count INT  NOT NULL,
	following_count INT  NOT NULL,
	tweet_count 	INT  NOT NULL,

	PRIMARY KEY (id)
);

CREATE TABLE tweet (
	tweet_id 	     INT,
	author_tweet_id  INT  NOT NULL,
	tweet_type	     TEXT NOT NULL,

	retweet_count 	 INT  NOT NULL,
	like_count 	     INT  NOT NULL,
	reply_count 	 INT  NOT NULL,
	quote_count 	 INT  NOT NULL,

	language 	     TEXT NOT NULL,
	text 		     TEXT     NULL,
	created_at       TEXT NOT NULL,
	place_id	     TEXT     NULL,

	parent_tweet_id  INT      NULL,

	PRIMARY KEY (tweet_id),

	FOREIGN KEY      (parent_tweet_id) 
	REFERENCES tweet (tweet_id)
	ON UPDATE CASCADE
	ON DELETE NO ACTION,

	FOREIGN KEY             (author_tweet_id)
	REFERENCES twitter_user (id)
	ON UPDATE CASCADE
	ON DELETE NO ACTION
);

-- The table nodes is build only for convenience,
-- for further searches!!!
CREATE TABLE nodes (
	tweet_id		        INT NOT NULL,

	generation_of_tweet_id  INT DEFAULT 0,
	amount_of_sons		    INT DEFAULT 0,

	PRIMARY KEY (tweet_id),

	FOREIGN KEY (tweet_id)
	REFERENCES tweet (tweet_id)
	ON UPDATE CASCADE
	ON DELETE NO ACTION
);

-- Am I going ot use any of the tables below??? {{{1
--CREATE TABLE user_followed (
--	user_X 		   INT,
--	user_who_follows_X INT,
--
--	PRIMARY KEY (user_X, user_who_follows_X),
--	FOREIGN KEY (user_X)		 REFERENCES twitter_user (id),
--	FOREIGN KEY (user_who_follows_X) REFERENCES twitter_user (id)
--);
--
--CREATE TABLE who_liked_tweet_Y (
--	tweet_Y          INT NOT NULL,
--	user_who_liked_Y INT NOT NULL,
--
--	PRIMARY KEY (tweet_Y, user_who_liked_Y),
--	FOREIGN KEY (tweet_Y)	       REFERENCES tweet (tweet_id),
--	FOREIGN KEY (user_who_liked_Y) REFERENCES twitter_user (id)
--);
--
--CREATE TABLE who_rt_tweet_Y (
--	tweet_Y       INT NOT NULL,
--	user_who_rt_Y INT NOT NULL,
--
--	PRIMARY KEY (tweet_Y, user_who_rt_Y),
--	FOREIGN KEY (tweet_Y) 	    REFERENCES tweet (tweet_id),
--	FOREIGN KEY (user_who_rt_Y) REFERENCES twitter_user (id)
--);
--
--CREATE TABLE who_quoted_tweet_Y (
--	tweet_Y 		INT NOT NULL,
--	user_who_quoted_tweet_Y INT NOT NULL,
--
--	PRIMARY KEY (tweet_Y, user_who_quoted_tweet_Y),
--	FOREIGN KEY (tweet_Y)		      REFERENCES tweet (tweet_id),
--	FOREIGN KEY (user_who_quoted_tweet_Y) REFERENCES twitter_user (id)
--);
--
--CREATE TABLE who_answered_tweet_Y (
--	tweet_Y             INT NOT NULL,
--	user_who_answered_Y INT NOT NULL,
--
--	PRIMARY KEY (tweet_Y, user_who_answered_Y),
--	FOREIGN KEY (tweet_Y) 		  REFERENCES tweet (tweet_id),
--	FOREIGN KEY (user_who_answered_Y) REFERENCES twitter_user (id)
--);
-- 1}}}
