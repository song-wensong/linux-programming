#/bin/bash

# cat cursor.sh

y=1
x=4

echo ""
sed -n "$y,$y p" "$1"

# sed -n "$y,$y p" "$1" | gawk 'BEGIN{FS=""} {print $1}'
# sed -n "$y,$y p" "$1" | gawk "BEGIN{FS=""} {print \$"$x"}"
# sed -n "$y,$y p" "$1" | gawk 'BEGIN{FS=""} {printf "%s" $$x}'
line=$(sed -n "$y,$y p" "$1")
echo $line
echo ${line:$x:1}

read -sn1 char
# 删除第五个
# echo $line | sed s/.//5
# 替换第五个
echo $line | sed s/./$char/$x

# 增加字符
# echo $line | sed 's/.\{7\}/& /'
# echo $line | sed "s/.\{7\}/&$char/"
echo $line | sed "s/.\{$x\}/&$char/"

echo "---------------"
line=$(sed -n "$y,$y p" "$1" | sed "s/.\{$x\}/&$char/")
echo line
# echo "------"
# sed -e -n "$y,$y p" "$1" "s/.\{$x\}/&$char/"

# 替换文件中相应行
sed ""$y"c $line" "$1"



# arr_line=($line)

# IFS_OLD=$IFS
# IFS=
# echo ${arr_line[*]}

# echo ${#arr_line[*]}
# echo ${arr_line[0]}
# IFS=$IFS_OLD

# for ((i=0;i<${#arr_line[*]};i++))
# do
#     echo "$i:${arr[$i]}"
# done

