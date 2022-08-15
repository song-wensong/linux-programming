#ifndef _MYSHELL_H_
#define _MYSHELL_H_

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<unistd.h>
#include<sys/wait.h>
#include<time.h>
#include<dirent.h>
#include<fcntl.h>

#define COMMAND_BUFSIZE 256

void TypePrompt(void);// 在屏幕上显示提示符
char *ReadCommand(FILE *fp);// 从键盘读取命令
char **ParseCommand(char *cmdLine);// 词法分析，分离参数
int ExecuteCommand(char **cmd);// 执行命令
int ExternalCmd(char **args);// 外部命令
void InitGlobalVar(void);// 初始化外部命令 

#endif