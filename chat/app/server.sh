#!/bin/bash

## Create the response FIFO
rm -f response
mkfifo response


function handle_GET_home() {
	if [ -z $COOKIE_NAME ]
	then
		handle_POST_logout
	else
		RESPONSE=$(cat html/home.html | \
		sed "s/{{$COOKIE_NAME}}/$COOKIE_VALUE/")
	fi
}

function handle_GET_login() {
  	RESPONSE=$(cat html/login.html)
	echo "runme"
}

function handle_POST_login() {
	RESPONSE=$(cat http/post-login.http | \
	sed "s/{{cookie_name}}/$INPUT_NAME/" | \
	sed "s/{{cookie_value}}/$INPUT_VALUE/" | \
	sed "s/{{ip}}/$IP/" | \
	sed "s/{{port}}/$PORT/")
}

function handle_POST_logout() {
	RESPONSE=$(cat http/post-logout.http | \
	sed "s/{{cookie_name}}/$COOKIE_NAME/" | \
	sed "s/{{cookie_value}}/$COOKIE_VALUE/" | \
	sed "s/{{ip}}/$IP/" | \
	sed "s/{{port}}/$PORT/")
}

function handle_POST_chat() {
	TEXT_FOR_CHAT=$(echo $INPUT_VALUE | sed "s/+/ /g" | sed "s/%2B/+/g")
	[[ $INPUT_NAME == "user_message_draft" ]] && echo -n "$COOKIE_VALUE: $TEXT_FOR_CHAT\\&#13\\;\\&#10\\;" >> chat_text.txt
	CHAT_TEXT=$(cat chat_text.txt)
	RESPONSE=$(cat html/chat.html | sed "s/{{$COOKIE_NAME}}/$COOKIE_VALUE/" | sed "s/{{chat_text}}/$CHAT_TEXT/")
}

function handle_not_found() {
	RESPONSE=$(cat html/404.html)
}


function handleRequest() {
	## Read request
	while read line; do
		echo $line
		trline=$(echo $line | tr -d '[\r\n]')

		[ -z "$trline" ] && break

		HEADLINE_REGEX='(.*?)\s(.*?)\sHTTP.*?'
		[[ "$trline" =~ $HEADLINE_REGEX ]] &&
    		REQUEST=$(echo $trline | sed -E "s/$HEADLINE_REGEX/\1 \2/")
	
		CONTENT_LENGTH_REGEX='Content-Length:\s(.*?)'
		[[ "$trline" =~ $CONTENT_LENGTH_REGEX ]] &&
    		CONTENT_LENGTH=$(echo $trline | sed -E "s/$CONTENT_LENGTH_REGEX/\1/")

		COOKIE_REGEX='Cookie:\s(.*?)\=(.*?).*?'
		[[ "$trline" =~ $COOKIE_REGEX ]] &&
	    	read COOKIE_NAME COOKIE_VALUE <<< $(echo $trline | sed -E "s/$COOKIE_REGEX/\1 \2/")

		HOST_REGEX="Host: ([^:]+):([0-9]+)"
		[[ "$trline" =~ $HOST_REGEX ]] &&
		read IP PORT <<< $(echo $trline | sed -E "s/$HOST_REGEX/\1 \2/")
	done

	## Read body
	if [ ! -z "$CONTENT_LENGTH" ]; then
		BODY_REGEX='(.*?)=(.*?)'

		while read -n$CONTENT_LENGTH -t1 line; do
    		echo $line
    		trline=`echo $line | tr -d '[\r\n]'`

    		[ -z "$trline" ] && break

    		read INPUT_NAME INPUT_VALUE <<< $(echo $trline | sed -E "s/$BODY_REGEX/\1 \2/")
		done
	fi

	## Route to the response handlers
	case "$REQUEST" in
    	"GET /login")   handle_GET_login ;;
    	"GET /")        handle_GET_home ;;
    	"POST /login")  handle_POST_login ;;
	"POST /logout") handle_POST_logout ;;
	"POST /chat")	handle_POST_chat ;;
	*)              handle_not_found ;;
	esac

	echo -e "$RESPONSE" > response
}

echo 'Listening on 3000...'

## Keep server running forever
while true; do
  ## 1. wait for FIFO
  ## 2. creates a socket and listens to the port 3000
  ## 3. as soon as a request message arrives to the socket, pipes it to the handleRequest function
  ## 4. the handleRequest function processes the request message and routes it to the response handler, which writes to the FIFO
  ## 5. as soon as the FIFO receives a message, it's sent to the socket
  ## 6. closes the connection (`-N`), closes the socket and repeat the loop
  cat response | nc -lN 3000 | handleRequest
done
