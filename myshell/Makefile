# # 变量
# CC=gcc
# OBJ=myshell.o
# # 链接
# myshell:$(OBJ)
# 	$(CC) $(OBJ) -o $@ -lm
# # 编译
# %.o:%.c
# 	$(CC) -c $< -o $@
# # .PHONY表示clean不是一个文件而是一个命令的名字。
# .PHONY: clean
# # 清理所有生成文件的命令
# clean:
# 	rm *.o myshell


#变量
CC=gcc
OBJ=myshell.o built_in_command.o
#链接
myshell:$(OBJ)
	$(CC) $(OBJ) -o $@ -lm
#编译
myshell.o:myshell.c
	$(CC) -c $< -o $@
built_in_command.o:built_in_command.c
	$(CC) -c $< -o $@

# .PHONY表示clean不是一个文件而是一个命令的名字。
.PHONY: clean
clean:
	rm ./*.o myshell