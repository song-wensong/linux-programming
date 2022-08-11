#!/bin/bash
# 宋文松
# 2022.08.08

clear
echo "hello world"
# 普通模式，state=0
state=0
# 显示文本
# 检查文件是否存在
if [ -e "$1" ]
then
    # 文件存在
    echo "OK on the filename"
	cat $1
else
    # 文件不存在
    echo "File does not exist"
	# 退出脚本
	exit
	# # 新建文件
	# touch "$1"
fi

# 接受用户输入
while true
do
# if true
# then
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

echo "Done"
