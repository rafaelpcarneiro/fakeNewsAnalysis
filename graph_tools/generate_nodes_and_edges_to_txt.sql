.separator "    "
.output nodes.txt
SELECT COUNT(*) FROM nodes;
SELECT * FROM nodes;

.output edges.txt
SELECT COUNT(*) FROM paths_xy;
SELECT * FROM paths_xy;


.exit
