#!/bin/bash

# Monitor active processes

old_process=$(ps -eo command)

while true; do
	new_process=$(ps -eo command)
	
	diff <(echo "$old_process") <(echo "$new_process") | grep "[\>\<]"
	old_process=$new_process
done
