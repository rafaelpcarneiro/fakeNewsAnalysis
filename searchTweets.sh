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
#        constraint of having been created between 22:30PM and 00:30 AM at the
#        UTC time (which is equivalent to the interval time 19:30PM - 21:30PM,
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
#
#
#
# Exit numbers returned by the program:
# -------------------------------------
#  0 = everything went ok
#  1 = user has stopped the script after finishing one day of search
#  2 = the program has stopped for network connection issues with Curl


####################### PARAMETERS OF THE SCRIPT ########################
#------------------------------------------------------------------------
#-> Here are the main parameters responsible for searching tweets
#
# => Date: YYYY-MM-DD
startSearch=2021-03-25
endSearch=2021-03-26
#
# => Time: HH:MM:SS (UTC) 
t0="21:00:00"
deltaH=3
deltaM=0
#
# The script will look for every tweet published in the 
# time interval [t0,t0 + deltaH:deltaM] of a day ranging through startSearch
# to endSearch. This can be seen at table below:
#
#			Date				initial time	end time
#			--------------------------------------------
#			startSearch	 		t0				t0 + deltaH:deltaM
#			startSearch + 1 	t0				t0 + deltaH:deltaM
#			startSearch + 2 	t0				t0 + deltaH:deltaM
#			startSearch + 3 	t0				t0 + deltaH:deltaM
#				.				.				.
#				.				.				.
#				.				.				.
#			endSearch 		 	t0				t0 + deltaH:deltaM
#
# If you want to search for tweets published at a one specifc day, just
# set: startSearch=endSearch-1. (Note that later the script will correct
# the date and times to UTC, which is the time used for Twitter.
#
# => Query:
myQuery="(vacina OR \
cloroquina OR \
covid OR corona OR covid-19 \
\"tratamento antecipado\" OR \"tratamento precoce\" \
azitromicina OR \
lockdown) lang:pt"
#
# myquery will set the keywords contained at the tweets we wish to find.
# Later the script will substitute white spaces by and colons (:)
# by %3A.
# 
# => maximum Results per pagination:
maxResults="&max_results=10"	
#
# maxresults tells Twitter API how many tweets to return at each request.
#
# => tweet fields:
tweetFields="author_id,id,text,lang,public_metrics,geo,created_at,\
referenced_tweets"	
#
# tweetFields will tell Twitter's API which fields of a tweet we 
# wish to receive
#
# => expansions:
expansions="author_id,geo.place_id,in_reply_to_user_id,referenced_tweets.id,\
referenced_tweets.id.author_id"
#
# => place.fields:
placeFields="country,name,full_name"
#
# => user.fields
userFields="location,name,username,public_metrics,id"
#
# 
twitterLink="https://api.twitter.com/2/tweets/search/all?"
#
# twitterLink is exactly the url where the API responsible for searching
# tweets is at.
#########################################################################



########################## AUXILIARY FUNCTIONS ##########################
checkRateLimit () {
	if test $callTwitter -eq 300
	then 
		waitingBar="###"
		counter=0
		clear
		echo "Wait 15min to erase the Rate Limit counter of Twitter"
		sleep 1m
		clear
		while test $counter -le 13
		do
			echo "Wait 15min to erase the Rate Limit counter of Twitter"
			echo ""
			echo ""
			echo "Timer:"
			echo "$waitingBar"
			echo "|-------------------------------------------| t=$counter"
			echo "0                   7min                    15min"
			sleep 1m
			clear
			counter=$((counter+1))
			waitingBar+="###"
		done
		callTwitter=0
	fi
}

searchThroughoutPagination() {
	# Parameter here is:
	#  	    $1 = next_token field
	#		$2 = dayToSearch
	#		$3 = twitterAPI

	if test "$1" = "empty_next_token"
	then
		mkdir "$2"
		mv $2*txt $2
		clear
		echo ""
		echo "Searching at day $2 is now complete!"
		echo "------------------------------------------------"
		echo ""
		echo "Statistics:"
		echo "    Paginations            = $pagination"
		echo "    Amount of Tweets Found = $amountOfTweetsFound"
		echo ""
		echo ""
		echo ""
		echo ""
		echo ""
		checkAnswer=0
		echo "Would you like to stop the script here? Press [y] If you want to"
		echo "to stop it"
		echo "(Obs: You have 30s to answer. In case nothing is done,"
		echo "the programme will carry on)"
		read -t 30 checkAnswer
		if test "$checkAnswer" = "y"
		then
			echo "Ending the search! Bye bye =)"
			exit 1
		else
			echo "Great, lets continue...."
		fi

		
	else
		### Printing usefull info
		barOfProgress=$((pagination%8))
		clear
		echo ""
		echo "Search at day $2 is being performed!"
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
		#next_token=`echo $1 |grep -o -E "\"next_token\":\".*\""|cut -c14-\
		#grep -o -E "[^\"].*[^\"]"`
		next_token=`echo $1 |cut -c14-| grep -o -E "[^\"].*[^\"]"`
		pagination=$((pagination+1))

		url=$twitterAPI"&next_token="$next_token

		saveAtThisFile="$2""_pagination""$pagination"".txt"

		# call function checkRateLimit
		checkRateLimit 
		curl -s -X GET -H "$authentication" "$url" > "$saveAtThisFile"

		# check if everything went fine with curl
		curlProblem=$?
		if test $curlProblem -ne 0
		then	
			echo "Problems with curl"
			curlAtempts=1
			while test $curlAtempts -le 5
			do
				curl -s -X GET -H "$authentication" "$url" > "$saveAtThisFile"
				curlProblem=$?
				test $curlProblem -eq 0 && break
				$((curlAtempts+1))
			done
			test $curlProblem -ne 0 && exit 2
			echo "Problem with curl solved"
		fi

		# sum one more valid connection with Twitter
		callTwitter=$((callTwitter+1))
		sleep 1

		next_token=`cat $saveAtThisFile |grep -o -E "\"next_token\":\".*\""`

		temp=$amountOfTweetsFound
		amountOfTweetsFound=`cat $saveAtThisFile|grep -o -E "\"id\":"|wc -l`
		amountOfTweetsFound=$((amountOfTweetsFound+temp))

		if test -z "$next_token"
		then 
			searchThroughoutPagination "empty_next_token" $2 $twitterAPI
		else
			searchThroughoutPagination $next_token $2 $twitterAPI
		fi
	fi
}



########################### MAIN SCRIPT ##################################
clear
echo "Script written  by Rafael"
echo "Shall the search begin \m/"
echo ""
echo ""
echo ""
echo ""
echo ""
sleep 5




# Remove white spaces from myQuery
myQuery="${myQuery// /%20}"

# Remove colon char from myQuery
myQuery="${myQuery//:/%3A}"

# Variable below will count how many times we have called of the program
# curl. Reaching 300 we have to wait a while to reset this variable
callTwitter=1

# We start our loop with dayToSearch
dayToSearch=$startSearch
while test "$dayToSearch" != "$endSearch" 
do
	pagination=0

    ############### WRITING THE URL TO MAKE THE REQUESTS #################

	######################### TIME VARIABLES #############################
    # Time: t0 (UTC)
	#timeToStartSearch="$dayToSearch""T22:30:00Z"
	strDate=$dayToSearch"T"$t0"Z"
	timeToStartSearch=`date -d "$strDate" -u "+%Y-%m-%dT%H:%M:%SZ"`

	timeToEndSearch=`date -d "$timeToStartSearch + $deltaH hours" -u\
	"+%Y-%m-%dT%H:%M:%SZ"`


	#timeToEndSearch=`date -I -d "$dayToSearch + 1 day"` 
	#timeToEndSearch="$timeToEndSearch""T00:30:00Z"

	timeToLook="start_time="$timeToStartSearch"&end_time="$timeToEndSearch

	######################### TWITTER API ################################

	#the whole url to make the request
	twitterAPI=$twitterLink$timeToLook"&query="$myQuery
	twitterAPI+="&tweet.fields="$tweetFields$maxResults"&expansions="
	twitterAPI+=$expansions"&place.fields="$placeFields"&user.fields="
	twitterAPI+=$userFields	

	######################################################################


	clear
	echo "Searching for tweets"
	echo "	From: `date -d $timeToStartSearch -u`"
	echo "	To:   `date -d $timeToEndSearch -u`"
	sleep 10

	saveAtThisFile="$dayToSearch""_pagination""$pagination"".txt"
	authentication="Authorization: Bearer $bearer_token"

	checkRateLimit 
	curl -s -X GET -H "$authentication" "$twitterAPI" > "$saveAtThisFile"
	sleep 1

	# check if everything went fine with curl
	curlProblem=$?
	if test $curlProblem -ne 0
	then	
		curlAtempts=1
		echo "Problems with curl"
		while test $curlAtempts -le 5
		do
			curl -s -X GET -H "$authentication" "$twitterAPI" > "$saveAtThisFile"
			curlProblem=$?
			test $curlProblem -eq 0 && break
			$((curlAtempts+1))
		done
		test $curlProblem -ne 0 && exit 2
		echo "Problem with curl solved"
	fi


	##### looping throughout pagination
	next_token=`cat "$saveAtThisFile" |grep -o -E "\"next_token\":\".*\""`
	amountOfTweetsFound=`cat $saveAtThisFile|grep -o -E "\"id\":"|wc -l`
	searchThroughoutPagination $next_token $dayToSearch $twitterAPI

	dayToSearch=`date -I -d "$dayToSearch + 1 day"` 
done	
