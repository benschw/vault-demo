#!/bin/bash


SVC_DATA=$(curl -s 172.20.20.10:8500/v1/catalog/service/todo)

PORT=$(echo $SVC_DATA | jq .[0].ServicePort)
ADDR=$(echo $SVC_DATA | jq .[0].Address | sed -e 's/^"//'  -e 's/"$//')

TODO_ID=$(curl -s -X POST http://$ADDR:$PORT/todo -d '{"status": "new", "content": "Hello World"}' | jq .id | sed -e 's/^"//'  -e 's/"$//')

if [ "$TODO_ID" == "" ]; then
	echo "Error: there was a problem creating a todo with 'curl -s -X POST http://s$ADDR:$PORT/todo'"
	exit 1
fi

for i in `seq 0 1`; do
	
	PORT=$(echo $SVC_DATA | jq .[$i].ServicePort)
	ADDR=$(echo $SVC_DATA | jq .[$i].Address | sed -e 's/^"//'  -e 's/"$//')
	
	CONTENT=$(curl -s http://$ADDR:$PORT/todo/$TODO_ID | jq .content | sed -e 's/^"//'  -e 's/"$//')
	if [ "$CONTENT" != "Hello World" ]; then
		echo "Error: there was a problem with the response from 'curl -s htte://$ADDR:$PORT/todo/$TODO_ID'"
		exit 1
	fi
done


FOUND_STATUS=$(curl -si -X DELETE http://$ADDR:$PORT/todo/$TODO_ID | grep HTTP/1.1 | awk '{print $2}')

if [ $FOUND_STATUS -ne 204 ]; then
	echo "Error: there was a problem deleting our test todo with 'curl -si -X DELETE http://$ADDR:$PORT/todo/$TODO_ID'"
	exit 1
fi
echo OK: tests passed
