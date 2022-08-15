/**
 * @file main.c
 * @author 宋文松 3200102854
 * @brief 
 * @version 0.1
 * @date 2022-08-14
 * 
 * @copyright Copyright (c) 2022
 * 
 */

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<unistd.h>
#include<sys/wait.h>
#include<time.h>

#define COMMAND_BUFSIZE 256

void TypePrompt(void);// 在屏幕上显示提示符
char *ReadCommand(void);// 从键盘读取命令
char **ParseCommand(char *cmdLine);// 词法分析，分离参数
int ExecuteCommand(char **cmd);// 执行命令
int ExternalCmd(char **args);// 外部命令
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



// 设置内建命令
char *buildInStr[] = {"bg", "cd", "clr", "dir", "echo", "exec", "exit", "fg", "help", "jobs", "pwd", "set", "test", "time", "umask" };
// 函数指针数组
int (*buildInCmd[]) (char **) = {&myshell_bg, &myshell_cd, &myshell_clr, &myshell_dir, &myshell_echo, &myshell_exec, &myshell_exit, &myshell_fg, &myshell_help, &myshell_jobs, &myshell_pwd, &myshell_set, &myshell_test, &myshell_time, &myshell_umask}; 

int main(int argc, char **argv) { // 永远重复
    char *line;
    while (1) {
        TypePrompt();// 在屏幕上显示提示副

        char *cmdLine = ReadCommand();// 从键盘上读取输入行
        
        char **cmd = ParseCommand(cmdLine);// 词法分析，分离参数
        
        int status = ExecuteCommand(cmd);// 执行命令
        if (status == 0) {
            break;// 如果status返回值为0，继续执行命令
        }
        // if (isBuiltInCommand(cmd)) {
        //     executeBuildInCommand(cmd);
        // }
        // else {
        //     int childPid = fork();// 创建子进程 
        //     if (childPid < 0) {
        //         printf("Unable to fork 0");// 错误状态
        //         continue;// 重复循环
        //     }

        //     if (childPid == 0) {
        //         executeCommand(cmd); // 调用execvp
        //     }
        //     else {
        //         if (isBackgroundJob(cmd)) {
        //             // 记录在后台任务中
        //         }
        //         else {
        //             waitpid(childPid);// 父进程等待子进程
        //         }
        //     }
        // }
    }
    return 0;
}


void TypePrompt(void) {
    char *path = NULL;
    path = getcwd(NULL, 0);// getcwd动态分配buf，获取目录
    printf("\x1b[1;34m%s\x1b[0m$ ", path);
}

// 读取命令
char *ReadCommand(void) {
    // int bufSize = COMMAND_BUFSIZE;// 缓冲区大小
    // int position = 0;
    ssize_t bufSize = 0; // 缓冲区大小，getline动态分配
    char *command = NULL;// 
    if (getline(&command, &bufSize, stdin) == -1) {// 读取失败
        if (feof(stdin)) {// 接受到流结束标识符，比如文件结束标识符或者Ctrl-D
            exit(EXIT_SUCCESS);// 退出
        }
        else {
            perror("readcommand");// 打印错误信息
            exit(EXIT_FAILURE);// 退出程序
        }
    }

    // 注意，gitline是读入换行符的 debug
    return command;
}

// 词法分析，分离参数，空白字符为分隔符
char **ParseCommand(char *cmdLine) {
    int bufSize = COMMAND_BUFSIZE;// 申请内存大小
    
    char **tokens = malloc(sizeof(char*) * bufSize);

    // 判断申请内存是否成功
    if (tokens == NULL) {
        fprintf(stderr, "In ParseCommand function, allocation error\n");// 不成功打印错误信息
        exit(EXIT_FAILURE);
    }

    // 以空白字符为分隔符，得到第一个子字符串
    const char delim[6] = " \t\r\n\a";
    char *token = strtok(cmdLine, delim);
    int position = 0;
    while (token != NULL) {// 如果第一个子字符串分隔成功
        tokens[position] = token;// 保存子字符串
        position++;
        if (position > bufSize) {// 如果命令过长
            bufSize += COMMAND_BUFSIZE;
            tokens = realloc(tokens, sizeof(char*) * bufSize);
            if (tokens == NULL) {
                fprintf(stderr, "In ParseCommand function, allocation error\n");// 不成功打印错误信息
                exit(EXIT_FAILURE);// 因内存申请失败而退出程序
            }
        }
        token = strtok(NULL, delim);// 继续获取其他的子字符串
    }
    tokens[position] = NULL;// 置为NULL标志
    return tokens;
}


// 内建命令
int myshell_bg(char **args) {

}// bg命令
/**
 * @brief change directory
 * 
 * @param args args[0]为cd，args[1]为目录
 * @return int 
 */
int myshell_cd(char **args) {
    if (args[1] == NULL) {// 没有参数
        myshell_pwd(args);// 显示当前目录
        // fprintf(stderr, "myshell: expected argument to cd\n");
    }
    else {
        if (chdir(args[1]) != 0) {// 执行失败
            perror("cd error");// 打印错误信息
        }
    }
    return 1;// 继续执行
}
/**
 * @brief 清空屏幕，clear
 * 
 * @param args 
 * @return int 
 */
int myshell_clr(char **args) {
    printf("\e[1;1H\e[2J");
    return 1;// 继续执行
}// clr命令
int myshell_dir(char **args) {
    
}// dir命令
/**
 * @brief echo 命令，打印
 * 
 * @param args 
 * @return int 
 */
int myshell_echo(char **args) {
    int i = 1;
    for (int i = 1; args[i] != NULL; i++) {
        printf("%s ", args[i]);// 输出echo后的字符
    }
    printf("\n");
}
int myshell_exec(char **args) {

};//exec命令
/**
 * @brief 内建命令：exit
 * 
 * @param args 
 * @return int 
 */
int myshell_exit(char **args) {
    return 0;// 终止执行
}// exit命令
int myshell_fg(char **args) {

}// fg命令
int myshell_help(char **args) {

}// help命令
int myshell_jobs(char **args) {

}// jobs命令
int myshell_pwd(char **args) {
    char *path = NULL;
    path = getcwd(NULL, 0);// getcwd动态分配buf，获取目录
    printf("%s\n", path);// 输出当前目录
    return 1;// 继续执行
}// pwd命令
int myshell_set(char **args) {

}// set命令
int myshell_test(char **args) {

}// test命令
/**
 * @brief 显示当前时间
 * 
 * @param args 
 * @return int 恒为1，继续执行命令
 */
int myshell_time(char **args) {
    time_t t;
    time(&t);// 返回从公元 1970 年1 月1 日的UTC 时间从0 时0 分0 秒算起到现在所经过的秒数。
    char *time = ctime(&t);// 转换成真实世界所使用的时间日期表示方法
    printf("%s\n", time);// 打印时间
    return 1;
}// time命令

int myshell_umask(char **args) {

}// umask命令

// 执行命令
int ExecuteCommand(char **args) {
    if (args[0] == NULL) {
        return 1;// 输入空命令
    }
    int i;
    for (i = 0; i < (sizeof(buildInStr) / sizeof(char*)); i++) {
        // 遍历内建命令，查找与输入的命令相符合的
        if (strcmp(args[0], buildInStr[i]) == 0) {
            return (*buildInCmd[i])(args);// 如果找到符合的就执行命令
        }
    }
    return ExternalCmd(args);// 外部命令
}

int ExternalCmd(char **args) {
    pid_t pid = fork();
    if (pid == 0) {// 子进程
        // 替换为子进程
        if (execvp(args[0], args) == -1) {// 替换失败
            perror("myshell");
        }
        exit(EXIT_FAILURE);
    }
    else if (pid < 0) {// 错误状态
        perror("myshell");
    }
    else {// 父进程
        int status;// 存储退出状态
        do {
            pid_t wpid = waitpid(pid, &status, WUNTRACED);
        }while (!WIFEXITED(status) && !WIFSIGNALED(status));// 直到进程终止或者被kill
    }
    return 1;
}