# Studying topological features of the users' interaction Graph on Twitter

## A brief view of the work

Let G be the directed graph
<div align='center'>
    G = (V, E),
</div>
where *V* is the set of users that have written a tweet containing a word
in the set of keywords **K** and *E* the set
<div align='center'>
    E = (u, v), where  *u,v* ∈ V  and the user *v* has interacted with *u*.
</div>
Here
<div align='center'>
    u → v ⇔ (u, v) ∈ E.
</div>
Also, each edge (u, v) ∈ E has a weight, given by the mean time that user *v*
interacts with *u*.

**The objective**  is to analyse the persistent homology of many graphs 
related with different keywords and to observe how fakenews influence their 
topological structure. These features can be used to classify graphs
between 'organic graphs' or 'graphs influenced by fakenews'.

## Programs to capture the users' interaction Graph on Twitter

* Firstly, a [developer account on Twitter](https://developer.twitter.com/en)
is needed.

* Secondly, a **Bearer Token** is needed. It can be generated on the the section
  of authentication tokens at the developer portal.

Assume that you want to download tweets containing the keywords
* hello AND "hello world"
created between 12:00 (UTC 0) and 12:20(UTC 0) of the day 
2021-01-15. Below are the steps necessary to create the respective database.

Head to the folder **database** and edit the files **keywordsList.txt**
and **time.txt** with the desired parameters. These files have explanation
of how to change them. Then a few commands are necessary to be issued.

Follow the command lines below and a file named **twitter.db** will be created
```
cd database
chmod +x searchTweets.sh
chmod +x insertTweetsAndUsersToDB.pl
chmod +x populateDB_part1.sh

./searchTweets
./populateDB_part1
```
