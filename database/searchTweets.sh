#!/bin/bash
## Title: Searching for the keywords of the project
##-------------------------------------------------
#
# Programing Language: shell script
# Author:              Rafael PC
#
# Brief Description
#       |
#        `-> This script is given the task for fetching tweets
#            cointaining any keyword (of a specific language) described on
#            'keywordsList.txt' and written at a specific time,
#            set on 'time.txt'
#
#            Both files, 'keywordsList.txt' and 'time.txt', must follow a specific
#            pattern for the correct work of this script. The way they must be
#            written are explained, as comment, on the first lines of the files itself
#
#       At the end we will have a collection of json files with the tweets we 
#       are interested in.
#
# WARNING: For this script to work you MUST have an enviroment variable 
#          named "bearer_token". Such variable MUST have your "bearer token"
#          developer's key as value, so CURL works properly. This can be generated
#          easily at the Twitter Developer Area.
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
# The script will look for every tweet published in the 
# time interval [t0,t0 + deltaH:deltaM] of day startSearch.
# This can be seen at table below:
#
#           Date		 initial time	 end time
#           -----------------------------------------------
#           startSearch  t0              t0 + deltaH:deltaM

### Date: YYYY-MM-DD
startSearch=`grep -P "^[^#]" time.txt| grep -P "^[^ ]+"| sed -n 1p`

### Time: HH:MM:SS (UTC) 
t0=`grep -P "^[^#]" time.txt| grep -P "^[^ ]+"| sed -n 2p`
deltaH=`grep -P "^[^#]" time.txt|grep -P "^[^ ]+"| sed -n 3p`
deltaM=`grep -P "^[^#]" time.txt|grep -P "^[^ ]+"| sed -n 4p`

### Query:
myQuery="("
myQuery+=`grep -P "^[^#]" keywordsList.txt|
          grep -P "^[^ ]+"|
          grep -v -P "^lang:"|
          perl -pe 's/\n/ /g'`
myQuery+=") "
myQuery+=`grep -P "^[^#]" keywordsList.txt|
          grep -P "^lang:.*"|
          perl -pe 's/\n/ /g'`

# Remove white spaces and : from myQuery
myQuery="${myQuery// /%20}"
myQuery="${myQuery//:/%3A}"

### maximum Results per pagination:
### -------------------------------
### maxresults tells Twitter API how many tweets to return at each request.

maxResults="&max_results=100"	
 
### tweet fields:
### -------------
### tweetFields will tell Twitter's API which fields of a tweet we 
### wish to receive

tweetFields="author_id,id,text,lang,public_metrics,geo,created_at,\
referenced_tweets"	
 
### expansions:
expansions="author_id,geo.place_id,in_reply_to_user_id,referenced_tweets.id,\
referenced_tweets.id.author_id"
 
### place.fields:
placeFields="country,name,full_name"
 
### user.fields
userFields="location,name,username,public_metrics,id"
 
  
# twitterLink is exactly the url where the API responsible for searching
# tweets is at.
twitterLink="https://api.twitter.com/2/tweets/search/all?"
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
				curlAtempts=$((curlAtempts+1))
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

# Variable below will count how many times we have called the program
# CURL. Reaching 300 we have to wait for a while to reset this variable
callTwitter=0

# We start our loop with dayToSearch
dayToSearch=$startSearch
pagination=0



############### WRITING THE URL TO MAKE THE REQUESTS #################

##### TIME VARIABLES 
# Time: t0 (UTC)
strDate=$dayToSearch"T"$t0"Z"

timeToStartSearch=`date -d "$strDate" -u "+%Y-%m-%dT%H:%M:%SZ"`

timeToEndSearch=`date -d "$timeToStartSearch + $deltaH hours" -u "+%Y-%m-%dT%H:%M:%SZ"`
timeToEndSearch=`date -d "$timeToEndSearch + $deltaM min" -u "+%Y-%m-%dT%H:%M:%SZ"`

timeToLook="start_time="$timeToStartSearch"&end_time="$timeToEndSearch



##### TWITTER API 

# the whole url to make the request
twitterAPI=$twitterLink$timeToLook"&query="$myQuery
twitterAPI+="&tweet.fields="$tweetFields$maxResults"&expansions="
twitterAPI+=$expansions"&place.fields="$placeFields"&user.fields="
twitterAPI+=$userFields	

######################################################################


clear
echo "Searching for tweets"
echo "	From: $timeToStartSearch"
echo "	To:   $timeToEndSearch"
sleep 5

saveAtThisFile="$dayToSearch""_pagination""$pagination"".txt"
authentication="Authorization: Bearer $bearer_token"

# Check if the download should start from 0 or continue from a stopped
# point
continueDownload=`ls *pagination* 2> /dev/null| wc -l`
next_token=""
amountOfTweetsFound=0

if [ $continueDownload -gt 1 ]
then
    lastFile=`ls *pagination*|
              sort -V        |
              tail -n 2      |
              sed -n 1p`

    next_token=`cat "$lastFile" |
                grep -o -E "\"next_token\":\".*\""`

    pagination=`echo $lastFile             |
                grep -o -P "pagination\d+" |
                grep -o -P "\d+"`

    amountOfTweetsFound=0
else
    checkRateLimit 
    curl -s -X GET -H "$authentication" "$twitterAPI" > "$saveAtThisFile"
    curlProblem=$?
    sleep 1

    # check if everything went fine with curl
    if test $curlProblem -ne 0
    then	
        curlAtempts=1
        echo "Problems with curl"
        while test $curlAtempts -le 5
        do
            curl -s -X GET -H "$authentication" "$twitterAPI" > "$saveAtThisFile"
            curlProblem=$?
            test $curlProblem -eq 0 && break
            curlAtempts=$((curlAtempts+1))
        done
        test $curlProblem -ne 0 && exit 2
        echo "Problem with curl solved"
    fi
    callTwitter=$((callTwitter+1))

    next_token=`cat "$saveAtThisFile" |
                grep -o -E "\"next_token\":\".*\""`

    amountOfTweetsFound=`cat $saveAtThisFile  |
                         grep -o -E "\"id\":" |
                         wc -l`
fi


##### looping throughout pagination

# check if there is more pagination than one
if test -z "$next_token"
then 
    searchThroughoutPagination "empty_next_token" $dayToSearch $twitterAPI
else
    searchThroughoutPagination $next_token $dayToSearch $twitterAPI
fi

#dayToSearch=`date -I -d "$dayToSearch + 1 day"` 
