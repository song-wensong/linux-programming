#include "built_in_command.h"

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
/**
 * @brief dir命令
 * 
 * @param args 
 * @return int 
 */
int myshell_dir(char **args) {
    DIR *dir; // DIR类型指针
    struct dirent *pdir;// dirent结构指针
    if (args[1] == NULL || args[2] == NULL) {// 没有参数
        char *path = (char*)malloc(sizeof(char) * 30);// 因为下面要strcpy，因此这里定义不能指向NULL
        if (args[1] == NULL) {// 没有参数
            path = getcwd(NULL, 0);// getcwd动态分配buf，获取目录
        }
        else {// 一个参数
            strcpy(path, args[1]);
        }
        dir = opendir(path);// 打开目录
        while ((pdir = readdir(dir)) != NULL) {// 读取目录项
            if (strcmp(pdir->d_name, ".") && strcmp(pdir->d_name, "..")) {
                printf("%s ", pdir->d_name);// 忽略.和..，其他目录打印
            }
        }
        printf("\n");
        closedir(dir);// 关闭目录
    }
    return 1;
}
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
    return 1;
}
/**
 * @brief exec命令
 * 用要被执行命令替换当前的shell进程，并且将老进程的环境清理掉，而且exec命令后的其它命令将不再执行
 * @param args 
 * @return int 
 */
int myshell_exec(char **args) {
    if (args[1] == NULL) {
        // 没有参数
    }
    else if (args[2] == NULL) {// 一个参数
        if (execvp(args[1], args) == -1) {// 执行失败
            fprintf(stderr, "myshell: exec: %s: not found\n", args[1]);// 输出错误提示信息
        }
    }

};
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
/**
 * @brief pwd命令
 * 打印当前工作目录
 * @param args 
 * @return int 
 */
int myshell_pwd(char **args) {
    char *path = NULL;
    path = getcwd(NULL, 0);// getcwd动态分配buf，获取目录
    printf("%s\n", path);// 输出当前目录
    return 1;// 继续执行
}
/**
 * @brief 列出所有的环境变量
 * 
 * @param args 
 * @return int 
 */
int myshell_set(char **args) {
    printf("set\n");
    extern char **environ;// 环境指针
    for (int i = 0; environ[i] != NULL; i++) {
        printf("%s\n", environ[i]);
    }
    return 1;
}
/**
 * @brief 判断有无参数，如果是1个参数该参数是否有内容，如果是3个参数进行字符串比较
 * 
 * @param args 
 * @return int 
 */
int myshell_test(char **args) {
    if (args[1] == NULL) {// 没有参数
        printf("false\n");// 没有参数返回false
    }
    else if (args[2] == NULL) {// 1个参数
        if (strcmp(args[1], "") == 0) {
            printf("false\n");// 参数为空返回false
        }
        else {
            printf("true\n");// 参数不为空返回true
        }
    }
    else if (args[3] != NULL && args[4] == NULL) {// 3个参数
        // 字符串比较
        // 字符串是否相等
        if (strcmp(args[2], "-eq") == 0 || strcmp(args[2], "==") == 0)
            if (strcmp(args[1], args[3]) == 0)
                printf("true\n");
            else
                printf("flase\n");
        // 字符串1是否大于等于2
        else if (strcmp(args[2], "-ge") == 0 || strcmp(args[2], ">=") == 0)
            if (strcmp(args[1], args[3]) >= 0)
                printf("true\n");
            else
                printf("flase\n");
        // 字符串1是否大于2
        else if (strcmp(args[2], "-gt") == 0 || strcmp(args[2], ">") == 0)
            if (strcmp(args[1], args[3]) > 0)
                printf("true\n");
            else
                printf("flase\n");
        // 字符串1是否小于等于2
        else if (strcmp(args[2], "-le") == 0 || strcmp(args[2], "<=") == 0)
            if (strcmp(args[1], args[3]) <= 0)
                printf("true\n");
            else
                printf("flase\n");
        // 字符串1是否小于2
        else if (strcmp(args[2], "-lt") == 0 || strcmp(args[2], "<") == 0)
            if (strcmp(args[1], args[3]) < 0)
                printf("true\n");
            else
                printf("flase\n");
        // 字符串1是否不等于2
        else if (strcmp(args[2], "-ne") == 0 || strcmp(args[2], "!=") == 0)
            if (strcmp(args[1], args[3]) != 0)
                printf("true\n");
            else
                printf("flase\n");
        // if (strcmp(args[2], "-eq") == 0) // 字符串比较
        //     if (strcmp(args[1], args[3]) == 0)
        //         printf("true\n");
        //     else
        //         printf("flase\n");
        // else if (strcmp(args[2], "-ge") == 0)
        //     if (strcmp(args[1], args[3]) >= 0)
        //         printf("true\n");
        //     else
        //         printf("flase\n");
        // else if (strcmp(args[2], "-gt") == 0)
        //     if (strcmp(args[1], args[3]) > 0)
        //         printf("true\n");
        //     else
        //         printf("flase\n");
        // else if (strcmp(args[2], "-le") == 0)
        //     if (strcmp(args[1], args[3]) <= 0)
        //         printf("true\n");
        //     else
        //         printf("flase\n");
        // else if (strcmp(args[2], "-lt") == 0)
        //     if (strcmp(args[1], args[3]) < 0)
        //         printf("true\n");
        //     else
        //         printf("flase\n");
        // else if (strcmp(args[2], "-ne") == 0)
        //     if (strcmp(args[1], args[3]) != 0)
        //         printf("true\n");
        //     else
        //         printf("flase\n");
        // else if (strcmp(args[2], "=") == 0)
        //     if (strcmp(args[1], args[3]) == 0)
        //         printf("true\n");
        //     else
        //         printf("flase\n");
        // else if (strcmp(args[2], "!=") == 0)
        //     if (strcmp(args[1], args[3]) != 0)
        //         printf("true\n");
        //     else
        //         printf("flase\n");
        // else if (strcmp(args[2], ">") == 0)
        //     if (strcmp(args[1], args[3]) > 0)
        //         printf("true\n");
        //     else
        //         printf("flase\n");
        // else if (strcmp(args[2], "-<") == 0)
        //     if (strcmp(args[1], args[3]) < 0)
        //         printf("true\n");
        //     else
        //         printf("flase\n");
    }
    else {// 其他情况
        fprintf(stderr, "myshell: test eroor");
    }
}
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
    printf("%s", time);// 打印时间
    return 1;
}// time命令
/**
 * @brief 输出当前系统默认的umask值或者设定当前系统umask值
 * 
 * @param args 
 * @return int 
 */
int myshell_umask(char **args) {
    if (args[1] == NULL) {// 没有参数
        mode_t cur_mask = umask(0);// 得到当前掩码
        printf("%04d\n", cur_mask);
    }
    else {
        if (atoi(args[1]) > 777 || atoi(args[1]) < 0) {// 如果umask数值超出范围，输出错误提示信息
            printf("myshell: umask: %s: octal number out of range\n", args[1]);
        }
        else {
            umask(atoi(args[1]));// 设定umask值
        }
    }
    return 1;// 继续执行
}