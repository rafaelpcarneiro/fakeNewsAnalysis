-- Script responsible to create all tables described at the relational
-- model of the file db.relationalmodel.

CREATE TABLE tweet_user (
	id 		 		INT,
	name 	 		TEXT NOT NULL,
	username 		TEXT NOT NULL,
	location 		TEXT NULL,
	followers_count INT  NOT NULL,
	following_count INT  NOT NULL,
	tweet_count 	INT  NOT NULL,

	PRIMARY KEY (id)
);

CREATE TABLE tweet (
	tweet_id 		INT,
	tweet_type		TEXT NOT NULL,
	retweet_count 	INT  NOT NULL,
	like_count 		INT  NOT NULL,
	reply_count 	INT  NOT NULL,
	quote_count 	INT  NOT NULL,
	language 		TEXT NOT NULL,
	text 			TEXT NOT NULL,
	created_at      TEXT NOT NULL,
	parent_tweet_id INT  NULL,
	author_tweet_id INT  NOT NULL,

	PRIMARY KEY (tweet_id),
	FOREIGN KEY (parent_tweet_id) REFERENCES tweet (tweet_id),
	FOREIGN KEY (author_tweet_id) REFERENCES tweet_user (id)
);

CREATE TABLE user_followed (
	user_X 			   INT,
	user_who_follows_X INT,

	PRIMARY KEY (user_X, user_who_follows_X),
	FOREIGN KEY (user_X) 			 REFERENCES tweet_user (id),
	FOREIGN KEY (user_who_follows_X) REFERENCES tweet_user (id)
);

CREATE TABLE who_liked_tweet_Y (
	tweet_Y          INT NOT NULL,
	user_who_liked_Y INT NOT NULL,

	PRIMARY KEY (tweet_Y, user_who_liked_Y),
	FOREIGN KEY (tweet_Y)		   REFERENCES tweet (tweet_id),
	FOREIGN KEY (user_who_liked_Y) REFERENCES tweet_user (id)
);

CREATE TABLE who_rt_tweet_Y (
	tweet_Y       INT NOT NULL,
	user_who_rt_Y INT NOT NULL,

	PRIMARY KEY (tweet_Y, user_who_rt_Y),
	FOREIGN KEY (tweet_Y) 	    REFERENCES tweet (tweet_id),
	FOREIGN KEY (user_who_rt_Y) REFERENCES tweet_user (id)
);

CREATE TABLE who_quoted_tweet_Y (
	tweet_Y 				INT NOT NULL,
	user_who_quoted_tweet_Y INT NOT NULL,

	PRIMARY KEY (tweet_Y, user_who_quoted_tweet_Y),
	FOREIGN KEY (tweet_Y) REFERENCES tweet (tweet_id),
	FOREIGN KEY (user_who_quoted_tweet_Y) REFERENCES tweet_user (id)
);

CREATE TABLE who_answered_tweet_Y (
	tweet_Y             INT NOT NULL,
	user_who_answered_Y INT NOT NULL,

	PRIMARY KEY (tweet_Y, user_who_answered_Y),
	FOREIGN KEY (tweet_Y) REFERENCES tweet (tweet_id),
	FOREIGN KEY (user_who_answered_Y) REFERENCES tweet_user (id)
);
