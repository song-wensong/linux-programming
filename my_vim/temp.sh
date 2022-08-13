#!/bin/bash
# 宋文松

cursor_x=0
temp='\t'
echo -e -n "\t"
temp=$(echo -e -n "\t")
echo -e -n "$temp"
printf "%s" "$temp"
# echo -e -n ${#temp}
((cursor_x+=${#temp}))
echo $cursor_x