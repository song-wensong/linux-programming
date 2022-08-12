#/bin/bash

clear
Width=$(tput cols)
Height=$(tput lines)
# echo "Width = $(tput cols) Height = $(tput lines)"
# sed -n "1,1p" test.txt


line=$(sed -n "1,$((Height-1)) p" test.txt)
# echo $line
# printf "%s" $line

# sed -n "2,11p" test.txt
gawk 'NR==2,NR==11{print}' test.txt

# tput cup 0 0
read -rsn1 a

# # sed -n "1,20p" test.txt | cat -n
# while [ 1 ]
# do
#     read a
# done