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

#include "myshell.h"
#include "built_in_command.h"
// 设置内建命令
char *buildInStr[] = {"bg", "cd", "clr", "dir", "echo", "exec", "exit", "fg", "help", "jobs", "pwd", "set", "test", "time", "umask" };
// 函数指针数组
int (*buildInCmd[]) (char **) = {&myshell_bg, &myshell_cd, &myshell_clr, &myshell_dir, &myshell_echo, &myshell_exec, &myshell_exit, &myshell_fg, &myshell_help, &myshell_jobs, &myshell_pwd, &myshell_set, &myshell_test, &myshell_time, &myshell_umask};
int IsPipe = 0;// 是否有管道操作
int PipePos = 0;// 管道操作符位置
int IsOutRedirectCover = 0;// 是否输出重定向
int IsOutRedirectApp = 0;// 是否输出追加
int IsInRedirect = 0;// 是否输入重定向
int OutRedirectPos = 0;// 输出重定向操作符位置
int InRedirectPos = 0;// 输入重定向操作符位置


int main(int argc, char **argv) { // 永远重复
    char *line;

    char path[50];
    getcwd(path, 50);// getcwd动态分配buf，获取目录
    printf("%s\n", strcat(path, "/myshell"));
    setenv("SHELL", strcat(path, "/myshell"), 1);// 将SHELL的值设定为myshell

    while (1) {
        InitGlobalVar();// 初始化全局变量

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

/**
 * @brief 初始化全局变量
 * 
 */
void InitGlobalVar(void) {
    IsPipe = 0;// 是否有管道操作
    PipePos = 0;// 管道操作符位置
    IsOutRedirectCover = 0;// 是否输出重定向
    IsOutRedirectApp = 0;// 是否输出追加
    IsInRedirect = 0;// 是否输入重定向
    OutRedirectPos = 0;// 输出重定向操作符位置
    InRedirectPos = 0;// 输入重定向操作符位置
}
/**
 * @brief 打印命令行提示符，当前路径
 * 
 */
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
    int position = 0;
    
    // char *token;
    // while ((token = strtok(cmdLine, delim)) != NULL) {
    //     tokens[position] = token;// 保存子字符串
    //     if (strcmp(token, "|") == 0) {// 管道
    //         IsPipe = 1;// 管道信号置为1
    //         PipePos = position;// 记录管道位置
    //     }
    //     position++;
    //     if (position > bufSize) {// 如果命令过长
    //         bufSize += COMMAND_BUFSIZE;
    //         tokens = realloc(tokens, sizeof(char*) * bufSize);
    //         if (tokens == NULL) {
    //             fprintf(stderr, "In ParseCommand function, allocation error\n");// 不成功打印错误信息
    //             exit(EXIT_FAILURE);// 因内存申请失败而退出程序
    //         }
    //     }
    // }
    char *token = strtok(cmdLine, delim);
    while (token != NULL) {// 如果第一个子字符串分隔成功
        tokens[position] = token;// 保存子字符串
        if (strcmp(token, "|") == 0) {// 管道
            IsPipe = 1;// 管道信号置为1
            PipePos = position;// 记录管道位置
        }
        if (strcmp(token, ">") == 0) {// 输出重定向，覆盖
            IsOutRedirectCover = 1;
            OutRedirectPos = position;
        }
        if (strcmp(token, ">>") == 0) {// 输出重定向，追加
            IsOutRedirectApp = 1;
            OutRedirectPos = position;
        }
        if (strcmp(token, "<") == 0) {// 输入重定向
            IsInRedirect = 1;
            InRedirectPos = position;
        }
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


// 执行命令
int ExecuteCommand(char **args) {
    if (args[0] == NULL) {
        return 1;// 输入空命令
    }
    int result = 1;// 保存返回值
    // 备份stdin和stdout的文件描述符
    int fdStdin = dup(fileno(stdin));
    int fdStdout = dup(fileno(stdout));
    if (IsInRedirect) {// 输入重定向
        args[InRedirectPos] = NULL;// 将输入重定向符号置为NULL，结尾标志服
        if (args[InRedirectPos + 1] == NULL) {
            fprintf(stderr, "myshell: syntax error, < lack file\n");
            exit(EXIT_FAILURE);// 输入重定向缺少文件
        }
        int fd = open(args[InRedirectPos + 1], O_RDONLY, 0666);//  
        if (fd == -1) {
            fprintf(stderr, "myshell: open %s failed\n", args[InRedirectPos + 1]);
            exit(EXIT_FAILURE);
        }
        if (dup2(fd, fileno(stdin)) == -1) {
            // 将标准输入重定向到文件中
            fprintf(stderr, "myshell: dup2() stdin failed\n");
            close(fd);// 关闭文件
            exit(EXIT_FAILURE);// 退出程序
        }
    }
    if (IsOutRedirectCover) {// 输出重定向，覆盖
        printf("%s\n", args[OutRedirectPos + 1]);// debug
        args[OutRedirectPos] = NULL;// 将输出重定向符号位置置为NULL，结尾标志符
        if (args[OutRedirectPos + 1] == NULL) {
            fprintf(stderr, "myshell: syntax error, > lack file\n");
            exit(EXIT_FAILURE);// 输出重定向缺少文件
        }
        // 覆盖方式打开
        int fd = open(args[OutRedirectPos + 1], O_RDWR | O_CREAT | O_TRUNC, 0666);
        if (fd == -1) {// 打开失败
            fprintf(stderr, "myshell: open %s failed\n", args[OutRedirectPos + 1]);
            exit(EXIT_FAILURE);
        }
        if (dup2(fd, fileno(stdout)) == -1) {
            // 将标准输出重定向到文件中
            fprintf(stderr, "myshell: dup2() stdout failed\n");
            close(fd);// 关闭文件
            exit(EXIT_FAILURE);// 退出程序
        }
    }
    if (IsOutRedirectApp) {// 输出重定向，追加
        args[OutRedirectPos] = NULL;// 将输出重定向符号位置置为NULL，结尾标志服
        if (args[OutRedirectPos + 1] == NULL) {
            fprintf(stderr, "myshell: syntax error, > lack file\n");
            exit(EXIT_FAILURE);// 输出重定向缺少文件
        }
        // 追加方式打开
        int fd = open(args[OutRedirectPos + 1], O_RDWR | O_CREAT | O_APPEND, 0666);
        if (fd == -1) {// 打开失败
            fprintf(stderr, "myshell: open %s failed\n", args[OutRedirectPos + 1]);
            exit(EXIT_FAILURE);
        }
        if (dup2(fd, fileno(stdout)) == -1) {
            // 将标准输出重定向到文件中
            fprintf(stderr, "myshell: dup2() stdout failed\n");
            close(fd);// 关闭文件
            exit(EXIT_FAILURE);// 退出程序
        }
    }
    
    int isBuildInCmd = 0;
    for (int i = 0; i < (sizeof(buildInStr) / sizeof(char*)); i++) {
        // 遍历内建命令，查找与输入的命令相符合的
        if (strcmp(args[0], buildInStr[i]) == 0) {
            result = (*buildInCmd[i])(args);// 如果找到符合的就执行命令
            isBuildInCmd = 1;
            break;
        }
    }
    // printf("isBuildInCmd = %d\n", isBuildInCmd);// debug
    if (isBuildInCmd == 0) {// 不是内部命令
        result = ExternalCmd(args);// 执行外部命令
    }
    // printf("isBuildInCmd = %d\n", isBuildInCmd);// debug
    if (IsInRedirect) {// 输入重定向
        if (dup2(fdStdin, fileno(stdin)) == -1) {
            // 输入重定向恢复为标准输入失败
            fprintf(stderr, "myshell: dup2() stdin failed\n");
            close(fdStdin);// 关闭文件
            exit(EXIT_FAILURE);// 退出程序
        }
    }
    if (IsOutRedirectCover || IsOutRedirectApp) {// 输出重定向
        if (dup2(fdStdout, fileno(stdout)) == -1) {
            // 输出重定向恢复为标准输入失败
            fprintf(stderr, "myshell: dup2() stdout failed\n");
            close(fdStdout);// 关闭文件
            exit(EXIT_FAILURE);// 退出程序
        }
    }
    // printf("well, command execute finish\n");// debug
    return result;
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