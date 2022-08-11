#/bin/bash
# simple script menu

function menu {
    clear
    echo
    echo -e "\t\t\tSys Admin Menu\n"
    echo -e "\t1. Display disk space"
    echo -e "\t2. Display logged on users"
    echo -e "\t3. Display memory usage"
    echo -e "\t0. Exit program\n\n"
    echo -en "\t\tEnter option: "
    # read -n 1 option
    read option
}

function diskspace {
    clear
    echo "This is where the diskspace commands will go"
}

function diskspace {
    clear
    df -k
}
function whoseon {
    clear
    who
}
function memusage {
    clear
    cat /proc/meminfo
}
function Up {
    echo "There is Up function"
}
function Down {
    echo "There is Down function"
}
function Right {
    echo "There is Right function"
}
function Left {
    echo "There is Left function"
}
function Esc {
    echo "There is Esc function"
}

while [ 1 ]
do
    menu
    case $option in
    0)
        break ;;
    1)
        diskspace ;;
    2)
        whoseon ;;
    3)
        memusage ;;
    $'\E[A'*)
        Up;;
    $'\E[B'*)
        Down;;
    $'\E[C'*)
        Right;;
    $'\E[D'*)
        Left;;
    $'\E'*)
        Esc;;
    *)
        clear
        echo "Sorry, wrong selection";;
    esac
    echo -en "\n\n\t\t\tHit any key to continue"
    read -n 1 line
done
clear


# # using select in the menu
# function diskspace {
#     clear
#     df -k
# }
# function whoseon {
#     clear
#     who
# }
# function memusage {
#     clear
#     cat /proc/meminfo
# }

# PS3="Enter option: "
# select option in "Display disk space" "Display logged on users" "Display memory usage" "Exit program"
# do
#     case $option in
#     "Exit program")
#         break ;;
#     "Display disk space")
#         diskspace ;;
#     "Display logged on users")
#         whoseon ;;
#     "Display memory usage")
#         memusage ;;
#     *)
#         clear
#         echo "Sorry, wrong selection";;
#     esac
# done
# clear