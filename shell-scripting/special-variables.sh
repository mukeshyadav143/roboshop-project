#!/bin/bash

echo "script name: $0"
#$1, $2…: Positional arguments --->  echo "1st argument: $1"
echo "all arguments individually: $@"
echo "all arguments as one string: $*"
echo "number of arguments: $#"
echo "current directory: $PWD"
echo "who is running this: $USER"
echo "who is running this: $USER"
echo "PID of this script: $$"
echo "PID of the last command in the background is: $!"
echo "exit status of last command: $?"
echo "current shell options: $-"
