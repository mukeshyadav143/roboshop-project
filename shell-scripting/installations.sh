#checking the root access

user_id=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
E="\e[0m"

if [ $user_id -eq 0 ]; then 
    echo -e "$R proceeding installations wih root access $E"
else 
    echo "please proceed wih root access"
    exit 1
fi

dnf remove nginx -y

if [ $? -ne 0 ]; then
    echo "mysql isntallation is success"
else 
    echo "mysql installation is failure"
    exit 1
fi