#checking the root access

user_id=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -eq 0 ]; then 
    echo -e "${G} proceeding installations wih root access ${N}"
else 
    echo "please proceed wih ${R} root access ${N}"
    exit 1
fi

dnf install mysql -y

if [ $? -eq 0 ]; then
    echo "mysql isntallation ${G} is success ${N}"
else 
    echo "mysql installation is ${R} failure ${N}"
    exit 1
fi

