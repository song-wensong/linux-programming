# 变量
CC=gcc
OBJ=main.o
# 链接
main:$(OBJ)
	$(CC) $(OBJ) -o $@ -lm
# 编译
%.o:%.c
	$(CC) -c $< -o $@
# .PHONY表示clean不是一个文件而是一个命令的名字。
.PHONY: clean
# 清理所有生成文件的命令
clean:
	rm ./*.o main