#!/bin/sh

echo $0 $* 
echo Environment:
echo `date`
echo 123
env

sleep 2

echo "stopping child"

exit 5
