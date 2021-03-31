## Title: Searching for the keywords of the project
##-------------------------------------------------
#
# Programing Language: shell script
# Author:              Rafael PC
#
# Brief Description
#       |
#        `-> This sript	is given the task of searching tweets satisfying the
#        constraint of having been created between 22:00PM and 01:00 AM at the
#        UTC time (which is equivalent to the interval time 19:00PM - 22:00PM,
#        brazilian time) AND  one of the following keywords:
#		   1. Vaccine; 
#		   2. chloroquine;
#		   3. Covid or corona or Covid-19;
#		   4. kit-covid;
#		   5. early-treatment;
#		   6. azithromycin;
#		   7. lockdown.
#
#		     It is important to notice that a simple tweet enfolds a large set 
#		 of elements, such as: the owner of the tweet, how many people 
#		 reacted to the message as well who, the images or urls at the text,
# 		 and so on...
#
#		     Here we will be interested only at the following elements of a
#		  tweet:
# 		  => The tweet ID;
#		  => The ID of the owner who wrote it;
#		  => The text of the tweet;
#         => A list up to 100 elements that have LIKED the tweet;
#		  => A list up to 100 elements that have RT the tweet;

myQuery="vacina OR \
		 cloroquina OR \
		 covid OR corona OR covid-19 \
		 \"tratamento antecipado\" OR \"tratamento precoce\" \
		 azitromicina OR \
		 lockdown"

startSearch=2021-01-01
endSearch=2021-03-31

while [ "$startSearch" != "$endSearch" ]; do

	echo $startSearch
	startSearch=`date -I -d "$startSearch + 1 day"` 
	sleep 1
done	
