#!/bin/bash

# use consul to fetch all "todo" service instances and their health status
function getAddresses() {
	CONSUL_ADDR=$1

	SVC_DATA=$(curl -s $CONSUL_ADDR/v1/health/service/todo)
	LEN=$(echo $SVC_DATA | jq '. | length')
	IDX=$(expr $LEN - 1)
	for i in `seq 0 $IDX`; do
		HEALTHY='yes'
		CHECK_LEN=$(echo $SVC_DATA | jq ".[$i].Checks | length")
		CHECK_IDX=$(expr $CHECK_LEN - 1)
		for j in `seq 0 $CHECK_IDX`; do
			STATUS=$(echo $SVC_DATA | jq .[$i].Checks[$j].Status | sed -e 's/^"//'  -e 's/"$//')
			if [ "$STATUS" != "passing" ]; then
				HEALTHY='no'
			fi
		done
	
		PORT=$(echo $SVC_DATA | jq .[$i].Service.Port)
		ADDR=$(echo $SVC_DATA | jq .[$i].Node.Address | sed -e 's/^"//'  -e 's/"$//')
	
		echo -e "http://$ADDR:$PORT\t$HEALTHY"
	done
}

ADDRESSES=$(getAddresses 172.20.20.10:8500)
HEALTHY_INSTANCE='no'

while read -r RESULT; do
	ADDR=$(echo $RESULT | awk '{print $1}')
	HEALTHY=$(echo $RESULT | awk '{print $2}')

	if [ "$HEALTHY" == "yes" ]; then
		HEALTHY_INSTANCE='yes'
		
		# create a new todo
		TODO_ID=$(curl -s -X POST $ADDR/todo -d '{"status": "new", "content": "Hello World"}' | jq .id)
		if [ "$TODO_ID" == "" ]; then
			echo "Error: there was a problem creating a todo with 'curl -s -X POST $ADDR/todo'"
			exit 1
		fi
		
		# get created todo
		CONTENT=$(curl -s $ADDR/todo/$TODO_ID | jq .content)
		if [ "$CONTENT" != '"Hello World"' ]; then
			echo "Error: there was a problem getting a todo with 'curl -s $ADDR/todo/$TODO_ID'"
			exit 1
		fi
		
		# delete todo
		FOUND_STATUS=$(curl -si -X DELETE $ADDR/todo/$TODO_ID | grep HTTP/1.1 | awk '{print $2}')
		if [ $FOUND_STATUS -ne 204 ]; then
			echo "Error: there was a problem deleting a todo with 'curl -si -X DELETE $ADDR/todo/$TODO_ID'"
			exit 1
		fi
	else
		echo "  => Warning: service at '$ADDR' is not healthy, won't use"
	fi

done <<< "$ADDRESSES"

if [ "$HEALTHY_INSTANCE" == "yes" ]; then
	echo "'todo' service is functioning correctly"
	exit 0
else
	echo "Error: There are no healthy 'todo' services available"
	exit 1
fi

