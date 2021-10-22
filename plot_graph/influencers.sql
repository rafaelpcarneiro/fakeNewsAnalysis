-- vim: foldmethod=marker:

-- lets call as 'A' and 'B' any user on the graph, G,
-- which interect with each other.
--
-- Here we will define as
--      weight(A) := card{ B in G; B interacts with A }
-- and
--      MAX := max { weight(A); A in G }.


CREATE VIEW tmp AS
SELECT
    from_author_tweet_id,
    COUNT(*) AS weight
FROM
    paths_xy
WHERE
    from_author_tweet_id !=-1
    AND
    path_distance = 1
GROUP BY
    from_author_tweet_id
ORDER BY
    weight ASC;

CREATE VIEW max_tmp AS
SELECT
    MAX(weight) 
FROM 
    tmp;

-- colorgroup ranges from 1 to 9. Thats why I multiply by 9
-- at the colorgroup
CREATE VIEW influencers AS
SELECT
    from_author_tweet_id,
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

-- First Plot: all_data_influencers.dot
-- {{{1
.separator " "
.output "all_data_influencers.dot"
.print "graph {"
.print "overlap = false;"
.print "bgcolor = black;"
.print "spline  = line;"
.print "node [shape = circle, style=filled, color=gray, label = \"\"];"
.print "edge [colorscheme=bupu9, label = \"\"];"

.print " "
SELECT
    from_author_tweet_id,
    "[width = ",
    1+5*normalized_weight,
    "];"
FROM
    influencers; 

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
    L.from_author_tweet_id = R.from_author_tweet_id;

.print "}"
-- 1}}}

-- Plot: 1_perc_data_influencers.dot
-- Plot with all influencers with weight greater than 1% of MAX.
-- {{{1
.separator " "
.output "1_perc_data_influencers.dot"
.print "graph {"
.print "overlap = false;"
.print "bgcolor = black;"
.print "spline  = line;"
.print "node [shape = circle, style=filled, color=gray, label = \"\"];"
.print "edge [colorscheme=bupu9, label = \"\"];"

.print " "
SELECT
    from_author_tweet_id,
    "[color=darkgoldenrod3, width = ",
    1+5*normalized_weight,
    "];"
FROM
    influencers
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
    (SELECT from_author_tweet_id, colorgroup
     FROM
        influencers
     WHERE
        normalized_weight >= 0.01) AS R
WHERE
    L.from_author_tweet_id = R.from_author_tweet_id;

.print "}"
-- 1}}}

-- Plot: 5_perc_data_influencers.dot
-- Plot with all influencers with weight greater than 5% of MAX.
-- {{{1
.separator " "
.output "5_perc_data_influencers.dot"
.print "graph {"
.print "overlap = false;"
.print "bgcolor = black;"
.print "spline  = line;"
.print "node [shape = circle, style=filled, color=gray, label = \"\"];"
.print "edge [colorscheme=bupu9, label = \"\"];"

.print " "
SELECT
    from_author_tweet_id,
    "[color=darkgoldenrod3, width = ",
    1+5*normalized_weight,
    "];"
FROM
    influencers
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
    (SELECT from_author_tweet_id, colorgroup
     FROM
        influencers
     WHERE
        normalized_weight >= 0.05) AS R
WHERE
    L.from_author_tweet_id = R.from_author_tweet_id;

.print "}"
-- 1}}}

-- Plot: 10_perc_data_influencers.dot
-- Plot with all influencers with weight greater than 10% of MAX.
-- {{{1
.separator " "
.output "10_perc_data_influencers.dot"
.print "graph {"
.print "overlap = false;"
.print "bgcolor = black;"
.print "spline  = line;"
.print "node [shape = circle, style=filled, color=gray, label = \"\"];"
.print "edge [colorscheme=bupu9, label = \"\"];"

.print " "
SELECT
    from_author_tweet_id,
    "[color=darkgoldenrod3, width = ",
    1+5*normalized_weight,
    "];"
FROM
    influencers
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
    (SELECT from_author_tweet_id, colorgroup
     FROM
        influencers
     WHERE
        normalized_weight >= 0.1) AS R
WHERE
    L.from_author_tweet_id = R.from_author_tweet_id;

.print "}"
-- 1}}}

-- Plot: 20_perc_data_influencers.dot
-- Plot with all influencers with weight greater than 20% of MAX.
-- {{{1
.separator " "
.output "20_perc_data_influencers.dot"
.print "graph {"
.print "overlap = false;"
.print "bgcolor = black;"
.print "spline  = line;"
.print "node [shape = circle, style=filled, color=gray, label = \"\"];"
.print "edge [colorscheme=bupu9, label = \"\"];"

.print " "
SELECT
    from_author_tweet_id,
    "[color=darkgoldenrod3, width = ",
    1+5*normalized_weight,
    "];"
FROM
    influencers
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
    (SELECT from_author_tweet_id, colorgroup
     FROM
        influencers
     WHERE
        normalized_weight >= 0.2) AS R
WHERE
    L.from_author_tweet_id = R.from_author_tweet_id;

.print "}"
-- 1}}}

DROP VIEW tmp;
DROP VIEW max_tmp;
DROP VIEW influencers;


--CREATE VIEW convincers AS
--SELECT
--    to_author_tweet_id,
--    COUNT(*) AS weight
--FROM
--    paths_xy
--WHERE
--    from_author_tweet_id !=-1
--GROUP BY
--    to_author_tweet_id
--ORDER BY
--    weight ASC;
--
--.separator " -- "
--.once "edges_influencers.dot"
--SELECT 
--    L.from_author_tweet_id,
--    L.to_author_tweet_id,
--    cast( R.weight / 3610.0 * 90/10 AS INT) + 1
--FROM
--    (SELECT DISTINCT
--        from_author_tweet_id,
--        to_author_tweet_id
--     FROM
--        paths_xy
--     WHERE
--        from_author_tweet_id != -1) AS L,
--    influencers                     AS R
--WHERE
--    L.from_author_tweet_id = R.from_author_tweet_id;
--
--
--.separator " -- "
--.once "edges_convincers.dot"
--SELECT 
--    L.from_author_tweet_id,
--    L.to_author_tweet_id,
--    cast( R.weight / 170.0 * 90/10 AS INT) + 1
--FROM
--    (SELECT DISTINCT
--        from_author_tweet_id,
--        to_author_tweet_id
--     FROM
--        paths_xy
--     WHERE
--        from_author_tweet_id != -1) AS L,
--    convincers                      AS R
--WHERE
--    L.to_author_tweet_id = R.to_author_tweet_id;
--
--DROP VIEW convincers;

