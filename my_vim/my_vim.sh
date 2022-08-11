#!/bin/bash
# 宋文松
# 2022.08.08

# 全局变量定义
# 普通模式
state=1
# 列坐标
cursor_x=0
old_cursor_x=0
# 行坐标
cursor_y=0
# shell列数目
cols=$(tput cols)
# shell行数目
lines=$(tput lines)
# 文本显示行数目
text_lines=$(($lines-1))
text_cols=$cols
# 文本位置，即第一行第一列在文本中的第y行第x列
text_x=1
text_y=1
# 光标所在位置在文件中的列数和行数
cursor_text_x=1
cursor_text_y=1
# 文件名
filename=$1

# 初始化
function Init {
    clear
	# echo "hello world"
	
	# 检查文件是否存在
	if [ -e "$filename" ]
	then
		# # 文件存在
		# echo "OK on the filename"

		# 显示文本
		textViewer
	else
		# 文件不存在
		echo "File does not exist"
		# 退出脚本
		exit
		# # 新建文件
		# touch "$filename"
	fi
    
	MoveCursor
}

# 显示文件内容
function textViewer {
	# 还需要设定显示范围 ......
    clear
	# echo "text_y=$text_y"
	text_y_begin=$text_y
    # echo "text_y=$text_y"
	text_y_end=$((text_y+text_lines-1))
	# echo "text_y_begin=$text_y_begin"
	# echo "text_y_end=$text_y_end"
	sed -n "$text_y_begin,$text_y_end p" "$filename"
	# echo $text | cat -n
    
	MoveCursor
	# case "$state" in
	# 0)
	#     # 普通模式，在页面最后一行显示文件名称
	# 	(tput sc ; tput cup $lines 1 ; echo "$filename" ; tput rc)
	# 	;;
	# 1)
	#     # 插入模式，在页面最后一行显示-- INSERT --
	# 	;;
	# 2)
	#     # 命令模式，在页面最后一行显示:
	# 	;;
	# esac
}

# 设定光标位置
function MoveCursor {
    tput cup $cursor_y $cursor_x
}
function PosCursorInText {
	# 计算光标所在位置在文件中的列数和行数
	(( cursor_text_x=$cursor_x+$text_x ))
	(( cursor_text_y=$cursor_y+$text_y ))
}
# 向上移动光标
function Up {
    # 需要确定是否超出边界
    # if 
	if [ $cursor_y -gt 0 ]
	then
        (( cursor_y=$cursor_y-1 ))
	fi
    MoveCursor
}
function Down {
    (( cursor_y=$cursor_y+1 ))
    MoveCursor
}
function Right {
	# 计算光标所在位置在文件中的列数和行数
	PosCursorInText
    # 计算光标所在行的字符串长度
	local line=$(sed -n "$cursor_text_y,$cursor_text_y p" "$filename")

	# 如果光标小于光标所在行的字符数或者小于文本编辑宽度，则可以向右
    
    (( cursor_x=$cursor_x+1 ))
	old_cursor_x=$cursor_x
    MoveCursor
}
function Left {
    (( cursor_x=$cursor_x-1 ))
    MoveCursor
}

function Read {
    # read -s option
    # case $option in
    # $'\E[A'*)
    #     Up;;
    # $'\E[B'*)
    #     Down;;
    # $'\E[C'*)
    #     Right;;
    # $'\E[D'*)
    #     Left;;
    # $'\E'*)
    #     Esc;;
    # *)
    #     clear
    #     echo "Sorry, wrong selection";;
    # esac
	read -sN1 key # 1个字符，静默
	read -sN1 -t 0.0001 k1
	read -sN1 -t 0.0001 k2
	read -sN1 -t 0.0001 k3
	key+=${k1}${k2}${k3}

	case "$key" in
	[[:graph:]])
	    
		;;
	$'\E[A')
	    Up;;
	$'\E[B')
	    Down;;
	$'\E[C')
	    Right;;
	$'\E[D')
	    Left;;
	$'\E')
	    Esc;;
	$'\E[H') # home键
	    ;;
	$'\E[F') # end键
	    ;;
	
    esac
}

# 普通模式
function NormalMode {
    # # 普通模式
	# echo "普通模式,$state"

	# 读取键盘输入
	read -n 1 -s character
    

	# 如果读如到i，进入插入模式
	if [ "$character" = "i" ]
	then
		state=1
	# 如果读到:，进入命令行模式
	elif [ "$character" = ":" ]
	then
		state=2
	fi
	# 移动光标位置
	# ......
}

# 插入模式
function InsertMode {
    # echo -n "插入模式，$state"
	# read -n 1 -r character
    
	# read -e -r character
	# if [[ "$charcter" = $'\e*' ]]
	# then
	# 	state=0
	# fi

	# 读取用户输入
	Read
	
}
# 命令模式
function CommandMode {
	echo "命令模式，$state"
	read character
	if [ "$character" = "wq" ]
	then
		break
	fi
}


# 初始化
Init

# 接受用户输入
while true
do
	# 状态机：普通模式，插入模式和命令模式
	case "$state" in
	0)
	    # 普通模式
	    NormalMode;;
	1)
	    # 插入模式
		InsertMode;;
	2)
	    # 命令模式
		CommandMode;;
	esac
	textViewer "$filename"
done

echo "Done"
