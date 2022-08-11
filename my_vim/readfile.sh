#/bin/bash


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

# read line
# echo "$line"