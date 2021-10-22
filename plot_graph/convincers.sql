-- vim: foldmethod=marker:

-- lets call as 'A' and 'B' any user on the graph, G,
-- which interect with each other.
--
-- Here we will define as
--      weight(A) := card{ B in G; A interacts with B }
-- and
--      MAX := max { weight(A); A in G }.


CREATE VIEW tmp AS
SELECT
    to_author_tweet_id,
    COUNT(*) AS weight
FROM
    paths_xy
WHERE
    from_author_tweet_id !=-1
    AND
    path_distance = 1
GROUP BY
    to_author_tweet_id
ORDER BY
    weight ASC;

CREATE VIEW max_tmp AS
SELECT
    MAX(weight) 
FROM 
    tmp;

-- colorgroup ranges from 1 to 9. Thats why I multiply by 9
-- at the colorgroup
CREATE VIEW convincers AS
SELECT
    to_author_tweet_id,
    weight,
    1.0 * weight / (SELECT * FROM max_tmp) AS normalized_weight,
    CASE
        WHEN cast(9.0 * weight / (SELECT * FROM max_tmp) AS INT) = 9
            THEN 9
        ELSE
            cast(9.0 * weight / (SELECT * FROM max_tmp) AS INT) + 1
    END AS colorgroup
FROM
    tmp;

-- First Plot: all_data_convincers.dot
-- {{{1
.separator " "
.output "all_data_convincers.dot"
.print "graph {"
.print "overlap = false;"
.print "bgcolor = black;"
.print "spline  = line;"
.print "node [shape = circle, style=filled, color=gray, label = \"\"];"
.print "edge [colorscheme=bugn9, label = \"\"];"

.print " "
SELECT
    to_author_tweet_id,
    "[width = ",
    1+5*normalized_weight,
    "];"
FROM
    convincers; 

.print " "
SELECT DISTINCT
    L.from_author_tweet_id,
    "--",
    L.to_author_tweet_id,
    "[color = ",
    R.colorgroup,
    "];"
FROM
    (SELECT from_author_tweet_id,
            to_author_tweet_id
     FROM
        paths_xy    
     WHERE
         from_author_tweet_id != -1
         AND
         path_distance = 1) AS L,
    influencers AS R
WHERE
    L.to_author_tweet_id = R.to_author_tweet_id;

.print "}"
-- 1}}}

-- Plot: 1_perc_data_convincers.dot
-- Plot with all convincers with weight greater than 1% of MAX.
-- {{{1
.separator " "
.output "1_perc_data_convincers.dot"
.print "graph {"
.print "overlap = false;"
.print "bgcolor = black;"
.print "spline  = line;"
.print "node [shape = circle, style=filled, color=gray, label = \"\"];"
.print "edge [colorscheme=bugn9, label = \"\"];"

.print " "
SELECT
    to_author_tweet_id,
    "[color=webmaroon, width = ",
    1+5*normalized_weight,
    "];"
FROM
    convincers
WHERE
    normalized_weight >= 0.01; 

.print " "
SELECT DISTINCT
    L.from_author_tweet_id,
    "--",
    L.to_author_tweet_id,
    "[color = ",
    R.colorgroup,
    "];"
FROM
    (SELECT from_author_tweet_id,
            to_author_tweet_id
     FROM
        paths_xy    
     WHERE
         from_author_tweet_id != -1
         AND
         path_distance = 1) AS L,
    (SELECT to_author_tweet_id, colorgroup
     FROM
        convincers
     WHERE
        normalized_weight >= 0.01) AS R
WHERE
    L.to_author_tweet_id = R.to_author_tweet_id;

.print "}"
-- 1}}}

-- Plot: 5_perc_data_convincers.dot
-- Plot with all convincers with weight greater than 5% of MAX.
-- {{{1
.separator " "
.output "5_perc_data_convincers.dot"
.print "graph {"
.print "overlap = false;"
.print "bgcolor = black;"
.print "spline  = line;"
.print "node [shape = circle, style=filled, color=gray, label = \"\"];"
.print "edge [colorscheme=bugn9, label = \"\"];"

.print " "
SELECT
    to_author_tweet_id,
    "[color=webmaroon, width = ",
    1+5*normalized_weight,
    "];"
FROM
    convincers
WHERE
    normalized_weight >= 0.05; 

.print " "
SELECT DISTINCT
    L.from_author_tweet_id,
    "--",
    L.to_author_tweet_id,
    "[color = ",
    R.colorgroup,
    "];"
FROM
    (SELECT from_author_tweet_id,
            to_author_tweet_id
     FROM
        paths_xy    
     WHERE
         from_author_tweet_id != -1
         AND
         path_distance = 1) AS L,
    (SELECT to_author_tweet_id, colorgroup
     FROM
        convincers
     WHERE
        normalized_weight >= 0.05) AS R
WHERE
    L.to_author_tweet_id = R.to_author_tweet_id;

.print "}"
-- 1}}}

-- Plot: 10_perc_data_convincers.dot
-- Plot with all convincers with weight greater than 10% of MAX.
-- {{{1
.separator " "
.output "10_perc_data_convincers.dot"
.print "graph {"
.print "overlap = false;"
.print "bgcolor = black;"
.print "spline  = line;"
.print "node [shape = circle, style=filled, color=gray, label = \"\"];"
.print "edge [colorscheme=bugn9, label = \"\"];"

.print " "
SELECT
    to_author_tweet_id,
    "[color=webmaroon, width = ",
    1+5*normalized_weight,
    "];"
FROM
    convincers
WHERE
    normalized_weight >= 0.1; 

.print " "
SELECT DISTINCT
    L.from_author_tweet_id,
    "--",
    L.to_author_tweet_id,
    "[color = ",
    R.colorgroup,
    "];"
FROM
    (SELECT from_author_tweet_id,
            to_author_tweet_id
     FROM
        paths_xy    
     WHERE
         from_author_tweet_id != -1
         AND
         path_distance = 1) AS L,
    (SELECT to_author_tweet_id, colorgroup
     FROM
        convincers
     WHERE
        normalized_weight >= 0.1) AS R
WHERE
    L.to_author_tweet_id = R.to_author_tweet_id;

.print "}"
-- 1}}}

-- Plot: 20_perc_data_convincers.dot
-- Plot with all convincers with weight greater than 20% of MAX.
-- {{{1
.separator " "
.output "20_perc_data_convincers.dot"
.print "graph {"
.print "overlap = false;"
.print "bgcolor = black;"
.print "spline  = line;"
.print "node [shape = circle, style=filled, color=gray, label = \"\"];"
.print "edge [colorscheme=bugn9, label = \"\"];"

.print " "
SELECT
    to_author_tweet_id,
    "[color=webmaroon, width = ",
    1+5*normalized_weight,
    "];"
FROM
    convincers
WHERE
    normalized_weight >= 0.2; 

.print " "
SELECT DISTINCT
    L.from_author_tweet_id,
    "--",
    L.to_author_tweet_id,
    "[color = ",
    R.colorgroup,
    "];"
FROM
    (SELECT from_author_tweet_id,
            to_author_tweet_id
     FROM
        paths_xy    
     WHERE
         from_author_tweet_id != -1
         AND
         path_distance = 1) AS L,
    (SELECT to_author_tweet_id, colorgroup
     FROM
        convincers
     WHERE
        normalized_weight >= 0.2) AS R
WHERE
    L.to_author_tweet_id = R.to_author_tweet_id;

.print "}"
-- 1}}}

DROP VIEW tmp;
DROP VIEW max_tmp;
DROP VIEW convincers;
