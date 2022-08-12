#/bin/bash

clear

y=1
cursor_x=1
filename="$1"
line=$(sed -n "$y p" "$1")
# line=$(sed -n "$y,$y p" "$1")
printf "第%s行:" "$y"
echo "$line"
printf "行长度"
echo ${#line}
printf "第%s个字符:" "$cursor_x"
echo "${line:$cursor_x:1}"

printf "保留前%s个字符:" "$cursor_x"
# echo ${line:0:1}
# begin=${$line:0:$cursor_x}

begin=${line:0:cursor_x}
printf "%s" "$begin"
# printf "%s" ${line:0:cursor_x}
# printf "%s" $line | sed -r "s/(.{$cursor_x}).*/\1/"
printf "\n"

printf "保留结尾%s个字符" 
end=${line:cursor_x}
# echo $end
printf "%s\n" "$end"




function Backspace {
    if [ $cursor_x -gt 0 ]
	then
	    # 取出第cursor_text_y行
		local line=$(sed -n "$y p" "$filename")
        echo "$line"
		# 提取第cursor_text_y行字符串的前部分和后半部分
		local begin=${line:0:cursor_x-1} # 位置:长度
        echo "$begin"
		local end=${line:cursor_x}
        echo "$end"
		line="$begin$end"
        echo "$line"
        
		# 替换文件中相应行
		sed -i ""$y"c $line" "$filename"
		# sed -i "$filename" ""$y"c $line" "$filename"
		
	fi
}
printf "Backspace:\n"
Backspace

# 增加一个字符
# read -sN1 char

# printf "%s字符,注意这个增加的字符处于后一个的位置" "$cursor_x"
# # echo $line | sed "s/.\{$cursor_x\}/&$char/"
# line="$begin$char$end"
# echo "$line"

# # backspace
# end=${line:cursor_x+1}
# # echo $end
# printf "%s\n" "$end"
# line="$begin$char$end"
# echo "$line"

# # printf "%s" $line | sed -r "s/.*(.{$cursor_x})/\1/"
# printf "%d\n" ${#line}
# printf "%s" $line | sed -r "s/.*(.{$((${#line}-$cursor_x))})/\1/"
# printf "\n"




# printf "替换文件中的相应行\n"
# # 替换文件中相应行
# sed  ""$y"c $begin" "$1"

# printf "增加一行\n"
# sed "$y a $end" "$1"