# Creating a Relational Database who will serve for me as a platform to study how Fake News spread throughout social media.

The social media used for my analysis is *Twitter*. This choise is based on the 
following facts:
+ Twitter is a platform with a broad audience. It has the impressive numbers of:
    1. *340 million users* (Last updated: 10/10/2020)
    2. *500 million tweets per day* (Last updated: 10/10/2020)
    
+ It allows anybody to study the information being produced at the platform. And,
By information I mean all the content produced such as messages, pictures, video, audio or, 
more abstractly, graphs representing the connections between the users and their interactions. 

## The  Database
All data gathered will be stored at a *relational database* called
[SQLite](https://www.sqlite.org/index.html). 
In fact, we will use SQLite with *python3* using the following 
library [sqlite3](https://docs.python.org/3/library/sqlite3.html).

### The metodology of collection of data
The info gathered will be based on daily searches
ranging from 7PM to 10PM (at the brazilian time) and will be based
on tweets whose content might have one of the following keywords:
1. *Vaccine*;
2. *chloroquine*
3. *Covid*
4. *kit-covid* 
5. *early-treatment*
6. *azithromycin*

### The Entity-Relationship model of our database
Down below there is the diagram of our ER model. 
(/obs: the diagram was made with the program *DOT*, from 
[GRAPHVIZ](https://graphviz.org/)/)
<img style="text-align:center;" src="er.png" > Problems to load the image </img>
