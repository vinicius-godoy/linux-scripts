#!/bin/bash

FNAME=server.fifo

echo "GET /ping" > $FNAME

read response < $FNAME

echo $response
