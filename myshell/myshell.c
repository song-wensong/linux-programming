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
char *buildInStr[] = {"bg", "cd", "clr", "dir", "echo", "exec", "exit", "fg", "help", "jobs", "pwd", "set", "test", "time", "umask", "environ"};
// 函数指针数组
int (*buildInCmd[]) (char **) = {&myshell_bg, &myshell_cd, &myshell_clr, &myshell_dir, &myshell_echo, &myshell_exec, &myshell_exit, &myshell_fg, &myshell_help, &myshell_jobs, &myshell_pwd, &myshell_set, &myshell_test, &myshell_time, &myshell_umask, &myshell_environ};
// 全局变量
int IsPipe = 0;             // 是否有管道操作
int PipePos = 0;            // 管道操作符位置
int IsOutRedirectCover = 0; // 是否输出重定向
int IsOutRedirectApp = 0;   // 是否输出追加
int IsInRedirect = 0;       // 是否输入重定向
int OutRedirectPos = 0;     // 输出重定向操作符位置
int InRedirectPos = 0;      // 输入重定向操作符位置

int main(int argc, char **argv) {
    char *line;
    char path[50];
    getcwd(path, 50);// getcwd动态分配buf，获取目录
    // printf("%s\n", strcat(path, "/myshell"));// debug
    setenv("SHELL", strcat(path, "/myshell"), 1);// 将SHELL的值设定为myshell
    int IsFile = 0; // 判断是否有脚本输入
    while (1) {
        InitGlobalVar();// 初始化全局变量
        char *cmdLine = NULL;
        if (argc == 1) {// 没有参数传入
            TypePrompt();// 在屏幕上显示提示符
            cmdLine = ReadCommand(stdin);// 从键盘上读取输入行
        }
        else if (argc == 2) {// 从文件中提取命令行输入
            FILE *fp;// 文件指针
            if (IsFile == 0) {// 打开文件
                IsFile = 1;// 打开标志设置为1
                if((fp = fopen(argv[1], "r")) == NULL){
                    fprintf(stderr, "myshell: Error: Cannot open the %s file\n", argv[1]);
                    exit(1);
                }
            }
            else {
                cmdLine = ReadCommand(fp);// 文件已经打开，从文件中读取命令
            }
        }
        if (cmdLine != NULL) {
            char **cmd = ParseCommand(cmdLine);// 词法分析，分离参数
            int status = ExecuteCommand(cmd);// 执行命令
            if (status == 0) {
                break;// 如果status返回值为0，继续执行命令
            }
        }
    }
    return 0;
}

/**
 * @brief 初始化全局变量
 * 
 */
void InitGlobalVar(void) {
    IsPipe = 0;             // 是否有管道操作
    PipePos = 0;            // 管道操作符位置
    IsOutRedirectCover = 0; // 是否输出重定向
    IsOutRedirectApp = 0;   // 是否输出追加
    IsInRedirect = 0;       // 是否输入重定向
    OutRedirectPos = 0;     // 输出重定向操作符位置
    InRedirectPos = 0;      // 输入重定向操作符位置
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
char *ReadCommand(FILE *fp) {
    ssize_t bufSize = 0; // 缓冲区大小，getline动态分配
    char *command = NULL;// 存储命令
    // int isFile;
    // if (fp == NULL) {
    //     isFile = 0;// 标准输入
    //     fp = stdin;
    // }
    // else {
    //     isFile = 1;// 文件中读取
    // }

    // if (fp == NULL) {
    //     fp = stdin;
    // }
    if (getline(&command, &bufSize, fp) == -1) {// 读取失败
        if (feof(fp)) {// 接受到流结束标识符，比如Ctrl-D
            exit(EXIT_SUCCESS);// 退出
        }
        else {
            fprintf(stderr, "myshell: read command failed");// 打印错误信息
            fclose(fp);
            exit(EXIT_FAILURE);// 退出程序
        }
    }
    // if (getline(&command, &bufSize, fp) == -1) {// 读取失败
    //     if (feof(fp)) {// 接受到流结束标识符，比如Ctrl-D
    //         exit(EXIT_SUCCESS);// 退出
    //     }
    //     else {
    //         fprintf(stderr, "myshell: read command failed");// 打印错误信息
    //         if (isFile == 1) {
    //             fclose(fp);
    //         }
    //         exit(EXIT_FAILURE);// 退出程序
    //     }
    // }
    return command;// 返回命令
}

// 词法分析，分离参数，空白字符为分隔符
char **ParseCommand(char *cmdLine) {
    int bufSize = COMMAND_BUFSIZE;// 申请内存大小
    
    char **tokens = malloc(sizeof(char*) * bufSize);

    // 判断申请内存是否成功
    if (tokens == NULL) {
        fprintf(stderr, "In ParseCommand function, allocation error\n");// 不成功打印错误信息
        exit(EXIT_FAILURE);// 不成功则退出程序
    }

    const char delim[6] = " \t\r\n\a"; // 以空白字符为分隔符，得到第一个子字符串
    int position = 0;
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
        // printf("%s\n", args[OutRedirectPos + 1]);// debug
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

    char **args1 = malloc(sizeof(char*) * 128);;
    for (int i = 0; i < 128; i++) args1[i] = (char*)malloc(sizeof(char) * 64);
    if (IsPipe) {// 管道操作
        args[PipePos] = NULL;// 将管道符号位置置为NULL
        int i;
        for (i = PipePos + 1; args[i] != NULL && (i - PipePos) < 128; i++) {
            strncpy(args1[i - PipePos - 1], args[i], 64);
        }
        args1[i - PipePos - 1] = NULL;
        int fd[2];// fd[0]为读而打开，fd[1]为写而打开
        if (pipe(fd) == -1) {// 失败
            fprintf(stderr, "myshell: create pipe failed\n");// debug
            exit(EXIT_FAILURE);// 退出程序
        }
        pid_t pid = fork();// 创建子进程
        if (pid < 0) {// 创建失败
            fprintf(stderr, "In 246, myshell: create process failed\n");// debug
            exit(EXIT_FAILURE);// 失败退出
        }
        else if (pid == 0) {// 子进程
            dup2(fd[1], 1);// 重定向标准输入，写入管道
            close(fd[0]);// 关闭管道输出端
            int isBuildInCmd = 0;// 是否为内置命令
            for (int i = 0; i < (sizeof(buildInStr) / sizeof(char*)); i++) {
                // 遍历内建命令，查找与输入的命令相符合的
                if (strcmp(args[0], buildInStr[i]) == 0) {
                    result = (*buildInCmd[i])(args);// 如果找到符合的就执行命令
                    isBuildInCmd = 1;
                    break;
                }
            }
            if (isBuildInCmd == 0) {// 不是内部命令
                if (execvp(args[0], args) == -1) {// 执行外部命令
                    fprintf(stderr, "In 263, myshell: execute command failed\n");
                }
                result = 1;// 外部命令执行完成
            }
            exit(EXIT_SUCCESS);// 正常退出子进程
        }
        else if (pid > 0) {// 父进程
            int status;
            waitpid(pid, &status, 0);// 阻塞父进程
            pid_t pid1 = fork();// 创建子进程
            if (pid1 == -1) {
                fprintf(stderr, "myshell: create process failed\n");
            }
            else if (pid1 == 0) {// 子进程
                close(fd[1]);// 关闭管道输入端
                dup2(fd[0], 0);// 重定向标准输入到管道输出
                int isBuildInCmd = 0;// 是否为内置命令
                for (int i = 0; i < (sizeof(buildInStr) / sizeof(char*)); i++) {
                    // 遍历内建命令，查找与输入的命令相符合的
                    if (strcmp(args1[0], buildInStr[i]) == 0) {
                        result = (*buildInCmd[i])(args1);// 如果找到符合的就执行命令
                        isBuildInCmd = 1;
                        break;
                    }
                }
                if (isBuildInCmd == 0) {// 不是内部命令
                    if (execvp(args1[0], args1) == -1) {// 执行外部命令
                        fprintf(stderr, "In 290, myshell: execute command failed\n");
                    }
                    result = 1;// 外部命令执行完成
                }
                exit(EXIT_SUCCESS);// 正常退出子进程
            }
            else if (pid > 0) {// 主进程
                close(fd[0]);// 关闭管道输入
                close(fd[1]);// 关闭管道输出
                waitpid(pid1, &status, 0);// 等待子进程结束
            }
        }
        return result;
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
        }
    }
    if (IsOutRedirectCover || IsOutRedirectApp) {// 输出重定向
        if (dup2(fdStdout, fileno(stdout)) == -1) {
            // 输出重定向恢复为标准输入失败
            fprintf(stderr, "myshell: dup2() stdout failed\n");
            close(fdStdout);// 关闭文件
        }
    }

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