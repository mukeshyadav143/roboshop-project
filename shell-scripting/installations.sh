
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
E="\e[0m"

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with ${R} root privelege ${N}"
    exit 1 # failure is other than 0
else 
    echo "Running with root previlege sudo access"
fi

dnf install mysql -y

if [ $? -ne 0 ]; then
    echo "ERROR:: Installing MySQL is failure"
    exit 1
else
    echo "Installing MySQL is SUCCESS"
fi

