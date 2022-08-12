#/bin/bash

while [ 1 ]
do
    read -sN1 key # 1个字符，静默
	read -sN1 -t 0.0001 k1
	read -sN1 -t 0.0001 k2
	read -sN1 -t 0.0001 k3
    # read -N1 key # 1个字符，静默
	# read -N1 -t 0.0001 k1
	# read -N1 -t 0.0001 k2
	# read -N1 -t 0.0001 k3
	key+=${k1}${k2}${k3}

	case "$key" in
	[[:graph:]]) # 可见字符
	    echo "graph";;
	$'\E[A'*) # 上方向键
	    echo "Up";;
	$'\E[B'*) # 下方向键
	    echo "Down";;
	$'\E[C'*) # 右方向键
	    echo "Right";;
	$'\E[D'*) # 左方向键
	    echo "Left";;
	$'\E'*)
	    echo "Esc";;
	$'\E[H'*) # home键
	    echo "home";;
	$'\E[F'*) # end键
	    echo "end";;
    $'\n'*)
        echo "enter";;
    $'\t'*)
        echo "tab";;
    $'\b'*)
        echo "Backspace\b";;
    # '\b')
    $' '*)
        echo "space";;
    $''*)
        echo "Backspace";;
    esac
done

# i=0
# array=
# while true
# do
#     read -rn1 line
#     array[$i]=$line
#     # echo ""
#     if [[ $line = $'\e' ]]
#     then
#         echo "esc,or up, down, left, right"
#         break
#     # elif [[ $line = "$'\e'" ]]
#     fi
    
#     # echo "array[$i] = ${array[$i]}"
#     ((i += 1))
# done

# echo "------------------------------"

# for (( n = 0; n < i; n += 1))
# do
#     echo ${array[$n]}
#     if [[ ${array[$n]} = '\n' ]]
#     then
#         echo "enter"
#     elif [[ ${array[$n]} = '^|' ]]
#     then
#         echo "tab"
#     fi

#     # if (( n != i - 1 ))
#     # then
#     #     echo ""
#     # fi
# done