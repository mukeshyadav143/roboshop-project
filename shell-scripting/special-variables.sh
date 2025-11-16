#!/bin/bash

$0: Script name ---> echo "script name: $0"
#$1, $2…: Positional arguments --->  echo "1st argument: $1"
$@: All arguments individually ---> echo "all arguments individually: $@"
$*: All arguments as one string ---> echo "all arguments as one string: $*"
$#: Number of arguments passed to the script ---> echo "number of arguments: $#"
$PWD: Current working directory ---> echo "current directory: $PWD"
$HOME: Home directory of the current user ---> echo "who is running this: $USER"
$USER: User running the script ---> echo "who is running this: $USER"
$$: Process ID of the current script ---> echo "PID of this script: $$"
$!: PID of the last background command ---> echo "PID of the last command in the background is: $!"
$?: Exit status of the last executed command ---> echo "exit status of last command: $?"
$-: Current shell flags/options ---> echo "current shell options: $-"
