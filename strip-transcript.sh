#!/bin/bash

# ./strip-transcript.sh [raw transcript (txt)] [p2fa-cleaned file (txt)]

# remove all special characters
tr -d ',=[].<>?%~' < $1 | \
sed -E 's/[^A-Za-z][@]+[^A-Za-z]/ {LG} /' | \
tr -d '@' | \
# replace dashes with spaces
tr '-' ' ' | \
# replace spaces with new lines
tr ' ' '\n' | \
# remove colons, should only be before the names
grep -v ":" | \
sed -E 's/ [@]+ /{LG}/' | \
sed 's/(H)/{BR}/' | sed 's/(Hx)/{BR}/' | \
sed 's/(TSK)/{LS}/' | \
# remove high-level transcript markers like (Hx) and (TSK)
grep -v "(.*)" | \
# remove all digits, they are usually used to mark overlapped speech 
tr -d [:digit:] | \
# find XX and WH patters, which are special coding patterns 
grep -vE 'XX|WH' | \
# everything goes UPPER
tr [:lower:] [:upper:] > $2


