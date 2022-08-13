#!/bin/bash
# 设定光标位置
function MoveCursor {
    tput cup $y $x
}
# 向上移动光标
function Up {
    # 需要确定是否超出边界
    # if 
    (( y=$y-1 ))
    MoveCursor
}
function Down {
    (( y=$y+1 ))
    MoveCursor
}
function Right {
    (( x=$x+1 ))
    MoveCursor
}
function Left {
    (( x=$x-1 ))
    MoveCursor
}
# function Enter {

# }
function Esc {
    echo "There is Esc function"
}

clear

# printf "\e[=3h"

cat cursor.sh

# # read line
# # tput cup 0 0
# # read line
# 列数
x=0
# 行数
y=0
# # 设置文本编辑范围
# screen_x=40
# screen_y=40

MoveCursor
while [ 1 ]
do
    read -s option
    case $option in
    $'\E[A'*)
        Up;;
    $'\E[B'*)
        Down;;
    $'\E[C'*)
        Right;;
    $'\E[D'*)
        Left;;
    $'\E'*)
        Esc;;
    $'\n'*)
        Enter;;
    *)
        clear
        echo "Sorry, wrong selection";;
    esac
done
# clear