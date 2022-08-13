#!/bin/bash
# 宋文松
# 2022.08.08
# 我自己制作的一个简易的vim编辑器

# 全局变量定义
# 普通模式
state=0
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
text_lines=$(($lines - 2))
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

# 错误检测信息
failure() {
	local lineno=$1
	local msg=$2
	echo "Failed at $lineno: $msg" >>testerror # 向testerror中输入错误信息
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
	if [ -e "$filename" ]
	then
		# 文件存在
		textViewer # 显示文本
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
		local filename_len=${#filename} # 文件名字长度
		local filelines=$(sed -n '$=' "$filename") # 计算行数
		# 普通模式，在页面最后一行显示文件名称，行数以及光标位置
		(tput sc; tput cup $lines 1; printf "\"%s\"" $filename; tput cup $lines $((filename_len+4)); printf "%sL" $filelines; tput cup $lines $((cols - 7)); printf "%s,%s" $cursor_text_y $cursor_text_x; tput rc)
		;;
	1)
		# 插入模式，在页面最后一行显示-- INSERT --
		# (tput sc; tput cup $lines 0; printf "\x1b[1m-- INSERT --\x1b[0m"; tput rc)
		(tput sc; tput cup $lines 0; printf "\x1b[1m-- INSERT --\x1b[0m"; tput cup $lines $((cols - 7)); printf "%s,%s" $cursor_text_y $cursor_text_x; tput rc)
		(tput sc; tput cup $lines $((cols - 16)); printf "%s,%s" $cursor_y $cursor_x; tput rc)
		;;
	2)
		# 命令模式，在页面最后一行显示:
		# (tput sc; tput cup $lines 0; printf "\x1b[1m-- INSERT --\x1b[0m"; tput cup $lines $((cols - 7)); printf "%s,%s" $cursor_text_y $cursor_text_x; tput rc)
		;;
	esac

	MoveCursor
}

# Up键处理
function Up {
	# 光标所在行数大于0并且光标所在文件行数大于1
	if [ $cursor_y -gt 0 ] && [ $cursor_text_y -gt 1 ]
	then
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
	# 如果等于0且到顶端，则向上翻页
	elif [ $cursor_y -eq 0 ] && [ $cursor_text_y -gt 1 ]
	then
	    ((text_y-=1))
	fi
	MoveCursor
	# 移动光标后需要重新定位光标所在屏幕位置在文件中的位置
	PosCursorInText
	# # 将cursor_x复原
	# cursor_x=$old_cursor_x
}
# Down键处理
function Down {
	# 文件行数
	local filelines=$(sed -n '$=' "$filename")
	# 光标所在行数小于lines才能移动并且光标所在文行的行数小于文件总行数
	if [ $cursor_y -lt $((text_lines - 1)) ] && [ $cursor_text_y -lt $filelines ]
	then
		# 将cursor_x复原
		cursor_x=$old_cursor_x
        # 将光标下移一行
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
		if [ $line_len -le $((old_cursor_x - 1)) ]
		then
			((cursor_x = $line_len)) # 将光标定位至字符串位置末尾
		fi
	# 如果光标移到指定屏幕最后一行，进行翻页
	elif [ $cursor_y -eq $((text_lines - 1)) ] && [ $cursor_text_y -lt $filelines ]
	then
	    ((text_y+=1))
	fi
	MoveCursor
	# 移动光标后需要重新定位光标所在屏幕位置在文件中的位置
	PosCursorInText
	# # 将cursor_x复原
	# cursor_x=$old_cursor_x
}
#处理right键
function Right {
	# 计算光标所在位置在文件中的列数和行数
	PosCursorInText
	# 计算光标所在行的字符串长度
	local line=$(sed -n "$cursor_text_y,$cursor_text_y p" "$filename")
	local line_len=${#line}
	# 如果光标列数小于光标所在行的字符数或者小于文本编辑宽度，则可以向右
	if [ $cursor_x -lt $line_len ] && [ $cursor_x -lt $((text_cols - 1)) ]; then
		((cursor_x = $cursor_x + 1))
		old_cursor_x=$cursor_x # 记录最新光标位置
		MoveCursor
		# 移动光标后需要重新定位光标所在屏幕位置在文件中的位置
		PosCursorInText
	fi
	# MoveCursor
	# # 移动光标后需要重新定位光标所在屏幕位置在文件中的位置
	# PosCursorInText
}
# 处理Left键
function Left {
	# 判断光标所在列数是否大于0
	if [ $cursor_x -gt 0 ]
	then
		((cursor_x = $cursor_x - 1))
		# 记录最新的光标列数
		old_cursor_x=$cursor_x
		# 设定光标位置
		MoveCursor
		# 移动光标后需要重新定位光标所在屏幕位置在文件中的位置
		PosCursorInText
	fi
}
# 插入字符
function InsertVisChar {
	local key="$1" # 保存插入的字符
	if [ -s "$filename" ] # 如果文件存在且为非空
	then
	    # 取出第cursor_text_y行
		local line=$(sed -n "$cursor_text_y p" "$filename")
		# 提取第cursor_text_y行字符串的前部分和后半部分
		local begin=${line:0:cursor_x}
		local end=${line:cursor_x}
		line="$begin$key$end"
		# 替换文件中相应行
		sed -i "$cursor_text_y c\\$line" "$filename"
	else
		# 如果文件为空，向文件中输入字符
	    echo -n "$key" > "$filename"
	fi
	# 光标向右移动
	Right
	# # 设定光标位置
	# MoveCursor
}
# Esc键处理
function Esc {
	# 进入普通模式
	state=0
}
# Enter键处理
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

    # 将光标移动至下一行
	Down
	# 将光标移动至一行开头
	cursor_x=0
	MoveCursor
}
# Tab键处理，将Tab替换为4个空格
function Tab {
	InsertVisChar " "; InsertVisChar " "; InsertVisChar " "; InsertVisChar " "
}
# space键处理
function Space {
	InsertVisChar " "
}
# Backspace键处理
function Backspace {
	PosCursorInText
    # 取出第cursor_text_y行
	local line=$(sed -n "$cursor_text_y p" "$filename")
	if [ $cursor_x -gt 0 ] # 如果光标所在列数大于0
	then
		# 提取第cursor_text_y行字符串的前部分和后半部分
		local begin=${line:0:cursor_x-1} # 位置:长度
		local end=${line:cursor_x}
		line="$begin$end"
		# 替换文件中相应行
		sed -i "$cursor_text_y c\\$line" "$filename"
		# 光标向左移动
		Left
		# 如果此行中为空行并且此行不为文件第一行，则插入一个换行符
		if [ ${#line} -eq 0 ] && [ $cursor_text_y -gt 1 ]
		then
		    InsertVisChar "\n"
		fi
	elif [ $cursor_x -eq 0 ] # 如果光标处于第0列
	then
	    # 如果光标所在文本行数大于1
		if [ $cursor_text_y -gt 1 ]
		then
		    # 上一行
	        local lastline=$(sed -n "$((cursor_text_y-1)) p" "$filename")
			# 上一行与光标所在行的拼接
			local newline="$lastline$line"
            # 删除光标所在行
			sed -i "$cursor_text_y d" "$filename"
			# 替换文件中光标所处的上一行
		    sed -i "$((cursor_text_y-1)) c\\$newline" "$filename"
			# 改变光标位置
			Up # 行位置
			cursor_x=${#lastline} # 列位置
			# 如果上两行全是空行，用sed处理会取消两行，因此需要插入一个换行
			if [ ${#newline} -eq 0 ]
			then
			    InsertVisChar "\n" #插入换行
			fi
		fi
	fi
}
# 普通模式下读取并且处理用户输入
function NormalModeRead {
	# 读取用户输入
	read -sN1 key # 1个字符，静默
	read -sN1 -t 0.0001 k1
	read -sN1 -t 0.0001 k2
	read -sN1 -t 0.0001 k3
	key+=${k1}${k2}${k3} # 字符串拼接

	case "$key" in
	[[:graph:]]) # 可见字符
		if [[ "$key" == i* ]] # 如果输入i进入插入模式
		then
		    state=1
		elif [[ "$key" == :* ]] #如果输入:进入命令模式
		then
		    state=2
		fi
		;;
	$'\E[A'*) # 上方向键
		Up ;;
	$'\E[B'*) # 下方向键
		Down ;;
	$'\E[C'*) # 右方向键
		Right ;;
	$'\E[D'*) # 左方向键
		Left ;;
	# $'\E'*)
	# 	Esc ;;# Esc键
	$'\E[H'*) # home键
		;;
	$'\E[F'*) # end键
		;;
	$'\n'*) # 回车键
		Down ;;
	$'\t'*) # Tab键
		;;
	$' '*)
		Right ;; # 右键
	$'\b'*) # Backspace键
		Left ;;
	$''*)
		Left ;; # Backspace键
	esac
}

function InsertModeRead {
	# 读取用户输入
	read -sN1 key # 1个字符，静默
	read -sN1 -t 0.0001 k1
	read -sN1 -t 0.0001 k2
	read -sN1 -t 0.0001 k3
	key+=${k1}${k2}${k3} # 字符串拼接

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
	$'\E'*)   # Esc键
		Esc ;;
	$'\E[H'*) # home键
		;;
	$'\E[F'*) # end键
		;;
	$'\n'*)   # 回车键
		Enter;;
	$'\t'*)   # Tab键
		Tab;;
	$' '*)
		Space;;# 空格键
	$'\b'*)
		Backspace;;
	$''*)
		Backspace;;# Backspace键
	esac
}

# 普通模式
function NormalMode {
	# 读取键盘输入
	NormalModeRead
}

# 插入模式
function InsertMode {
	# 读取用户输入
	InsertModeRead
}
# 命令模式
function CommandMode {
    tput sc # 记录光标原位置
	tput cup $lines 0 # 将光标移动至页面左下端
	printf ":" # 打印左下端的冒号
    
	read character # 读取字符串
	if [ "$character" = "wq" ] # 保存并推出
	then
		return 1 # 如果退出返回值就为1
	elif [ "$character" = "q" ] # 退出不保存
	then
		cp "$filename.cp" "$filename" # 不保存就恢复原来文件
		return 1 # 如果退出返回值就为1
	elif [ "$character" = "w" ] # 保存
	then
	    state=0 # 切换为普通模式
	    tput rc # 将光标置位
		return 0 # 设定函数返回值
	fi
}

# 初始化
Init

# 接受用户输入
while true; do
	# 状态机：普通模式，插入模式和命令模式
	case "$state" in
	0)
		NormalMode;; # 普通模式
	1)
		InsertMode;; # 插入模式
	2)
	    CommandMode
		result="$?"
		if [ $result -eq 1 ]
		then
		    break
		fi
		;; # 命令模式
	esac
	textViewer # 重现文本
done

clear # 清理屏幕
# 恢复标准错误流
exec 2>&3
