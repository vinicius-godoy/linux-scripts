#!/bin/bash

FNAME=server.fifo
mkfifo $FNAME

echo "Server is running..."

while true
do
  read request < $FNAME
  echo "[`date`] $request"
  echo "200 PONG" > $FNAME
done
