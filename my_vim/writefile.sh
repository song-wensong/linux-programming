#/bin/bash

# 函数
function Up {
    echo "There is Up function"
}
function Down {
    echo "There is Down function"
}
function Right {
    echo "There is Right function"
}
function Left {
    echo "There is Left function"
}
function Esc {
    echo "There is Esc function"
}





# 指令

clear

# 将标准输入重定向至文件描述符3
exec 3<&0
# 将文件重定向到标准输入
exec 0< "$1"
# 保存内部分隔符，便于之后还原
IFS_OLD=$IFS
# 修改内部分隔符仅为换行符
IFS=$'\n'

# 存储文件内容
text=""
# 行计数
count=1

# # 读取文件内容
# while read -e line
# do
#     # 打印行内容，以换行符为分隔符
#     echo "Line #$count: $line"
#     # 将每行内容以字符串形式存储
#     text=$(printf "%s\n%s" "$text" "$line")
#     count=$[ $count + 1 ]
# done

# cat "$1" > $text
text=$(cat "$1")

# 打印文件内容
echo "$text"



# 还原内部分隔符
IFS=$IFS_OLD
# 将文件描述符3重定向至标准输入，恢复标准输入
exec 0<&3

# 接受用户输入
while true
do
	# 状态机：普通模式，插入模式和命令模式
	case "$state" in
	0)
	    # 普通模式
	    echo "普通模式,$state"
        # 读取键盘输入
		read -n 1 -s character
		if [ "$character" = "i" ]
		then
		    state=1
		elif [ "$character" = ":" ]
		then
		    state=2
        fi
		# echo "$character"
		;;
	1)
	    # 插入模式
	    # echo -n "插入模式，$state"
	    # echo -n "$state"
		read -n 1 -r character
		if [[ "$charcter" = $'\e' ]]
		then
		    state=0
		fi
		;;
	2)
	    # 命令模式
	    echo "命令模式，$state"
		read -r character
		if [ "$character" = "wq" ]
		then
		    break
		fi
		;;
	esac
# fi
done

# read line
# echo "$line"