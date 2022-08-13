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
text_lines=$(($lines - 2)) # to do，这里可以不用改，就这个设置也可以，看着比较清晰，debug
text_cols=$cols
# 文本位置，即第一行第一列在文本中的第y行第x列
text_x=1
text_y=1
# 光标所在位置在文件中的列数和行数
cursor_text_x=1
cursor_text_y=1
# 文件名
filename=$1

# 重定向错误
exec 3>&2
exec 2>testerror

failure() {
	local lineno=$1
	local msg=$2
	echo "Failed at $lineno: $msg" >>testerror
}
trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

# 设定光标位置
function MoveCursor {
	tput cup $cursor_y $cursor_x
	# echo $cursor_y$cursor_x
}
# 计算光标所在位置在文件中的列数和行数
function PosCursorInText {
	((cursor_text_x = $cursor_x + $text_x))
	((cursor_text_y = $cursor_y + $text_y))
}
# 初始化
function Init {
	clear
	# echo "hello world"

	# 检查文件是否存在
	if [ -e "$filename" ]; then
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
	cp -f "$filename" "$filename.cp"
	# 初始化光标位置
	MoveCursor
	PosCursorInText
}

# 显示文件内容
function textViewer {
	# 还需要设定显示范围 ......
	clear
	# echo "text_y=$text_y"
	text_y_begin=$text_y
	# echo "text_y=$text_y"
	text_y_end=$((text_y + text_lines - 1))
	# echo "text_y_begin=$text_y_begin"
	# echo "text_y_end=$text_y_end"
	sed -n "$text_y_begin,$text_y_end p" "$filename"
	# echo $text | cat -n

	# 因为有新老光标的交替，如果在每次while循环MoveCusor，会引起错乱

	# # 定位光标位置
	PosCursorInText

	case "$state" in
	0)
		# 普通模式，在页面最后一行显示文件名称
		(
			tput sc
			tput cup $lines 1
			printf "\"%s\"" $filename
			tput rc
		)
		;;
	1)
		# 插入模式，在页面最后一行显示-- INSERT --
		# (tput sc; tput cup $lines 0; printf "\x1b[1m-- INSERT --\x1b[0m"; tput rc)
		(
			tput sc
			tput cup $lines 0
			printf "\x1b[1m-- INSERT --\x1b[0m"
			tput cup $lines $((cols - 7))
			printf "%s,%s" $cursor_text_y $cursor_text_x
			tput rc
		)
		(
			tput sc
			tput cup $lines $((cols - 16))
			printf "%s,%s" $cursor_y $cursor_x
			tput rc
		)
		;;
	2)
		# 命令模式，在页面最后一行显示:
		;;
	esac

	MoveCursor
}

# 向上移动光标
function Up {
	# 光标所在行数大于0才能移动
	if [ $cursor_y -gt 0 ]; then
		# 将cursor_x复原
		cursor_x=$old_cursor_x

		((cursor_y = $cursor_y - 1))
		# 计算光标所在位置在文件中的列数和行数
		PosCursorInText
		# 计算光标所在行的字符串长度
		local line=$(sed -n "$cursor_text_y,$cursor_text_y p" "$filename")
		local line_len=${#line}
		# 如果光标所在行的字符串长度小于old_cursor_x（因为左右而修改的光标的左右位置），则将光标移动至
		# 这里为发现insert模式和普通模式最后位置有所区别，insert模式要多一列，奇葩，... to do
		# echo "line_len=$line_len"
		# echo $((old_cursor_x-1))
		if [ $line_len -le $((old_cursor_x - 1)) ]; then
			((cursor_x = $line_len)) # 将光标定位至字符串位置末尾
		fi
	fi
	MoveCursor
	# 移动光标后需要重新定位光标所在屏幕位置在文件中的位置
	PosCursorInText
	# # 将cursor_x复原
	# cursor_x=$old_cursor_x
}
function Down {
	# 光标所在行数小于lines才能移动
	if [ $cursor_y -lt $((text_lines - 1)) ]; then
		# 将cursor_x复原
		cursor_x=$old_cursor_x

		((cursor_y = $cursor_y + 1))
		# 计算光标所在位置在文件中的列数和行数
		PosCursorInText
		# 计算光标所在行的字符串长度
		local line=$(sed -n "$cursor_text_y,$cursor_text_y p" "$filename")
		local line_len=${#line}
		# 如果光标所在行的字符串长度小于old_cursor_x（因为左右而修改的光标的左右位置），则将光标移动至
		# 这里为发现insert模式和普通模式最后位置有所区别，insert模式要多一列，奇葩，... to do
		# echo "line_len=$line_len"
		# echo $((old_cursor_x-1))
		if [ $line_len -le $((old_cursor_x - 1)) ]; then
			((cursor_x = $line_len)) # 将光标定位至字符串位置末尾
		fi
	fi
	MoveCursor
	# 移动光标后需要重新定位光标所在屏幕位置在文件中的位置
	PosCursorInText
	# # 将cursor_x复原
	# cursor_x=$old_cursor_x
}
function Right {
	# 计算光标所在位置在文件中的列数和行数
	PosCursorInText
	# 计算光标所在行的字符串长度
	local line=$(sed -n "$cursor_text_y,$cursor_text_y p" "$filename")
	local line_len=${#line}
	# 如果光标列数小于光标所在行的字符数或者小于文本编辑宽度，则可以向右
	if [ $cursor_x -lt $line_len ] && [ $cursor_x -lt $((text_cols - 1)) ]; then
		((cursor_x = $cursor_x + 1))
		old_cursor_x=$cursor_x
	fi
	MoveCursor
	# 移动光标后需要重新定位光标所在屏幕位置在文件中的位置
	PosCursorInText
}
# 光标向左移动
function Left {
	# 判断光标所在列数是否大于0
	if [ $cursor_x -gt 0 ]; then
		((cursor_x = $cursor_x - 1))
		# 记录最新的光标列数
		old_cursor_x=$cursor_x
	fi
	# 设定光标位置
	MoveCursor
	# 移动光标后需要重新定位光标所在屏幕位置在文件中的位置
	PosCursorInText
}

function InsertVisChar {
	local key="$1" # 保存插入的字符
	echo "$key"    # debug
	# 取出第cursor_text_y行
	local line=$(sed -n "$cursor_text_y p" "$filename")
	# 提取第cursor_text_y行字符串的前部分和后半部分
	local begin=${line:0:cursor_x}
	local end=${line:cursor_x}
	line="$begin$key$end"
	# local line=$(sed -n "$cursor_text_y,$cursor_text_y p" "$filename" | sed "s/.\{$((cursor_text_x-1))\}/&$key/")
	# 替换文件中相应行
	sed -i "$cursor_text_y c\\$line" "$filename"
	# 光标向右移动，如果到了一行末尾需要向下移动，这个能不能交给less的光标自己完成？为觉得是不行的，毕竟已经控制了光标的位置
	Right
	# # 设定光标位置
	# MoveCursor
}

function Enter {
    InsertVisChar "\n"

	# # 取出第cursor_text_y行
	# local line=$(sed -n "$cursor_text_y,$cursor_text_y p" "$filename")
	# # 提取第cursor_text_y行字符串的前部分和后半部分
	# local begin=${line:0:cursor_x}
	# local end=${line:cursor_x}
	# # 替换文件
	# sed -i "$cursor_text_y c\\$begin" "$filename"
	# # 因为sed无法读取空字符，判断光标是否到一行末尾，如果到达就插入空行
	# if [ $cursor_x -eq ${#line} ]
	# then
	#     echo "$cursor_text_y end yes">>testerror
	#     sed -i "$cursor_text_y a\\\\" "$filename"
	# else
	#     echo "$cursor_text_y No end yes">>testerror
	#     sed -i "$cursor_text_y a\\$end" "$filename"
	# fi

    # 将光标移动至下一行开头
	cursor_x=0
	((cursor_y+=1))
	MoveCursor
}

function Space {
	InsertVisChar " "
}

function Backspace {
	PosCursorInText

	if [ $cursor_x -gt 0 ]; then
		# 取出第cursor_text_y行
		local line=$(sed -n "$cursor_text_y p" "$filename")
		# 提取第cursor_text_y行字符串的前部分和后半部分
		local begin=${line:0:cursor_x-1} # 位置:长度
		local end=${line:cursor_x}
		line="$begin$end"
		# 替换文件中相应行
		sed -i "$cursor_text_y c\\$line" "$filename"
		Left
	fi

	# # 如果没有到第一列，to do
	# # local temp_cursor_text_x=$((cursor_text_x-1))
	# local line=$(sed -n "$cursor_text_y,$cursor_text_y p" "$filename" | sed "s/.//$((cursor_text_x-1))")
	# # 替换文件中相应行
	# # printf "\n%s\n" $line
	# sed -i ""$cursor_text_y"c $line" "$filename"
	# # 光标向左移动，这里需要考虑是否到上一行
}

function Read {
	read -sN1 key # 1个字符，静默
	read -sN1 -t 0.0001 k1
	read -sN1 -t 0.0001 k2
	read -sN1 -t 0.0001 k3
	key+=${k1}${k2}${k3}

	case "$key" in
	[[:graph:]]) # 可见字符
		InsertVisChar "$key" ;;
	$'\E[A'*) # 上方向键
		Up ;;
	$'\E[B'*) # 下方向键
		Down ;;
	$'\E[C'*) # 右方向键
		Right ;;
	$'\E[D'*) # 左方向键
		Left ;;
	$'\E'*)
		Esc
		;;
	$'\E[H'*) # home键
		;;
	$'\E[F'*) # end键
		;;
	$'\n'*)
		Enter
		;;
	$'\t'*)
		echo "tab"
		;;
	$' '*)
		Space
		;;
	$'\b'*)
		Backspace
		;;
	$''*)
		Backspace
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
	if [ "$character" = "i" ]; then
		state=1
	# 如果读到:，进入命令行模式
	elif [ "$character" = ":" ]; then
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
	if [ "$character" = "wq" ]; then
		# break
		return
	fi
}

# 初始化
Init

# 接受用户输入
while true; do
	# 状态机：普通模式，插入模式和命令模式
	case "$state" in
	0)
		# 普通模式
		NormalMode
		;;
	1)
		# 插入模式
		InsertMode
		;;
	2)
		# 命令模式
		CommandMode
		;;
	esac
	# textViewer "$filename"# debug

	textViewer
done

# echo "Done"
# 恢复标准错误流
exec 2>&3
