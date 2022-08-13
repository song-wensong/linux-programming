#!/bin/bash

y=3
# x=4
x=4

echo ""
printf "%s" "第y行:"
sed -n "$y,$y p" "$1"

# sed -n "$y,$y p" "$1" | gawk 'BEGIN{FS=""} {print $1}'
# sed -n "$y,$y p" "$1" | gawk "BEGIN{FS=""} {print \$"$x"}"
# sed -n "$y,$y p" "$1" | gawk 'BEGIN{FS=""} {printf "%s" $$x}'
line=$(sed -n "$y,$y p" "$1")
printf "%s" "第y行:"
echo $line
printf "第x个字符:"
echo ${line:$x:1}

read -sn1 char
# 删除第五个
# echo $line | sed s/.//5
printf "删除第0个字符"
sed -n "$y,$y p" "$1" | sed "s/.//$((x-3))"
line=$(sed -n "$y,$y p" "$1" | sed "s/.//$((x-3))")
echo "$line"
# line=$(sed -n "$y,$y p" "$1" | sed s/.//0)

printf "替换第4个字符"
# 替换第五个
echo $line | sed s/./$char/$x

# 增加字符
# echo $line | sed 's/.\{7\}/& /'
# echo $line | sed "s/.\{7\}/&$char/"
printf "增加第四个字符，注意这个增加的字符处于第五个的位置"
echo $line | sed "s/.\{$x\}/&$char/"

echo "---------------"

printf "替换为新的一行"
line=$(sed -n "$y,$y p" "$1" | sed "s/.\{$x\}/&$char/")
echo line
# echo "------"
# sed -e -n "$y,$y p" "$1" "s/.\{$x\}/&$char/"

# printf "替换文件中的相应行\n"
# # 替换文件中相应行
# sed ""$y"c $line" "$1"