# vim: foldmethod=marker:
echo "Considering that a message branch [a b c d e] has size 5."
echo "What size of message branches should I take in consideration"
echo "to remove it from the graph"
echo ""
echo "Give a size number N and I will remove all individuals that are roots"
echo "of message branches whose size are greater or equal than N"
echo ""
echo -n "Value N: "
read answer

# Start by checking the roots of all message branches considered large
# {{{1
sh countWordsLine.sh $answer    > longChats.txt
grep -o -P "^\d*" longChats.txt > longChatsB.txt
# 1}}}

# Now that we have the roots we will look for the users that have created 
# these messages. Then we will store all tweet_ids connected with these accounts
# {{{1
longChatSize=`wc -l longChatsB.txt| grep -o -P "^\d*"`
i=1

echo "CREATE VIEW longChats AS" >> longChats.sql
echo "SELECT "                  >> longChats.sql
echo "    author_tweet_id"      >> longChats.sql
echo "FROM"                     >> longChats.sql
echo "    tweet"                >> longChats.sql
echo "WHERE"                    >> longChats.sql
while IFS= read -r line; do
    if [ $i -eq 1 ]; then
        echo "(tweet_id = $line"
        echo "OR"
    elif [ $i -eq $longChatSize ]; then
        echo "tweet_id = $line)"
    else
        echo "tweet_id = $line"
        echo "OR"
    fi
    i=$((i+1))
done < longChatsB.txt >> longChats.sql

echo "AND"                                               >> longChats.sql
echo "(tweet_type = \"simple_message\""                  >> longChats.sql
echo "OR"                                                >> longChats.sql
echo "tweet_type = \"quote_plus_simple_message\");"      >> longChats.sql

echo ".separator \"  \""                                 >> longChats.sql
echo ".output \"longChatsTweets.txt\""                   >> longChats.sql
echo "SELECT"                                            >> longChats.sql
echo "    tweet_id"                                      >> longChats.sql
echo "FROM"                                              >> longChats.sql
echo "    tweet"                                         >> longChats.sql
echo "WHERE"                                             >> longChats.sql
echo "    author_tweet_id IN (SELECT * FROM longChats);" >> longChats.sql
echo ""                                                  >> longChats.sql
echo "DROP VIEW longChats;"                              >> longChats.sql

sqlite3 twitter.db < longChats.sql
# 1}}}

# So far so good.
# Let's check for all messages that have interected with the tweet_ids we
# found previously
# {{{1
(while IFS= read -r line; do
    grep -o -P "$line.*$" allBranches.txt 
done < longChatsTweets.txt) > longChatsTweetsB.txt

grep -o -P "\d*" longChatsTweetsB.txt > longChatsTweets.txt
# 1}}}

# Finally, we just need to delete from paths_xy all edges containing these tweet ids
# {{{1
while IFS= read -r line; do
        echo "DELETE FROM paths_xy WHERE  (from_tweet_id = $line OR to_tweet_id = $line);"
done < longChatsTweets.txt >> tweetsToIgnore.sql

sqlite3 twitter.db < tweetsToIgnore.sql
# 1}}}

# Cleaning all the mess
for file in *.txt; do
    if [ $file != "allBranches.txt" ]; then
        rm $file
    fi
done
rm *.sql
