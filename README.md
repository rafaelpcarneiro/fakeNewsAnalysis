# Studying topological features of the users' interaction Graph on Twitter

## A brief view of the work

Let G be the directed graph
<div align='center'>
    G = (V, E),
</div>
where <em>V</em> is the set of users that have written a tweet containing a word
in the set of keywords <strong>K</strong> and <em>E</em> the set
<div align='center'>
    E = (u, v), where  <em>u, v</em> ∈ V  and the user <em>v</em> 
    has interacted with <em>u</em>.
</div>
Here
<div align='center'>
    u → v ⇔ (u, v) ∈ E.
</div>
Also, each edge (u, v) ∈ E has a weight, given by the mean time that user 
<em>v</em> interacts with <em>u</em>.


<strong>The objective</strong>  is to analyse the persistent homology of many graphs 
related with different keywords and to observe how fakenews influence their 
topological structure. These features can be used to classify graphs
between 'organic graphs' or 'graphs influenced by fakenews'.

## Programs to capture the users' interaction Graph on Twitter

* Firstly, a [developer account on Twitter](https://developer.twitter.com/en)
is needed.

* Secondly, a <strong>Bearer Token</strong> is needed. It can be generated on the the section
  of authentication tokens at the developer portal.

Assume that you want to download tweets containing the keywords
* hello AND "hello world"
created between 12:00 (UTC 0) and 12:20(UTC 0) of the day 
2021-01-15. Below are the steps necessary to create the respective database.

Head to the folder <strong>database</strong> and edit the files 
<strong>keywordsList.txt</strong> and <strong>time.txt</strong> with the
desired parameters. These files have explanation
on how to change them. Then a few commands are necessary to be issued.

Follow the command lines below and a file named <strong>twitter.db</strong>
will be created
```
cd database
chmod +x searchTweets.sh
chmod +x insertTweetsAndUsersToDB.pl
chmod +x populateDB_part1.sh

./searchTweets
./populateDB_part1
```


The file <strong>twitter.db</strong> is a Relational Database satisfying
the Entity-Relation diagram below.

<div align='center'>
    <img src='database/er.png'
         width='900px'
         alt='ER diagram'
    />
</div>

There are more relations on the database but their utility is only for future
computations. The raw data collected from the scripts above are in the relations
of the diagram above.

The atributes of the relational database are quite straightforward. The only 
atribute that is worth mentioning is <em>tweet_type</em>. This atribute
has as possible values:
* retweet: the tweet is a RT;                         
* reply: the tweet is a reply for another tweet;
* quote_plus_reply: the tweet is a quote plus a reply to another tweet;
* simple_message: the tweet is a simple message created by a user;
* quote_plus_simple_message: the tweet is a simple message whose content includes
  a quote to another tweet.
