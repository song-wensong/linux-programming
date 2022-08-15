#ifndef _BUILT_IN_COMMAND_H_
#define _BUILT_IN_COMMAND_H_

// 头文件包含
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<unistd.h>
#include<sys/wait.h>
#include<time.h>
#include<dirent.h>
// 函数umask
#include<sys/stat.h>
// 内建命令
int myshell_bg(char **args);// bg命令
int myshell_cd(char **args);// cd命令
int myshell_clr(char **args);// clr命令
int myshell_dir(char **args);// dir命令
int myshell_echo(char **args);// echo命令
int myshell_exec(char **args);//exec命令
int myshell_exit(char **args);// exit命令
int myshell_fg(char **args);// fg命令
int myshell_help(char **args);// help命令
int myshell_jobs(char **args);// jobs命令
int myshell_pwd(char **args);// pwd命令
int myshell_set(char **args);// set命令
int myshell_test(char **args);// test命令
int myshell_time(char **args);// time命令
int myshell_umask(char **args);// umask命令
int myshell_environ(char **args);// envirom命令

#endif