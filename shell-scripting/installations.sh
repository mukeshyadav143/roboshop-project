
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
E="\e[0m"

if [ $USERID -ne 0 ]; then
    echo -e "ERROR:: Please run this script with ${R} root privelege ${E}"
    exit 1 # failure is other than 0
else 
    echo -e "${G} Running with root previlege sudo access ${E}"
fi

dnf install mysql -y

if [ $? -ne 0 ]; then
    echo -e "ERROR:: ${R} Installing MySQL is failure ${E}"
    exit 1
else
    echo -e "${G}Installing MySQL is SUCCESS ${E}"
fi

