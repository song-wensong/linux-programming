#/bin/bash

i=0
array=
while true
do
    read -rn1 line
    array[$i]=$line
    # echo ""
    if [[ $line = $'\e' ]]
    then
        echo "esc,or up, down, left, right"
        break
    # elif [[ $line = "$'\e'" ]]
    fi
    
    # echo "array[$i] = ${array[$i]}"
    ((i += 1))
done

echo "------------------------------"

for (( n = 0; n < i; n += 1))
do
    echo ${array[$n]}
    if [[ ${array[$n]} = '\n' ]]
    then
        echo "enter"
    elif [[ ${array[$n]} = '^|' ]]
    then
        echo "tab"
    fi

    # if (( n != i - 1 ))
    # then
    #     echo ""
    # fi
done