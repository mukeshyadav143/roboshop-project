
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
E="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "ERROR:: ${R} Please run this script with  root privelege ${E}"
    exit 1 # failure is other than 0
else 
    echo -e "${G} Running with root previlege sudo access ${E}"
fi

validate() {    # here this function can take the args like in the shell script  
    if [ $1 -ne 0 ]; then
        echo -e "ERROR:: ${R} Installing $2 is failure ${E}"
        exit 1
    else
        echo -e "${G}Installing $2 is SUCCESS ${E}"
    fi
}

dnf install mysql -y
validate $? "mysql"

dnf install nginx -y
validate $? "nginx"

dnf install python3 -y
validate $? "python3"

