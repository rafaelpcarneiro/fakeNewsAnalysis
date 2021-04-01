#!/bin/bash
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


########################## AUXILIARY FUNCTIONS ##########################
checkRateLimit () {
	if test $callTwitter -eq 300
		waitingBar=""
		then 
			echo "Wait 15min to erase the Rate Limit counter of Twitter"
			counter=0
			while test $counter -le 14
			do
				sleep 1m
				waitingBar+="#"
				echo $waitingBar
				counter=$((counter+1))
			done
	fi
}

searchThroughoutPagination() {
	# Parameter here is:
	#  	    $1 = next_token field
	#		$2 = dayToSearch
	#		$3 = twitterAPI

	if test -z "$1"
	then
		echo ""
		echo "Searching at day $2 is now complete!"
		echo "------------------------------------------------"
		echo ""
		echo "Statistics:"
		echo "    Paginations            = $pagination"
		echo "    Amount of Tweets Found = $amountOfTweetsFound"
		echo ""
		echo ""
	else
		### Printing usefull info
		barOfProgress=$((pagination%8))
		echo ""
		echo "Search at day $3 is being performed!"
		echo "------------------------------------------------"
		echo ""
		echo "Statistics:"
		echo "    Paginations            = $pagination"
		echo "    Amount of Tweets Found = $amountOfTweetsFound"
		echo ""
		echo ""
		case "$barOfProgress" in
			"0")
				echo " Progress |"
				;;
			"1")
				echo " Progress /"
				;;
			"2")
				echo " Progress -"
				;;
			"3")
				echo " Progress \\"
				;;
			"4")
				echo " Progress |"
				;;
			"5")
				echo " Progress /"
				;;
			"6")
				echo " Progress -"
				;;
			"7")
				echo " Progress \\"
				;;
		esac

		### Now seacrh again	
		next_token=`echo $1 |grep -o -E "\"next_token\":\".*\""|cut -c14-`
		pagination=$((pagination+1))

		url=$3"&next_token="$next_token

		saveAtThisFile="$2""_pagination""$pagination"".txt"

		checkRateLimit 
		curl -X GET -H "$authentication" "$url" >> "$saveAtThisFile"

		callTwitter=$((callTwitter+1))
		sleep 1

		next_token=`cat $saveAtThisFile |grep -o -E "\"next_token\":\".*\""`

		temp=$amountOfTweetsFound
		amountOfTweetsFound=`cat $saveAtThisFile|grep -o -E "\"id\":"|wc -l`
		amountOfTweetsFound=$((amountOfTweetsFound+temp))

		searchThroughoutPagination $next_token\
		 						   $2\
								   $twitterAPI
	fi
}



########################### MAIN SCRIPT ##################################
myQuery="(vacina OR \
cloroquina OR \
covid OR corona OR covid-19 \
\"tratamento antecipado\" OR \"tratamento precoce\" \
azitromicina OR \
lockdown) lang:pt"

# Remove white spaces from myQuery
myQuery="${myQuery// /%20}"

# Remove colon char from myQuery
myQuery="${myQuery//:/%3A}"

#myQuery="(vacina%20OR%20\
#cloroquina%20OR%20\
#covid%20OR%20%20corona%20OR%20%20covid-19\
#\"tratamento%20antecipado\"%20OR%20%20\"tratamento%20precoce\"\
#azitromicina%20OR%20\
#lockdown)%20lang%3Apt"

startSearch=2021-01-01
endSearch=2021-03-31

dayToSearch=$startSearch
echo $dayToSearch

while test "$dayToSearch" != "$endSearch" 
do
	pagination=0
    ############### Writing the url to make the requests #################
	----------------------------------------------------------------------

	######################### TIME VARIABLES #############################
	timeToStartSearch="$dayToSearch""T22:00:00Z"

	timeToEndSearch=`date -I -d "$dayToSearch + 1 day"` 
	timeToEndSearch="$timeToEndSearch""T01:00:00Z"

	timeToLook="start_time="$timeToStartSearch"&end_time="$timeToEndSearch


	######################### TWITTER API ################################
	twitterLink="https://api.twitter.com/2/tweets/search/all?"


	######################## TWEET FIELDS ################################
	tweetFields="author_id,id,text,lang,public_metrics,geo,created_at"	


	######################## MAX TWEETS SEARCHED #########################
	maxResults="&max_results=10"	


	#the whole url to make the request
	twitterAPI=$twitterLink$timeToLook"&query="$myQuery
	twitterAPI+="&tweet.fields="$tweetFields$maxResults

	echo "$twitterAPI"
	######################################################################

	saveAtThisFile="$dayToSearch""_pagination""$pagination"".txt"
	authentication="Authorization: Bearer $bearer_token"
	curl -X GET -H "$authentication" "$twitterAPI" >> "$saveAtThisFile"

	# Variable below will count how many times we have called of the program
	# curl. Reaching 300 we have to wait a while to reset this variable
	callTwitter=1

	# Wait one second before next search
	sleep 1

	#curl -X GET -H "Authorization: Bearer $bearer_token" "$twitterAPI" >>\
	#"$dayToSearch""pagination""$pagination"".txt"

	##### looping throughout pagination
	next_token=`cat "$saveAtThisFile" |grep -o -E "\"next_token\":\".*\""`
	amountOfTweetsFound=`cat $saveAtThisFile|grep -o -E "\"id\":"|wc -l`
	searchThroughoutPagination $next_token $dayToSearch $twitterAPI


	dayToSearch=`date -I -d "$dayToSearch + 1 day"` 
done	
#cat 2021-01-01.txt |grep -o -E "\"next_token\":\".*\""


#curl -X GET -H "Authorization: Bearer $bearer_token" "https://api.twitter.com/2/tweets/2/tweets/1374909220584370178?tweet.fields=author_id,text,lang,referenced_tweets" >> tweets.json
